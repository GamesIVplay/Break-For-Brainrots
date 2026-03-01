local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--local TweenService = game:GetService("TweenService")

local Assets = ReplicatedStorage:WaitForChild("Assets")

local VFX = Assets:WaitForChild("VFX")
local Collect_VFX = VFX:WaitForChild("Collect") :: Attachment

local Sounds = Assets:WaitForChild("Sounds")

local World_Sounds = Sounds:WaitForChild("World")
local Collect_Sound = World_Sounds:WaitForChild("Collect") :: Sound

return function(Part: Part)
    local Sound = Collect_Sound:Clone()
    Sound.PlayOnRemove = true
    Sound.Parent = Part
    Sound:Destroy()

    local VFX = Collect_VFX:Clone()
    VFX.Parent = Part

    for _, Inst: ParticleEmitter in VFX:GetDescendants() do
        if Inst:IsA("ParticleEmitter") then
            local EmitCount = Inst:GetAttribute("EmitCount") or 1

            Inst:Emit(EmitCount)
        end
    end

    Debris:AddItem(VFX, 3)
end
