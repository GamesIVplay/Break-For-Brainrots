local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Planck = require(ReplicatedStorage.Packages.Planck)
local PlanckRunService = require(ReplicatedStorage.Packages.PlanckRunService)

local Phases = {
    Runservice = PlanckRunService.Phases,
    InitPhases = {
        PreInit = Planck.Phase.PreStartup,
        Init = Planck.Phase.Startup,
        PostInit = Planck.Phase.PostStartup,
    },
}

return table.freeze(Phases)
