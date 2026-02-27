local CollectionService = game:GetService("CollectionService")
local MarketPlaceService = game:GetService("MarketplaceService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SocialService = game:GetService("SocialService")
local TweenService = game:GetService("TweenService")

local Map = workspace:WaitForChild("Map") :: Folder
local Shops = Map:WaitForChild("Shops") :: Folder

local Assets = ReplicatedStorage:WaitForChild("Assets")

local Zone = require(Assets:WaitForChild("Modules"):WaitForChild("Zone")) :: any

local Billboards = Assets:WaitForChild("Billboards")
local Home_Billboard = Billboards:WaitForChild("Home") :: BillboardGui

local VFX = ReplicatedStorage.Common.Modules.VFX

local Network = require(ReplicatedFirst.Network)

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Peek = Fusion.peek

local Clock = require(ReplicatedStorage.Packages.Clock)

local Components = require(ReplicatedStorage.Common.Components)
local Config = require(ReplicatedStorage.Common.Config)
local Log = require(ReplicatedStorage.Common.Log)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local Types = require(ReplicatedStorage.Common.Types)
local World = require(ReplicatedStorage.Common.World)

local Developer_Products = require(ReplicatedStorage.Common.Modules.Developer_Products)
local Gamepasses = require(ReplicatedStorage.Common.Modules.Gamepasses)
local Proximity = require(ReplicatedStorage.Common.Modules.Proximity)
local Ratelimits = require(ReplicatedStorage.Common.Modules.Ratelimits)
local Stat_Calculator = require(ReplicatedStorage.Common.Modules.Stat_Calculator)
local Tutorial_Steps = require(ReplicatedStorage.Common.Modules.Tutorial_Steps)
local Unicode_Characters = require(ReplicatedStorage.Common.Modules.Unicode_Characters)
local Util = require(ReplicatedStorage.Common.Modules.Util)

local Fusion_Values = require(ReplicatedFirst.Client.Modules.Fusion_Values)

local TOUCH_PART_BOUNCE_TIME = 0.08
local TOUCH_PART_TWEEN_INFO = TweenInfo.new(TOUCH_PART_BOUNCE_TIME, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
local STOCK_START_TIMESTAMP = 1772190287
local STOCK_FULL_TIME = 2 * 7 * 86400

local function BindFakeStock(Count: TextLabel, Max_Count: number)
    local CurrentStock = 0

    local function Update()
        local Now = os.time()
        local Elapsed = math.max(0, Now - STOCK_START_TIMESTAMP)
        local Alpha = math.clamp(Elapsed / STOCK_FULL_TIME, 0, 1)

        CurrentStock = math.floor(Max_Count * Alpha)
        Count.Text = string.format("%d/%d", CurrentStock, Max_Count)
    end

    Update()
    Clock(30, Update)

    return function()
        return CurrentStock
    end
end

local function On_Plot_Assigned(Local_Entity: Types.Entity, Plot_Model: Model)
    local Local_Player = World:get(Local_Entity, Components.Player)

    World:set(Local_Entity, Components.Plot_Model, Plot_Model)

    Home_Billboard:Clone().Parent = Plot_Model

    local Break_Prompt, Skip_Screen =
        Plot_Model:WaitForChild("Break"):WaitForChild("Prompt") :: Part,
        Plot_Model:WaitForChild("Skip"):WaitForChild("Screen") :: Part

    Proximity(Break_Prompt, {
        ActionText = "Break Block",
        MaxActivationDistance = 4.5,
    }, function()
        MarketPlaceService:PromptProductPurchase(Local_Player, Developer_Products["Break Block"])
    end)

    Proximity(Skip_Screen, {
        ActionText = "Skip Block",
        MaxActivationDistance = 4.5,
    }, function()
        Network.Requests.Skip_Block.Fire()
    end)

    local Stands = Plot_Model:FindFirstChild("Stands")

    for _, Stand_Model in Stands:GetChildren() do
        local Touch = Stand_Model:FindFirstChild("Touch") :: Part
        local Brainrot_Spawn_Attachment = Stand_Model:FindFirstChild("Brainrot_Spawn", true) :: Attachment

        local Tween_Up = TweenService:Create(Touch, TOUCH_PART_TWEEN_INFO, {
            Position = Touch.Position,
        })

        local Tween_Down = TweenService:Create(Touch, TOUCH_PART_TWEEN_INFO, {
            Position = Touch.Position - Vector3.new(0, 0.35, 0),
        })

        local Place_Prompt = Proximity(Brainrot_Spawn_Attachment, {
            ActionText = "Place Brainrot",
            MaxActivationDistance = 6,
            HoldDuration = 0.5,
        }, function()
            local ServerEntity = Stand_Model:GetAttribute("ServerEntity")

            if ServerEntity and Ratelimits.Pickup() then
                Network.Requests.Pickup.Fire(ServerEntity)
            elseif Ratelimits.Place() then
                Network.Requests.Place.Fire(Stand_Model)
            end
        end)

        local function Update_Prompt_Text()
            if Stand_Model:GetAttribute("ServerEntity") then
                Place_Prompt.ActionText = "Pickup Brainrot"
            else
                Place_Prompt.ActionText = "Place Brainrot"
            end
        end

        Stand_Model:GetAttributeChangedSignal("ServerEntity"):Connect(Update_Prompt_Text)

        Update_Prompt_Text()

        local Collect_Zone = Zone.fromParts({ Touch })
        Collect_Zone:BindToHeartbeat()

        Collect_Zone:ListenTo("Player", "Entered", function(Target_Player: Player)
            if Target_Player ~= Local_Player then
                return
            end

            if not Ratelimits.Collect(Stand_Model) then
                return
            end

            local ServerEntity = Stand_Model:GetAttribute("ServerEntity")

            if ServerEntity then
                Network.Requests.Collect.Fire(ServerEntity)

                task.spawn(require(VFX.Collect), Touch)
            end

            Tween_Down:Play()

            task.wait(0.8)

            Tween_Up:Play()
        end)
    end
end

local function Setup_Shops(Local_Player: Player)
    for _, Inst: Instance in Shops:GetChildren() do
        if not Inst:IsA("Model") then
            continue
        end

        local Touch = Inst:WaitForChild("Touch") :: Part

        local New_Zone = Zone.fromParts({ Touch })
        New_Zone:BindToHeartbeat()

        New_Zone:ListenTo("Player", "Entered", function(Target_Player: Player)
            if Target_Player ~= Local_Player then
                return
            end

            if Peek(Fusion_Values.Screen) == Inst.Name then
                return
            end

            if
                not (Peek(Fusion_Values.Tutorial_Step) >= #Tutorial_Steps)
                and (Peek(Fusion_Values.Tutorial_Step) ~= 4 or Inst.Name ~= "Pickaxes")
            then
                local Entity = World:entity()
                World:set(Entity, Components.Text, "Complete the tutorial first")
                World:set(Entity, Components.NotificationType, "Error")
                World:add(Entity, Components.Tags.Notification)
                return
            end

            Fusion_Values.Screen:set(Inst.Name)
        end)

        New_Zone:ListenTo("Player", "Exited", function(Target_Player: Player)
            if Target_Player ~= Local_Player then
                return
            end

            if Peek(Fusion_Values.Screen) == Inst.Name then
                Fusion_Values.Screen:set("HUD")
            end
        end)
    end
end

local function Setup_x2_Cash_Parts(Local_Player: Player)
    for _, Inst in CollectionService:GetTagged("x2Cash") do
        if not Inst:IsA("Model") then
            continue
        end

        local Touch = Inst:FindFirstChild("Touch") :: Part

        if not Touch then
            continue
        end

        local New_Zone = Zone.fromParts({ Touch })
        New_Zone:BindToHeartbeat()

        New_Zone:ListenTo("Player", "Entered", function(Target_Player: Player)
            if Target_Player ~= Local_Player then
                return
            end

            MarketPlaceService:PromptGamePassPurchase(Local_Player, Gamepasses["x2 Cash"])
        end)
    end
end

local function Setup_x2_Luck_Parts(Local_Player: Player)
    for _, Inst in CollectionService:GetTagged("x2Luck") do
        if not Inst:IsA("Model") then
            continue
        end

        local Touch = Inst:FindFirstChild("Touch") :: Part

        if not Touch then
            continue
        end

        local New_Zone = Zone.fromParts({ Touch })
        New_Zone:BindToHeartbeat()

        New_Zone:ListenTo("Player", "Entered", function(Target_Player: Player)
            if Target_Player ~= Local_Player then
                return
            end

            MarketPlaceService:PromptGamePassPurchase(Local_Player, Gamepasses["x2 Luck"])
        end)
    end
end

local function Setup_Update_Signs(Local_Player: Player)
    local Event_Info = SocialService:GetExperienceEventAsync(Config.UPDATE_EVENT_ID)

    if not Event_Info then
        Log.Warn("Failed to retrieve update event data")
        return
    end

    for _, Inst in CollectionService:GetTagged("Update Sign") do
        if not Inst:IsA("Model") then
            continue
        end

        local Display = Inst:FindFirstChild("Display")

        if not Display then
            continue
        end

        Proximity(
            Display,
            { ObjectText = "Next Update!", ActionText = "Sign Up", MaxActivationDistance = 8 },
            function()
                SocialService:PromptRsvpToEventAsync(Config.UPDATE_EVENT_ID)
            end
        )
    end

    local StartInfo = Event_Info.StartTime
    local EndInfo = Event_Info.EndTime

    local StartDateTime = DateTime.fromUniversalTime(
        StartInfo.Year,
        StartInfo.Month,
        StartInfo.Day,
        StartInfo.Hour,
        StartInfo.Minute,
        StartInfo.Second,
        StartInfo.Millisecond
    )

    local EndDateTime = DateTime.fromUniversalTime(
        EndInfo.Year,
        EndInfo.Month,
        EndInfo.Day,
        EndInfo.Hour,
        EndInfo.Minute,
        EndInfo.Second,
        EndInfo.Millisecond
    )

    Clock(1, function()
        for _, Inst in CollectionService:GetTagged("Update Sign") do
            local Timer = Inst:FindFirstChild("Timer", true) :: TextLabel
            if not Timer then
                continue
            end

            local NowDateTime = DateTime.now()

            if NowDateTime.UnixTimestamp >= EndDateTime.UnixTimestamp then
                Timer.Text = "Ended"
                continue
            end

            if NowDateTime.UnixTimestamp >= StartDateTime.UnixTimestamp then
                Timer.Text = "00:00:00"
                continue
            end

            local Remaining = StartDateTime.UnixTimestamp - NowDateTime.UnixTimestamp

            local Hours = math.floor(Remaining / 3600)
            local Minutes = math.floor((Remaining % 3600) / 60)
            local Seconds = Remaining % 60

            Timer.Text = string.format("%02d:%02d:%02d", Hours, Minutes, Seconds)
        end
    end)
end

local function Setup_Troll_Face(Local_Player: Player)
    for _, Inst in CollectionService:GetTagged("Troll Face") do
        if not Inst:IsA("Model") then
            continue
        end

        local Title = Inst:FindFirstChild("Title", true) :: TextLabel

        local Income_Per_Sec = Stat_Calculator.Calculate_Income_Per_Sec({
            Brainrot_Name = "Troll Face",
            Secondary_Mutations = {},
            Weight = 10,
        })

        Title.Text = `Troll Face (${Util.Format_Number_With_Commas(Income_Per_Sec)}+/s)`

        task.spawn(function()
            local Price = Inst:FindFirstChild("Price", true)
            local Product_Info = Util.Get_Product_Info(Developer_Products["Troll Face"])

            if Product_Info then
                Price.Text = `{Unicode_Characters.Robux}{Util.Format_Number_With_Commas(Product_Info.PriceInRobux)}`
            else
                Price.Text = ""
            end
        end)

        local Count = Inst:FindFirstChild("Count", true) :: TextLabel
        local Get_Stock = BindFakeStock(Count, 750)

        local Prompt = Inst:FindFirstChild("Prompt", true) :: Attachment

        Proximity(Prompt, { ActionText = "Purchase", ObjectText = "Troll Face", MaxActivationDistance = 15 }, function()
            if Get_Stock() >= 750 then
                local Entity = World:entity()
                World:set(Entity, Components.Text, "This is sold Out")
                World:set(Entity, Components.NotificationType, "Error")
                World:add(Entity, Components.Tags.Notification)
                return
            end

            MarketPlaceService:PromptProductPurchase(Local_Player, Developer_Products["Troll Face"])
        end)
    end
end

local function Setup_La_Grande_Combinasion(Local_Player: Player)
    for _, Inst in CollectionService:GetTagged("La Grande Combinasion") do
        if not Inst:IsA("Model") then
            continue
        end

        local Title = Inst:FindFirstChild("Title", true) :: TextLabel

        local Income_Per_Sec = Stat_Calculator.Calculate_Income_Per_Sec({
            Brainrot_Name = "La Grande Combinasion",
            Secondary_Mutations = {},
            Weight = 10,
        })

        Title.Text = `Troll Face (${Util.Format_Number_With_Commas(Income_Per_Sec)}+/s)`

        task.spawn(function()
            local Price = Inst:FindFirstChild("Price", true)
            local Product_Info = Util.Get_Product_Info(Developer_Products["La Grande Combinasion"])

            if Product_Info then
                Price.Text = `{Unicode_Characters.Robux}{Util.Format_Number_With_Commas(Product_Info.PriceInRobux)}`
            else
                Price.Text = ""
            end
        end)

        local Count = Inst:FindFirstChild("Count", true) :: TextLabel
        local Get_Stock = BindFakeStock(Count, 250)

        local Prompt = Inst:FindFirstChild("Prompt", true) :: Attachment

        Proximity(
            Prompt,
            { ActionText = "Purchase", ObjectText = "La Grande Combinasion", MaxActivationDistance = 15 },
            function()
                if Get_Stock() >= 250 then
                    local Entity = World:entity()
                    World:set(Entity, Components.Text, "This is sold Out")
                    World:set(Entity, Components.NotificationType, "Error")
                    World:add(Entity, Components.Tags.Notification)
                    return
                end

                MarketPlaceService:PromptProductPurchase(Local_Player, Developer_Products["La Grande Combinasion"])
            end
        )
    end
end

local function Setup_Skibidi_Toilet(Local_Player: Player)
    for _, Inst in CollectionService:GetTagged("Skibidi Toilet") do
        if not Inst:IsA("Model") then
            continue
        end

        local Title = Inst:FindFirstChild("Title", true) :: TextLabel

        local Income_Per_Sec = Stat_Calculator.Calculate_Income_Per_Sec({
            Brainrot_Name = "Skibidi Toilet",
            Secondary_Mutations = {},
            Weight = 10,
        })

        Title.Text = `Troll Face (${Util.Format_Number_With_Commas(Income_Per_Sec)}+/s)`

        task.spawn(function()
            local Price = Inst:FindFirstChild("Price", true)
            local Product_Info = Util.Get_Product_Info(Developer_Products["Skibidi Toilet"])

            if Product_Info then
                Price.Text = `{Unicode_Characters.Robux}{Util.Format_Number_With_Commas(Product_Info.PriceInRobux)}`
            else
                Price.Text = ""
            end
        end)

        local Count = Inst:FindFirstChild("Count", true) :: TextLabel
        local Get_Stock = BindFakeStock(Count, 500)

        local Prompt = Inst:FindFirstChild("Prompt", true) :: Attachment

        Proximity(
            Prompt,
            { ActionText = "Purchase", ObjectText = "Skibidi Toilet", MaxActivationDistance = 15 },
            function()
                if Get_Stock() >= 500 then
                    local Entity = World:entity()
                    World:set(Entity, Components.Text, "This is sold Out")
                    World:set(Entity, Components.NotificationType, "Error")
                    World:add(Entity, Components.Tags.Notification)
                    return
                end

                MarketPlaceService:PromptProductPurchase(Local_Player, Developer_Products["Skibidi Toilet"])
            end
        )
    end
end

return {
    name = script.Name,
    phase = Phases.InitPhases.Init,
    system = function()
        local Local_Entity = Registry.Get("Players", "Local")
        local Local_Player = World:get(Local_Entity, Components.Player)

        Network.DataChanged.Plot_Assigned.On(function(Plot_Model: Model)
            On_Plot_Assigned(Local_Entity, Plot_Model)
        end)

        Setup_Shops(Local_Player)

        Setup_x2_Cash_Parts(Local_Player)

        Setup_x2_Luck_Parts(Local_Player)

        task.spawn(Setup_Update_Signs, Local_Player)

        Setup_Troll_Face(Local_Player)

        Setup_La_Grande_Combinasion(Local_Player)

        Setup_Skibidi_Toilet(Local_Player)
    end,
    runConditions = {},
}
