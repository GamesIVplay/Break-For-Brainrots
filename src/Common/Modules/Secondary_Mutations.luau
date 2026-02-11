type Secondary_Mutation = {
    Weather: string?,
    Chance: number,
    Cash_Multiplier: number,
    Image: string,
}

local Secondary_Mutations: { [string]: Secondary_Mutation } = {
    ["Blood"] = {
        Weather = "Blood",
        Chance = 0.08,
        Cash_Multiplier = 1.5,
        Image = "rbxassetid://122272507513469",
    },
    ["Volcanic"] = {
        Weather = "Volcanic",
        Chance = 0.08,
        Cash_Multiplier = 1.5,
        Image = "rbxassetid://112422836214373",
    },
    ["Candy"] = {
        Weather = "Candy",
        Chance = 0.03,
        Cash_Multiplier = 2,
        Image = "rbxassetid://127536426524827",
    },
    ["Toxic"] = {
        Weather = "Toxic",
        Chance = 0.01,
        Cash_Multiplier = 2,
        Image = "rbxassetid://73251144399969",
    },
}

return Secondary_Mutations
