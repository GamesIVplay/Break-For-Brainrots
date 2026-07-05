local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage:WaitForChild("Assets")

local VFX = Assets:WaitForChild("VFX")
local Confetti_VFX = VFX:WaitForChild("Confetti") :: Attachment

local Sounds = Assets:WaitForChild("Sounds")

local World_Sounds = Sounds:WaitForChild("World")
local Confetti_Sound = World_Sounds:WaitForChild("Confetti") :: Sound

return function(Character: Model)
    local Root_Part = Character:FindFirstChild("HumanoidRootPart")

    if not Root_Part then
        return
    end

    local Sound = Confetti_Sound:Clone()
    Sound.Parent = Root_Part
    Sound.PlayOnRemove = true
    Sound:Destroy()

    local Confetti_Attachment = Confetti_VFX:Clone()
    Confetti_Attachment.Parent = Root_Part

    for _, Inst: ParticleEmitter in Confetti_Attachment:GetDescendants() do
        if Inst:IsA("ParticleEmitter") then
            local EmitCount = Inst:GetAttribute("EmitCount") or 1

            Inst:Emit(EmitCount)
        end
    end

    Debris:AddItem(Confetti_Attachment, 5)
end
