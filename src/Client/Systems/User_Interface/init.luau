local Lighting = game:GetService("Lighting")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Camera = workspace.CurrentCamera
local Map = workspace:WaitForChild("Map")

local Assets = ReplicatedStorage:WaitForChild("Assets")

local UIGradients = Assets:WaitForChild("UIGradients") :: Folder

local UISounds = Assets:WaitForChild("Sounds"):WaitForChild("UI")
local Shop_Open = UISounds:WaitForChild("Shop_Open") :: Sound
local CashChange = UISounds:WaitForChild("CashChange") :: Sound
local Activate = UISounds:WaitForChild("Activate") :: Sound
local Hover = UISounds:WaitForChild("Hover") :: Sound
local Frame_Open = UISounds:WaitForChild("Frame_Open") :: Sound

local Network = require(ReplicatedFirst.Network)

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

local Blocks = require(ReplicatedStorage.Common.Modules.Blocks)
local Developer_Products = require(ReplicatedStorage.Common.Modules.Developer_Products)
local Gamepasses = require(ReplicatedStorage.Common.Modules.Gamepasses)
local Pickaxes = require(ReplicatedStorage.Common.Modules.Pickaxes)
local Unicode_Characters = require(ReplicatedStorage.Common.Modules.Unicode_Characters)
local Util = require(ReplicatedStorage.Common.Modules.Util)

local Fusion_Values = require(ReplicatedFirst.Client.Modules.Fusion_Values)
local Teleport_Character = require(ReplicatedFirst.Client.Modules.Teleport_Character)

local DEFAULT_SIZE_MULTIPLIER = 1
local HOVER_SIZE_MULTIPLIER = 1.05
local PRESS_DOWN_SIZE_MULTIPLIER = 0.9
local ACTIVATE_VELOCITY = 2
local EQUIPPED_IMAGE_ID = "rbxassetid://105827258558873"
local UNEQUIPPED_IMAGE_ID = "rbxassetid://119691695893621"

local Scope = Fusion.scoped(Fusion)

local DeviceType = require(script.Components.DeviceType)(Scope)

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

type HydrateButtonOptions = {
    DefaultSizeMultiplier: number?,
    HoverSizeMultiplier: number?,
    PressDownSizeMultiplier: number?,
    SpringSpeed: number?,
    SpringDamping: number?,
}

local function Hydrate_Frame_Visibility(Frame: ImageLabel, Screen_Name: string, Callback: (() -> ())?)
    local Visible = Scope:Value(false)
    local SizeMultiplierSpring = Scope:Spring(Scope:Value(DEFAULT_SIZE_MULTIPLIER), 17, 0.5)

    Scope:Hydrate(Frame)({
        Visible = Scope:Computed(function(Use)
            return Use(Visible)
        end),
        [Children] = {
            Scope:New("UIScale")({
                Scale = SizeMultiplierSpring,
            }),
        },
    })

    Scope:Observer(Fusion_Values.Screen):onBind(function()
        if Peek(Fusion_Values.Screen) == Screen_Name then
            Visible:set(true)

            SizeMultiplierSpring:addVelocity(-10)

            if Callback then
                Callback()
            end
        else
            Visible:set(false)
        end
    end)
end

local function Hydrate_Button(GuiButton: GuiButton, OnActivate: () -> (), Options: HydrateButtonOptions?)
    Options = Options or {}

    local DEFAULT = Options.DefaultSizeMultiplier or DEFAULT_SIZE_MULTIPLIER
    local HOVER = Options.HoverSizeMultiplier or HOVER_SIZE_MULTIPLIER
    local PRESS = Options.PressDownSizeMultiplier or PRESS_DOWN_SIZE_MULTIPLIER
    local SPRING_SPEED = Options.SpringSpeed or 17
    local SPRING_DAMPING = Options.SpringDamping or 0.5

    local SizeMultiplier = Scope:Value(DEFAULT)
    local Hovering = Scope:Value(false)
    local Pressing_Down = Scope:Value(false)
    local SizeMultiplierSpring = Scope:Spring(SizeMultiplier, SPRING_SPEED, SPRING_DAMPING)

    local function Update_Size_Multiplier()
        if Peek(Pressing_Down) then
            SizeMultiplier:set(PRESS)
        elseif Peek(Hovering) then
            SizeMultiplier:set(HOVER)
        else
            SizeMultiplier:set(DEFAULT)
        end
    end

    Scope:Observer(Hovering):onBind(Update_Size_Multiplier)
    Scope:Observer(Pressing_Down):onBind(Update_Size_Multiplier)

    Scope:Hydrate(GuiButton)({
        [OnEvent("MouseEnter")] = function()
            if Peek(DeviceType) ~= "Mobile" then
                Hover:Play()
            end
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

local function Setup_HUD_Visibility(PlayerGui: PlayerGui)
    local Main = PlayerGui:WaitForChild("Main") :: ScreenGui
    local Top = Main:WaitForChild("Top") :: Frame
    local Left = Main:WaitForChild("Left") :: Frame
    local Offers = Main:WaitForChild("Offers") :: Frame

    local Visible_Computed = Scope:Computed(function(Use)
        return Use(Fusion_Values.Screen) == "HUD"
    end)

    Scope:Hydrate(Top)({
        Visible = Visible_Computed,
    })

    Scope:Hydrate(Left)({
        Visible = Visible_Computed,
    })

    Scope:Hydrate(Offers)({
        Visible = Visible_Computed,
    })
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
    Setup_HUD_Visibility(PlayerGui)

    Setup_HUD_Top_Buttons(LocalEntity, PlayerGui)

    Setup_HUD_Left_Buttons(LocalEntity, PlayerGui)

    Setup_HUD_Cash(PlayerGui)
end

local function Setup_Robux_Shop_Visibility(PlayerGui: PlayerGui)
    local Main = PlayerGui:WaitForChild("Main") :: ScreenGui
    local Frames = Main:WaitForChild("Frames") :: Frame

    local RobuxShop = Frames:WaitForChild("RobuxShop") :: ImageLabel

    Hydrate_Frame_Visibility(RobuxShop, "RobuxShop", function()
        Shop_Open:Play()
    end)

    Setup_Close_Button(RobuxShop:WaitForChild("Close"))
end

local function Setup_Robux_Shop(LocalEntity: Types.Entity, PlayerGui: PlayerGui)
    Setup_Robux_Shop_Visibility(PlayerGui)
end

local function Setup_Index_Visibility(PlayerGui: PlayerGui)
    local Main = PlayerGui:WaitForChild("Main") :: ScreenGui
    local Frames = Main:WaitForChild("Frames") :: Frame

    local Index = Frames:WaitForChild("Index") :: ImageLabel

    Hydrate_Frame_Visibility(Index, "Index")

    Setup_Close_Button(Index:WaitForChild("Close"))
end

local function Setup_Index(LocalEntity: Types.Entity, PlayerGui: PlayerGui)
    Setup_Index_Visibility(PlayerGui)
end

local function Setup_Rebirth_Visibility(PlayerGui: PlayerGui)
    local Main = PlayerGui:WaitForChild("Main") :: ScreenGui
    local Frames = Main:WaitForChild("Frames") :: Frame

    local Rebirth = Frames:WaitForChild("Rebirth") :: ImageLabel

    Hydrate_Frame_Visibility(Rebirth, "Rebirth")

    Setup_Close_Button(Rebirth:WaitForChild("Close"))
end

local function Setup_Rebirth(LocalEntity: Types.Entity, PlayerGui: PlayerGui)
    Setup_Rebirth_Visibility(PlayerGui)
end

local function Setup_Pickaxes_Visibility(PlayerGui: PlayerGui)
    local Main = PlayerGui:WaitForChild("Main") :: ScreenGui
    local Frames = Main:WaitForChild("Frames") :: Frame

    local Pickaxes_Frame = Frames:WaitForChild("Pickaxes") :: ImageLabel
    local Contents = Pickaxes_Frame:WaitForChild("Contents") :: ScrollingFrame

    Hydrate_Frame_Visibility(Pickaxes_Frame, "Pickaxes", function()
        local Current_Pickaxe = Peek(Fusion_Values.Pickaxe)

        if not Current_Pickaxe then
            return
        end

        local TargetFrame = Contents:FindFirstChild(Current_Pickaxe)
        if not TargetFrame then
            return
        end

        local Layout = Contents:FindFirstChildOfClass("UIListLayout")
        if not Layout then
            return
        end

        local PaddingPx = Layout.Padding.Offset + Layout.Padding.Scale * Contents.AbsoluteSize.Y
        local FrameHeightPx = TargetFrame.Size.Y.Offset + TargetFrame.Size.Y.Scale * Contents.AbsoluteSize.Y

        local Count_Above = 0
        for _, Frame in Contents:GetChildren() do
            if Frame:IsA("GuiObject") and Frame.Visible and Frame.LayoutOrder < TargetFrame.LayoutOrder then
                Count_Above += 1
            end
        end

        local TargetY = (FrameHeightPx + PaddingPx) * Count_Above
        Contents.CanvasPosition = Vector2.new(0, TargetY)
    end)

    Setup_Close_Button(Pickaxes_Frame:WaitForChild("Close"))
end

local function Setup_Pickaxes_Content(LocalEntity: Types.Entity, PlayerGui: PlayerGui)
    local Local_Player = World:get(LocalEntity, Components.Player)

    local Main = PlayerGui:WaitForChild("Main") :: ScreenGui
    local Frames = Main:WaitForChild("Frames") :: Frame
    local Pickaxes_Frame = Frames:WaitForChild("Pickaxes")

    local Contents = Pickaxes_Frame:WaitForChild("Contents") :: ScrollingFrame
    local Template = Contents:WaitForChild("Template") :: ImageLabel

    for Name, Data in Pickaxes do
        local Equiped_Computed = Scope:Computed(function(Use)
            return Use(Fusion_Values.Pickaxe) == Name
        end)

        local Has_Rebirth_Required_Computed = Scope:Computed(function(Use)
            return Use(Fusion_Values.Rebirth) >= Data.Rebirth
        end)

        local Owned_Computed = Scope:Computed(function(Use)
            if table.find(Use(Fusion_Values.Owned_Pickaxes), Name) then
                return true
            end

            return false
        end)

        local Not_Owned_Computed = Scope:Computed(function(Use)
            return not Use(Owned_Computed)
        end)

        local ImageLabel = Template:Clone()
        ImageLabel.Name = Name
        ImageLabel.LayoutOrder = Data.Power
        ImageLabel.Parent = Template.Parent

        Scope:Hydrate(ImageLabel)({
            Visible = Data.Price == nil and Owned_Computed or true,
            Active = Has_Rebirth_Required_Computed,
            Interactable = Has_Rebirth_Required_Computed,
        })

        local Title = ImageLabel:WaitForChild("Title") :: TextLabel
        Title.Text = Name

        local Rarity = ImageLabel:WaitForChild("Rarity") :: TextLabel
        Rarity.Text = Data.Rarity

        local Rarity_Gradient = UIGradients:FindFirstChild(Data.Rarity)

        if Rarity_Gradient then
            Rarity_Gradient:Clone().Parent = Rarity
        end

        local Power = ImageLabel:WaitForChild("Power") :: TextLabel
        Power.Text = `📊 {Util.Abbreviate_Number(Data.Power)} Power`

        local Icon = ImageLabel:WaitForChild("Icon") :: ImageLabel
        Icon.Image = Data.Image

        local Buy = ImageLabel:WaitForChild("Buy") :: ImageButton

        if Data.Price then
            local Price = Buy:WaitForChild("Price") :: TextLabel
            Price.Text = `${Util.Format_Number_With_Commas(Data.Price, 2)}`

            Scope:Hydrate(Buy)({
                Visible = Not_Owned_Computed,
                Active = Has_Rebirth_Required_Computed,
                Interactable = Has_Rebirth_Required_Computed,
            })

            Hydrate_Button(Buy, function()
                Network.Requests.Buy_Pickaxe.Fire(Name)
            end)
        else
            Buy.Visible = false
        end

        local RobuxBuy = ImageLabel:WaitForChild("RobuxBuy") :: ImageButton

        if Data.Price then
            task.spawn(function()
                local RobuxBuy_Price = RobuxBuy:WaitForChild("Price") :: TextLabel
                local Product_Info = Util.Get_Product_Info(Data.Developer_Product)

                if Product_Info then
                    RobuxBuy_Price.Text =
                        `{Unicode_Characters.Robux}{Util.Format_Number_With_Commas(Product_Info.PriceInRobux)}`
                else
                    RobuxBuy_Price.Text = "Buy"
                end
            end)

            Scope:Hydrate(RobuxBuy)({
                Visible = Not_Owned_Computed,
                Active = Has_Rebirth_Required_Computed,
                Interactable = Has_Rebirth_Required_Computed,
            })

            Hydrate_Button(RobuxBuy, function()
                MarketplaceService:PromptProductPurchase(Local_Player, Data.Developer_Product)
            end)
        else
            RobuxBuy.Visible = false
        end

        local Equip = ImageLabel:WaitForChild("Equip") :: ImageButton
        local Equip_Title = Equip:WaitForChild("Title") :: TextLabel

        Scope:Hydrate(Equip)({
            Visible = Owned_Computed,
            Image = Scope:Computed(function(Use)
                if Use(Equiped_Computed) then
                    return EQUIPPED_IMAGE_ID
                end

                return UNEQUIPPED_IMAGE_ID
            end),
        })

        Scope:Hydrate(Equip_Title)({
            Text = Scope:Computed(function(Use)
                if Use(Equiped_Computed) then
                    return "Equipped"
                end

                return "Equip"
            end),
        })

        Hydrate_Button(Equip, function()
            if Peek(Fusion_Values.Pickaxe) == Name then
                return
            end

            Network.Requests.Equip_Pickaxe.Fire(Name)
        end)

        local Rebirth_Requirement = ImageLabel:WaitForChild("Rebirth_Requirement") :: Frame
        local Rebirth_Requirement_Title = Rebirth_Requirement:WaitForChild("Title") :: TextLabel

        Scope:Hydrate(Rebirth_Requirement)({
            Visible = Scope:Computed(function(Use)
                if Use(Owned_Computed) == true then
                    return false
                end

                return not Use(Has_Rebirth_Required_Computed)
            end),
        })

        Rebirth_Requirement_Title.Text = `Requires Rebirth {Data.Rebirth}`
    end

    Template.Visible = false
end

local function Setup_Pickaxes(LocalEntity: Types.Entity, PlayerGui: PlayerGui)
    Setup_Pickaxes_Visibility(PlayerGui)

    Setup_Pickaxes_Content(LocalEntity, PlayerGui)
end

local function Setup_Blocks_Visibility(PlayerGui: PlayerGui)
    local Main = PlayerGui:WaitForChild("Main") :: ScreenGui
    local Frames = Main:WaitForChild("Frames") :: Frame

    local Blocks_Frame = Frames:WaitForChild("Blocks") :: ImageLabel
    local Contents = Blocks_Frame:WaitForChild("Contents") :: ScrollingFrame

    Hydrate_Frame_Visibility(Blocks_Frame, "Blocks", function()
        Contents.CanvasPosition = Vector2.zero
    end)

    Setup_Close_Button(Blocks_Frame:WaitForChild("Close"))
end

local function Setup_Blocks_Restock(LocalEntity: Types.Entity, PlayerGui: PlayerGui)
    local Local_Player = World:get(LocalEntity, Components.Player)

    local Main = PlayerGui:WaitForChild("Main") :: ScreenGui
    local Frames = Main:WaitForChild("Frames") :: Frame

    local Blocks_Frame = Frames:WaitForChild("Blocks") :: ImageLabel

    Hydrate_Button(Blocks_Frame:WaitForChild("Restock"), function()
        MarketplaceService:PromptProductPurchase(Local_Player, Developer_Products.Restock)
    end)
end

local function Setup_Blocks_Content(LocalEntity: Types.Entity, PlayerGui: PlayerGui)
    local Local_Player = World:get(LocalEntity, Components.Player)

    local Main = PlayerGui:WaitForChild("Main") :: ScreenGui
    local Frames = Main:WaitForChild("Frames") :: Frame
    local Blocks_Frame = Frames:WaitForChild("Blocks")

    local Contents = Blocks_Frame:WaitForChild("Contents") :: ScrollingFrame
    local Template = Contents:WaitForChild("Template") :: ImageLabel

    for Name, Data in Blocks do
        if not Data.Price then
            continue
        end

        local ImageLabel = Template:Clone()
        ImageLabel.Name = Name
        ImageLabel.LayoutOrder = Data.Price
        ImageLabel.Parent = Template.Parent

        local Title = ImageLabel:WaitForChild("Title") :: TextLabel
        Title.Text = Name

        local Rarity_Gradient = UIGradients:FindFirstChild(Data.Rarity)

        if Rarity_Gradient then
            Rarity_Gradient:Clone().Parent = Title
        end

        local Icon = ImageLabel:WaitForChild("Icon") :: ImageLabel
        Icon.Image = Data.Image

        local Buy = ImageLabel:WaitForChild("Buy") :: ImageButton

        local Price = Buy:WaitForChild("Price") :: TextLabel
        Price.Text = `${Util.Format_Number_With_Commas(Data.Price, 2)}`

        Hydrate_Button(Buy, function() end)

        local RobuxBuy = ImageLabel:WaitForChild("RobuxBuy") :: ImageButton

        task.spawn(function()
            local RobuxBuy_Price = RobuxBuy:WaitForChild("Price") :: TextLabel
            local Product_Info = Util.Get_Product_Info(Data.Developer_Product)

            if Product_Info then
                RobuxBuy_Price.Text =
                    `{Unicode_Characters.Robux}{Util.Format_Number_With_Commas(Product_Info.PriceInRobux)}`
            else
                RobuxBuy_Price.Text = "Buy"
            end
        end)

        Hydrate_Button(RobuxBuy, function()
            MarketplaceService:PromptProductPurchase(Local_Player, Data.Developer_Product)
        end)
    end

    Template.Visible = false
end

local function Setup_Blocks(LocalEntity: Types.Entity, PlayerGui: PlayerGui)
    Setup_Blocks_Visibility(PlayerGui)

    Setup_Blocks_Restock(LocalEntity, PlayerGui)

    Setup_Blocks_Content(LocalEntity, PlayerGui)
end

local function Setup_Upgrades_Visibility(PlayerGui: PlayerGui)
    local Main = PlayerGui:WaitForChild("Main") :: ScreenGui
    local Frames = Main:WaitForChild("Frames") :: Frame

    local Upgrades_Frame = Frames:WaitForChild("Upgrades") :: ImageLabel

    Hydrate_Frame_Visibility(Upgrades_Frame, "Upgrades")

    Setup_Close_Button(Upgrades_Frame:WaitForChild("Close"))
end

local function Setup_Upgrades(LocalEntity: Types.Entity, PlayerGui: PlayerGui)
    Setup_Upgrades_Visibility(PlayerGui)
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
            Setup_Pickaxes(Local_Entity, PlayerGui)
            Setup_Blocks(Local_Entity, PlayerGui)
            Setup_Upgrades(Local_Entity, PlayerGui)

            Setup_Stroke_Fixer(PlayerGui)

            Scope:Observer(Fusion_Values.Screen):onBind(function()
                if Peek(Fusion_Values.Screen) == "HUD" then
                    TweenFov(0.15, 70)
                    Remove_Blur()
                else
                    Frame_Open:Play()

                    TweenFov(0.15, 50)
                    Add_Blur(30)
                end
            end)

            Log.Info("UI has been setup")
        end)
    end,
    runConditions = {},
}
