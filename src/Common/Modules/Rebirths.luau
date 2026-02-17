type Rebirth = {
    Requirement: number,
    Multiplier: number,
}

local Rebirths: { [number]: Rebirth } = {
    [0] = {
        Requirement = 0,
        Multiplier = 1.0,
    },
    [1] = {
        Requirement = 1_000_000,
        Multiplier = 1.25,
    },
    [2] = {
        Requirement = 5_000_000,
        Multiplier = 1.5,
    },
    [3] = {
        Requirement = 10_000_000,
        Multiplier = 1.75,
    },
    [4] = {
        Requirement = 20_000_000,
        Multiplier = 2.0,
    },
}

return table.freeze(Rebirths)
