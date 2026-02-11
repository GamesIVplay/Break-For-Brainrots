local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Ratelimit = require(ReplicatedStorage.Packages.Ratelimit)

return table.freeze({
    Swing_Rate_Limit = Ratelimit(1, 0.35),
    Collect = Ratelimit(1, 1),
})
