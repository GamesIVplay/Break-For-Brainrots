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

local function Handle_Pickaxes_Changes(Local_Entity: Types.Entity)
    for _, Value in Network.DataChanged.Pickaxe.Iter() do
        World:set(Local_Entity, Components.Pickaxe, Value)

        Fusion_Values.Pickaxe:set(Value)
    end
end

local function Handle_Owned_Pickaxes_Changes(Local_Entity: Types.Entity)
    for _, Value in Network.DataChanged.Owned_Pickaxes.Iter() do
        World:set(Local_Entity, Components.Owned_Pickaxes, Value)

        Fusion_Values.Owned_Pickaxes:set(Value)
    end
end

local function Handle_Gamepass_Changes(Local_Entity: Types.Entity)
    for _, Value in Network.DataChanged.Gamepasses.Iter() do
        World:set(Local_Entity, Components.Gamepasses, Value)
    end
end

return {
    name = script.Name,
    phase = Phases.Runservice.First,
    system = function()
        local Local_Entity = Registry.Get("Players", "Local")

        Handle_Cash_Changes(Local_Entity)

        Handle_Pickaxes_Changes(Local_Entity)

        Handle_Owned_Pickaxes_Changes(Local_Entity)

        Handle_Gamepass_Changes(Local_Entity)
    end,
    runConditions = {},
}
