local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage:WaitForChild("Assets")

local VFX = Assets:WaitForChild("VFX")
local Rebirth_VFX = VFX:WaitForChild("Rebirth") :: Attachment

local Highlights = Assets:WaitForChild("Highlights")
local Rebirth_Highlight = Highlights:WaitForChild("Rebirth") :: Highlight

local Sounds = Assets:WaitForChild("Sounds")

local World_Sounds = Sounds:WaitForChild("World")
local Rebirth_Sound = World_Sounds:WaitForChild("Rebirth") :: Sound

return function(Character: Model)
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
        or Character:FindFirstChild("RootPart")
        or Character.PrimaryPart

    if not RootPart then
        return
    end

    local Sound = Rebirth_Sound:Clone()
    Sound.PlayOnRemove = true
    Sound.Parent = RootPart
    Sound:Destroy()

    local Highlight = Rebirth_Highlight:Clone()
    Highlight.Parent = Character

    Debris:AddItem(Highlight, 0.15)

    local Rebirth_Attachment = Rebirth_VFX:Clone()
    Rebirth_Attachment.Parent = RootPart

    for _, Inst: ParticleEmitter in Rebirth_Attachment:GetDescendants() do
        if Inst:IsA("ParticleEmitter") then
            local EmitCount = Inst:GetAttribute("EmitCount") or 1

            Inst:Emit(EmitCount)
        end
    end

    Debris:AddItem(Rebirth_Attachment, 5)
end
