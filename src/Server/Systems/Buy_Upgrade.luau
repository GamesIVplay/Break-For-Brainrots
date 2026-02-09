local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Network = require(ServerScriptService.Network)

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local World = require(ReplicatedStorage.Common.World)

local Upgrades = require(ReplicatedStorage.Common.Modules.Upgrades)

local function Handle_Upgrade_Purchase_Requests()
    for _, Player: Player, Upgrade_Name: string in Network.Requests.Buy_Upgrade.Iter() do
        local Player_Entity = Registry.Get("Players", Player)

        if not Player_Entity then
            continue
        end

        local Character = World:get(Player_Entity, Components.Renderable)

        if not Character then
            continue
        end

        local Upgrade_Data = Upgrades[Upgrade_Name]

        if not Upgrade_Data then
            Network.Notification.Fire(Player, {
                Text = "Invalid upgrade",
                Type = "Error",
            })
            continue
        end

        local Upgrades = World:get(Player_Entity, Components.Upgrades)

        if not Upgrades then
            continue
        end

        local Upgrade_Level = Upgrades[Upgrade_Name]

        if not Upgrade_Level then
            continue
        end

        local Next_Upgrade_Data = Upgrade_Data.Levels[Upgrade_Level + 1]

        if not Next_Upgrade_Data then
            Network.Notification.Fire(Player, {
                Text = "This upgrade is max",
                Type = "Error",
            })
            continue
        end

        local Cash = World:get(Player_Entity, Components.Cash)

        if Cash < Next_Upgrade_Data.Price then
            Network.Notification.Fire(Player, {
                Text = "You don't have enough cash",
                Type = "Error",
            })
            continue
        end

        Upgrades[Upgrade_Name] = Upgrades[Upgrade_Name] + 1

        Network.Notification.Fire(Player, {
            Text = `You upgraded {Upgrade_Name} to level {Upgrades[Upgrade_Name]}!`,
            Type = "Success",
        })

        Network.VFX.Buy.FireAll(Character)
    end
end

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = Handle_Upgrade_Purchase_Requests,
    runConditions = {},
}
