local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Start = require(ReplicatedStorage.Common.Start)
require(ReplicatedStorage.Common.Modules.Brainrots)
require(ReplicatedStorage.Common.Modules.Blocks)

local Systems = script.Parent.Systems

Start({
    require(Systems.Create_Folders),
    require(Systems.Player_Session),
    require(Systems.Plot),
    require(Systems.Restock),
    require(Systems.Buy_Pickaxe),
    require(Systems.Buy_Block),
    require(Systems.Buy_Upgrade),
    require(Systems.Equip_Pickaxe),
    require(Systems.Skip_Block),
    require(Systems.Block_Spawner),
    require(Systems.Block_Overhead),
    require(Systems.Data_Sender),
    require(Systems.Leaderstats),
})
