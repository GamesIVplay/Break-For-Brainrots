return {
    Name = "StartLocalEvent",
    Aliases = {},
    Description = "Starts a Local Event.",
    Group = "Developer",
    Args = {
        {
            Type = "event",
            Name = "Event",
            Description = "The event to start",
        },
        {
            Type = "number",
            Name = "Luck Multiplier",
            Description = "The luck multiplier of the event",
        },
        {
            Type = "number",
            Name = "Duration",
            Description = "The duration of the event",
        },
    },
}
