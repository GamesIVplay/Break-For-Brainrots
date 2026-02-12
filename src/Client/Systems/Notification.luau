local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local NotificationHaptic = Instance.new("HapticEffect")
NotificationHaptic.Position = Vector3.new(0, 0, 0)
NotificationHaptic.Radius = 1
NotificationHaptic.Type = Enum.HapticEffectType.UIHover
NotificationHaptic.Parent = workspace

local Assets = ReplicatedStorage:WaitForChild("Assets")

local Sounds = Assets:WaitForChild("Sounds")
local UISounds = Sounds:WaitForChild("UI")
local Notification_Sounds = UISounds:WaitForChild("Notification")

local UIGradients = Assets:WaitForChild("UIGradients")
local Notification_UI_Gradients = UIGradients:WaitForChild("Notification")

local Components = require(ReplicatedStorage.Common.Components)
local Network = require(ReplicatedFirst.Network)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local Types = require(ReplicatedStorage.Common.Types)
local World = require(ReplicatedStorage.Common.World)

local Spring = require(ReplicatedStorage.Common.Modules.Spring)

local NOTIFICATION_COUNT = 0
local DEFAULT_NOTIFICATION_DURATION = 4

local ActiveNotifications: { [string]: {
    Frame: Frame,
    Count: number,
    Type: Types.NotificationType,
    Token: any,
} } =
    {}

local Notification_Query =
    World:query(Components.Text, Components.NotificationType):with(Components.Tags.Notification):cached()

local function Handle_Server_Notifications()
    for _, Notification in Network.Notification.Iter() do
        local Entity = World:entity()
        World:set(Entity, Components.Text, Notification.Text)
        World:set(Entity, Components.NotificationType, Notification.Type)

        if Notification.Duration then
            World:set(Entity, Components.Duration, Notification.Duration)
        end

        World:add(Entity, Components.Tags.Notification)
    end
end

local function Schedule_Cleanup(Text: string, Type: Types.NotificationType, Duration: number, Frame: Frame)
    local Token = {}
    ActiveNotifications[Text].Token = Token

    task.delay(Duration, function()
        if
            ActiveNotifications[Text]
            and ActiveNotifications[Text].Token == Token
            and ActiveNotifications[Text].Type == Type
            and ActiveNotifications[Text].Frame == Frame
        then
            ActiveNotifications[Text] = nil
            Frame:Destroy()
        end
    end)
end

local function Create_Notifications()
    local LocalEntity = Registry.Get("Players", "Local")
    local LocalPlayer = World:get(LocalEntity, Components.Player) :: Player
    local PlayerGui = LocalPlayer.PlayerGui

    local ScreenGui = PlayerGui:FindFirstChild("Notifications") :: ScreenGui?
    if not ScreenGui then
        return
    end

    local Notifications = ScreenGui:FindFirstChild("Notifications") :: Frame?
    if not Notifications then
        return
    end

    if UserInputService.TouchEnabled and workspace.CurrentCamera.ViewportSize.X < 1024 then
        Notifications.Position = UDim2.fromScale(0.5, 0.825)
    else
        Notifications.Position = UDim2.fromScale(0.5, 0.9)
    end

    local Template = Notifications:FindFirstChild("Template") :: Frame?

    if not Template then
        return
    end

    for Entity, Text, Type in Notification_Query:iter() do
        local Duration = World:get(Entity, Components.Duration) or DEFAULT_NOTIFICATION_DURATION

        local Existing = ActiveNotifications[Text]

        if Existing and Existing.Frame:IsDescendantOf(Notifications) and Existing.Type == Type then
            Existing.Count += 1

            NOTIFICATION_COUNT += 1
            Existing.Frame.LayoutOrder = NOTIFICATION_COUNT

            local TextLabel = Existing.Frame:FindFirstChildOfClass("TextLabel")
            if TextLabel then
                TextLabel.Text = string.format("%s (x%d)", Text, Existing.Count)
            end

            local UIScale = Existing.Frame:FindFirstChildOfClass("UIScale")
            Spring.stop(UIScale, "Scale")
            UIScale.Scale = 0
            Spring.target(UIScale, 0.6, 5, { Scale = 1 })

            local Sound = Notification_Sounds:FindFirstChild(Existing.Type)

            if Sound then
                Sound:Play()
            end

            NotificationHaptic:Play()

            Schedule_Cleanup(Text, Existing.Type, Duration, Existing.Frame)

            World:delete(Entity)
            continue
        end

        local Visible = {}
        for _, Child in Notifications:GetChildren() do
            if Child:IsA("Frame") and Child.Name ~= "Template" then
                table.insert(Visible, Child)
            end
        end

        table.sort(Visible, function(a, b)
            return a.LayoutOrder < b.LayoutOrder
        end)

        if #Visible >= 3 then
            Visible[1]:Destroy()
        end

        local Notification = Template:Clone()
        Notification.Name = Text
        Notification.Visible = true

        NOTIFICATION_COUNT += 1
        Notification.LayoutOrder = NOTIFICATION_COUNT

        local TextLabel = Notification:FindFirstChildOfClass("TextLabel")
        TextLabel.Text = Text

        local Gradient = Notification_UI_Gradients:FindFirstChild(Type)

        if Gradient then
            Gradient:Clone().Parent = TextLabel
        end

        local UIScale = Notification:FindFirstChildOfClass("UIScale")
        UIScale.Scale = 0
        Spring.target(UIScale, 0.6, 5, { Scale = 1 })

        local Sound = Notification_Sounds:FindFirstChild(Type)

        if Sound then
            Sound:Play()
        end

        Notification.Parent = Notifications

        ActiveNotifications[Text] = {
            Frame = Notification,
            Count = 1,
            Type = Type,
            Token = nil,
        }

        NotificationHaptic:Play()

        Schedule_Cleanup(Text, Type, Duration, Notification)
        World:delete(Entity)
    end
end

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = function()
        Handle_Server_Notifications()
        Create_Notifications()
    end,
    runConditions = {},
}
