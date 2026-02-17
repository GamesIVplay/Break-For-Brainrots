local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Cmdr = require(ReplicatedStorage.Packages.cmdr)

local Phases = require(ReplicatedStorage.Common.Phases)

return {
    name = script.Name,
    phase = Phases.InitPhases.PreInit,
    system = function()
        Cmdr:RegisterCommandsIn(script.Commands)
        Cmdr:RegisterTypesIn(script.Types)
        Cmdr:RegisterHooksIn(script.Hooks)
    end,
    runConditions = {},
}
