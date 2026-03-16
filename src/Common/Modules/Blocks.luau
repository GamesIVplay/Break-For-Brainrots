local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Block_Models = Assets:WaitForChild("Blocks")

local Brainrots = require(ReplicatedStorage.Common.Modules.Brainrots)

local Rarities = require(ReplicatedStorage.Common.Modules.Rarities)
local Types = require(ReplicatedStorage.Common.Types)

local RarityOrder = {}

for Name, Index in pairs(Rarities) do
    table.insert(RarityOrder, Name)
end

table.sort(RarityOrder, function(a, b)
    return Rarities[a] > Rarities[b]
end)

local function GetLowerRarity(Rarity)
    local Index = table.find(RarityOrder, Rarity)

    if not Index or Index == 1 then
        return Rarity
    end

    return RarityOrder[Index - 1]
end

local DowngradeChance = {
    Rare = 0.05,
    Epic = 0.2,
    Legendary = 0.6,
    Mythical = 0.8,
    Secret = 0.9,
}

local function New_Rarity_Brainrot_Roll(Rarity: Types.Rarity, Exclusions: { string }?, Additions: { string }?)
    return function()
        local RolledRarity = Rarity

        while DowngradeChance[RolledRarity] and math.random() <= DowngradeChance[RolledRarity] do
            local Lower = GetLowerRarity(RolledRarity)
            if not Lower then
                break
            end

            RolledRarity = Lower
        end

        local Choices = {}

        for Name, Data in Brainrots do
            local IsExcluded = Exclusions and table.find(Exclusions, Name)
            local IsAdded = Additions and table.find(Additions, Name)

            if not IsExcluded and (Data.Rarity == RolledRarity or IsAdded) then
                table.insert(Choices, Name)
            end
        end

        return Choices[math.random(#Choices)]
    end
end

local function New_Multi_Rarity_Brainrot_Roll(
    RaritiesList: { Types.Rarity },
    Exclusions: { string }?,
    Additions: { string }?
)
    return function()
        local RolledRarity = RaritiesList[math.random(#RaritiesList)]

        while DowngradeChance[RolledRarity] and math.random() <= DowngradeChance[RolledRarity] do
            local Lower = GetLowerRarity(RolledRarity)
            if not Lower then
                break
            end

            RolledRarity = Lower
        end

        local Choices = {}

        for Name, Data in Brainrots do
            local IsExcluded = Exclusions and table.find(Exclusions, Name)
            local IsAdded = Additions and table.find(Additions, Name)

            if not IsExcluded and (Data.Rarity == RolledRarity or IsAdded) then
                table.insert(Choices, Name)
            end
        end

        return Choices[math.random(#Choices)]
    end
end

export type Block = {
    Health: number,
    Rarity: Types.Rarity,
    Guranteed_Mutation: string?,
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
    Part_Color: Color3,
}

local Blocks: { [string]: Block } = {
    ["Common"] = {
        Health = 5,
        Rarity = "Common",
        Chance = 0.484,
        Price = 500,
        Restock_Chance = 1,
        Minimum_Stock = 6,
        Maximum_Stock = 8,
        Image = "rbxassetid://79213647551491",
        Developer_Product = 3524815548,
        Model = Block_Models:WaitForChild("Common"),
        Roll_Brainrot = New_Rarity_Brainrot_Roll("Common"),
        Part_Color = Color3.fromRGB(128, 129, 138),
    },
    ["Rare"] = {
        Health = 25,
        Rarity = "Rare",
        Chance = 0.263,
        Price = 10_000,
        Restock_Chance = 1,
        Minimum_Stock = 5,
        Maximum_Stock = 7,
        Image = "rbxassetid://93587961651208",
        Developer_Product = 3524815699,
        Model = Block_Models:WaitForChild("Rare"),
        Roll_Brainrot = New_Rarity_Brainrot_Roll("Rare"),
        Part_Color = Color3.fromRGB(33, 84, 185),
    },
    ["Epic"] = {
        Health = 100,
        Rarity = "Epic",
        Chance = 0.068,
        Price = 500_000,
        Restock_Chance = 1,
        Minimum_Stock = 3,
        Maximum_Stock = 6,
        Image = "rbxassetid://97817682630959",
        Developer_Product = 3524816002,
        Model = Block_Models:WaitForChild("Epic"),
        Floats = true,
        Roll_Brainrot = New_Rarity_Brainrot_Roll("Epic"),
        Part_Color = Color3.fromRGB(255, 176, 0),
    },

    ["Legendary"] = {
        Health = 250,
        Rarity = "Legendary",
        Chance = 0.05,
        Price = 2_500_000,
        Restock_Chance = 3 / 10,
        Minimum_Stock = 2,
        Maximum_Stock = 4,
        Image = "rbxassetid://72423874015250",
        Developer_Product = 3524816133,
        Model = Block_Models:WaitForChild("Legendary"),
        Floats = true,
        Roll_Brainrot = New_Rarity_Brainrot_Roll("Legendary"),
        Part_Color = Color3.fromRGB(171, 23, 23),
    },
    ["Mythical"] = {
        Health = 500,
        Rarity = "Mythical",
        Chance = 0.025,
        Price = 5_000_000,
        Restock_Chance = 2 / 10,
        Minimum_Stock = 1,
        Maximum_Stock = 4,
        Image = "rbxassetid://89867971269576",
        Developer_Product = 3524816198,
        Model = Block_Models:WaitForChild("Mythical"),
        Roll_Brainrot = New_Rarity_Brainrot_Roll("Mythical"),
        Part_Color = Color3.fromRGB(255, 255, 255),
    },
    ["Secret"] = {
        Health = 1000,
        Rarity = "Secret",
        Chance = 0.01,
        Price = 10_000_000,
        Restock_Chance = 1 / 10,
        Minimum_Stock = 1,
        Maximum_Stock = 3,
        Image = "rbxassetid://110996944104233",
        Developer_Product = 3524816292,
        Model = Block_Models:WaitForChild("Secret"),
        Floats = true,
        Roll_Brainrot = New_Rarity_Brainrot_Roll("Secret", { "Los Tralaleritos" }),
        Part_Color = Color3.fromRGB(0, 0, 0),
    },

    -- Mutated Blocks
    ["Hacker"] = {
        Health = 150,
        Rarity = "Mutation",
        Guranteed_Mutation = "Hacker",
        Chance = 0.025,
        Model = Block_Models:WaitForChild("Hacker"),
        Roll_Brainrot = New_Multi_Rarity_Brainrot_Roll({
            "Common",
            "Rare",
            "Epic",
            "Legendary",
            "Mythical",
            "Secret",
        }),
        Part_Color = Color3.fromRGB(74, 150, 62),
    },
    ["Volcanic"] = {
        Health = 150,
        Rarity = "Mutation",
        Guranteed_Mutation = "Volcanic",
        Chance = 0.025,
        Model = Block_Models:WaitForChild("Volcanic"),
        Roll_Brainrot = New_Multi_Rarity_Brainrot_Roll({
            "Common",
            "Rare",
            "Epic",
            "Legendary",
            "Mythical",
            "Secret",
        }),
        Part_Color = Color3.fromRGB(220, 121, 50),
    },
    ["Candy"] = {
        Health = 150,
        Rarity = "Mutation",
        Guranteed_Mutation = "Candy",
        Chance = 0.025,
        Model = Block_Models:WaitForChild("Candy"),
        Roll_Brainrot = New_Multi_Rarity_Brainrot_Roll({
            "Common",
            "Rare",
            "Epic",
            "Legendary",
            "Mythical",
            "Secret",
        }),
        Part_Color = Color3.fromRGB(230, 143, 241),
    },
    ["Electro"] = {
        Health = 150,
        Rarity = "Mutation",
        Guranteed_Mutation = "Electro",
        Chance = 0.025,
        Model = Block_Models:WaitForChild("Electro"),
        Roll_Brainrot = New_Multi_Rarity_Brainrot_Roll({
            "Common",
            "Rare",
            "Epic",
            "Legendary",
            "Mythical",
            "Secret",
        }),
        Part_Color = Color3.fromRGB(90, 181, 189),
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
