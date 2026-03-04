local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage:WaitForChild("Assets")

local Billboards = Assets:WaitForChild("Billboards")
local Food_Overhead = Billboards:WaitForChild("Food_Overhead")

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Types = require(ReplicatedStorage.Common.Types)
local World = require(ReplicatedStorage.Common.World)

local Food = require(ReplicatedStorage.Common.Modules.Food)
local Util = require(ReplicatedStorage.Common.Modules.Util)

local Food_Update_Query =
    World:query(Components.Renderable, Components.Experience, Components.Name):with(Components.Tags.Food):cached()

local function Food_Updater()
    for Entity: Types.Entity, Model: Model, Xp: number, Current_Name: string in Food_Update_Query:iter() do
        local Food_Data = Food.Get_Data_From_Xp(Xp)

        if Food_Data.Name ~= Current_Name then
            local Pivot = Model:GetPivot()
            Model:Destroy()

            local New_Model = Food_Data.Model:Clone()
            New_Model:PivotTo(Pivot)
            New_Model:SetAttribute("IdlePreset", "Food")
            New_Model:AddTag("Idle")
            New_Model.Parent = workspace:FindFirstChild("Foods")

            World:set(Entity, Components.Renderable, New_Model)
            World:set(Entity, Components.Name, Food_Data.Name)

            World:set(Entity, Components.Cleanup, function()
                New_Model:Destroy()
            end)

            Model = New_Model
        end

        local Overhead_Attachment = Model:FindFirstChild("Overhead_Attachment", true) :: Attachment

        local Overhead = Overhead_Attachment:FindFirstChild("Food_Overhead")
        if not Overhead then
            Overhead = Food_Overhead:Clone()
            Overhead.Parent = Overhead_Attachment
        end

        local Title_Text = Overhead:FindFirstChild("Title") :: TextLabel
        local Xp_Frame_Inside = Overhead:FindFirstChild("Inside", true) :: Frame

        local Current_In_Tier = Xp - Food_Data.Tier_Start_Xp
        local Max_In_Tier = Food_Data.Next_Tier_Xp - Food_Data.Tier_Start_Xp

        local Current_Text = Util.Abbreviate_Number(Xp, 2)

        Title_Text.Text = string.format("+%s XP", Current_Text)

        local Alpha = math.clamp(Current_In_Tier / Max_In_Tier, 0, 1)
        Xp_Frame_Inside.Size = UDim2.fromScale(Alpha, 1)

        Model:ScaleTo(Food_Data.Scale)
    end
end

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = Food_Updater,
    runConditions = {},
}
