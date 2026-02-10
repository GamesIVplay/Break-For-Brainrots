local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Brainrot_Models = Assets:WaitForChild("Brainrots")

local Weight = require(ReplicatedStorage.Common.Modules.Weight)

return function(
    Brainrot_Name: string,
    Primary_Mutation: string?,
    Secondary_Mutations: { string },
    Brainrot_Weight: number
): Model
    print(Primary_Mutation)
    local MutationFolder = Brainrot_Models:FindFirstChild(Primary_Mutation or "Normal") :: Folder
    local Brainrot_Model = MutationFolder:FindFirstChild(Brainrot_Name):Clone() :: Model

    local Scale = Weight.GetScale(Brainrot_Weight, 0.1, 5)

    Brainrot_Model:ScaleTo(Scale)

    return Brainrot_Model
end
