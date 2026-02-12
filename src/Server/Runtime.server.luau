local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Start = require(ReplicatedStorage.Common.Start)

local Systems = script.Parent.Systems

Start({
    require(Systems.Create_Folders),
    require(Systems.Player_Session),
    require(Systems.Plot),
    require(Systems.Brainrot_Loader),
    require(Systems.Restock),
    require(Systems.Buy_Pickaxe),
    require(Systems.Buy_Block),
    require(Systems.Buy_Upgrade),
    require(Systems.Equip_Pickaxe),
    require(Systems.Skip_Block),
    require(Systems.Block_Spawner),
    require(Systems.Swing),
    require(Systems.Block_Overhead),
    require(Systems.Block_Open),
    require(Systems.Place),
    require(Systems.Pickup),
    require(Systems.Cash_Generator),
    require(Systems.Collect),
    require(Systems.Data_Sender),
    require(Systems.Leaderstats),
})
