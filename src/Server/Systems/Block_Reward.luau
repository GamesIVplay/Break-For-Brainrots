local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Network = require(ServerScriptService.Network)

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Types = require(ReplicatedStorage.Common.Types)
local World = require(ReplicatedStorage.Common.World)

local Blocks = require(ReplicatedStorage.Common.Modules.Blocks)
local Calculate_Time_Till_Block_Reward = require(ReplicatedStorage.Common.Modules.Calculate_Time_Till_Block_Reward)
local Util = require(ReplicatedStorage.Common.Modules.Util)

local Player_Block_Queue_Query = World:query(Components.Player, Components.Block_Queue):cached()

local Gave_Blocks = false

local function Update_Block_Countdown_Display()
    for _, Part: Part in CollectionService:GetTagged("Block Countdown") do
        local Mythical_Text = Part:FindFirstChild("Mythical") :: TextLabel
        local RainbowText = Mythical_Text:FindFirstChild("RainbowText")

        local Secret_Text = Part:FindFirstChild("Secret") :: TextLabel

        local T = Util.BreakdownTime(Calculate_Time_Till_Block_Reward())

        local Time_Text = `{T.Minutes}m {T.Seconds}s`

        Mythical_Text.Text = `Mythic in {Time_Text}`
        RainbowText = `Mythic in {Time_Text}`

        Secret = `Secret in {Time_Text}`
    end
end

local function Give_Block_Rewards()
    local SecondsRemaining = Calculate_Time_Till_Block_Reward()

    if SecondsRemaining > 0 then
        Gave_Blocks = false
        return
    end

    if Gave_Blocks then
        return
    end

    Gave_Blocks = true

    for Player_Entity: Types.Entity, Player: Player, Block_Queue: { string } in Player_Block_Queue_Query:iter() do
        table.insert(Block_Queue, "Mythical")
        table.insert(Block_Queue, "Secret")

        Network.Notification.Fire(Player, {
            Text = `A Mythical and Seceret have been addded to queue!`,
            Type = "Info",
        })
    end
end

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = function()
        Update_Block_Countdown_Display()

        Give_Block_Rewards()
    end,
    runConditions = {},
}
