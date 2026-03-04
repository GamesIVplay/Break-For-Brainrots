local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Network = require(ServerScriptService.Network)

local Slot_Util = require(ServerScriptService.Server.Modules.Slot_Util)

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local Types = require(ReplicatedStorage.Common.Types)
local World = require(ReplicatedStorage.Common.World)

local Config = require(ReplicatedStorage.Common.Config)
local Daily_Rewards = require(ReplicatedStorage.Common.Modules.Daily_Rewards)
local Ratelimits = require(ReplicatedStorage.Common.Modules.Ratelimits)
local Stat_Calculator = require(ReplicatedStorage.Common.Modules.Stat_Calculator)
local Weight = require(ReplicatedStorage.Common.Modules.Weight)

local Brainrot_Capacity = Stat_Calculator.Get_Brainrot_Capacity()

local function Handle_Claim_Daily_Reward_Requests()
    for _, Player: Player, Index: number in Network.Requests.Claim_Daily_Reward.Iter() do
        if not Ratelimits.Claim_Daily_Reward(Player) then
            continue
        end

        local Player_Entity = Registry.Get("Players", Player)

        if not Player_Entity then
            continue
        end

        local Last_Daily_Reward_Claim = World:get(Player_Entity, Components.Last_Daily_Reward_Claim)

        if not Last_Daily_Reward_Claim then
            continue
        end

        local Claimed_Daily_Rewards = World:get(Player_Entity, Components.Claimed_Daily_Rewards)

        if not Claimed_Daily_Rewards then
            continue
        end

        local Reward_Data = Daily_Rewards[Config.DAILY_REWARD_ID][Index]

        if not Reward_Data then
            continue
        end

        local NextIndex = #Claimed_Daily_Rewards + 1

        if table.find(Claimed_Daily_Rewards, tostring(Index)) then
            Network.Notification.Fire(Player, {
                Text = "You already claimed this reward",
                Type = "Error",
            })
            continue
        end

        if Index ~= NextIndex then
            Network.Notification.Fire(Player, {
                Text = "You must claim rewards in order",
                Type = "Error",
            })
            continue
        end

        local Elapsed = os.time() - Last_Daily_Reward_Claim
        if Elapsed < (86_400 / 2) then
            Network.Notification.Fire(Player, {
                Text = "You can't claim this yet",
                Type = "Error",
            })
            continue
        end

        if Reward_Data.Type == "Brainrot" then
            local Brainrot_Inventory = World:get(Player_Entity, Components.Brainrot_Inventory)

            if not Brainrot_Inventory then
                continue
            end

            local Open_Slot = Slot_Util.Get_First_Open(Brainrot_Inventory, Brainrot_Capacity)

            if not Open_Slot then
                Network.Notification.Fire(Player, {
                    Text = `Your brainrot inventory is full ({Brainrot_Capacity}/{Brainrot_Capacity})`,
                    Type = "Error",
                })
                continue
            end

            local Brainrot_Item: Types.Brainrot_Item = {
                Name = Reward_Data.Name,
                Primary_Mutation = Reward_Data.Primary_Mutation,
                Secondary_Mutations = {},
                Weight = Weight.Roll_Weight(),
                Cash = 0,
                Offline_Cash = 0,
            }

            Brainrot_Inventory[Open_Slot] = Brainrot_Item
        end

        if Reward_Data.Type == "Cash" then
            local Cash = World:get(Player_Entity, Components.Cash)

            if not Cash then
                continue
            end

            World:set(Player_Entity, Components.Cash, Cash + Reward_Data.Amount)
        end

        table.insert(Claimed_Daily_Rewards, tostring(Index))

        World:set(Player_Entity, Components.Last_Daily_Reward_Claim, os.time())

        Network.Notification.Fire(Player, {
            Text = "Daily reward claimed!",
            Type = "Success",
        })
    end
end

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = Handle_Claim_Daily_Reward_Requests,
    runConditions = {},
}
