local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Pickaxe_Tools = Assets:WaitForChild("Pickaxes")

local Types = require(ReplicatedStorage.Common.Types)

type Pickaxe = {
    Rarity: Types.Rarity,
    Price: number?,
    Rebirth: number,
    Power: number,
    Image: string,
    Developer_Product: number,
    Tool: Tool,
}

local Pickaxes: { [string]: Pickaxe } = {
    -- Common
    ["Starter"] = {
        Rarity = "Common",
        Price = 150,
        Rebirth = 0,
        Power = 1,
        Image = "rbxassetid://102455470086563",
        Developer_Product = 3529458977,
        Tool = Pickaxe_Tools:WaitForChild("Starter"),
    },
    ["Stone"] = {
        Rarity = "Common",
        Price = 500,
        Rebirth = 0,
        Power = 2,
        Image = "rbxassetid://99837424509453",
        Developer_Product = 3529374574,
        Tool = Pickaxe_Tools:WaitForChild("Stone"),
    },

    -- Rare
    ["Iron"] = {
        Rarity = "Rare",
        Price = 5_000,
        Rebirth = 0,
        Power = 4,
        Image = "rbxassetid://81526194453089",
        Developer_Product = 3529456216,
        Tool = Pickaxe_Tools:WaitForChild("Iron"),
    },
    ["Gold"] = {
        Rarity = "Rare",
        Price = 15_000,
        Rebirth = 0,
        Power = 8,
        Image = "rbxassetid://85995206766563",
        Developer_Product = 3529456554,
        Tool = Pickaxe_Tools:WaitForChild("Gold"),
    },

    -- Epic
    ["Candy"] = {
        Rarity = "Epic",
        Price = 35_000,
        Rebirth = 0,
        Power = 12,
        Image = "rbxassetid://126085895816695",
        Developer_Product = 3529456696,
        Tool = Pickaxe_Tools:WaitForChild("Candy"),
    },
    ["Toxic"] = {
        Rarity = "Epic",
        Price = 100_000,
        Rebirth = 0,
        Power = 16,
        Image = "rbxassetid://127007778356683",
        Developer_Product = 3529456796,
        Tool = Pickaxe_Tools:WaitForChild("Toxic"),
    },

    -- Legendary
    ["Lava"] = {
        Rarity = "Legendary",
        Price = 500_000,
        Rebirth = 0,
        Power = 22,
        Image = "rbxassetid://95702708325404",
        Developer_Product = 3529456895,
        Tool = Pickaxe_Tools:WaitForChild("Lava"),
    },
    ["Ice"] = {
        Rarity = "Legendary",
        Price = 1_000_000,
        Rebirth = 0,
        Power = 30,
        Image = "rbxassetid://91474283800298",
        Developer_Product = 3529457012,
        Tool = Pickaxe_Tools:WaitForChild("Ice"),
    },
    ["Glitch"] = {
        Rarity = "Legendary",
        Price = 2_000_000,
        Rebirth = 0,
        Power = 42,
        Image = "rbxassetid://112421977124033",
        Developer_Product = 3529457124,
        Tool = Pickaxe_Tools:WaitForChild("Glitch"),
    },

    -- Mythical
    ["67"] = {
        Rarity = "Mythical",
        Price = 5_000_000,
        Rebirth = 0,
        Power = 67,
        Image = "rbxassetid://77223024075900",
        Developer_Product = 3529457220,
        Tool = Pickaxe_Tools:WaitForChild("67"),
    },
    ["UFO"] = {
        Rarity = "Mythical",
        Price = 10_000_000,
        Rebirth = 1,
        Power = 88,
        Image = "rbxassetid://77362587488589",
        Developer_Product = 3529457345,
        Tool = Pickaxe_Tools:WaitForChild("UFO"),
    },
    ["Electro"] = {
        Rarity = "Mythical",
        Price = 20_000_000,
        Rebirth = 2,
        Power = 98,
        Image = "rbxassetid://81403123319089",
        Developer_Product = 3529457437,
        Tool = Pickaxe_Tools:WaitForChild("Electro"),
    },

    -- Secret
    ["Angel"] = {
        Rarity = "Secret",
        Price = 25_000_000,
        Rebirth = 2,
        Power = 108,
        Image = "rbxassetid://103777101628861",
        Developer_Product = 3529457565,
        Tool = Pickaxe_Tools:WaitForChild("Angel"),
    },
}

local function Setup_Tools()
    for Name, Data in Pickaxes do
        local Tool = Data.Tool

        Tool.ToolTip = `{Name} Pickaxe`
        Tool.CanBeDropped = false
        Tool.TextureId = Data.Image
        Tool:AddTag("Pickaxe")
    end
end

Setup_Tools()

return table.freeze(Pickaxes)
