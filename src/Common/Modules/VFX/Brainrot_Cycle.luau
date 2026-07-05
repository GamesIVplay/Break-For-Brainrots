local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Assets = ReplicatedStorage:WaitForChild("Assets")

local Sounds = Assets:WaitForChild("Sounds")
local World_Sounds = Sounds:WaitForChild("World")
local Cycle = World_Sounds:WaitForChild("Cycle") :: Sound
local Cycle_Result_Sound = World_Sounds:WaitForChild("Cycle_Result") :: Sound

local VFX = Assets:WaitForChild("VFX")
local Result = VFX:WaitForChild("Result") :: Attachment
local Spin = VFX:WaitForChild("Spin") :: Attachment

local Components = require(ReplicatedStorage.Common.Components)
local Registry = require(ReplicatedStorage.Common.Registry)
local World = require(ReplicatedStorage.Common.World)

local Blocks = require(ReplicatedStorage.Common.Modules.Blocks)
local Brainrots = require(ReplicatedStorage.Common.Modules.Brainrots)
local Generate_Brainrot_Model = require(ReplicatedStorage.Common.Modules.Generate_Brainrot_Model)
local Roll_Primary_Mutation = require(ReplicatedStorage.Common.Modules.Roll_Primary_Mutation)
local Roll_Secondary_Mutation = require(ReplicatedStorage.Common.Modules.Roll_Secondary_Mutation)
local Stat_Calculator = require(ReplicatedStorage.Common.Modules.Stat_Calculator)
local Update_Brainrot_Overhead = require(ReplicatedStorage.Common.Modules.Update_Brainrot_Overhead)
local Util = require(ReplicatedStorage.Common.Modules.Util)
local Weight = require(ReplicatedStorage.Common.Modules.Weight)

local Brainrot_Offset = Stat_Calculator.Get_Brainrot_Offset()

local CYCLE_DURATION = 0.5
local SHOWCASE_TIME = 3
local BOUNCE_TIME = 0.08
local FINAL_BOUNCE_TIME = 0.15
local CYCLE_INTERVAL = BOUNCE_TIME
local CYCLE_COUNT = math.floor(CYCLE_DURATION / CYCLE_INTERVAL + 0.5)
local FINAL_BOUNCE_SCALE_MULTIPLIER = 1.5
local CHAIN_TIMEOUT = 1.25 -- Seconds before chain resets
local PITCH_MIN = 1.0
local PITCH_MAX = 1.75
local PITCH_STEPS = CYCLE_COUNT -- How many collects to reach max pitch

local Brainrot_Tween_Info = TweenInfo.new(BOUNCE_TIME, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
local Final_Brainrot_Tween_Info = TweenInfo.new(FINAL_BOUNCE_TIME, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
local Final_Highlight_Tween_Info = TweenInfo.new(FINAL_BOUNCE_TIME, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

local ChainCount = 0
local LastCycleTime = os.clock()

local function Get_Cycle_Pitch(): number
    local now = os.clock()

    if LastCycleTime + CHAIN_TIMEOUT < now then
        ChainCount = 0
    end

    LastCycleTime = now
    ChainCount = ChainCount + 1

    local pitch = math.clamp(ChainCount / PITCH_STEPS + PITCH_MIN, PITCH_MIN, PITCH_MAX)

    if math.clamp((ChainCount + 1) / PITCH_STEPS + PITCH_MIN, PITCH_MIN, PITCH_MAX) == PITCH_MAX then
        ChainCount = 0
    end

    return pitch
end

local function Spawn_Spin_VFX(CF: CFrame)
    local Part = Instance.new("Part")
    Part.CFrame = CF
    Part.Size = Vector3.one
    Part.Transparency = 1
    Part.CanCollide = false
    Part.Anchored = true
    Part.Parent = workspace:FindFirstChild("Debris")

    local Attachment = Spin:Clone()
    Attachment.Parent = Part

    for _, Inst: ParticleEmitter in Attachment:GetDescendants() do
        if Inst:IsA("ParticleEmitter") then
            local EmitCount = Inst:GetAttribute("EmitCount") or 1
            Inst:Emit(EmitCount)
        end
    end

    Debris:AddItem(Part, 3)
end

local function Spawn_Result_VFX(CF: CFrame)
    local Part = Instance.new("Part")
    Part.CFrame = CF
    Part.Size = Vector3.one
    Part.Transparency = 1
    Part.CanCollide = false
    Part.Anchored = true
    Part.Parent = workspace:FindFirstChild("Debris")

    local Attachment = Result:Clone()
    Attachment.Parent = Part

    for _, Inst: ParticleEmitter in Attachment:GetDescendants() do
        if Inst:IsA("ParticleEmitter") then
            local EmitCount = Inst:GetAttribute("EmitCount") or 1
            Inst:Emit(EmitCount)
        end
    end

    Debris:AddItem(Part, 3)
end

local function Spawn_Cycle_Brainrot(
    Block_Name: string,
    Mutation_Luck: number,
    CF: CFrame,
    Final_Result: {
        Brainrot: string,
        Primary_Mutation: string?,
        Secondary_Mutations: { string },
        Weight: number?,
    }?
)
    local Rolled_Brainrot
    local Rolled_Primary_Mutation
    local Rolled_Secondary_Mutations
    local Rolled_Weight

    if Final_Result then
        Rolled_Brainrot = Final_Result.Brainrot
        Rolled_Primary_Mutation = Final_Result.Primary_Mutation
        Rolled_Secondary_Mutations = Final_Result.Secondary_Mutations
        Rolled_Weight = Final_Result.Weight
    else
        Rolled_Brainrot = Blocks[Block_Name].Roll_Brainrot()
        Rolled_Primary_Mutation = Roll_Primary_Mutation(Mutation_Luck)
        Rolled_Secondary_Mutations = Roll_Secondary_Mutation(Mutation_Luck)
        Rolled_Weight = Weight.Roll_Weight()
    end

    local Brainrot_Model, Offset =
        Generate_Brainrot_Model(Rolled_Brainrot, Rolled_Primary_Mutation, Rolled_Secondary_Mutations, Rolled_Weight)
    local Primary_Part = Brainrot_Model.PrimaryPart

    local Sound: Sound

    if not Final_Result then
        Sound = Cycle:Clone()
        Sound.PlaybackSpeed = Get_Cycle_Pitch()
    else
        Sound = Cycle_Result_Sound:Clone()
    end

    Sound.Parent = Primary_Part
    Sound:Play()

    local Highlight = Instance.new("Highlight")
    Highlight.FillColor = not Final_Result and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
    Highlight.FillTransparency = 0
    Highlight.OutlineTransparency = 1
    Highlight.DepthMode = Enum.HighlightDepthMode.Occluded
    Highlight.Parent = Brainrot_Model

    Brainrot_Model:AddTag("Idle")

    Brainrot_Model.Parent = workspace:FindFirstChild("Debris")

    local Brainrot_CF = CF * Offset * CFrame.new(Brainrot_Offset)
    Brainrot_Model:PivotTo(Brainrot_CF)

    local Original_Scale = Brainrot_Model:GetScale()
    local Target_Scale = not Final_Result and Original_Scale / 2 or 0.2

    Brainrot_Model:ScaleTo(Target_Scale)

    if Final_Result then
        Spawn_Result_VFX(Brainrot_CF)
    end

    Util.Tween_Model_Scale(
        Target_Scale,
        not Final_Result and Original_Scale or Original_Scale * FINAL_BOUNCE_SCALE_MULTIPLIER,
        not Final_Result and Brainrot_Tween_Info or Final_Brainrot_Tween_Info,
        Brainrot_Model
    )

    task.wait(not Final_Result and BOUNCE_TIME or FINAL_BOUNCE_TIME)

    if Final_Result then
        Debris:AddItem(Brainrot_Model, SHOWCASE_TIME)

        Util.Tween_Model_Scale(
            Original_Scale * FINAL_BOUNCE_SCALE_MULTIPLIER,
            Original_Scale,
            Final_Brainrot_Tween_Info,
            Brainrot_Model
        )

        task.wait(FINAL_BOUNCE_TIME)

        TweenService:Create(Highlight, Final_Highlight_Tween_Info, { FillTransparency = 1 }):Play()

        Update_Brainrot_Overhead(Brainrot_Model, {
            Brainrot_Name = Rolled_Brainrot,
            Primary_Mutation = Rolled_Primary_Mutation,
            Secondary_Mutations = Rolled_Secondary_Mutations,
            Weight = Rolled_Weight,
        })
    else
        Brainrot_Model:Destroy()
    end
end

local RARE_BRAINROTS = {
    "Mythical",
    "Legendary",
    "Secret",
}

return function(Data: {
    Block: string,
    Mutation_Luck: number,
    Brainrot_CF: CFrame,
    Spin_VFX_CF: CFrame,
    Owner: number,
    Rolled_Brainrot: { Name: string, Primary_Mutation: string?, Secondary_Mutations: { string }, Weight: number },
})
    Spawn_Spin_VFX(Data.Spin_VFX_CF)

    for _ = 1, CYCLE_COUNT do
        Spawn_Cycle_Brainrot(Data.Block, Data.Mutation_Luck, Data.Brainrot_CF)
    end

    local Brainrot_Rarity = Brainrots[Data.Rolled_Brainrot.Name].Rarity

    if Data.Owner == Players.LocalPlayer.UserId and table.find(RARE_BRAINROTS, Brainrot_Rarity) then
        local Notification = World:entity()
        World:set(Notification, Components.Text, `You rolled a {Brainrot_Rarity}!`)
        World:set(Notification, Components.Duration, 3)
        World:set(Notification, Components.Gradient, Brainrot_Rarity)
        World:set(Notification, Components.NotificationType, "Announcement")

        World:add(Notification, Components.Tags.Notification)

        local Local_Entity = Registry.Get("Players", "Local")

        local Character = Local_Entity and World:get(Local_Entity, Components.Renderable)

        if Character then
            require(ReplicatedStorage.Common.Modules.VFX.Confetti)(Character)
        end
    end

    Spawn_Cycle_Brainrot(Data.Block, Data.Mutation_Luck, Data.Brainrot_CF, {
        Brainrot = Data.Rolled_Brainrot.Name,
        Primary_Mutation = Data.Rolled_Brainrot.Primary_Mutation,
        Secondary_Mutations = Data.Rolled_Brainrot.Secondary_Mutations,
        Weight = Data.Rolled_Brainrot.Weight,
    })
end
