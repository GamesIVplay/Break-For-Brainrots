local CollectionService = game:GetService("CollectionService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage:WaitForChild("Assets")

local VFX = Assets:WaitForChild("VFX")
local ArrowBeam = VFX:WaitForChild("ArrowBeam") :: Beam

local Map = workspace:WaitForChild("Map") :: Folder
local Shops = Map:WaitForChild("Shops") :: Folder

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Peek = Fusion.peek

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local World = require(ReplicatedStorage.Common.World)

local Darkener = require(ReplicatedFirst.Client.Modules.ScreenDarkener).New(5)
local Fusion_Values = require(ReplicatedFirst.Client.Modules.Fusion_Values)
local Get_Target_Block = require(ReplicatedFirst.Client.Modules.Get_Target_Block)

local function Update_Darkener()
    local Local_Entity = Registry.Get("Players", "Local")

    local Local_Player = World:get(Local_Entity, Components.Player)
    local Tutorial_Step = World:get(Local_Entity, Components.Tutorial_Step)

    local Character = World:get(Local_Entity, Components.Renderable)

    if not Character then
        return
    end

    local RootPart = Character:FindFirstChild("HumanoidRootPart") :: Part

    if not RootPart then
        return
    end

    local RootAttachment = RootPart:FindFirstChild("RootAttachment") :: Attachment

    if not RootAttachment then
        return
    end

    local Plot_Model = World:get(Local_Entity, Components.Plot_Model)

    if not Plot_Model then
        return
    end

    local VFX_Needed = table.find({ 1, 3 }, Tutorial_Step)

    local Tutorial_VFX = CollectionService:GetTagged("Tutorial_VFX")[1] :: Beam

    if not Tutorial_VFX and VFX_Needed then
        Tutorial_VFX = ArrowBeam:Clone()
        Tutorial_VFX.Attachment0 = RootAttachment
        Tutorial_VFX.Parent = RootPart
        Tutorial_VFX:AddTag("Tutorial_VFX")
    elseif Tutorial_VFX and not VFX_Needed then
        Tutorial_VFX:Destroy()
    end

    if Tutorial_Step == 1 then
        local Block_Model = Get_Target_Block() :: Model?

        if not Block_Model then
            return
        end

        local Block_Model_Attachment = Block_Model.PrimaryPart:FindFirstChild("Tutorial_Attachment")
        if not Block_Model_Attachment then
            Block_Model_Attachment = Instance.new("Attachment")
            Block_Model_Attachment.Name = "Tutorial_Attachment"
            Block_Model_Attachment.Parent = Block_Model.PrimaryPart
        end

        Tutorial_VFX.Attachment1 = Block_Model_Attachment
    elseif Tutorial_Step == 3 then
        local Stands = Plot_Model:FindFirstChild("Stands")
        local Stand_One = Stands and Stands:FindFirstChild("1")
        local Touch = Stand_One and Stand_One:FindFirstChild("Touch") :: Part

        Darkener:Activate(Touch, 10)

        local Touch_Attachment = Touch:FindFirstChildOfClass("Attachment")

        if not Touch_Attachment then
            Touch_Attachment = Instance.new("Attachment")
            Touch_Attachment.Parent = Touch
        end

        Tutorial_VFX.Attachment1 = Touch_Attachment
    elseif Tutorial_Step == 4 then
        local Shops_Spawn = Shops:FindFirstChild("Spawn") :: Part

        if Peek(Fusion_Values.Screen) == "Pickaxes" then
            Darkener:Switch(
                Local_Player.PlayerGui:FindFirstChild("Main"):FindFirstChild("Frames"):FindFirstChild("Pickaxes"),
                5
            )
        elseif (Shops_Spawn.Position - RootPart.Position).magnitude > 25 then
            Darkener:Switch(
                Local_Player.PlayerGui:FindFirstChild("Main"):FindFirstChild("Top"):FindFirstChild("Shops"),
                10
            )
        else
            Darkener:Switch(workspace.Map.Shops.Pickaxes.Touch)
        end
    elseif Tutorial_Step >= 5 then
        Darkener:Deactivate()
    end
end

local function Tutorial()
    Update_Darkener()
end

return {
    name = script.Name,
    phase = Phases.Runservice.PreRender,
    system = Tutorial,
    runConditions = {},
}
