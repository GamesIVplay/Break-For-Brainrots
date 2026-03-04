local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage:WaitForChild("Assets")

local Highlights = Assets:WaitForChild("Highlights")
local Feed_Highlight = Highlights:WaitForChild("Feed") :: Highlight

local Billboards = Assets:WaitForChild("Billboards")
local Feed_Overhead = Billboards:WaitForChild("Feed_Overhead")

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local World = require(ReplicatedStorage.Common.World)

local function Setup_Feed_Prompts()
    local Local_Entity = Registry.Get("Players", "Local")
    local Local_Player = World:get(Local_Entity, Components.Player)

    local Local_Character = World:get(Local_Entity, Components.Renderable)

    if not Local_Character then
        return
    end

    local Tool: Tool?

    for _, Inst in Local_Character:GetChildren() do
        if Inst:IsA("Tool") and Inst:HasTag("Food") then
            Tool = Inst
            break
        end
    end

    for _, Brainrot_Model: Model in workspace:FindFirstChild("Brainrots"):GetChildren() do
        if Local_Player.UserId ~= Brainrot_Model:GetAttribute("Owner") then
            continue
        end
        local Primary_Part = Brainrot_Model.PrimaryPart :: MeshPart

        if not Primary_Part then
            continue
        end

        local Overhead_Attachment = Primary_Part:FindFirstChild("Overhead_Attachment")

        if not Overhead_Attachment then
            continue
        end

        local Brainrot_Overhead = Overhead_Attachment:FindFirstChild("Brainrot_Overhead")

        if not Brainrot_Overhead then
            continue
        end

        local Overhead = Overhead_Attachment:FindFirstChild("Feed_Overhead")

        if not Overhead then
            Overhead = Feed_Overhead:Clone()
            Overhead.Parent = Overhead_Attachment
        end

        local Highlight = Primary_Part:FindFirstChildOfClass("Highlight")

        if not Highlight then
            Highlight = Feed_Highlight:Clone()
            Highlight.Parent = Primary_Part
        end

        Brainrot_Overhead.Enabled = Tool == nil
        Highlight.Enabled = Tool ~= nil
        Overhead.Enabled = Tool ~= nil
    end
end

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = function()
        Setup_Feed_Prompts()
    end,
    runConditions = {},
}
