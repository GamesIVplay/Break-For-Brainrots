local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Phases = require(ReplicatedStorage.Common.Phases)

local function New_Folder(Name: string, Parent: Instance)
    local Folder = Instance.new("Folder")
    Folder.Name = Name
    Folder.Parent = Parent
end

return {
    name = script.Name,
    phase = Phases.InitPhases.PreInit,
    system = function()
        New_Folder("Characters", workspace)
        New_Folder("Blocks", workspace)
        New_Folder("Brainrots", workspace)
        New_Folder("Debris", workspace)
        New_Folder("Temp", ReplicatedStorage)
    end,
    runConditions = {},
}
