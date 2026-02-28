local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Brainrot_Models = Assets:WaitForChild("Brainrots")

local VFX = Assets:WaitForChild("VFX")
local Secondary_Mutations_VFX = VFX:WaitForChild("Secondary_Mutations")

local Weight = require(ReplicatedStorage.Common.Modules.Weight)

return function(
    Brainrot_Name: string,
    Primary_Mutation: string?,
    Secondary_Mutations: { string },
    Brainrot_Weight: number
): (Model, CFrame, Vector3)
    local MutationFolder = Brainrot_Models:FindFirstChild(Primary_Mutation or "Normal") :: Folder
    local Brainrot_Model = MutationFolder:FindFirstChild(Brainrot_Name):Clone() :: Model

    local Scale = Weight.GetScale(Brainrot_Weight, 0.3, 3)

    Brainrot_Model:ScaleTo(Scale)

    local Extents = Brainrot_Model:GetExtentsSize()
    local Offset = CFrame.new(Vector3.new(0, Extents.Y / 2, 0))

    for _, Mutation_Name in Secondary_Mutations do
        local Part = Secondary_Mutations_VFX:FindFirstChild(Mutation_Name):Clone() :: Part
        Part.Parent = Brainrot_Model
        Part.CFrame = Brainrot_Model.PrimaryPart.CFrame

        local Weld = Instance.new("WeldConstraint")
        Weld.Part0 = Brainrot_Model.PrimaryPart
        Weld.Part1 = Part
        Weld.Parent = Part
    end

    return Brainrot_Model, Offset, Extents
end
