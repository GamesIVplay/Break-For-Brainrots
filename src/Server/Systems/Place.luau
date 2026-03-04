local MarketPlaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Network = require(ServerScriptService.Network)

local New_Brainrot_Entity = require(ServerScriptService.Server.Modules.New_Brainrot_Entity)
local Slot_Util = require(ServerScriptService.Server.Modules.Slot_Util)

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local Types = require(ReplicatedStorage.Common.Types)
local World = require(ReplicatedStorage.Common.World)

local Gamepass_Config = require(ReplicatedStorage.Common.Modules.Gamepasses)
local Ratelimits = require(ReplicatedStorage.Common.Modules.Ratelimits)

local function Handle_Place_Requests()
    for _, Player: Player, Stand_Model: Model in Network.Requests.Place.Iter() do
        if not Ratelimits.Place(Player) then
            continue
        end

        local Player_Entity = Registry.Get("Players", Player)

        if not Player_Entity then
            continue
        end

        local Plot_Entity = World:target(Player_Entity, Components.Relationships.Plot)

        if not Plot_Entity then
            continue
        end

        local Plot_Model = World:get(Plot_Entity, Components.Renderable) :: Model

        local Stands = Plot_Model:FindFirstChild("Stands")

        if Stand_Model.Parent ~= Stands or Stand_Model:HasTag("Occupied") then
            continue
        end

        local Brainrot_Inventory = World:get(Player_Entity, Components.Brainrot_Inventory)

        if not Brainrot_Inventory then
            continue
        end

        local Character = World:get(Player_Entity, Components.Renderable) :: Model?

        if not Character then
            continue
        end

        local Gamepasses = World:get(Player_Entity, Components.Gamepasses)

        if not Gamepasses then
            continue
        end

        local Tool: Tool?

        for _, Inst: Instance in Character:GetChildren() do
            if Inst:IsA("Tool") and Inst:HasTag("Brainrot") then
                Tool = Inst
                break
            end
        end

        if not Tool then
            Network.Notification.Fire(Player, {
                Text = "You must hold a brainrot",
                Type = "Error",
            })
            continue
        end

        local Stand_Number = tonumber(Stand_Model.Name)

        if (Stand_Number == 5 or Stand_Number == 10) and not table.find(Gamepasses, "+2 Slots") then
            MarketPlaceService:PromptGamePassPurchase(Player, Gamepass_Config["+2 Slots"])
            continue
        end

        Stand_Model:AddTag("Occupied")

        local Index = Tool:GetAttribute("Index")
        local Brainrot_Item: Types.Brainrot_Item = Brainrot_Inventory[Index]

        New_Brainrot_Entity(
            Player_Entity,
            Stand_Model,
            Brainrot_Item.Level,
            Brainrot_Item.Experience,
            Brainrot_Item.Name,
            Brainrot_Item.Primary_Mutation,
            Brainrot_Item.Secondary_Mutations,
            Brainrot_Item.Weight,
            Brainrot_Item.Cash,
            Brainrot_Item.Offline_Cash
        )

        Slot_Util.Clear_Slot(Brainrot_Inventory, Index)

        Network.Notification.Fire(Player, {
            Text = "Brainrot was placed",
            Type = "Success",
        })
    end
end

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = Handle_Place_Requests,
    runConditions = {},
}
