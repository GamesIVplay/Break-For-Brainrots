local Lighting = game:GetService("Lighting")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

local Map = workspace:WaitForChild("Map")

local Assets = ReplicatedStorage:WaitForChild("Assets")

local Modules = Assets:WaitForChild("Modules") :: Folder
local Zone = require(Modules:WaitForChild("Zone")) :: any

local UISounds = Assets:WaitForChild("Sounds"):WaitForChild("UI")
local Activate = UISounds:WaitForChild("Activate") :: Sound
local Hover = UISounds:WaitForChild("Hover") :: Sound

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local Peek = Fusion.peek

local TopbarPlus = require(ReplicatedStorage.Packages.TopbarPlus)

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local World = require(ReplicatedStorage.Common.World)

local Fusion_Values = require(ReplicatedFirst.Client.Modules.Fusion_Values)
local Teleport_Character = require(ReplicatedFirst.Client.Modules.Teleport_Character)

local Log = require(ReplicatedStorage.Common.Log)

local Types = require(ReplicatedStorage.Common.Types)

local DEFAULT_SIZE_MULTIPLIER = 1
local HOVER_SIZE_MULTIPLIER = 1.05
local PRESS_DOWN_SIZE_MULTIPLIER = 0.9
local ACTIVATE_VELOCITY = 2

local Scope = Fusion.scoped(Fusion)

local ActivateHaptic = Instance.new("HapticEffect")
ActivateHaptic.Position = Vector3.new(0, 0, 0)
ActivateHaptic.Radius = 1
ActivateHaptic.Type = Enum.HapticEffectType.UIHover
ActivateHaptic.Parent = workspace

local CameraFovTween: Tween?
local BlurEffect: BlurEffect?

local function TweenFov(Time: number, Value: number)
    if CameraFovTween then
        CameraFovTween:Destroy()
    end

    CameraFovTween = TweenService:Create(
        Camera,
        TweenInfo.new(Time, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
        { FieldOfView = Value }
    ):Play()
end

local function Remove_Blur()
    if BlurEffect then
        BlurEffect:Destroy()
        BlurEffect = nil
    end
end

local function Add_Blur(Size: number)
    Remove_Blur()

    local BlurEffectInstance = Instance.new("BlurEffect")
    BlurEffectInstance.Size = Size
    BlurEffectInstance.Parent = Lighting

    BlurEffect = BlurEffectInstance
end

local function Open_Screen(Screen: string)
    if Peek(Fusion_Values.Screen) == Screen then
        Fusion_Values.Screen:set("HUD")
    else
        Fusion_Values.Screen:set(Screen)
    end
end

local function Hydrate_Button(GuiButton: GuiButton, OnActivate: () -> ())
    local SizeMultiplier = Scope:Value(DEFAULT_SIZE_MULTIPLIER)
    local Hovering = Scope:Value(false)
    local Pressing_Down = Scope:Value(false)
    local SizeMultiplierSpring = Scope:Spring(SizeMultiplier, 17, 0.5)

    local function Update_Size_Multiplier()
        if Peek(Pressing_Down) then
            SizeMultiplier:set(PRESS_DOWN_SIZE_MULTIPLIER)
        elseif Peek(Hovering) then
            SizeMultiplier:set(HOVER_SIZE_MULTIPLIER)
        else
            SizeMultiplier:set(DEFAULT_SIZE_MULTIPLIER)
        end
    end

    Scope:Observer(Hovering):onBind(Update_Size_Multiplier)
    Scope:Observer(Pressing_Down):onBind(Update_Size_Multiplier)

    Scope:Hydrate(GuiButton)({
        [OnEvent("MouseEnter")] = function()
            Hover:Play()
            Hovering:set(true)
        end,
        [OnEvent("MouseLeave")] = function()
            Hovering:set(false)
            Pressing_Down:set(false)
        end,
        [OnEvent("MouseButton1Down")] = function()
            Pressing_Down:set(true)
        end,
        [OnEvent("MouseButton1Up")] = function()
            if not Peek(Pressing_Down) then
                return
            end

            Pressing_Down:set(false)
            Activate:Play()
            ActivateHaptic:Play()

            OnActivate()
        end,
        [Children] = {
            Scope:New("UIScale")({
                Scale = SizeMultiplierSpring,
            }),
        },
    })
end

local function Setup_HUD_Top_Buttons(_LocalEntity: Types.Entity, PlayerGui: PlayerGui)
    local Main = PlayerGui:WaitForChild("Main") :: ScreenGui
    local Top = Main:WaitForChild("Top") :: Frame

    local Home = Top:WaitForChild("Home") :: ImageButton
    local Shops = Top:WaitForChild("Shops") :: ImageButton

    Hydrate_Button(Home, function() end)

    Hydrate_Button(Shops, function()
        local Shop_Spawn = Map:WaitForChild("Shops"):WaitForChild("Spawn") :: Part

        Teleport_Character(Shop_Spawn.CFrame)
    end)
end

local function Setup_HUD(LocalEntity: Types.Entity, PlayerGui: PlayerGui)
    Setup_HUD_Top_Buttons(LocalEntity, PlayerGui)
end

local function Setup_Topbar()
    local Settings = TopbarPlus.new()
        :setImage("rbxassetid://126487825375209")
        :setImageScale(0.8)
        :oneClick(true)
        :align("Right")
        :setCaption("Settings")
        :setTextFont("Montserrat", Enum.FontWeight.Bold, Enum.FontStyle.Normal)

    Settings.selected:Connect(function()
        Activate:Play()

        Open_Screen("Settings")
    end)

    Settings.viewingStarted:Connect(function()
        Hover:Play()
    end)

    local Daily_Rewards = TopbarPlus.new()
        :setImage("rbxassetid://83312608302744")
        :setImageScale(0.8)
        :oneClick(true)
        :align("Right")
        :setLabel("Daily Rewards")
        :setCaption("Daily Rewards")
        :setTextFont("Montserrat", Enum.FontWeight.Bold, Enum.FontStyle.Normal)

    Daily_Rewards.selected:Connect(function()
        Activate:Play()

        Open_Screen("Daily Rewards")
    end)

    Daily_Rewards.viewingStarted:Connect(function()
        Hover:Play()
    end)
end

local function Setup_Stroke_Fixer(PlayerGui: PlayerGui)
    local Reference_Height = 1080

    local function Update_Non_Native_Scaling()
        local ScreenSize = Camera.ViewportSize
        local ScaleFactorY = ScreenSize.Y / Reference_Height

        for _, Descendant in pairs(PlayerGui:GetDescendants()) do
            if Descendant:IsA("UIStroke") then
                local Original_Thickness = Descendant:GetAttribute("Original_Thickness") or Descendant.Thickness

                Descendant:SetAttribute("Original_Thickness", Original_Thickness)

                if Original_Thickness > 0 then
                    Descendant.Thickness = math.max(1, math.floor(Original_Thickness * ScaleFactorY))
                end
            elseif Descendant:IsA("UITextSizeConstraint") then
                local Original_Max_Text_Size = Descendant.MaxTextSize
                Descendant.MaxTextSize = math.max(1, math.floor(Original_Max_Text_Size * ScaleFactorY))
            elseif Descendant:IsA("ScrollingFrame") then
                local Original_Thickness = Descendant:GetAttribute("Original_Thickness")
                    or Descendant.ScrollBarThickness

                Descendant:SetAttribute("Original_Thickness", Original_Thickness)

                local AbsoluteSize: Vector2 = Descendant.Parent and Descendant.Parent.AbsoluteSize or Vector2.new(0, 0)
                local Width = AbsoluteSize.X

                Descendant.ScrollBarThickness = (Width / Reference_Height) * Original_Thickness
            end
        end
    end

    Update_Non_Native_Scaling()

    Camera:GetPropertyChangedSignal("ViewportSize"):Connect(Update_Non_Native_Scaling)
end

return {
    name = script.Name,
    phase = Phases.InitPhases.Init,
    system = function()
        task.spawn(function()
            local Local_Entity = Registry.Get("Players", "Local")

            local Local_Player = World:get(Local_Entity, Components.Player) :: Player

            local PlayerGui = Local_Player.PlayerGui

            Setup_HUD(Local_Entity, PlayerGui)

            Setup_Topbar()

            Setup_Stroke_Fixer(PlayerGui)

            Scope:Observer(Fusion_Values.Screen):onBind(function()
                if Peek(Fusion_Values.Screen) == "HUD" then
                    TweenFov(0.15, 70)
                    Remove_Blur()
                else
                    TweenFov(0.15, 50)
                    Add_Blur(30)
                end
            end)

            Log.Info("UI has been setup")
        end)
    end,
    runConditions = {},
}
