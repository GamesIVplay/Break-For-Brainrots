local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Network = require(ServerScriptService.Network)

local Components = require(ReplicatedStorage.Common.Components)
local World = require(ReplicatedStorage.Common.World)

return function(context, eventName: string, luck_multiplier: number, duration: number)
    local Executor = context.Executor :: Player

    local Active_Events = World:get(Components.Singletons.Active_Events, Components.Singletons.Active_Events)

    Active_Events[eventName] = {
        Start_Time = os.time(),
        End_Time = os.time() + duration,
        Luck_Multiplier = luck_multiplier,
    }

    Network.Notification.FireAll({
        Text = `{Executor.Name} started a {eventName} Event!`,
        Type = "Info",
        Duration = 5,
    })
end
