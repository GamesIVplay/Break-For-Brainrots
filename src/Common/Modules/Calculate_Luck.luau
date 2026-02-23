local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Components = require(ReplicatedStorage.Common.Components)
local Types = require(ReplicatedStorage.Common.Types)
local World = require(ReplicatedStorage.Common.World)

local Upgrades = require(ReplicatedStorage.Common.Modules.Upgrades)

return function(Player_Entity: Types.Entity)
    local Active_Events = World:get(Components.Singletons.Active_Events, Components.Singletons.Active_Events)

    local Luck = 1

    for _, Data in Active_Events do
        Luck *= Data.Luck_Multiplier
    end

    if not World:contains(Player_Entity) or not World:has(Player_Entity, Components.Player) then
        return Luck
    end

    local Player_Upgrades = World:get(Player_Entity, Components.Upgrades)

    if Player_Upgrades then
        for _, Upgrade_Name in { "Luck Multiplier", "Better Luck" } do
            local Level = Player_Upgrades[Upgrade_Name] or 1
            local Multiplier = Upgrades[Upgrade_Name].Levels[Level].Multiplier

            Luck *= Multiplier
        end
    end

    local Gamepasses = World:get(Player_Entity, Components.Gamepasses)

    if Gamepasses and table.find(Gamepasses, "x2 Luck") then
        Luck *= 2
    end

    Luck = math.round(Luck * 100) / 100
    return Luck
end
