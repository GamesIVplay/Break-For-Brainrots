local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Block_Models = Assets:WaitForChild("Blocks")

local Types = require(ReplicatedStorage.Common.Types)

type Block = {
    Health: number,
    Rarity: Types.Rarity,
    Price: number?,
    Restock_Chance: number,
    Minimum_Stock: number,
    Maximum_Stock: number,
    Image: string,
    Developer_Product: number,
    Model: Model,
    Roll_Brainrot: () -> string,
}

local Blocks: { [string]: Block } = {
    ["Common"] = {
        Health = 6,
        Rarity = "Common",
        Price = 100,
        Restock_Chance = 1,
        Minimum_Stock = 6,
        Maximum_Stock = 8,
        Image = "rbxassetid://79213647551491",
        Developer_Product = 3524815548,
        Model = Block_Models:WaitForChild("Common"),
        Roll_Brainrot = function() end,
    },
    ["Rare"] = {
        Health = 30,
        Rarity = "Rare",
        Price = 1000,
        Restock_Chance = 1,
        Minimum_Stock = 5,
        Maximum_Stock = 7,
        Image = "rbxassetid://93587961651208",
        Developer_Product = 3524815699,
        Model = Block_Models:WaitForChild("Rare"),
        Roll_Brainrot = function() end,
    },
    ["Epic"] = {
        Health = 250,
        Rarity = "Epic",
        Price = 10_000,
        Restock_Chance = 1,
        Minimum_Stock = 3,
        Maximum_Stock = 6,
        Image = "rbxassetid://97817682630959",
        Developer_Product = 3524816002,
        Model = Block_Models:WaitForChild("Epic"),
        Roll_Brainrot = function() end,
    },
    ["Legendary"] = {
        Health = 600,
        Rarity = "Legendary",
        Price = 100_000,
        Restock_Chance = 3 / 10,
        Minimum_Stock = 2,
        Maximum_Stock = 4,
        Image = "rbxassetid://72423874015250",
        Developer_Product = 3524816133,
        Model = Block_Models:WaitForChild("Legendary"),
        Roll_Brainrot = function() end,
    },
    ["Mythical"] = {
        Health = 1250,
        Rarity = "Mythical",
        Price = 250_000,
        Restock_Chance = 2 / 10,
        Minimum_Stock = 1,
        Maximum_Stock = 4,
        Image = "rbxassetid://89867971269576",
        Developer_Product = 3524816198,
        Model = Block_Models:WaitForChild("Mythical"),
        Roll_Brainrot = function() end,
    },
    ["Secret"] = {
        Health = 2500,
        Rarity = "Secret",
        Price = 500_000,
        Restock_Chance = 1 / 10,
        Minimum_Stock = 1,
        Maximum_Stock = 3,
        Image = "rbxassetid://110996944104233",
        Developer_Product = 3524816292,
        Model = Block_Models:WaitForChild("Secret"),
        Roll_Brainrot = function() end,
    },
}

return table.freeze(Blocks)
