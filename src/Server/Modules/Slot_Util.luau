local Slot_Util = {}

function Slot_Util.Set_Slot(Slots, Index, Value, MaxSlots)
    assert(Index >= 1 and Index <= MaxSlots, "slot index out of range")
    Slots[Index] = Value
end

function Slot_Util.Clear_Slot(Slots, Index)
    Slots[Index] = nil
end

function Slot_Util.Get_Total(Slots, MaxSlots)
    local Total = 0
    for i = 1, MaxSlots do
        if Slots[i] ~= nil then
            Total += 1
        end
    end
    return Total
end

function Slot_Util.Get_First_Open(Slots, MaxSlots)
    for i = 1, MaxSlots do
        if Slots[i] == nil then
            return i
        end
    end
    return nil
end

function Slot_Util.Is_Occupied(Slots, Index, MaxSlots)
    assert(Index >= 1 and Index <= MaxSlots, "slot index out of range")
    return Slots[Index] ~= nil
end

function Slot_Util.For_Each(Slots, MaxSlots, Callback)
    for i = 1, MaxSlots do
        local Value = Slots[i]
        if Value ~= nil then
            Callback(i, Value)
        end
    end
end

function Slot_Util.Clear_All(Slots, MaxSlots)
    for i = 1, MaxSlots do
        Slots[i] = nil
    end
end

return Slot_Util
