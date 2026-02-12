local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local World = require(ReplicatedStorage.Common.World)

local Jecs = require(ReplicatedStorage.Packages.Jecs)
local Pair = Jecs.pair

local Brainrot_Without_Owner =
    World:query(Components.Tags.Brainrot):without(Pair(Components.Relationships.Owner, Jecs.Wildcard)):cached()

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = function()
        for Brainrot_Entity in Brainrot_Without_Owner:iter() do
            World:delete(Brainrot_Entity)
        end
    end,
    runConditions = {},
}
