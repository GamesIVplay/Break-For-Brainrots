local CollectionService = game:GetService("CollectionService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ImpactHaptic = Instance.new("HapticEffect")
ImpactHaptic.Position = Vector3.new(0, 0, 0)
ImpactHaptic.Radius = 1
ImpactHaptic.Type = Enum.HapticEffectType.UIHover
ImpactHaptic.Parent = workspace

local VFX = ReplicatedStorage.Common.Modules.VFX

local Network = require(ReplicatedFirst.Network)

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local Types = require(ReplicatedStorage.Common.Types)
local World = require(ReplicatedStorage.Common.World)

local AnimPlayer = require(ReplicatedStorage.Common.Modules.AnimPlayer)
local Block_Hit = require(ReplicatedStorage.Common.Modules.VFX.Block_Hit)
local Proximity = require(ReplicatedStorage.Common.Modules.Proximity)
local Ratelimits = require(ReplicatedStorage.Common.Modules.Ratelimits)

local Fusion_Values = require(ReplicatedFirst.Client.Modules.Fusion_Values)

local Util = require(ReplicatedStorage.Common.Modules.Util)

local function Handle_Cash_Changes(Local_Entity: Types.Entity)
    for _, Value in Network.DataChanged.Cash.Iter() do
        World:set(Local_Entity, Components.Cash, Value)

        Fusion_Values.Cash:set(Value)
    end
end

local function Handle_Rebirth_Changes(Local_Entity: Types.Entity)
    for _, Value in Network.DataChanged.Rebirth.Iter() do
        World:set(Local_Entity, Components.Rebirth, Value)

        Fusion_Values.Rebirth:set(Value)
    end
end

local function Handle_Pickaxes_Changes(Local_Entity: Types.Entity)
    for _, Value in Network.DataChanged.Pickaxe.Iter() do
        World:set(Local_Entity, Components.Pickaxe, Value)

        Fusion_Values.Pickaxe:set(Value)
    end
end

local function Handle_Owned_Pickaxes_Changes(Local_Entity: Types.Entity)
    for _, Value in Network.DataChanged.Owned_Pickaxes.Iter() do
        World:set(Local_Entity, Components.Owned_Pickaxes, Value)

        Fusion_Values.Owned_Pickaxes:set(Value)
    end
end

local function Handle_Opens_Changes(Local_Entity: Types.Entity)
    for _, Value in Network.DataChanged.Opens.Iter() do
        World:set(Local_Entity, Components.Opens, Value)

        Fusion_Values.Opens:set(Value)
    end
end

local function Handle_Gamepass_Changes(Local_Entity: Types.Entity)
    for _, Value in Network.DataChanged.Gamepasses.Iter() do
        World:set(Local_Entity, Components.Gamepasses, Value)

        Fusion_Values.Gamepasses:set(Value)
    end
end

local function Handle_Stock_Changes(Local_Entity: Types.Entity)
    for _, Value in Network.DataChanged.Stock.Iter() do
        World:set(Local_Entity, Components.Stock, Value)

        Fusion_Values.Stock:set(Value)
    end
end

local function Handle_Last_Restock_Changes(Local_Entity: Types.Entity)
    for _, Value in Network.DataChanged.Last_Restock.Iter() do
        World:set(Local_Entity, Components.Last_Restock, Value)

        Fusion_Values.Last_Restock:set(Value)
    end
end

local function Handle_Upgrades_Changes(Local_Entity: Types.Entity)
    for _, Value in Network.DataChanged.Upgrades.Iter() do
        World:set(Local_Entity, Components.Upgrades, Value)

        Fusion_Values.Upgrades:set(Value)
    end
end

local function Handle_Buy_VFX()
    for _, Model: Model in Network.VFX.Buy.Iter() do
        if not Model:IsDescendantOf(game.Workspace) then
            continue
        end

        task.spawn(require(VFX.Buy), Model)
    end
end

local function Handle_Block_Spawn()
    for _, Model: Model in Network.VFX.Block_Spawn.Iter() do
        if not Model:IsDescendantOf(game.Workspace) then
            continue
        end

        task.spawn(require(VFX.Block_Spawn), Model)
    end
end

local function Handle_Block_Hit()
    for _, Model: Model in Network.VFX.Block_Hit.Iter() do
        if not Model:IsDescendantOf(game.Workspace) then
            continue
        end

        task.spawn(require(VFX.Block_Hit), Model)
    end
end

local function Handle_Brainrot_Cycle()
    for _, Data in Network.VFX.Brainrot_Cycle.Iter() do
        task.spawn(require(VFX.Brainrot_Cycle), Data)
    end
end

local function Handle_Swing()
    for _, Model: Model in Network.VFX.Swing.Iter() do
        if not Model:IsDescendantOf(game.Workspace) then
            continue
        end

        task.spawn(require(VFX.Swing), Model)
    end
end

local function Handle_Bounce_Brainrot()
    for _, Model: Model in Network.VFX.Bounce_Brainrot.Iter() do
        if not Model:IsDescendantOf(game.Workspace) then
            continue
        end

        task.spawn(require(VFX.Bounce_Brainrot), Model)
    end
end

local function Handle_Tool_Setup(Local_Entity: Types.Entity)
    for _, Tool: Tool in Network.Setup_Tool.Iter() do
        Tool.Activated:Connect(function()
            local Character = World:get(Local_Entity, Components.Renderable) :: Model?
            local RootPart = Character and Character:FindFirstChild("HumanoidRootPart") :: Part?
            local Animator = Character and Character:FindFirstChild("Animator", true) :: Animator?

            if not Character or not RootPart or not Animator then
                return
            end

            if not Ratelimits.Swing_Rate_Limit() then
                return
            end

            AnimPlayer.PlayAnimation(Animator, { Name = "Swing", Priority = Enum.AnimationPriority.Action })

            task.delay(0.2, function()
                task.spawn(require(VFX.Swing), Character)

                for _, Block_Model: Model in CollectionService:GetTagged("Block") do
                    if not Block_Model:IsDescendantOf(workspace:FindFirstChild("Blocks")) then
                        continue
                    end

                    if (RootPart.Position - Block_Model.PrimaryPart.Position).Magnitude <= 12 then
                        local Hit_Block_Entity = Block_Model:GetAttribute("ServerEntity")

                        Block_Hit(Block_Model)

                        ImpactHaptic:Play()

                        Network.Requests.Swing.Fire(Hit_Block_Entity)

                        return
                    end
                end

                Network.Requests.Swing.Fire()
            end)
        end)
    end
end

local function Handle_Sell_Prompt_Setup()
    for _, Data in Network.Setup_Sell_Prompt.Iter() do
        local Brainrot_Model = Data.Brainrot_Model
        local Sell_Price = Data.Sell_Price

        if not Brainrot_Model:IsDescendantOf(workspace) then
            continue
        end

        local ObjectText = not Data.Primary_Mutation and Data.Brainrot_Name
            or `{Data.Primary_Mutation} {Data.Brainrot_Name}`

        Proximity(Brainrot_Model.PrimaryPart, {
            ObjectText = ObjectText,
            ActionText = `Sell: ${Util.Abbreviate_Number(Sell_Price)}`,
            MaxActivationDistance = 7,
            Keycode = Enum.KeyCode.Q,
            GamepadKeyCode = Enum.KeyCode.ButtonY,
            HoldDuration = 1,
        }, function()
            if not Ratelimits.Sell() then
                return
            end

            local ServerEntity = Brainrot_Model:GetAttribute("ServerEntity")

            if ServerEntity then
                Network.Requests.Sell_Brainrot.Fire(ServerEntity)
            end
        end)
    end
end

local function Handle_Inventory_Changes(Local_Entity: Types.Entity)
    for _, Data in Network.DataChanged.Brainrot_Inventory.Iter() do
        World:set(Local_Entity, Components.Brainrot_Inventory, Data)

        Fusion_Values.Brainrot_Inventory:set(Data)
    end
end

local function Handle_Rebirth()
    for _, Model: Model in Network.VFX.Rebirth.Iter() do
        if not Model:IsDescendantOf(game.Workspace) then
            continue
        end

        task.spawn(require(VFX.Rebirth), Model)
    end
end

local function Handle_Index_Changes(Local_Entity: Types.Entity)
    for _, Data in Network.DataChanged.Index.Iter() do
        World:set(Local_Entity, Components.Index, Data)

        Fusion_Values.Index:set(Data)
    end
end

local function Handle_Robux_Purchase()
    for _, Model: Model in Network.VFX.Robux_Purchase.Iter() do
        if not Model:IsDescendantOf(game.Workspace) then
            continue
        end

        task.spawn(require(VFX.Robux_Purchase), Model)
    end
end

local function Handle_Active_Events()
    for _, Data in Network.DataChanged.Active_Events.Iter() do
        World:set(Components.Singletons.Active_Events, Components.Singletons.Active_Events, Data)

        Fusion_Values.Active_Events:set(Data)
    end
end

local function Handle_Last_Daily_Reward_Claim_Changes(Local_Entity: Types.Entity)
    for _, Data in Network.DataChanged.Last_Daily_Reward_Claim.Iter() do
        World:set(Local_Entity, Components.Last_Daily_Reward_Claim, Data)

        Fusion_Values.Last_Daily_Reward_Claim:set(Data)
    end
end

local function Handle_Claimed_Daily_Rewards_Changes(Local_Entity: Types.Entity)
    for _, Data in Network.DataChanged.Claimed_Daily_Rewards.Iter() do
        World:set(Local_Entity, Components.Claimed_Daily_Rewards, Data)

        Fusion_Values.Claimed_Daily_Rewards:set(Data)
    end
end

return {
    name = script.Name,
    phase = Phases.Runservice.First,
    system = function()
        local Local_Entity = Registry.Get("Players", "Local")

        Handle_Cash_Changes(Local_Entity)

        Handle_Rebirth_Changes(Local_Entity)

        Handle_Pickaxes_Changes(Local_Entity)

        Handle_Owned_Pickaxes_Changes(Local_Entity)

        Handle_Opens_Changes(Local_Entity)

        Handle_Gamepass_Changes(Local_Entity)

        Handle_Stock_Changes(Local_Entity)

        Handle_Last_Restock_Changes(Local_Entity)

        Handle_Upgrades_Changes(Local_Entity)

        Handle_Buy_VFX()

        Handle_Block_Spawn()

        Handle_Block_Hit()

        Handle_Brainrot_Cycle()

        Handle_Swing()

        Handle_Bounce_Brainrot()

        Handle_Tool_Setup(Local_Entity)

        Handle_Sell_Prompt_Setup()

        Handle_Inventory_Changes(Local_Entity)

        Handle_Rebirth()

        Handle_Index_Changes(Local_Entity)

        Handle_Robux_Purchase()

        Handle_Active_Events()

        Handle_Last_Daily_Reward_Claim_Changes(Local_Entity)

        Handle_Claimed_Daily_Rewards_Changes(Local_Entity)
    end,
    runConditions = {},
}
