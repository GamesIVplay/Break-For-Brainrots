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
local Get_Target_Block = require(ReplicatedFirst.Client.Modules.Get_Target_Block)

--[[local function Setup_Tutorial_Darkener(LocalEntity: Types.Entity)
    local Darkener = ScreenDarkener.New(0, 8)
    Darkener:Activate()

    RunService.RenderStepped:Connect(function()
        local Plot_Model = World:get(LocalEntity, Components.Plot_Model)

        if not Plot_Model then
            return
        end

        local Target_Block: Model?

        for _, Model in CollectionService:GetTagged(Plot_Model.Name .. "_Block") do
            Target_Block = Model
            break
        end

        local Tutorial_Step = Peek(Fusion_Values.Tutorial_Step)

        if Tutorial_Step == 1 and Target_Block then
            -- Darkener:Set(Target_Block.PrimaryPart, 500)

            print(1)
        elseif Tutorial_Step == 3 and Plot_Model then
            local Stands = Plot_Model:FindFirstChild("Stands")
            local Stand_One = Stands:FindFirstChild("1")
            local Touch = Stand_One:FindFirstChild("Touch")

            Darkener:Set(Touch, 200)

            print(2)
        elseif Tutorial_Step == 4 then
            Darkener:Set(workspace.Map.Shops.Pickaxes.Touch, 300)
            print(3)
        elseif Tutorial_Step >= #Tutorial_Steps then
            Darkener:Deactivate()
        end
    end)
end]]

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
