local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Network = require(ServerScriptService.Network)

local Jecs = require(ReplicatedStorage.Packages.Jecs)
local Pair = Jecs.pair

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Types = require(ReplicatedStorage.Common.Types)
local World = require(ReplicatedStorage.Common.World)

local Blocks = require(ReplicatedStorage.Common.Modules.Blocks)
local Calculate_Luck = require(ReplicatedStorage.Common.Modules.Calculate_Luck)
local Roll_Block = require(ReplicatedStorage.Common.Modules.Roll_Block)

local Block_Spawner_Query = World:query(Components.Renderable)
    :with(Components.Tags.Plot, Pair(Components.Relationships.Owner, Jecs.Wildcard))
    :without(Pair(Components.Relationships.Block, Jecs.Wildcard))
    :cached()

local function Spawn_Blocks()
    for Plot_Entity: Types.Entity, Plot_Model: Model in Block_Spawner_Query:iter() do
        local Owner_Entity = World:target(Plot_Entity, Components.Relationships.Owner)
        local Owner_Player = World:get(Owner_Entity, Components.Player) :: Player

        local Block_Queue = World:get(Owner_Entity, Components.Block_Queue)

        local Luck = Calculate_Luck(Owner_Entity)

        local Block_Name, Block_Data

        if #Block_Queue > 0 then
            Block_Name, Block_Data = Block_Queue[1], Blocks[Block_Queue[1]]

            table.remove(Block_Queue, 1)

            Network.Notification.Fire(Owner_Player, {
                Text = `Your queued {Block_Name} Block spawned!`,
                Type = "Info",
            })
        else
            Block_Name, Block_Data = Roll_Block(Luck)

            --[[local counts = { Common = 0, Rare = 0, Epic = 0, Legendary = 0, Mythical = 0, Secret = 0 }
            for i = 1, 100 do
                local name = Roll_Block(Luck)
                counts[name] += 1
            end
            print(counts)]]
        end

        local Block_Spawn = Plot_Model:FindFirstChild("Block_Spawn", true) :: Attachment

        local Block_Model = Block_Data.Model:Clone()

        if not Block_Data.Floats then
            Block_Model:PivotTo(Block_Spawn.WorldCFrame)
        else
            Block_Model:PivotTo(Block_Spawn.WorldCFrame * CFrame.new(0, 0.25, 0))
        end

        Block_Model:SetAttribute("Owner", Owner_Player.UserId)
        Block_Model.Parent = workspace:FindFirstChild("Blocks")

        if Block_Data.Floats then
            Block_Model:AddTag("Idle")
        end

        local Block_Entity = World:entity()

        World:set(Block_Entity, Components.Name, Block_Name)
        World:set(Block_Entity, Components.Renderable, Block_Model)
        World:set(Block_Entity, Components.Health, Block_Data.Health)

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
