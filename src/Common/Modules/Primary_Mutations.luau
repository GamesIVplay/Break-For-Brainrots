type Primary_Mutation = {
    Chance: number,
    Cash_Multiplier: number,
}

local Primary_Mutations: { [string]: Primary_Mutation } = {
    ["Lava"] = {
        Chance = 0.2,
        Cash_Multiplier = 1.15,
    },
    ["Gold"] = {
        Chance = 0.15,
        Cash_Multiplier = 1.25,
    },
    ["Diamond"] = {
        Chance = 0.1,
        Cash_Multiplier = 1.5,
    },
    ["Rainbow"] = {
        Chance = 0.05,
        Cash_Multiplier = 2,
    },
}

return Primary_Mutations
