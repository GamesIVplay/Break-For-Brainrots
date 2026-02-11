local CollectionService = game:GetService("CollectionService")
local MarketPlaceService = game:GetService("MarketplaceService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Map = workspace:WaitForChild("Map") :: Folder
local Shops = Map:WaitForChild("Shops") :: Folder

local Assets = ReplicatedStorage:WaitForChild("Assets")

local UIGradients = Assets:WaitForChild("UIGradients") :: Folder

local Zone = require(Assets:WaitForChild("Modules"):WaitForChild("Zone")) :: any

local Billboards = Assets:WaitForChild("Billboards")
local Home_Billboard = Billboards:WaitForChild("Home") :: BillboardGui

local VFX = ReplicatedStorage.Common.Modules.VFX

local Network = require(ReplicatedFirst.Network)

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Peek = Fusion.peek

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local Types = require(ReplicatedStorage.Common.Types)
local World = require(ReplicatedStorage.Common.World)

local Developer_Products = require(ReplicatedStorage.Common.Modules.Developer_Products)
local Gamepasses = require(ReplicatedStorage.Common.Modules.Gamepasses)
local Proximity = require(ReplicatedStorage.Common.Modules.Proximity)
local Ratelimits = require(ReplicatedStorage.Common.Modules.Ratelimits)
local Unicode_Characters = require(ReplicatedStorage.Common.Modules.Unicode_Characters)
local Util = require(ReplicatedStorage.Common.Modules.Util)

local Fusion_Values = require(ReplicatedFirst.Client.Modules.Fusion_Values)

local TOUCH_PART_BOUNCE_TIME = 0.08
local TOUCH_PART_TWEEN_INFO = TweenInfo.new(TOUCH_PART_BOUNCE_TIME, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

local function On_Plot_Assigned(Local_Entity: Types.Entity, Plot_Model: Model)
    local Local_Player = World:get(Local_Entity, Components.Player)

    World:set(Local_Entity, Components.Plot_Model, Plot_Model)

    Home_Billboard:Clone().Parent = Plot_Model

    local Break_Screen, Skip_Screen =
        Plot_Model:WaitForChild("Break"):WaitForChild("Screen") :: Part,
        Plot_Model:WaitForChild("Skip"):WaitForChild("Screen") :: Part

    Proximity(Break_Screen, {
        ActionText = "Break Block",
        MaxActivationDistance = 4.5,
    }, function()
        MarketPlaceService:PromptProductPurchase(Local_Player, Developer_Products["Break Block"])
    end)

    Proximity(Skip_Screen, {
        ActionText = "Skip Block",
        MaxActivationDistance = 4.5,
    }, function()
        Network.Requests.Skip_Block.Fire()
    end)

    local Stands = Plot_Model:FindFirstChild("Stands")

    for _, Stand_Model in Stands:GetChildren() do
        local Touch = Stand_Model:FindFirstChild("Touch") :: Part
        local Brainrot_Spawn_Attachment = Stand_Model:FindFirstChild("Brainrot_Spawn", true) :: Attachment

        local Tween_Up = TweenService:Create(Touch, TOUCH_PART_TWEEN_INFO, {
            Position = Touch.Position,
        })

        local Tween_Down = TweenService:Create(Touch, TOUCH_PART_TWEEN_INFO, {
            Position = Touch.Position - Vector3.new(0, 0.35, 0),
        })

        local Place_Prompt = Proximity(
            Brainrot_Spawn_Attachment,
            { ActionText = "Place", MaxActivationDistance = 6 },
            function()
                -- Fire to pickup / place
            end
        )

        local function Update_Prompt_Text()
            if Stand_Model:GetAttribute("ServerEntity") then
                Place_Prompt.ActionText = "Pickup Brainrot"
            else
                Place_Prompt.ActionText = "Place Brainrot"
            end
        end

        Stand_Model:GetAttributeChangedSignal("ServerEntity"):Connect(Update_Prompt_Text)

        Update_Prompt_Text()

        local Collect_Zone = Zone.fromParts({ Touch })
        Collect_Zone:BindToHeartbeat()

        Collect_Zone:ListenTo("Player", "Entered", function(Target_Player: Player)
            if Target_Player ~= Local_Player then
                return
            end

            if not Ratelimits.Collect(Stand_Model) then
                return
            end

            local ServerEntity = Stand_Model:GetAttribute("ServerEntity")

            if ServerEntity then
                Network.Requests.Collect.Fire(ServerEntity)

                task.spawn(require(VFX.Collect), Touch)
            end

            Tween_Down:Play()

            task.wait(0.8)

            Tween_Up:Play()
        end)
    end
end

local function Setup_Shops(Local_Player: Player)
    for _, Inst: Instance in Shops:GetChildren() do
        if not Inst:IsA("Model") then
            continue
        end

        local Touch = Inst:WaitForChild("Touch") :: Part

        local New_Zone = Zone.fromParts({ Touch })
        New_Zone:BindToHeartbeat()

        New_Zone:ListenTo("Player", "Entered", function(Target_Player: Player)
            if Target_Player ~= Local_Player then
                return
            end

            if Peek(Fusion_Values.Screen) == Inst.Name then
                return
            end

            Fusion_Values.Screen:set(Inst.Name)
        end)

        New_Zone:ListenTo("Player", "Exited", function(Target_Player: Player)
            if Target_Player ~= Local_Player then
                return
            end

            if Peek(Fusion_Values.Screen) == Inst.Name then
                Fusion_Values.Screen:set("HUD")
            end
        end)
    end
end

local function Setup_Free_Rewards()
    for _, Inst in CollectionService:GetTagged("FreeReward") do
        if not Inst:IsA("Model") then
            continue
        end

        local Prompt = Inst:FindFirstChild("Prompt") :: BasePart?

        if not Prompt then
            continue
        end

        Proximity(Prompt, { ActionText = "🎁 Free Reward 🎁" }, function() end)
    end
end

local function Setup_Gold_Ballerina_Cappuccina(Local_Player: Player)
    for _, Inst in CollectionService:GetTagged("Gold Ballerina Cappuccina") do
        if not Inst:IsA("Model") then
            continue
        end

        local Main = Inst:FindFirstChild("Main", true) :: Attachment
        local Rarity_Text_Label = Main:FindFirstChild("Rarity", true) :: TextLabel
        local Price_Text_Label = Main:FindFirstChild("Price", true) :: TextLabel

        Proximity(Main, { ActionText = "Purchase" }, function()
            MarketPlaceService:PromptProductPurchase(Local_Player, Developer_Products["Gold Ballerina Cappuccina"])
        end)

        UIGradients.Legendary:Clone().Parent = Rarity_Text_Label

        task.spawn(function()
            local Product_Info = Util.Get_Product_Info(Developer_Products["Gold Ballerina Cappuccina"])

            if Product_Info then
                Price_Text_Label.Text =
                    `{Unicode_Characters.Robux}{Util.Format_Number_With_Commas(Product_Info.PriceInRobux)}`
            else
                Price_Text_Label.Visible = false
            end
        end)
    end
end

local function Setup_Diamond_Bananita_Dolphinita(Local_Player: Player)
    for _, Inst in CollectionService:GetTagged("Diamond Bananita Dolphinita") do
        if not Inst:IsA("Model") then
            continue
        end

        local Main = Inst:FindFirstChild("Main", true) :: Attachment
        local Rarity_Text_Label = Main:FindFirstChild("Rarity", true) :: TextLabel
        local Price_Text_Label = Main:FindFirstChild("Price", true) :: TextLabel

        Proximity(Main, { ActionText = "Purchase" }, function()
            MarketPlaceService:PromptProductPurchase(Local_Player, Developer_Products["Diamond Bananita Dolphinita"])
        end)

        UIGradients.Epic:Clone().Parent = Rarity_Text_Label

        task.spawn(function()
            local Product_Info = Util.Get_Product_Info(Developer_Products["Diamond Bananita Dolphinita"])

            if Product_Info then
                Price_Text_Label.Text =
                    `{Unicode_Characters.Robux}{Util.Format_Number_With_Commas(Product_Info.PriceInRobux)}`
            else
                Price_Text_Label.Visible = false
            end
        end)
    end
end

local function Setup_x2_Cash_Parts(Local_Player: Player)
    for _, Inst in CollectionService:GetTagged("x2Cash") do
        if not Inst:IsA("Model") then
            continue
        end

        local Touch = Inst:FindFirstChild("Touch") :: Part

        if not Touch then
            continue
        end

        local New_Zone = Zone.fromParts({ Touch })
        New_Zone:BindToHeartbeat()

        New_Zone:ListenTo("Player", "Entered", function(Target_Player: Player)
            if Target_Player ~= Local_Player then
                return
            end

            MarketPlaceService:PromptGamePassPurchase(Local_Player, Gamepasses["x2 Cash"])
        end)
    end
end

local function Setup_x2_Luck_Parts(Local_Player: Player)
    for _, Inst in CollectionService:GetTagged("x2Luck") do
        if not Inst:IsA("Model") then
            continue
        end

        local Touch = Inst:FindFirstChild("Touch") :: Part

        if not Touch then
            continue
        end

        local New_Zone = Zone.fromParts({ Touch })
        New_Zone:BindToHeartbeat()

        New_Zone:ListenTo("Player", "Entered", function(Target_Player: Player)
            if Target_Player ~= Local_Player then
                return
            end

            MarketPlaceService:PromptGamePassPurchase(Local_Player, Gamepasses["x2 Luck"])
        end)
    end
end

return {
    name = script.Name,
    phase = Phases.InitPhases.Init,
    system = function()
        local Local_Entity = Registry.Get("Players", "Local")
        local Local_Player = World:get(Local_Entity, Components.Player)

        Network.DataChanged.Plot_Assigned.On(function(Plot_Model: Model)
            On_Plot_Assigned(Local_Entity, Plot_Model)
        end)

        Setup_Shops(Local_Player)

        Setup_Free_Rewards()

        Setup_Gold_Ballerina_Cappuccina(Local_Player)

        Setup_Diamond_Bananita_Dolphinita(Local_Player)

        Setup_x2_Cash_Parts(Local_Player)

        Setup_x2_Luck_Parts(Local_Player)
    end,
    runConditions = {},
}
