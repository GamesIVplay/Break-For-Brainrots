local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Components = require(ReplicatedStorage.Common.Components)
local Secondary_Mutations = require(script.Parent.Secondary_Mutations)
local World = require(ReplicatedStorage.Common.World)

return function(Mutation_Luck: number)
    local Active_Events = World:get(Components.Singletons.Active_Events, Components.Singletons.Active_Events)

    local Luck_Factor = 0.2
    local Rolled_Mutations = {}

    local Bonus = math.max(0, Mutation_Luck - 1)

    local ScaledBonus = Bonus ^ 0.6

    local Names = {}
    for Mutation_Name in pairs(Secondary_Mutations) do
        table.insert(Names, Mutation_Name)
    end

    for i = #Names, 2, -1 do
        local j = math.random(1, i)
        Names[i], Names[j] = Names[j], Names[i]
    end

    for _, Mutation_Name in ipairs(Names) do
        local Data = Secondary_Mutations[Mutation_Name]

        if Data.Required_Weather and Active_Events[Data.Required_Weather] == nil then
            continue
        end

        local Effective_Chance = Data.Chance * (1 + Luck_Factor * ScaledBonus)

        Effective_Chance = math.min(Effective_Chance, 0.85)

        if math.random() <= Effective_Chance then
            table.insert(Rolled_Mutations, Mutation_Name)
        end
    end

    return Rolled_Mutations
end
