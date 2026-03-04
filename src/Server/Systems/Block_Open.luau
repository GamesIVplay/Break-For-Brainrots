local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Network = require(ServerScriptService.Network)

local New_Brainrot_Entity = require(ServerScriptService.Server.Modules.New_Brainrot_Entity)
local Slot_Util = require(ServerScriptService.Server.Modules.Slot_Util)

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Types = require(ReplicatedStorage.Common.Types)
local World = require(ReplicatedStorage.Common.World)

local Blocks = require(ReplicatedStorage.Common.Modules.Blocks)
local Roll_Primary_Mutation = require(ReplicatedStorage.Common.Modules.Roll_Primary_Mutation)
local Roll_Secondary_Mutation = require(ReplicatedStorage.Common.Modules.Roll_Secondary_Mutation)
local Stat_Calculator = require(ReplicatedStorage.Common.Modules.Stat_Calculator)
local Weight = require(ReplicatedStorage.Common.Modules.Weight)

local Brainrot_Capacity = Stat_Calculator.Get_Brainrot_Capacity()

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

        local Character = World:get(Player_Entity, Components.Renderable)

        if not Character then
            continue
        end

        local Player = World:get(Player_Entity, Components.Player)
        local Tutorial_Step = World:get(Player_Entity, Components.Tutorial_Step)
        local Gamepasses = World:get(Player_Entity, Components.Gamepasses)
        local Opens = World:get(Player_Entity, Components.Opens)
        local Brainrot_Inventory = World:get(Player_Entity, Components.Brainrot_Inventory)

        World:add(Block_Entity, Components.Tags.Opening)

        Block_Model.Parent = ReplicatedStorage:FindFirstChild("Temp")

        Network.VFX.Spawn_Debris.FireAll({
            Position = Block_Model.PrimaryPart.Position,
            Color = Blocks[Block_Name].Part_Color,
            Count = 6,
            Use_Rainbow_Colors = Block_Name == "Mythical",
        })

        local Mutation_Luck = Stat_Calculator.Get_Mutation_Luck(Player_Entity)

        local Rolled_Brainrot = Blocks[Block_Name].Roll_Brainrot()
        local Rolled_Primary_Mutation = Roll_Primary_Mutation(Tutorial_Step ~= 1 and Mutation_Luck or 300)
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

        task.delay(3.8, function()
            if not World:contains(Block_Entity) or not World:contains(Player_Entity) then
                return
            end

            if Tutorial_Step == 1 then
                World:set(Player_Entity, Components.Tutorial_Step, 3)
            end

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

            if Open_Stand then
                New_Brainrot_Entity(
                    Player_Entity,
                    Open_Stand,
                    Rolled_Brainrot,
                    Rolled_Primary_Mutation,
                    Rolled_Secondary_Mutations,
                    Rolled_Weight
                )
            else
                local Open_Slot = Slot_Util.Get_First_Open(Brainrot_Inventory, Brainrot_Capacity)

                if Open_Slot then
                    Brainrot_Inventory[Open_Slot] = {
                        Name = Rolled_Brainrot,
                        Primary_Mutation = Rolled_Primary_Mutation,
                        Secondary_Mutations = Rolled_Secondary_Mutations,
                        Weight = Rolled_Weight,
                        Cash = 0,
                        Offline_Cash = 0,
                    }
                else
                    Network.Notification.Fire(
                        Player,
                        { Text = `Your inventory is full ({Brainrot_Capacity}/{Brainrot_Capacity})`, Type = "Error" }
                    )
                end
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
