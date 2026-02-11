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
local Brainrot_Offset = require(ReplicatedStorage.Common.Modules.Brainrot_Offset)
local Calculate_Mutation_Luck = require(ReplicatedStorage.Common.Modules.Calculate_Mutation_Luck)
local Generate_Brainrot_Model = require(ReplicatedStorage.Common.Modules.Generate_Brainrot_Model)
local Roll_Primary_Mutation = require(ReplicatedStorage.Common.Modules.Roll_Primary_Mutation)
local Roll_Secondary_Mutation = require(ReplicatedStorage.Common.Modules.Roll_Secondary_Mutation)
local Update_Brainrot_Overhead = require(ReplicatedStorage.Common.Modules.Update_Brainrot_Overhead)
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
        local Player_Entity = World:target(Plot_Entity, Components.Relationships.Owner)

        if not Player_Entity then
            continue
        end

        local Player = World:get(Player_Entity, Components.Player)
        local Gamepasses = World:get(Player_Entity, Components.Gamepasses)
        local Opens = World:get(Player_Entity, Components.Opens)

        World:add(Block_Entity, Components.Tags.Opening)

        Block_Model.Parent = ReplicatedStorage:FindFirstChild("Temp")

        local Mutation_Luck = Calculate_Mutation_Luck(Player_Entity)

        local Rolled_Brainrot = Blocks[Block_Name].Roll_Brainrot()
        local Rolled_Primary_Mutation = Roll_Primary_Mutation(Mutation_Luck)
        local Rolled_Secondary_Mutations = Roll_Secondary_Mutation(Mutation_Luck)
        local Rolled_Weight = Weight.Roll_Weight()

        local Brainrot_CF = Block_Model:GetPivot()

        Network.VFX.Brainrot_Cycle.FireAll({
            Block = Block_Name,
            Mutation_Luck = Mutation_Luck,
            Brainrot_CF = Brainrot_CF,
            Spin_VFX_CF = Block_Model.PrimaryPart.CFrame,
            Owner = Player.UserId,
            Rolled_Brainrot = {
                Name = Rolled_Brainrot,
                Primary_Mutation = Rolled_Primary_Mutation,
                Secondary_Mutations = Rolled_Secondary_Mutations,
                Weight = Rolled_Weight,
            },
        })

        local Plot_Model = World:get(Plot_Entity, Components.Renderable) :: Model
        local Stands = Plot_Model:FindFirstChild("Stands")

        local Open_Stand: Model?

        for Stand = 1, 10 do
            if (Stand == 5 or Stand == 10) and not table.find(Gamepasses, "+2 Slots") then
                continue
            end

            local Stand_Model = Stands:FindFirstChild(Stand)

            if Stand_Model:HasTag("Occupied") then
                continue
            end

            Stand_Model:AddTag("Occupied")
            Open_Stand = Stand_Model
            break
        end

        task.delay(3.8, function()
            if not World:contains(Block_Entity) or not World:contains(Player_Entity) then
                return
            end

            if Open_Stand then
                local Attachment = Open_Stand:FindFirstChild("Brainrot_Spawn", true) :: Attachment

                local Brainrot_Model, Offset = Generate_Brainrot_Model(
                    Rolled_Brainrot,
                    Rolled_Primary_Mutation,
                    Rolled_Secondary_Mutations,
                    Rolled_Weight
                )

                Update_Brainrot_Overhead(Brainrot_Model, {
                    Brainrot_Name = Rolled_Brainrot,
                    Primary_Mutation = Rolled_Primary_Mutation,
                    Secondary_Mutations = Rolled_Secondary_Mutations,
                    Weight = Rolled_Weight,
                })

                Brainrot_Model:AddTag("Idle")

                Brainrot_Model.Parent = workspace:FindFirstChild("Brainrots")

                Brainrot_Model:PivotTo(Attachment.WorldCFrame * Offset * CFrame.new(Brainrot_Offset))

                local Brainrot_Entity = World:entity()

                Open_Stand:SetAttribute("ServerEntity", Brainrot_Entity)

                World:set(Brainrot_Entity, Components.Name, Rolled_Brainrot)

                if Rolled_Primary_Mutation then
                    World:set(Brainrot_Entity, Components.Primary_Mutation, Rolled_Primary_Mutation)
                end

                World:set(Brainrot_Entity, Components.Secondary_Mutations, Rolled_Secondary_Mutations)
                World:set(Brainrot_Entity, Components.Weight, Rolled_Weight)
                World:set(Brainrot_Entity, Components.Stand, Open_Stand)
                World:set(Brainrot_Entity, Components.Cash, 0)
                World:set(Brainrot_Entity, Components.Offline_Cash, 0)

                World:add(Brainrot_Entity, Components.Tags.Brainrot)
                World:add(Brainrot_Entity, Components.Tags.Networked)

                World:add(Brainrot_Entity, Pair(Components.Relationships.Owner, Player_Entity))
                World:add(Player_Entity, Pair(Components.Relationships.Brainrot, Brainrot_Entity))

                World:set(Brainrot_Entity, Components.Cleanup, function()
                    Brainrot_Model:Destroy()
                    Open_Stand:RemoveTag("Occupied")
                    Open_Stand:SetAttribute("ServerEntity", nil)
                end)
            else
                -- Add to inventory
            end

            World:set(Player_Entity, Components.Opens, Opens + 1)

            World:delete(Block_Entity)
        end)
    end
end

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = Open_Blocks,
    runConditions = {},
}
