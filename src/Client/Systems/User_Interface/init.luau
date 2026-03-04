local Lighting = game:GetService("Lighting")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SocialService = game:GetService("SocialService")
local TweenService = game:GetService("TweenService")

local Camera = workspace.CurrentCamera
local Map = workspace:WaitForChild("Map")

local Satchel = require(ReplicatedStorage:FindFirstChild("Satchel", true))

local Assets = ReplicatedStorage:WaitForChild("Assets")
local UIGradients = Assets:WaitForChild("UIGradients")

local Sounds = Assets:WaitForChild("Sounds")

local Music = Sounds:WaitForChild("Music") :: SoundGroup

local UISounds = Sounds:WaitForChild("UI")
local Shop_Open = UISounds:WaitForChild("Shop_Open") :: Sound
local CashChange = UISounds:WaitForChild("CashChange") :: Sound
local Activate = UISounds:WaitForChild("Activate") :: Sound
local Hover = UISounds:WaitForChild("Hover") :: Sound
local Frame_Open = UISounds:WaitForChild("Frame_Open") :: Sound
local TypeWriter = UISounds:WaitForChild("TypeWriter") :: Sound

local Network = require(ReplicatedFirst.Network)

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local Peek = Fusion.peek

type Fusion = Fusion.Fusion
type Scope = Fusion.Scope

local Clock = require(ReplicatedStorage.Packages.Clock)
local TopbarPlus = require(ReplicatedStorage.Packages.TopbarPlus)

local Components = require(ReplicatedStorage.Common.Components)
local Config = require(ReplicatedStorage.Common.Config)
local Log = require(ReplicatedStorage.Common.Log)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local Types = require(ReplicatedStorage.Common.Types)
local World = require(ReplicatedStorage.Common.World)

local Blocks = require(ReplicatedStorage.Common.Modules.Blocks)
local Brainrots = require(ReplicatedStorage.Common.Modules.Brainrots)
local Daily_Rewards = require(ReplicatedStorage.Common.Modules.Daily_Rewards)
local Developer_Products = require(ReplicatedStorage.Common.Modules.Developer_Products)
local Events = require(ReplicatedStorage.Common.Modules.Events)
local Gamepasses = require(ReplicatedStorage.Common.Modules.Gamepasses)
local Generate_Brainrot_Model = require(ReplicatedStorage.Common.Modules.Generate_Brainrot_Model)
local Pickaxes = require(ReplicatedStorage.Common.Modules.Pickaxes)
local Rarities = require(ReplicatedStorage.Common.Modules.Rarities)
local Ratelimits = require(ReplicatedStorage.Common.Modules.Ratelimits)
local Rebirths = require(ReplicatedStorage.Common.Modules.Rebirths)
local Secondary_Mutations_Config = require(ReplicatedStorage.Common.Modules.Secondary_Mutations)
local Stat_Calculator = require(ReplicatedStorage.Common.Modules.Stat_Calculator)
local Tutorial_Steps = require(ReplicatedStorage.Common.Modules.Tutorial_Steps)
local Unicode_Characters = require(ReplicatedStorage.Common.Modules.Unicode_Characters)
local Upgrades = require(ReplicatedStorage.Common.Modules.Upgrades)
local Util = require(ReplicatedStorage.Common.Modules.Util)

local Fusion_Values = require(ReplicatedFirst.Client.Modules.Fusion_Values)
local Teleport_Character = require(ReplicatedFirst.Client.Modules.Teleport_Character)

local DEFAULT_SIZE_MULTIPLIER = 1
local HOVER_SIZE_MULTIPLIER = 1.05
local PRESS_DOWN_SIZE_MULTIPLIER = 0.9
local ACTIVATE_VELOCITY = 2
local EQUIPPED_IMAGE_ID = "rbxassetid://105827258558873"
local UNEQUIPPED_IMAGE_ID = "rbxassetid://119691695893621"
local CANT_REBIRTH_ID = "rbxassetid://89624548762867"
local CAN_REBIRTH_ID = "rbxassetid://90784618165931"
local CLAIMABLE_DAILY_REWARD_ID = "rbxassetid://121666171277789"
local NON_CLAIMABLE_DAILY_REWARD_ID = "rbxassetid://136916422259079"
local CLAIMED_DAILY_REWARD_ID = "rbxassetid://80526863525449"

local Scope = Fusion.scoped(Fusion)

local DeviceType = require(script.Components.DeviceType)(Scope)

local Tutorial_Completed_Computed = Scope:Computed(function(Use)
    local Tutorial_Step = Use(Fusion_Values.Tutorial_Step)
    local Total_Steps = #Tutorial_Steps

    return Tutorial_Step >= Total_Steps
end)

local Tutorial_Text_Computed = Scope:Computed(function(Use)
    return Tutorial_Steps[Use(Fusion_Values.Tutorial_Step)]
end)

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

type Brainrot_Group = {
    Key: string,
    Name: string,
    Primary_Mutation: string?,
    Secondary_Mutations: { string },
    Count: number,
    Total_Value: number,
}

local function Make_Sell_Group_Key(Item: Types.Brainrot_Item): string
    local Secondary_Mutations = Util.CopyTable(Item.Secondary_Mutations)
    table.sort(Secondary_Mutations)

    return table.concat({
        Item.Name,
        Item.Primary_Mutation or "",
        table.concat(Secondary_Mutations, ","),
    })
end

local function Make_Sell_Group(Brainrot_Inventory: { Types.Brainrot_Item })
    local Groups = {}

    for _, Brainrot_Item in Brainrot_Inventory do
        local Key = Make_Sell_Group_Key(Brainrot_Item)

        if not Groups[Key] then
            Groups[Key] = {
                Key = Key,
                Name = Brainrot_Item.Name,
                Primary_Mutation = Brainrot_Item.Primary_Mutation,
                Secondary_Mutations = Brainrot_Item.Secondary_Mutations,
                Count = 0,
                Total_Value = 0,
            }
        end

        local Sell_Price = Stat_Calculator.Calculate_Sell_Price({
            Brainrot_Name = Brainrot_Item.Name,
            Primary_Mutation = Brainrot_Item.Primary_Mutation,
            Secondary_Mutations = Brainrot_Item.Secondary_Mutations,
            Weight = Brainrot_Item.Weight,
        })

        Groups[Key].Count += 1
        Groups[Key].Total_Value += Sell_Price
    end

    return Groups
end

local function Setup_HUD_Visibility(PlayerGui: PlayerGui)
    local Main = PlayerGui:WaitForChild("Main") :: ScreenGui
    local Top = Main:WaitForChild("Top") :: Frame
    local Left = Main:WaitForChild("Left") :: Frame
    local Offers = Main:WaitForChild("Offers") :: Frame
    local Plot_Income_Per_Sec = Main:WaitForChild("Plot_Income_Per_Sec") :: Frame
    local Tutorial = PlayerGui:WaitForChild("Visuals"):WaitForChild("Tutorial") :: ImageLabel

    local Visible_Computed = Scope:Computed(function(Use)
        return Use(Fusion_Values.Screen) == "HUD"
    end)

    Scope:Hydrate(Top)({
        Visible = Scope:Computed(function(Use)
            return (Use(Visible_Computed) and Use(Fusion_Values.Tutorial_Step) >= 4)
        end),
    })

    Scope:Hydrate(Left)({
        Visible = Scope:Computed(function(Use)
            return (Use(Visible_Computed) and Use(Tutorial_Completed_Computed))
        end),
    })

    Scope:Hydrate(Offers)({
        Visible = Scope:Computed(function(Use)
            return (Use(Visible_Computed) and Use(Tutorial_Completed_Computed))
        end),
    })

    Scope:Hydrate(Plot_Income_Per_Sec)({
        Visible = Scope:Computed(function(Use)
            return (Use(Visible_Computed) and Use(Tutorial_Text_Computed) == nil)
        end),
    })

    Scope:Hydrate(Tutorial)({
        Visible = Scope:Computed(function(Use)
            return (Use(Visible_Computed) and Use(Tutorial_Text_Computed) ~= nil)
        end),
    })
end

local function Setup_HUD_Top_Buttons(LocalEntity: Types.Entity, PlayerGui: PlayerGui)
    local Main = PlayerGui:WaitForChild("Main") :: ScreenGui
    local Top = Main:WaitForChild("Top") :: Frame

    local Home = Top:WaitForChild("Home") :: ImageButton
    local Shops = Top:WaitForChild("Shops") :: ImageButton
    local Sell = Top:WaitForChild("Sell") :: ImageButton

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

    Hydrate_Button(Sell, function()
        local Sell_Spawn = Map:WaitForChild("Shops"):WaitForChild("Sell_Spawn") :: Part

        Teleport_Character(Sell_Spawn.CFrame)
    end)

    local Shop_Arrow = Shops:WaitForChild("Arrow")

    local Shop_Arrow_Start_Position = UDim2.fromScale(0.5, 1.684)
    local Shop_Arrow_End_Position = UDim2.fromScale(0.5, 1.435)

    local Shop_Arrow_Tween_Info = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

    local Shop_Arrow_Position = Scope:Value(Shop_Arrow_Start_Position)
    local Shop_Arrow_Position_Tween = Scope:Tween(Shop_Arrow_Position, Shop_Arrow_Tween_Info)

    Scope:Hydrate(Shop_Arrow)({
        Position = Shop_Arrow_Position_Tween,
        Visible = Scope:Computed(function(Use)
            return Use(Fusion_Values.Tutorial_Step) == 4
        end),
    })

    Clock(0.5, function()
        if Peek(Fusion_Values.Tutorial_Step) ~= 4 then
            return
        end

        if Peek(Shop_Arrow_Position) == Shop_Arrow_Start_Position then
            Shop_Arrow_Position:set(Shop_Arrow_End_Position)
        else
            Shop_Arrow_Position:set(Shop_Arrow_Start_Position)
        end
    end)
end

local function Setup_HUD_Left_Buttons(LocalEntity: Types.Entity, PlayerGui: PlayerGui)
    local Main = PlayerGui:WaitForChild("Main") :: ScreenGui
    local Left = Main:WaitForChild("Left") :: Frame

    local RobuxShop = Left:WaitForChild("RobuxShop") :: ImageButton
    local Index = Left:WaitForChild("Index") :: ImageButton
    local Rebirth = Left:WaitForChild("Rebirth") :: ImageButton
    local Upgrades = Left:WaitForChild("Upgrades") :: ImageButton
    local FreeReward = Left:WaitForChild("FreeReward") :: ImageButton

    Hydrate_Button(RobuxShop, function()
        Toggle_Screen("RobuxShop")
    end)

    Hydrate_Button(Index, function()
        Toggle_Screen("Index")
    end)

    Hydrate_Button(Rebirth, function()
        Toggle_Screen("Rebirth")
    end)

    Hydrate_Button(Upgrades, function()
        Toggle_Screen("Upgrades")
    end)

    Scope:Hydrate(FreeReward)({
        Visible = Scope:Computed(function(Use)
            if Use(Fusion_Values.Group_Reward_Claimed) == true then
                return false
            end

            return true
        end),
    })

    Hydrate_Button(FreeReward, function()
        Toggle_Screen("FreeReward")
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
    })

    Scope:New("UIScale")({
        Parent = Corner,
        Scale = MoneySizeMultiplierSpring,
    })
end

local function Setup_HUD_Friend_Boost(PlayerGui: PlayerGui)
    local Main = PlayerGui:WaitForChild("Main") :: ScreenGui

    local Corner = Main:WaitForChild("Corner") :: Frame
    local FriendBoost = Corner:WaitForChild("FriendBoost") :: TextLabel

    Scope:Hydrate(FriendBoost)({
        Text = Scope:Computed(function(Use)
            return `Friend Boost: +{Use(Fusion_Values.Friend_Boost)}%`
        end),
    })
end

local function Setup_HUD_Offers(LocalEntity: Types.Entity, PlayerGui: PlayerGui)
    local Local_Player = World:get(LocalEntity, Components.Player)

    local Main = PlayerGui:WaitForChild("Main") :: ScreenGui

    local Offers = Main:WaitForChild("Offers") :: Frame

    local Random_Brainrot = Offers:WaitForChild("Random_Brainrot") :: TextButton
    local Random_Brainrot_Icon = Random_Brainrot:WaitForChild("Icon") :: ImageLabel
    local Random_Brainrot_Price_Text_Label = Random_Brainrot:WaitForChild("Price") :: TextLabel

    local Offer_One = Offers:WaitForChild("Offer_One") :: TextButton
    local Offer_One_Price_Text_Label = Offer_One:WaitForChild("Price") :: TextLabel

    local Offer_Two = Offers:WaitForChild("Offer_Two") :: TextButton
    local Offer_Two_Price_Text_Label = Offer_Two:WaitForChild("Price") :: TextLabel

    task.spawn(function()
        local Product_Info = Util.Get_Product_Info(Developer_Products["Random Brainrot"])

        if Product_Info then
            Random_Brainrot_Price_Text_Label.Text =
                `{Unicode_Characters.Robux}{Util.Format_Number_With_Commas(Product_Info.PriceInRobux)}`
        else
            Random_Brainrot_Price_Text_Label.Visible = false
        end
    end)

    Hydrate_Button(Random_Brainrot, function()
        MarketplaceService:PromptProductPurchase(Local_Player, Developer_Products["Random Brainrot"])
    end)

    local Brainrot_Images = {
        "rbxassetid://70703031730045", -- Pencil
        "rbxassetid://76303552087337", -- Coffee
        "rbxassetid://121516259576117", -- 67
        "rbxassetid://115908223011277", -- Gum
        "rbxassetid://75623505435314", -- Dragon
        "rbxassetid://94082776251492", -- Job
        "rbxassetid://98082069262098", -- Shovel
        "rbxassetid://104919860405904", -- House
    }

    Clock(1, function()
        Random_Brainrot_Icon.Image = Brainrot_Images[math.random(1, #Brainrot_Images)]
    end)

    task.spawn(function()
        local Product_Info = Util.Get_Product_Info(Developer_Products["Ballerino Lololo"])

        if Product_Info then
            Offer_One_Price_Text_Label.Text =
                `{Unicode_Characters.Robux}{Util.Format_Number_With_Commas(Product_Info.PriceInRobux)}`
        else
            Offer_One_Price_Text_Label.Visible = false
        end
    end)

    Hydrate_Button(Offer_One, function()
        MarketplaceService:PromptProductPurchase(Local_Player, Developer_Products["Ballerino Lololo"])
    end)

    task.spawn(function()
        local Product_Info = Util.Get_Product_Info(Developer_Products["Tung Sahur"])

        if Product_Info then
            Offer_Two_Price_Text_Label.Text =
                `{Unicode_Characters.Robux}{Util.Format_Number_With_Commas(Product_Info.PriceInRobux)}`
        else
            Offer_Two_Price_Text_Label.Visible = false
        end
    end)

    Hydrate_Button(Offer_Two, function()
        MarketplaceService:PromptProductPurchase(Local_Player, Developer_Products["Tung Sahur"])
    end)
end

local function Setup_HUD_Right_Corner(LocalEntity: Types.Entity, PlayerGui: PlayerGui)
    local Main = PlayerGui:WaitForChild("Main") :: ScreenGui

    local Right_Corner = Main:WaitForChild("Right_Corner") :: Frame
    local Event_Template = Right_Corner:WaitForChild("Event_Template") :: ImageButton
    Event_Template.Visible = false

    local Cash = Right_Corner:WaitForChild("Cash") :: ImageButton
    local Cash_Text = Cash:WaitForChild("Title") :: TextLabel

    local Luck = Right_Corner:WaitForChild("Luck") :: ImageButton
    local Luck_Text = Luck:WaitForChild("Title") :: TextLabel

    local Mutation = Right_Corner:WaitForChild("Mutation") :: Frame
    local Mutation_Text = Mutation:WaitForChild("Title") :: TextLabel

    Hydrate_Button(Cash, function() end)
    Hydrate_Button(Luck, function() end)
    Hydrate_Button(Mutation, function() end)

    for _, Inst in { Cash, Luck, Mutation } do
        Hydrate_Button(Inst, function() end)

        local Hover = Inst:FindFirstChild("Hover") :: TextLabel

        if not Hover then
            continue
        end

        Hover.Visible = false

        Scope:Hydrate(Inst)({
            [OnEvent("MouseEnter")] = function()
                Hover.Visible = true
            end,
            [OnEvent("MouseLeave")] = function()
                Hover.Visible = false
            end,
        })
    end

    Clock(1, function()
        local Cash_Multiplier = Stat_Calculator.Get_Cash_Multiplier(LocalEntity)
        local Cash_Percent = (Cash_Multiplier - 1) * 100

        Cash.Visible = Cash_Percent ~= 0
        Cash_Text.Text = Util.Format_Percent(Cash_Percent)

        local Luck_Multiplier = Stat_Calculator.Get_Luck(LocalEntity)
        local Luck_Percent = (Luck_Multiplier - 1) * 100

        Luck.Visible = Luck_Percent ~= 0
        Luck_Text.Text = Util.Format_Percent(Luck_Percent)

        local Mutation_Multiplier = Stat_Calculator.Get_Mutation_Luck(LocalEntity)
        local Mutation_Percent = (Mutation_Multiplier - 1) * 100

        Mutation.Visible = Mutation_Percent ~= 0
        Mutation_Text.Text = Util.Format_Percent(Mutation_Percent)
    end)

    Scope:Hydrate(Right_Corner)({
        [Children] = Scope:Computed(function(Use: Fusion.Use, Processor: Fusion.Scope<Fusion.Fusion>)
            local Active_Events = Use(Fusion_Values.Active_Events)

            local Children = {}

            for Event_Name, Data in Active_Events do
                local ImageButton = Event_Template:Clone() :: ImageButton
                ImageButton.LayoutOrder = -Data.Start_Time
                ImageButton.Name = Event_Name
                ImageButton.Visible = true

                local Hover = ImageButton:FindFirstChild("Hover") :: TextLabel
                local Time_Remaining = ImageButton:FindFirstChild("Time_Remaining") :: TextLabel
                local Image = ImageButton:FindFirstChildOfClass("ImageLabel")

                Hover.Text = `{Event_Name} Event`
                Hover.Visible = false

                Hydrate_Button(ImageButton, function() end)

                Processor:Hydrate(ImageButton)({
                    [OnEvent("MouseEnter")] = function()
                        Hover.Visible = true
                    end,
                    [OnEvent("MouseLeave")] = function()
                        Hover.Visible = false
                    end,
                })

                table.insert(
                    Processor,
                    Clock(1, function()
                        local End_Time = Data.End_Time

                        local Seconds_Remaining = math.max(1, End_Time - os.time())

                        local T = Util.BreakdownTime(Seconds_Remaining)

                        Time_Remaining.Text = string.format("%02d:%02d", T.Minutes, T.Seconds)
                    end)
                )

                Image.Image = Events[Event_Name].Image

                table.insert(Processor, ImageButton)
                table.insert(Children, ImageButton)
            end

            return Children
        end),
    })
end

local function Setup_HUD_Plot_Income_Per_Sec(PlayerGui: PlayerGui)
    local Main = PlayerGui:WaitForChild("Main") :: ScreenGui
    local Plot_Income_Per_Sec = Main:WaitForChild("Plot_Income_Per_Sec")

    Scope:Hydrate(Plot_Income_Per_Sec)({
        Position = Scope:Computed(function(Use)
            if Use(DeviceType) ~= "Mobile" then
                return UDim2.fromScale(0.5, 0.85)
            else
                return UDim2.fromScale(0.5, 0.75)
            end
        end),
    })

    Scope:Hydrate(Plot_Income_Per_Sec:WaitForChild("Value"))({
        Text = Scope:Computed(function(Use)
            return `${Util.Abbreviate_Number(Use(Fusion_Values.Plot_Income_Per_Sec), 2)}/s`
        end),
    })
end

local function Setup_Hold_To_Swing_Disclaimer(PlayerGui: PlayerGui)
    local Main = PlayerGui:WaitForChild("Main") :: ScreenGui
    local Hold_To_Swing_Disclaimer = Main:WaitForChild("Hold_To_Swing_Disclaimer")

    Scope:Hydrate(Hold_To_Swing_Disclaimer)({
        Visible = Scope:Computed(function(Use)
            return Use(Fusion_Values.Hold_To_Swing_Disclaimer)
        end),
        Position = Scope:Computed(function(Use)
            if Use(DeviceType) ~= "Mobile" then
                return UDim2.fromScale(0.5, 0.77)
            else
                return UDim2.fromScale(0.5, 0.67)
            end
        end),
    })
end

local function Setup_HUD_Tutorial(LocalEntity: Types.Entity, PlayerGui: PlayerGui)
    local Tutorial = PlayerGui:WaitForChild("Visuals"):WaitForChild("Tutorial") :: ImageLabel

    local Text_Value = Scope:Value(nil)

    local Type_Writer_Task: thread?

    local Daily_Opened = false

    Scope:Observer(Fusion_Values.Tutorial_Step):onChange(function()
        local Tutorial_Step = Peek(Fusion_Values.Tutorial_Step)
        local Tutorial_Text = Peek(Tutorial_Text_Computed)

        if Type_Writer_Task then
            task.cancel(Type_Writer_Task)
        end

        if Tutorial_Step == #Tutorial_Steps then
            local Plot_Model = World:get(LocalEntity, Components.Plot_Model)

            if not Plot_Model then
                return
            end

            local Spawn = Plot_Model:WaitForChild("Spawn") :: Part

            Teleport_Character(Spawn.CFrame)
        elseif Tutorial_Step == 1 then
            Fusion_Values.Screen:set("HUD")
        end

        if Tutorial_Step >= #Tutorial_Steps and not Daily_Opened then
            Fusion_Values.Screen:set("DailyRewards")

            Daily_Opened = true
        end

        if not Tutorial_Text then
            Text_Value:set(nil)
            return
        end

        Type_Writer_Task = task.spawn(function()
            for i = 1, #Tutorial_Text do
                Text_Value:set(string.sub(Tutorial_Text, 1, i))

                TypeWriter:Play()

                task.wait(0.05)
            end
        end)
    end)

    Scope:Hydrate(Tutorial)({
        Position = Scope:Computed(function(Use)
            if Use(DeviceType) ~= "Mobile" then
                return UDim2.fromScale(0.5, 0.85)
            else
                return UDim2.fromScale(0.5, 0.75)
            end
        end),
    })

    Scope:Hydrate(Tutorial:WaitForChild("Title"))({
        Text = Scope:Computed(function(Use)
            return Use(Text_Value) or ""
        end),
    })
end

local function Setup_HUD(LocalEntity: Types.Entity, PlayerGui: PlayerGui)
    Setup_HUD_Visibility(PlayerGui)

    Setup_HUD_Top_Buttons(LocalEntity, PlayerGui)

    Setup_HUD_Left_Buttons(LocalEntity, PlayerGui)

    Setup_HUD_Cash(PlayerGui)

    Setup_HUD_Friend_Boost(PlayerGui)

    Setup_HUD_Offers(LocalEntity, PlayerGui)

    Setup_HUD_Right_Corner(LocalEntity, PlayerGui)

    Setup_HUD_Plot_Income_Per_Sec(PlayerGui)

    Setup_Hold_To_Swing_Disclaimer(PlayerGui)

    Setup_HUD_Tutorial(LocalEntity, PlayerGui)
end

local function Setup_Robux_Shop_Visibility(PlayerGui: PlayerGui)
    local Main = PlayerGui:WaitForChild("Main") :: ScreenGui
    local Frames = Main:WaitForChild("Frames") :: Frame

    local RobuxShop = Frames:WaitForChild("RobuxShop") :: ImageLabel
    local Contents = RobuxShop:WaitForChild("Contents") :: ScrollingFrame

    Hydrate_Frame_Visibility(RobuxShop, "RobuxShop", function()
        Contents.CanvasPosition = Vector2.zero
        Shop_Open:Play()
    end)

    Setup_Close_Button(RobuxShop:WaitForChild("Close"))
end

local function Setup_Robux_Shop_Starter_Pack(Local_Player: Player, PlayerGui: PlayerGui)
    local Main = PlayerGui:WaitForChild("Main") :: ScreenGui
    local Frames = Main:WaitForChild("Frames") :: Frame

    local RobuxShop = Frames:WaitForChild("RobuxShop") :: ImageLabel
    local Contents = RobuxShop:WaitForChild("Contents") :: ScrollingFrame

    local StarterPack = Contents:WaitForChild("StarterPack") :: ImageLabel
    local Buy = StarterPack:WaitForChild("Buy") :: ImageButton
    local Price = Buy:FindFirstChildOfClass("TextLabel")

    task.spawn(function()
        local Product_Info = Util.Get_Product_Info(Developer_Products["Starter Pack"])

        if Product_Info then
            Price.Text = `{Unicode_Characters.Robux}{Util.Format_Number_With_Commas(Product_Info.PriceInRobux)}`
        else
            Price.Visible = false
        end
    end)

    Hydrate_Button(Buy, function()
        MarketplaceService:PromptProductPurchase(Local_Player, Developer_Products["Starter Pack"])
    end)
end

local function Setup_Robux_Shop_Pro_Pack(Local_Player: Player, PlayerGui: PlayerGui)
    local Main = PlayerGui:WaitForChild("Main") :: ScreenGui
    local Frames = Main:WaitForChild("Frames") :: Frame

    local RobuxShop = Frames:WaitForChild("RobuxShop") :: ImageLabel
    local Contents = RobuxShop:WaitForChild("Contents") :: ScrollingFrame

    local ProPack = Contents:WaitForChild("ProPack") :: ImageLabel
    local Buy = ProPack:WaitForChild("Buy") :: ImageButton
    local Price = Buy:FindFirstChildOfClass("TextLabel")

    task.spawn(function()
        local Product_Info = Util.Get_Product_Info(Developer_Products["Pro Pack"])

        if Product_Info then
            Price.Text = `{Unicode_Characters.Robux}{Util.Format_Number_With_Commas(Product_Info.PriceInRobux)}`
        else
            Price.Visible = false
        end
    end)

    Hydrate_Button(Buy, function()
        MarketplaceService:PromptProductPurchase(Local_Player, Developer_Products["Pro Pack"])
    end)
end

local function Setup_Robux_Shop_Brainrot_Offer_One(Local_Player: Player, PlayerGui: PlayerGui)
    local Main = PlayerGui:WaitForChild("Main") :: ScreenGui
    local Frames = Main:WaitForChild("Frames") :: Frame

    local RobuxShop = Frames:WaitForChild("RobuxShop") :: ImageLabel
    local Contents = RobuxShop:WaitForChild("Contents") :: ScrollingFrame

    local Brainrots = Contents:WaitForChild("Brainrots")
    local Offer_One = Brainrots:WaitForChild("One") :: ImageLabel
    local Buy = Offer_One:WaitForChild("Buy") :: ImageButton
    local Price = Buy:FindFirstChildOfClass("TextLabel")

    task.spawn(function()
        local Product_Info = Util.Get_Product_Info(Developer_Products["Frigo Camelo"])

        if Product_Info then
            Price.Text = `{Unicode_Characters.Robux}{Util.Format_Number_With_Commas(Product_Info.PriceInRobux)}`
        else
            Price.Visible = false
        end
    end)

    Hydrate_Button(Buy, function()
        MarketplaceService:PromptProductPurchase(Local_Player, Developer_Products["Frigo Camelo"])
    end)
end

local function Setup_Robux_Shop_Brainrot_Offer_Two(Local_Player: Player, PlayerGui: PlayerGui)
    local Main = PlayerGui:WaitForChild("Main") :: ScreenGui
    local Frames = Main:WaitForChild("Frames") :: Frame

    local RobuxShop = Frames:WaitForChild("RobuxShop") :: ImageLabel
    local Contents = RobuxShop:WaitForChild("Contents") :: ScrollingFrame

    local Brainrots = Contents:WaitForChild("Brainrots")
    local Offer_Two = Brainrots:WaitForChild("Two") :: ImageLabel
    local Buy = Offer_Two:WaitForChild("Buy") :: ImageButton
    local Price = Buy:FindFirstChildOfClass("TextLabel")

    task.spawn(function()
        local Product_Info = Util.Get_Product_Info(Developer_Products["Six Seven"])

        if Product_Info then
            Price.Text = `{Unicode_Characters.Robux}{Util.Format_Number_With_Commas(Product_Info.PriceInRobux)}`
        else
            Price.Visible = false
        end
    end)

    Hydrate_Button(Buy, function()
        MarketplaceService:PromptProductPurchase(Local_Player, Developer_Products["Six Seven"])
    end)
end

local function Setup_Robux_Shop_Brainrot_Offer_Three(Local_Player: Player, PlayerGui: PlayerGui)
    local Main = PlayerGui:WaitForChild("Main") :: ScreenGui
    local Frames = Main:WaitForChild("Frames") :: Frame

    local RobuxShop = Frames:WaitForChild("RobuxShop") :: ImageLabel
    local Contents = RobuxShop:WaitForChild("Contents") :: ScrollingFrame

    local Brainrots = Contents:WaitForChild("Brainrots")
    local Offer_Three = Brainrots:WaitForChild("Three") :: ImageLabel
    local Buy = Offer_Three:WaitForChild("Buy") :: ImageButton
    local Price = Buy:FindFirstChildOfClass("TextLabel")

    task.spawn(function()
        local Product_Info = Util.Get_Product_Info(Developer_Products["Esok Sekolah"])

        if Product_Info then
            Price.Text = `{Unicode_Characters.Robux}{Util.Format_Number_With_Commas(Product_Info.PriceInRobux)}`
        else
            Price.Visible = false
        end
    end)

    Hydrate_Button(Buy, function()
        MarketplaceService:PromptProductPurchase(Local_Player, Developer_Products["Esok Sekolah"])
    end)
end

local function Setup_Robux_Shop_Gamepass_Offer_One(Local_Player: Player, PlayerGui: PlayerGui)
    local Main = PlayerGui:WaitForChild("Main") :: ScreenGui
    local Frames = Main:WaitForChild("Frames") :: Frame

    local RobuxShop = Frames:WaitForChild("RobuxShop") :: ImageLabel
    local Contents = RobuxShop:WaitForChild("Contents") :: ScrollingFrame

    local Gamepasses_Frame = Contents:WaitForChild("Gamepasses")
    local Offer_One = Gamepasses_Frame:WaitForChild("One") :: ImageLabel
    local Buy = Offer_One:WaitForChild("Buy") :: ImageButton
    local Price = Buy:FindFirstChildOfClass("TextLabel")

    task.spawn(function()
        local Product_Info = Util.Get_Gamepass_Info(Gamepasses["+2 Slots"])

        if Product_Info then
            Price.Text = `{Unicode_Characters.Robux}{Util.Format_Number_With_Commas(Product_Info.PriceInRobux)}`
        else
            Price.Visible = false
        end
    end)

    Hydrate_Button(Buy, function()
        MarketplaceService:PromptGamePassPurchase(Local_Player, Gamepasses["+2 Slots"])
    end)
end

local function Setup_Robux_Shop_Gamepass_Offer_Two(Local_Player: Player, PlayerGui: PlayerGui)
    local Main = PlayerGui:WaitForChild("Main") :: ScreenGui
    local Frames = Main:WaitForChild("Frames") :: Frame

    local RobuxShop = Frames:WaitForChild("RobuxShop") :: ImageLabel
    local Contents = RobuxShop:WaitForChild("Contents") :: ScrollingFrame

    local Gamepasses_Frame = Contents:WaitForChild("Gamepasses")
    local Offer_Two = Gamepasses_Frame:WaitForChild("Two") :: ImageLabel
    local Buy = Offer_Two:WaitForChild("Buy") :: ImageButton
    local Price = Buy:FindFirstChildOfClass("TextLabel")

    task.spawn(function()
        local Product_Info = Util.Get_Gamepass_Info(Gamepasses["x2 Cash"])

        if Product_Info then
            Price.Text = `{Unicode_Characters.Robux}{Util.Format_Number_With_Commas(Product_Info.PriceInRobux)}`
        else
            Price.Visible = false
        end
    end)

    Hydrate_Button(Buy, function()
        MarketplaceService:PromptGamePassPurchase(Local_Player, Gamepasses["x2 Cash"])
    end)
end

local function Setup_Robux_Shop_Gamepass_Offer_Three(Local_Player: Player, PlayerGui: PlayerGui)
    local Main = PlayerGui:WaitForChild("Main") :: ScreenGui
    local Frames = Main:WaitForChild("Frames") :: Frame

    local RobuxShop = Frames:WaitForChild("RobuxShop") :: ImageLabel
    local Contents = RobuxShop:WaitForChild("Contents") :: ScrollingFrame

    local Gamepasses_Frame = Contents:WaitForChild("Gamepasses")
    local Offer_Three = Gamepasses_Frame:WaitForChild("Three") :: ImageLabel
    local Buy = Offer_Three:WaitForChild("Buy") :: ImageButton
    local Price = Buy:FindFirstChildOfClass("TextLabel")

    task.spawn(function()
        local Product_Info = Util.Get_Gamepass_Info(Gamepasses["x2 Luck"])

        if Product_Info then
            Price.Text = `{Unicode_Characters.Robux}{Util.Format_Number_With_Commas(Product_Info.PriceInRobux)}`
        else
            Price.Visible = false
        end
    end)

    Hydrate_Button(Buy, function()
        MarketplaceService:PromptGamePassPurchase(Local_Player, Gamepasses["x2 Luck"])
    end)
end
local function Setup_Robux_Shop_Time_Warping_Offer_One(Local_Player: Player, PlayerGui: PlayerGui)
    local Main = PlayerGui:WaitForChild("Main") :: ScreenGui
    local Frames = Main:WaitForChild("Frames") :: Frame

    local RobuxShop = Frames:WaitForChild("RobuxShop") :: ImageLabel
    local Contents = RobuxShop:WaitForChild("Contents") :: ScrollingFrame

    local Time_Warping = Contents:WaitForChild("TimeWarping")
    local Offer_One = Time_Warping:WaitForChild("One") :: ImageLabel
    local Buy = Offer_One:WaitForChild("Buy") :: ImageButton
    local Price = Buy:FindFirstChildOfClass("TextLabel")

    task.spawn(function()
        local Product_Info = Util.Get_Product_Info(Developer_Products["15 min"])

        if Product_Info then
            Price.Text = `{Unicode_Characters.Robux}{Util.Format_Number_With_Commas(Product_Info.PriceInRobux)}`
        else
            Price.Visible = false
        end
    end)

    Hydrate_Button(Buy, function()
        MarketplaceService:PromptProductPurchase(Local_Player, Developer_Products["15 min"])
    end)
end

local function Setup_Robux_Shop_Time_Warping_Offer_Two(Local_Player: Player, PlayerGui: PlayerGui)
    local Main = PlayerGui:WaitForChild("Main") :: ScreenGui
    local Frames = Main:WaitForChild("Frames") :: Frame

    local RobuxShop = Frames:WaitForChild("RobuxShop") :: ImageLabel
    local Contents = RobuxShop:WaitForChild("Contents") :: ScrollingFrame

    local Time_Warping = Contents:WaitForChild("TimeWarping")
    local Offer_Two = Time_Warping:WaitForChild("Two") :: ImageLabel
    local Buy = Offer_Two:WaitForChild("Buy") :: ImageButton
    local Price = Buy:FindFirstChildOfClass("TextLabel")

    task.spawn(function()
        local Product_Info = Util.Get_Product_Info(Developer_Products["1 hour"])

        if Product_Info then
            Price.Text = `{Unicode_Characters.Robux}{Util.Format_Number_With_Commas(Product_Info.PriceInRobux)}`
        else
            Price.Visible = false
        end
    end)

    Hydrate_Button(Buy, function()
        MarketplaceService:PromptProductPurchase(Local_Player, Developer_Products["1 hour"])
    end)
end

local function Setup_Robux_Shop_Time_Warping_Offer_Three(Local_Player: Player, PlayerGui: PlayerGui)
    local Main = PlayerGui:WaitForChild("Main") :: ScreenGui
    local Frames = Main:WaitForChild("Frames") :: Frame

    local RobuxShop = Frames:WaitForChild("RobuxShop") :: ImageLabel
    local Contents = RobuxShop:WaitForChild("Contents") :: ScrollingFrame

    local Time_Warping = Contents:WaitForChild("TimeWarping")
    local Offer_Three = Time_Warping:WaitForChild("Three") :: ImageLabel
    local Buy = Offer_Three:WaitForChild("Buy") :: ImageButton
    local Price = Buy:FindFirstChildOfClass("TextLabel")

    task.spawn(function()
        local Product_Info = Util.Get_Product_Info(Developer_Products["6 hours"])

        if Product_Info then
            Price.Text = `{Unicode_Characters.Robux}{Util.Format_Number_With_Commas(Product_Info.PriceInRobux)}`
        else
            Price.Visible = false
        end
    end)

    Hydrate_Button(Buy, function()
        MarketplaceService:PromptProductPurchase(Local_Player, Developer_Products["6 hours"])
    end)
end

local function Setup_Robux_Shop_Cash_Offer_One(Local_Player: Player, PlayerGui: PlayerGui)
    local Main = PlayerGui:WaitForChild("Main") :: ScreenGui
    local Frames = Main:WaitForChild("Frames") :: Frame

    local RobuxShop = Frames:WaitForChild("RobuxShop") :: ImageLabel
    local Contents = RobuxShop:WaitForChild("Contents") :: ScrollingFrame

    local Cash = Contents:WaitForChild("Cash")
    local Offer_One = Cash:WaitForChild("One") :: ImageLabel
    local Buy = Offer_One:WaitForChild("Buy") :: ImageButton
    local Price = Buy:FindFirstChildOfClass("TextLabel")

    task.spawn(function()
        local Product_Info = Util.Get_Product_Info(Developer_Products["Small Pack"])

        if Product_Info then
            Price.Text = `{Unicode_Characters.Robux}{Util.Format_Number_With_Commas(Product_Info.PriceInRobux)}`
        else
            Price.Visible = false
        end
    end)

    Hydrate_Button(Buy, function()
        MarketplaceService:PromptProductPurchase(Local_Player, Developer_Products["Small Pack"])
    end)
end

local function Setup_Robux_Shop_Cash_Offer_Two(Local_Player: Player, PlayerGui: PlayerGui)
    local Main = PlayerGui:WaitForChild("Main") :: ScreenGui
    local Frames = Main:WaitForChild("Frames") :: Frame

    local RobuxShop = Frames:WaitForChild("RobuxShop") :: ImageLabel
    local Contents = RobuxShop:WaitForChild("Contents") :: ScrollingFrame

    local Cash = Contents:WaitForChild("Cash")
    local Offer_Two = Cash:WaitForChild("Two") :: ImageLabel
    local Buy = Offer_Two:WaitForChild("Buy") :: ImageButton
    local Price = Buy:FindFirstChildOfClass("TextLabel")

    task.spawn(function()
        local Product_Info = Util.Get_Product_Info(Developer_Products["Medium Pack"])

        if Product_Info then
            Price.Text = `{Unicode_Characters.Robux}{Util.Format_Number_With_Commas(Product_Info.PriceInRobux)}`
        else
            Price.Visible = false
        end
    end)

    Hydrate_Button(Buy, function()
        MarketplaceService:PromptProductPurchase(Local_Player, Developer_Products["Medium Pack"])
    end)
end

local function Setup_Robux_Shop_Cash_Offer_Three(Local_Player: Player, PlayerGui: PlayerGui)
    local Main = PlayerGui:WaitForChild("Main") :: ScreenGui
    local Frames = Main:WaitForChild("Frames") :: Frame

    local RobuxShop = Frames:WaitForChild("RobuxShop") :: ImageLabel
    local Contents = RobuxShop:WaitForChild("Contents") :: ScrollingFrame

    local Cash = Contents:WaitForChild("Cash")
    local Offer_Three = Cash:WaitForChild("Three") :: ImageLabel
    local Buy = Offer_Three:WaitForChild("Buy") :: ImageButton
    local Price = Buy:FindFirstChildOfClass("TextLabel")

    task.spawn(function()
        local Product_Info = Util.Get_Product_Info(Developer_Products["Huge Pack"])

        if Product_Info then
            Price.Text = `{Unicode_Characters.Robux}{Util.Format_Number_With_Commas(Product_Info.PriceInRobux)}`
        else
            Price.Visible = false
        end
    end)

    Hydrate_Button(Buy, function()
        MarketplaceService:PromptProductPurchase(Local_Player, Developer_Products["Huge Pack"])
    end)
end

local function Setup_Robux_Shop_Contents(LocalEntity: Types.Entity, PlayerGui: PlayerGui)
    local Local_Player = World:get(LocalEntity, Components.Player)

    -- Packs
    Setup_Robux_Shop_Starter_Pack(Local_Player, PlayerGui)

    Setup_Robux_Shop_Pro_Pack(Local_Player, PlayerGui)

    -- Brainrot Offers
    Setup_Robux_Shop_Brainrot_Offer_One(Local_Player, PlayerGui)

    Setup_Robux_Shop_Brainrot_Offer_Two(Local_Player, PlayerGui)

    Setup_Robux_Shop_Brainrot_Offer_Three(Local_Player, PlayerGui)

    -- Time Warping Offers
    Setup_Robux_Shop_Time_Warping_Offer_One(Local_Player, PlayerGui)
    Setup_Robux_Shop_Time_Warping_Offer_Two(Local_Player, PlayerGui)
    Setup_Robux_Shop_Time_Warping_Offer_Three(Local_Player, PlayerGui)

    -- Cash Offers
    Setup_Robux_Shop_Cash_Offer_One(Local_Player, PlayerGui)

    Setup_Robux_Shop_Cash_Offer_Two(Local_Player, PlayerGui)

    Setup_Robux_Shop_Cash_Offer_Three(Local_Player, PlayerGui)

    -- Gamepass Offers
    Setup_Robux_Shop_Gamepass_Offer_One(Local_Player, PlayerGui)
    Setup_Robux_Shop_Gamepass_Offer_Two(Local_Player, PlayerGui)
    Setup_Robux_Shop_Gamepass_Offer_Three(Local_Player, PlayerGui)
end

local function Setup_Robux_Shop(LocalEntity: Types.Entity, PlayerGui: PlayerGui)
    Setup_Robux_Shop_Visibility(PlayerGui)

    Setup_Robux_Shop_Contents(LocalEntity, PlayerGui)
end

local function Setup_Index_Visibility(PlayerGui: PlayerGui)
    local Main = PlayerGui:WaitForChild("Main") :: ScreenGui
    local Frames = Main:WaitForChild("Frames") :: Frame

    local Index = Frames:WaitForChild("Index") :: ImageLabel
    local Contents = Index:WaitForChild("Contents") :: ScrollingFrame

    Hydrate_Frame_Visibility(Index, "Index", function()
        Contents.CanvasPosition = Vector2.zero
    end)

    Setup_Close_Button(Index:WaitForChild("Close"))
end

local function Setup_Index_Contents(PlayerGui: PlayerGui)
    local Main = PlayerGui:WaitForChild("Main") :: ScreenGui
    local Frames = Main:WaitForChild("Frames") :: Frame

    local Index = Frames:WaitForChild("Index") :: ImageLabel

    local Contents = Index:WaitForChild("Contents") :: ScrollingFrame
    local Template = Contents:WaitForChild("Template") :: ImageLabel
    Template.Visible = false

    local Mutations = Index:WaitForChild("Mutations")

    local Mutation_Category = Scope:Value("Normal")

    Scope:Hydrate(Contents)({
        [Children] = Scope:Computed(function(Use, Processor: Fusion.Scope<Fusion.Fusion>)
            local Mutation = Use(Mutation_Category)

            local Children = {}

            for Brainrot_Name, Data in Brainrots do
                local Owned_Computed = Processor:Computed(function(Use)
                    local Index_Data = Use(Fusion_Values.Index)

                    if Index_Data[Mutation] and table.find(Index_Data[Mutation], Brainrot_Name) then
                        return true
                    end

                    return false
                end)

                local ImageLabel = Template:Clone()
                ImageLabel.LayoutOrder = -Rarities[Data.Rarity]
                ImageLabel.Visible = true

                local Title = ImageLabel:FindFirstChild("Title") :: TextLabel
                Title.Text = Brainrot_Name

                Processor:Hydrate(Title)({
                    Visible = Owned_Computed,
                })

                local Rarity = ImageLabel:FindFirstChild("Rarity") :: TextLabel
                Rarity.Text = Data.Rarity

                local UIGradient = UIGradients:FindFirstChild(Data.Rarity)

                if UIGradient then
                    UIGradient:Clone().Parent = Rarity
                end

                local ViewportFrame = ImageLabel:FindFirstChildOfClass("ViewportFrame")

                Processor:Hydrate(ViewportFrame)({
                    ImageColor3 = Processor:Computed(function(Use)
                        if Use(Owned_Computed) then
                            return Color3.fromRGB(255, 255, 255)
                        end

                        return Color3.fromRGB(0, 0, 0)
                    end),
                })

                local ViewportCamera = Instance.new("Camera")
                ViewportCamera.FieldOfView = 70
                ViewportCamera.Parent = ViewportFrame

                if Mutation == "Rainbow" then
                    UIGradients:FindFirstChild("Rainbow"):Clone().Parent = ViewportFrame
                end

                ViewportFrame.CurrentCamera = ViewportCamera

                local WorldModel = Instance.new("WorldModel")
                WorldModel.Parent = ViewportFrame

                local Model = Generate_Brainrot_Model(Brainrot_Name, Mutation, {}, 10)
                Model.Parent = workspace.Debris
                Model:PivotTo(CFrame.new(Vector3.zero))
                Model.Parent = WorldModel

                local Cf, Size = Model:GetBoundingBox()
                local MaxSize = math.max(Size.X, Size.Y, Size.Z)

                local Distance = MaxSize * 1

                -- Camera on the opposite side of the model
                ViewportCamera.CFrame = Cf
                    * CFrame.new(0, MaxSize * 0.1, -Distance)
                    * CFrame.fromOrientation(0, math.rad(180), 0)

                table.insert(Processor, ImageLabel)

                table.insert(Children, ImageLabel)
            end

            return Children
        end),
    })

    for _, Inst in Mutations:GetChildren() do
        if not Inst:IsA("ImageButton") then
            continue
        end

        Hydrate_Button(Inst, function()
            Mutation_Category:set(Inst.Name)
            Contents.CanvasPosition = Vector2.zero
        end)
    end
end

local function Setup_Index(LocalEntity: Types.Entity, PlayerGui: PlayerGui)
    Setup_Index_Visibility(PlayerGui)

    Setup_Index_Contents(PlayerGui)
end

local function Setup_Rebirth_Visibility(PlayerGui: PlayerGui)
    local Main = PlayerGui:WaitForChild("Main") :: ScreenGui
    local Frames = Main:WaitForChild("Frames") :: Frame

    local Rebirth = Frames:WaitForChild("Rebirth") :: ImageLabel

    Hydrate_Frame_Visibility(Rebirth, "Rebirth")

    Setup_Close_Button(Rebirth:WaitForChild("Close"))
end

local function Setup_Rebirth_Contents(PlayerGui: PlayerGui)
    local Main = PlayerGui:WaitForChild("Main") :: ScreenGui
    local Frames = Main:WaitForChild("Frames") :: Frame

    local Rebirth = Frames:WaitForChild("Rebirth") :: ImageLabel
    local Old_Multiplier_Title = Rebirth:WaitForChild("Old_Multiplier"):FindFirstChildOfClass("TextLabel")
    local New_Multiplier_Title = Rebirth:WaitForChild("New_Multiplier"):FindFirstChildOfClass("TextLabel")
    local Rebirth_Button = Rebirth:WaitForChild("Rebirth") :: ImageButton

    local ProgressBar = Rebirth:WaitForChild("ProgressBar")
    local ProgressBar_Frame = ProgressBar:FindFirstChildOfClass("Frame")
    local ProgressBar_Title = ProgressBar:FindFirstChildOfClass("TextLabel")

    Scope:Hydrate(Old_Multiplier_Title)({
        Text = Scope:Computed(function(Use)
            local value = Rebirths[Use(Fusion_Values.Rebirth)].Multiplier
            return `x{string.format("%.2f", value)}`
        end),
    })

    Scope:Hydrate(New_Multiplier_Title)({
        Text = Scope:Computed(function(Use)
            local Next_Rebirth = Rebirths[Use(Fusion_Values.Rebirth) + 1]

            if not Next_Rebirth then
                return "?"
            end

            return `x{string.format("%.2f", Next_Rebirth.Multiplier)}`
        end),
    })

    Scope:Hydrate(Rebirth_Button)({
        Image = Scope:Computed(function(Use)
            local Plot_Income_Per_Sec = Use(Fusion_Values.Plot_Income_Per_Sec)
            local Next_Rebirth = Rebirths[Use(Fusion_Values.Rebirth) + 1]

            if not Next_Rebirth then
                return CANT_REBIRTH_ID
            end

            local Progress = math.clamp(Plot_Income_Per_Sec / Next_Rebirth.Requirement, 0, 1)

            if Progress ~= 1 then
                return CANT_REBIRTH_ID
            end

            return CAN_REBIRTH_ID
        end),
    })

    Hydrate_Button(Rebirth_Button, function()
        if not Ratelimits.Rebirth() then
            return
        end

        Network.Requests.Rebirth.Fire()
    end)

    Scope:Hydrate(ProgressBar_Frame)({
        Size = Scope:Computed(function(Use)
            local Plot_Income_Per_Sec = Use(Fusion_Values.Plot_Income_Per_Sec)
            local Next_Rebirth = Rebirths[Use(Fusion_Values.Rebirth) + 1]

            if not Next_Rebirth then
                return UDim2.fromScale(0, 1)
            end

            return UDim2.fromScale(math.clamp(Plot_Income_Per_Sec / Next_Rebirth.Requirement, 0, 1), 1)
        end),
    })

    Scope:Hydrate(ProgressBar_Title)({
        Text = Scope:Computed(function(Use)
            local Plot_Income_Per_Sec = Use(Fusion_Values.Plot_Income_Per_Sec)
            local Next_Rebirth = Rebirths[Use(Fusion_Values.Rebirth) + 1]

            if not Next_Rebirth then
                return "Max Rebirth"
            end

            return `Total Cash Per Second: ${Util.Format_Number_With_Commas(Plot_Income_Per_Sec)} / ${Util.Format_Number_With_Commas(
                Next_Rebirth.Requirement
            )}`
        end),
    })
end

local function Setup_Rebirth(LocalEntity: Types.Entity, PlayerGui: PlayerGui)
    Setup_Rebirth_Visibility(PlayerGui)

    Setup_Rebirth_Contents(PlayerGui)
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
        local CanvasHeight = Contents.AbsoluteCanvasSize.Y
        local WindowHeight = Contents.AbsoluteWindowSize.Y

        local MaxY = math.max(0, CanvasHeight - WindowHeight)

        TargetY = math.clamp(TargetY, 0, MaxY)

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
            Active = Scope:Computed(function(Use)
                if Use(Owned_Computed) == true then
                    return true
                end

                if not Use(Tutorial_Completed_Computed) and Name ~= "Stone" then
                    return false
                end

                return Use(Has_Rebirth_Required_Computed)
            end),
            Interactable = Scope:Computed(function(Use)
                if Use(Owned_Computed) == true then
                    return true
                end

                if not Use(Tutorial_Completed_Computed) and Name ~= "Stone" then
                    return false
                end

                return Use(Has_Rebirth_Required_Computed)
            end),
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

                if not Use(Tutorial_Completed_Computed) and Name ~= "Stone" then
                    return true
                end

                return not Use(Has_Rebirth_Required_Computed)
            end),
        })

        Scope:Hydrate(Rebirth_Requirement_Title)({
            Text = Scope:Computed(function(Use)
                if not Use(Tutorial_Completed_Computed) and Name ~= "Stone" then
                    return "Comple the tutorial"
                end

                return `Requires Rebirth {Data.Rebirth}`
            end),
        })

        local Tutorial_Arrow = ImageLabel:WaitForChild("Tutorial_Arrow")

        if Name ~= "Stone" then
            Tutorial_Arrow:Destroy()
            continue
        end

        local Tutorial_Arrow_Start_Position = UDim2.fromScale(0.682, 0.709)
        local Tutorial_Arrow_End_Position = UDim2.fromScale(0.71, 0.709)

        local Tutorial_Arrow_Tween_Info = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

        local Tutorial_Arrow_Position = Scope:Value(Tutorial_Arrow_Start_Position)
        local Tutorial_Arrow_Position_Tween = Scope:Tween(Tutorial_Arrow_Position, Tutorial_Arrow_Tween_Info)

        Scope:Hydrate(Tutorial_Arrow)({
            Position = Tutorial_Arrow_Position_Tween,
            Visible = Scope:Computed(function(Use)
                return Use(Fusion_Values.Tutorial_Step) == 4
            end),
        })

        Clock(0.5, function()
            if Peek(Fusion_Values.Tutorial_Step) ~= 4 then
                return
            end

            if Peek(Tutorial_Arrow_Position) == Tutorial_Arrow_Start_Position then
                Tutorial_Arrow_Position:set(Tutorial_Arrow_End_Position)
            else
                Tutorial_Arrow_Position:set(Tutorial_Arrow_Start_Position)
            end
        end)
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

    local Time = Blocks_Frame:WaitForChild("Time") :: TextLabel

    local Contents = Blocks_Frame:WaitForChild("Contents") :: ScrollingFrame
    local Template = Contents:WaitForChild("Template") :: ImageLabel

    Clock(1, function()
        local Last_Restock = World:get(LocalEntity, Components.Last_Restock)
        local Next_Restock = Last_Restock + Config.RESTOCK_TIME

        local Remaining = math.max(0, Next_Restock - os.time())

        local T = Util.BreakdownTime(Remaining)

        Time.Text = `New blocks in {T.Minutes}m {T.Seconds}s`
    end)

    for Name, Data in Blocks do
        if not Data.Price then
            continue
        end

        local Stock_Computed = Scope:Computed(function(Use)
            local Current_Stock = Use(Fusion_Values.Stock)

            if Current_Stock[Name] ~= nil then
                return Current_Stock[Name]
            end

            return 0
        end)

        local Can_Buy_Computed = Scope:Computed(function(Use)
            if Use(Stock_Computed) > 0 then
                return true
            end

            return false
        end)

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

        local Stock = ImageLabel:WaitForChild("Stock") :: TextLabel
        Scope:Hydrate(Stock)({
            Text = Scope:Computed(function(Use)
                return `x{Use(Stock_Computed)} Stock`
            end),
        })

        local NoStock = ImageLabel:WaitForChild("NoStock") :: Frame
        Scope:Hydrate(NoStock)({
            Visible = Scope:Computed(function(Use)
                return Use(Stock_Computed) == 0
            end),
        })

        local Buy = ImageLabel:WaitForChild("Buy") :: ImageButton

        Scope:Hydrate(Buy)({
            Active = Can_Buy_Computed,
            Interactable = Can_Buy_Computed,
        })

        local Price = Buy:WaitForChild("Price") :: TextLabel
        Price.Text = `${Util.Format_Number_With_Commas(Data.Price, 2)}`

        Hydrate_Button(Buy, function()
            Network.Requests.Buy_Block.Fire(Name)
        end)

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
    local Contents = Upgrades_Frame:WaitForChild("Contents") :: ScrollingFrame

    Hydrate_Frame_Visibility(Upgrades_Frame, "Upgrades", function()
        Contents.CanvasPosition = Vector2.zero
    end)

    Setup_Close_Button(Upgrades_Frame:WaitForChild("Close"))
end

local function Setup_Upgrades_Content(LocalEntity: Types.Entity, PlayerGui: PlayerGui)
    local Local_Player = World:get(LocalEntity, Components.Player)

    local Main = PlayerGui:WaitForChild("Main") :: ScreenGui
    local Frames = Main:WaitForChild("Frames") :: Frame
    local Upgrades_Frame = Frames:WaitForChild("Upgrades")

    local Contents = Upgrades_Frame:WaitForChild("Contents") :: ScrollingFrame
    local Template = Contents:WaitForChild("Template") :: ImageLabel

    for Name, Data in Upgrades do
        local Level_Computed = Scope:Computed(function(Use)
            return Use(Fusion_Values.Upgrades)[Name] or 1
        end)

        local Has_Rebirth_Required_Computed = Scope:Computed(function(Use)
            return Use(Fusion_Values.Rebirth) >= Data.Rebirth
        end)

        local ImageLabel = Template:Clone()
        ImageLabel.Name = Name
        ImageLabel.LayoutOrder = Data.Index
        ImageLabel.Parent = Template.Parent

        local Title = ImageLabel:WaitForChild("Title") :: TextLabel
        Title.Text = Name

        local Icon = ImageLabel:WaitForChild("Icon") :: ImageLabel
        Icon.Image = Data.Image
        Icon.Size = Data.Image_Size

        local Original_Text_Label = ImageLabel:WaitForChild("Original") :: TextLabel
        local New_Text_Label = ImageLabel:WaitForChild("New") :: TextLabel

        Scope:Hydrate(Original_Text_Label)({
            Text = Scope:Computed(function(Use)
                local Level = Use(Level_Computed)
                local Current_Data = Data.Levels[Level]

                if Current_Data then
                    return Util.Format_Percent(Current_Data.Percent)
                end

                return "+0%"
            end),
        })

        Scope:Hydrate(New_Text_Label)({
            Text = Scope:Computed(function(Use)
                local Level = Use(Level_Computed)
                local Next_Data = Data.Levels[Level + 1]

                if Next_Data then
                    return Util.Format_Percent(Next_Data.Percent)
                end

                return "Max"
            end),
        })

        local Buy = ImageLabel:WaitForChild("Buy") :: ImageButton

        Scope:Hydrate(Buy)({
            Active = Has_Rebirth_Required_Computed,
            Interactable = Has_Rebirth_Required_Computed,
        })

        local Price = Buy:WaitForChild("Price") :: TextLabel
        Scope:Hydrate(Price)({
            Text = Scope:Computed(function(Use)
                local Next_Data = Data.Levels[Use(Level_Computed) + 1]

                if Next_Data then
                    return `${Util.Format_Number_With_Commas(Next_Data.Price, 2)}`
                end

                return "Max"
            end),
        })

        Hydrate_Button(Buy, function()
            Network.Requests.Buy_Upgrade.Fire(Name)
        end)

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

        Scope:Hydrate(RobuxBuy)({
            Visible = Scope:Computed(function(Use: Fusion.Use)
                local Next_Data = Data.Levels[Use(Level_Computed) + 1]

                if Next_Data then
                    return true
                end

                return false
            end),
            Active = Has_Rebirth_Required_Computed,
            Interactable = Has_Rebirth_Required_Computed,
        })

        Hydrate_Button(RobuxBuy, function()
            MarketplaceService:PromptProductPurchase(Local_Player, Data.Developer_Product)
        end)

        local Rebirth_Requirement = ImageLabel:WaitForChild("Rebirth_Requirement")
        local Rebirth_Requirement_Title = Rebirth_Requirement:WaitForChild("Title") :: TextLabel

        Scope:Hydrate(Rebirth_Requirement)({
            Visible = Scope:Computed(function(Use)
                return not Use(Has_Rebirth_Required_Computed)
            end),
        })

        Rebirth_Requirement_Title.Text = `Requires Rebirth {Data.Rebirth}`
    end

    Template.Visible = false
end

local function Setup_Upgrades(LocalEntity: Types.Entity, PlayerGui: PlayerGui)
    Setup_Upgrades_Visibility(PlayerGui)

    Setup_Upgrades_Content(LocalEntity, PlayerGui)
end

local function Setup_Daily_Rewards_Visibility(PlayerGui: PlayerGui)
    local Main = PlayerGui:WaitForChild("Main") :: ScreenGui
    local Frames = Main:WaitForChild("Frames") :: Frame

    local Daily_Rewards_Frame = Frames:WaitForChild("DailyRewards") :: ImageLabel

    Hydrate_Frame_Visibility(Daily_Rewards_Frame, "DailyRewards")

    Setup_Close_Button(Daily_Rewards_Frame:WaitForChild("Close"))
end

local function Setup_Daily_Rewards_Content(PlayerGui: PlayerGui)
    local Main = PlayerGui:WaitForChild("Main") :: ScreenGui
    local Frames = Main:WaitForChild("Frames") :: Frame

    local Daily_Rewards_Frame = Frames:WaitForChild("DailyRewards") :: ImageLabel

    local DAILY_REWARD_ID = Config.DAILY_REWARD_ID

    local Update_Funcs = {}

    for Index, Data in Daily_Rewards[DAILY_REWARD_ID] do
        local ImageLabel = Daily_Rewards_Frame:FindFirstChild(tostring(Index))
        local Title = ImageLabel:WaitForChild("Title") :: TextLabel
        local Image = ImageLabel:WaitForChild("Image") :: ImageLabel
        local Claim = ImageLabel:WaitForChild("Claim") :: ImageLabel
        local Claim_Title = Claim:WaitForChild("Title") :: TextLabel

        if Data.Type == "Cash" then
            Title.Text = `${Util.Format_Number_With_Commas(Data.Amount)}`

            UIGradients:WaitForChild("Cash"):Clone().Parent = Title

            Image.Image = "rbxassetid://126731247819551"
        elseif Data.Type == "Brainrot" then
            local Brainrot_Rarity = Brainrots[Data.Name].Rarity

            local Formatted_Name = not Data.Primary_Mutation and Data.Name or `{Data.Primary_Mutation} {Data.Name}`
            Title.Text = Formatted_Name

            if Index ~= 7 then
                UIGradients:WaitForChild(Brainrot_Rarity):Clone().Parent = Title
            end

            Image.Image = Data.Image

            Image:AddTag("ImageFloat")
        end

        table.insert(Update_Funcs, function()
            local Claimed_Daily_Rewards = Peek(Fusion_Values.Claimed_Daily_Rewards)
            local Elapsed = os.time() - Peek(Fusion_Values.Last_Daily_Reward_Claim)
            local Remaining_Seconds = math.max((86_400 / 2) - Elapsed, 0)
            local T = Util.BreakdownTime(Remaining_Seconds)

            local NextIndex = #Claimed_Daily_Rewards + 1
            local CanClaim = (Index == NextIndex) and Remaining_Seconds == 0

            if table.find(Claimed_Daily_Rewards, tostring(Index)) then
                Claim.Image = CLAIMED_DAILY_REWARD_ID
                Claim_Title.Text = "Claimed"
            elseif Index == NextIndex then
                if CanClaim then
                    Claim.Image = CLAIMABLE_DAILY_REWARD_ID
                    Claim_Title.Text = "Claim"
                else
                    Claim.Image = NON_CLAIMABLE_DAILY_REWARD_ID

                    if T.Days > 0 then
                        Claim_Title.Text = string.format("%02d:%02d:%02d:%02d", T.Days, T.Hours, T.Minutes, T.Seconds)
                    elseif T.Hours > 0 then
                        Claim_Title.Text = string.format("%02d:%02d:%02d", T.Hours, T.Minutes, T.Seconds)
                    else
                        Claim_Title.Text = string.format("%02d:%02d", T.Minutes, T.Seconds)
                    end
                end
            else
                Claim.Image = NON_CLAIMABLE_DAILY_REWARD_ID
                Claim_Title.Text = "Locked"
            end
        end)

        Hydrate_Button(Claim, function()
            if not Ratelimits.Claim_Daily_Reward() then
                return
            end

            Network.Requests.Claim_Daily_Reward.Fire(Index)
        end)
    end

    local function Update()
        for _, Func in Update_Funcs do
            Func()
        end
    end

    Scope:Observer(Fusion_Values.Last_Daily_Reward_Claim):onChange(Update)
    Scope:Observer(Fusion_Values.Claimed_Daily_Rewards):onChange(Update)

    Clock(1, Update)
end

local function Setup_Daily_Rewards(LocalEntity: Types.Entity, PlayerGui: PlayerGui)
    Setup_Daily_Rewards_Visibility(PlayerGui)

    Setup_Daily_Rewards_Content(PlayerGui)
end

local function Setup_Playtime_Rewards_Visibility(PlayerGui: PlayerGui)
    local Main = PlayerGui:WaitForChild("Main") :: ScreenGui
    local Frames = Main:WaitForChild("Frames") :: Frame

    local Playtime_Rewards_Frame = Frames:WaitForChild("PlaytimeRewards") :: ImageLabel

    Hydrate_Frame_Visibility(Playtime_Rewards_Frame, "PlaytimeRewards")

    Setup_Close_Button(Playtime_Rewards_Frame:WaitForChild("Close"))
end

local function Setup_Playtime_Rewards(LocalEntity: Types.Entity, PlayerGui: PlayerGui)
    Setup_Playtime_Rewards_Visibility(PlayerGui)
end

local function Setup_Sell_Visibility(PlayerGui: PlayerGui)
    local Main = PlayerGui:WaitForChild("Main") :: ScreenGui
    local Frames = Main:WaitForChild("Frames") :: Frame

    local Sell_Frame = Frames:WaitForChild("Sell") :: ImageLabel
    local Contents = Sell_Frame:WaitForChild("Contents") :: ScrollingFrame

    Hydrate_Frame_Visibility(Sell_Frame, "Sell", function()
        Contents.CanvasPosition = Vector2.zero
    end)

    Setup_Close_Button(Sell_Frame:WaitForChild("Close"))
end

local function Setup_Sell_Total_Value(PlayerGui: PlayerGui)
    local Main = PlayerGui:WaitForChild("Main") :: ScreenGui
    local Frames = Main:WaitForChild("Frames") :: Frame

    local Sell_Frame = Frames:WaitForChild("Sell") :: ImageLabel
    local Total_Value = Sell_Frame:WaitForChild("Total_Value") :: TextLabel

    Scope:Hydrate(Total_Value)({
        Text = Scope:Computed(function(Use)
            local Brainrot_Inventory = Use(Fusion_Values.Brainrot_Inventory)

            local Total_Value = 0

            for _, Brainrot_Item: Types.Brainrot_Item in Brainrot_Inventory do
                local Sell_Price = Stat_Calculator.Calculate_Sell_Price({
                    Brainrot_Name = Brainrot_Item.Name,
                    Primary_Mutation = Brainrot_Item.Primary_Mutation,
                    Secondary_Mutations = Brainrot_Item.Secondary_Mutations,
                    Weight = Brainrot_Item.Weight,
                })

                Total_Value += Sell_Price
            end

            return `Total Value: ${Util.Format_Number_With_Commas(Total_Value)}`
        end),
    })
end

local function Setup_Sell_All_Button(PlayerGui: PlayerGui)
    local Main = PlayerGui:WaitForChild("Main") :: ScreenGui
    local Frames = Main:WaitForChild("Frames") :: Frame

    local Sell_Frame = Frames:WaitForChild("Sell") :: ImageLabel
    local Sell_All = Sell_Frame:WaitForChild("Sell_All") :: ImageLabel

    Hydrate_Button(Sell_All, function()
        if not Ratelimits.Sell_All() then
            return
        end

        Network.Requests.Sell_All.Fire()
    end)
end

local function Setup_Sell_Contents(PlayerGui: PlayerGui)
    local Main = PlayerGui:WaitForChild("Main") :: ScreenGui
    local Frames = Main:WaitForChild("Frames") :: Frame

    local Sell_Frame = Frames:WaitForChild("Sell") :: ImageLabel
    local Contents = Sell_Frame:WaitForChild("Contents") :: ScrollingFrame

    local Template = Contents:WaitForChild("Template") :: ImageButton
    Template.Visible = false

    Scope:Hydrate(Contents)({
        [Children] = Scope:Computed(function(Use: Fusion.Use, Processor: Fusion.Scope<Fusion.Fusion>)
            local Brainrot_Inventory = Use(Fusion_Values.Brainrot_Inventory)
            local Groups = Make_Sell_Group(Brainrot_Inventory)

            local Children = {}

            for _, Data in Groups do
                local Brainrot_Data = Brainrots[Data.Name]

                local ImageButton = Template:Clone()
                ImageButton.Visible = true
                ImageButton.LayoutOrder = -Data.Total_Value
                ImageButton.ZIndex = -Data.Total_Value

                table.insert(Processor, ImageButton)

                local Title_Text

                if Data.Primary_Mutation then
                    Title_Text = `{Data.Primary_Mutation} {Data.Name}`
                else
                    Title_Text = Data.Name
                end

                local Title = ImageButton:FindFirstChild("Title") :: TextLabel
                Title.Text = Title_Text

                if Data.Primary_Mutation then
                    local UIGradient = UIGradients:FindFirstChild(Data.Primary_Mutation)

                    if UIGradient then
                        UIGradient:Clone().Parent = Title
                    end
                end

                local Rarity = ImageButton:FindFirstChild("Rarity")
                Rarity.Text = Brainrot_Data.Rarity

                local UIGradient = UIGradients:FindFirstChild(Brainrot_Data.Rarity)

                if UIGradient then
                    UIGradient:Clone().Parent = ImageButton
                end

                local Total_Value = ImageButton:FindFirstChild("Total_Value") :: TextLabel
                Total_Value.Text = `${Util.Format_Number_With_Commas(Data.Total_Value)}`

                local Owned = ImageButton:FindFirstChild("Owned") :: TextLabel
                Owned.Text = `Owned: {Data.Count}`

                local Secondary_Mutations_Frame = ImageButton:FindFirstChild("Secondary_Mutations") :: Frame
                local Secondary_Mutations_Template = Secondary_Mutations_Frame:FindFirstChild("Template") :: ImageLabel
                Secondary_Mutations_Template.Visible = false

                for _, Mutation_Name in Data.Secondary_Mutations do
                    local Clone = Secondary_Mutations_Template:Clone()
                    Clone.Name = Mutation_Name
                    Clone.Image = Secondary_Mutations_Config[Mutation_Name].Image
                    Clone.Visible = true
                    Clone.Parent = Secondary_Mutations_Frame
                end

                local Sell = ImageButton:FindFirstChild("Sell") :: ImageButton

                Hydrate_Button(Sell, function()
                    if not Ratelimits.Sell_Brainrot_Item_Group() then
                        return
                    end

                    Network.Requests.Sell_Brainrot_Item_Group.Fire({
                        Name = Data.Name,
                        Primary_Mutation = Data.Primary_Mutation,
                        Secondary_Mutations = Data.Secondary_Mutations,
                    })
                end)

                table.insert(Children, ImageButton)
            end

            return Children
        end),
    })
end

local function Setup_Sell(LocalEntity: Types.Entity, PlayerGui: PlayerGui)
    Setup_Sell_Visibility(PlayerGui)

    Setup_Sell_Total_Value(PlayerGui)

    Setup_Sell_All_Button(PlayerGui)

    Setup_Sell_Contents(PlayerGui)
end

local function Setup_Free_Reward(PlayerGui: PlayerGui)
    local Main = PlayerGui:WaitForChild("Main") :: ScreenGui
    local Frames = Main:WaitForChild("Frames") :: Frame

    local FreeReward = Frames:WaitForChild("FreeReward") :: ImageLabel
    local Claim = FreeReward:WaitForChild("Claim") :: ImageButton

    Hydrate_Frame_Visibility(FreeReward, "FreeReward")

    Setup_Close_Button(FreeReward:WaitForChild("Close"))

    Hydrate_Button(Claim, function()
        Network.Requests.Claim_Group_Reward.Fire()
    end)

    Scope:Observer(Fusion_Values.Group_Reward_Claimed):onBind(function()
        if Peek(Fusion_Values.Group_Reward_Claimed) == true and Peek(Fusion_Values.Screen) == "FreeReward" then
            Fusion_Values.Screen:set("HUD")
        end
    end)
end

local function Setup_Topbar_Daily_Rewards()
    local Icon = TopbarPlus.new()
        :setImage("rbxassetid://122975945860743")
        :setImageScale(0.8)
        :oneClick(true)
        :align("Right")
        :setCaption("Daily Rewards")
        :setOrder(0)
        :setTextFont("Montserrat", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
        :autoDeselect(false)

    if Peek(DeviceType) ~= "Mobile" then
        Icon:setLabel("Daily Rewards")

        Icon.viewingStarted:Connect(function()
            Hover:Play()
        end)
    end

    Icon.selected:Connect(function()
        Activate:Play()

        Toggle_Screen("DailyRewards")
    end)

    Scope:Observer(Tutorial_Completed_Computed):onBind(function()
        if Peek(Tutorial_Completed_Computed) == true then
            Icon:setEnabled(true)
        else
            Icon:setEnabled(false)
        end
    end)
end

local function Setup_Topbar_Toggle_Music()
    local Icon = TopbarPlus.new()
        :setImage("rbxassetid://134056990643242", "Selected")
        :setImage("rbxassetid://99028625406197", "Deselected")
        :setImageScale(0.8)
        :align("Right")
        :setCaption("Toggle Music")
        :setOrder(2)
        :setTextFont("Montserrat", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
        :autoDeselect(false)

    if Peek(DeviceType) ~= "Mobile" then
        Icon.viewingStarted:Connect(function()
            Hover:Play()
        end)
    end

    Icon.toggled:Connect(function(IsSelected)
        Activate:Play()

        if IsSelected then
            Music.Volume = 0
        else
            Music.Volume = 1
        end
    end)

    Scope:Observer(Tutorial_Completed_Computed):onBind(function()
        if Peek(Tutorial_Completed_Computed) == true then
            Icon:setEnabled(true)
        else
            Icon:setEnabled(false)
        end
    end)
end

local function Setup_Topbar_Invite_Friends(Local_Player: Player)
    local Icon = TopbarPlus.new()
        :setImage("75568998181349")
        :setImageScale(0.8)
        :oneClick(true)
        :align("Right")
        :setCaption("Invite Friends")
        :setOrder(1)
        :setTextFont("Montserrat", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
        :autoDeselect(false)

    if Peek(DeviceType) ~= "Mobile" then
        Icon.viewingStarted:Connect(function()
            Hover:Play()
        end)
    end

    Icon.toggled:Connect(function(IsSelected)
        Activate:Play()

        local Success, CanInvite = pcall(function()
            return SocialService:CanSendGameInviteAsync(Local_Player)
        end)

        if Success and CanInvite then
            SocialService:PromptGameInvite(Local_Player)
        end
    end)

    Scope:Observer(Tutorial_Completed_Computed):onBind(function()
        if Peek(Tutorial_Completed_Computed) == true then
            Icon:setEnabled(true)
        else
            Icon:setEnabled(false)
        end
    end)
end

local function Setup_Topbar(LocalEntity: Types.Entity)
    local Local_Player = World:get(LocalEntity, Components.Player)

    TopbarPlus.modifyBaseTheme(require(script.Icon_Themes.Default))

    Setup_Topbar_Daily_Rewards()

    Setup_Topbar_Toggle_Music()

    Setup_Topbar_Invite_Friends(Local_Player)
end

local function Setup_Stroke_Fixer(PlayerGui: PlayerGui)
    local Reference_Height = 1080

    local function Update_Non_Native_Scaling()
        local ScreenSize = Camera.ViewportSize
        local ScaleFactorY = ScreenSize.Y / Reference_Height

        for _, Descendant in PlayerGui:GetDescendants() do
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
            Setup_Daily_Rewards(Local_Entity, PlayerGui)
            Setup_Playtime_Rewards(Local_Entity, PlayerGui)
            Setup_Sell(Local_Entity, PlayerGui)
            Setup_Free_Reward(PlayerGui)

            Setup_Topbar(Local_Entity)

            Setup_Stroke_Fixer(PlayerGui)

            Scope:Observer(Fusion_Values.Screen):onBind(function()
                if Peek(Fusion_Values.Screen) == "HUD" then
                    TweenFov(0.15, 70)
                    Remove_Blur()
                    Satchel:SetBackpackEnabled(true)
                else
                    Frame_Open:Play()

                    TweenFov(0.15, 50)
                    Add_Blur(30)
                    Satchel:SetBackpackEnabled(false)
                end
            end)

            Log.Info("UI has been setup")
        end)
    end,
    runConditions = {},
}
