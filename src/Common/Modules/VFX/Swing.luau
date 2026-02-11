local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage:WaitForChild("Assets")

local Sounds = Assets:WaitForChild("Sounds")

local World_Sounds = Sounds:WaitForChild("World")
local Swing_Sound = World_Sounds:WaitForChild("Swing") :: Sound

return function(Character: Model)
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
        or Character:FindFirstChild("RootPart")
        or Character.PrimaryPart

    if not RootPart then
        return
    end

    local Sound = Swing_Sound:Clone()
    Sound.PlayOnRemove = true
    Sound.Parent = RootPart
    Sound:Destroy()
end
