local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Network = require(ServerScriptService.Network)

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local World = require(ReplicatedStorage.Common.World)

local Blocks = require(ReplicatedStorage.Common.Modules.Blocks)

local function Handle_Block_Purchase_Requests()
    for _, Player: Player, Block_Name: string in Network.Requests.Buy_Block.Iter() do
        local Player_Entity = Registry.Get("Players", Player)

        if not Player_Entity then
            continue
        end

        local Character = World:get(Player_Entity, Components.Renderable)

        if not Character then
            continue
        end

        local Block_Data = Blocks[Block_Name]

        if not Block_Data or not Block_Data.Price then
            Network.Notification.Fire(Player, {
                Text = "Invalid Block",
                Type = "Error",
            })
            continue
        end

        local Cash = World:get(Player_Entity, Components.Cash)

        if Cash < Block_Data.Price then
            Network.Notification.Fire(Player, {
                Text = "You don't have enough cash",
                Type = "Error",
            })
            continue
        end

        local Stock = World:get(Player_Entity, Components.Stock)

        if Stock[Block_Name] == nil or Stock[Block_Name] == 0 then
            Network.Notification.Fire(Player, {
                Text = "This block is out of stock",
                Type = "Error",
            })
            continue
        end

        local Block_Queue = World:get(Player_Entity, Components.Block_Queue)

        table.insert(Block_Queue, Block_Name)

        Stock[Block_Name] = math.max(Stock[Block_Name] - 1, 0)

        World:set(Player_Entity, Components.Cash, Cash - Block_Data.Price)

        Network.Notification.Fire(Player, {
            Text = `You bought a {Block_Name} Block!`,
            Type = "Success",
        })

        Network.VFX.Buy.FireAll(Character)
    end
end

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = Handle_Block_Purchase_Requests,
    runConditions = {},
}
