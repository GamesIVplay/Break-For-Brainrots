local EstOffset = -5 * 3600
local IntervalMinutes = 20 -- change this to 15, 10, 5, etc.

local IntervalSeconds = IntervalMinutes * 60

local function SecondsUntilNextEventEst()
    local NowUtc = os.time()
    local EstTime = NowUtc + EstOffset

    local Minutes = tonumber(os.date("%M", EstTime))
    local Seconds = tonumber(os.date("%S", EstTime))

    local ElapsedThisHour = (Minutes * 60) + Seconds
    local Remainder = ElapsedThisHour % IntervalSeconds

    if Remainder == 0 then
        return 0
    end

    return IntervalSeconds - Remainder
end

return SecondsUntilNextEventEst
