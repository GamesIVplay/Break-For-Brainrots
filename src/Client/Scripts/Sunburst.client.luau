local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local ROTATION_SPEED = 90
local Active = {}

local function Start(Instance)
    if not Instance:IsA("ImageLabel") then
        return
    end
    if not CollectionService:HasTag(Instance, "Sunburst") then
        return
    end
    if Active[Instance] then
        return
    end

    Active[Instance] = true
end

RunService.RenderStepped:Connect(function(DeltaTime)
    for Image in Active do
        if Image.Parent then
            Image.Rotation = (Image.Rotation + ROTATION_SPEED * DeltaTime) % 360
        else
            Active[Image] = nil
        end
    end
end)

for _, Instance in workspace:GetDescendants() do
    Start(Instance)
end

workspace.DescendantAdded:Connect(Start)
CollectionService:GetInstanceAddedSignal("Sunburst"):Connect(Start)
