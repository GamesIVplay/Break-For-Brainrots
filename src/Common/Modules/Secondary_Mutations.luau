type Secondary_Mutation = {
    Chance: number,
    Cash_Multiplier: number,
    Weather: string,
}

local Secondary_Mutations: { [string]: Secondary_Mutation } = {
    ["Blood"] = {
        Chance = 0.2,
        Cash_Multiplier = 1.15,
        Weather = "Blood",
    },
    ["Candy"] = {
        Chance = 0.15,
        Cash_Multiplier = 1.25,
        Weather = "Candy",
    },
    ["Volcanic"] = {
        Chance = 0.1,
        Cash_Multiplier = 1.5,
        Weather = "Volcanic",
    },
    ["Toxic"] = {
        Chance = 0.05,
        Cash_Multiplier = 2,
        Weather = "Toxic",
    },
}

return Secondary_Mutations
