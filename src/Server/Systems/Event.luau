local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Network = require(ServerScriptService.Network)

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Types = require(ReplicatedStorage.Common.Types)
local World = require(ReplicatedStorage.Common.World)

local Blocks = require(ReplicatedStorage.Common.Modules.Blocks)
local Calculate_Time_Till_Next_Event = require(ReplicatedStorage.Common.Modules.Calculate_Time_Till_Next_Event)
local Events = require(ReplicatedStorage.Common.Modules.Events)
local Util = require(ReplicatedStorage.Common.Modules.Util)

local Player_Block_Queue_Query = World:query(Components.Player, Components.Block_Queue):cached()

local Started_Event = false

local Next_Event: {
    Name: string,
    Block_Name: string,
    Block_Amount: number,
    Luck_Multiplier: number,
}?

local Event_Names = {}
for Name in Events do
    table.insert(Event_Names, Name)
end

local Block_Names = { "Rare", "Epic", "Legendary" }

local function Choose_Next_Event()
    if Next_Event then
        return
    end

    Next_Event = {
        Name = Event_Names[math.random(1, #Event_Names)],
        Block_Name = Block_Names[math.random(1, #Block_Names)],
        Block_Amount = math.random(2, 3),
        Luck_Multiplier = math.random(2, 3),
    }
end
local function Update_Admin_Machine_Display()
    for _, Model: Model in CollectionService:GetTagged("Admin Machine") do
        local Event_Title = Model:FindFirstChild("Event_Title", true) :: TextLabel
        local Event_Image = Model:FindFirstChild("Event_Image", true) :: ImageLabel
        local Event_Block_Image = Model:FindFirstChild("Block_Image", true) :: ImageLabel
        local Event_Block_Amount = Model:FindFirstChild("Block_Amount", true) :: TextLabel
        local Event_Luck_Amount = Model:FindFirstChild("Luck_Amount", true) :: TextLabel
        local Remaining_Text_Label = Model:FindFirstChild("Remaining", true) :: TextLabel
        local Time_Till = Model:FindFirstChild("Time_Till", true) :: TextLabel

        Event_Title.Text = Next_Event.Name
        Event_Image.Image = Events[Next_Event.Name].Image
        Event_Block_Image.Image = Blocks[Next_Event.Block_Name].Image
        Event_Block_Amount.Text = `x{Next_Event.Block_Amount}`
        Event_Luck_Amount.Text = `x{Next_Event.Luck_Multiplier}`

        local T = Util.BreakdownTime(Calculate_Time_Till_Next_Event())

        local Time_Text = `{T.Minutes}m {T.Seconds}s`
        Remaining_Text_Label.Text = `{T.Minutes}m {T.Seconds}s`
        Time_Till.Text = `{Time_Text} till event`
    end
end

local function Start_Event()
    local Active_Events = World:get(Components.Singletons.Active_Events, Components.Singletons.Active_Events)

    local SecondsRemaining = Calculate_Time_Till_Next_Event()

    if SecondsRemaining > 0 then
        Started_Event = false
        return
    end

    if Started_Event then
        return
    end

    Started_Event = true

    Active_Events[Next_Event.Name] = {
        Start_Time = os.time(),
        End_Time = os.time() + Events[Next_Event.Name].Duration,
        Luck_Multiplier = Next_Event.Luck_Multiplier,
    }

    Network.Notification.FireAll({
        Text = `A {Next_Event.Name} Event Started!`,
        Type = "Info",
        Duration = 5,
    })

    for Player_Entity: Types.Entity, Player: Player, Block_Queue: { string } in Player_Block_Queue_Query:iter() do
        for i = 1, Next_Event.Block_Amount do
            table.insert(Block_Queue, Next_Event.Block_Name)
        end

        Network.Notification.Fire(Player, {
            Text = `Added x{Next_Event.Block_Amount} {Next_Event.Block_Name} Blocks to queue!`,
            Type = "Info",
        })
    end

    Next_Event = nil
end

local function Stop_Events()
    local Active_Events = World:get(Components.Singletons.Active_Events, Components.Singletons.Active_Events)

    for Event_Name, Data in Active_Events do
        if os.time() >= Data.End_Time then
            Active_Events[Event_Name] = nil
        end
    end
end

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = function()
        Choose_Next_Event()

        Update_Admin_Machine_Display()

        Start_Event()

        Stop_Events()
    end,
    runConditions = {},
}
