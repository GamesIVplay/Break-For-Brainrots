local AnalyticsService = game:GetService("AnalyticsService")
local DataStoreService = game:GetService("DataStoreService")
local MarketplaceService = game:GetService("MarketplaceService")
local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayTime_Leaderboard_Data_Store = DataStoreService:GetOrderedDataStore("PlayTime")
local Open_Leaderboard_Data_Store = DataStoreService:GetOrderedDataStore("Open")

local Types = require(ReplicatedStorage.Common.Types)

PhysicsService:RegisterCollisionGroup("Character")
PhysicsService:CollisionGroupSetCollidable("Character", "Character", false)

local Network = require(ServerScriptService.Network)

local Profile = require(ServerScriptService.Server.Modules.Profile)

local Jecs = require(ReplicatedStorage.Packages.Jecs)
local Pair = Jecs.pair

local Collect = require(ReplicatedStorage.Common.Collect)
local Components = require(ReplicatedStorage.Common.Components)
local Log = require(ReplicatedStorage.Common.Log)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local World = require(ReplicatedStorage.Common.World)

local AnimPlayer = require(ReplicatedStorage.Common.Modules.AnimPlayer)
local Config = require(ReplicatedStorage.Common.Config)
local Gamepasses = require(ReplicatedStorage.Common.Modules.Gamepasses)
local Upgrades = require(ReplicatedStorage.Common.Modules.Upgrades)

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

    for Name, Id in Gamepasses do
        if
            not table.find(Profile_Data.Gamepasses, Name)
            and MarketplaceService:UserOwnsGamePassAsync(Player.UserId, Id)
        then
            table.insert(Profile_Data.Gamepasses, Name)
        end
    end

    for Name, Data in Upgrades do
        local Current_Upgrades = Profile_Data.Upgrades

        if not Current_Upgrades[Name] then
            Current_Upgrades[Name] = 1

            AnalyticsService:LogFunnelStepEvent(Player, Name, tostring(Player.UserId), 1, `Level 1`)
        end

        local Max_Level = #Data.Levels

        if Current_Upgrades[Name] > Max_Level then
            Current_Upgrades[Name] = Max_Level
        end
    end

    if Profile_Data.Claimed_Group_Reward then
        World:add(Player_Entity, Components.Tags.Claimed_Group_Reward)
    end

    World:set(Player_Entity, Components.Name, Player.Name)
    World:set(Player_Entity, Components.Cash, Profile_Data.Cash)
    World:set(Player_Entity, Components.Rebirth, Profile_Data.Rebirth)
    World:set(Player_Entity, Components.Pickaxe, Profile_Data.Pickaxe)
    World:set(Player_Entity, Components.Owned_Pickaxes, Profile_Data.Owned_Pickaxes)
    World:set(Player_Entity, Components.Opens, Profile_Data.Opens)
    World:set(Player_Entity, Components.Gamepasses, Profile_Data.Gamepasses)
    World:set(Player_Entity, Components.Stock, Profile_Data.Stock)
    World:set(Player_Entity, Components.Last_Restock, Profile_Data.Last_Restock)
    World:set(Player_Entity, Components.Block_Queue, Profile_Data.Block_Queue)
    World:set(Player_Entity, Components.Upgrades, Profile_Data.Upgrades)
    World:set(Player_Entity, Components.Brainrot_Inventory, Profile_Data.Brainrot_Inventory)
    World:set(Player_Entity, Components.Pending_Brainrots, Profile_Data.Brainrots)
    World:set(Player_Entity, Components.Index, Profile_Data.Index)
    World:set(Player_Entity, Components.PlayTime, Profile_Data.PlayTime)
    World:set(Player_Entity, Components.LastPlayed, Profile_Data.LastPlayed)

    if Profile_Data.Tutorial_Step == 5 then
        World:set(Player_Entity, Components.Tutorial_Step, 6)
    elseif Profile_Data.Tutorial_Step == 2 then
        World:set(Player_Entity, Components.Tutorial_Step, 1)
    else
        World:set(Player_Entity, Components.Tutorial_Step, Profile_Data.Tutorial_Step)
    end

    if Profile_Data.Daily_Reward_Id == Config.DAILY_REWARD_ID then
        World:set(Player_Entity, Components.Daily_Reward_Id, Profile_Data.Daily_Reward_Id)
        World:set(Player_Entity, Components.Last_Daily_Reward_Claim, Profile_Data.Last_Daily_Reward_Claim)
        World:set(Player_Entity, Components.Claimed_Daily_Rewards, Profile_Data.Claimed_Daily_Rewards)
    else
        World:set(Player_Entity, Components.Daily_Reward_Id, Config.DAILY_REWARD_ID)
        World:set(Player_Entity, Components.Last_Daily_Reward_Claim, 0)
        World:set(Player_Entity, Components.Claimed_Daily_Rewards, {})
    end

    World:set(Player_Entity, Components.Player, Player)
    World:set(Player_Entity, Components.Cleanup, function()
        Profile.Unload(Player)

        Registry.Undefine("Players", Player)

        Log.Info(`Cleaned up {Player.Name}'s entity`)
    end)

    World:add(Player_Entity, Components.Tags.Networked)

    Player_Profile.OnSave:Connect(function()
        if World:has(Player_Entity, Components.Pending_Brainrots) then
            return
        end

        if World:has(Player_Entity, Components.Tags.Claimed_Group_Reward) then
            Profile_Data.Claimed_Group_Reward = true
        end

        Profile_Data.Cash = World:get(Player_Entity, Components.Cash)
        Profile_Data.Rebirth = World:get(Player_Entity, Components.Rebirth)
        Profile_Data.Pickaxe = World:get(Player_Entity, Components.Pickaxe)
        Profile_Data.Owned_Pickaxes = World:get(Player_Entity, Components.Owned_Pickaxes)
        Profile_Data.Opens = World:get(Player_Entity, Components.Opens)
        Profile_Data.Gamepasses = World:get(Player_Entity, Components.Gamepasses)
        Profile_Data.Stock = World:get(Player_Entity, Components.Stock)
        Profile_Data.Last_Restock = World:get(Player_Entity, Components.Last_Restock)
        Profile_Data.Block_Queue = World:get(Player_Entity, Components.Block_Queue)
        Profile_Data.Upgrades = World:get(Player_Entity, Components.Upgrades)
        Profile_Data.Brainrot_Inventory = World:get(Player_Entity, Components.Brainrot_Inventory)
        Profile_Data.Index = World:get(Player_Entity, Components.Index)
        Profile_Data.PlayTime = World:get(Player_Entity, Components.PlayTime)
        Profile_Data.LastPlayed = os.time()
        Profile_Data.Daily_Reward_Id = World:get(Player_Entity, Components.Daily_Reward_Id)
        Profile_Data.Last_Daily_Reward_Claim = World:get(Player_Entity, Components.Last_Daily_Reward_Claim)
        Profile_Data.Claimed_Daily_Rewards = World:get(Player_Entity, Components.Claimed_Daily_Rewards)
        Profile_Data.Tutorial_Step = World:get(Player_Entity, Components.Tutorial_Step)

        local Serialized_Brainrots: { [number]: Types.Serialized_Brainrot } = {}

        for
            Brainrot_Entity,
            Brainrot_Name: string,
            Secondary_Mutations: { string },
            Weight: number,
            Cash: number,
            Offline_Cash: number,
            Stand: Model
        in
            World:query(
                Components.Name,
                Components.Secondary_Mutations,
                Components.Weight,
                Components.Cash,
                Components.Offline_Cash,
                Components.Stand
            ):with(Pair(Components.Relationships.Owner, Player_Entity))
        do
            Serialized_Brainrots[Stand.Name] = {
                Name = Brainrot_Name,
                Primary_Mutation = World:get(Brainrot_Entity, Components.Primary_Mutation),
                Secondary_Mutations = Secondary_Mutations,
                Weight = Weight,
                Cash = Cash,
                Offline_Cash = Offline_Cash,
            }
        end

        Profile_Data.Brainrots = Serialized_Brainrots
    end)

    if Player.Character then
        Character_Appearance_Loaded(Player_Entity, Player.Character)
    end

    Player.CharacterAppearanceLoaded:Connect(function(Character)
        Character_Appearance_Loaded(Player_Entity, Character)
    end)

    Player.CharacterRemoving:Connect(function()
        World:remove(Player_Entity, Components.Renderable)
        World:remove(Player_Entity, Pair(Components.Relationships.Previous, Components.Brainrot_Inventory))
        World:remove(Player_Entity, Pair(Components.Relationships.Previous, Components.Pickaxe))
    end)

    Log.Info(`Setup {Player.Name}'s entity`)
end

local function Update_Leaderboard_Data(Player_Entity: Types.Entity)
    local Player = World:get(Player_Entity, Components.Player)

    local PlayTime = World:get(Player_Entity, Components.PlayTime)
    local Opens = World:get(Player_Entity, Components.Opens)

    task.spawn(function()
        local Success, Error = pcall(function()
            PlayTime_Leaderboard_Data_Store:SetAsync(Player.UserId, PlayTime)
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
        for _, Player: Player in Network.ClientLoaded.Iter() do
            AnalyticsService:LogOnboardingFunnelStepEvent(Player, 1, "Player Joined")
            AnalyticsService:LogFunnelStepEvent(Player, "Rebirth", tostring(Player.UserId), 1, `Rebirth 0`)

            task.spawn(Handle_New_Player, Player)
        end

        for Player: Player in PlayersRemoving do
            task.spawn(Handle_Leaving_Player, Player)
        end
    end,
    runConditions = {},
}
