local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Network = require(ServerScriptService.Network)

local Slot_Util = require(ServerScriptService.Server.Modules.Slot_Util)

local Components = require(ReplicatedStorage.Common.Components)
local Config = require(ReplicatedStorage.Common.Config)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local Types = require(ReplicatedStorage.Common.Types)
local World = require(ReplicatedStorage.Common.World)

local Ratelimits = require(ReplicatedStorage.Common.Modules.Ratelimits)
local Stat_Calculator = require(ReplicatedStorage.Common.Modules.Stat_Calculator)

local function Handle_Start_Requests()
    for _, Player: Player, Index: number in Network.Requests.Start_Fusion.Iter() do
        if not Ratelimits.Fusion_Start(Player) then
            continue
        end

        local Player_Entity = Registry.Get("Players", Player)

        if not Player_Entity then
            continue
        end

        if World:has(Player_Entity, Components.Next_Fusion_Time) then
            continue
        end

        local Fusion_Machine = World:get(Player_Entity, Components.Fusion_Machine)

        if not Fusion_Machine then
            continue
        end

        local Brainrot_Names = {}

        for _, Data in Fusion_Machine do
            table.insert(Brainrot_Names, Data.Name)
        end

        if #Brainrot_Names ~= 4 then
            continue
        end

        World:set(Player_Entity, Components.Next_Fusion_Time, os.time() + Config.FUSE_TIME)
    end
end

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = Handle_Start_Requests,
    runConditions = {},
}
