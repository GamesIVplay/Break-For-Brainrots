local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Blocks = require(ReplicatedStorage.Common.Modules.Blocks)

local Max_Weight_Per_Rarity = {
    Common = 0.45,
    Rare = 0.4,
    Epic = 0.15,
    Legendary = 0.8,
    Mythical = 0.04,
    Secret = 0.02,
}

return function(Luck: number, Excluded: { string }): (string, Blocks.Block)
    local WeightedBlocks = {}
    local TotalWeight = 0

    for Name, Block in Blocks do
        local Weight = 0
        local RarityToUse = Block.Rarity

        if not (Excluded and table.find(Excluded, Name)) then
            Weight = Block.Chance
            -- Apply Luck multiplier per rarity
            if RarityToUse == "Rare" then
                Weight *= 1 + 0.25 * math.sqrt(Luck)
            elseif RarityToUse == "Epic" then
                Weight *= 1 + 0.375 * math.sqrt(Luck)
            elseif RarityToUse == "Legendary" then
                Weight *= 1 + 0.5 * math.sqrt(Luck)
            elseif RarityToUse == "Mythical" then
                Weight *= 1 + 0.625 * math.sqrt(Luck)
            elseif RarityToUse == "Secret" then
                Weight *= 1 + 0.75 * math.sqrt(Luck)
            end

            Weight = math.min(Weight, Max_Weight_Per_Rarity[RarityToUse])
        end

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
