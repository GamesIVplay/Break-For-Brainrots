local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Jecs = require(ReplicatedStorage.Packages.Jecs)
local Pair = Jecs.pair

local Network = require(ServerScriptService.Network)

local Components = require(ReplicatedStorage.Common.Components)
local Log = require(ReplicatedStorage.Common.Log)
local Phases = require(ReplicatedStorage.Common.Phases)
local Types = require(ReplicatedStorage.Common.Types)
local World = require(ReplicatedStorage.Common.World)

local Generate_Brainrot_Model = require(ReplicatedStorage.Common.Modules.Generate_Brainrot_Model)
local Pickaxes = require(ReplicatedStorage.Common.Modules.Pickaxes)
local Update_Brainrot_Overhead = require(ReplicatedStorage.Common.Modules.Update_Brainrot_Overhead)
local Util = require(ReplicatedStorage.Common.Modules.Util)

local Player_Entities = World:query(Components.Player):cached()

local function Remove_Pickaxe_Tool(Player: Player, Character: Model)
    for _, Inst in Player.Backpack:GetChildren() do
        if Inst:HasTag("Pickaxe") then
            Inst:Destroy()
        end
    end

    for _, Inst in Character:GetChildren() do
        if Inst:HasTag("Pickaxe") then
            Inst:Destroy()
        end
    end
end

local function Add_Pickaxe_Tool(Player: Player, Name: string)
    local Data = Pickaxes[Name]

    local Existing_Tools = {}

    for _, Inst in Player.Backpack:GetChildren() do
        if Inst:IsA("Tool") then
            table.insert(Existing_Tools, Inst)
            Inst.Parent = nil
        end
    end

    local Pickaxe_Tool = Data.Tool:Clone()

    Pickaxe_Tool.Parent = Player.Backpack
    Network.Setup_Tool.Fire(Player, Pickaxe_Tool)

    for _, Tool in Existing_Tools do
        Tool.Parent = Player.Backpack
    end
end

local function Replicate_Cash(Player: Player, Entity: Types.Entity)
    local Cash = World:get(Entity, Components.Cash)
    local Previous_Cash = World:get(Entity, Pair(Components.Relationships.Previous, Components.Cash))

    if Cash ~= Previous_Cash then
        Network.DataChanged.Cash.Fire(Player, Cash)

        World:set(Entity, Pair(Components.Relationships.Previous, Components.Cash), Cash)

        Log.Info(`{Player.Name}'s cash was changed to {Cash}`)
    end
end

local function Replicate_Rebirth(Player: Player, Entity: Types.Entity)
    local Rebirth = World:get(Entity, Components.Rebirth)
    local Previous_Rebirth = World:get(Entity, Pair(Components.Relationships.Previous, Components.Rebirth))

    if Rebirth ~= Previous_Rebirth then
        Network.DataChanged.Rebirth.Fire(Player, Rebirth)

        World:set(Entity, Pair(Components.Relationships.Previous, Components.Rebirth), Rebirth)

        Log.Info(`{Player.Name}'s rebirth was changed to {Rebirth}`)
    end
end

local function Replicate_Pickaxe(Player: Player, Entity: Types.Entity)
    local Character = World:get(Entity, Components.Renderable)

    if not Character then
        return
    end

    local Pickaxe = World:get(Entity, Components.Pickaxe)
    local Previous_Pickaxe = World:get(Entity, Pair(Components.Relationships.Previous, Components.Pickaxe))

    if Pickaxe ~= Previous_Pickaxe then
        Remove_Pickaxe_Tool(Player, Character)
        Add_Pickaxe_Tool(Player, Pickaxe)

        Network.DataChanged.Pickaxe.Fire(Player, Pickaxe)

        World:set(Entity, Pair(Components.Relationships.Previous, Components.Pickaxe), Pickaxe)

        Log.Info(`{Player.Name}'s pickaxe was changed to {Pickaxe}`)
    end
end

local function Replicate_Owned_Pickaxes(Player: Player, Entity: Types.Entity)
    local Owned_Pickaxes = World:get(Entity, Components.Owned_Pickaxes)
    local Previous_Owned_Pickaxes =
        World:get(Entity, Pair(Components.Relationships.Previous, Components.Owned_Pickaxes))

    if not Util.TablesAreEqual(Owned_Pickaxes, Previous_Owned_Pickaxes) then
        Network.DataChanged.Owned_Pickaxes.Fire(Player, Owned_Pickaxes)

        World:set(
            Entity,
            Pair(Components.Relationships.Previous, Components.Owned_Pickaxes),
            Util.CopyTable(Owned_Pickaxes, true)
        )

        Log.Info(`{Player.Name}'s pickaxes were changed`)
    end
end

local function Replicate_Opens(Player: Player, Entity: Types.Entity)
    local Opens = World:get(Entity, Components.Opens)
    local Previous_Opens = World:get(Entity, Pair(Components.Relationships.Previous, Components.Opens))

    if Opens ~= Previous_Opens then
        Network.DataChanged.Opens.Fire(Player, Opens)

        World:set(Entity, Pair(Components.Relationships.Previous, Components.Opens), Opens)

        Log.Info(`{Player.Name}'s opens was changed to {Opens}`)
    end
end

local function Replicate_Gamepasses(Player: Player, Entity: Types.Entity)
    local Gamepasses = World:get(Entity, Components.Gamepasses)
    local Previous_Gamepasses = World:get(Entity, Pair(Components.Relationships.Previous, Components.Gamepasses))

    if not Util.TablesAreEqual(Gamepasses, Previous_Gamepasses) then
        Network.DataChanged.Gamepasses.Fire(Player, Gamepasses)

        World:set(
            Entity,
            Pair(Components.Relationships.Previous, Components.Gamepasses),
            Util.CopyTable(Gamepasses, true)
        )

        Log.Info(`{Player.Name}'s gamepasses were changed`)
    end
end

local function Replicate_Stock(Player: Player, Entity: Types.Entity)
    local Stock = World:get(Entity, Components.Stock)
    local Previous_Stock = World:get(Entity, Pair(Components.Relationships.Previous, Components.Stock))

    if not Util.TablesAreEqual(Stock, Previous_Stock) then
        Network.DataChanged.Stock.Fire(Player, Stock)

        World:set(Entity, Pair(Components.Relationships.Previous, Components.Stock), Util.CopyTable(Stock, true))

        Log.Info(`{Player.Name}'s stock was changed`)
    end
end

local function Replicate_Last_Restock(Player: Player, Entity: Types.Entity)
    local Last_Restock = World:get(Entity, Components.Last_Restock)
    local Previous_Last_Restock = World:get(Entity, Pair(Components.Relationships.Previous, Components.Last_Restock))

    if Last_Restock ~= Previous_Last_Restock then
        Network.DataChanged.Last_Restock.Fire(Player, Last_Restock)

        World:set(Entity, Pair(Components.Relationships.Previous, Components.Last_Restock), Last_Restock)

        Log.Info(`{Player.Name}'s last restock was changed`)
    end
end

local function Replicate_Upgrades(Player: Player, Entity: Types.Entity)
    local Upgrades = World:get(Entity, Components.Upgrades)
    local Previous_Upgrades = World:get(Entity, Pair(Components.Relationships.Previous, Components.Upgrades))

    if not Util.TablesAreEqual(Previous_Upgrades, Upgrades) then
        Network.DataChanged.Upgrades.Fire(Player, Upgrades)

        World:set(Entity, Pair(Components.Relationships.Previous, Components.Upgrades), Util.CopyTable(Upgrades, true))

        Log.Info(`{Player.Name}'s upgrades were changed`)
    end
end

local function Replicate_Brainrot_Inventory(Player: Player, Entity: Types.Entity)
    local Character = World:get(Entity, Components.Renderable)

    if not Character then
        return
    end

    local Brainrot_Inventory = World:get(Entity, Components.Brainrot_Inventory) :: { [number]: Types.Brainrot_Item }

    local Existing_Tools = {}

    for _, Inst: Instance in Player.Backpack:GetChildren() do
        if Inst:IsA("Tool") and Inst:HasTag("Brainrot") then
            local Index = Inst:GetAttribute("Index")
            if Index then
                Existing_Tools[Index] = Inst
            end
        end
    end

    for _, Inst: Instance in Player.Character:GetChildren() do
        if Inst:IsA("Tool") and Inst:HasTag("Brainrot") then
            local Index = Inst:GetAttribute("Index")
            if Index then
                Existing_Tools[Index] = Inst
            end
        end
    end

    local Slots_To_Keep = {}

    for Index = 1, #Brainrot_Inventory do
        local Brainrot_Item = Brainrot_Inventory[Index]
        if not Brainrot_Item then
            continue
        end

        Slots_To_Keep[Index] = true

        local Old_Tool = Existing_Tools[Index]

        if Old_Tool then
            local Name_Match = Old_Tool:GetAttribute("Name") == Brainrot_Item.Name
            local Primary_Match = Old_Tool:GetAttribute("Primary_Mutation") == Brainrot_Item.Primary_Mutation
            local Secondary_Match = Old_Tool:GetAttribute("Secondary_Mutations")
                == table.concat(Brainrot_Item.Secondary_Mutations, ",")
            local Weight_Match = Old_Tool:GetAttribute("Weight") == Brainrot_Item.Weight

            if Name_Match and Primary_Match and Secondary_Match and Weight_Match then
                continue
            else
                Old_Tool:Destroy()
            end
        end

        local Brainrot_Name = Brainrot_Item.Name
        local Primary_Mutation = Brainrot_Item.Primary_Mutation
        local Secondary_Mutations = Brainrot_Item.Secondary_Mutations
        local Weight = Brainrot_Item.Weight

        local Tool_Name

        local New_Tool = Instance.new("Tool")

        if Primary_Mutation then
            New_Tool:SetAttribute("Primary_Mutation", Primary_Mutation)
            Tool_Name = string.format("[%s] %s", Primary_Mutation, Brainrot_Name)
        else
            Tool_Name = string.format("[%.1f kg] %s", Weight, Brainrot_Name)
        end

        New_Tool.Name = Tool_Name
        New_Tool.ToolTip = Tool_Name
        New_Tool:SetAttribute("Name", Brainrot_Name)
        New_Tool:SetAttribute("Secondary_Mutations", table.concat(Secondary_Mutations, ","))
        New_Tool:SetAttribute("Weight", Weight)
        New_Tool:SetAttribute("Index", Index)
        New_Tool:AddTag("Brainrot")

        local Brainrot_Model, _, Extents =
            Generate_Brainrot_Model(Brainrot_Name, Primary_Mutation, Secondary_Mutations, Weight)

        Update_Brainrot_Overhead(Brainrot_Model, {
            Brainrot_Name = Brainrot_Name,
            Primary_Mutation = Primary_Mutation,
            Secondary_Mutations = Secondary_Mutations,
            Weight = Weight,
        })

        New_Tool.Grip = CFrame.new(0, 0, Extents.Z / 3)

        local Handle = Brainrot_Model.PrimaryPart
        Handle.Name = "Handle"

        for _, Inst: Instance in Brainrot_Model:GetDescendants() do
            if Inst:IsA("BasePart") then
                Inst.Massless = true
                Inst.CanCollide = false
                Inst.Anchored = false

                if Inst == Handle then
                    continue
                end

                local Weld = Instance.new("WeldConstraint")
                Weld.Part0 = Handle
                Weld.Part1 = Inst
                Weld.Parent = Handle
            end
        end

        for _, Inst in Brainrot_Model:GetChildren() do
            Inst.Parent = New_Tool
        end

        New_Tool.Parent = Player.Backpack
    end

    for Slot, Tool in Existing_Tools do
        if not Slots_To_Keep[Slot] then
            Tool:Destroy()
        end
    end
end

return {
    name = script.Name,
    phase = Phases.Runservice.PostUpdate,
    system = function()
        for Entity, Player in Player_Entities:iter() do
            Replicate_Cash(Player, Entity)

            Replicate_Rebirth(Player, Entity)

            Replicate_Pickaxe(Player, Entity)

            Replicate_Owned_Pickaxes(Player, Entity)

            Replicate_Opens(Player, Entity)

            Replicate_Gamepasses(Player, Entity)

            Replicate_Stock(Player, Entity)

            Replicate_Last_Restock(Player, Entity)

            Replicate_Upgrades(Player, Entity)

            Replicate_Brainrot_Inventory(Player, Entity)
        end
    end,
    runConditions = {},
}
