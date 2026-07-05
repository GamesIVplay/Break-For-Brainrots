local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Network = require(ServerScriptService.Network)

local New_Brainrot_Entity = require(ServerScriptService.Server.Modules.New_Brainrot_Entity)

local Jecs = require(ReplicatedStorage.Packages.Jecs)
local Pair = Jecs.pair

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Types = require(ReplicatedStorage.Common.Types)
local World = require(ReplicatedStorage.Common.World)

local Stat_Calculator = require(ReplicatedStorage.Common.Modules.Stat_Calculator)
local Util = require(ReplicatedStorage.Common.Modules.Util)

local Pending_Brainrot_Query = World:query(
    Components.Player,
    Components.Rebirth,
    Components.Gamepasses,
    Components.LastPlayed,
    Components.Pending_Brainrots
)
    :with(Pair(Components.Relationships.Plot, Jecs.Wildcard))
    :cached()

local function Load_Brainrots()
    for
        Player_Entity: Types.Entity,
        Player: Player,
        _Rebirth: number,
        _Gamepasses: { string },
        LastPlayed: number,
        Pending_Brainrots: { [number]: Types.Serialized_Brainrot }
    in Pending_Brainrot_Query:iter() do
        local Plot_Entity = World:target(Player_Entity, Components.Relationships.Plot)

        local Plot_Model = World:get(Plot_Entity, Components.Renderable) :: Model
        local Stands = Plot_Model:FindFirstChild("Stands")

        local Total_Offline_Cash = 0

        local Time_Offline = os.time() - LastPlayed
        Time_Offline = math.min(Time_Offline, 4 * 60 * 60) -- 4 hour cap

        for Stand_Number, Serialized_Brainrot in Pending_Brainrots do
            local Stand_Model = Stands:FindFirstChild(Stand_Number) :: Model

            Stand_Model:AddTag("Occupied")

            local Brainrot_Name = Serialized_Brainrot.Name
            local Primary_Mutation = Serialized_Brainrot.Primary_Mutation
            local Secondary_Mutations = Serialized_Brainrot.Secondary_Mutations
            local Weight = Serialized_Brainrot.Weight
            local Cash = Serialized_Brainrot.Cash
            local Offline_Cash = Serialized_Brainrot.Offline_Cash

            local Income_Per_Sec = Stat_Calculator.Calculate_Income_Per_Sec({
                Brainrot_Name = Serialized_Brainrot.Name,
                Primary_Mutation = Serialized_Brainrot.Primary_Mutation,
                Secondary_Mutations = Serialized_Brainrot.Secondary_Mutations,
                Weight = Serialized_Brainrot.Weight,
            })

            local New_Offline_Cash =
                math.round((Time_Offline * Income_Per_Sec * Stat_Calculator.Get_Cash_Multiplier(Player_Entity)) * 0.01) -- 1% of what u would make

            Offline_Cash += New_Offline_Cash

            Total_Offline_Cash += New_Offline_Cash

            New_Brainrot_Entity(
                Player_Entity,
                Stand_Model,
                Brainrot_Name,
                Primary_Mutation,
                Secondary_Mutations,
                Weight,
                Cash,
                Offline_Cash
            )
        end

        World:remove(Player_Entity, Components.Pending_Brainrots)

        if Total_Offline_Cash > 0 then
            Network.Notification.Fire(Player, {
                Text = `You earned ${Util.Format_Number_With_Commas(Total_Offline_Cash)} while you were away!`,
                Type = "Info",
                Duration = 8,
            })
        end
    end
end

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = Load_Brainrots,
    runConditions = {},
}
