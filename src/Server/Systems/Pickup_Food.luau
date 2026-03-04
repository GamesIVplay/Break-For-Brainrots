local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Network = require(ServerScriptService.Network)

local Slot_Util = require(ServerScriptService.Server.Modules.Slot_Util)

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local World = require(ReplicatedStorage.Common.World)

local Ratelimits = require(ReplicatedStorage.Common.Modules.Ratelimits)
local Stat_Calculator = require(ReplicatedStorage.Common.Modules.Stat_Calculator)

local Food_Capacity = Stat_Calculator.Get_Food_Capacity()

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = function()
        for _, Player: Player in Network.Requests.Pickup_Food.Iter() do
            if not Ratelimits.Pickup_Food(Player) then
                continue
            end

            local Player_Entity = Registry.Get("Players", Player)

            if not Player_Entity then
                continue
            end

            local Food_Inventory = World:get(Player_Entity, Components.Food_Inventory)

            if not Food_Inventory then
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

            local Food_Name = World:get(Food_Entity, Components.Name)

            local Experience = World:get(Food_Entity, Components.Experience)

            if not Experience then
                continue
            end

            if Experience == 0 then
                Network.Notification.Fire(Player, {
                    Text = "Pump the food first",
                    Type = "Error",
                })
                continue
            end

            local Open_Slot = Slot_Util.Get_First_Open(Food_Inventory, Food_Capacity)

            if not Open_Slot then
                Network.Notification.Fire(Player, {
                    Text = `Your food inventory is full ({Food_Capacity}/{Food_Capacity})`,
                    Type = "Error",
                })
                continue
            end

            Food_Inventory[Open_Slot] = {
                Name = Food_Name,
                Xp = Experience,
            }

            World:delete(Food_Entity)

            Network.Notification.Fire(Player, {
                Text = "Food picked up",
                Type = "Success",
            })
        end
    end,
    runConditions = {},
}
