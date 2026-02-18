local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Ratelimit = require(ReplicatedStorage.Packages.Ratelimit)

local Can_Run = Ratelimit(1, 1)

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Types = require(ReplicatedStorage.Common.Types)
local World = require(ReplicatedStorage.Common.World)

local PlayTime_Query = World:query(Components.PlayTime):with(Components.Player):cached()

return {
    name = script.Name,
    phase = Phases.Runservice.PostUpdate,
    system = function()
        for Player_Entity: Types.Entity, PlayTime: number in PlayTime_Query:iter() do
            World:set(Player_Entity, Components.PlayTime, PlayTime + 1)
        end
    end,
    runConditions = {
        Can_Run,
    },
}
