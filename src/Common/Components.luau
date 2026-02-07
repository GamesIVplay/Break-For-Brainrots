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
    Last_Restock: number,
    Block_Queue: { string },
    Upgrades: { [string]: number },

    Plot_Model: Types.Id<Model>,

    Text: Types.Id<string>,
    Duration: Types.Id<number>,

    NotificationType: Types.Id<Types.NotificationType>,

    Singletons: {},
    Tags: {
        Networked: Types.Entity,
        Plot: Types.Entity,
        Notification: Types.Entity,
    },
    Relationships: {
        Owner: Types.Entity,
        Plot: Types.Entity,
        Previous: Types.Entity,
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

        Plot_Model = World:component(),

        Text = World:component(),
        Duration = World:component(),

        NotificationType = World:component(),

        Singletons = {},
        Tags = {
            Networked = World:component(),
            Plot = World:component(),
            Notification = World:component(),
        },
        Relationships = {
            Owner = World:component(),
            Plot = World:component(),
            Previous = World:component(),
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

Setup_Hooks()

Name_Components(Components)

return table.freeze(Components)
