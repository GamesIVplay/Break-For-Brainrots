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

local Ratelimits = require(ReplicatedStorage.Common.Modules.Ratelimits)

local function Handle_Collect_Requests()
    for _, Player: Player, ServerEntity: Types.Entity in Network.Requests.Collect.Iter() do
        if not World:contains(ServerEntity) or not World:has(ServerEntity, Components.Tags.Brainrot) then
            continue
        end

        if not Ratelimits.Collect(ServerEntity) then
            continue
        end

        local Player_Entity = Registry.Get("Players", Player)

        if not Player_Entity then
            continue
        end

        if not World:has(ServerEntity, Pair(Components.Relationships.Owner, Player_Entity)) then
            continue
        end

        local Player_Cash = World:get(Player_Entity, Components.Cash)

        if not Player_Cash then
            continue
        end

        local Tutorial_Step = World:get(Player_Entity, Components.Tutorial_Step)

        if not Tutorial_Step then
            continue
        end

        local Brainrot_Model = World:get(ServerEntity, Components.Renderable)
        local Brainrot_Cash = World:get(ServerEntity, Components.Cash)
        local Brainrot_Offline_Cash = World:get(ServerEntity, Components.Offline_Cash)

        if not Brainrot_Model or not Brainrot_Cash or not Brainrot_Offline_Cash then
            continue
        end

        if Tutorial_Step == 3 then
            World:set(Player_Entity, Components.Tutorial_Step, 4)
            World:set(
                Player_Entity,
                Components.Cash,
                math.max(500, Player_Cash + Brainrot_Cash + Brainrot_Offline_Cash)
            )
        else
            World:set(Player_Entity, Components.Cash, Player_Cash + Brainrot_Cash + Brainrot_Offline_Cash)
        end

        World:set(ServerEntity, Components.Cash, 0)
        World:set(ServerEntity, Components.Offline_Cash, 0)

        Network.VFX.Bounce_Brainrot.FireAll(Brainrot_Model)
    end
end

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = Handle_Collect_Requests,
    runConditions = {},
}
