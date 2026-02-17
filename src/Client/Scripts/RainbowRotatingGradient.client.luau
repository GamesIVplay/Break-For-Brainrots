local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local TAG = "RainbowRotatingGradient"

local W = math.pi / 12
local NUM = 15
local SPEED = math.pi / 40

local Active = {}

local function Start(Instance)
    if not Instance:IsA("UIGradient") then
        return
    end
    if not CollectionService:HasTag(Instance, TAG) then
        return
    end
    if Active[Instance] then
        return
    end

    Active[Instance] = {
        Counter = 0,
        Frames = 0,
    }
end

RunService.Heartbeat:Connect(function()
    for Gradient, State in Active do
        if not Gradient.Parent then
            Active[Gradient] = nil
            continue
        end

        State.Frames += 1
        if State.Frames % 2 ~= 0 then
            continue
        end

        local ColorSequenceTable = {}

        for i = 0, NUM do
            local Color = Color3.fromRGB(
                127 * math.sin(W * i + State.Counter) + 128,
                127 * math.sin(W * i + 2 * math.pi / 3 + State.Counter) + 128,
                127 * math.sin(W * i + 4 * math.pi / 3 + State.Counter) + 128
            )

            ColorSequenceTable[i + 1] = ColorSequenceKeypoint.new(i / NUM, Color)
        end

        Gradient.Color = ColorSequence.new(ColorSequenceTable)

        State.Counter -= SPEED
        if State.Counter <= -math.pi * 2 then
            State.Counter = 0
        end

        if State.Frames >= 1000 then
            State.Frames = 0
        end
    end
end)

for _, Instance in workspace:GetDescendants() do
    Start(Instance)
end

workspace.DescendantAdded:Connect(Start)
CollectionService:GetInstanceAddedSignal(TAG):Connect(Start)
