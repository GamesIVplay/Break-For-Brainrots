local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Brainrots = require(ReplicatedStorage.Common.Modules.Brainrots)
local Primary_Mutations = require(ReplicatedStorage.Common.Modules.Primary_Mutations)
local Secondary_Mutations = require(ReplicatedStorage.Common.Modules.Secondary_Mutations)
local Weight = require(ReplicatedStorage.Common.Modules.Weight)

return function(Data: {
    Brainrot_Name: string,
    Primary_Mutation: string?,
    Secondary_Mutations: { string },
    Weight: number,
}): number
    local Income_Per_Sec = Brainrots[Data.Brainrot_Name].IncomePerSec

    if Data.Primary_Mutation then
        Income_Per_Sec *= Primary_Mutations[Data.Primary_Mutation].Cash_Multiplier
    end

    for _, Mutation_Name in Data.Secondary_Mutations do
        Income_Per_Sec *= Secondary_Mutations[Mutation_Name].Cash_Multiplier
    end

    Income_Per_Sec *= Weight.Get_Cash_Multiplier(Data.Weight)

    return math.max(1, Income_Per_Sec)
end
