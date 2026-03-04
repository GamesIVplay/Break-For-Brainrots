local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Network = require(ServerScriptService.Network)

local Components = require(ReplicatedStorage.Common.Components)
local Registry = require(ReplicatedStorage.Common.Registry)
local World = require(ReplicatedStorage.Common.World)

local Slot_Util = require(ServerScriptService.Server.Modules.Slot_Util)

local Stat_Calculator = require(ReplicatedStorage.Common.Modules.Stat_Calculator)

local Brainrot_Capacity = Stat_Calculator.Get_Brainrot_Capacity()

return function(context, brainrotName: string, player: Player)
    local Executor = context.Executor :: Player

    local Player_Entity = Registry.Get("Players", player)

    if not Player_Entity then
        return
    end

    local Brainrot_Inventory = World:get(Player_Entity, Components.Brainrot_Inventory)

    if not Brainrot_Inventory then
        return
    end

    local Open_Slot = Slot_Util.Get_First_Open(Brainrot_Inventory, Brainrot_Capacity)

    if not Open_Slot then
        Network.Notification.Fire(Executor, {
            Text = `This players inventory is full ({Brainrot_Capacity}/{Brainrot_Capacity})`,
            Type = "Error",
        })
        return
    end

    Brainrot_Inventory[Open_Slot] = {
        Name = brainrotName,
        Primary_Mutation = nil,
        Secondary_Mutations = {},
        Weight = 10,
        Cash = 0,
        Offline_Cash = 0,
    }

    Network.Notification.Fire(player, {
        Text = `{Executor.Name} gave you a {brainrotName}`,
        Type = "Info",
        Duration = 5,
    })
end
