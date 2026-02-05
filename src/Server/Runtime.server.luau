local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Start = require(ReplicatedStorage.Common.Start)

local Systems = script.Parent.Systems

Start({
    require(Systems.Create_Folders),
    require(Systems.Player_Session),
    require(Systems.Plot),
    require(Systems.Purchase_Pickaxe),
    require(Systems.Equip_Pickaxe),
    require(Systems.Data_Sender),
    require(Systems.Leaderstats),
})
