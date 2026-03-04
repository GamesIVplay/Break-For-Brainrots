local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Network = require(ServerScriptService.Network)

local Slot_Util = require(ServerScriptService.Server.Modules.Slot_Util)

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local Types = require(ReplicatedStorage.Common.Types)
local World = require(ReplicatedStorage.Common.World)

local GroupId = require(ReplicatedStorage.Common.Modules.GroupId)
local Ratelimits = require(ReplicatedStorage.Common.Modules.Ratelimits)
local Stat_Calculator = require(ReplicatedStorage.Common.Modules.Stat_Calculator)
local Tutorial_Steps = require(ReplicatedStorage.Common.Modules.Tutorial_Steps)

local Brainrot_Capacity = Stat_Calculator.Get_Brainrot_Capacity()

local function Handle_Claim_Group_Reward_Requests()
    for _, Player: Player in Network.Requests.Claim_Group_Reward.Iter() do
        if not Ratelimits.Claim_Group_Reward(Player) then
            continue
        end

        task.spawn(function()
            local Player_Entity = Registry.Get("Players", Player)

            if not Player_Entity then
                return
            end

            local Tutorial_Step = World:get(Player_Entity, Components.Tutorial_Step)

            if not Tutorial_Step then
                return
            end

            if Tutorial_Step < #Tutorial_Steps then
                Network.Notification.Fire(Player, {
                    Text = "Complete the tutorial first",
                    Type = "Error",
                })
                return
            end

            if not Player:IsInGroupAsync(GroupId) then
                Network.Notification.Fire(Player, {
                    Text = "Like the game and join our group to claim!",
                    Type = "Info",
                })
                return
            end

            if World:has(Player_Entity, Components.Tags.Claimed_Group_Reward) then
                Network.Notification.Fire(Player, {
                    Text = "Reward already claimed",
                    Type = "Error",
                })
                return
            end

            local Brainrot_Inventory = World:get(Player_Entity, Components.Brainrot_Inventory)

            local Open_Slot = Slot_Util.Get_First_Open(Brainrot_Inventory, Brainrot_Capacity)

            if not Open_Slot then
                Network.Notification.Fire(Player, {
                    Text = `Your brainrot inventory is full ({Brainrot_Capacity}/{Brainrot_Capacity})`,
                    Type = "Error",
                })
                return
            end

            World:add(Player_Entity, Components.Tags.Claimed_Group_Reward)

            Brainrot_Inventory[Open_Slot] = {
                Name = "Cappuccino Assassino",
                Primary_Mutation = "Diamond",
                Secondary_Mutations = {},
                Weight = 10,
                Cash = 0,
                Offline_Cash = 0,
            } :: Types.Brainrot_Item

            Network.Notification.Fire(Player, {
                Text = "Thanks for liking the game and joining our group!",
                Type = "Success",
            })
        end)
    end
end

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = Handle_Claim_Group_Reward_Requests,
    runConditions = {},
}
