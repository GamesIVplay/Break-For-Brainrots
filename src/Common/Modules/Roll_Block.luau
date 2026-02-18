local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Blocks = require(ReplicatedStorage.Common.Modules.Blocks)

local Max_Weight_Per_Rarity = {
    Common = 0.45,
    Rare = 0.4,
    Epic = 0.3,
    Legendary = 0.1,
    Mythical = 0.08,
    Secret = 0.05,
}

return function(Luck: number, Exluded: { string }): (string, Blocks.Block)
    local WeightedBlocks = {}
    local TotalWeight = 0

    for Name, Block in Blocks do
        if Exluded and table.find(Exluded, Name) then
            continue
        end

        local Weight = Block.Chance

        local RarityMultiplier = 1

        if Block.Rarity == "Rare" then
            RarityMultiplier = 1 + 0.25 * (Luck - 1)
        elseif Block.Rarity == "Epic" then
            RarityMultiplier = 1 + 0.375 * (Luck - 1)
        elseif Block.Rarity == "Legendary" then
            RarityMultiplier = 1 + 0.5 * (Luck - 1)
        elseif Block.Rarity == "Mythical" then
            RarityMultiplier = 1 + 0.625 * (Luck - 1)
        elseif Block.Rarity == "Secret" then
            RarityMultiplier = 1 + 0.75 * (Luck - 1)
        end

        Weight *= RarityMultiplier

        Weight = math.min(Weight, Max_Weight_Per_Rarity[Block.Rarity])

        table.insert(WeightedBlocks, { Name = Name, Weight = Weight })
        TotalWeight += Weight
    end

    local Roll = math.random() * TotalWeight
    local Cumulative = 0
    for _, Data in WeightedBlocks do
        Cumulative += Data.Weight
        if Roll <= Cumulative then
            return Data.Name, Blocks[Data.Name]
        end
    end

    return "Common", Blocks["Common"]
end
