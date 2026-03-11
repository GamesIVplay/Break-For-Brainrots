return {
    Name = "StartGlobalEvent",
    Aliases = {},
    Description = "Starts a Global Event.",
    Group = "Developer",
    Args = {
        {
            Type = "event",
            Name = "Event",
            Description = "The event to start",
        },
        {
            Type = "number",
            Name = "LuckBonus",
            Description = "The bonus luck of the event",
        },
        {
            Type = "number",
            Name = "Duration",
            Description = "The duration of the event",
        },
    },
}
