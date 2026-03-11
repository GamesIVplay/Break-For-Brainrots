local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local World = require(ReplicatedStorage.Common.World)

local Brainrots_Folder = workspace:WaitForChild("Brainrots") :: Folder
local Culled_Brainrots_Folder = ReplicatedStorage:WaitForChild("Culled_Brainrots") :: Folder

local MAX_DISTANCE = 150
local MAX_DISTANCE_SQUARED = MAX_DISTANCE * MAX_DISTANCE

local function StoreBaseCF(model: Model)
    if model:GetAttribute("BaseCF_X") then
        return
    end

    local cf = model:GetPivot()
    local rx, ry, rz = cf:ToOrientation()

    model:SetAttribute("BaseCF_X", cf.X)
    model:SetAttribute("BaseCF_Y", cf.Y)
    model:SetAttribute("BaseCF_Z", cf.Z)

    model:SetAttribute("BaseCF_RX", rx)
    model:SetAttribute("BaseCF_RY", ry)
    model:SetAttribute("BaseCF_RZ", rz)
end

local function RestoreBaseCF(model: Model)
    local x = model:GetAttribute("BaseCF_X")
    if not x then
        return
    end

    local baseCF = CFrame.new(x, model:GetAttribute("BaseCF_Y"), model:GetAttribute("BaseCF_Z"))
        * CFrame.Angles(
            model:GetAttribute("BaseCF_RX"),
            model:GetAttribute("BaseCF_RY"),
            model:GetAttribute("BaseCF_RZ")
        )

    model:PivotTo(baseCF)
end

local function Update(Character_Position: Vector3, Brainrot_Model: Model)
    local Brainrot_Position = Brainrot_Model:GetPivot().Position
    local Offset = Brainrot_Position - Character_Position
    local DistanceSquared = Offset:Dot(Offset)

    if DistanceSquared > MAX_DISTANCE_SQUARED then
        if Brainrot_Model.Parent ~= Culled_Brainrots_Folder then
            Brainrot_Model.Parent = Culled_Brainrots_Folder

            if Brainrot_Model:HasTag("Idle") then
                Brainrot_Model:RemoveTag("Idle")
            end
        end
    else
        if not Brainrot_Model:GetAttribute("BaseCF_X") then
            StoreBaseCF(Brainrot_Model)
        end

        if Brainrot_Model.Parent ~= Brainrots_Folder then
            Brainrot_Model.Parent = Brainrots_Folder

            RestoreBaseCF(Brainrot_Model)
        end

        if not Brainrot_Model:HasTag("Idle") then
            Brainrot_Model:AddTag("Idle")
        end
    end
end

return {
    name = script.Name,
    phase = Phases.Runservice.PreRender,
    system = function()
        local Local_Entity = Registry.Get("Players", "Local")

        local Local_Character = World:get(Local_Entity, Components.Renderable)

        if not Local_Character then
            return
        end

        local Character_Position = Local_Character:GetPivot().Position

        for _, Brainrot_Model: Model in Brainrots_Folder:GetChildren() do
            Update(Character_Position, Brainrot_Model)
        end

        for _, Brainrot_Model: Model in Culled_Brainrots_Folder:GetChildren() do
            Update(Character_Position, Brainrot_Model)
        end
    end,
    runConditions = {},
}
