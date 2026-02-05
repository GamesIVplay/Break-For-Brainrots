local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local World = require(ReplicatedStorage.Common.World)

local Leaderstats_Query = World:query(Components.Player, Components.Cash, Components.Opens):cached()

return {
    name = script.Name,
    phase = Phases.Runservice.PostUpdate,
    system = function()
        for _, Player, Cash: number, Opens: number in Leaderstats_Query:iter() do
            local Leaderstats = Player:FindFirstChild("leaderstats")

            if not Leaderstats then
                Leaderstats = Instance.new("Folder")
                Leaderstats.Name = "leaderstats"
                Leaderstats.Parent = Player
            end

            local CashInstance = Leaderstats:FindFirstChild("💵 Cash")

            if not CashInstance then
                CashInstance = Instance.new("IntValue")
                CashInstance.Name = "💵 Cash"
                CashInstance.Parent = Leaderstats
            end

            CashInstance.Value = Cash

            local OpensInstance = Leaderstats:FindFirstChild("📦 Opens")

            if not OpensInstance then
                OpensInstance = Instance.new("IntValue")
                OpensInstance.Name = "📦 Opens"
                OpensInstance.Parent = Leaderstats
            end

            OpensInstance.Value = Opens
        end
    end,
    runConditions = {},
}
