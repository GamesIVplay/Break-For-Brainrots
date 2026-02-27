local Primary_Mutations = require(script.Parent.Primary_Mutations)

return function(Mutation_Luck: number)
    local Luck_Factor = 0.20
    local Candidates = {}

    local Bonus = math.max(0, Mutation_Luck - 1)

    local ScaledBonus = Bonus ^ 0.6

    local Names = {}
    for Mutation_Name in pairs(Primary_Mutations) do
        table.insert(Names, Mutation_Name)
    end

    for i = #Names, 2, -1 do
        local j = math.random(1, i)
        Names[i], Names[j] = Names[j], Names[i]
    end

    for _, Mutation_Name in ipairs(Names) do
        local Data = Primary_Mutations[Mutation_Name]

        local Effective_Chance = Data.Chance * (1 + Luck_Factor * ScaledBonus)

        if math.random() <= Effective_Chance then
            table.insert(Candidates, Mutation_Name)
        end
    end

    if #Candidates > 0 then
        return Candidates[math.random(1, #Candidates)]
    end

    return nil
end
