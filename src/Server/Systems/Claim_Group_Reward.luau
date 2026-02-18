local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Network = require(ServerScriptService.Network)

local Slot_Util = require(ServerScriptService.Server.Modules.Slot_Util)

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local Types = require(ReplicatedStorage.Common.Types)
local World = require(ReplicatedStorage.Common.World)

local Brainrot_Capacity = require(ReplicatedStorage.Common.Modules.Brainrot_Capacity)
local GroupId = require(ReplicatedStorage.Common.Modules.GroupId)
local Ratelimits = require(ReplicatedStorage.Common.Modules.Ratelimits)

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

            if not Player:IsInGroupAsync(GroupId) then
                Network.Notification.Fire(Player, {
                    Text = "Join the group and like the game to claim!",
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

            local Cash = World:get(Player_Entity, Components.Cash)
            local Brainrot_Inventory = World:get(Player_Entity, Components.Brainrot_Inventory)

            local Open_Slot = Slot_Util.Get_First_Open(Brainrot_Inventory, Brainrot_Capacity)

            if not Open_Slot then
                Network.Notification.Fire(
                    Player,
                    { Text = `Your inventory is full ({Brainrot_Capacity}/{Brainrot_Capacity})`, Type = "Error" }
                )
                return
            end

            World:add(Player_Entity, Components.Tags.Claimed_Group_Reward)

            World:set(Player_Entity, Components.Cash, Cash + 10000)

            Brainrot_Inventory[Open_Slot] = {
                Name = "Brr Brr Patapim",
                Secondary_Mutations = {},
                Weight = 10,
                Cash = 0,
                Offline_Cash = 0,
            } :: Types.Brainrot_Item

            Network.Notification.Fire(Player, {
                Text = "Thanks for joining the group! Rewards Claimed",
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
