local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Components = require(ReplicatedStorage.Common.Components)
local World = require(ReplicatedStorage.Common.World)

return function(context, eventName: string, duration: number)
    local Active_Events = World:get(Components.Singletons.Active_Events, Components.Singletons.Active_Events)

    Active_Events[eventName] = nil
end
