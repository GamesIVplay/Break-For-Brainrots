local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Network = require(ServerScriptService.Network)

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local World = require(ReplicatedStorage.Common.World)

local Pickaxes = require(ReplicatedStorage.Common.Modules.Pickaxes)

local function Handle_Pickaxe_Purchase_Requests()
    for _, Player: Player, Pickaxe_Name: string in Network.Requests.Buy_Pickaxe.Iter() do
        local Player_Entity = Registry.Get("Players", Player)

        if not Player_Entity then
            continue
        end

        local Character = World:get(Player_Entity, Components.Renderable)

        if not Character then
            continue
        end

        local Pickaxe_Data = Pickaxes[Pickaxe_Name]

        if not Pickaxe_Data or not Pickaxe_Data.Price then
            Network.Notification.Fire(Player, {
                Text = "Invalid Pickaxe",
                Type = "Error",
            })
            continue
        end

        local Cash = World:get(Player_Entity, Components.Cash)

        if Cash < Pickaxe_Data.Price then
            Network.Notification.Fire(Player, {
                Text = "You don't have enough cash",
                Type = "Error",
            })
            continue
        end

        local Owned_Pickaxes = World:get(Player_Entity, Components.Owned_Pickaxes)

        if table.find(Owned_Pickaxes, Pickaxe_Name) then
            Network.Notification.Fire(Player, {
                Text = "You already own this",
                Type = "Error",
            })
            continue
        end

        World:set(Player_Entity, Components.Cash, Cash - Pickaxe_Data.Price)

        table.insert(Owned_Pickaxes, Pickaxe_Name)

        Network.Notification.Fire(Player, {
            Text = `You bought a {Pickaxe_Name} Pickaxe!`,
            Type = "Success",
        })

        Network.VFX.Buy.FireAll(Character)
    end
end

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = Handle_Pickaxe_Purchase_Requests,
    runConditions = {},
}
