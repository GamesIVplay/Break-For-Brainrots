local Lighting = game:GetService("Lighting")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Camera = workspace.CurrentCamera
local Map = workspace:WaitForChild("Map")

local Assets = ReplicatedStorage:WaitForChild("Assets")

local UISounds = Assets:WaitForChild("Sounds"):WaitForChild("UI")
local CashChange = UISounds:WaitForChild("CashChange") :: Sound
local Activate = UISounds:WaitForChild("Activate") :: Sound
local Hover = UISounds:WaitForChild("Hover") :: Sound

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local Peek = Fusion.peek

local Components = require(ReplicatedStorage.Common.Components)
local Log = require(ReplicatedStorage.Common.Log)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local Types = require(ReplicatedStorage.Common.Types)
local World = require(ReplicatedStorage.Common.World)

local Gamepasses = require(ReplicatedStorage.Common.Modules.Gamepasses)
local Pickaxes = require(ReplicatedStorage.Common.Modules.Pickaxes)
local Util = require(ReplicatedStorage.Common.Modules.Util)

local Fusion_Values = require(ReplicatedFirst.Client.Modules.Fusion_Values)
local Teleport_Character = require(ReplicatedFirst.Client.Modules.Teleport_Character)

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

local function Toggle_Screen(Screen: string)
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

local function Setup_Close_Button(ImageButton: ImageButton)
    Hydrate_Button(ImageButton, function()
        Fusion_Values.Screen:set("HUD")
    end)
end

local function Setup_HUD_Top_Buttons(LocalEntity: Types.Entity, PlayerGui: PlayerGui)
    local Main = PlayerGui:WaitForChild("Main") :: ScreenGui
    local Top = Main:WaitForChild("Top") :: Frame

    local Home = Top:WaitForChild("Home") :: ImageButton
    local Shops = Top:WaitForChild("Shops") :: ImageButton

    Hydrate_Button(Home, function()
        local Plot_Model = World:get(LocalEntity, Components.Plot_Model)

        if not Plot_Model then
            return
        end

        local Spawn = Plot_Model:WaitForChild("Spawn") :: Part

        Teleport_Character(Spawn.CFrame)
    end)

    Hydrate_Button(Shops, function()
        local Shop_Spawn = Map:WaitForChild("Shops"):WaitForChild("Spawn") :: Part

        Teleport_Character(Shop_Spawn.CFrame)
    end)
end

local function Setup_HUD_Left_Buttons(LocalEntity: Types.Entity, PlayerGui: PlayerGui)
    local Local_Player = World:get(LocalEntity, Components.Player)

    local Main = PlayerGui:WaitForChild("Main") :: ScreenGui
    local Left = Main:WaitForChild("Left") :: Frame

    local RobuxShop = Left:WaitForChild("RobuxShop") :: ImageButton
    local Index = Left:WaitForChild("Index") :: ImageButton
    local Rebirth = Left:WaitForChild("Rebirth") :: ImageButton
    local VIP = Left:WaitForChild("VIP") :: ImageButton

    Hydrate_Button(RobuxShop, function()
        Toggle_Screen("RobuxShop")
    end)

    Hydrate_Button(Index, function()
        Toggle_Screen("Index")
    end)

    Hydrate_Button(Rebirth, function()
        Toggle_Screen("Rebirth")
    end)

    Hydrate_Button(VIP, function()
        MarketplaceService:PromptGamePassPurchase(Local_Player, Gamepasses["VIP"])
    end)
end

local function Setup_HUD_Cash(PlayerGui: PlayerGui)
    local Main = PlayerGui:WaitForChild("Main") :: ScreenGui

    local Corner = Main:WaitForChild("Corner") :: Frame
    local Cash = Corner:WaitForChild("Cash") :: TextLabel

    local MoneySizeMultiplierSpring = Scope:Spring(Scope:Value(1), 17, 0.5)
    local OldCash = Peek(Fusion_Values.Cash)

    Scope:Observer(Fusion_Values.Cash):onBind(function()
        local NewCash = Peek(Fusion_Values.Cash)

        local Difference = math.round(math.abs(NewCash - OldCash))

        if Difference == 0 then
            return
        end

        CashChange:Play()

        OldCash = NewCash

        MoneySizeMultiplierSpring:addVelocity(ACTIVATE_VELOCITY)
    end)

    Scope:Hydrate(Cash)({
        Text = Scope:Computed(function(Use)
            return `${Util.Format_Number_With_Commas(Use(Fusion_Values.Cash))}`
        end),
        [Children] = {
            Scope:New("UIScale")({
                Scale = MoneySizeMultiplierSpring,
            }),
        },
    })
end

local function Setup_HUD(LocalEntity: Types.Entity, PlayerGui: PlayerGui)
    Setup_HUD_Top_Buttons(LocalEntity, PlayerGui)

    Setup_HUD_Left_Buttons(LocalEntity, PlayerGui)

    Setup_HUD_Cash(PlayerGui)
end

local function Setup_Robux_Shop_Visibility(PlayerGui: PlayerGui)
    local Main = PlayerGui:WaitForChild("Main") :: ScreenGui
    local Frames = Main:WaitForChild("Frames") :: Frame

    local RobuxShop = Frames:WaitForChild("RobuxShop") :: ImageLabel

    Scope:Hydrate(RobuxShop)({
        Visible = Scope:Computed(function(Use)
            return Use(Fusion_Values.Screen) == "RobuxShop"
        end),
    })

    Setup_Close_Button(RobuxShop:WaitForChild("Close"))
end

local function Setup_Robux_Shop(LocalEntity: Types.Entity, PlayerGui: PlayerGui)
    Setup_Robux_Shop_Visibility(PlayerGui)
end

local function Setup_Index_Visibility(PlayerGui: PlayerGui)
    local Main = PlayerGui:WaitForChild("Main") :: ScreenGui
    local Frames = Main:WaitForChild("Frames") :: Frame

    local Index = Frames:WaitForChild("Index") :: ImageLabel

    Scope:Hydrate(Index)({
        Visible = Scope:Computed(function(Use)
            return Use(Fusion_Values.Screen) == "Index"
        end),
    })

    Setup_Close_Button(Index:WaitForChild("Close"))
end

local function Setup_Index(LocalEntity: Types.Entity, PlayerGui: PlayerGui)
    Setup_Index_Visibility(PlayerGui)
end

local function Setup_Rebirth_Visibility(PlayerGui: PlayerGui)
    local Main = PlayerGui:WaitForChild("Main") :: ScreenGui
    local Frames = Main:WaitForChild("Frames") :: Frame

    local Rebirth = Frames:WaitForChild("Rebirth") :: ImageLabel

    Scope:Hydrate(Rebirth)({
        Visible = Scope:Computed(function(Use)
            return Use(Fusion_Values.Screen) == "Rebirth"
        end),
    })

    Setup_Close_Button(Rebirth:WaitForChild("Close"))
end

local function Setup_Rebirth(LocalEntity: Types.Entity, PlayerGui: PlayerGui)
    Setup_Rebirth_Visibility(PlayerGui)
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
            Setup_Robux_Shop(Local_Entity, PlayerGui)
            Setup_Index(Local_Entity, PlayerGui)
            Setup_Rebirth(Local_Entity, PlayerGui)

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
