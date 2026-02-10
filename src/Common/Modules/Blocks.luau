local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Block_Models = Assets:WaitForChild("Blocks")

local Brainrots = require(ReplicatedStorage.Common.Modules.Brainrots)

local Types = require(ReplicatedStorage.Common.Types)

local function New_Rarity_Brainrot_Roll(Rarity: Types.Rarity)
    local Choices = {}
    for Name, Data in Brainrots do
        if Data.Rarity == Rarity then
            table.insert(Choices, Name)
        end
    end

    return function()
        return Choices[math.random(1, #Choices)]
    end
end

export type Block = {
    Health: number,
    Rarity: Types.Rarity,
    Chance: number,
    Price: number?,
    Restock_Chance: number,
    Minimum_Stock: number,
    Maximum_Stock: number,
    Image: string,
    Developer_Product: number,
    Model: Model,
    Floats: boolean,
    Roll_Brainrot: () -> string,
}

local Blocks: { [string]: Block } = {
    ["Common"] = {
        Health = 6,
        Rarity = "Common",
        Chance = 0.484,
        Price = 100,
        Restock_Chance = 1,
        Minimum_Stock = 6,
        Maximum_Stock = 8,
        Image = "rbxassetid://79213647551491",
        Developer_Product = 3524815548,
        Model = Block_Models:WaitForChild("Common"),
        Roll_Brainrot = New_Rarity_Brainrot_Roll("Common"),
    },
    ["Rare"] = {
        Health = 30,
        Rarity = "Rare",
        Chance = 0.323,
        Price = 1000,
        Restock_Chance = 1,
        Minimum_Stock = 5,
        Maximum_Stock = 7,
        Image = "rbxassetid://93587961651208",
        Developer_Product = 3524815699,
        Model = Block_Models:WaitForChild("Rare"),
        Roll_Brainrot = New_Rarity_Brainrot_Roll("Rare"),
    },
    ["Epic"] = {
        Health = 250,
        Rarity = "Epic",
        Chance = 0.108,
        Price = 10_000,
        Restock_Chance = 1,
        Minimum_Stock = 3,
        Maximum_Stock = 6,
        Image = "rbxassetid://97817682630959",
        Developer_Product = 3524816002,
        Model = Block_Models:WaitForChild("Epic"),
        Floats = true,
        Roll_Brainrot = New_Rarity_Brainrot_Roll("Epic"),
    },
    ["Legendary"] = {
        Health = 600,
        Rarity = "Legendary",
        Chance = 0.05,
        Price = 100_000,
        Restock_Chance = 3 / 10,
        Minimum_Stock = 2,
        Maximum_Stock = 4,
        Image = "rbxassetid://72423874015250",
        Developer_Product = 3524816133,
        Model = Block_Models:WaitForChild("Legendary"),
        Floats = true,
        Roll_Brainrot = New_Rarity_Brainrot_Roll("Legendary"),
    },
    ["Mythical"] = {
        Health = 1250,
        Rarity = "Mythical",
        Chance = 0.025,
        Price = 250_000,
        Restock_Chance = 2 / 10,
        Minimum_Stock = 1,
        Maximum_Stock = 4,
        Image = "rbxassetid://89867971269576",
        Developer_Product = 3524816198,
        Model = Block_Models:WaitForChild("Mythical"),
        Roll_Brainrot = New_Rarity_Brainrot_Roll("Mythical"),
    },
    ["Secret"] = {
        Health = 2500,
        Rarity = "Secret",
        Chance = 0.01,
        Price = 500_000,
        Restock_Chance = 1 / 10,
        Minimum_Stock = 1,
        Maximum_Stock = 3,
        Image = "rbxassetid://110996944104233",
        Developer_Product = 3524816292,
        Model = Block_Models:WaitForChild("Secret"),
        Floats = true,
        Roll_Brainrot = New_Rarity_Brainrot_Roll("Secret"),
    },
}

local function IsClose(a, b, eps)
    return math.abs(a - b) < (eps or 1e-6)
end

local function Verify_Integrity()
    local Total_Block_Chances = 0

    for Block_Name, Block_Data in Blocks do
        Block_Data.Model:AddTag("Block")
        Total_Block_Chances += Block_Data.Chance
    end
    if not IsClose(Total_Block_Chances, 1) then
        error(string.format("Total Block Chances must equal 1 (currently %.6f)", Total_Block_Chances))
    end
end

Verify_Integrity()

return table.freeze(Blocks)
