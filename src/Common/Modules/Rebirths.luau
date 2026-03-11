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
        Requirement = 10_000,
        Multiplier = 1.25,
    },

    [2] = {
        Requirement = 30_000,
        Multiplier = 1.5,
    },

    [3] = {
        Requirement = 55_000,
        Multiplier = 1.75,
    },

    [4] = {
        Requirement = 75_000,
        Multiplier = 2.0,
    },
    [5] = {
        Requirement = 115_000,
        Multiplier = 2.25,
    },
}

return table.freeze(Rebirths)
