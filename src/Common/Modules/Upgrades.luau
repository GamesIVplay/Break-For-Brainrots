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
    ["Luck Multiplier"] = {
        Index = 1,
        Rebirth = 0,
        Image = "rbxassetid://133762348059753",
        Image_Size = UDim2.fromScale(0.166, 0.665),
        Levels = {
            [1] = { Price = 0, Multiplier = 1 },
            [2] = { Price = 15_000, Multiplier = 1.25 },
            [3] = { Price = 50_000, Multiplier = 1.5 },
            [4] = { Price = 100_000, Multiplier = 1.75 },
            [5] = { Price = 500_000, Multiplier = 2 },
            [6] = { Price = 1_000_000, Multiplier = 2.25 },
            [7] = { Price = 5_000_000, Multiplier = 2.5 },
            [8] = { Price = 10_000_000, Multiplier = 2.75 },
            [9] = { Price = 20_000_000, Multiplier = 3 },
        },
        Developer_Product = 3532186159,
    },

    ["Cash Multiplier"] = {
        Index = 2,
        Rebirth = 0,
        Image = "rbxassetid://117096352870961",
        Image_Size = UDim2.fromScale(0.166, 0.665),
        Levels = {
            [1] = { Price = 0, Multiplier = 1 },
            [2] = { Price = 15_000, Multiplier = 1.05 },
            [3] = { Price = 50_000, Multiplier = 1.1 },
            [4] = { Price = 100_000, Multiplier = 1.15 },
            [5] = { Price = 500_000, Multiplier = 1.2 },
            [6] = { Price = 1_000_000, Multiplier = 1.25 },
            [7] = { Price = 5_000_000, Multiplier = 1.3 },
            [8] = { Price = 10_000_000, Multiplier = 1.35 },
            [9] = { Price = 20_000_000, Multiplier = 1.4 },
        },
        Developer_Product = 3532186247,
    },

    --[[["Auto Swing"] = {
        Index = 3,
        Rebirth = 1,
        Image = "rbxassetid://120608776234904",
        Image_Size = UDim2.fromScale(0.189, 0.756),
        Levels = {
            [1] = { Price = 0, Multiplier = 1 },
            [2] = { Price = 0, Multiplier = 1.25 },
            [3] = { Price = 0, Multiplier = 1.5 },
            [4] = { Price = 0, Multiplier = 1.75 },
            [5] = { Price = 0, Multiplier = 2 },
            [6] = { Price = 0, Multiplier = 2.25 },
            [7] = { Price = 0, Multiplier = 2.5 },
            [8] = { Price = 0, Multiplier = 2.75 },
            [9] = { Price = 0, Multiplier = 3 },
        },
        Developer_Product = 3532186376,
    },]]

    ["Mutation Luck"] = {
        Index = 4,
        Rebirth = 1,
        Image = "rbxassetid://78657286311430",
        Image_Size = UDim2.fromScale(0.166, 0.665),

        Levels = {
            [1] = { Price = 100_000, Multiplier = 1 },
            [2] = { Price = 250_000, Multiplier = 1.25 },
            [3] = { Price = 750_000, Multiplier = 1.5 },
            [4] = { Price = 1_500_000, Multiplier = 1.75 },
            [5] = { Price = 5_000_000, Multiplier = 2 },
            [6] = { Price = 10_000_000, Multiplier = 2.25 },
            [7] = { Price = 25_000_000, Multiplier = 2.5 },
            [8] = { Price = 60_000_000, Multiplier = 2.75 },
            [9] = { Price = 120_000_000, Multiplier = 3 },
        },
        Developer_Product = 3532186497,
    },

    ["Better Luck"] = {
        Index = 5,
        Rebirth = 2,
        Image = "rbxassetid://101894466559920",
        Image_Size = UDim2.fromScale(0.166, 0.665),
        Levels = {
            [1] = { Price = 250_000, Multiplier = 1 },
            [2] = { Price = 600_000, Multiplier = 1.25 },
            [3] = { Price = 1_500_000, Multiplier = 1.5 },
            [4] = { Price = 3_500_000, Multiplier = 1.75 },
            [5] = { Price = 10_000_000, Multiplier = 2 },
            [6] = { Price = 22_000_000, Multiplier = 2.25 },
            [7] = { Price = 55_000_000, Multiplier = 2.5 },
            [8] = { Price = 120_000_000, Multiplier = 2.75 },
            [9] = { Price = 250_000_000, Multiplier = 3 },
        },
        Developer_Product = 3532186620,
    },
}

return table.freeze(Upgrades)
