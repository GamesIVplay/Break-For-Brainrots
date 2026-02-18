local TextChatService = game:GetService("TextChatService")

TextChatService.OnIncomingMessage = function(Message: TextChatMessage)
    local Properties = Instance.new("TextChatMessageProperties")

    if Message.TextSource then
        local Player = game:GetService("Players"):GetPlayerByUserId(Message.TextSource.UserId)

        if Player.UserId == 3439160531 then
            Properties.PrefixText = "<font color='#00A6FF'>[Owner]</font> " .. Message.PrefixText
        end
    end

    return Properties
end
