local DataStoreService = game:GetService("DataStoreService")
local MarketPlaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PurchaseHistoryStore = DataStoreService:GetDataStore("PurchaseHistory")

local Network = require(ServerScriptService.Network)

local Slot_Util = require(ServerScriptService.Server.Modules.Slot_Util)

local Components = require(ReplicatedStorage.Common.Components)
local Log = require(ReplicatedStorage.Common.Log)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local Types = require(ReplicatedStorage.Common.Types)
local World = require(ReplicatedStorage.Common.World)

local Blocks = require(ReplicatedStorage.Common.Modules.Blocks)
local Developer_Products = require(ReplicatedStorage.Common.Modules.Developer_Products)
local Gamepasses = require(ReplicatedStorage.Common.Modules.Gamepasses)
local Pickaxes = require(ReplicatedStorage.Common.Modules.Pickaxes)
local Roll_Primary_Mutation = require(ReplicatedStorage.Common.Modules.Roll_Primary_Mutation)
local Roll_Secondary_Mutation = require(ReplicatedStorage.Common.Modules.Roll_Secondary_Mutation)
local Stat_Calculator = require(ReplicatedStorage.Common.Modules.Stat_Calculator)
local Upgrades_Config = require(ReplicatedStorage.Common.Modules.Upgrades)
local Weight = require(ReplicatedStorage.Common.Modules.Weight)

local Brainrot_Capacity = Stat_Calculator.Get_Brainrot_Capacity()

local Grant_Purchase_By_Product_Id = {
    [Developer_Products["Restock"]] = function(PlayerEntity: Types.Entity)
        World:set(PlayerEntity, Components.Last_Restock, 0)

        return true
    end,

    -- Robux Shop
    [Developer_Products["Starter Pack"]] = function(PlayerEntity: Types.Entity)
        local Player = World:get(PlayerEntity, Components.Player)
        local Brainrot_Inventory = World:get(PlayerEntity, Components.Brainrot_Inventory)
        local Cash = World:get(PlayerEntity, Components.Cash)

        local Open_Slot = Slot_Util.Get_First_Open(Brainrot_Inventory, Brainrot_Capacity)

        if not Open_Slot then
            Network.Notification.Fire(Player, {
                Text = "Inventory full! Starter Pack not claimed. Free up a slot and rejoin.",
                Type = "Error",
            })
            return false
        end

        Brainrot_Inventory[Open_Slot] = {
            Name = "Matteo",
            Secondary_Mutations = {},
            Weight = math.max(10, Weight.Roll_Weight()),
            Cash = 0,
            Offline_Cash = 0,
        } :: Types.Brainrot_Item

        World:set(PlayerEntity, Components.Cash, Cash + 50_000)

        return true
    end,
    [Developer_Products["Pro Pack"]] = function(PlayerEntity: Types.Entity)
        local Player = World:get(PlayerEntity, Components.Player)
        local Brainrot_Inventory = World:get(PlayerEntity, Components.Brainrot_Inventory)
        local Cash = World:get(PlayerEntity, Components.Cash)

        local Open_Slot = Slot_Util.Get_First_Open(Brainrot_Inventory, Brainrot_Capacity)

        if not Open_Slot then
            Network.Notification.Fire(Player, {
                Text = "Inventory full! Pro Pack not claimed. Free up a slot and rejoin.",
                Type = "Error",
            })
            return false
        end

        Brainrot_Inventory[Open_Slot] = {
            Name = "Dragon Cannelloni",
            Secondary_Mutations = {},
            Weight = math.max(10, Weight.Roll_Weight()),
            Cash = 0,
            Offline_Cash = 0,
        } :: Types.Brainrot_Item

        World:set(PlayerEntity, Components.Cash, Cash + 1_000_000)

        return true
    end,
    [Developer_Products["Frigo Camelo"]] = function(PlayerEntity: Types.Entity)
        local Player = World:get(PlayerEntity, Components.Player)
        local Brainrot_Inventory = World:get(PlayerEntity, Components.Brainrot_Inventory)

        local Open_Slot = Slot_Util.Get_First_Open(Brainrot_Inventory, Brainrot_Capacity)

        if not Open_Slot then
            Network.Notification.Fire(Player, {
                Text = "Inventory full! Frigo Camelo not claimed. Free up a slot and rejoin.",
                Type = "Error",
            })
            return false
        end

        Brainrot_Inventory[Open_Slot] = {
            Name = "Frigo Camelo",
            Secondary_Mutations = {},
            Weight = math.max(10, Weight.Roll_Weight()),
            Cash = 0,
            Offline_Cash = 0,
        } :: Types.Brainrot_Item

        return true
    end,
    [Developer_Products["Six Seven"]] = function(PlayerEntity: Types.Entity)
        local Player = World:get(PlayerEntity, Components.Player)
        local Brainrot_Inventory = World:get(PlayerEntity, Components.Brainrot_Inventory)

        local Open_Slot = Slot_Util.Get_First_Open(Brainrot_Inventory, Brainrot_Capacity)

        if not Open_Slot then
            Network.Notification.Fire(Player, {
                Text = "Inventory full! Six Seven not claimed. Free up a slot and rejoin.",
                Type = "Error",
            })
            return false
        end

        Brainrot_Inventory[Open_Slot] = {
            Name = "Six Seven",
            Secondary_Mutations = {},
            Weight = math.max(10, Weight.Roll_Weight()),
            Cash = 0,
            Offline_Cash = 0,
        } :: Types.Brainrot_Item

        return true
    end,
    [Developer_Products["Esok Sekolah"]] = function(PlayerEntity: Types.Entity)
        local Player = World:get(PlayerEntity, Components.Player)
        local Brainrot_Inventory = World:get(PlayerEntity, Components.Brainrot_Inventory)

        local Open_Slot = Slot_Util.Get_First_Open(Brainrot_Inventory, Brainrot_Capacity)

        if not Open_Slot then
            Network.Notification.Fire(Player, {
                Text = "Inventory full! Esok Sekolah not claimed. Free up a slot and rejoin.",
                Type = "Error",
            })
            return false
        end

        Brainrot_Inventory[Open_Slot] = {
            Name = "Esok Sekolah",
            Secondary_Mutations = {},
            Weight = math.max(10, Weight.Roll_Weight()),
            Cash = 0,
            Offline_Cash = 0,
        } :: Types.Brainrot_Item

        return true
    end,
    [Developer_Products["Small Pack"]] = function(PlayerEntity: Types.Entity)
        local Cash = World:get(PlayerEntity, Components.Cash)

        World:set(PlayerEntity, Components.Cash, Cash + 10_000)

        return true
    end,
    [Developer_Products["Medium Pack"]] = function(PlayerEntity: Types.Entity)
        local Cash = World:get(PlayerEntity, Components.Cash)

        World:set(PlayerEntity, Components.Cash, Cash + 100_000)

        return true
    end,
    [Developer_Products["Huge Pack"]] = function(PlayerEntity: Types.Entity)
        local Cash = World:get(PlayerEntity, Components.Cash)

        World:set(PlayerEntity, Components.Cash, Cash + 1_000_000)

        return true
    end,

    -- HUD Offers
    [Developer_Products["Random Brainrot"]] = function(PlayerEntity: Types.Entity)
        local Player = World:get(PlayerEntity, Components.Player)
        local Brainrot_Inventory = World:get(PlayerEntity, Components.Brainrot_Inventory)

        local Open_Slot = Slot_Util.Get_First_Open(Brainrot_Inventory, Brainrot_Capacity)

        if not Open_Slot then
            Network.Notification.Fire(Player, {
                Text = "Inventory full! Random Brainrot not claimed. Free up a slot and rejoin.",
                Type = "Error",
            })
            return false
        end

        local Roll = math.random()

        local Random_Block

        if Roll < 0.005 then
            Random_Block = "Secret"
        elseif Roll < 0.01 then
            Random_Block = "Mythical"
        elseif Roll < 0.04 then
            Random_Block = "Legendary"
        elseif Roll < 0.11 then
            Random_Block = "Epic"
        elseif Roll < 0.36 then
            Random_Block = "Rare"
        else
            Random_Block = "Common"
        end

        local Rolled_Name = Blocks[Random_Block].Roll_Brainrot()

        local Mutation_Luck = Stat_Calculator.Get_Mutation_Luck(PlayerEntity)

        Brainrot_Inventory[Open_Slot] = {
            Name = Rolled_Name,
            Primary_Mutation = Roll_Primary_Mutation(Mutation_Luck),
            Secondary_Mutations = Roll_Secondary_Mutation(Mutation_Luck),
            Weight = Weight.Roll_Weight(),
            Cash = 0,
            Offline_Cash = 0,
        } :: Types.Brainrot_Item

        Network.Notification.Fire(Player, {
            Text = `You got a {Rolled_Name}!`,
            Type = "Info",
        })

        return true
    end,
    [Developer_Products["Ballerino Lololo"]] = function(PlayerEntity: Types.Entity)
        local Player = World:get(PlayerEntity, Components.Player)
        local Brainrot_Inventory = World:get(PlayerEntity, Components.Brainrot_Inventory)

        local Open_Slot = Slot_Util.Get_First_Open(Brainrot_Inventory, Brainrot_Capacity)

        if not Open_Slot then
            Network.Notification.Fire(Player, {
                Text = "Inventory full! Ballerino Lololo not claimed. Free up a slot and rejoin.",
                Type = "Error",
            })
            return false
        end

        Brainrot_Inventory[Open_Slot] = {
            Name = "Ballerino Lololo",
            Secondary_Mutations = {},
            Weight = math.max(10, Weight.Roll_Weight()),
            Cash = 0,
            Offline_Cash = 0,
        } :: Types.Brainrot_Item

        return true
    end,
    [Developer_Products["Tung Sahur"]] = function(PlayerEntity: Types.Entity)
        local Player = World:get(PlayerEntity, Components.Player)
        local Brainrot_Inventory = World:get(PlayerEntity, Components.Brainrot_Inventory)

        local Open_Slot = Slot_Util.Get_First_Open(Brainrot_Inventory, Brainrot_Capacity)

        if not Open_Slot then
            Network.Notification.Fire(Player, {
                Text = "Inventory full! Tung Sahur not claimed. Free up a slot and rejoin.",
                Type = "Error",
            })
            return false
        end

        local Mutation_Luck = Stat_Calculator.Get_Mutation_Luck(PlayerEntity)

        Brainrot_Inventory[Open_Slot] = {
            Name = "Tung Sahur",
            Primary_Mutation = Roll_Primary_Mutation(Mutation_Luck),
            Secondary_Mutations = Roll_Secondary_Mutation(Mutation_Luck),
            Weight = math.max(10, Weight.Roll_Weight()),
            Cash = 0,
            Offline_Cash = 0,
        } :: Types.Brainrot_Item

        return true
    end,

    -- Map Offers
    [Developer_Products["Gold Ballerina Cappuccina"]] = function(PlayerEntity: Types.Entity)
        local Player = World:get(PlayerEntity, Components.Player)
        local Brainrot_Inventory = World:get(PlayerEntity, Components.Brainrot_Inventory)

        local Open_Slot = Slot_Util.Get_First_Open(Brainrot_Inventory, Brainrot_Capacity)

        if not Open_Slot then
            Network.Notification.Fire(Player, {
                Text = "Inventory full! Gold Ballerina Cappuccina not claimed. Free up a slot and rejoin.",
                Type = "Error",
            })
            return false
        end

        Brainrot_Inventory[Open_Slot] = {
            Name = "Ballerina Cappuccina",
            Primary_Mutation = "Gold",
            Secondary_Mutations = {},
            Weight = math.max(10, Weight.Roll_Weight()),
            Cash = 0,
            Offline_Cash = 0,
        } :: Types.Brainrot_Item

        return true
    end,
    [Developer_Products["Diamond Bananita Dolphinita"]] = function(PlayerEntity: Types.Entity)
        local Player = World:get(PlayerEntity, Components.Player)
        local Brainrot_Inventory = World:get(PlayerEntity, Components.Brainrot_Inventory)

        local Open_Slot = Slot_Util.Get_First_Open(Brainrot_Inventory, Brainrot_Capacity)

        if not Open_Slot then
            Network.Notification.Fire(Player, {
                Text = "Inventory full! Diamond Bananita Dolphinita not claimed. Free up a slot and rejoin.",
                Type = "Error",
            })
            return false
        end

        Brainrot_Inventory[Open_Slot] = {
            Name = "Bananita Dolphinita",
            Primary_Mutation = "Diamond",
            Secondary_Mutations = {},
            Weight = math.max(10, Weight.Roll_Weight()),
            Cash = 0,
            Offline_Cash = 0,
        } :: Types.Brainrot_Item

        return true
    end,
    [Developer_Products["Break Block"]] = function(PlayerEntity: Types.Entity)
        local Plot_Entity = World:target(PlayerEntity, Components.Relationships.Plot)

        if not Plot_Entity then
            return false
        end

        local Block_Entity = World:target(Plot_Entity, Components.Relationships.Block)

        if not Block_Entity or World:has(Block_Entity, Components.Tags.Opening) then
            return false
        end

        World:set(Block_Entity, Components.Health, 0)

        return true
    end,
    [Developer_Products["Troll Face"]] = function(PlayerEntity: Types.Entity)
        local Player = World:get(PlayerEntity, Components.Player)
        local Brainrot_Inventory = World:get(PlayerEntity, Components.Brainrot_Inventory)

        local Open_Slot = Slot_Util.Get_First_Open(Brainrot_Inventory, Brainrot_Capacity)

        if not Open_Slot then
            Network.Notification.Fire(Player, {
                Text = "Inventory full! Troll Face not claimed. Free up a slot and rejoin.",
                Type = "Error",
            })
            return false
        end

        local Mutation_Luck = Stat_Calculator.Get_Mutation_Luck(PlayerEntity)

        Brainrot_Inventory[Open_Slot] = {
            Name = "Troll Face",
            Primary_Mutation = Roll_Primary_Mutation(Mutation_Luck),
            Secondary_Mutations = Roll_Secondary_Mutation(Mutation_Luck),
            Weight = math.max(10, Weight.Roll_Weight()),
            Cash = 0,
            Offline_Cash = 0,
        } :: Types.Brainrot_Item

        return true
    end,
    [Developer_Products["La Grande Combinasion"]] = function(PlayerEntity: Types.Entity)
        local Player = World:get(PlayerEntity, Components.Player)
        local Brainrot_Inventory = World:get(PlayerEntity, Components.Brainrot_Inventory)

        local Open_Slot = Slot_Util.Get_First_Open(Brainrot_Inventory, Brainrot_Capacity)

        if not Open_Slot then
            Network.Notification.Fire(Player, {
                Text = "Inventory full! La Grande Combinasion not claimed. Free up a slot and rejoin.",
                Type = "Error",
            })
            return false
        end

        local Mutation_Luck = Stat_Calculator.Get_Mutation_Luck(PlayerEntity)

        Brainrot_Inventory[Open_Slot] = {
            Name = "La Grande Combinasion",
            Primary_Mutation = Roll_Primary_Mutation(Mutation_Luck),
            Secondary_Mutations = Roll_Secondary_Mutation(Mutation_Luck),
            Weight = math.max(10, Weight.Roll_Weight()),
            Cash = 0,
            Offline_Cash = 0,
        } :: Types.Brainrot_Item

        return true
    end,
    [Developer_Products["Skibidi Toilet"]] = function(PlayerEntity: Types.Entity)
        local Player = World:get(PlayerEntity, Components.Player)
        local Brainrot_Inventory = World:get(PlayerEntity, Components.Brainrot_Inventory)

        local Open_Slot = Slot_Util.Get_First_Open(Brainrot_Inventory, Brainrot_Capacity)

        if not Open_Slot then
            Network.Notification.Fire(Player, {
                Text = "Inventory full! Skibidi Toilet not claimed. Free up a slot and rejoin.",
                Type = "Error",
            })
            return false
        end

        local Mutation_Luck = Stat_Calculator.Get_Mutation_Luck(PlayerEntity)

        Brainrot_Inventory[Open_Slot] = {
            Name = "Skibidi Toilet",
            Primary_Mutation = Roll_Primary_Mutation(Mutation_Luck),
            Secondary_Mutations = Roll_Secondary_Mutation(Mutation_Luck),
            Weight = math.max(10, Weight.Roll_Weight()),
            Cash = 0,
            Offline_Cash = 0,
        } :: Types.Brainrot_Item

        return true
    end,
}

local function Add_Pickaxe_Purchases()
    for Pickaxe_Name, Data in Pickaxes do
        Grant_Purchase_By_Product_Id[Data.Developer_Product] = function(PlayerEntity: Types.Entity)
            local Owned_Pickaxes = World:get(PlayerEntity, Components.Owned_Pickaxes)

            table.insert(Owned_Pickaxes, Pickaxe_Name)

            return true
        end
    end
end

local function Add_Block_Purchases()
    for Block_Name, Data in Blocks do
        Grant_Purchase_By_Product_Id[Data.Developer_Product] = function(PlayerEntity: Types.Entity)
            local Player = World:get(PlayerEntity, Components.Player)
            local Block_Queue = World:get(PlayerEntity, Components.Block_Queue)

            table.insert(Block_Queue, Block_Name)

            Network.Notification.Fire(Player, {
                Text = `You bought a {Block_Name} Block!`,
                Type = "Success",
            })

            return true
        end
    end
end

local function Add_Upgrade_Purchases()
    for Upgrade_Name, Data in Upgrades_Config do
        local Upgrade_Data = Upgrades_Config[Upgrade_Name]

        Grant_Purchase_By_Product_Id[Data.Developer_Product] = function(PlayerEntity: Types.Entity)
            local Player = World:get(PlayerEntity, Components.Player)
            local Upgrades = World:get(PlayerEntity, Components.Upgrades)

            local Upgrade_Level = Upgrades[Upgrade_Name]

            if not Upgrade_Level then
                return
            end

            local Next_Upgrade_Data = Upgrade_Data.Levels[Upgrade_Level + 1]

            if not Next_Upgrade_Data then
                return true
            end

            Upgrades[Upgrade_Name] = Upgrades[Upgrade_Name] + 1

            Network.Notification.Fire(Player, {
                Text = `You upgraded {Upgrade_Name} to level {Upgrades[Upgrade_Name]}!`,
                Type = "Success",
            })

            return true
        end
    end
end

local function ProcessReceipt(ReceiptInfo)
    local Success, Result = pcall(
        PurchaseHistoryStore.UpdateAsync,
        PurchaseHistoryStore,
        ReceiptInfo.PurchaseId,
        function(IsPurchased)
            if IsPurchased then
                return true
            end

            local Player = Players:GetPlayerByUserId(ReceiptInfo.PlayerId)

            if not Player then
                return nil
            end

            local PlayerEntity = Registry.Get("Players", Player)

            if not PlayerEntity then
                return nil
            end

            local Character = World:get(PlayerEntity, Components.Renderable) :: Model?

            if not Character then
                return nil
            end

            local RootPart = Character:FindFirstChild("HumanoidRootPart")

            if not RootPart then
                return nil
            end

            Network.Notification.Fire(Player, { Text = "Thanks for your purchase!", Type = "Success" })

            local GrantPurchaseHandler = Grant_Purchase_By_Product_Id[ReceiptInfo.ProductId]

            if not GrantPurchaseHandler then
                warn(`No purchase handler defined for product ID '{ReceiptInfo.ProductId}'`)

                return nil
            end

            local HandlerSucceeded, HandlerResult = pcall(GrantPurchaseHandler, PlayerEntity, ReceiptInfo)

            if not HandlerSucceeded then
                local errorMessage = HandlerResult

                warn(

                    `Grant purchase handler errored while processing purchase from '{Player.Name}' of product ID '{ReceiptInfo.ProductId}': {errorMessage}`
                )

                return nil
            end

            local DidHandlerGrantPurchase = HandlerResult == true

            if not DidHandlerGrantPurchase then
                return nil
            end

            Network.VFX.Robux_Purchase.FireAll(Character)

            return true
        end
    )

    if not Success then
        Log.Warn(`Failed to process receipt due to data store error: {Result}`)

        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    local DidGrantPurchase = Result == true

    return if DidGrantPurchase

        then Enum.ProductPurchaseDecision.PurchaseGranted
        else Enum.ProductPurchaseDecision.NotProcessedYet
end

return {
    name = script.Name,
    phase = Phases.InitPhases.PreInit,
    system = function()
        Add_Pickaxe_Purchases()

        Add_Block_Purchases()

        Add_Upgrade_Purchases()

        MarketPlaceService.ProcessReceipt = ProcessReceipt

        MarketPlaceService.PromptGamePassPurchaseFinished:Connect(function(Player, GamepassId, IsPurchased)
            if not IsPurchased then
                return
            end

            local PlayerEntity = Registry.Get("Players", Player)

            if not PlayerEntity then
                return
            end

            local Owned_Gamepasses = World:get(PlayerEntity, Components.Gamepasses)

            local Gamepass_Name

            for Name, Id in Gamepasses do
                if Id == GamepassId then
                    Gamepass_Name = Name
                    break
                end
            end

            if
                Gamepass_Name
                and MarketPlaceService:UserOwnsGamePassAsync(Player.UserId, Gamepasses[Gamepass_Name])
                and not table.find(Owned_Gamepasses, Gamepass_Name)
            then
                table.insert(Owned_Gamepasses, Gamepass_Name)
            end

            local Character = PlayerEntity and World:get(PlayerEntity, Components.Renderable) :: Model?

            if Character then
                Network.VFX.Robux_Purchase.FireAll(Character)
            end

            Network.Notification.Fire(Player, { Text = "Thanks for your purchase!", Type = "Success" })
        end)
    end,
    runConditions = {},
}
