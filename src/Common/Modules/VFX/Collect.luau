local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Assets = ReplicatedStorage:WaitForChild("Assets")

local Sounds = Assets:WaitForChild("Sounds")

local World_Sounds = Sounds:WaitForChild("World")
local Collect_Sound = World_Sounds:WaitForChild("Collect") :: Sound

local Highlight_Tween_Info = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

return function(Part: Part)
    local Sound = Collect_Sound:Clone()
    Sound.PlayOnRemove = true
    Sound.Parent = Part
    Sound:Destroy()

    local Highlight = Instance.new("Highlight")
    Highlight.FillColor = Color3.fromRGB(255, 255, 255)
    Highlight.FillTransparency = 0
    Highlight.OutlineTransparency = 1
    Highlight.DepthMode = Enum.HighlightDepthMode.Occluded
    Highlight.Parent = Part

    task.wait(0.2)

    TweenService:Create(Highlight, Highlight_Tween_Info, { FillTransparency = 1 }):Play()

    task.wait(0.5)

    Highlight:Destroy()
end
