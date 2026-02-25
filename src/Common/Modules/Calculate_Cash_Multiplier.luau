local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Components = require(ReplicatedStorage.Common.Components)
local Types = require(ReplicatedStorage.Common.Types)
local World = require(ReplicatedStorage.Common.World)

local Rebirths = require(ReplicatedStorage.Common.Modules.Rebirths)
local Upgrades = require(ReplicatedStorage.Common.Modules.Upgrades)

return function(Player_Entity: Types.Entity)
    local Cash_Multiplier = 1

    if not World:contains(Player_Entity) or not World:has(Player_Entity, Components.Player) then
        return Cash_Multiplier
    end

    local Player_Upgrades = World:get(Player_Entity, Components.Upgrades)

    if Player_Upgrades then
        for _, Upgrade_Name in { "Cash Multiplier" } do
            local Level = Player_Upgrades[Upgrade_Name] or 1
            local Multiplier = Upgrades[Upgrade_Name].Levels[Level].Multiplier

            Cash_Multiplier *= Multiplier
        end
    end

    local Gamepasses = World:get(Player_Entity, Components.Gamepasses)

    if Gamepasses and table.find(Gamepasses, "x2 Cash") then
        Cash_Multiplier *= 2
    end

    local Rebirth = World:get(Player_Entity, Components.Rebirth)

    if Rebirth then
        Cash_Multiplier *= Rebirths[Rebirth].Multiplier
    end

    Cash_Multiplier = math.round(Cash_Multiplier * 100) / 100
    return Cash_Multiplier
end
