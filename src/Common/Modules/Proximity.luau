type ProximityPromptOptions = {
    ActionText: string?,
    ObjectText: string?,
    HoldDuration: number?,
    RequiresLineOfSight: boolean?,
    MaxActivationDistance: number?,
    UIOffset: Vector2?,
    Args: any?,
    Once: boolean?,
}

type ProximityPromptCallback = (Player: Player, Args: any?) -> ()

return function(
    Target: BasePart | Attachment,
    Options: ProximityPromptOptions?,
    Callback: ProximityPromptCallback
): ProximityPrompt
    assert(Target and (Target:IsA("BasePart") or Target:IsA("Attachment")), "Target must be a BasePart or Attachment")
    assert(typeof(Callback) == "function", "Callback must be a function")

    Options = Options or {}

    local Prompt = Instance.new("ProximityPrompt")
    Prompt.ActionText = Options.ActionText or ""
    Prompt.ObjectText = Options.ObjectText or ""
    Prompt.HoldDuration = Options.HoldDuration or 0
    Prompt.RequiresLineOfSight = Options.RequiresLineOfSight or false
    Prompt.MaxActivationDistance = Options.MaxActivationDistance or 10
    Prompt.UIOffset = Options.UIOffset or Vector2.zero
    Prompt.Style = Enum.ProximityPromptStyle.Custom
    Prompt.Parent = Target

    local Connection
    Connection = Prompt.Triggered:Connect(function(Player: Player)
        if Options.Args ~= nil then
            Callback(Player, Options.Args)
        else
            Callback(Player)
        end

        if Options.Once then
            Connection:Disconnect()
        end
    end)

    return Prompt
end
