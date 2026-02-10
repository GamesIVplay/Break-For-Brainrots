type Secondary_Mutation = {
    Weather: string?,
    Chance: number,
    Cash_Multiplier: number,
    Image: string,
}

local Secondary_Mutations: { [string]: Secondary_Mutation } = {
    ["Blood"] = {
        Weather = "Blood",
        Chance = 0.2,
        Cash_Multiplier = 1.15,
        Image = "rbxassetid://122272507513469",
    },
    ["Candy"] = {
        Weather = "Candy",
        Chance = 0.15,
        Cash_Multiplier = 1.25,
        Image = "rbxassetid://127536426524827",
    },
    ["Volcanic"] = {
        Weather = "Volcanic",
        Chance = 0.1,
        Cash_Multiplier = 1.5,
        Image = "rbxassetid://112422836214373",
    },
    ["Toxic"] = {
        Weather = "Toxic",
        Chance = 0.05,
        Cash_Multiplier = 2,
        Image = "rbxassetid://73251144399969",
    },
}

return Secondary_Mutations
