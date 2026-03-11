local MessagingService = game:GetService("MessagingService")

return function(context, eventName: string)
    MessagingService:PublishAsync("Stop_Global_Event", {
        Name = eventName,
    })
end
