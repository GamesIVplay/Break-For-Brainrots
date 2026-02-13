local Slot_Util = {}

function Slot_Util.Set_Slot(Slots, Index, Value, MaxSlots)
    assert(Index >= 1 and Index <= MaxSlots)
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
    assert(Index >= 1 and Index <= MaxSlots)
    return Slots[Index] ~= nil
end

return Slot_Util
