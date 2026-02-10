local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage:WaitForChild("Assets")

local VFX = Assets:WaitForChild("VFX")
local Spin = VFX:WaitForChild("Spin") :: Attachment

local Blocks = require(ReplicatedStorage.Common.Modules.Blocks)
local Generate_Brainrot_Model = require(ReplicatedStorage.Common.Modules.Generate_Brainrot_Model)
local Roll_Primary_Mutation = require(ReplicatedStorage.Common.Modules.Roll_Primary_Mutation)
local Roll_Secondary_Mutation = require(ReplicatedStorage.Common.Modules.Roll_Secondary_Mutation)
local Util = require(ReplicatedStorage.Common.Modules.Util)
local Weight = require(ReplicatedStorage.Common.Modules.Weight)

local CYCLE_DURATION = 1
local SHOWCASE_TIME = 3
local BOUNCE_TIME = 0.1
local BRAINROT_OFFSET = Vector3.new(0, 0.5, 0)

local Brainrot_Tween_Info = TweenInfo.new(BOUNCE_TIME, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

local function Spawn_Spin_Vfx(CF: CFrame)
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

local function Spawn_Cycle_Brainrot(
    Block_Name: string,
    Mutation_Luck: number,
    CF: CFrame,
    Result: {
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

    if Result then
        Rolled_Brainrot = Result.Brainrot
        Rolled_Primary_Mutation = Result.Primary_Mutation
        Rolled_Secondary_Mutations = Result.Secondary_Mutations
        Rolled_Weight = Result.Weight
    else
        Rolled_Brainrot = Blocks[Block_Name].Roll_Brainrot()
        Rolled_Primary_Mutation = Roll_Primary_Mutation(Mutation_Luck)
        Rolled_Secondary_Mutations = Roll_Secondary_Mutation(Mutation_Luck)
        Rolled_Weight = Weight.Roll_Weight()
    end

    local Brainrot_Model =
        Generate_Brainrot_Model(Rolled_Brainrot, Rolled_Primary_Mutation, Rolled_Secondary_Mutations, Rolled_Weight)

    if not Result then
        local Highlight = Instance.new("Highlight")
        Highlight.FillColor = Color3.fromRGB(0, 0, 0)
        Highlight.FillTransparency = 0
        Highlight.OutlineTransparency = 1
        Highlight.DepthMode = Enum.HighlightDepthMode.Occluded
        Highlight.Parent = Brainrot_Model
    end

    Brainrot_Model.Parent = workspace:FindFirstChild("Debris")
    local Extents = Brainrot_Model:GetExtentsSize()
    local Offset = CFrame.new(Vector3.new(0, Extents.Y / 2, 0))

    Brainrot_Model:PivotTo(CF * Offset * CFrame.new(BRAINROT_OFFSET))

    local Original_Scale = Brainrot_Model:GetScale()
    local Target_Scale = Original_Scale / 2

    Brainrot_Model:ScaleTo(Target_Scale)

    Util.Tween_Model_Scale(Target_Scale, Original_Scale, Brainrot_Tween_Info, Brainrot_Model)

    task.wait(BOUNCE_TIME)

    if Result then
        Brainrot_Model:AddTag("Idle")
        Debris:AddItem(Brainrot_Model, SHOWCASE_TIME)
    else
        Brainrot_Model:Destroy()
    end
end

return function(Data: {
    Block: string,
    Mutation_Luck: number,
    Brainrot_CF: CFrame,
    Spin_VFX_CF: CFrame,
    Owner: number,
    Rolled_Brainrot: { Name: string, Primary_Mutation: string?, Secondary_Mutations: { string }, Weight: number },
})
    Spawn_Spin_Vfx(Data.Spin_VFX_CF)

    local Start = os.time()

    while os.time() - Start < CYCLE_DURATION do
        Spawn_Cycle_Brainrot(Data.Block, Data.Mutation_Luck, Data.Brainrot_CF)
    end

    Spawn_Cycle_Brainrot(Data.Block, Data.Mutation_Luck, Data.Brainrot_CF, {
        Brainrot = Data.Rolled_Brainrot.Name,
        Primary_Mutation = Data.Rolled_Brainrot.Primary_Mutation,
        Secondary_Mutations = Data.Rolled_Brainrot.Secondary_Mutations,
        Weight = Data.Rolled_Brainrot.Weight,
    })
end
