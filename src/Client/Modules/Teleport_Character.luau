local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Components = require(ReplicatedStorage.Common.Components)
local Registry = require(ReplicatedStorage.Common.Registry)
local World = require(ReplicatedStorage.Common.World)

return function(TargetCFrame: CFrame)
    local Local_Entity = Registry.Get("Players", "Local")

    local Local_Character = World:get(Local_Entity, Components.Renderable) :: Model?

    if not Local_Character then
        return
    end

    Local_Character:PivotTo(TargetCFrame)
end
