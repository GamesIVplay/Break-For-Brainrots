local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CmdrClient = require(ReplicatedStorage:WaitForChild("CmdrClient"))

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local World = require(ReplicatedStorage.Common.World)

return {
    name = script.Name,
    phase = Phases.InitPhases.PreInit,
    system = function()
        CmdrClient:SetActivationKeys({ Enum.KeyCode.F2 })
    end,
    runConditions = {},
}
