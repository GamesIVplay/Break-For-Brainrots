local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Components = require(ReplicatedStorage.Common.Components)
local Types = require(ReplicatedStorage.Common.Types)
local World = require(ReplicatedStorage.Common.World)

local Upgrades = require(ReplicatedStorage.Common.Modules.Upgrades)

return function(Player_Entity: Types.Entity)
    local Mutation_Luck = 1

    if not World:contains(Player_Entity) or not World:has(Player_Entity, Components.Player) then
        return Mutation_Luck
    end

    local Player_Upgrades = World:get(Player_Entity, Components.Upgrades)

    if Player_Upgrades then
        for _, Upgrade_Name in { "Mutation Luck" } do
            local Level = Player_Upgrades[Upgrade_Name]
            local Multiplier = Upgrades[Upgrade_Name].Levels[Level].Multiplier

            Mutation_Luck *= Multiplier
        end
    end

    return Mutation_Luck
end
