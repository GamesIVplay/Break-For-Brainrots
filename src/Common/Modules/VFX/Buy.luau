local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage:WaitForChild("Assets")

local VFX = Assets:WaitForChild("VFX")
local Buy_VFX = VFX:WaitForChild("Buy") :: Attachment

local Highlights = Assets:WaitForChild("Highlights")
local Buy_Highlight = Highlights:WaitForChild("Buy") :: Highlight

local Sounds = Assets:WaitForChild("Sounds")

local World_Sounds = Sounds:WaitForChild("World")
local Buy_Sound = World_Sounds:WaitForChild("Buy") :: Sound

return function(Character: Model)
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
        or Character:FindFirstChild("RootPart")
        or Character.PrimaryPart

    if not RootPart then
        return
    end

    local Sound = Buy_Sound:Clone()
    Sound.PlayOnRemove = true
    Sound.Parent = RootPart
    Sound:Destroy()

    local Highlight = Buy_Highlight:Clone()
    Highlight.Parent = Character

    Debris:AddItem(Highlight, 0.15)

    local VFX = Buy_VFX:Clone()
    VFX.Parent = RootPart

    for _, Inst: ParticleEmitter in VFX:GetDescendants() do
        if Inst:IsA("ParticleEmitter") then
            local EmitCount = Inst:GetAttribute("EmitCount") or 1

            Inst:Emit(EmitCount)
        end
    end

    Debris:AddItem(VFX, 5)
end
