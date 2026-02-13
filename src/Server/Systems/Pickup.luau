local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Network = require(ServerScriptService.Network)

local Jecs = require(ReplicatedStorage.Packages.Jecs)
local Pair = Jecs.pair

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local Types = require(ReplicatedStorage.Common.Types)
local World = require(ReplicatedStorage.Common.World)

local Brainrot_Capacity = require(ReplicatedStorage.Common.Modules.Brainrot_Capacity)
local Ratelimits = require(ReplicatedStorage.Common.Modules.Ratelimits)

local function Handle_Pickup_Requests()
    for _, Player: Player, Brainrot_Entity: Types.Entity in Network.Requests.Pickup.Iter() do
        if not Ratelimits.Pickup(Player) then
            continue
        end

        if not World:contains(Brainrot_Entity) or not World:has(Brainrot_Entity, Components.Tags.Brainrot) then
            continue
        end

        local Player_Entity = Registry.Get("Players", Player)

        if not Player_Entity then
            continue
        end

        if not World:has(Player_Entity, Pair(Components.Relationships.Brainrot, Brainrot_Entity)) then
            continue
        end

        local Brainrot_Inventory = World:get(Player_Entity, Components.Brainrot_Inventory)

        local Brainrot_Inventory_Size = 0

        for _ in pairs(Brainrot_Inventory) do
            Brainrot_Inventory_Size += 1
        end

        if Brainrot_Inventory_Size > Brainrot_Capacity then
            Network.Notification.Fire(
                Player,
                { Text = `Your inventory is full ({Brainrot_Inventory_Size}/{Brainrot_Capacity})`, Type = "Error" }
            )
            continue
        end

        local Brainrot_Name = World:get(Brainrot_Entity, Components.Name)
        local Primary_Mutation = World:get(Brainrot_Entity, Components.Primary_Mutation)
        local Secondary_Mutations = World:get(Brainrot_Entity, Components.Secondary_Mutations)
        local Weight = World:get(Brainrot_Entity, Components.Weight)

        local Brainrot_Item: Types.Brainrot_Item = {
            Name = Brainrot_Name,
            Primary_Mutation = Primary_Mutation,
            Secondary_Mutations = Secondary_Mutations,
            Weight = Weight,
        }

        for Index = 1, Brainrot_Inventory_Size + 1 do
            if Brainrot_Inventory[Index] == nil then
                Brainrot_Inventory[Index] = Brainrot_Item
                break
            end
        end

        World:delete(Brainrot_Entity)

        Network.Notification.Fire(Player, {
            Text = "Picked up brainrot",
            Type = "Success",
        })
    end
end

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = Handle_Pickup_Requests,
    runConditions = {},
}
