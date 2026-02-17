local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Network = require(ServerScriptService.Network)

--[[local Slot_Util = require(ServerScriptService.Server.Modules.Slot_Util)

local Jecs = require(ReplicatedStorage.Packages.Jecs)
local Pair = Jecs.pair]]

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local World = require(ReplicatedStorage.Common.World)

-- local Brainrot_Capacity = require(ReplicatedStorage.Common.Modules.Brainrot_Capacity)
local Ratelimits = require(ReplicatedStorage.Common.Modules.Ratelimits)
local Rebirths = require(ReplicatedStorage.Common.Modules.Rebirths)

local function Handle_Rebirth_Requests()
    for _, Player: Player in Network.Requests.Rebirth.Iter() do
        if not Ratelimits.Rebirth(Player) then
            continue
        end

        local Player_Entity = Registry.Get("Players", Player)

        if not Player_Entity then
            continue
        end

        local Character = World:get(Player_Entity, Components.Renderable)

        if not Character then
            continue
        end

        local Plot_Entity = World:target(Player_Entity, Components.Relationships.Plot)

        if not Plot_Entity then
            continue
        end

        local Plot_Model = World:get(Plot_Entity, Components.Renderable)

        if not Plot_Model then
            continue
        end

        local Rebirth = World:get(Player_Entity, Components.Rebirth)

        if not Rebirth then
            continue
        end

        local Cash = World:get(Player_Entity, Components.Cash)

        if not Cash then
            continue
        end

        --[[local Brainrot_Inventory = World:get(Player_Entity, Components.Brainrot_Inventory)

        if not Brainrot_Inventory then
            continue
        end]]

        local Next_Rebirth_Data = Rebirths[Rebirth + 1]

        if not Next_Rebirth_Data then
            Network.Notification.Fire(Player, {
                Text = "Your max rebirth",
                Type = "Error",
            })
            continue
        end

        if Cash < Next_Rebirth_Data.Requirement then
            Network.Notification.Fire(Player, {
                Text = "Requirements not met",
                Type = "Error",
            })
            continue
        end

        --[[for Brainrot_Entity in
            World:query(Components.Tags.Brainrot):with(Pair(Components.Relationships.Owner, Player_Entity))
        do
            World:delete(Brainrot_Entity)
        end

        Slot_Util.Clear_All(Brainrot_Inventory, Brainrot_Capacity)]]

        World:set(Player_Entity, Components.Cash, 0)
        World:set(Player_Entity, Components.Rebirth, Rebirth + 1)

        local Spawn = Plot_Model:FindFirstChild("Spawn") :: Part
        Character:PivotTo(Spawn.CFrame)

        Network.VFX.Rebirth.FireAll(Character)

        Network.Notification.Fire(Player, {
            Text = "You successfully rebirthed!",
            Type = "Success",
        })
    end
end

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = Handle_Rebirth_Requests,
    runConditions = {},
}
