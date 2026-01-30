if not game:IsLoaded() then
    game.Loaded:Wait()
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")
local Music = Sounds:WaitForChild("Music")

local Tracks = {}
for _, Track in Music:GetChildren() do
    if Track:IsA("Sound") then
        table.insert(Tracks, Track)
    end
end

if #Tracks == 0 then
    return
end

local function Shuffle(Tbl)
    for i = #Tbl, 2, -1 do
        local j = math.random(1, i)
        Tbl[i], Tbl[j] = Tbl[j], Tbl[i]
    end
end

while true do
    Shuffle(Tracks)
    for _, Track in ipairs(Tracks) do
        if Track.Parent ~= SoundService then
            Track.Parent = SoundService
        end
        Track.Looped = false
        Track:Play()
        Track.Ended:Wait()
    end
end
