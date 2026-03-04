local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage:WaitForChild("Assets")

local Billboards = Assets:WaitForChild("Billboards")
local Collect_Overhead = Billboards:WaitForChild("Collect_Overhead") :: BillboardGui

local Jecs = require(ReplicatedStorage.Packages.Jecs)
local Pair = Jecs.pair

local Ratelimit = require(ReplicatedStorage.Packages.Ratelimit)

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Types = require(ReplicatedStorage.Common.Types)
local World = require(ReplicatedStorage.Common.World)

local Stat_Calculator = require(ReplicatedStorage.Common.Modules.Stat_Calculator)
local Update_Brainrot_Overhead = require(ReplicatedStorage.Common.Modules.Update_Brainrot_Overhead)
local Util = require(ReplicatedStorage.Common.Modules.Util)

local Can_Generate = Ratelimit(1, 1)

local Cash_Generator_Query = World:query(
    Components.Renderable,
    Components.Level,
    Components.Experience,
    Components.Name,
    Components.Secondary_Mutations,
    Components.Weight,
    Components.Stand,
    Components.Cash,
    Components.Offline_Cash
)
    :with(Components.Tags.Brainrot, Pair(Components.Relationships.Owner, Jecs.Wildcard))
    :cached()

local function Generate_Brainrots_Cash()
    for
        Brainrot_Entity: Types.Entity,
        Brainrot_Model: Model,
        Level: number,
        Experience: number,
        Brainrot_Name: string,
        Secondary_Mutations: { string },
        Weight: number,
        Stand: Model,
        Cash: number,
        Offline_Cash: number
    in Cash_Generator_Query:iter() do
        local Owner_Entity = World:target(Brainrot_Entity, Components.Relationships.Owner)

        if not Owner_Entity then
            continue
        end

        local Primary_Mutation = World:get(Brainrot_Entity, Components.Primary_Mutation)

        Update_Brainrot_Overhead(Brainrot_Model, {
            Level = Level,
            Experience = Experience,
            Brainrot_Name = Brainrot_Name,
            Primary_Mutation = Primary_Mutation,
            Secondary_Mutations = Secondary_Mutations,
            Weight = Weight,
        })

        local Income_Per_Sec = Stat_Calculator.Calculate_Income_Per_Sec({
            Level = Level,
            Experience = Experience,
            Brainrot_Name = Brainrot_Name,
            Primary_Mutation = Primary_Mutation,
            Secondary_Mutations = Secondary_Mutations,
            Weight = Weight,
        })

        if Can_Generate(Brainrot_Entity) then
            Cash += math.round(Income_Per_Sec * Stat_Calculator.Get_Cash_Multiplier(Owner_Entity))
        end

        local Touch = Stand:FindFirstChild("Touch") :: Part

        local Overhead = Touch:FindFirstChildOfClass("BillboardGui") :: BillboardGui

        if not Overhead then
            Overhead = Collect_Overhead:Clone()
            Overhead.Parent = Touch

            Brainrot_Model.Destroying:Connect(function()
                Overhead:Destroy()
            end)
        end

        local Cash_Text_Label = Overhead:FindFirstChild("Cash") :: TextLabel
        local Offline_Cash_Text_Label = Overhead:FindFirstChild("Offline_Cash") :: TextLabel

        Cash_Text_Label.Text = `${Util.Format_Number_With_Commas(Cash)}`
        Offline_Cash_Text_Label.Text = `(Offline Cash: ${Util.Format_Number_With_Commas(Offline_Cash)})`

        if Offline_Cash > 0 then
            Offline_Cash_Text_Label.Visible = true
        else
            Offline_Cash_Text_Label.Visible = false
        end

        World:set(Brainrot_Entity, Components.Cash, Cash)
    end
end

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = Generate_Brainrots_Cash,
    runConditions = {},
}
