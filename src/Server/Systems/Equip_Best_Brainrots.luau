local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Network = require(ServerScriptService.Network)
local New_Brainrot_Entity = require(ServerScriptService.Server.Modules.New_Brainrot_Entity)
local Slot_Util = require(ServerScriptService.Server.Modules.Slot_Util)

local Jecs = require(ReplicatedStorage.Packages.Jecs)
local Pair = Jecs.pair

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local Types = require(ReplicatedStorage.Common.Types)
local World = require(ReplicatedStorage.Common.World)

local Calculate_Income_Per_Sec = require(ReplicatedStorage.Common.Modules.Calculate_Income_Per_Sec)
local Ratelimits = require(ReplicatedStorage.Common.Modules.Ratelimits)

local function Handle_Equip_Best_Brainrots_Requests()
    for _, Player: Player in Network.Requests.Equip_Best_Brainrots.Iter() do
        if not Ratelimits.Equip_Best_Brainrots(Player) then
            continue
        end

        local Player_Entity = Registry.Get("Players", Player)
        if not Player_Entity then
            continue
        end

        local Brainrot_Inventory = World:get(Player_Entity, Components.Brainrot_Inventory)
        if not Brainrot_Inventory then
            continue
        end

        for
            Brainrot_Entity,
            Brainrot_Name: string,
            Secondary_Mutations: { string },
            Weight: number,
            Cash: number,
            Offline_Cash: number
        in
            World:query(
                Components.Name,
                Components.Secondary_Mutations,
                Components.Weight,
                Components.Cash,
                Components.Offline_Cash
            ):with(Components.Tags.Brainrot, Pair(Components.Relationships.Owner, Player_Entity))
        do
            local Primary_Mutation = World:get(Brainrot_Entity, Components.Primary_Mutation)

            local Brainrot_Item: Types.Brainrot_Item = {
                Name = Brainrot_Name,
                Primary_Mutation = Primary_Mutation,
                Secondary_Mutations = Secondary_Mutations,
                Weight = Weight,
                Cash = Cash,
                Offline_Cash = Offline_Cash,
            }

            for Index = 1, Brainrot_Inventory_Size + 1 do
                if Brainrot_Inventory[Index] == nil then
                    Brainrot_Inventory[Index] = Brainrot_Item
                    break
                end
            end

            World:delete(Brainrot_Entity)
        end
    end
end

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = Handle_Equip_Best_Brainrots_Requests,
    runConditions = {},
}
