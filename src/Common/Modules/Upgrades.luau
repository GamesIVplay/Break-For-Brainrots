type Upgrade = {
    Index: number,
    Rebirth: number,
    Image: string,
    Image_Size: UDim2,
    Levels: {
        [number]: { Price: number, Multiplier: number },
    },
    Developer_Product: number,
}

local Upgrades: { [string]: Upgrade } = {
    ["Luck Boost"] = {
        Index = 1,
        Rebirth = 0,
        Image = "rbxassetid://133762348059753",
        Image_Size = UDim2.fromScale(0.166, 0.665),
        Levels = {
            [1] = { Price = 0, Percent = 0 },
            [2] = { Price = 15_000, Percent = 12 },
            [3] = { Price = 50_000, Percent = 25 },
            [4] = { Price = 100_000, Percent = 37 },
            [5] = { Price = 500_000, Percent = 50 },
            [6] = { Price = 1_000_000, Percent = 62 },
            [7] = { Price = 5_000_000, Percent = 75 },
            [8] = { Price = 10_000_000, Percent = 87 },
            [9] = { Price = 20_000_000, Percent = 100 },
        },
        Developer_Product = 3532186159,
    },

    ["Cash Boost"] = {
        Index = 2,
        Rebirth = 0,
        Image = "rbxassetid://117096352870961",
        Image_Size = UDim2.fromScale(0.166, 0.665),
        Levels = {
            [1] = { Price = 0, Percent = 0 },
            [2] = { Price = 15_000, Percent = 5 },
            [3] = { Price = 50_000, Percent = 10 },
            [4] = { Price = 100_000, Percent = 15 },
            [5] = { Price = 500_000, Percent = 20 },
            [6] = { Price = 1_000_000, Percent = 30 },
            [7] = { Price = 5_000_000, Percent = 40 },
            [8] = { Price = 10_000_000, Percent = 50 },
            [9] = { Price = 20_000_000, Percent = 60 },
        },
        Developer_Product = 3532186247,
    },

    ["Mutation Luck"] = {
        Index = 4,
        Rebirth = 1,
        Image = "rbxassetid://78657286311430",
        Image_Size = UDim2.fromScale(0.166, 0.665),
        Levels = {
            [1] = { Price = 100_000, Percent = 0 },
            [2] = { Price = 250_000, Percent = 12 },
            [3] = { Price = 750_000, Percent = 25 },
            [4] = { Price = 1_500_000, Percent = 37 },
            [5] = { Price = 5_000_000, Percent = 50 },
            [6] = { Price = 10_000_000, Percent = 62 },
            [7] = { Price = 25_000_000, Percent = 75 },
            [8] = { Price = 60_000_000, Percent = 87 },
            [9] = { Price = 120_000_000, Percent = 100 },
        },
        Developer_Product = 3532186497,
    },

    ["Better Luck"] = {
        Index = 5,
        Rebirth = 2,
        Image = "rbxassetid://101894466559920",
        Image_Size = UDim2.fromScale(0.166, 0.665),
        Levels = {
            [1] = { Price = 250_000, Percent = 0 },
            [2] = { Price = 600_000, Percent = 12 },
            [3] = { Price = 1_500_000, Percent = 25 },
            [4] = { Price = 3_500_000, Percent = 37 },
            [5] = { Price = 10_000_000, Percent = 50 },
            [6] = { Price = 22_000_000, Percent = 62 },
            [7] = { Price = 55_000_000, Percent = 75 },
            [8] = { Price = 120_000_000, Percent = 87 },
            [9] = { Price = 250_000_000, Percent = 100 },
        },
        Developer_Product = 3532186620,
    },
}

return table.freeze(Upgrades)
