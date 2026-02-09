local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage:WaitForChild("Assets")

local Types = require(ReplicatedStorage.Common.Types)

type Brainrot = {
    Rarity: Types.Rarity,
    IncomePerSec: number,
}

local Brainrots: { [string]: Brainrot } = {}

return table.freeze(Brainrots)
