local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Jecs = require(ReplicatedStorage.Packages.Jecs)
local Pair = Jecs.pair

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Types = require(ReplicatedStorage.Common.Types)
local World = require(ReplicatedStorage.Common.World)

local Food = require(ReplicatedStorage.Common.Modules.Food)

local Food_Spawner_Query = World:query(Components.Renderable)
    :with(Components.Tags.Plot, Pair(Components.Relationships.Owner, Jecs.Wildcard))
    :without(Pair(Components.Relationships.Food, Jecs.Wildcard))
    :cached()

local function Spawn_Foods()
    for Plot_Entity: Types.Entity, Plot_Model: Model in Food_Spawner_Query:iter() do
        local Food_Spawn = Plot_Model:FindFirstChild("Food_Spawn", true) :: Attachment

        local Food_Data = Food.Get_Data_From_Xp(0)

        local Food_Model = Food_Data.Model:Clone()
        Food_Model:ScaleTo(Food_Data.Scale)
        Food_Model:PivotTo(Food_Spawn.WorldCFrame)
        Food_Model:SetAttribute("IdlePreset", "Food")
        Food_Model:AddTag("Idle")
        Food_Model.Parent = workspace:FindFirstChild("Foods")

        local Food_Entity = World:entity()

        World:set(Food_Entity, Components.Name, Food_Data.Name)
        World:set(Food_Entity, Components.Renderable, Food_Model)
        World:set(Food_Entity, Components.Experience, 0)

        World:add(Food_Entity, Components.Tags.Food)
        World:add(Food_Entity, Components.Tags.Networked)
        World:add(Food_Entity, Pair(Components.Relationships.Owner, Plot_Entity))

        World:add(Plot_Entity, Pair(Components.Relationships.Food, Food_Entity))

        World:set(Food_Entity, Components.Cleanup, function()
            Food_Model:Destroy()
        end)
    end
end

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = Spawn_Foods,
    runConditions = {},
}
