local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")

local function Start(ImageLabel: ImageLabel)
    if not ImageLabel:IsA("ImageLabel") or not CollectionService:HasTag(ImageLabel, "ImageFloat") then
        return
    end

    local Default_Position = ImageLabel.Position

    TweenService:Create(ImageLabel, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
        Position = Default_Position + UDim2.fromOffset(0, Default_Position.Y.Offset - math.random(7, 12)),
    }):Play()
end

for _, Inst in workspace:GetDescendants() do
    Start(Inst)
end

workspace.DescendantAdded:Connect(Start)
CollectionService:GetInstanceAddedSignal("ImageFloat"):Connect(Start)
