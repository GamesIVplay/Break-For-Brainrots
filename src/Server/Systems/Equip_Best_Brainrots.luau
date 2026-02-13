local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Network = require(ServerScriptService.Network)
local New_Brainrot_Entity = require(ServerScriptService.Server.Modules.New_Brainrot_Entity)

local Jecs = require(ReplicatedStorage.Packages.Jecs)
local Pair = Jecs.pair

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local Types = require(ReplicatedStorage.Common.Types)
local World = require(ReplicatedStorage.Common.World)

local Calculate_Income_Per_Sec = require(ReplicatedStorage.Common.Modules.Calculate_Income_Per_Sec)
local Ratelimits = require(ReplicatedStorage.Common.Modules.Ratelimits)

local function Handle_Equip_Best_Brainrots_Requests()
    for _, Player: Player in Network.Requests.Equip_Best_Brainrots.Iter() do
        if not Ratelimits.Equip_Best_Brainrots(Player) then
            continue
        end

        local Player_Entity = Registry.Get("Players", Player)
        if not Player_Entity then
            continue
        end

        local Plot_Entity = World:target(Player_Entity, Components.Relationships.Plot)
        if not Plot_Entity then
            continue
        end

        local Plot_Model = World:get(Plot_Entity, Components.Renderable)
        local Stands = Plot_Model:FindFirstChild("Stands") :: Folder

        local Brainrot_Inventory = World:get(Player_Entity, Components.Brainrot_Inventory)
        local Gamepasses = World:get(Player_Entity, Components.Gamepasses)

        local All = {}

        for Index, Item in pairs(Brainrot_Inventory) do
            if Item then
                table.insert(All, {
                    Source = "Inventory",
                    Index = Index,
                    Data = Item,
                    Income_Per_Sec = Calculate_Income_Per_Sec({
                        Brainrot_Name = Item.Name,
                        Primary_Mutation = Item.Primary_Mutation,
                        Secondary_Mutations = Item.Secondary_Mutations,
                        Weight = Item.Weight,
                    }),
                })
            end
        end

        for Brainrot_Entity, Brainrot_Name: string, Secondary_Mutations: { string }, Weight: number in
            World:query(
                Components.Name,
                Components.Secondary_Mutations,
                Components.Weight,
                Components.Cash,
                Components.Offline_Cash,
                Components.Stand
            ):with(Pair(Components.Relationships.Owner, Player_Entity))
        do
            local Primary_Mutation = World:get(Brainrot_Entity, Components.Primary_Mutation)
            table.insert(All, {
                Source = "World",
                Entity = Brainrot_Entity,
                Stand = World:get(Brainrot_Entity, Components.Stand),
                Name = Brainrot_Name,
                Primary_Mutation = Primary_Mutation,
                Secondary_Mutations = Secondary_Mutations,
                Weight = Weight,
                Income_Per_Sec = Calculate_Income_Per_Sec({
                    Brainrot_Name = Brainrot_Name,
                    Primary_Mutation = Primary_Mutation,
                    Secondary_Mutations = Secondary_Mutations,
                    Weight = Weight,
                }),
            })
        end

        if #All == 0 then
            continue
        end

        table.sort(All, function(a, b)
            return a.Income_Per_Sec > b.Income_Per_Sec
        end)

        local Desired_Inventory = {}
        local Desired_World = {}

        for Index = 1, math.min(not table.find(Gamepasses, "+2 Slots") and 8 or 10, #All) do
            local Entry = All[Index]

            if Entry.Source == "Inventory" then
                table.insert(Desired_Inventory, Index)
            elseif Entry.Source == "World" then
                Desired_World[Entry.Entity] = true
            end
        end

        for _, Index in ipairs(Desired_Inventory) do
            local Open_Stand: Model?

            for Stand = 1, 10 do
                if (Stand == 5 or Stand == 10) and not table.find(Gamepasses, "+2 Slots") then
                    continue
                end

                local Stand_Model = Stands:FindFirstChild(Stand)

                if Stand_Model:HasTag("Occupied") then
                    local ServerEntity: Types.Entity? = Stand_Model:GetAttribute("ServerEntity")

                    if not ServerEntity then
                        warn("No Server Entity")
                        continue
                    end

                    if Desired_World[ServerEntity] then
                        warn("DESIRED")
                        continue
                    else
                        local Brainrot_Name = World:get(ServerEntity, Components.Name)
                        local Primary_Mutation = World:get(ServerEntity, Components.Primary_Mutation)
                        local Secondary_Mutations = World:get(ServerEntity, Components.Secondary_Mutations)
                        local Weight = World:get(ServerEntity, Components.Weight)

                        local Brainrot_Item: Types.Brainrot_Item = {
                            Name = Brainrot_Name,
                            Primary_Mutation = Primary_Mutation,
                            Secondary_Mutations = Secondary_Mutations,
                            Weight = Weight,
                        }

                        for Index = 1, #Brainrot_Inventory + 1 do
                            if Brainrot_Inventory[Index] == nil then
                                Brainrot_Inventory[Index] = Brainrot_Item
                                break
                            end
                        end

                        World:delete(ServerEntity)
                    end
                end

                Stand_Model:AddTag("Occupied")
                Open_Stand = Stand_Model
                break
            end

            if not Open_Stand then
                warn("No open stand")
                break
            end

            local Entry = All[Index]

            Open_Stand:AddTag("Occupied")

            New_Brainrot_Entity(
                Player_Entity,
                Open_Stand,
                Entry.Data.Name,
                Entry.Data.Primary_Mutation,
                Entry.Data.Secondary_Mutations,
                Entry.Data.Weight
            )

            Brainrot_Inventory[Entry.Index] = nil
            table.remove(Desired_Inventory, Index)
        end
    end
end

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = Handle_Equip_Best_Brainrots_Requests,
    runConditions = {},
}
