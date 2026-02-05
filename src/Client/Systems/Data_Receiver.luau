local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VFX = ReplicatedStorage.Common.Modules.VFX

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

local function Handle_Rebirth_Changes(Local_Entity: Types.Entity)
    for _, Value in Network.DataChanged.Rebirth.Iter() do
        World:set(Local_Entity, Components.Rebirth, Value)

        Fusion_Values.Rebirth:set(Value)
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

local function Handle_Opens_Changes(Local_Entity: Types.Entity)
    for _, Value in Network.DataChanged.Opens.Iter() do
        World:set(Local_Entity, Components.Opens, Value)

        Fusion_Values.Opens:set(Value)
    end
end

local function Handle_Gamepass_Changes(Local_Entity: Types.Entity)
    for _, Value in Network.DataChanged.Gamepasses.Iter() do
        World:set(Local_Entity, Components.Gamepasses, Value)

        Fusion_Values.Gamepasses:set(Value)
    end
end

local function Handle_Buy_VFX()
    for _, Model: Model in Network.VFX.Buy.Iter() do
        if not Model:IsDescendantOf(game.Workspace) then
            continue
        end

        require(VFX.Buy)(Model)
    end
end

return {
    name = script.Name,
    phase = Phases.Runservice.First,
    system = function()
        local Local_Entity = Registry.Get("Players", "Local")

        Handle_Cash_Changes(Local_Entity)

        Handle_Rebirth_Changes(Local_Entity)

        Handle_Pickaxes_Changes(Local_Entity)

        Handle_Owned_Pickaxes_Changes(Local_Entity)

        Handle_Opens_Changes(Local_Entity)

        Handle_Gamepass_Changes(Local_Entity)

        Handle_Buy_VFX()
    end,
    runConditions = {},
}
