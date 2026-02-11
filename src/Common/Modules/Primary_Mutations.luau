type Primary_Mutation = {
    Chance: number,
    Cash_Multiplier: number,
}

local Primary_Mutations: { [string]: Primary_Mutation } = {
    ["Lava"] = {
        Chance = 0.08,
        Cash_Multiplier = 1.15,
    },
    ["Gold"] = {
        Chance = 0.05,
        Cash_Multiplier = 1.25,
    },
    ["Diamond"] = {
        Chance = 0.02,
        Cash_Multiplier = 1.5,
    },
    ["Rainbow"] = {
        Chance = 0.01,
        Cash_Multiplier = 2,
    },
}

return table.freeze(Primary_Mutations)
