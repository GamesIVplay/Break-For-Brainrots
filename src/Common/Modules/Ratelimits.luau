local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Ratelimit = require(ReplicatedStorage.Packages.Ratelimit)

return table.freeze({
    Swing_Rate_Limit = Ratelimit(1, 0.35),
    Collect = Ratelimit(1, 1),
    Place = Ratelimit(1, 0.5),
    Pickup = Ratelimit(1, 0.5),
    Equip_Best_Brainrots = Ratelimit(1, 1),
    Sell = Ratelimit(1, 0.5),
    Sell_All = Ratelimit(1, 0.5),
    Sell_Brainrot_Item_Group = Ratelimit(1, 0.5),
    Gift = Ratelimit(1, 0.5),
    Rebirth = Ratelimit(1, 0.5),
    Claim_Group_Reward = Ratelimit(1, 0.5),
    Claim_Daily_Reward = Ratelimit(1, 0.5),
})
