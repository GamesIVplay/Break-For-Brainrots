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

local Calculate_Income_Per_Sec = require(ReplicatedStorage.Common.Modules.Calculate_Income_Per_Sec)
local Rebirths = require(ReplicatedStorage.Common.Modules.Rebirths)
local Util = require(ReplicatedStorage.Common.Modules.Util)

local Can_Generate = Ratelimit(1, 1)

local Cash_Generator_Query = World:query(
    Components.Renderable,
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

        local Gamepasses = World:get(Owner_Entity, Components.Gamepasses)

        if not Gamepasses then
            continue
        end

        local Rebirth = World:get(Owner_Entity, Components.Rebirth)

        if not Rebirth then
            continue
        end

        local Income_Per_Sec = Calculate_Income_Per_Sec({
            Brainrot_Name = Brainrot_Name,
            Primary_Mutation = World:get(Brainrot_Entity, Components.Primary_Mutation),
            Secondary_Mutations = Secondary_Mutations,
            Weight = Weight,
        })

        Income_Per_Sec *= Rebirths[Rebirth].Multiplier

        if Gamepasses and table.find(Gamepasses, "VIP") then
            Income_Per_Sec *= 1.25
        end

        if table.find(Gamepasses, "x2 Cash") then
            Income_Per_Sec *= 2
        end

        local NewCash = Cash

        if Can_Generate(Brainrot_Entity) then
            NewCash += math.round(Income_Per_Sec)
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

        Cash_Text_Label.Text = `${Util.Format_Number_With_Commas(NewCash)}`
        Offline_Cash_Text_Label.Text = `(Offline Cash: ${Util.Format_Number_With_Commas(Offline_Cash)})`

        if Offline_Cash > 0 then
            Offline_Cash_Text_Label.Visible = true
        else
            Offline_Cash_Text_Label.Visible = false
        end

        World:set(Brainrot_Entity, Components.Cash, NewCash)
    end
end

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = Generate_Brainrots_Cash,
    runConditions = {},
}
