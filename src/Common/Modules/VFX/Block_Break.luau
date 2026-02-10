local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage:WaitForChild("Assets")

local VFX = Assets:WaitForChild("VFX")
local Block_Break = VFX:WaitForChild("Block_Break") :: Attachment

return function(CF: CFrame)
    local Part = Instance.new("Part")
    Part.Transparency = 1
    Part.Size = Vector3.new(1, 1, 1)
    Part.CFrame = CF
    Part.CanCollide = false
    Part.Anchored = true
    Part.Parent = workspace:FindFirstChild("Debris")

    local Attachment = Block_Break:Clone()
    Attachment.Parent = Part

    for _, Inst: ParticleEmitter in Attachment:GetDescendants() do
        if Inst:IsA("ParticleEmitter") then
            local EmitCount = Inst:GetAttribute("EmitCount") or 1

            Inst:Emit(EmitCount)
        end
    end

    Debris:AddItem(Part, 3)
end
