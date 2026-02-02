local CollectionService = game:GetService("CollectionService")
local MarketPlaceService = game:GetService("MarketplaceService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Map = workspace:WaitForChild("Map") :: Folder
local Shops = Map:WaitForChild("Shops") :: Folder

local Assets = ReplicatedStorage:WaitForChild("Assets")

local Zone = require(Assets:WaitForChild("Modules"):WaitForChild("Zone")) :: any

local Billboards = Assets:WaitForChild("Billboards")
local Home_Billboard = Billboards:WaitForChild("Home") :: BillboardGui

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

local Fusion_Values = require(ReplicatedFirst.Client.Modules.Fusion_Values)

--[[
Zone Usage Example
	
local function Setup_Zone(Part: Part, Screen: string)
    local New_Zone = Zone.fromParts({ Part })
    New_Zone:BindToHeartbeat()

    New_Zone:ListenTo("Player", "Entered", function(_Target_Player: Player)
   		
    end)

    New_Zone:ListenTo("Player", "Exited", function(_Target_Player: Player)
      
    end)
end

]]

local function On_Plot_Assigned(Local_Entity: Types.Entity, Plot_Model: Model)
    World:set(Local_Entity, Components.Plot_Model, Plot_Model)

    Home_Billboard:Clone().Parent = Plot_Model

    local Break_Screen, Skip_Screen =
        Plot_Model:WaitForChild("Break"):WaitForChild("Screen") :: Part,
        Plot_Model:WaitForChild("Skip"):WaitForChild("Screen") :: Part

    Proximity(Break_Screen, {
        ActionText = "Break Block",
    }, function() end)

    Proximity(Skip_Screen, {
        ActionText = "Skip Block",
    }, function() end)
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

        local Mesh = Inst:FindFirstChildOfClass("MeshPart") :: MeshPart

        if not Mesh then
            continue
        end

        local Attachment = Mesh:FindFirstChildOfClass("Attachment")

        if not Attachment then
            continue
        end

        Proximity(Attachment, { ActionText = "Purchase" }, function()
            MarketPlaceService:PromptProductPurchase(Local_Player, Developer_Products["Gold Ballerina Cappuccina"])
        end)
    end
end

local function Setup_Diamond_Bananita_Dolphinita(Local_Player: Player)
    for _, Inst in CollectionService:GetTagged("Diamond Bananita Dolphinita") do
        if not Inst:IsA("Model") then
            continue
        end

        local Mesh = Inst:FindFirstChildOfClass("MeshPart") :: MeshPart

        if not Mesh then
            continue
        end

        local Attachment = Mesh:FindFirstChildOfClass("Attachment")

        if not Attachment then
            continue
        end

        Proximity(Attachment, { ActionText = "Purchase" }, function()
            MarketPlaceService:PromptProductPurchase(Local_Player, Developer_Products["Diamond Bananita Dolphinita"])
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
