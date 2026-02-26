local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CmdrClient = require(ReplicatedStorage:WaitForChild("CmdrClient"))

local Phases = require(ReplicatedStorage.Common.Phases)

return {
    name = script.Name,
    phase = Phases.InitPhases.PreInit,
    system = function()
        CmdrClient:SetActivationKeys({ Enum.KeyCode.F2 })
    end,
    runConditions = {},
}
