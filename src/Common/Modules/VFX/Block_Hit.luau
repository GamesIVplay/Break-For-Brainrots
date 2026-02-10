local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage:WaitForChild("Assets")

local Highlights = Assets:WaitForChild("Highlights")
local Block_Hit_Highlight = Highlights:WaitForChild("Block_Hit") :: Highlight

local Sounds = Assets:WaitForChild("Sounds")

local World_Sounds = Sounds:WaitForChild("World")
local Block_Hit_Sound = World_Sounds:WaitForChild("Block_Hit") :: Sound

local Util = require(ReplicatedStorage.Common.Modules.Util)

local BOUNCE_TIME = 0.15
local Spawn_Tween_Info = TweenInfo.new(BOUNCE_TIME, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

return function(Block_Model: Model)
    local Sound = Block_Hit_Sound:Clone()
    Sound.PlayOnRemove = true
    Sound.Parent = Block_Model.PrimaryPart
    Sound:Destroy()

    task.spawn(function()
        Util.Tween_Model_Scale(1, 0.5, Spawn_Tween_Info, Block_Model)
        local Highlight = Block_Hit_Highlight:Clone()
        Highlight.Parent = Block_Model

        task.wait(BOUNCE_TIME)

        if not Block_Model:IsDescendantOf(workspace) then
            return
        end

        Highlight:Destroy()
        Util.Tween_Model_Scale(0.8, 1, Spawn_Tween_Info, Block_Model)
    end)
end
