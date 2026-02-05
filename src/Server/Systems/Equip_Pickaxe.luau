local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Network = require(ServerScriptService.Network)

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local World = require(ReplicatedStorage.Common.World)

local function Handle_Pickaxe_Equip_Requests()
    for _, Player: Player, Pickaxe_Name: string in Network.Requests.Equip_Pickaxe.Iter() do
        local Player_Entity = Registry.Get("Players", Player)

        if not Player_Entity then
            continue
        end

        local Owned_Pickaxes = World:get(Player_Entity, Components.Owned_Pickaxes)

        if not table.find(Owned_Pickaxes, Pickaxe_Name) then
            -- Notif
            continue
        end

        World:set(Player_Entity, Components.Pickaxe, Pickaxe_Name)

        -- Send Notif
    end
end

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = Handle_Pickaxe_Equip_Requests,
    runConditions = {},
}
