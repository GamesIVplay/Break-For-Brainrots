local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Phases = require(ReplicatedStorage.Common.Phases)

local function New_Folder(Name: string)
    local Folder = Instance.new("Folder")
    Folder.Name = Name
    Folder.Parent = workspace
end

return {
    name = script.Name,
    phase = Phases.InitPhases.PreInit,
    system = function()
        New_Folder("Characters")
        New_Folder("Blocks")
        New_Folder("Brainrots")
    end,
    runConditions = {},
}
