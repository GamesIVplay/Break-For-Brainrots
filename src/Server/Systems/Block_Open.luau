local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Network = require(ServerScriptService.Network)

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Types = require(ReplicatedStorage.Common.Types)
local World = require(ReplicatedStorage.Common.World)

local Blocks = require(ReplicatedStorage.Common.Modules.Blocks)
local Calculate_Mutation_Luck = require(ReplicatedStorage.Common.Modules.Calculate_Mutation_Luck)
local Roll_Primary_Mutation = require(ReplicatedStorage.Common.Modules.Roll_Primary_Mutation)
local Roll_Secondary_Mutation = require(ReplicatedStorage.Common.Modules.Roll_Secondary_Mutation)
local Weight = require(ReplicatedStorage.Common.Modules.Weight)

local Block_Open_Query = World:query(Components.Name, Components.Renderable, Components.Health)
    :with(Components.Tags.Block)
    :without(Components.Tags.Opening)
    :cached()

local function Open_Blocks()
    for Block_Entity: Types.Entity, Block_Name: string, Block_Model: Model, Block_Health: number in
        Block_Open_Query:iter()
    do
        if Block_Health > 0 then
            continue
        end

        local Plot_Entity = World:target(Block_Entity, Components.Relationships.Owner)
        local Plot_Owner = World:target(Plot_Entity, Components.Relationships.Owner)

        if not Plot_Owner then
            continue
        end

        local Opens = World:get(Plot_Owner, Components.Opens)

        World:add(Block_Entity, Components.Tags.Opening)

        Block_Model.Parent = ReplicatedStorage:FindFirstChild("Temp")

        Network.VFX.Block_Break.FireAll(Block_Model.PrimaryPart.CFrame)

        local Mutation_Luck = Calculate_Mutation_Luck(Plot_Owner)

        local Rolled_Brainrot = Blocks[Block_Name].Roll_Brainrot()
        local Rolled_Primary_Mutation = Roll_Primary_Mutation(Mutation_Luck)
        local Rolled_Secondary_Mutations = Roll_Secondary_Mutation(Mutation_Luck)
        local Rolled_Weight = Weight.Roll_Weight()

        warn("________")
        print(Rolled_Brainrot)
        print(Rolled_Primary_Mutation)
        print(Rolled_Secondary_Mutations)
        print(Rolled_Weight)
        warn("________")

        World:set(Plot_Owner, Components.Opens, Opens + 1)
        World:delete(Block_Entity)
    end
end

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = Open_Blocks,
    runConditions = {},
}
