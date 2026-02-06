local DataStoreService = game:GetService("DataStoreService")
local MarketplaceService = game:GetService("MarketplaceService")
local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Cash_Leaderboard_Data_Store = DataStoreService:GetOrderedDataStore("Cash")
local Open_Leaderboard_Data_Store = DataStoreService:GetOrderedDataStore("Open")

local Types = require(ReplicatedStorage.Common.Types)

PhysicsService:RegisterCollisionGroup("Character")
PhysicsService:CollisionGroupSetCollidable("Character", "Character", false)

local Network = require(ServerScriptService.Network)

local Profile = require(ServerScriptService.Server.Modules.Profile)

local Collect = require(ReplicatedStorage.Common.Collect)
local Components = require(ReplicatedStorage.Common.Components)
local Log = require(ReplicatedStorage.Common.Log)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local World = require(ReplicatedStorage.Common.World)

local AnimPlayer = require(ReplicatedStorage.Common.Modules.AnimPlayer)
local Gamepasses = require(ReplicatedStorage.Common.Modules.Gamepasses)

local PlayersRemoving = Collect(Players.PlayerRemoving)

local function Update_Character_Collision_Groups(Character: Model)
    for _, Part in Character:GetDescendants() do
        if not Part:IsA("BasePart") then
            continue
        end

        Part.CollisionGroup = "Character"
    end
end

local function Load_Animations(Character: Model)
    local Animator = Character:FindFirstChild("Animator", true) :: Animator?

    if Animator then
        AnimPlayer.Load(Animator)
    end
end

local function Character_Appearance_Loaded(Player_Entity: Types.Entity, Character: Model)
    Update_Character_Collision_Groups(Character)
    Load_Animations(Character)

    Character.Parent = workspace.Characters

    World:set(Player_Entity, Components.Renderable, Character)
end

local function Handle_New_Player(Player: Player)
    if Registry.Get("Players", Player) ~= nil then
        return
    end

    local Player_Profile = Profile.Load(Player)

    if not Player_Profile then
        return
    end

    local Profile_Data = Player_Profile.Data

    local Player_Entity = World:entity()
    Registry.Define("Players", Player, Player_Entity)

    World:set(Player_Entity, Components.Player, Player)
    World:set(Player_Entity, Components.Name, Player.Name)

    for Name, Id in Gamepasses do
        if
            not table.find(Profile_Data.Gamepasses, Name)
            and MarketplaceService:UserOwnsGamePassAsync(Player.UserId, Id)
        then
            table.insert(Profile_Data.Gamepasses, Name)
        end
    end

    World:set(Player_Entity, Components.Cash, Profile_Data.Cash)
    World:set(Player_Entity, Components.Rebirth, Profile_Data.Rebirth)
    World:set(Player_Entity, Components.Pickaxe, Profile_Data.Pickaxe)
    World:set(Player_Entity, Components.Owned_Pickaxes, Profile_Data.Owned_Pickaxes)
    World:set(Player_Entity, Components.Opens, Profile_Data.Opens)
    World:set(Player_Entity, Components.Gamepasses, Profile_Data.Gamepasses)
    World:set(Player_Entity, Components.Stock, Profile_Data.Stock)
    World:set(Player_Entity, Components.Last_Restock, Profile_Data.Last_Restock)
    World:set(Player_Entity, Components.Cleanup, function()
        Profile.Unload(Player)

        Registry.Undefine("Players", Player)

        Log.Info(`Cleaned up {Player.Name}'s entity`)
    end)

    Player_Profile.OnSave:Connect(function()
        Profile_Data.Cash = World:get(Player_Entity, Components.Cash)
        Profile_Data.Rebirth = World:get(Player_Entity, Components.Rebirth)
        Profile_Data.Pickaxe = World:get(Player_Entity, Components.Pickaxe)
        Profile_Data.Owned_Pickaxes = World:get(Player_Entity, Components.Owned_Pickaxes)
        Profile_Data.Opens = World:get(Player_Entity, Components.Opens)
        Profile_Data.Gamepasses = World:get(Player_Entity, Components.Gamepasses)
        Profile_Data.Stock = World:get(Player_Entity, Components.Stock)
        Profile_Data.Last_Restock = World:get(Player_Entity, Components.Last_Restock)
    end)

    if Player.Character then
        Character_Appearance_Loaded(Player_Entity, Player.Character)
    end

    Player.CharacterAppearanceLoaded:Connect(function(Character)
        Character_Appearance_Loaded(Player_Entity, Character)
    end)

    Player.CharacterRemoving:Connect(function()
        World:remove(Player_Entity, Components.Renderable)
    end)

    Log.Info(`Setup {Player.Name}'s entity`)
end

local function Update_Leaderboard_Data(Player_Entity: Types.Entity)
    local Player = World:get(Player_Entity, Components.Player)

    local Cash = World:get(Player_Entity, Components.Cash)
    local Opens = World:get(Player_Entity, Components.Opens)

    task.spawn(function()
        local Success, Error = pcall(function()
            Cash_Leaderboard_Data_Store:SetAsync(Player.UserId, Cash)
            Open_Leaderboard_Data_Store:SetAsync(Player.UserId, Opens)
        end)

        if not Success then
            Log.Warn(`Failed to update leaderboard data for {Player.Name}: {Error}`)
        end
    end)
end

local function Handle_Leaving_Player(Player: Player)
    local Player_Entity = Registry.Get("Players", Player)

    if Player_Entity then
        if not _G.IN_DEV then
            Update_Leaderboard_Data(Player_Entity)
        end
    end

    Registry.Delete("Players", Player)
end

return {
    name = script.Name,
    phase = Phases.Runservice.First,
    system = function()
        for _, Player in Network.ClientLoaded.Iter() do
            task.spawn(Handle_New_Player, Player)
        end

        for Player in PlayersRemoving do
            task.spawn(Handle_Leaving_Player, Player)
        end
    end,
    runConditions = {},
}
