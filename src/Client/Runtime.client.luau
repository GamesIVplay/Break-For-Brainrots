if not game:IsLoaded() then
    game.Loaded:Wait()
end

local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local Log = require(ReplicatedStorage.Common.Log)
local Start = require(ReplicatedStorage.Common.Start)

local Systems = script.Parent.Systems

task.spawn(function()
    local Assets = game:GetDescendants()

    for _, Asset in Assets do
        ContentProvider:PreloadAsync({ Asset })
    end

    Log.Info(`{#Assets} Assets preloaded`)
end)

repeat
    local Success = pcall(function()
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
        StarterGui:SetCore("ResetButtonCallback", false)
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, true)
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
    end)

    if not Success then
        task.wait(1)
    end
until Success == true

Start({
    require(Systems.Cmdr),
    require(Systems.Init_Local_Entity),
    require(Systems.Brainrot_Cleaner),
    require(Systems.Brainrot_Culling),
    require(Systems.Map_Setup),
    require(Systems.User_Interface),
    require(Systems.Notification),
    require(Systems.Data_Receiver),
    require(Systems.Feed),
    require(Systems.Gift),
    require(Systems.Event),
    require(Systems.Music),
    require(Systems.Tutorial),
    require(Systems.Action_Notifier),
})

require(game:GetService("ReplicatedFirst").Network).ClientLoaded.Fire()
