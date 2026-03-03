local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage:WaitForChild("Assets")

local VFX = Assets:WaitForChild("VFX")
local Food_Pump = VFX:WaitForChild("Food_Pump") :: Attachment

return function(Part: Part)
    local Attachment = Food_Pump:Clone()
    Attachment.Parent = Part

    for _, Inst: ParticleEmitter in Attachment:GetDescendants() do
        if Inst:IsA("ParticleEmitter") then
            local EmitCount = Inst:GetAttribute("EmitCount") or 1
            Inst:Emit(EmitCount)
        end
    end

    Debris:AddItem(Attachment, 1)
end
