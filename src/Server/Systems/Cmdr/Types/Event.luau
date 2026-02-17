local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Events = require(ReplicatedStorage.Common.Modules.Events)

return function(Registry)
    local Event_Names = {}

    for Event_Name in Events do
        table.insert(Event_Names, Event_Name)
    end

    Registry:RegisterType("event", Registry.Cmdr.Util.MakeEnumType("Event", Event_Names))
end
