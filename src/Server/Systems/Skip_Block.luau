local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Network = require(ServerScriptService.Network)

local Ratelimit = require(ReplicatedStorage.Packages.Ratelimit)
local Skip_Rate_Limit = Ratelimit(1, 8)

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local World = require(ReplicatedStorage.Common.World)

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = function()
        for _, Player: Player in Network.Requests.Skip_Block.Iter() do
            local Player_Entity = Registry.Get("Players", Player)

            if not Player_Entity then
                continue
            end

            local Plot_Entity = World:target(Player_Entity, Components.Relationships.Plot)

            if not Plot_Entity then
                continue
            end

            local Block_Entity = World:target(Plot_Entity, Components.Relationships.Block)

            if not Block_Entity then
                continue
            end

            --[[if World:has(Block_Entity, Components.Tags.Opening) then
                Network.Notification.Fire(Player, {
                    Text = "Your crate is opening!",
                })
                continue
            end]]

            --[[if not Skip_Rate_Limit(Player_Entity) then
                Network.Notification.Fire(Player, {
                    Text = "You're on cooldown",
                    Type = "Warning",
                })
                continue
            end]]

            World:delete(Block_Entity)
        end
    end,
    runConditions = {},
}
