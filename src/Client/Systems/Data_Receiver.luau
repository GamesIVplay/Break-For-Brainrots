local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Network = require(ReplicatedFirst.Network)

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local World = require(ReplicatedStorage.Common.World)

local Types = require(ReplicatedStorage.Common.Types)

local Fusion_Values = require(ReplicatedFirst.Client.Modules.Fusion_Values)

local function Handle_Cash_Changes(Local_Entity: Types.Entity)
    for _, Value in Network.DataChanged.Cash.Iter() do
        World:set(Local_Entity, Components.Cash, Value)

        Fusion_Values.Cash:set(Value)
    end
end

return {
    name = script.Name,
    phase = Phases.Runservice.First,
    system = function()
        local Local_Entity = Registry.Get("Players", "Local")

        Handle_Cash_Changes(Local_Entity)
    end,
    runConditions = {},
}
