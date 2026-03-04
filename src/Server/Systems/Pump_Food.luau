local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Network = require(ServerScriptService.Network)

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local World = require(ReplicatedStorage.Common.World)

local Food = require(ReplicatedStorage.Common.Modules.Food)
local Ratelimits = require(ReplicatedStorage.Common.Modules.Ratelimits)

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = function()
        for _, Player: Player in Network.Requests.Pump_Food.Iter() do
            if not Ratelimits.Pump_Food(Player) then
                continue
            end

            local Player_Entity = Registry.Get("Players", Player)

            if not Player_Entity then
                continue
            end

            local Plot_Entity = World:target(Player_Entity, Components.Relationships.Plot)

            if not Plot_Entity then
                continue
            end

            local Food_Entity = World:target(Plot_Entity, Components.Relationships.Food)

            if not Food_Entity then
                continue
            end

            local Experience = World:get(Food_Entity, Components.Experience)

            if not Experience then
                continue
            end

            local Food_Data = Food.Get_Data_From_Xp(Experience)

            if Food_Data.Is_Max then
                Network.Notification.Fire(Player, {
                    Text = "Can't pump anymore",
                    Type = "Error",
                })
                continue
            end

            World:set(Food_Entity, Components.Experience, Experience + 2)
        end
    end,
    runConditions = {},
}
