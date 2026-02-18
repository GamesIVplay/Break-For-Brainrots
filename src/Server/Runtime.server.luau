local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Start = require(ReplicatedStorage.Common.Start)

local Systems = script.Parent.Systems

Start({
    require(Systems.Cmdr),
    require(Systems.Create_Folders),
    require(Systems.Purchase_Handler),
    require(Systems.Player_Session),
    require(Systems.Plot),
    require(Systems.Brainrot_Loader),
    require(Systems.Event),
    require(Systems.Block_Reward),
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
    require(Systems.Gift),
    require(Systems.Equip_Best_Brainrots),
    require(Systems.Cash_Generator),
    require(Systems.Collect),
    require(Systems.Sell),
    require(Systems.Rebirth),
    require(Systems.Claim_Daily_Reward),
    require(Systems.Claim_Group_Reward),
    require(Systems.Cleanup),
    require(Systems.PlayTime),
    require(Systems.Leaderstats),
    require(Systems.Leaderboard),
    require(Systems.Data_Sender),
})
