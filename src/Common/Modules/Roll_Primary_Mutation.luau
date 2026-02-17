local Primary_Mutations = require(script.Parent.Primary_Mutations)

return function(Mutation_Luck: number)
    local Luck_Factor = 0.15

    for Mutation_Name, Data in Primary_Mutations do
        local Effective_Chance = Data.Chance * (1 + Mutation_Luck * Luck_Factor)

        if math.random() <= Effective_Chance then
            return Mutation_Name
        end
    end

    return nil
end
