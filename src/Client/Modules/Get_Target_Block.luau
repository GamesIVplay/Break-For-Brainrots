local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Components = require(ReplicatedStorage.Common.Components)
local Registry = require(ReplicatedStorage.Common.Registry)
local World = require(ReplicatedStorage.Common.World)

return function()
    local Local_Entity = Registry.Get("Players", "Local")
    local Plot_Model = World:get(Local_Entity, Components.Plot_Model)

    if not Plot_Model then
        return
    end

    local Target_Block: Model?

    for _, Model in CollectionService:GetTagged(Plot_Model.Name .. "_Block") do
        Target_Block = Model
    end

    return Target_Block
end
