local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local Types = require(ReplicatedStorage.Common.Types)
local World = require(ReplicatedStorage.Common.World)

local Pickaxes = require(ReplicatedStorage.Common.Modules.Pickaxes)
local Rebirths = require(ReplicatedStorage.Common.Modules.Rebirths)
local Tutorial_Steps = require(ReplicatedStorage.Common.Modules.Tutorial_Steps)

local PICKAXE_NOTIFY_INTERVAL = 40
local REBIRTH_NOTIFY_INTERVAL = 60
local LastPickaxeNotify = 0
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

local function Action_Notifier()
    local Local_Entity = Registry.Get("Players", "Local")
    if not Local_Entity then
        return
    end

    local Tutorial_Step = World:get(Local_Entity, Components.Tutorial_Step)

    if Tutorial_Step < #Tutorial_Steps then
        return
    end

    local currentTime = tick()

    if Can_Upgrade_Pickaxe(Local_Entity) then
        if currentTime - LastPickaxeNotify >= PICKAXE_NOTIFY_INTERVAL then
            Notify("New pickaxe available!")
            LastPickaxeNotify = currentTime
        end
    else
        LastPickaxeNotify = 0
    end

    if Can_Rebirth(Local_Entity) then
        if currentTime - LastRebirthNotify >= REBIRTH_NOTIFY_INTERVAL then
            Notify("You can rebirth!")
            LastRebirthNotify = currentTime
        end
    else
        LastRebirthNotify = 0
    end
end

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = Action_Notifier,
    runConditions = {},
}
