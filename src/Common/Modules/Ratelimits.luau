local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Ratelimit = require(ReplicatedStorage.Packages.Ratelimit)

return table.freeze({
    Swing_Rate_Limit = Ratelimit(1, 0.35),
    Collect = Ratelimit(1, 1),
    Place = Ratelimit(1, 0.5),
    Pickup = Ratelimit(1, 0.5),
    Equip_Best_Brainrots = Ratelimit(1, 0.25),
})
