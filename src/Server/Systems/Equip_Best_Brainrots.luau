local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Network = require(ServerScriptService.Network)
local New_Brainrot_Entity = require(ServerScriptService.Server.Modules.New_Brainrot_Entity)
local Slot_Util = require(ServerScriptService.Server.Modules.Slot_Util)

local Jecs = require(ReplicatedStorage.Packages.Jecs)
local Pair = Jecs.pair

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local Types = require(ReplicatedStorage.Common.Types)
local World = require(ReplicatedStorage.Common.World)

local Brainrot_Capacity = require(ReplicatedStorage.Common.Modules.Brainrot_Capacity)
local Calculate_Income_Per_Sec = require(ReplicatedStorage.Common.Modules.Calculate_Income_Per_Sec)
local Ratelimits = require(ReplicatedStorage.Common.Modules.Ratelimits)
local Util = require(ReplicatedStorage.Common.Modules.Util)

local function Handle_Equip_Best_Brainrots_Requests()
    for _, Player: Player in Network.Requests.Equip_Best_Brainrots.Iter() do
        if not Ratelimits.Equip_Best_Brainrots(Player) then
            continue
        end

        local Player_Entity = Registry.Get("Players", Player)
        if not Player_Entity then
            continue
        end

        local Player_Cash = World:get(Player_Entity, Components.Cash)

        if not Player_Cash then
            continue
        end

        local Gamepasses = World:get(Player_Entity, Components.Gamepasses)

        if not Gamepasses then
            continue
        end

        local HasExtraSlots = table.find(Gamepasses, "+2 Slots")

        local Brainrot_Inventory = World:get(Player_Entity, Components.Brainrot_Inventory)
        if not Brainrot_Inventory then
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

        local Stands = Plot_Model:FindFirstChild("Stands")

        local Gained_Cash = 0

        for
            Brainrot_Entity,
            Brainrot_Name: string,
            Secondary_Mutations: { string },
            Weight: number,
            Cash: number,
            Offline_Cash: number
        in
            World:query(
                Components.Name,
                Components.Secondary_Mutations,
                Components.Weight,
                Components.Cash,
                Components.Offline_Cash
            ):with(Components.Tags.Brainrot, Pair(Components.Relationships.Owner, Player_Entity))
        do
            local Slot = Slot_Util.Get_First_Open(Brainrot_Inventory, Brainrot_Capacity)

            if not Slot then
                break
            end

            local Primary_Mutation = World:get(Brainrot_Entity, Components.Primary_Mutation)

            local Brainrot_Item: Types.Brainrot_Item = {
                Name = Brainrot_Name,
                Primary_Mutation = Primary_Mutation,
                Secondary_Mutations = Secondary_Mutations,
                Weight = Weight,
                Cash = 0,
                Offline_Cash = 0,
            }

            Gained_Cash += Cash
            Gained_Cash += Offline_Cash

            Brainrot_Inventory[Slot] = Brainrot_Item

            World:delete(Brainrot_Entity)
        end

        World:set(Player_Entity, Components.Cash, Player_Cash + Gained_Cash)

        local Sorted_By_Income = {}

        Slot_Util.For_Each(Brainrot_Inventory, Brainrot_Capacity, function(Index, Item: Types.Brainrot_Item)
            table.insert(Sorted_By_Income, {
                Index = Index,
                Data = Item,
                Income = Calculate_Income_Per_Sec({
                    Brainrot_Name = Item.Name,
                    Primary_Mutation = Item.Primary_Mutation,
                    Secondary_Mutations = Item.Secondary_Mutations,
                    Weight = Item.Weight,
                }),
            })
        end)

        table.sort(Sorted_By_Income, function(a, b)
            return a.Income > b.Income
        end)

        for Index = 1, HasExtraSlots and 10 or 8 do
            local Data = Sorted_By_Income[Index]

            if not Data then
                break
            end

            local Open_Stand: Model?

            for Stand = 1, 10 do
                if (Stand == 5 or Stand == 10) and not table.find(Gamepasses, "+2 Slots") then
                    continue
                end

                local Stand_Model = Stands:FindFirstChild(Stand)

                if Stand_Model:HasTag("Occupied") then
                    continue
                end

                Stand_Model:AddTag("Occupied")
                Open_Stand = Stand_Model
                break
            end

            if Open_Stand then
                New_Brainrot_Entity(
                    Player_Entity,
                    Open_Stand,
                    Data.Data.Name,
                    Data.Data.Primary_Mutation,
                    Data.Data.Secondary_Mutations,
                    Data.Data.Weight
                )

                Slot_Util.Clear_Slot(Brainrot_Inventory, Data.Index)
            else
                break
            end
        end

        Network.Notification.Fire(Player, {
            Text = `Equipped best and Collected ${Util.Abbreviate_Number(Gained_Cash, 2)}`,
            Type = "Success",
        })
    end
end

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = function()
        Handle_Equip_Best_Brainrots_Requests()
    end,
    runConditions = {},
}
