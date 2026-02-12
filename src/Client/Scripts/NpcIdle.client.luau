if not game:IsLoaded() then
    game.Loaded:Wait()
end

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NpcIdle = require(ReplicatedStorage.Common.Modules.NpcIdle)

local PRESETS = {
    -- Default / Brainrot
    Default = {
        Distance = 0.6,
        Duration = 2.25,
        BobHeight = 0.15,
        BobSpeed = 1.25,
        GlideHeight = 0.45,
        GlideSpeed = 3.5,
        WagSpeed = 1.1,
        YawAngleDegrees = 12,
        RollAngleDegrees = 6,
    },

    -- Skip / Break
    Tiny = {
        Distance = 0.3,
        Duration = 4.0,
        BobHeight = 0.01,
        BobSpeed = 0.4,
        GlideHeight = 0.02,
        GlideSpeed = 0.8,
        WagSpeed = 0.2,
        YawAngleDegrees = 1,
        RollAngleDegrees = 0.5,
    },

    -- Brainrot but less movement
    DecorBrainrot = {
        Distance = 0.15,
        Duration = 2.25,
        BobHeight = 0.15,
        BobSpeed = 1.25,
        GlideHeight = 0.45,
        GlideSpeed = 3.5,
        WagSpeed = 1.1,
        YawAngleDegrees = 12,
        RollAngleDegrees = 6,
    },
}

local function Start(Inst: Instance)
    if not Inst:IsA("Model") or not CollectionService:HasTag(Inst, "Idle") then
        return
    end

    local IdlePreset = Inst:GetAttribute("IdlePreset") or "Default"
    local config = PRESETS[IdlePreset] or PRESETS.Default

    NpcIdle.Start(Inst, config)
end

for _, Inst in workspace:GetDescendants() do
    Start(Inst)
end

workspace.DescendantAdded:Connect(Start)
CollectionService:GetInstanceAddedSignal("Idle"):Connect(Start)
