local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Network = require(ServerScriptService.Network)

local Jecs = require(ReplicatedStorage.Packages.Jecs)
local Pair = Jecs.pair

local Components = require(ReplicatedStorage.Common.Components)
local Types = require(ReplicatedStorage.Common.Types)
local World = require(ReplicatedStorage.Common.World)

local Brainrot_Offset = require(ReplicatedStorage.Common.Modules.Brainrot_Offset)
local Calculate_Sell_Price = require(ReplicatedStorage.Common.Modules.Calculate_Sell_Price)
local Generate_Brainrot_Model = require(ReplicatedStorage.Common.Modules.Generate_Brainrot_Model)
local Update_Brainrot_Overhead = require(ReplicatedStorage.Common.Modules.Update_Brainrot_Overhead)

return function(
    Player_Entity: Types.Entity,
    Open_Stand: Model,
    Brainrot_Name: string,
    Primary_Mutation: string?,
    Secondary_Mutations: { string },
    Weight: number,
    Cash: number?,
    Offline_Cash: number?
)
    local Player = World:get(Player_Entity, Components.Player)

    local Attachment = Open_Stand:FindFirstChild("Brainrot_Spawn", true) :: Attachment

    local Brainrot_Model, Offset = Generate_Brainrot_Model(Brainrot_Name, Primary_Mutation, Secondary_Mutations, Weight)

    Update_Brainrot_Overhead(Brainrot_Model, {
        Brainrot_Name = Brainrot_Name,
        Primary_Mutation = Primary_Mutation,
        Secondary_Mutations = Secondary_Mutations,
        Weight = Weight,
    })

    Brainrot_Model:AddTag("Idle")
    Brainrot_Model.Parent = workspace:FindFirstChild("Brainrots")

    Brainrot_Model:PivotTo(Attachment.WorldCFrame * Offset * CFrame.new(Brainrot_Offset))

    Network.VFX.Bounce_Brainrot.FireAll(Brainrot_Model)

    local Brainrot_Entity = World:entity()

    Open_Stand:SetAttribute("ServerEntity", Brainrot_Entity)

    World:set(Brainrot_Entity, Components.Name, Brainrot_Name)
    World:set(Brainrot_Entity, Components.Renderable, Brainrot_Model)

    if Primary_Mutation then
        World:set(Brainrot_Entity, Components.Primary_Mutation, Primary_Mutation)
    end

    World:set(Brainrot_Entity, Components.Secondary_Mutations, Secondary_Mutations)
    World:set(Brainrot_Entity, Components.Weight, Weight)
    World:set(Brainrot_Entity, Components.Stand, Open_Stand)
    World:set(Brainrot_Entity, Components.Cash, Cash or 0)
    World:set(Brainrot_Entity, Components.Offline_Cash, Offline_Cash or 0)

    World:add(Brainrot_Entity, Components.Tags.Brainrot)
    World:add(Brainrot_Entity, Components.Tags.Networked)

    World:add(Brainrot_Entity, Pair(Components.Relationships.Owner, Player_Entity))
    World:add(Player_Entity, Pair(Components.Relationships.Brainrot, Brainrot_Entity))

    World:set(Brainrot_Entity, Components.Cleanup, function()
        Brainrot_Model:Destroy()
        Open_Stand:RemoveTag("Occupied")
        Open_Stand:SetAttribute("ServerEntity", nil)
    end)

    local Sell_Price = Calculate_Sell_Price({
        Brainrot_Name = Brainrot_Name,
        Primary_Mutation = Primary_Mutation,
        Secondary_Mutations = Secondary_Mutations,
        Weight = Weight,
    })

    Network.Setup_Sell_Prompt.Fire(Player, {
        Brainrot_Model = Brainrot_Model,
        Sell_Price = Sell_Price,
    })

    return Brainrot_Entity, Brainrot_Model
end
