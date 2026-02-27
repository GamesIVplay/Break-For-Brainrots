local AnalyticsService = game:GetService("AnalyticsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Network = require(ServerScriptService.Network)

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local World = require(ReplicatedStorage.Common.World)

local Pickaxes = require(ReplicatedStorage.Common.Modules.Pickaxes)

local Ranked_Pickaxes = {}

for Name, Data in Pickaxes do
    table.insert(Ranked_Pickaxes, {
        Name = Name,
        Power = Data.Power,
    })
end

table.sort(Ranked_Pickaxes, function(a, b)
    return a.Power < b.Power
end)

local PickaxeRank = {}

for index, entry in ipairs(Ranked_Pickaxes) do
    PickaxeRank[entry.Name] = index
end

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

        local Tutorial_Step = World:get(Player_Entity, Components.Tutorial_Step)

        if not Tutorial_Step then
            continue
        end

        local Current_Pickaxe = World:get(Player_Entity, Components.Pickaxe)

        if not Current_Pickaxe then
            continue
        end

        local Upgrades = World:get(Player_Entity, Components.Upgrades)

        if not Upgrades then
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

        local Rebirth = World:get(Player_Entity, Components.Rebirth)

        if Rebirth < Pickaxe_Data.Rebirth then
            Network.Notification.Fire(Player, {
                Text = "You don't have the required rebirth",
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

        if Tutorial_Step == 4 then
            if Pickaxe_Name ~= "Stone" then
                continue
            end

            for Name, Level in Upgrades do
                AnalyticsService:LogFunnelStepEvent(Player, Name, tostring(Player.UserId), Level, `Level {Level}`)
            end

            Network.VFX.Tutorial_Complete.FireAll(Character)

            AnalyticsService:LogFunnelStepEvent(Player, "Rebirth", tostring(Player.UserId), 1, `Rebirth 0`)

            World:set(Player_Entity, Components.Tutorial_Step, 5)

            task.delay(3, function()
                if not World:contains(Player_Entity) then
                    return
                end

                World:set(Player_Entity, Components.Tutorial_Step, 6)
            end)
        end

        World:set(Player_Entity, Components.Cash, Cash - Pickaxe_Data.Price)

        table.insert(Owned_Pickaxes, Pickaxe_Name)

        if Pickaxes[Current_Pickaxe].Power < Pickaxes[Pickaxe_Name].Power then
            World:set(Player_Entity, Components.Pickaxe, Pickaxe_Name)
        end

        Network.Notification.Fire(Player, {
            Text = `You bought a {Pickaxe_Name} Pickaxe!`,
            Type = "Success",
        })

        Network.VFX.Buy.FireAll(Character)

        AnalyticsService:LogFunnelStepEvent(
            Player,
            "Pickaxe Progression",
            tostring(Player.UserId),
            PickaxeRank[Pickaxe_Name] or 1,
            `{Pickaxe_Name} (Power {Pickaxe_Data.Power})`
        )
    end
end

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = Handle_Pickaxe_Purchase_Requests,
    runConditions = {},
}
