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
        Multiplier = 1.05,
    },
    [2] = {
        Requirement = 20_000,
        Multiplier = 1.1,
    },
    [3] = {
        Requirement = 40_000,
        Multiplier = 1.15,
    },
    [4] = {
        Requirement = 80_000,
        Multiplier = 1.2,
    },
}

return table.freeze(Rebirths)
