local Jecs = require(game:GetService("ReplicatedStorage").Packages.Jecs)
local World = require("./World")

local Types = require("./Types")

local Components: {
    Player: Types.Id<Player>,
    Renderable: Types.Id<Model>,
    Cleanup: Types.Id<() -> ()>,

    Name: Types.Id<string>,

    Cash: Types.Id<number>,
    Rebirth: Types.Id<number>,
    Pickaxe: Types.Id<string>,
    Owned_Pickaxes: Types.Id<{ string }>,
    Opens: Types.Id<number>,
    Gamepasses: Types.Id<{ string }>,
    Stock: Types.Id<{ [string]: number }>,
    Last_Restock: Types.Id<number>,
    Block_Queue: Types.Id<{ string }>,
    Upgrades: Types.Id<{ [string]: number }>,
    Brainrot_Inventory: Types.Id<{ [number]: Types.Brainrot_Item }>,
    Pending_Brainrots: Types.Id<{ [number]: Types.Serialized_Brainrot }>,
    LastPlayed: Types.Id<number>,
    Index: Types.Id<{ [string]: { string } }>,
    PlayTime: Types.Id<number>,
    Daily_Reward_Id: Types.Id<number>,
    Last_Daily_Reward_Claim: Types.Id<number>,
    Claimed_Daily_Rewards: Types.Id<{ string }>,
    Tutorial_Step: Types.Id<number>,

    Friend_Boost: Types.Id<number>,

    Plot_Model: Types.Id<Model>,

    Text: Types.Id<string>,
    Duration: Types.Id<number>,

    NotificationType: Types.Id<Types.NotificationType>,
    Gradient: Types.Id<string>,

    Health: Types.Id<number>,

    Stand: Types.Id<Model>,
    Primary_Mutation: Types.Id<string>,
    Secondary_Mutations: Types.Id<{ string }>,
    Weight: Types.Id<number>,
    Offline_Cash: Types.Id<number>,

    Plot_Income_Per_Sec: Types.Id<number>,

    Singletons: {
        Active_Events: Types.Id<{
            [string]: {
                Start_Time: number,
                End_Time: number,
                Luck_Bonus: number,
            },
        }>,
    },
    Tags: {
        Networked: Types.Entity,
        Plot: Types.Entity,
        Notification: Types.Entity,
        Block: Types.Entity,
        Opening: Types.Entity,
        Brainrot: Types.Entity,
        Claimed_Group_Reward: Types.Entity,
        Bought_Starter_Pack: Types.Entity,
    },
    Relationships: {
        Owner: Types.Entity,
        Plot: Types.Entity,
        Previous: Types.Entity,
        Block: Types.Entity,
        Brainrot: Types.Entity,
    },
} =
    {
        Player = World:component(),
        Renderable = World:component(),
        Cleanup = World:component(),

        Name = World:component(),

        Cash = World:component(),
        Rebirth = World:component(),
        Pickaxe = World:component(),
        Owned_Pickaxes = World:component(),
        Opens = World:component(),
        Gamepasses = World:component(),
        Stock = World:component(),
        Last_Restock = World:component(),
        Block_Queue = World:component(),
        Upgrades = World:component(),
        Brainrot_Inventory = World:component(),
        Pending_Brainrots = World:component(),
        LastPlayed = World:component(),
        Index = World:component(),
        PlayTime = World:component(),
        Daily_Reward_Id = World:component(),
        Last_Daily_Reward_Claim = World:component(),
        Claimed_Daily_Rewards = World:component(),
        Tutorial_Step = World:component(),

        Friend_Boost = World:component(),

        Plot_Model = World:component(),

        Text = World:component(),
        Duration = World:component(),

        NotificationType = World:component(),
        Gradient = World:component(),

        Health = World:component(),

        Stand = World:component(),
        Primary_Mutation = World:component(),
        Secondary_Mutations = World:component(),
        Weight = World:component(),
        Offline_Cash = World:component(),

        Plot_Income_Per_Sec = World:component(),

        Singletons = {
            Active_Events = World:component(),
        },
        Tags = {
            Networked = World:component(),
            Plot = World:component(),
            Notification = World:component(),
            Block = World:component(),
            Opening = World:component(),
            Brainrot = World:component(),
            Claimed_Group_Reward = World:component(),
            Bought_Starter_Pack = World:component(),
        },
        Relationships = {
            Owner = World:component(),
            Plot = World:component(),
            Previous = World:component(),
            Block = World:component(),
            Brainrot = World:component(),
        },
    }

local function Setup_Hooks()
    World:set(Components.Renderable, Jecs.OnAdd, function(Entity)
        if not World:has(Entity, Components.Tags.Networked) then
            return
        end

        local Model: Model? = World:get(Entity, Components.Renderable)

        if Model then
            Model:SetAttribute("ServerEntity", Entity)
        end
    end)

    World:set(Components.Renderable, Jecs.OnChange, function(Entity)
        if not World:has(Entity, Components.Tags.Networked) then
            return
        end

        local Model: Model? = World:get(Entity, Components.Renderable)

        if Model then
            Model:SetAttribute("ServerEntity", Entity)
        end
    end)

    World:set(Components.Tags.Networked, Jecs.OnAdd, function(Entity)
        local Model: Model? = World:get(Entity, Components.Renderable)

        if Model then
            Model:SetAttribute("ServerEntity", Entity)
        end
    end)

    World:set(Components.Tags.Networked, Jecs.OnRemove, function(Entity)
        local Model: Model? = World:get(Entity, Components.Renderable)

        if Model then
            Model:SetAttribute("ServerEntity", Entity)
        end
    end)

    World:set(Components.Cleanup, Jecs.OnRemove, function(Entity)
        local Cleanup = World:get(Entity, Components.Cleanup)

        if Cleanup then
            Cleanup()
        end
    end)
end

local function Name_Components(Cts)
    for Name, Component in Cts do
        if type(Component) == "table" then
            Name_Components(Component)
        else
            World:set(Component, Jecs.Name, Name)
        end
    end
end

local function Init_Components()
    World:set(Components.Singletons.Active_Events, Components.Singletons.Active_Events, {})
end

Setup_Hooks()

Name_Components(Components)

Init_Components()

return table.freeze(Components)
