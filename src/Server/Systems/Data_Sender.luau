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

local Pickaxes = require(ReplicatedStorage.Common.Modules.Pickaxes)
local Util = require(ReplicatedStorage.Common.Modules.Util)

local Player_Entities = World:query(Components.Player):cached()

local function Remove_Pickaxe_Tool(Player: Player, Character: Model)
    for _, Inst in Player.Backpack:GetChildren() do
        if Inst:HasTag("Pickaxe") then
            Inst:Destroy()
        end
    end

    for _, Inst in Character:GetChildren() do
        if Inst:HasTag("Pickaxe") then
            Inst:Destroy()
        end
    end
end

local function Add_Pickaxe_Tool(Player: Player, Name: string)
    local Data = Pickaxes[Name]

    if not Data then
        error(`Invalid pickaxe: {Name}`)
    end

    local Existing_Tools = {}

    for _, Inst in Player.Backpack:GetChildren() do
        if Inst:IsA("Tool") then
            table.insert(Existing_Tools, Inst)
            Inst.Parent = nil
        end
    end

    Data.Tool:Clone().Parent = Player.Backpack

    for _, Tool in Existing_Tools do
        Tool.Parent = Player.Backpack
    end
end

local function Replicate_Cash(Player: Player, Entity: Types.Entity)
    local Cash = World:get(Entity, Components.Cash)
    local Previous_Cash = World:get(Entity, Pair(Components.Relationships.Previous, Components.Cash))

    if Cash ~= Previous_Cash then
        Network.DataChanged.Cash.Fire(Player, Cash)

        World:set(Entity, Pair(Components.Relationships.Previous, Components.Cash), Cash)

        Log.Info(`{Player.Name}'s cash was changed to {Cash}`)
    end
end

local function Replicate_Pickaxe(Player: Player, Entity: Types.Entity)
    local Character = World:get(Entity, Components.Renderable)

    if not Character then
        return
    end

    local Pickaxe = World:get(Entity, Components.Pickaxe)
    local Previous_Pickaxe = World:get(Entity, Pair(Components.Relationships.Previous, Components.Pickaxe))

    if Pickaxe ~= Previous_Pickaxe then
        Remove_Pickaxe_Tool(Player, Character)
        Add_Pickaxe_Tool(Player, Pickaxe)

        Network.DataChanged.Pickaxe.Fire(Player, Pickaxe)

        World:set(Entity, Pair(Components.Relationships.Previous, Components.Pickaxe), Pickaxe)

        Log.Info(`{Player.Name}'s pickaxe was changed to {Pickaxe}`)
    end
end

local function Replicate_Owned_Pickaxes(Player: Player, Entity: Types.Entity)
    local Owned_Pickaxes = World:get(Entity, Components.Owned_Pickaxes)
    local Previous_Owned_Pickaxes =
        World:get(Entity, Pair(Components.Relationships.Previous, Components.Owned_Pickaxes))

    if not Util.TablesAreEqual(Owned_Pickaxes, Previous_Owned_Pickaxes) then
        Network.DataChanged.Owned_Pickaxes.Fire(Player, Owned_Pickaxes)

        World:set(
            Entity,
            Pair(Components.Relationships.Previous, Components.Owned_Pickaxes),
            Util.CopyTable(Owned_Pickaxes, true)
        )

        Log.Info(`{Player.Name}'s pickaxes were changed`)
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

            Replicate_Pickaxe(Player, Entity)

            Replicate_Owned_Pickaxes(Player, Entity)

            Replicate_Gamepasses(Player, Entity)
        end
    end,
    runConditions = {},
}
