local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Map = workspace:WaitForChild("Map") :: Folder
local Shops = Map:WaitForChild("Shops") :: Folder

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Peek = Fusion.peek

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local World = require(ReplicatedStorage.Common.World)

local Darkener = require(ReplicatedFirst.Client.Modules.ScreenDarkener).New(5)
local Fusion_Values = require(ReplicatedFirst.Client.Modules.Fusion_Values)

local function Update_Darkener()
    local Local_Entity = Registry.Get("Players", "Local")

    local Local_Player = World:get(Local_Entity, Components.Player)
    local Tutorial_Step = World:get(Local_Entity, Components.Tutorial_Step)

    local Character = World:get(Local_Entity, Components.Renderable)

    if not Character then
        return
    end

    local RootPart = Character:FindFirstChild("HumanoidRootPart") :: Part

    if not RootPart then
        return
    end

    local Plot_Model = World:get(Local_Entity, Components.Plot_Model)

    if not Plot_Model then
        return
    end

    if Tutorial_Step == 3 then
        local Stands = Plot_Model:FindFirstChild("Stands")
        local Stand_One = Stands and Stands:FindFirstChild("1")
        local Touch = Stand_One and Stand_One:FindFirstChild("Touch") :: Part

        Darkener:Activate(Touch, 10)
    elseif Tutorial_Step == 4 then
        local Shops_Spawn = Shops:FindFirstChild("Spawn") :: Part

        if Peek(Fusion_Values.Screen) == "Pickaxes" then
            Darkener:Switch(
                Local_Player.PlayerGui:FindFirstChild("Main"):FindFirstChild("Frames"):FindFirstChild("Pickaxes"),
                5
            )
        elseif (Shops_Spawn.Position - RootPart.Position).magnitude > 25 then
            Darkener:Switch(
                Local_Player.PlayerGui:FindFirstChild("Main"):FindFirstChild("Top"):FindFirstChild("Shops"),
                10
            )
        else
            Darkener:Switch(workspace.Map.Shops.Pickaxes.Touch)
        end
    elseif Tutorial_Step >= 5 then
        Darkener:Deactivate()
    end
end

local function Tutorial()
    Update_Darkener()
end

return {
    name = script.Name,
    phase = Phases.Runservice.PreRender,
    system = Tutorial,
    runConditions = {},
}
