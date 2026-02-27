local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Components = require(ReplicatedStorage.Common.Components)
local Types = require(ReplicatedStorage.Common.Types)
local World = require(ReplicatedStorage.Common.World)

local Brainrots = require(ReplicatedStorage.Common.Modules.Brainrots)
local Primary_Mutations = require(ReplicatedStorage.Common.Modules.Primary_Mutations)
local Rebirths = require(ReplicatedStorage.Common.Modules.Rebirths)
local Secondary_Mutations = require(ReplicatedStorage.Common.Modules.Secondary_Mutations)
local Upgrades = require(ReplicatedStorage.Common.Modules.Upgrades)
local Weight = require(ReplicatedStorage.Common.Modules.Weight)

local BRAINROT_CAPACITY = 300
local BRAINROT_OFFSET = Vector3.new(0, 0.5, 0)

export type Brainrot_Data = {
    Brainrot_Name: string,
    Primary_Mutation: string?,
    Secondary_Mutations: { string },
    Weight: number,
}

local Stat_Calculator = {}

local function Get_Base_With_Percent(Base: number, Total_Percent: number)
    return Base + (Total_Percent / 100)
end

function Stat_Calculator.Get_Luck(Player_Entity: Types.Entity)
    local Base = 1
    local Total_Percent = 0

    local Active_Events = World:get(Components.Singletons.Active_Events, Components.Singletons.Active_Events)

    for _, Data in Active_Events do
        Total_Percent += Data.Luck_Bonus
    end

    if not World:contains(Player_Entity) or not World:has(Player_Entity, Components.Player) then
        return Get_Base_With_Percent(Base, Total_Percent)
    end

    local Player_Upgrades = World:get(Player_Entity, Components.Upgrades)

    if Player_Upgrades then
        for _, Upgrade_Name in { "Luck Boost", "Better Luck" } do
            local Level = Player_Upgrades[Upgrade_Name] or 1
            Total_Percent += Upgrades[Upgrade_Name].Levels[Level].Percent
        end
    end

    local Final = Get_Base_With_Percent(Base, Total_Percent)

    local Gamepasses = World:get(Player_Entity, Components.Gamepasses)
    if Gamepasses and table.find(Gamepasses, "x2 Luck") then
        Final *= 2
    end

    return math.round(Final * 100) / 100
end

function Stat_Calculator.Get_Mutation_Luck(Player_Entity: Types.Entity)
    local Base = 1
    local Total_Percent = 0

    if not World:contains(Player_Entity) or not World:has(Player_Entity, Components.Player) then
        return Base
    end

    local Player_Upgrades = World:get(Player_Entity, Components.Upgrades)

    if Player_Upgrades then
        local Level = Player_Upgrades["Mutation Luck"] or 1
        Total_Percent += Upgrades["Mutation Luck"].Levels[Level].Percent
    end

    local Final = Get_Base_With_Percent(Base, Total_Percent)

    return math.round(Final * 100) / 100
end

function Stat_Calculator.Get_Cash_Multiplier(Player_Entity: Types.Entity)
    local Base = 1
    local Total_Percent = 0

    if not World:contains(Player_Entity) or not World:has(Player_Entity, Components.Player) then
        return Base
    end

    local Player_Upgrades = World:get(Player_Entity, Components.Upgrades)

    if Player_Upgrades then
        local Level = Player_Upgrades["Cash Boost"] or 1
        Total_Percent += Upgrades["Cash Boost"].Levels[Level].Percent
    end

    local Friend_Boost = World:get(Player_Entity, Components.Friend_Boost)

    if Friend_Boost then
        Total_Percent += Friend_Boost
    end

    local Final = Get_Base_With_Percent(Base, Total_Percent)

    local Gamepasses = World:get(Player_Entity, Components.Gamepasses)
    if Gamepasses and table.find(Gamepasses, "x2 Cash") then
        Final *= 2
    end

    local Rebirth = World:get(Player_Entity, Components.Rebirth)
    if Rebirth then
        Final *= Rebirths[Rebirth].Multiplier
    end

    return math.round(Final * 100) / 100
end

function Stat_Calculator.Calculate_Income_Per_Sec(Data: Brainrot_Data): number
    local Income_Per_Sec = Brainrots[Data.Brainrot_Name].IncomePerSec

    if Data.Primary_Mutation then
        Income_Per_Sec *= Primary_Mutations[Data.Primary_Mutation].Cash_Multiplier
    end

    for _, Mutation_Name in Data.Secondary_Mutations do
        Income_Per_Sec *= Secondary_Mutations[Mutation_Name].Cash_Multiplier
    end

    Income_Per_Sec *= Weight.Get_Cash_Multiplier(Data.Weight)

    return math.max(1, math.round(Income_Per_Sec))
end

function Stat_Calculator.Calculate_Sell_Price(Data: Brainrot_Data): number
    local Sell_Price = Stat_Calculator.Calculate_Income_Per_Sec(Data)
    Sell_Price = math.round(Sell_Price * 15)

    return math.max(1, Sell_Price)
end

function Stat_Calculator.Get_Brainrot_Capacity()
    return BRAINROT_CAPACITY
end

function Stat_Calculator.Get_Brainrot_Offset()
    return BRAINROT_OFFSET
end

return table.freeze(Stat_Calculator)
