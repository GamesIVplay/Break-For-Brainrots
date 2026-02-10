local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage:WaitForChild("Assets")

local Billboards = Assets:WaitForChild("Billboards")
local Block_Overhead = Billboards:WaitForChild("Block_Overhead") :: BillboardGui

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local World = require(ReplicatedStorage.Common.World)

local Blocks = require(ReplicatedStorage.Common.Modules.Blocks)

local Block_Overhead_Query =
    World:query(Components.Name, Components.Health, Components.Renderable):with(Components.Tags.Block):cached()

local function Update_Block_Overheads()
    for Block_Entity, Block_Name: string, Block_Health: number, Block_Model: Model in Block_Overhead_Query:iter() do
        local Max_Health = Blocks[Block_Name].Health

        local Overhead_Attachment = Block_Model:FindFirstChild("Overhead_Attachment", true)

        local Billboard = Overhead_Attachment:FindFirstChildOfClass("BillboardGui")

        if not Billboard then
            Billboard = Block_Overhead:Clone()
            Billboard.Parent = Overhead_Attachment
        end

        local Title = Billboard:FindFirstChild("Title") :: TextLabel

        local Health = Billboard:FindFirstChild("Health") :: Frame
        local Health_Inside = Health:FindFirstChild("Inside") :: Frame
        local Health_Title = Health:FindFirstChild("Title") :: Frame

        Title.Text = Block_Name

        Health_Inside.Size = UDim2.fromScale(math.clamp(Block_Health / Max_Health, 0, 1), 1)
        Health_Title.Text = `{Block_Health}/{Max_Health}`
    end
end

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = Update_Block_Overheads,
    runConditions = {},
}
