if not game:IsLoaded() then
    game.Loaded:Wait()
end

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NpcIdle = require(ReplicatedStorage.Common.Modules.NpcIdle)

local function Start(Inst: Instance)
    if not Inst:IsA("Model") or not CollectionService:HasTag(Inst, "NpcIdle") then
        return
    end

    NpcIdle.Start(Inst, {
        Distance = 0.6,
        Duration = 2.25,
        BobHeight = 0.15,
        BobSpeed = 1.25,
        GlideHeight = 0.45,
        GlideSpeed = 3.5,
        WagSpeed = 1.1,
        YawAngleDegrees = 12,
        RollAngleDegrees = 6,
    })
end

for _, Inst in workspace:GetDescendants() do
    Start(Inst)
end

workspace.DescendantAdded:Connect(function(Inst)
    Start(Inst)
end)
