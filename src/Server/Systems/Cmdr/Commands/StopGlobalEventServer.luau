local MessagingService = game:GetService("MessagingService")

return function(_context, eventName: string)
    MessagingService:PublishAsync("Stop_Global_Event", {
        Name = eventName,
    })
end
