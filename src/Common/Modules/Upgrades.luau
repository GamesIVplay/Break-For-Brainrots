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
            [2] = { Price = 0, Multiplier = 1.25 },
            [3] = { Price = 0, Multiplier = 1.5 },
            [4] = { Price = 0, Multiplier = 1.75 },
            [5] = { Price = 0, Multiplier = 2 },
            [6] = { Price = 0, Multiplier = 2.25 },
            [7] = { Price = 0, Multiplier = 2.5 },
            [8] = { Price = 0, Multiplier = 2.75 },
            [9] = { Price = 0, Multiplier = 3 },
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
            [2] = { Price = 0, Multiplier = 1.25 },
            [3] = { Price = 0, Multiplier = 1.5 },
            [4] = { Price = 0, Multiplier = 1.75 },
            [5] = { Price = 0, Multiplier = 2 },
            [6] = { Price = 0, Multiplier = 2.25 },
            [7] = { Price = 0, Multiplier = 2.5 },
            [8] = { Price = 0, Multiplier = 2.75 },
            [9] = { Price = 0, Multiplier = 3 },
        },
        Developer_Product = 3532186247,
    },

    ["Auto Swing"] = {
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
    },

    ["Mutation Luck"] = {
        Index = 4,
        Rebirth = 2,
        Image = "rbxassetid://78657286311430",
        Image_Size = UDim2.fromScale(0.166, 0.665),
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
        Developer_Product = 3532186497,
    },

    ["Better Luck"] = {
        Index = 5,
        Rebirth = 2,
        Image = "rbxassetid://101894466559920",
        Image_Size = UDim2.fromScale(0.166, 0.665),
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
        Developer_Product = 3532186620,
    },
}

return table.freeze(Upgrades)
