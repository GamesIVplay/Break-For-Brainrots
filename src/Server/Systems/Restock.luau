local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Network = require(ServerScriptService.Network)

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Types = require(ReplicatedStorage.Common.Types)
local World = require(ReplicatedStorage.Common.World)

local Blocks = require(ReplicatedStorage.Common.Modules.Blocks)

local Restock_Query = World:query(Components.Player, Components.Last_Restock, Components.Stock):cached()

local RESTOCK_TIME = 60 * 5 -- 5 Minutes

return {
    name = script.Name,
    phase = Phases.Runservice.PreUpdate,
    system = function()
        for Player_Entity: Types.Entity, Player: Player, Last_Restock: number, Stock: { [string]: number } in
            Restock_Query:iter()
        do
            if os.time() - Last_Restock >= RESTOCK_TIME then
                table.clear(Stock)

                World:set(Player_Entity, Components.Last_Restock, os.time())

                Network.Notification.Fire(Player, {
                    Text = "The shop has been restocked!",
                    Type = "Info",
                    Duration = 4,
                })
            end

            for Block_Name, Block_Data in Blocks do
                if Stock[Block_Name] then
                    continue
                end

                if math.random() <= Block_Data.Restock_Chance then
                    Stock[Block_Name] = math.random(Block_Data.Minimum_Stock, Block_Data.Maximum_Stock)
                else
                    Stock[Block_Name] = 0
                end
            end
        end
    end,
    runConditions = {},
}
