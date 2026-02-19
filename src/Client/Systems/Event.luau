local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Map = workspace:FindFirstChild("Map")

local Ground = Map:WaitForChild("Ground")
local Grass = Ground:WaitForChild("Grass") :: Part
local Water = Ground:WaitForChild("Water") :: Part

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Lightings = Assets:WaitForChild("Lightings")

local Events_Folder = workspace:WaitForChild("Events") :: Folder

local Lighting = require(ReplicatedFirst.Client.Modules.Lighting)

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local World = require(ReplicatedStorage.Common.World)

local Events = require(ReplicatedStorage.Common.Modules.Events)

local GRASS_NORMAL_COLOR = Grass.Color
local WATER_NORMAL_COLOR = Water.Color

local Last_Loaded_Event_Name = nil

local function Setup_VFX_Parts(
    Active_Events: { [string]: { Start_Time: number, End_Time: number, Luck_Multiplier: number } }
)
    for _, Inst: Instance in Events_Folder:GetChildren() do
        if not Active_Events[Inst.Name] then
            Inst:Destroy()
        end
    end

    local Latest_Event_Name = nil
    local Latest_Start_Time = -math.huge

    for Name, EventInfo in pairs(Active_Events) do
        if not Events_Folder:FindFirstChild(Name) then
            local Event_Data = Events[Name]
            local VFX_Part = Event_Data.VFX:Clone()
            VFX_Part.Name = Name
            VFX_Part.Parent = Events_Folder
        end

        if EventInfo.Start_Time > Latest_Start_Time then
            Latest_Start_Time = EventInfo.Start_Time
            Latest_Event_Name = Name
        end
    end

    if Latest_Event_Name ~= Last_Loaded_Event_Name then
        if Latest_Event_Name then
            local Latest_Event_Data = Events[Latest_Event_Name]

            Lighting.Load(Latest_Event_Data.Lighting)
            Grass.Color = Latest_Event_Data.Grass_Color or GRASS_NORMAL_COLOR
            Water.Color = Latest_Event_Data.Water_Color or WATER_NORMAL_COLOR
        else
            Lighting.Load(Lightings:WaitForChild("Normal"))
            Grass.Color = GRASS_NORMAL_COLOR
            Water.Color = WATER_NORMAL_COLOR
        end

        Last_Loaded_Event_Name = Latest_Event_Name
    end
end

local function Handle_Events()
    local Active_Events = World:get(Components.Singletons.Active_Events, Components.Singletons.Active_Events)

    Setup_VFX_Parts(Active_Events)
end

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = Handle_Events,
    runConditions = {},
}
