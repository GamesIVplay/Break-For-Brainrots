local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Assets = ReplicatedStorage:WaitForChild("Assets")

local VFX = Assets:WaitForChild("VFX")
local Secondary_Mutations_VFX = VFX:WaitForChild("Secondary_Mutations")

local Network = require(ServerScriptService.Network)

local Jecs = require(ReplicatedStorage.Packages.Jecs)
local Pair = Jecs.pair

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Types = require(ReplicatedStorage.Common.Types)
local World = require(ReplicatedStorage.Common.World)

local Blocks = require(ReplicatedStorage.Common.Modules.Blocks)
local Roll_Block = require(ReplicatedStorage.Common.Modules.Roll_Block)
local Roll_Secondary_Mutation = require(ReplicatedStorage.Common.Modules.Roll_Secondary_Mutation)
local Stat_Calculator = require(ReplicatedStorage.Common.Modules.Stat_Calculator)

local Block_Spawner_Query = World:query(Components.Renderable)
    :with(Components.Tags.Plot, Pair(Components.Relationships.Owner, Jecs.Wildcard))
    :without(Pair(Components.Relationships.Block, Jecs.Wildcard))
    :cached()

local function Spawn_Blocks()
    for Plot_Entity: Types.Entity, Plot_Model: Model in Block_Spawner_Query:iter() do
        local Owner_Entity = World:target(Plot_Entity, Components.Relationships.Owner)
        local Owner_Player = World:get(Owner_Entity, Components.Player) :: Player

        local Opens = World:get(Owner_Entity, Components.Opens)
        local Block_Queue = World:get(Owner_Entity, Components.Block_Queue)

        local Luck = Stat_Calculator.Get_Luck(Owner_Entity)
        local Mutation_Luck = Stat_Calculator.Get_Luck(Owner_Entity)

        local Block_Name, Block_Data, Secondary_Mutations

        if Opens == 0 or Opens == 1 then
            Block_Name = "Common"
            Block_Data = Blocks["Common"]
        elseif Opens == 2 then
            Block_Name = "Rare"
            Block_Data = Blocks["Rare"]
        elseif #Block_Queue > 0 and Opens > 9 then
            Block_Name, Block_Data = Block_Queue[1], Blocks[Block_Queue[1]]

            table.remove(Block_Queue, 1)

            Network.Notification.Fire(Owner_Player, {
                Text = `Your queued {Block_Name} Block spawned!`,
                Type = "Info",
            })
        else
            local Excluded = Opens <= 9 and { "Legendary", "Mythical", "Secret" } or {}

            Block_Name, Block_Data = Roll_Block(Luck, Excluded)
        end

        Secondary_Mutations = Roll_Secondary_Mutation(Mutation_Luck)

        local Block_Spawn = Plot_Model:FindFirstChild("Block_Spawn", true) :: Attachment

        local Block_Model = Block_Data.Model:Clone()

        if not Block_Data.Floats then
            Block_Model:PivotTo(Block_Spawn.WorldCFrame)
        else
            Block_Model:PivotTo(Block_Spawn.WorldCFrame * CFrame.new(0, 0.25, 0))
        end

        Block_Model:AddTag(Plot_Model.Name .. "_Block")
        Block_Model.Parent = workspace:FindFirstChild("Blocks")

        if Secondary_Mutations ~= nil then
            for _, Mutation_Name in Secondary_Mutations do
                local Part = Secondary_Mutations_VFX:FindFirstChild(Mutation_Name):Clone() :: Part
                Part.Parent = Block_Model
                Part.CFrame = Block_Model.PrimaryPart.CFrame
                Part.Size = Block_Model:GetExtentsSize()

                local Weld = Instance.new("WeldConstraint")
                Weld.Part0 = Block_Model.PrimaryPart
                Weld.Part1 = Part
                Weld.Parent = Part
            end
        end

        if Block_Data.Floats then
            Block_Model:AddTag("Idle")
        end

        local Block_Entity = World:entity()

        World:set(Block_Entity, Components.Name, Block_Name)
        World:set(Block_Entity, Components.Renderable, Block_Model)
        World:set(Block_Entity, Components.Health, Block_Data.Health)
        World:set(Block_Entity, Components.Secondary_Mutations, Secondary_Mutations or {})

        World:add(Block_Entity, Components.Tags.Block)
        World:add(Block_Entity, Components.Tags.Networked)
        World:add(Block_Entity, Pair(Components.Relationships.Owner, Plot_Entity))

        World:add(Plot_Entity, Pair(Components.Relationships.Block, Block_Entity))

        World:set(Block_Entity, Components.Cleanup, function()
            Block_Model:Destroy()
        end)

        Network.VFX.Block_Spawn.FireAll(Block_Model)
    end
end

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = Spawn_Blocks,
    runConditions = {},
}
