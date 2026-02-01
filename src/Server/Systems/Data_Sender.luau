local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Jecs = require(ReplicatedStorage.Packages.Jecs)
local Pair = Jecs.pair

local Network = require(ServerScriptService.Network)

local Components = require(ReplicatedStorage.Common.Components)
local Log = require(ReplicatedStorage.Common.Log)
local Phases = require(ReplicatedStorage.Common.Phases)
local Types = require(ReplicatedStorage.Common.Types)
local World = require(ReplicatedStorage.Common.World)

local Util = require(ReplicatedStorage.Common.Modules.Util)

local Player_Entities = World:query(Components.Player):cached()

local function Replicate_Cash(Player: Player, Entity: Types.Entity)
    local Cash = World:get(Entity, Components.Cash)
    local Previous_Cash = World:get(Entity, Pair(Components.Relationships.Previous, Components.Cash))

    if Cash ~= Previous_Cash then
        Network.PlayerDataChanges.Cash.Fire(Player, Cash)

        World:set(Entity, Pair(Components.Relationships.Previous, Components.Cash), Cash)

        Log.Info(`{Player.Name}'s cash was changed to {Cash}`)
    end
end

local function Replicate_Gamepasses(Player: Player, Entity: Types.Entity)
    local Gamepasses = World:get(Entity, Components.Gamepasses)
    local Previous_Gamepasses = World:get(Entity, Pair(Components.Relationships.Previous, Components.Gamepasses))

    if not Util.TablesAreEqual(Gamepasses, Previous_Gamepasses) then
        Network.DataChanged.Gamepasses.Fire(Player, Gamepasses)

        World:set(
            Entity,
            Pair(Components.Relationships.Previous, Components.Gamepasses),
            Util.CopyTable(Gamepasses, true)
        )

        Log.Info(`{Player.Name}'s gamepasses were changed`)
    end
end

return {
    name = script.Name,
    phase = Phases.Runservice.PostUpdate,
    system = function()
        for Entity, Player in Player_Entities:iter() do
            Replicate_Cash(Player, Entity)

            Replicate_Gamepasses(Player, Entity)
        end
    end,
    runConditions = {},
}
