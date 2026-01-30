if not game:IsLoaded() then
    game.Loaded:Wait()
end

local AvatarEditorService = game:GetService("AvatarEditorService")
local GroupService = game:GetService("GroupService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local GroupId = require(ReplicatedStorage.Common.Modules.GroupId)

local Local_Player = Players.LocalPlayer

local function TryPromptGroup()
    local InGroup = false
    pcall(function()
        InGroup = Local_Player:IsInGroupAsync(GroupId)
    end)

    if InGroup then
        return
    end

    pcall(function()
        GroupService:PromptJoinAsync(GroupId)
    end)
end

local function TryPromptFavorite()
    if RunService:IsStudio() then
        return
    end

    pcall(function()
        AvatarEditorService:PromptSetFavorite(game.PlaceId, Enum.AvatarItemType.Asset, true)
    end)
end

task.delay(2, function()
    TryPromptGroup()
    task.wait(1)
    TryPromptFavorite()
end)
