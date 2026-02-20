local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local World = require(ReplicatedStorage.Common.World)

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = function()
        local Local_Entity = Registry.Get("Players", "Local")

        local Local_Player = World:get(Local_Entity, Components.Player)

        for _, Brainrot_Model in CollectionService:GetTagged("Pending_VFX_Removal") do
            if Brainrot_Model:GetAttribute("Owner") == Local_Player.UserId then
                Brainrot_Model:RemoveTag("Pending_VFX_Removal")
                continue
            end

            for _, Inst in Brainrot_Model:GetDescendants() do
                if Inst:IsA("Beam") or Inst:IsA("ParticleEmitter") then
                    Inst:Destroy()
                end
            end

            Brainrot_Model:RemoveTag("Pending_VFX_Removal")
        end
    end,
    runConditions = {},
}
