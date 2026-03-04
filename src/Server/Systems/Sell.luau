local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Slot_Util = require(ServerScriptService.Server.Modules.Slot_Util)

local Network = require(ServerScriptService.Network)

local Jecs = require(ReplicatedStorage.Packages.Jecs)
local Pair = Jecs.pair

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local Types = require(ReplicatedStorage.Common.Types)
local World = require(ReplicatedStorage.Common.World)

local Ratelimits = require(ReplicatedStorage.Common.Modules.Ratelimits)
local Stat_Calculator = require(ReplicatedStorage.Common.Modules.Stat_Calculator)
local Tutorial_Steps = require(ReplicatedStorage.Common.Modules.Tutorial_Steps)
local Util = require(ReplicatedStorage.Common.Modules.Util)

local Brainrot_Capacity = Stat_Calculator.Get_Brainrot_Capacity()

local function Normalize_Secondary(List: { string }): string
    if #List == 0 then
        return ""
    end

    local Copy = table.clone(List)
    table.sort(Copy)

    return table.concat(Copy, ",")
end

local function Handle_Sell_Requests()
    for _, Player: Player, ServerEntity: Types.Entity in Network.Requests.Sell_Brainrot.Iter() do
        if not Ratelimits.Sell(Player) then
            continue
        end

        if not Ratelimits.Collect(ServerEntity) then
            continue
        end

        local Player_Entity = Registry.Get("Players", Player)

        if not Player_Entity then
            continue
        end

        local Tutorial_Step = World:get(Player_Entity, Components.Tutorial_Step)

        if not Tutorial_Step then
            continue
        end

        if Tutorial_Step < #Tutorial_Steps then
            Network.Notification.Fire(Player, { Text = "Complete the tutorial first", Type = "Error" })

            continue
        end

        if
            not World:has(ServerEntity, Pair(Components.Relationships.Owner, Player_Entity))
            or not World:has(ServerEntity, Components.Tags.Brainrot)
        then
            continue
        end

        local Player_Cash = World:get(Player_Entity, Components.Cash)

        if not Player_Cash then
            continue
        end

        local Level = World:get(ServerEntity, Components.Level)
        local Experience = World:get(ServerEntity, Components.Experience)
        local Brainrot_Name = World:get(ServerEntity, Components.Name)
        local Primary_Mutation = World:get(ServerEntity, Components.Primary_Mutation)
        local Secondary_Mutations = World:get(ServerEntity, Components.Secondary_Mutations)
        local Weight = World:get(ServerEntity, Components.Weight)

        local Sell_Price = Stat_Calculator.Calculate_Sell_Price({
            Level = Level,
            Experience = Experience,
            Brainrot_Name = Brainrot_Name,
            Primary_Mutation = Primary_Mutation,
            Secondary_Mutations = Secondary_Mutations,
            Weight = Weight,
        })

        World:set(Player_Entity, Components.Cash, Player_Cash + Sell_Price)

        World:delete(ServerEntity)

        local Sold_Name = not Primary_Mutation and Brainrot_Name or `{Primary_Mutation} {Brainrot_Name}`

        Network.Notification.Fire(Player, {
            Text = `Sold x1 {Sold_Name} for ${Util.Abbreviate_Number(Sell_Price)}`,
            Type = "Success",
        })
    end

    for _, Player: Player in Network.Requests.Sell_All.Iter() do
        if not Ratelimits.Sell_All(Player) then
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

        local Brainrot_Inventory = World:get(Player_Entity, Components.Brainrot_Inventory)

        if not Brainrot_Inventory then
            continue
        end

        local Total_Price = 0

        Slot_Util.For_Each(Brainrot_Inventory, Brainrot_Capacity, function(_, Brainrot_Item: Types.Brainrot_Item)
            local Sell_Price = Stat_Calculator.Calculate_Sell_Price({
                Level = Brainrot_Item.Level,
                Experience = Brainrot_Item.Experience,
                Brainrot_Name = Brainrot_Item.Name,
                Primary_Mutation = Brainrot_Item.Primary_Mutation,
                Secondary_Mutations = Brainrot_Item.Secondary_Mutations,
                Weight = Brainrot_Item.Weight,
            })

            Total_Price += Sell_Price
        end)

        if Total_Price == 0 then
            Network.Notification.Fire(Player, {
                Text = "You have nothing to sell",
                Type = "Error",
            })
            continue
        end

        Slot_Util.Clear_All(Brainrot_Inventory, Brainrot_Capacity)

        World:set(Player_Entity, Components.Cash, Player_Cash + Total_Price)

        Network.Notification.Fire(Player, {
            Text = `Sold all Brainrots for ${Util.Abbreviate_Number(Total_Price)}`,
            Type = "Success",
        })
    end

    for _, Player: Player, Item_Group in Network.Requests.Sell_Brainrot_Item_Group.Iter() do
        if not Ratelimits.Sell_Brainrot_Item_Group(Player) then
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

        local Brainrot_Inventory = World:get(Player_Entity, Components.Brainrot_Inventory)

        if not Brainrot_Inventory then
            continue
        end

        local Total_Price = 0
        local Sold_Count = 0
        local Sold_Name = not Item_Group.Primary_Mutation and Item_Group.Name
            or `{Item_Group.Primary_Mutation} {Item_Group.Name}`

        local Group_Secondary = Normalize_Secondary(Item_Group.Secondary_Mutations)

        Slot_Util.For_Each(Brainrot_Inventory, Brainrot_Capacity, function(Index, Brainrot_Item: Types.Brainrot_Item)
            if
                Brainrot_Item.Name ~= Item_Group.Name
                or Brainrot_Item.Primary_Mutation ~= Item_Group.Primary_Mutation
                or Normalize_Secondary(Brainrot_Item.Secondary_Mutations) ~= Group_Secondary
            then
                return
            end

            local Sell_Price = Stat_Calculator.Calculate_Sell_Price({
                Level = Brainrot_Item.Level,
                Experience = Brainrot_Item.Experience,
                Brainrot_Name = Brainrot_Item.Name,
                Primary_Mutation = Brainrot_Item.Primary_Mutation,
                Secondary_Mutations = Brainrot_Item.Secondary_Mutations,
                Weight = Brainrot_Item.Weight,
            })

            Total_Price += Sell_Price
            Sold_Count += 1

            Slot_Util.Clear_Slot(Brainrot_Inventory, Index)
        end)

        if Sold_Count == 0 then
            continue
        end

        World:set(Player_Entity, Components.Cash, Player_Cash + Total_Price)

        Network.Notification.Fire(Player, {
            Text = `Sold x{Sold_Count} {Sold_Name} for ${Util.Abbreviate_Number(Total_Price)}`,
            Type = "Success",
        })
    end
end

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = Handle_Sell_Requests,
    runConditions = {},
}
