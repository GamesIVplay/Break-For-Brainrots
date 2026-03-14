local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Network = require(ServerScriptService.Network)

local Slot_Util = require(ServerScriptService.Server.Modules.Slot_Util)

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Types = require(ReplicatedStorage.Common.Types)
local World = require(ReplicatedStorage.Common.World)

local Roll_Primary_Mutation = require(ReplicatedStorage.Common.Modules.Roll_Primary_Mutation)
local Roll_Secondary_Mutation = require(ReplicatedStorage.Common.Modules.Roll_Secondary_Mutation)
local Stat_Calculator = require(ReplicatedStorage.Common.Modules.Stat_Calculator)
local Weight = require(ReplicatedStorage.Common.Modules.Weight)

local Brainrot_Capacity = Stat_Calculator.Get_Brainrot_Capacity()

local Query = World:query(
    Components.Player,
    Components.Renderable,
    Components.Brainrot_Inventory,
    Components.Fusion_Machine,
    Components.Next_Fusion_Time
):cached()

return {
    name = script.Name,
    phase = Phases.Runservice.PreUpdate,
    system = function()
        for
            Player_Entity: Types.Entity,
            Player: Player,
            Character: Model,
            Brainrot_Inventory,
            Fusion_Machine: { Types.Brainrot_Item },
            Next_Fusion_Time: number
        in Query:iter() do
            if not (os.time() >= Next_Fusion_Time) then
                continue
            end

            local Brainrot_Names = {}

            for _, Data in Fusion_Machine do
                table.insert(Brainrot_Names, Data.Name)
            end

            if #Brainrot_Names ~= 4 then
                World:remove(Player_Entity, Components.Next_Fusion_Time)
                continue
            end

            local Mutation_Luck = Stat_Calculator.Get_Mutation_Luck(Player_Entity)

            local Fusion_Results = Stat_Calculator.Get_Fusion_Results(Brainrot_Names)

            local Result_Name = Fusion_Results[math.random(1, #Fusion_Results)]
            local Primary_Mutation = Roll_Primary_Mutation(Mutation_Luck)
            local Secondary_Mutation = Roll_Secondary_Mutation(Mutation_Luck)
            local Weight = Weight.Roll_Weight()

            local Open_Slot = Slot_Util.Get_First_Open(Brainrot_Inventory, Brainrot_Capacity)

            if Open_Slot then
                Brainrot_Inventory[Open_Slot] = {
                    Name = Result_Name,
                    Primary_Mutation = Primary_Mutation,
                    Secondary_Mutations = Secondary_Mutation,
                    Weight = Weight,
                    Cash = 0,
                    Offline_Cash = 0,
                }

                Network.VFX.Confetti.FireAll(Character)
                local Display_Name = Primary_Mutation and `{Primary_Mutation} {Result_Name}` or Result_Name
                Network.Notification.Fire(Player, {
                    Text = `You fused a {Display_Name}!`,
                    Type = "Success",
                })

                World:set(Player_Entity, Components.Fusion_Machine, {})
            else
                Network.Notification.Fire(
                    Player,
                    { Text = `Your inventory is full ({Brainrot_Capacity}/{Brainrot_Capacity})`, Type = "Error" }
                )
            end

            World:remove(Player_Entity, Components.Next_Fusion_Time)
        end
    end,
    runConditions = {},
}
