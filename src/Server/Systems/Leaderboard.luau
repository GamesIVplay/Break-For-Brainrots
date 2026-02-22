local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayTime_Leaderboard_Data_Store = DataStoreService:GetOrderedDataStore("PlayTime")
local Open_Leaderboard_Data_Store = DataStoreService:GetOrderedDataStore("Open")

local Map = workspace:WaitForChild("Map")

local Leaderboards = Map:WaitForChild("Leaderboards")

local PlayTime_Leaderboard = Leaderboards:WaitForChild("PlayTime")
local PlayTime_Scrolling_Frame = PlayTime_Leaderboard:FindFirstChild("ScrollingFrame", true) :: ScrollingFrame

local Open_Leaderboard = Leaderboards:WaitForChild("Open")
local Open_Scrolling_Frame = Open_Leaderboard:FindFirstChild("ScrollingFrame", true) :: ScrollingFrame

local Ratelimit = require(ReplicatedStorage.Packages.Ratelimit)
local Can_Run = Ratelimit(1, 60 * 5)

local Log = require(ReplicatedStorage.Common.Log)
local Phases = require(ReplicatedStorage.Common.Phases)

local Util = require(ReplicatedStorage.Common.Modules.Util)

local MAX_ATTEMPTS = 3

local function Fetch_Leaderboard_Data(OrderedDataStore: OrderedDataStore)
    local Attempts = 0

    local New_Entries = {}

    while Attempts < MAX_ATTEMPTS do
        local Success, Error = pcall(function()
            local TopData = OrderedDataStore:GetSortedAsync(false, 20)

            for Index, Data in ipairs(TopData:GetCurrentPage()) do
                local UserId: number = Data.key
                local PlayerInfo = Util.Get_Player_Info(UserId)

                New_Entries[Index] = {
                    Name = PlayerInfo.Name,
                    Image = PlayerInfo.Image,
                    Value = Data.value,
                }
            end
        end)

        if Success then
            break
        else
            Log.Warn(`Failed to fetch leaderboard data :C`, Error)
            Attempts += 1
            task.wait(5 * Attempts)
        end
    end

    return New_Entries
end

local function Update_Open_Leaderboard()
    local Template = Open_Scrolling_Frame:WaitForChild("Template")
    Template.Visible = false

    local Entries = Fetch_Leaderboard_Data(Open_Leaderboard_Data_Store)

    for _, Inst in Open_Scrolling_Frame:GetChildren() do
        if Inst:HasTag("Can_Delete") then
            Inst:Destroy()
        end
    end

    for Rank, Data in Entries do
        local Clone = Template:Clone()
        Clone.Rank.ImageLabel.Image = Data.Image
        Clone.Rank.TextLabel.Text = Rank .. "."
        Clone.Username.TextLabel.Text = Data.Name
        Clone.Amount.TextLabel.Text = Util.Abbreviate_Number(Data.Value, 2)
        Clone:AddTag("Can_Delete")

        Clone.Visible = true
        Clone.Parent = Open_Scrolling_Frame
    end
end

local function Update_PlayTime_Leaderboard()
    local Template = PlayTime_Scrolling_Frame:WaitForChild("Template")
    Template.Visible = false

    local Entries = Fetch_Leaderboard_Data(PlayTime_Leaderboard_Data_Store)

    for _, Inst in PlayTime_Scrolling_Frame:GetChildren() do
        if Inst:HasTag("Can_Delete") then
            Inst:Destroy()
        end
    end

    for Rank, Data in Entries do
        local T = Util.BreakdownTime(Data.Value)

        local Clone = Template:Clone()
        Clone.Rank.ImageLabel.Image = Data.Image
        Clone.Rank.TextLabel.Text = Rank .. "."
        Clone.Username.TextLabel.Text = Data.Name
        Clone.Amount.TextLabel.Text = string.format("%02d:%02d:%02d", T.Hours, T.Minutes, T.Seconds)
        Clone:AddTag("Can_Delete")

        Clone.Visible = true
        Clone.Parent = PlayTime_Scrolling_Frame
    end
end

return {
    name = script.Name,
    phase = Phases.Runservice.PreUpdate,
    system = function()
        task.spawn(function()
            Update_Open_Leaderboard()

            Update_PlayTime_Leaderboard()
        end)
    end,
    runConditions = {
        function()
            return Can_Run()
        end,
    },
}
