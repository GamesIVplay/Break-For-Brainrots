local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage:WaitForChild("Assets")

local Sounds = Assets:WaitForChild("Sounds")

local World_Sounds = Sounds:WaitForChild("World")
local Block_Spawn_Sound = World_Sounds:WaitForChild("Block_Spawn") :: Sound

local Util = require(ReplicatedStorage.Common.Modules.Util)

local BOUNCE_TIME = 0.08
local Spawn_Tween_Info = TweenInfo.new(BOUNCE_TIME, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

return function(Block_Model: Model)
    local Sound = Block_Spawn_Sound:Clone()
    Sound.PlayOnRemove = true
    Sound.Parent = Block_Model.PrimaryPart
    Sound:Destroy()

    Util.Tween_Model_Scale(1, 0.3, Spawn_Tween_Info, Block_Model)

    task.wait(BOUNCE_TIME)

    if not Block_Model:IsDescendantOf(workspace) then
        return
    end

    Util.Tween_Model_Scale(0.8, 1, Spawn_Tween_Info, Block_Model)
end
