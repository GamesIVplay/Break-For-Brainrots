local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Map = workspace:WaitForChild("Map")

local Shops = Map:WaitForChild("Shops")

local Pickaxes_Shop = Shops:WaitForChild("Pickaxes")
local Pickaxes_Exclamation_Billboard = Pickaxes_Shop:WaitForChild("Touch"):FindFirstChildOfClass("BillboardGui")

local Upgrades_Shop = Shops:WaitForChild("Upgrades")
local Upgrades_Exclamation_Billboard = Upgrades_Shop:WaitForChild("Touch"):FindFirstChildOfClass("BillboardGui")

local Assets = ReplicatedStorage:WaitForChild("Assets")

local VFX = Assets:WaitForChild("VFX")
local ArrowBeam = VFX:WaitForChild("ArrowBeam") :: Beam

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local Types = require(ReplicatedStorage.Common.Types)
local World = require(ReplicatedStorage.Common.World)

local Pickaxes = require(ReplicatedStorage.Common.Modules.Pickaxes)
local Rebirths = require(ReplicatedStorage.Common.Modules.Rebirths)
local Tutorial_Steps = require(ReplicatedStorage.Common.Modules.Tutorial_Steps)
local Upgrades = require(ReplicatedStorage.Common.Modules.Upgrades)

local PICKAXE_NOTIFY_INTERVAL = 30
local UPGRADE_NOTIFY_INTERVAL = 60
local REBIRTH_NOTIFY_INTERVAL = 45

local LastPickaxeNotify = 0
local LastUpgradeNotify = 0
local LastRebirthNotify = 0

local function Notify(Text: string)
    local Entity = World:entity()
    World:set(Entity, Components.Text, Text)
    World:set(Entity, Components.NotificationType, "Reward")
    World:set(Entity, Components.Duration, 6)
    World:add(Entity, Components.Tags.Notification)
end

local function Can_Upgrade_Pickaxe(Local_Entity: Types.Entity)
    local Cash = World:get(Local_Entity, Components.Cash)
    local Rebirth = World:get(Local_Entity, Components.Rebirth)
    local Owned_Pickaxes = World:get(Local_Entity, Components.Owned_Pickaxes)

    local Highest_Power = 0
    for _, Name in Owned_Pickaxes do
        local Data = Pickaxes[Name]
        if Data.Power > Highest_Power then
            Highest_Power = Data.Power
        end
    end

    local Next_Pickaxe = nil

    for Name, Data in Pickaxes do
        if table.find(Owned_Pickaxes, Name) then
            continue
        end

        if Data.Power > Highest_Power and Data.Price and Cash >= Data.Price and Rebirth >= Data.Rebirth then
            Next_Pickaxe = Name
        end
    end

    return Next_Pickaxe ~= nil
end

local function Can_Upgrade(Local_Entity: Types.Entity)
    local Cash = World:get(Local_Entity, Components.Cash)
    local Rebirth = World:get(Local_Entity, Components.Rebirth)
    local Player_Upgrades = World:get(Local_Entity, Components.Upgrades)

    for Upgrade_Name, Upgrade_Data in Upgrades do
        if Rebirth < Upgrade_Data.Rebirth then
            continue
        end

        local Current_Level = Player_Upgrades[Upgrade_Name] or 1
        local Next_Level_Data = Upgrade_Data.Levels[Current_Level + 1]

        if Next_Level_Data and Cash >= Next_Level_Data.Price then
            return true
        end
    end

    return false
end

local function Can_Rebirth(Local_Entity: Types.Entity)
    local Rebirth = World:get(Local_Entity, Components.Rebirth)
    local Plot_Income_Per_Sec = World:get(Local_Entity, Components.Plot_Income_Per_Sec)

    local Next_Rebirth_Data = Rebirths[Rebirth + 1]

    if not Next_Rebirth_Data then
        return false
    end

    if Plot_Income_Per_Sec < Next_Rebirth_Data.Requirement then
        return false
    end

    return true
end

local function Toggle_Pickaxe_Beam(Local_Entity: Types.Entity, Enabled: boolean)
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

    local Can_Upgrade = Can_Upgrade_Pickaxe(Local_Entity)

    local Pickaxe_Beam = CollectionService:GetTagged("Pickaxe_Beam")[1] :: Beam

    if not Pickaxe_Beam and Can_Upgrade then
        Pickaxe_Beam = ArrowBeam:Clone()
        Pickaxe_Beam.Attachment0 = RootAttachment
        Pickaxe_Beam.Parent = RootPart
        Pickaxe_Beam:AddTag("Pickaxe_Beam")
    elseif Pickaxe_Beam and not Can_Upgrade then
        Pickaxe_Beam:Destroy()
    end

    if not Can_Upgrade then
        return
    end

    Pickaxe_Beam.Attachment1 = Pickaxes_Shop:FindFirstChild("Touch"):FindFirstChildOfClass("Attachment")
end

local function Action_Notifier()
    local Local_Entity = Registry.Get("Players", "Local")
    if not Local_Entity then
        return
    end

    local Local_Player = World:get(Local_Entity, Components.Player)

    local Main = Local_Player.PlayerGui:WaitForChild("Main") :: ScreenGui

    local Left = Main:WaitForChild("Left") :: Frame
    local Rebirth_Exclamation = Left:FindFirstChild("Rebirth"):FindFirstChild("Exclamation") :: Frame
    local Upgrades_Exclamation = Left:FindFirstChild("Upgrades"):FindFirstChild("Exclamation") :: Frame

    local Tutorial_Step = World:get(Local_Entity, Components.Tutorial_Step)
    local Should_Notify = Tutorial_Step >= #Tutorial_Steps

    local currentTime = tick()

    if Can_Upgrade_Pickaxe(Local_Entity) then
        if currentTime - LastPickaxeNotify >= PICKAXE_NOTIFY_INTERVAL and Should_Notify then
            Notify("Stronger pickaxe available!")
            LastPickaxeNotify = currentTime
        end
        Pickaxes_Exclamation_Billboard.Enabled = true
        Toggle_Pickaxe_Beam(Local_Entity, true)
    else
        LastPickaxeNotify = 0
        Pickaxes_Exclamation_Billboard.Enabled = false
        Toggle_Pickaxe_Beam(Local_Entity, false)
    end

    if Can_Rebirth(Local_Entity) then
        if currentTime - LastRebirthNotify >= REBIRTH_NOTIFY_INTERVAL and Should_Notify then
            Notify("You can rebirth!")
            LastRebirthNotify = currentTime
        end
        Rebirth_Exclamation.Visible = true
    else
        LastRebirthNotify = 0
        Rebirth_Exclamation.Visible = false
    end

    if Can_Upgrade(Local_Entity) then
        if currentTime - LastUpgradeNotify >= UPGRADE_NOTIFY_INTERVAL and Should_Notify then
            -- Notify("An upgrade is available!")
            LastUpgradeNotify = currentTime
        end
        Upgrades_Exclamation.Visible = true
        Upgrades_Exclamation_Billboard.Enabled = true
    else
        LastUpgradeNotify = 0
        Upgrades_Exclamation.Visible = false
        Upgrades_Exclamation_Billboard.Enabled = false
    end
end

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = Action_Notifier,
    runConditions = {},
}
