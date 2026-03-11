local MessagingService = game:GetService("MessagingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = require(ReplicatedStorage.Common.Types)

return function(context, eventName: string, luckBonus: number, duration: number)
    local Executor = context.Executor :: Player

    MessagingService:PublishAsync(
        "Start_Global_Event",
        {
            Executor = Executor.Name,
            Name = eventName,
            Duration = duration,
            Luck_Bonus = luckBonus,
        } :: Types.Start_Global_Event_Data
    )
end
