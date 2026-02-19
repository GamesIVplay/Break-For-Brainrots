local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Network = require(ServerScriptService.Network)

local Slot_Util = require(ServerScriptService.Server.Modules.Slot_Util)

local Jecs = require(ReplicatedStorage.Packages.Jecs)
local Pair = Jecs.pair

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local Types = require(ReplicatedStorage.Common.Types)
local World = require(ReplicatedStorage.Common.World)

local Brainrot_Capacity = require(ReplicatedStorage.Common.Modules.Brainrot_Capacity)
local Ratelimits = require(ReplicatedStorage.Common.Modules.Ratelimits)
local Tutorial_Steps = require(ReplicatedStorage.Common.Modules.Tutorial_Steps)

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

        local Tutorial_Step = World:get(Player_Entity, Components.Tutorial_Step)

        if not Tutorial_Step then
            continue
        end

        if Tutorial_Step < #Tutorial_Steps then
            Network.Notification.Fire(Player, { Text = "Complete the tutorial first", Type = "Error" })

            continue
        end

        if not World:has(Player_Entity, Pair(Components.Relationships.Brainrot, Brainrot_Entity)) then
            continue
        end

        local Brainrot_Inventory = World:get(Player_Entity, Components.Brainrot_Inventory)

        local Open_Slot = Slot_Util.Get_First_Open(Brainrot_Inventory, Brainrot_Capacity)

        if not Open_Slot then
            Network.Notification.Fire(
                Player,
                { Text = `Your inventory is full ({Brainrot_Capacity}/{Brainrot_Capacity})`, Type = "Error" }
            )
            continue
        end

        local Brainrot_Name = World:get(Brainrot_Entity, Components.Name)
        local Primary_Mutation = World:get(Brainrot_Entity, Components.Primary_Mutation)
        local Secondary_Mutations = World:get(Brainrot_Entity, Components.Secondary_Mutations)
        local Weight = World:get(Brainrot_Entity, Components.Weight)
        local Cash = World:get(Brainrot_Entity, Components.Cash)
        local Offline_Cash = World:get(Brainrot_Entity, Components.Offline_Cash)

        local Brainrot_Item: Types.Brainrot_Item = {
            Name = Brainrot_Name,
            Primary_Mutation = Primary_Mutation,
            Secondary_Mutations = Secondary_Mutations,
            Weight = Weight,
            Cash = Cash,
            Offline_Cash = Offline_Cash,
        }

        Brainrot_Inventory[Open_Slot] = Brainrot_Item

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
