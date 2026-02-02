local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Scope = Fusion.scoped(Fusion)

return table.freeze({
    Screen = Scope:Value("HUD"),
    Cash = Scope:Value(0),
    Pickaxe = Scope:Value(nil),
    Owned_Pickaxes = Scope:Value({}),
})
