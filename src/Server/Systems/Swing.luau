local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Network = require(ServerScriptService.Network)

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local Types = require(ReplicatedStorage.Common.Types)
local World = require(ReplicatedStorage.Common.World)

local Pickaxes = require(ReplicatedStorage.Common.Modules.Pickaxes)
local Ratelimits = require(ReplicatedStorage.Common.Modules.Ratelimits)
local Tutorial_Steps = require(ReplicatedStorage.Common.Modules.Tutorial_Steps)

local function Handle_Swing_Requests()
    for _, Player: Player, Block_Entity: Types.Entity? in Network.Requests.Swing.Iter() do
        if not Ratelimits.Swing_Rate_Limit(Player) then
            continue
        end

        local Player_Entity = Registry.Get("Players", Player)

        if not Player_Entity then
            continue
        end

        local Character = World:get(Player_Entity, Components.Renderable)

        if not Character then
            continue
        end

        local Plot_Entity = World:target(Player_Entity, Components.Relationships.Plot)

        if not Plot_Entity then
            continue
        end

        local Pickaxe = World:get(Player_Entity, Components.Pickaxe)

        if not Pickaxe then
            continue
        end

        Network.VFX.Swing.FireExcept(Player, Character)

        if
            not Block_Entity
            or not World:contains(Block_Entity)
            or not World:has(Block_Entity, Components.Tags.Block)
            or World:has(Block_Entity, Components.Tags.Opening)
        then
            continue
        end

        local Block_Model = World:get(Block_Entity, Components.Renderable)

        if not Block_Model then
            continue
        end

        local Block_Health = World:get(Block_Entity, Components.Health)

        if not Block_Health or Block_Health == 0 then
            continue
        end

        local Tutorial_Step = World:get(Player_Entity, Components.Tutorial_Step)

        if not Tutorial_Step then
            continue
        end

        if Tutorial_Step ~= 1 and Tutorial_Step < #Tutorial_Steps then
            Network.Notification.Fire(Player, {
                Text = "Complete the tutorial first",
                Type = "Error",
            })
            continue
        end

        local Block_Plot_Entity = World:target(Block_Entity, Components.Relationships.Owner)
        local Is_Own_Block = Block_Plot_Entity == Plot_Entity

        if not Is_Own_Block then
            local Plot_Owner_Entity = World:target(Block_Plot_Entity, Components.Relationships.Owner)

            if not Plot_Owner_Entity then
                continue
            end

            local Plot_Owner_Tutorial_Step = World:get(Plot_Owner_Entity, Components.Tutorial_Step)

            if not Plot_Owner_Tutorial_Step then
                continue
            end

            if Plot_Owner_Tutorial_Step < #Tutorial_Steps then
                Network.Notification.Fire(Player, {
                    Text = "Owner is still in the tutorial",
                    Type = "Error",
                })
                continue
            end
        end

        local Damage = Pickaxes[Pickaxe].Power

        if not Is_Own_Block then
            Damage = math.max(math.round(Damage / 2), 1)
        end

        local New_Health = math.max(Block_Health - Damage, 0)

        if New_Health == 0 then
            Network.VFX.Confetti.FireAll(Character)
        end

        World:set(Block_Entity, Components.Health, New_Health)

        Network.VFX.Block_Hit.FireExcept(Player, Block_Model)
    end
end

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = Handle_Swing_Requests,
    runConditions = {},
}
