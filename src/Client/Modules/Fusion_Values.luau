local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Scope = Fusion.scoped(Fusion)

return table.freeze({
    Screen = Scope:Value("HUD"),
    Cash = Scope:Value(0),
    Rebirth = Scope:Value(0),
    Pickaxe = Scope:Value(nil),
    Owned_Pickaxes = Scope:Value({}),
    Opens = Scope:Value(0),
    Gamepasses = Scope:Value({}),
    Stock = Scope:Value({}),
    Last_Restock = Scope:Value(0),
})
