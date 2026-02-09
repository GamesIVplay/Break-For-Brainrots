local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Local_Player = Players.LocalPlayer

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local World = require(ReplicatedStorage.Common.World)

local AnimPlayer = require(ReplicatedStorage.Common.Modules.AnimPlayer)
local Types = require(ReplicatedStorage.Common.Types)

local function Setup_Character(Local_Entity: Types.Entity, Character: Model)
    local Humanoid = Character:WaitForChild("Humanoid")

    local Animator = Humanoid:WaitForChild("Animator")

    AnimPlayer.Load(Animator)

    World:set(Local_Entity, Components.Renderable, Character)
end

return {
    name = script.Name,
    phase = Phases.InitPhases.PreInit,
    system = function()
        local Local_Entity = World:entity()
        Registry.Define("Players", "Local", Local_Entity)

        World:set(Local_Entity, Components.Player, Local_Player)

        World:set(Local_Entity, Components.Name, Local_Player.Name)
        World:set(Local_Entity, Components.Cash, 0)
        World:set(Local_Entity, Components.Opens, 0)
        World:set(Local_Entity, Components.Gamepasses, {})
        World:set(Local_Entity, Components.Stock, {})
        World:set(Local_Entity, Components.Last_Restock, 0)

        if Local_Player.Character then
            task.spawn(function()
                Setup_Character(Local_Entity, Local_Player.Character)
            end)
        end

        Local_Player.CharacterAdded:Connect(function(Character)
            task.spawn(function()
                Setup_Character(Local_Entity, Local_Player.Character)
            end)
        end)

        Local_Player.CharacterRemoving:Connect(function()
            World:remove(Local_Entity, Components.Renderable)
        end)
    end,
    runConditions = {},
}
