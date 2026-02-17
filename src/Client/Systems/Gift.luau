local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Network = require(ReplicatedFirst.Network)

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local World = require(ReplicatedStorage.Common.World)

local Proximity = require(ReplicatedStorage.Common.Modules.Proximity)
local Ratelimits = require(ReplicatedStorage.Common.Modules.Ratelimits)

local function Setup_Gifting_Prompts()
    local Local_Entity = Registry.Get("Players", "Local")

    local Local_Character = World:get(Local_Entity, Components.Renderable)

    if not Local_Character then
        return
    end

    local Tool: Tool?

    for _, Inst in Local_Character:GetChildren() do
        if Inst:IsA("Tool") and Inst:HasTag("Brainrot") then
            Tool = Inst
            break
        end
    end

    for _, Character: Model in workspace:FindFirstChild("Characters"):GetChildren() do
        if Character == Local_Character then
            continue
        end

        local RootPart = Character:FindFirstChild("HumanoidRootPart")

        if not RootPart then
            continue
        end

        local Prompt = RootPart:FindFirstChildOfClass("ProximityPrompt")

        if not Prompt then
            Prompt = Proximity(RootPart, {
                ActionText = "Gift",
                HoldDuration = 0.5,
                MaxActivationDistance = 6,
            }, function()
                if not Ratelimits.Gift() then
                    return
                end

                local ServerEntity = Character:GetAttribute("ServerEntity")

                if not ServerEntity then
                    return
                end

                Network.Requests.Gift.Fire(ServerEntity)
            end)
        end

        if Tool then
            local Brainrot_Name = Tool:GetAttribute("Name") :: string
            local Primary_Mutation = Tool:GetAttribute("Primary_Mutation") :: string?

            Prompt.ObjectText = not Primary_Mutation and Brainrot_Name or `{Primary_Mutation} {Brainrot_Name}`
        end

        Prompt.Enabled = Tool ~= nil
    end
end

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = Setup_Gifting_Prompts,
    runConditions = {},
}
