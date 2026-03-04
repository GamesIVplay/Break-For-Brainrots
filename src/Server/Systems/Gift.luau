local PolicyService = game:GetService("PolicyService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Network = require(ServerScriptService.Network)

local Slot_Util = require(ServerScriptService.Server.Modules.Slot_Util)

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local Types = require(ReplicatedStorage.Common.Types)
local World = require(ReplicatedStorage.Common.World)

local Ratelimits = require(ReplicatedStorage.Common.Modules.Ratelimits)
local Stat_Calculator = require(ReplicatedStorage.Common.Modules.Stat_Calculator)
local Util = require(ReplicatedStorage.Common.Modules.Util)

local Trade_Allowed = {}

game.Players.PlayerAdded:Connect(function(Player)
    task.spawn(function()
        local Success, PolicyInfo = pcall(function()
            return PolicyService:GetPolicyInfoForPlayerAsync(Player)
        end)

        Trade_Allowed[Player] = Success and PolicyInfo and PolicyInfo.IsPaidItemTradingAllowed ~= false
    end)
end)

game.Players.PlayerRemoving:Connect(function(Player)
    Trade_Allowed[Player] = nil
end)

local function Handle_Gift_Requests()
    for _, Player: Player, Target_Player_Entity: Types.Entity in Network.Requests.Gift.Iter() do
        if not Ratelimits.Gift(Player) then
            continue
        end

        if not World:contains(Target_Player_Entity) then
            continue
        end

        local Target_Player = World:get(Target_Player_Entity, Components.Player)

        if not Target_Player then
            continue
        end

        if not Trade_Allowed[Player] then
            Network.Notification.Fire(Player, {
                Text = "Gifting is not available in your region",
                Type = "Error",
            })
            continue
        end

        if not Trade_Allowed[Target_Player] then
            Network.Notification.Fire(Player, {
                Text = "This player cannot receive gifts in their region",
                Type = "Error",
            })
            continue
        end

        local Target_Player_Entity_Brainrot_Inventory = World:get(Target_Player_Entity, Components.Brainrot_Inventory)

        if not Target_Player_Entity_Brainrot_Inventory then
            continue
        end

        local Player_Entity = Registry.Get("Players", Player)

        if not Player_Entity then
            continue
        end

        local Brainrot_Inventory = World:get(Player_Entity, Components.Brainrot_Inventory)

        if not Brainrot_Inventory then
            continue
        end

        local Character = World:get(Player_Entity, Components.Renderable) :: Model?

        if not Character then
            continue
        end

        local Tool: Tool?

        for _, Inst: Instance in Character:GetChildren() do
            if Inst:IsA("Tool") and Inst:HasTag("Brainrot") then
                Tool = Inst
                break
            end
        end

        if not Tool then
            Network.Notification.Fire(Player, {
                Text = "You must hold a brainrot",
                Type = "Error",
            })
            continue
        end

        local Brainrot_Capacity = Stat_Calculator.Get_Brainrot_Capacity()
        local Open_Slot = Slot_Util.Get_First_Open(Target_Player_Entity_Brainrot_Inventory, Brainrot_Capacity)

        if not Open_Slot then
            Network.Notification.Fire(Player, {
                Text = `This players inventory is full ({Brainrot_Capacity}/{Brainrot_Capacity})`,
                Type = "Error",
            })
            continue
        end

        local Index = Tool:GetAttribute("Index")
        local Brainrot_Item: Types.Brainrot_Item = Brainrot_Inventory[Index]

        Target_Player_Entity_Brainrot_Inventory[Open_Slot] = Util.CopyTable(Brainrot_Item, true)

        Slot_Util.Clear_Slot(Brainrot_Inventory, Index)

        local Gifted_Name = not Brainrot_Item.Primary_Mutation and Brainrot_Item.Name
            or `{Brainrot_Item.Primary_Mutation} {Brainrot_Item.Name}`

        Network.Notification.Fire(Player, {
            Text = `Gifted {Target_Player} a {Gifted_Name}!`,
            Type = "Success",
        })

        Network.Notification.Fire(Target_Player, {
            Text = `{Player.Name} gifted you a {Gifted_Name}!`,
            Type = "Info",
        })
    end
end

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = Handle_Gift_Requests,
    runConditions = {},
}
