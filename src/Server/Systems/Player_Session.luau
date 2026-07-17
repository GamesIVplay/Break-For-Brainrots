-- Discord: dale.devs | Roblox: dale_devs

local AnalyticsService = game:GetService("AnalyticsService")
local DataStoreService = game:GetService("DataStoreService")
local MarketplaceService = game:GetService("MarketplaceService")
local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayTime_Leaderboard_Data_Store = DataStoreService:GetOrderedDataStore("PlayTime")
local Cash_Leaderboard_Data_Store = DataStoreService:GetOrderedDataStore("Cash")
local Open_Leaderboard_Data_Store = DataStoreService:GetOrderedDataStore("Open")

local Types = require(ReplicatedStorage.Common.Types)

-- Character and debris collision groups are configured once on server start.
-- Characters cannot collide with each other or loose debris, which prevents players
-- from blocking each other while still allowing normal map/world collisions.
PhysicsService:RegisterCollisionGroup("Character")
PhysicsService:RegisterCollisionGroup("Debris")

PhysicsService:CollisionGroupSetCollidable("Character", "Debris", false)
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
    -- Roblox characters can contain many object types. Only BasePart instances have
    -- CollisionGroup, so non-physical descendants are skipped before assignment.
    for _, Part in Character:GetDescendants() do
        if not Part:IsA("BasePart") then
            continue
        end

        Part.CollisionGroup = "Character"
    end
end

local function Load_Animations(Character: Model)
    -- Animations are loaded from the server-side Animator so every replicated
    -- character has the same custom animation set after appearance loading.
    local Animator = Character:FindFirstChild("Animator", true) :: Animator?

    if Animator then
        AnimPlayer.Load(Animator)
    end
end

local function Character_Appearance_Loaded(Player_Entity: Types.Entity, Character: Model)
    -- This bridges Roblox character lifecycle into the ECS world. The physical
    -- Model is stored as Renderable so other systems can find the server entity.
    Update_Character_Collision_Groups(Character)
    Load_Animations(Character)

    Character.Parent = workspace.Characters

    World:set(Player_Entity, Components.Renderable, Character)
end

local Updating_Friend_Boosts = false
local Pending_Friend_Boost_Update = false

local function Update_Friend_Boosts()
    -- Friend checks yield because they call Roblox web-backed APIs. This lock keeps
    -- multiple joins/leaves from running overlapping scans against the same players.
    if Updating_Friend_Boosts then
        Pending_Friend_Boost_Update = true
        return
    end

    Updating_Friend_Boosts = true

    repeat
        Pending_Friend_Boost_Update = false

        local PlayersList = Players:GetPlayers()

        for _, Player in PlayersList do
            local PlayerEntity = Registry.Get("Players", Player)
            if not PlayerEntity or not World:contains(PlayerEntity) then
                continue
            end

            -- Each in-server friend adds a flat percentage boost. The boost is stored
            -- as an ECS component so stat and replication systems can consume it.
            local Friends = 0

            for _, TargetPlayer in PlayersList do
                if TargetPlayer ~= Player then
                    local success, isFriend = pcall(function()
                        return Player:IsFriendsWithAsync(TargetPlayer.UserId)
                    end)

                    if success and isFriend then
                        Friends += 1
                    end
                end
            end

            World:set(PlayerEntity, Components.Friend_Boost, Friends * 5)
        end

    until not Pending_Friend_Boost_Update

    Updating_Friend_Boosts = false
end

local function Handle_New_Player(Player: Player)
    -- Prevent duplicate sessions if the client sends its loaded signal twice.
    if Registry.Get("Players", Player) ~= nil then
        return
    end

    -- Profile.Load owns DataStore session locking and reconciliation. If it returns
    -- nil, the player already left or the profile could not be safely loaded.
    local Player_Profile = Profile.Load(Player)

    if not Player_Profile then
        return
    end

    local Profile_Data = Player_Profile.Data

    local Player_Entity = World:entity()
    Registry.Define("Players", Player, Player_Entity)

    -- Existing saves may not contain recently purchased gamepasses if the purchase
    -- happened outside this server, so ownership is verified at session start.
    for Name, Id in Gamepasses do
        if
            not table.find(Profile_Data.Gamepasses, Name)
            and MarketplaceService:UserOwnsGamePassAsync(Player.UserId, Id)
        then
            table.insert(Profile_Data.Gamepasses, Name)
        end
    end

    -- Upgrade names changed over time. This migration preserves player progress
    -- while removing retired keys that no longer exist in the current upgrade table.
    for Name, Level in Profile_Data.Upgrades do
        if Name == "Luck Multiplier" then
            Profile_Data.Upgrades["Luck Boost"] = Level
        elseif Name == "Cash Multiplier" then
            Profile_Data.Upgrades["Cash Boost"] = Level
        end

        if not Upgrades[Name] then
            Profile_Data.Upgrades[Name] = nil
        end
    end

    -- Every current upgrade must have a valid level. Clamping protects later math
    -- from indexing past the configured Levels array after balance changes.
    for Name, Data in Upgrades do
        local Current_Upgrades = Profile_Data.Upgrades

        if not Current_Upgrades[Name] then
            Current_Upgrades[Name] = 1
        end

        local Max_Level = #Data.Levels

        if Current_Upgrades[Name] > Max_Level then
            Current_Upgrades[Name] = Max_Level
        end
    end

    if Profile_Data.Claimed_Group_Reward then
        World:add(Player_Entity, Components.Tags.Claimed_Group_Reward)
    end

    if Profile_Data.Bought_Starter_Pack then
        World:add(Player_Entity, Components.Tags.Bought_Starter_Pack)
    end

    -- Persistent profile fields are copied into ECS components. Runtime systems read
    -- and mutate components, then the OnSave callback writes them back to the profile.
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
    World:set(Player_Entity, Components.Friend_Boost, 0)
    World:set(Player_Entity, Components.Fusion_Machine, Profile_Data.Fusion_Machine)

    -- Tutorial step remaps handle old saves from earlier onboarding versions.
    -- Players stuck on removed steps are moved to the nearest valid current step.
    if Profile_Data.Tutorial_Step == 5 then
        World:set(Player_Entity, Components.Tutorial_Step, 6)
    elseif Profile_Data.Tutorial_Step == 2 then
        World:set(Player_Entity, Components.Tutorial_Step, 1)
    else
        World:set(Player_Entity, Components.Tutorial_Step, Profile_Data.Tutorial_Step)
    end

    -- Daily rewards are versioned by Config.DAILY_REWARD_ID. When the id changes,
    -- old claim history is reset so a new reward calendar can start cleanly.
    if Profile_Data.Daily_Reward_Id == Config.DAILY_REWARD_ID then
        World:set(Player_Entity, Components.Daily_Reward_Id, Profile_Data.Daily_Reward_Id)
        World:set(Player_Entity, Components.Last_Daily_Reward_Claim, Profile_Data.Last_Daily_Reward_Claim)
        World:set(Player_Entity, Components.Claimed_Daily_Rewards, Profile_Data.Claimed_Daily_Rewards)
    else
        World:set(Player_Entity, Components.Daily_Reward_Id, Config.DAILY_REWARD_ID)
        World:set(Player_Entity, Components.Last_Daily_Reward_Claim, 0)
        World:set(Player_Entity, Components.Claimed_Daily_Rewards, {})
    end

    if Profile_Data.Next_Fusion_Time ~= 0 then
        World:set(Player_Entity, Components.Next_Fusion_Time, Profile_Data.Next_Fusion_Time)
    end

    World:set(Player_Entity, Components.Player, Player)
    World:set(Player_Entity, Components.Cleanup, function()
        -- Cleanup is attached to the ECS entity so Registry.Delete can end the
        -- profile session and remove registry state from one ownership point.
        Profile.Unload(Player)

        Registry.Undefine("Players", Player)

        Log.Info(`Cleaned up {Player.Name}'s entity`)
    end)

    World:add(Player_Entity, Components.Tags.Networked)

    Player_Profile.OnSave:Connect(function()
        -- Brainrot_Loader removes Pending_Brainrots after rebuilding saved entities.
        -- Saving before that would replace the saved collection with an incomplete one.
        if World:has(Player_Entity, Components.Pending_Brainrots) then
            return
        end

        if World:has(Player_Entity, Components.Tags.Claimed_Group_Reward) then
            Profile_Data.Claimed_Group_Reward = true
        end

        if World:has(Player_Entity, Components.Tags.Bought_Starter_Pack) then
            Profile_Data.Bought_Starter_Pack = true
        end

        local Next_Fusion_Time = World:get(Player_Entity, Components.Next_Fusion_Time)

        if Next_Fusion_Time then
            Profile_Data.Next_Fusion_Time = Next_Fusion_Time
        else
            Profile_Data.Next_Fusion_Time = 0
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
        Profile_Data.Fusion_Machine = World:get(Player_Entity, Components.Fusion_Machine)
        Profile_Data.Tutorial_Step = World:get(Player_Entity, Components.Tutorial_Step)

        local Serialized_Brainrots: { [number]: Types.Serialized_Brainrot } = {}

        -- Owned brainrot entities are serialized back into plain Lua tables because
        -- DataStores cannot save Instances or ECS entities directly.
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
        -- Existing characters are handled immediately so fast-loading players do not
        -- wait for another respawn before collision and renderable setup happens.
        Character_Appearance_Loaded(Player_Entity, Player.Character)
    end

    Player.CharacterAppearanceLoaded:Connect(function(Character)
        Character_Appearance_Loaded(Player_Entity, Character)
    end)

    Player.CharacterRemoving:Connect(function()
        -- Previous relationship components are invalid once the character leaves,
        -- so replication can resend fresh inventory/pickaxe visuals on the next spawn.
        World:remove(Player_Entity, Components.Renderable)
        World:remove(Player_Entity, Pair(Components.Relationships.Previous, Components.Brainrot_Inventory))
        World:remove(Player_Entity, Pair(Components.Relationships.Previous, Components.Pickaxe))
    end)

    task.spawn(Update_Friend_Boosts)

    Log.Info(`Setup {Player.Name}'s entity`)
end

local function Update_Leaderboard_Data(Player_Entity: Types.Entity)
    -- OrderedDataStores are updated on leave so global leaderboards can sort by
    -- lifetime playtime, cash, and block opens without scanning player profiles.
    local Player = World:get(Player_Entity, Components.Player)

    local PlayTime = World:get(Player_Entity, Components.PlayTime)
    local Cash = World:get(Player_Entity, Components.Cash)
    local Opens = World:get(Player_Entity, Components.Opens)

    task.spawn(function()
        local Success, Error = pcall(function()
            PlayTime_Leaderboard_Data_Store:SetAsync(Player.UserId, PlayTime)
            Cash_Leaderboard_Data_Store:SetAsync(Player.UserId, Cash)
            Open_Leaderboard_Data_Store:SetAsync(Player.UserId, Opens)
        end)

        if not Success then
            Log.Warn(`Failed to update leaderboard data for {Player.Name}: {Error}`)
        end
    end)
end

local function Handle_Leaving_Player(Player: Player)
    -- The entity is looked up before deletion so leaderboard data can be read from
    -- ECS components while the player's session state still exists.
    local Player_Entity = Registry.Get("Players", Player)

    if Player_Entity then
        if not _G.IN_DEV then
            Update_Leaderboard_Data(Player_Entity)
        end
    end

    Registry.Delete("Players", Player)

    task.spawn(Update_Friend_Boosts)
end

return {
    name = script.Name,
    phase = Phases.Runservice.First,
    system = function()
        -- Network.ClientLoaded means the client has finished its initial boot path,
        -- so the server can create the profile-backed entity and begin replication.
        for _, Player: Player in Network.ClientLoaded.Iter() do
            AnalyticsService:LogOnboardingFunnelStepEvent(Player, 1, "Player Joined")

            task.spawn(Handle_New_Player, Player)
        end

        for Player: Player in PlayersRemoving do
            task.spawn(Handle_Leaving_Player, Player)
        end
    end,
    runConditions = {},
}
