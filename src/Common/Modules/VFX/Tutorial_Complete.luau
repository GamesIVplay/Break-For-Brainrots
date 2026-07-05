local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage:WaitForChild("Assets")

local VFX = Assets:WaitForChild("VFX")
local Tutorial_Complete_VFX = VFX:WaitForChild("Tutorial_Complete") :: Attachment

local Sounds = Assets:WaitForChild("Sounds")

local World_Sounds = Sounds:WaitForChild("World")
local Tutorial_Complete_Sound = World_Sounds:WaitForChild("Tutorial_Complete") :: Sound

return function(Character: Model)
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
        or Character:FindFirstChild("RootPart")
        or Character.PrimaryPart

    if not RootPart then
        return
    end

    local Sound = Tutorial_Complete_Sound:Clone()
    Sound.PlayOnRemove = true
    Sound.Parent = RootPart
    Sound:Destroy()

    local Tutorial_Complete_Attachment = Tutorial_Complete_VFX:Clone()
    Tutorial_Complete_Attachment.Parent = RootPart

    for _, Inst: ParticleEmitter in Tutorial_Complete_Attachment:GetDescendants() do
        if Inst:IsA("ParticleEmitter") then
            local EmitCount = Inst:GetAttribute("EmitCount") or 1

            Inst:Emit(EmitCount)
        end
    end

    Debris:AddItem(Tutorial_Complete_Attachment, 5)
end
