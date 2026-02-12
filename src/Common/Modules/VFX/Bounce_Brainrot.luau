local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")

local World_Sounds = Sounds:WaitForChild("World")
local Bounce_Sound = World_Sounds:WaitForChild("Bounce") :: Sound

local Util = require(ReplicatedStorage.Common.Modules.Util)

local BOUNCE_TIME = 0.15
local Bounce_Tween_Info = TweenInfo.new(BOUNCE_TIME, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

return function(Brainrot_Model: Model)
    local Sound = Bounce_Sound:Clone()
    Sound.PlayOnRemove = true
    Sound.Parent = Brainrot_Model.PrimaryPart
    Sound:Destroy()

    local Original_Scale = Brainrot_Model:GetScale()
    local Target_Scale = Original_Scale / 1.5

    Util.Tween_Model_Scale(Original_Scale, Target_Scale, Bounce_Tween_Info, Brainrot_Model)

    task.wait(BOUNCE_TIME)

    if not Brainrot_Model:IsDescendantOf(workspace) then
        return
    end

    Util.Tween_Model_Scale(Target_Scale, Original_Scale, Bounce_Tween_Info, Brainrot_Model)
end
