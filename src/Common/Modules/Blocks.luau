local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Block_Models = Assets:WaitForChild("Blocks")

local Types = require(ReplicatedStorage.Common.Types)

type Block = {
    Health: number,
    Rarity: Types.Rarity,
    Price: number?,
    Minimum_Stock: number,
    Maximum_Stock: number,
    Image: string,
    Developer_Product: number,
    Model: Model,
}

local Blocks: { [string]: Block } = {
    ["Common"] = {
        Health = 6,
        Rarity = "Common",
        Price = 1,
        Minimum_Stock = 6,
        Maximum_Stock = 8,
        Image = "rbxassetid://79213647551491",
        Developer_Product = 3524815548,
        Model = Block_Models:WaitForChild("Common"),
    },
    ["Rare"] = {
        Health = 30,
        Rarity = "Rare",
        Price = 2,
        Minimum_Stock = 6,
        Maximum_Stock = 8,
        Image = "rbxassetid://93587961651208",
        Developer_Product = 3524815699,
        Model = Block_Models:WaitForChild("Rare"),
    },
    ["Epic"] = {
        Health = 250,
        Rarity = "Epic",
        Price = 3,
        Minimum_Stock = 6,
        Maximum_Stock = 8,
        Image = "rbxassetid://97817682630959",
        Developer_Product = 3524816002,
        Model = Block_Models:WaitForChild("Epic"),
    },
    ["Legendary"] = {
        Health = 600,
        Rarity = "Legendary",
        Price = 4,
        Minimum_Stock = 6,
        Maximum_Stock = 8,
        Image = "rbxassetid://72423874015250",
        Developer_Product = 3524816133,
        Model = Block_Models:WaitForChild("Legendary"),
    },
    ["Mythical"] = {
        Health = 1250,
        Rarity = "Mythical",
        Price = 5,
        Minimum_Stock = 6,
        Maximum_Stock = 8,
        Image = "rbxassetid://89867971269576",
        Developer_Product = 3524816198,
        Model = Block_Models:WaitForChild("Mythical"),
    },
    ["Secret"] = {
        Health = 2500,
        Rarity = "Secret",
        Price = 6,
        Minimum_Stock = 6,
        Maximum_Stock = 8,
        Image = "rbxassetid://110996944104233",
        Developer_Product = 3524816292,
        Model = Block_Models:WaitForChild("Secret"),
    },
}

return table.freeze(Blocks)
