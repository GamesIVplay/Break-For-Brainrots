local MessagingService = game:GetService("MessagingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = require(ReplicatedStorage.Common.Types)

return function(context, message)
    local Executor = context.Executor :: Player

    MessagingService:PublishAsync(
        "Announcement",
        {
            Executor = Executor.Name,
            Message = message,
        } :: Types.Start_Global_Event_Data
    )
end
