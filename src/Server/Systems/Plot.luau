local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Map = workspace:WaitForChild("Map")
local Plots = Map:WaitForChild("Plots")

local Network = require(ServerScriptService.Network)

local Jecs = require(ReplicatedStorage.Packages.Jecs)
local Pair = Jecs.pair

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local World = require(ReplicatedStorage.Common.World)

local Util = require(ReplicatedStorage.Common.Modules.Util)

local function Create_Plot_Entities()
    for _, Model: Model in Plots:GetChildren() do
        local Plot_Number = tonumber(Model.Name)

        local Entity = World:entity()
        Registry.Define("Plots", Plot_Number, Entity)

        World:set(Entity, Components.Renderable, Model)

        World:add(Entity, Components.Tags.Plot)
        World:add(Entity, Components.Tags.Networked)
    end
end

Create_Plot_Entities()

local Plots_Without_Owner = World:query(Components.Renderable)
    :with(Components.Tags.Plot)
    :without(Pair(Components.Relationships.Owner, Jecs.Wildcard))
    :cached()

local function Cleanup_Plots()
    for _, Plot_Model: Model in Plots_Without_Owner:iter() do
        if Plot_Model:HasTag("Cleaned") then
            continue
        end

        local PlayerInfo = Plot_Model:FindFirstChild("PlayerInfo")
        local Title: TextLabel, Avatar: ImageLabel =
            PlayerInfo:FindFirstChild("Title", true), PlayerInfo:FindFirstChild("Avatar", true)

        Title.Text = ""
        Title.Visible = false

        Avatar.Image = ""
        Avatar.Visible = false

        Plot_Model:AddTag("Cleaned")
    end
end

local Players_Without_Plot = World:query(Components.Player, Components.Renderable)
    :without(Pair(Components.Relationships.Plot, Jecs.Wildcard))
    :cached()

local function Assign_Plots()
    for Player_Entity, Player: Player, Character: Model in Players_Without_Plot:iter() do
        for Plot_Number = 1, 6 do
            local Plot_Entity = Registry.Get("Plots", Plot_Number)

            if World:target(Plot_Entity, Components.Relationships.Owner) ~= nil then
                continue
            end

            local Plot_Model = World:get(Plot_Entity, Components.Renderable) :: Model

            task.spawn(function()
                local PlayerInfo = Plot_Model:FindFirstChild("PlayerInfo")
                local Title: TextLabel, Avatar: ImageLabel =
                    PlayerInfo:FindFirstChild("Title", true), PlayerInfo:FindFirstChild("Avatar", true)

                local Info = Util.Get_Player_Info(Player.UserId)

                Title.Text = Info.Name .. "'s Plot"
                Avatar.Image = Info.Image

                Title.Visible = true
                Avatar.Visible = true
            end)

            local Spawn = Plot_Model:FindFirstChild("Spawn") :: Part
            Character:PivotTo(Spawn.CFrame)

            World:add(Player_Entity, Pair(Components.Relationships.Plot, Plot_Entity))

            World:add(Plot_Entity, Pair(Components.Relationships.Owner, Player_Entity))

            Network.DataChanged.Plot_Assigned.Fire(Player, Plot_Model)

            break
        end
    end
end

return {
    name = script.Name,
    phase = Phases.Runservice.PreUpdate,
    system = function()
        Cleanup_Plots()

        Assign_Plots()
    end,
}
