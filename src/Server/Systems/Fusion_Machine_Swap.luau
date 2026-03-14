local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Network = require(ServerScriptService.Network)

local Slot_Util = require(ServerScriptService.Server.Modules.Slot_Util)

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local Types = require(ReplicatedStorage.Common.Types)
local World = require(ReplicatedStorage.Common.World)

local Ratelimits = require(ReplicatedStorage.Common.Modules.Ratelimits)
local Stat_Calculator = require(ReplicatedStorage.Common.Modules.Stat_Calculator)

local function Handle_Swap_Requests()
    for _, Player: Player, Index: number in Network.Requests.Fusion_Machine_Swap.Iter() do
        if not Ratelimits.Fusion_Machine_Swap(Player) then
            continue
        end

        if not table.find({ 1, 2, 3, 4 }, Index) then
            continue
        end

        local Player_Entity = Registry.Get("Players", Player)

        if not Player_Entity then
            continue
        end

        local Character = World:get(Player_Entity, Components.Renderable)

        if not Character then
            continue
        end

        local Brainrot_Inventory = World:get(Player_Entity, Components.Brainrot_Inventory)

        if not Brainrot_Inventory then
            continue
        end

        local Fusion_Machine = World:get(Player_Entity, Components.Fusion_Machine)

        if not Fusion_Machine then
            continue
        end

        if World:has(Player_Entity, Components.Next_Fusion_Time) then
            Network.Notification.Fire(Player, {
                Text = `You have a fusion in progress`,
                Type = "Error",
            })
            continue
        end

        local Current_Slot_Data = Fusion_Machine[Index]

        if Current_Slot_Data then
            local Brainrot_Capacity = Stat_Calculator.Get_Brainrot_Capacity()
            local Open_Slot = Slot_Util.Get_First_Open(Brainrot_Inventory, Brainrot_Capacity)

            if not Open_Slot then
                Network.Notification.Fire(Player, {
                    Text = `This players inventory is full ({Brainrot_Capacity}/{Brainrot_Capacity})`,
                    Type = "Error",
                })
                continue
            end

            Brainrot_Inventory[Open_Slot] = Current_Slot_Data
            Fusion_Machine[Index] = nil

            continue
        end
        local Tool: Tool?

        for _, Inst: Instance in Character:GetChildren() do
            if Inst:IsA("Tool") and Inst:HasTag("Brainrot") then
                Tool = Inst
                break
            end
        end

        if not Tool then
            Network.Notification.Fire(Player, {
                Text = "You must hold a brainrot",
                Type = "Error",
            })
            continue
        end

        local Tool_Index = Tool:GetAttribute("Index")
        local Brainrot_Item: Types.Brainrot_Item = Brainrot_Inventory[Tool_Index]

        Fusion_Machine[Index] = Brainrot_Item
        Brainrot_Inventory[Tool_Index] = nil
    end
end

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = Handle_Swap_Requests,
    runConditions = {},
}
