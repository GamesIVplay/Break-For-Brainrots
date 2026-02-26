local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local World = require(ReplicatedStorage.Common.World)

local VFX_CLASSES = {
    Beam = true,
    ParticleEmitter = true,
    Trail = true,
    Smoke = true,
    Fire = true,
    Sparkles = true,
    Highlight = true,
    PointLight = true,
    SpotLight = true,
    SurfaceLight = true,
    Explosion = true,
    Sound = true,
}

local function ProcessModel(Brainrot_Model: Model, Local_UserId: number)
    if not Brainrot_Model:IsDescendantOf(workspace:FindFirstChild("Brainrots")) then
        return
    end

    local Owner = Brainrot_Model:GetAttribute("Owner")

    if Owner == Local_UserId then
        Brainrot_Model:AddTag("Idle")
        return
    end

    local function RemoveIfVFX(inst)
        if VFX_CLASSES[inst.ClassName] then
            inst:Destroy()
        end
    end

    for _, inst in Brainrot_Model:GetDescendants() do
        RemoveIfVFX(inst)
    end

    Brainrot_Model.DescendantAdded:Connect(RemoveIfVFX)
end

return {
    name = script.Name,
    phase = Phases.InitPhases.Init,
    system = function()
        local Local_Entity = Registry.Get("Players", "Local")
        local Local_Player = World:get(Local_Entity, Components.Player)

        for _, Model in CollectionService:GetTagged("Brainrot") do
            ProcessModel(Model, Local_Player.UserId)
        end

        CollectionService:GetInstanceAddedSignal("Brainrot"):Connect(function(Model)
            ProcessModel(Model, Local_Player.UserId)
        end)
    end,
    runConditions = {},
}
