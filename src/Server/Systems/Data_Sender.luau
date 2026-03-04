local AnalyticsService = game:GetService("AnalyticsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Assets = ReplicatedStorage:WaitForChild("Assets")

local Billboards = Assets:WaitForChild("Billboards")
local Food_Overhead = Billboards:WaitForChild("Food_Overhead")

local Slot_Util = require(ServerScriptService.Server.Modules.Slot_Util)

local Jecs = require(ReplicatedStorage.Packages.Jecs)
local Pair = Jecs.pair

local Network = require(ServerScriptService.Network)

local Components = require(ReplicatedStorage.Common.Components)
local Log = require(ReplicatedStorage.Common.Log)
local Phases = require(ReplicatedStorage.Common.Phases)
local Types = require(ReplicatedStorage.Common.Types)
local World = require(ReplicatedStorage.Common.World)

local Food = require(ReplicatedStorage.Common.Modules.Food)
local Generate_Brainrot_Model = require(ReplicatedStorage.Common.Modules.Generate_Brainrot_Model)
local Pickaxes = require(ReplicatedStorage.Common.Modules.Pickaxes)
local Stat_Calculator = require(ReplicatedStorage.Common.Modules.Stat_Calculator)
local Tutorial_Steps = require(ReplicatedStorage.Common.Modules.Tutorial_Steps)
local Update_Brainrot_Overhead = require(ReplicatedStorage.Common.Modules.Update_Brainrot_Overhead)
local Util = require(ReplicatedStorage.Common.Modules.Util)

local Food_Capacity = Stat_Calculator.Get_Food_Capacity()
local Brainrot_Capacity = Stat_Calculator.Get_Brainrot_Capacity()

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
    local Previous_Brainrot_Inventory =
        World:get(Entity, Pair(Components.Relationships.Previous, Components.Brainrot_Inventory))

    if Util.TablesAreEqual(Previous_Brainrot_Inventory, Brainrot_Inventory) then
        return
    end

    local Serialized_Brainrot_Inventory: { Types.Brainrot_Item } = {}

    Slot_Util.For_Each(Brainrot_Inventory, Brainrot_Capacity, function(_, Brainrot_Item: Types.Brainrot_Item)
        table.insert(Serialized_Brainrot_Inventory, Brainrot_Item)
    end)

    Network.DataChanged.Brainrot_Inventory.Fire(Player, Serialized_Brainrot_Inventory)

    World:set(
        Entity,
        Pair(Components.Relationships.Previous, Components.Brainrot_Inventory),
        Util.CopyTable(Brainrot_Inventory, true)
    )

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

    for Index, Brainrot_Item in pairs(Brainrot_Inventory) do
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
            local Cash_Match = Old_Tool:GetAttribute("Cash") == Brainrot_Item.Cash
            local Offline_Cash_Match = Old_Tool:GetAttribute("Offline_Cash") == Brainrot_Item.Offline_Cash

            if
                Name_Match
                and Primary_Match
                and Secondary_Match
                and Weight_Match
                and Cash_Match
                and Offline_Cash_Match
            then
                continue
            else
                Old_Tool:Destroy()
            end
        end

        local Brainrot_Name = Brainrot_Item.Name
        local Primary_Mutation = Brainrot_Item.Primary_Mutation
        local Secondary_Mutations = Brainrot_Item.Secondary_Mutations
        local Weight = Brainrot_Item.Weight
        local Cash = Brainrot_Item.Cash
        local Offline_Cash = Brainrot_Item.Offline_Cash

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
        New_Tool:SetAttribute("Cash", Cash)
        New_Tool:SetAttribute("Offline_Cash", Offline_Cash)
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

    Log.Info(`{Player.Name}'s Brainrot Inventory was changed`)
end

local function Replicate_Food_Inventory(Player: Player, Entity: Types.Entity)
    local Character = World:get(Entity, Components.Renderable)

    if not Character then
        return
    end

    local Food_Inventory = World:get(Entity, Components.Food_Inventory) :: { [number]: Types.Food_Item }
    local Previous_Food_Inventory =
        World:get(Entity, Pair(Components.Relationships.Previous, Components.Food_Inventory))

    if Util.TablesAreEqual(Previous_Food_Inventory, Food_Inventory) then
        return
    end

    local Serialized_Food_Inventory: { Types.Food_Item } = {}

    Slot_Util.For_Each(Food_Inventory, Food_Capacity, function(_, Food_Item: Types.Food_Item)
        table.insert(Serialized_Food_Inventory, Food_Item)
    end)

    --Network.DataChanged.Brainrot_Inventory.Fire(Player, Serialized_Brainrot_Inventory)

    World:set(
        Entity,
        Pair(Components.Relationships.Previous, Components.Food_Inventory),
        Util.CopyTable(Food_Inventory, true)
    )

    local Existing_Tools = {}

    for _, Inst: Instance in Player.Backpack:GetChildren() do
        if Inst:IsA("Tool") and Inst:HasTag("Food") then
            local Index = Inst:GetAttribute("Index")
            if Index then
                Existing_Tools[Index] = Inst
            end
        end
    end

    for _, Inst: Instance in Player.Character:GetChildren() do
        if Inst:IsA("Tool") and Inst:HasTag("Food") then
            local Index = Inst:GetAttribute("Index")
            if Index then
                Existing_Tools[Index] = Inst
            end
        end
    end

    local Slots_To_Keep = {}

    for Index, Food_Item in pairs(Food_Inventory) do
        if not Food_Item then
            continue
        end

        Slots_To_Keep[Index] = true

        local Old_Tool = Existing_Tools[Index]

        if Old_Tool then
            local Xp_Match = Old_Tool:GetAttribute("Xp") == Food_Item.Xp

            if Xp_Match then
                continue
            else
                Old_Tool:Destroy()
            end
        end

        local Xp = Food_Item.Xp
        local Food_Data = Food.Get_Data_From_Xp(Xp)

        local New_Tool = Instance.new("Tool")

        New_Tool.Name = `[+{Xp} Xp] {Food_Data.Name}`
        New_Tool.ToolTip = `[+{Xp} Xp] {Food_Data.Name}`
        New_Tool:SetAttribute("Xp", Food_Item.Xp)
        New_Tool:SetAttribute("Index", Index)
        New_Tool:AddTag("Food")

        local Food_Model = Food_Data.Model:Clone()

        local Overhead_Attachment = Food_Model:FindFirstChild("Overhead_Attachment", true) :: Attachment

        local Overhead = Overhead_Attachment:FindFirstChild("Food_Overhead")
        if not Overhead then
            Overhead = Food_Overhead:Clone()
            Overhead.Parent = Overhead_Attachment
        end

        local Title_Text = Overhead:FindFirstChild("Title") :: TextLabel
        local Current_Text = Util.Abbreviate_Number(Xp, 2)
        Title_Text.Text = string.format("+%s XP", Current_Text)

        local Xp_Frame = Overhead:FindFirstChild("Xp") :: Frame
        Xp_Frame.Visible = false

        Food_Model:ScaleTo(Food_Data.Scale)

        local Extents = Food_Model:GetExtentsSize()

        New_Tool.Grip = CFrame.new(0, 0, Extents.Z / 3)

        local Handle = Food_Model.PrimaryPart
        Handle.Name = "Handle"

        for _, Inst: Instance in Food_Model:GetDescendants() do
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

        for _, Inst in Food_Model:GetChildren() do
            Inst.Parent = New_Tool
        end

        New_Tool.Parent = Player.Backpack
    end

    for Slot, Tool in Existing_Tools do
        if not Slots_To_Keep[Slot] then
            Tool:Destroy()
        end
    end

    Log.Info(`{Player.Name}'s Food Inventory was changed`)
end

local function Replicate_Index(Player: Player, Entity: Types.Entity)
    local Index = World:get(Entity, Components.Index)
    local Previous_Index = World:get(Entity, Pair(Components.Relationships.Previous, Components.Index)) or {}

    local Brainrot_Inventory = World:get(Entity, Components.Brainrot_Inventory)

    for Brainrot_Entity, Name in
        World:query(Components.Name):with(Components.Tags.Brainrot, Pair(Components.Relationships.Owner, Entity))
    do
        local Primary_Mutation = World:get(Brainrot_Entity, Components.Primary_Mutation) or "Normal"

        if not Index[Primary_Mutation] then
            Index[Primary_Mutation] = {}
        end

        if not table.find(Index[Primary_Mutation], Name) then
            table.insert(Index[Primary_Mutation], Name)
        end
    end

    Slot_Util.For_Each(Brainrot_Inventory, Brainrot_Capacity, function(_, Brainrot_Item: Types.Brainrot_Item)
        local Primary_Mutation = Brainrot_Item.Primary_Mutation or "Normal"

        if not Index[Primary_Mutation] then
            Index[Primary_Mutation] = {}
        end

        if not table.find(Index[Primary_Mutation], Brainrot_Item.Name) then
            table.insert(Index[Primary_Mutation], Brainrot_Item.Name)
        end
    end)

    if not Util.TablesAreEqual(Index, Previous_Index) then
        Network.DataChanged.Index.Fire(Player, Index)

        World:set(Entity, Components.Index, Index)
        World:set(Entity, Pair(Components.Relationships.Previous, Components.Index), Util.CopyTable(Index, true))

        Log.Info(`{Player.Name}'s index was changed`)
    end
end

local function Replicate_Active_Events(Player: Player, Entity: Types.Entity)
    local Active_Events = World:get(Components.Singletons.Active_Events, Components.Singletons.Active_Events)
    local Previous_Active_Events =
        World:get(Entity, Pair(Components.Relationships.Previous, Components.Singletons.Active_Events))

    if not Util.TablesAreEqual(Previous_Active_Events, Active_Events) then
        Network.DataChanged.Active_Events.Fire(Player, Active_Events)

        World:set(
            Entity,
            Pair(Components.Relationships.Previous, Components.Singletons.Active_Events),
            Util.CopyTable(Active_Events, true)
        )

        Log.Info(`Active events replicated to {Player.Name}'s`)
    end
end

local function Replicate_Last_Daily_Reward_Claim(Player: Player, Entity: Types.Entity)
    local Last_Daily_Reward_Claim = World:get(Entity, Components.Last_Daily_Reward_Claim)
    local Previous_Last_Daily_Reward_Claim =
        World:get(Entity, Pair(Components.Relationships.Previous, Components.Last_Daily_Reward_Claim))

    if Last_Daily_Reward_Claim ~= Previous_Last_Daily_Reward_Claim then
        Network.DataChanged.Last_Daily_Reward_Claim.Fire(Player, Last_Daily_Reward_Claim)

        World:set(
            Entity,
            Pair(Components.Relationships.Previous, Components.Last_Daily_Reward_Claim),
            Last_Daily_Reward_Claim
        )

        Log.Info(`{Player.Name}'s last daily reward claim changed`)
    end
end

local function Replicate_Claimed_Daily_Rewards(Player: Player, Entity: Types.Entity)
    local Claimed_Daily_Rewards = World:get(Entity, Components.Claimed_Daily_Rewards)
    local Previous_Claimed_Daily_Rewards =
        World:get(Entity, Pair(Components.Relationships.Previous, Components.Claimed_Daily_Rewards))

    if not Util.TablesAreEqual(Claimed_Daily_Rewards, Previous_Claimed_Daily_Rewards) then
        Network.DataChanged.Claimed_Daily_Rewards.Fire(Player, Claimed_Daily_Rewards)

        World:set(
            Entity,
            Pair(Components.Relationships.Previous, Components.Claimed_Daily_Rewards),
            Util.CopyTable(Claimed_Daily_Rewards, true)
        )
        Log.Info(`{Player.Name}'s claimed daily rewards were changed`)
    end
end

local function Replicate_Plot_Income_Per_Sec(Player: Player, Entity: Types.Entity)
    local Plot_Income_Per_Sec = 0
    local Previous_Plot_Income_Per_Sec =
        World:get(Entity, Pair(Components.Relationships.Previous, Components.Plot_Income_Per_Sec))

    for
        Brainrot_Entity,
        Level: number,
        Experience: number,
        Brainrot_Name: string,
        Secondary_Mutations: { string },
        Weight: number
    in
        World:query(
            Components.Level,
            Components.Experience,
            Components.Name,
            Components.Secondary_Mutations,
            Components.Weight
        ):with(Components.Tags.Brainrot, Pair(Components.Relationships.Owner, Entity))
    do
        local Primary_Mutation = World:get(Brainrot_Entity, Components.Primary_Mutation)

        Plot_Income_Per_Sec += math.round(Stat_Calculator.Calculate_Income_Per_Sec({
            Level = 1,
            Experience = 0,
            Brainrot_Name = Brainrot_Name,
            Primary_Mutation = Primary_Mutation,
            Secondary_Mutations = Secondary_Mutations,
            Weight = Weight,
        }) * Stat_Calculator.Get_Cash_Multiplier(Entity))
    end

    if Plot_Income_Per_Sec ~= Previous_Plot_Income_Per_Sec then
        Network.DataChanged.Plot_Income_Per_Sec.Fire(Player, Plot_Income_Per_Sec)

        World:set(Entity, Pair(Components.Relationships.Previous, Components.Plot_Income_Per_Sec), Plot_Income_Per_Sec)

        Log.Info(`{Player.Name}'s plot income per sec changed`)
    end
end

local function Replicate_Tutorial_Step(Player: Player, Entity: Types.Entity)
    local Tutorial_Step = World:get(Entity, Components.Tutorial_Step)
    local Previous_Tutorial_Step = World:get(Entity, Pair(Components.Relationships.Previous, Components.Tutorial_Step))

    if Tutorial_Step ~= Previous_Tutorial_Step then
        local Step_Text = Tutorial_Steps[Tutorial_Step]

        if Step_Text then
            AnalyticsService:LogOnboardingFunnelStepEvent(Player, Tutorial_Step + 1, Step_Text)
        end

        Network.DataChanged.Tutorial_Step.Fire(Player, Tutorial_Step)

        World:set(Entity, Pair(Components.Relationships.Previous, Components.Tutorial_Step), Tutorial_Step)

        Log.Info(`{Player.Name}'s tutorial step changed to {Tutorial_Step}`)
    end
end

local function Replicate_Group_Reward_Claimed(Player: Player, Entity: Types.Entity)
    local Group_Reward_Claimed = World:has(Entity, Components.Tags.Claimed_Group_Reward)

    local Previous_Group_Reward_Claimed =
        World:has(Entity, Pair(Components.Relationships.Previous, Components.Tags.Claimed_Group_Reward))

    if Group_Reward_Claimed ~= Previous_Group_Reward_Claimed then
        Network.DataChanged.Group_Reward_Claimed.Fire(Player, Group_Reward_Claimed)

        if Group_Reward_Claimed then
            World:add(Entity, Pair(Components.Relationships.Previous, Components.Tags.Claimed_Group_Reward))
        else
            World:remove(Entity, Pair(Components.Relationships.Previous, Components.Tags.Claimed_Group_Reward))
        end

        Log.Info(`{Player.Name}'s group reward claimed state changed to {Group_Reward_Claimed}`)
    end
end

local function Replicate_Friend_Boost(Player: Player, Entity: Types.Entity)
    local Friend_Boost = World:get(Entity, Components.Friend_Boost)
    local Previous_Friend_Boost = World:get(Entity, Pair(Components.Relationships.Previous, Components.Friend_Boost))

    if Friend_Boost ~= Previous_Friend_Boost then
        Network.DataChanged.Friend_Boost.Fire(Player, Friend_Boost)

        if Friend_Boost > 0 then
            Network.Notification.Fire(Player, { Text = `Friend boost changed to +{Friend_Boost}%`, Type = "Success" })
        end

        World:set(Entity, Pair(Components.Relationships.Previous, Components.Friend_Boost), Friend_Boost)

        Log.Info(`{Player.Name}'s friend boost changed to {Friend_Boost}`)
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

            Replicate_Food_Inventory(Player, Entity)

            Replicate_Index(Player, Entity)

            Replicate_Active_Events(Player, Entity)

            Replicate_Last_Daily_Reward_Claim(Player, Entity)

            Replicate_Claimed_Daily_Rewards(Player, Entity)

            Replicate_Plot_Income_Per_Sec(Player, Entity)

            Replicate_Tutorial_Step(Player, Entity)

            Replicate_Group_Reward_Claimed(Player, Entity)

            Replicate_Friend_Boost(Player, Entity)
        end
    end,
    runConditions = {},
}
