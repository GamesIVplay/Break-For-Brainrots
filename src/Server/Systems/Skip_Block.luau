local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Network = require(ServerScriptService.Network)

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local World = require(ReplicatedStorage.Common.World)

local Last_Skipped: { [Player]: number } = {}

local COOLDOWN = 3

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

            if World:has(Block_Entity, Components.Tags.Opening) then
                Network.Notification.Fire(Player, {
                    Text = "Your block is opening!",
                    Type = "Error",
                })
                continue
            end

            local Now = os.clock()
            local Last = Last_Skipped[Player] or 0
            local Elapsed = Now - Last

            if Elapsed < COOLDOWN then
                Network.Notification.Fire(Player, {
                    Text = ("%.1f seconds remaining"):format(COOLDOWN - Elapsed),
                    Type = "Warning",
                })
                continue
            end

            World:delete(Block_Entity)

            Last_Skipped[Player] = os.clock()
        end
    end,
    runConditions = {},
}
