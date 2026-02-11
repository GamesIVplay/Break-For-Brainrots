local BASE_WEIGHT = 10

local Weight = {}

function Weight.Roll_Weight()
    local Factor = math.random(70, 140) / 100
    local Weight_Value = BASE_WEIGHT * Factor

    if math.random() < 0.02 then
        local Lucky_multiplier = math.random(2, 4)
        Weight_Value *= Lucky_multiplier
    end

    return Weight_Value
end

function Weight.GetScale(Weight_Value: number, Min_scale: number?, Max_scale: number?)
    Min_scale = Min_scale or 1
    Max_scale = Max_scale or 2

    local Scale = math.clamp(Weight_Value / BASE_WEIGHT, Min_scale, Max_scale)
    return Scale
end

function Weight.Get_Cash_Multiplier(Weight_Value: number)
    return Weight_Value / BASE_WEIGHT
end

return Weight
