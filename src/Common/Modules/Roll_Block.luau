local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Blocks = require(ReplicatedStorage.Common.Modules.Blocks)

-- Balanced rarity caps
local Max_Weight_Per_Rarity = {
    Common = 0.45,
    Rare = 0.35,
    Epic = 0.15,
    Mutation = 0.13,
    Legendary = 0.08,
    Mythical = 0.04,
    Secret = 0.02,
}

return function(Luck: number, Excluded: { string }): (string, Blocks.Block)
    local WeightedBlocks = {}
    local TotalWeight = 0

    local Bonus = math.max(0, Luck - 1)

    local ScaledBonus = Bonus ^ 0.6

    for Name, Block in Blocks do
        local Weight = 0
        local Rarity = Block.Rarity

        if not (Excluded and table.find(Excluded, Name)) then
            Weight = Block.Chance

            if Rarity == "Rare" then
                Weight *= 1 + 0.20 * ScaledBonus
            elseif Rarity == "Mutation" then
                Weight *= 1 + 0.35 * ScaledBonus
            elseif Rarity == "Epic" then
                Weight *= 1 + 0.30 * ScaledBonus
            elseif Rarity == "Legendary" then
                Weight *= 1 + 0.40 * ScaledBonus
            elseif Rarity == "Mythical" then
                Weight *= 1 + 0.50 * ScaledBonus
            elseif Rarity == "Secret" then
                Weight *= 1 + 0.60 * ScaledBonus
            end

            -- Clamp to rarity cap

            if Max_Weight_Per_Rarity[Rarity] then
                Weight = math.min(Weight, Max_Weight_Per_Rarity[Rarity])
            end
        end

        table.insert(WeightedBlocks, {
            Name = Name,
            Weight = Weight,
        })

        TotalWeight += Weight
    end

    if TotalWeight <= 0 then
        return "Common", Blocks["Common"]
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
