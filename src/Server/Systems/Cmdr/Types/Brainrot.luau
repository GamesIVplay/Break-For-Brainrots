local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Brainrots = require(ReplicatedStorage.Common.Modules.Brainrots)

return function(Registry)
    local Brainrot_Names = {}

    for Name in Brainrots do
        table.insert(Brainrot_Names, Name)
    end

    Registry:RegisterType("brainrot", Registry.Cmdr.Util.MakeEnumType("Brainrot", Brainrot_Names))
end
