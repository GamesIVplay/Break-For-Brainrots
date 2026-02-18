local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")
local Music = Sounds:WaitForChild("Music")

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local World = require(ReplicatedStorage.Common.World)

local Events = require(ReplicatedStorage.Common.Modules.Events)

local CurrentTrack = nil
local CurrentEvent = nil
local StopTrack = false

local function Pick_Random_Track(Tracks: { Sound })
    if #Tracks == 0 then
        return nil
    end

    return Tracks[math.random(1, #Tracks)]
end

local function Play_Track(Track: Sound)
    if not Track then
        return
    end

    if CurrentTrack == Track then
        return
    end

    if CurrentTrack then
        StopTrack = true
        CurrentTrack:Stop()
    end

    Track.Looped = false
    Track:Play()
    CurrentTrack = Track
    StopTrack = false

    task.spawn(function()
        Track.Ended:Wait()

        if not StopTrack and CurrentTrack == Track then
            CurrentTrack = nil
        end
    end)
end

local function Handle_Music()
    local ActiveEvents = World:get(Components.Singletons.Active_Events, Components.Singletons.Active_Events)

    local Target_Event = nil
    local Latest_Start_Time = -math.huge

    for Event_Name, EventInfo in pairs(ActiveEvents) do
        if EventInfo and Events[Event_Name] then
            if EventInfo.Start_Time > Latest_Start_Time then
                Latest_Start_Time = EventInfo.Start_Time
                Target_Event = Event_Name
            end
        end
    end

    if Target_Event then
        if CurrentEvent ~= Target_Event then
            CurrentEvent = Target_Event

            local Tracks = Events[Target_Event].Music

            local Track = Pick_Random_Track(Tracks)
            Play_Track(Track)
        elseif not CurrentTrack then
            local Tracks = Events[Target_Event].Music

            local Track = Pick_Random_Track(Tracks)
            Play_Track(Track)
        end
    else
        if CurrentEvent then
            StopTrack = true
            CurrentTrack:Stop()
            CurrentTrack = nil
        end

        CurrentEvent = nil
    end

    if CurrentTrack then
        return
    end

    local Normal_Tracks = Music:FindFirstChild("Normal"):GetChildren()
    local Track = Pick_Random_Track(Normal_Tracks)

    Play_Track(Track)
end

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = Handle_Music,
    runConditions = {},
}
