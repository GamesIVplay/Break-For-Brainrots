local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Network = require(ServerScriptService.Network)

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Types = require(ReplicatedStorage.Common.Types)
local World = require(ReplicatedStorage.Common.World)

local Calculate_Time_Till_Legendary_Reward =
    require(ReplicatedStorage.Common.Modules.Calculate_Time_Till_Legendary_Reward)
local Calculate_Time_Till_Mythical_Reward =
    require(ReplicatedStorage.Common.Modules.Calculate_Time_Till_Mythical_Reward)
local Util = require(ReplicatedStorage.Common.Modules.Util)

local Player_Block_Queue_Query = World:query(Components.Player, Components.Block_Queue):cached()

local Gave_Mythical = false
local Gave_Legendary = false

local function Update_Block_Countdown_Display()
    for _, Part: Part in CollectionService:GetTagged("Block Countdown") do
        local Mythical_Text = Part:FindFirstChild("Mythical", true) :: TextLabel
        local Rainbow_Text = Mythical_Text:FindFirstChild("RainbowText") :: TextLabel

        local Legendary_Text = Part:FindFirstChild("Legendary", true) :: TextLabel

        local T_Mythical = Util.BreakdownTime(Calculate_Time_Till_Mythical_Reward())
        local T_Legendary = Util.BreakdownTime(Calculate_Time_Till_Legendary_Reward())

        Mythical_Text.Text = `Mythic Block in {T_Mythical.Minutes}m {T_Mythical.Seconds}s`
        Rainbow_Text.Text = `Mythic Block in {T_Mythical.Minutes}m {T_Mythical.Seconds}s`

        Legendary_Text.Text =
            `<font color="#cf0000">Legendary Block</font> in {T_Legendary.Minutes}m {T_Legendary.Seconds}s`
    end
end

local function Give_Legendary_Reward()
    local SecondsRemaining = Calculate_Time_Till_Legendary_Reward()

    if SecondsRemaining > 0 then
        Gave_Legendary = false
        return
    end

    if Gave_Legendary then
        return
    end

    Gave_Legendary = true

    for Player_Entity: Types.Entity, Player: Player, Block_Queue: { string } in Player_Block_Queue_Query:iter() do
        table.insert(Block_Queue, "Legendary")

        Network.Notification.Fire(Player, {
            Text = `<font color="#cf0000">Legendary Block</font> added to queue!`,
            Type = "Info",
            Duration = 4,
        })
    end
end

local function Give_Mythical_Reward()
    local SecondsRemaining = Calculate_Time_Till_Mythical_Reward()

    if SecondsRemaining > 0 then
        Gave_Mythical = false
        return
    end

    if Gave_Mythical then
        return
    end

    Gave_Mythical = true

    for Player_Entity: Types.Entity, Player: Player, Block_Queue: { string } in Player_Block_Queue_Query:iter() do
        table.insert(Block_Queue, "Mythical")

        Network.Notification.Fire(Player, {
            Text = Util.Get_Rainbow_Text("Mythical Block added to queue!"),
            Type = "Info",
            Duration = 4,
        })
    end
end

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = function()
        Update_Block_Countdown_Display()

        Give_Legendary_Reward()

        Give_Mythical_Reward()
    end,
    runConditions = {},
}
