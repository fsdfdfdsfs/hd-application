local module = {}
 
-- Config
local WantDebugs = true -- if true it will print a bunch of stuff
local TimeNotificationLasts = 5 -- how long a notification lasts before it fades out
local WantDebounce = true -- if true then is will allow messages to only be sent after the debounce time
local DebounceTime = 0.5 -- how often a message can be sent if WantDebounce if false this will not be applied
-- WARNING THE SYSTEM BELOW DOES NOT CURRENTLY WORK SO YOU NEED TO INPUT ALL VARIABLES
local DefaultSettings = {nil,"client","bottomright","Value not set.",Color3.new(255,255,255),true,0} -- What all the variables will be if they are not inputed when sendNotification gets called
 
local AmountOfNotifications = 0
local TweenService = game:GetService("TweenService")
local ServerWideNotificationEvent = nil
local ServerWideNotificationEventHasBeenMade = false
local DebounceEnabled = false
local CurrentDebounceTime = 0
local MessageQueue = {}
 
--[[
--CURRENT ISSUES
default settings dont work text is set to nil not the value
 
--]]
 
--fixed vars
module.FixedBackGroundTransparency = nil
module.FixedNotificationType = nil
module.FixedNotificationPosition = nil
module.FixedText = nil
module.FixedBacgroundColor = nil
module.FixedHasRoundedCorners = nil
module.FixedBackgroundColor = nil
 
task.spawn(function()
	if WantDebounce then
		if CurrentDebounceTime > CurrentDebounceTime then
			CurrentDebounceTime = CurrentDebounceTime
		end
		if CurrentDebounceTime > 0  then
			DebounceEnabled = true
			CurrentDebounceTime -= 1
		else
			DebounceEnabled = false
		end
	end
	wait(DebounceTime)
end)
 
 
function module.Debugs(IsWarning,text)
	if WantDebugs == true then
		if IsWarning then
			warn(text)
		else
			print(text)
		end
	end
end
 
 
function module.SetUiPosition (CurrentUi,ScreenPosition)
	if ScreenPosition == "bottomright" then
		CurrentUi.Position = UDim2.new(0.694, 0,0.724, 0)
	end
 
	if ScreenPosition == "bottomleft" then
		CurrentUi.Position = UDim2.new(0.07, 0,0.724, 0)
	end
 
	if ScreenPosition == "bottommiddle" then
		CurrentUi.Position = UDim2.new(0.381, 0,0.724, 0)
	end
 
	if ScreenPosition == "middleleft" then
		CurrentUi.Position = UDim2.new(0.07, 0,0.471, 0)
	end
 
	if ScreenPosition == "center" then
		CurrentUi.Position = UDim2.new(0.381, 0,0.471, 0)
	end
 
	if ScreenPosition == "middleright" then
		CurrentUi.Position = UDim2.new(0.694, 0,0.724, 0)
	end
 
	if ScreenPosition == "topright" then
		CurrentUi.Position = UDim2.new(0.694, 0,0.218, 0)
	end
 
	if ScreenPosition == "topmiddle" then
		CurrentUi.Position = UDim2.new(0.381, 0,0.218, 0)
	end
 
	if ScreenPosition == "topleft" then
		CurrentUi.Position = UDim2.new(0.07, 0,0.218, 0)
	end
end
 
function module.fadeout(Player,CurrentNotification)
	module.Debugs(false,"Running fadeout")
	local goal = {BackgroundTransparency = 1, TextTransparency = 1}
	local TweenService = game:GetService("TweenService")
	local CurrentNotificationGui = Player.PlayerGui:WaitForChild("Notification"..tostring(CurrentNotification)):WaitForChild("TextLabel")
	local tween = TweenService:Create(CurrentNotificationGui, TweenInfo.new(1), goal)
	tween:Play()
end
 
function module.MoveAllNotificationsManager(Player,CurrentNotification,CurrentUi,Position)
	if Position == "bottomright" then
		module.MoveAllNotificationsUp(Player,CurrentNotification,CurrentUi)
	end
end
 
function module.MoveAllNotificationsUp(Player,CurrentNotification,CurrentUi)
	local PlayerGui = Player:WaitForChild("PlayerGui")
	for i=1,CurrentNotification-1 do
		local currentTextLabel = PlayerGui:FindFirstChild("Notification"..i).TextLabel
 
		local currentTextLabelXScale = currentTextLabel.Position.X.Scale
		local currentTextLabelXOffset = currentTextLabel.Position.X.Offset
		local currentTextLabelYScale = currentTextLabel.Position.Y.Scale
		local currentTextLabelYOffset = currentTextLabel.Position.Y.Offset
 
		local TweenService = game:GetService("TweenService")
		local tween = TweenService:Create(currentTextLabel, TweenInfo.new(0.5), {Position = UDim2.new(currentTextLabelXScale,currentTextLabelXOffset,currentTextLabelYScale-0.1,currentTextLabelYOffset)})
		tween:Play()
		wait(0.5)
	end
end
 
function module.CreateUi(Player,RoundedCorners,Text,BackgroundColor,ScreenPosition)
	local ScreenGui = Instance.new("ScreenGui")
	local TextLabel = Instance.new("TextLabel")
	ScreenGui.Name = "Notification"..tostring(AmountOfNotifications)
	ScreenGui.Parent = Player:WaitForChild("PlayerGui")
	TextLabel.Parent = ScreenGui
	TextLabel.BackgroundTransparency = 0
	TextLabel.Size = UDim2.new(0, 350,0, 50)
 
	if RoundedCorners then
		local UiCorner = Instance.new("UICorner")
		UiCorner.Parent = TextLabel
	end
 
	TextLabel.Text = Text
	TextLabel.BackgroundColor3 = BackgroundColor
	module.SetUiPosition(TextLabel,ScreenPosition)
end
 
function module.CreateNotificationClient(Player,TypeOfNotification,ScreenPosition,Text,BackgroundColor,RoundedCorners,BackgroundTransparency)-- creates the ui for the notification
	AmountOfNotifications += 1
	module.Debugs(false,"Creating New Notification")
	task.spawn(function()-- creates a thread that mananges the individual notification being created
		module.Debugs(false,"Task.spawn started")
		module.CreateUi(Player,RoundedCorners,Text,BackgroundColor,ScreenPosition)
 
		local PlayerGui = Player:WaitForChild("PlayerGui")
		local currentTextLabel = PlayerGui:FindFirstChild("Notification"..AmountOfNotifications).TextLabel
		local CurrentNotification = AmountOfNotifications
		local TimeUntilDestroy = TimeNotificationLasts
 
		currentTextLabel.TextTransparency = 1
		currentTextLabel.BackgroundTransparency = 1	
 
		module.MoveAllNotificationsManager(Player,CurrentNotification,currentTextLabel,ScreenPosition)
 
		currentTextLabel.TextTransparency = 0
		currentTextLabel.BackgroundTransparency = BackgroundTransparency
 
 
		while TimeUntilDestroy > 0 do
			module.Debugs(false,"time until destroy: "..TimeUntilDestroy)
			if TimeUntilDestroy <= 0 then
				module.fadeout(Player,CurrentNotification)
			else
				TimeUntilDestroy = TimeUntilDestroy - 1
				if TimeUntilDestroy <= 0 then
					module.fadeout(Player,CurrentNotification)
				end
			end
			wait(1)
		end
	end)
end
 
function module.CreateNotificationServer(Player,ScreenPosition,Text,BackgroundColor,RoundedCorners)
	if not ServerWideNotificationEventHasBeenMade then
		ServerWideNotificationEventHasBeenMade = true
 
		local ServerWideNotificationEventHandlerServerScript = Instance.new("Script")
		ServerWideNotificationEventHandlerServerScript.Parent = script
		ServerWideNotificationEventHandlerServerScript.Name = "Server Wide Notification Event Handler ServerScript"
 
		local ServerWideNotificationEvent = Instance.new("RemoteEvent")
		ServerWideNotificationEvent.Parent = script
		ServerWideNotificationEvent.Name = "ServerWideNotificationEvent"
		ServerWideNotificationEvent:FireServer(Player,ScreenPosition,Text,BackgroundColor,RoundedCorners)
		ServerWideNotificationEvent = script.Parent:WaitForChild("ServerWideNotificationEvent")
	end
end
 
if ServerWideNotificationEventHasBeenMade then
	ServerWideNotificationEvent.OnClientEvent(function(Player,ScreenPosition,Text,BackgroundColor,RoundedCorners)
		AmountOfNotifications += 1
		module.Debugs(false,"Creating New Notification")
		task.spawn(function()-- creates a thread that mananges the individual notification being created
			module.Debugs(false,"Task.spawn started")
			module.CreateUi(Player,RoundedCorners,Text,BackgroundColor,ScreenPosition)
			local CurrentNotification = AmountOfNotifications
			local TimeUntilDestroy = TimeNotificationLasts
 
			while TimeUntilDestroy > 0 do
				module.Debugs(false,"time until destroy: "..TimeUntilDestroy)
				if TimeUntilDestroy <= 0 then
					module.fadeout(Player,CurrentNotification)
				else
					TimeUntilDestroy = TimeUntilDestroy - 1
					if TimeUntilDestroy <= 0 then
						module.fadeout(Player,CurrentNotification)
					end
				end
				wait(1)
			end
			wait(DebounceTime)-- stops message spam
		end)
		wait(1)
	end) 
end
 
 
function module.CreateNotificationGlobal(ScreenPosition,Text,BackgroundColor,RoundedCorners)
	-- need to set this up to work in serverscriptservice
end
 
-- also need a recieve for global here
 
function module.SetToDefaultSettings(TypeOfNotification,ScreenPosition,Text,BackgroundColor,RoundedCorners,BackgroundTransparency)
 
	local varsChanged = {}
	local IsValidTypeOfNotification = table.find({"client","server","global"},TypeOfNotification)
 
	if IsValidTypeOfNotification == 1 then
		IsValidTypeOfNotification = true
	else
		IsValidTypeOfNotification = false
	end
 
	if not IsValidTypeOfNotification then
		module.FixedNotificationType = DefaultSettings[2]
		table.insert(varsChanged,"TypeOfNotification")
		table.insert(varsChanged,module.FixedNotificationType)
	else
		module.FixedNotificationType = TypeOfNotification
	end
 
	if BackgroundTransparency == nil or BackgroundTransparency >1 or BackgroundTransparency <0 then
		module.FixedBackGroundTransparency = DefaultSettings[7]
		table.insert(varsChanged,"BackgroundTransparency")
		table.insert(varsChanged,module.FixedBackGroundTransparency)
	else
		module.FixedBackGroundTransparency = BackgroundTransparency
	end
 
	if Text == nil then
		module.FixedText = DefaultSettings[4]
		table.insert(varsChanged,"Text")
		table.insert(varsChanged,module.FixedText)
	else
		module.FixedText = Text
	end
 
	if ScreenPosition == nil then
		module.FixedNotificationPosition = DefaultSettings[3]
		table.insert(varsChanged,"NotificationPosition")
		table.insert(varsChanged,module.FixedNotificationPosition)
	else
		module.FixedNotificationPosition = ScreenPosition
	end
 
	if RoundedCorners == nil then
		module.FixedHasRoundedCorners = DefaultSettings[6]
		table.insert(varsChanged,"FixedHasRoundedCorners")
		table.insert(varsChanged,module.FixedHasRoundedCorners)
	else
		module.FixedHasRoundedCorners = RoundedCorners
	end
 
	if BackgroundColor == nil then
		module.FixedBackgroundColor = DefaultSettings[5]
		table.insert(varsChanged,"FixedBackgroundColor")
		table.insert(varsChanged,module.FixedBackgroundColor)
	else
		module.FixedBackgroundColor = BackgroundColor
	end
 
 
	module.Debugs(false,"Default Settings: ")
	module.Debugs(false,DefaultSettings)
	module.Debugs(false,"Vars changed: ")
	module.Debugs(false,varsChanged)
 
end
 
 
function module.SendNotification(Player,TypeOfNotification,ScreenPosition,Text,BackgroundColor,RoundedCorners,BackgroundTransparency)
	local Text = tostring(Text)
	module.SetToDefaultSettings(TypeOfNotification,ScreenPosition,Text,BackgroundColor,RoundedCorners,BackgroundTransparency)
	module.Debugs(false,"Set to default settings done.")
	if module.FixedNotificationType == "client" then
		module.CreateNotificationClient(Player,module.FixedNotificationType,module.FixedNotificationPosition,module.FixedText,module.FixedBackgroundColor,module.FixedHasRoundedCorners,module.FixedBackGroundTransparency)
		wait(DebounceTime)
	end
 
	if TypeOfNotification == "server" then
		module.CreateNotificationServer(ScreenPosition,Text,BackgroundColor,RoundedCorners)
		wait(DebounceTime)
	end
end
 
return module
