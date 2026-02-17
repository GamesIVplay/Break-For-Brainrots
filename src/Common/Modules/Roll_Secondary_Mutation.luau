local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Components = require(ReplicatedStorage.Common.Components)
local World = require(ReplicatedStorage.Common.World)

local Secondary_Mutations = require(script.Parent.Secondary_Mutations)

return function(Mutation_Luck: number)
    local Active_Events = World:get(Components.Singletons.Active_Events, Components.Singletons.Active_Events)

    local Luck_Factor = 0.15
    local Rolled_Mutations = {}

    for Mutation_Name, Data in Secondary_Mutations do
        if Data.Required_Weather and Active_Events[Data.Required_Weather] == nil then
            continue
        end

        local Effective_Chance = Data.Chance * (1 + Mutation_Luck * Luck_Factor)

        if math.random() <= Effective_Chance then
            table.insert(Rolled_Mutations, Mutation_Name)
        end
    end

    return Rolled_Mutations
end
