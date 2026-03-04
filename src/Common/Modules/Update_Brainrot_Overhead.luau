local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local UIGradients = Assets:WaitForChild("UIGradients") :: Folder

local Billboards = Assets:WaitForChild("Billboards")
local Brainrot_Overhead = Billboards:WaitForChild("Brainrot_Overhead") :: BillboardGui

local Brainrots = require(ReplicatedStorage.Common.Modules.Brainrots)
local Secondary_Mutations = require(ReplicatedStorage.Common.Modules.Secondary_Mutations)
local Stat_Calculator = require(ReplicatedStorage.Common.Modules.Stat_Calculator)
local Util = require(ReplicatedStorage.Common.Modules.Util)

return function(
    Brainrot_Model: Model,
    Data: {
        Level: number,
        Experience: number,
        Brainrot_Name: string,
        Primary_Mutation: string?,
        Secondary_Mutations: { string },
        Weight: number,
    }
)
    local Brainrot_Rarity = Brainrots[Data.Brainrot_Name].Rarity
    local Xp_Needed = Stat_Calculator.Calculate_Xp_Needed(Data.Level)

    local Overhead_Attachment = Brainrot_Model:FindFirstChild("Overhead_Attachment", true) :: Attachment
    local Billboard = Overhead_Attachment:FindFirstChild("Brainrot_Overhead") :: BillboardGui

    if not Billboard then
        Billboard = Brainrot_Overhead:Clone()
        Billboard.Parent = Overhead_Attachment
    end

    local Level = Billboard:FindFirstChild("Level") :: TextLabel
    Level.Text = `Level {Data.Level} ({Data.Experience}/{Xp_Needed})`

    local Name = Billboard:FindFirstChild("Name") :: TextLabel
    Name.Text = string.format("[%.1f kg] %s", Data.Weight, Data.Brainrot_Name)

    local Rarity = Billboard:FindFirstChild("Rarity") :: TextLabel
    Rarity.Text = Brainrots[Data.Brainrot_Name].Rarity

    local Rarity_UIGradient = Rarity:FindFirstChildOfClass("UIGradient")

    if Rarity_UIGradient and Rarity_UIGradient.Name ~= Brainrot_Rarity then
        Rarity_UIGradient:Destroy()
        Rarity_UIGradient = nil
    end

    if not Rarity_UIGradient then
        UIGradients:FindFirstChild(Brainrot_Rarity):Clone().Parent = Rarity
    end

    local Primary_Mutation = Billboard:FindFirstChild("Primary_Mutation") :: TextLabel

    if Data.Primary_Mutation then
        Primary_Mutation.Text = Data.Primary_Mutation

        local Primary_Mutation_UIGradient = Primary_Mutation:FindFirstChildOfClass("UIGradient")

        if Primary_Mutation_UIGradient and Primary_Mutation_UIGradient.Name ~= Data.Primary_Mutation then
            Primary_Mutation_UIGradient:Destroy()
            Primary_Mutation_UIGradient = nil
        end

        if not Primary_Mutation_UIGradient then
            UIGradients:FindFirstChild(Data.Primary_Mutation):Clone().Parent = Primary_Mutation
        end

        Primary_Mutation.Visible = true
    else
        Primary_Mutation.Visible = false
    end

    local Secondary_Mutations_Frame = Billboard:FindFirstChild("Secondary_Mutations") :: Frame
    local Template = Secondary_Mutations_Frame:FindFirstChild("Template") :: ImageLabel
    Template.Visible = false

    for _, Inst in Secondary_Mutations_Frame:GetChildren() do
        if not Inst:IsA("ImageLabel") or Inst == Template then
            continue
        end

        if not table.find(Data.Secondary_Mutations, Inst.Name) then
            Inst:Destroy()
        end
    end

    if #Data.Secondary_Mutations > 0 then
        for _, Mutation_Name in Data.Secondary_Mutations do
            if Secondary_Mutations_Frame:FindFirstChild(Mutation_Name) then
                continue
            end

            local Clone = Template:Clone()
            Clone.Name = Mutation_Name
            Clone.Image = Secondary_Mutations[Mutation_Name].Image
            Clone.Visible = true
            Clone.Parent = Secondary_Mutations_Frame
        end

        Secondary_Mutations_Frame.Visible = true
    else
        Secondary_Mutations_Frame.Visible = false
    end

    local Earnings = Billboard:FindFirstChild("Earnings") :: TextLabel

    local Income_Per_Sec = Stat_Calculator.Calculate_Income_Per_Sec({
        Level = Data.Level,
        Experience = Data.Experience,
        Brainrot_Name = Data.Brainrot_Name,
        Primary_Mutation = Data.Primary_Mutation,
        Secondary_Mutations = Data.Secondary_Mutations,
        Weight = Data.Weight,
    })

    Earnings.Text = `+{Util.Format_Number_With_Commas(Income_Per_Sec)}/s`
end
