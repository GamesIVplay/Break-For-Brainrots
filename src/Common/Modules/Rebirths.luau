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
        Requirement = 15_000,
        Multiplier = 1.5,
    },
}

return table.freeze(Rebirths)
