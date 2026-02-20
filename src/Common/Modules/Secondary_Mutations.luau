type Secondary_Mutation = {
    Required_Weather: string?,
    Chance: number,
    Cash_Multiplier: number,
    Image: string,
}

local Secondary_Mutations: { [string]: Secondary_Mutation } = {
    ["Starstruck"] = {
        Chance = 0.02,
        Cash_Multiplier = 1.25,
        Image = "rbxassetid://126473147853106",
    },
    ["Electro"] = {
        Chance = 0.02,
        Cash_Multiplier = 1.25,
        Image = "rbxassetid://96532161780642",
    },
    ["Blood"] = {
        Chance = 0.02,
        Cash_Multiplier = 1.25,
        Image = "rbxassetid://122272507513469",
    },
    ["YinYang"] = {
        Required_Weather = "YinYang",
        Chance = 0.15,
        Cash_Multiplier = 1.5,
        Image = "rbxassetid://138317915035795",
    },
    ["Hacker"] = {
        Required_Weather = "Hacker",
        Chance = 0.15,
        Cash_Multiplier = 1.5,
        Image = "rbxassetid://140099576560562",
    },
    ["Volcanic"] = {
        Required_Weather = "Volcanic",
        Chance = 0.15,
        Cash_Multiplier = 2,
        Image = "rbxassetid://112422836214373",
    },
    ["Candy"] = {
        Required_Weather = "Candy",
        Chance = 0.15,
        Cash_Multiplier = 2,
        Image = "rbxassetid://127536426524827",
    },
    ["Toxic"] = {
        Required_Weather = "Toxic",
        Chance = 0.15,
        Cash_Multiplier = 2,
        Image = "rbxassetid://73251144399969",
    },
}

return Secondary_Mutations
