local Secondary_Mutations = require(script.Parent.Secondary_Mutations)

return function(Mutation_Luck: number)
    local Luck_Factor = 0.5 -- reduce luck effect by half
    local Rolled_Mutations = {}

    for Mutation_Name, Data in Secondary_Mutations do
        local Effective_Chance = Data.Chance * (1 + Mutation_Luck * Luck_Factor)

        if math.random() <= Effective_Chance then
            table.insert(Rolled_Mutations, Mutation_Name)
        end
    end

    return Rolled_Mutations
end
