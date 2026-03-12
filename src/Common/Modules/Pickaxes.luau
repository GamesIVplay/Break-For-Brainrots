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
        Power = 2,
        Image = "rbxassetid://102455470086563",
        Developer_Product = 3529458977,
        Tool = Pickaxe_Tools:WaitForChild("Starter"),
    },
    ["Stone"] = {
        Rarity = "Common",
        Price = 500,
        Rebirth = 0,
        Power = 4,
        Image = "rbxassetid://99837424509453",
        Developer_Product = 3529374574,
        Tool = Pickaxe_Tools:WaitForChild("Stone"),
    },
    ["Ruby"] = {
        Rarity = "Common",
        Price = 1_000,
        Rebirth = 0,
        Power = 6,
        Image = "rbxassetid://123344566248684",
        Developer_Product = 3545777765,
        Tool = Pickaxe_Tools:WaitForChild("Ruby"),
    },

    -- Rare
    ["Diamond"] = {
        Rarity = "Rare",
        Price = 3_000,
        Rebirth = 0,
        Power = 8,
        Image = "rbxassetid://84725117549730",
        Developer_Product = 3554745982,
        Tool = Pickaxe_Tools:WaitForChild("Diamond"),
    },
    ["Iron"] = {
        Rarity = "Rare",
        Price = 5_000,
        Rebirth = 0,
        Power = 10,
        Image = "rbxassetid://81526194453089",
        Developer_Product = 3529456216,
        Tool = Pickaxe_Tools:WaitForChild("Iron"),
    },
    ["Gold"] = {
        Rarity = "Rare",
        Price = 10_000,
        Rebirth = 0,
        Power = 12,
        Image = "rbxassetid://85995206766563",
        Developer_Product = 3529456554,
        Tool = Pickaxe_Tools:WaitForChild("Gold"),
    },
    ["Yin Yang"] = {
        Rarity = "Rare",
        Price = 15_000,
        Rebirth = 0,
        Power = 15,
        Image = "rbxassetid://72067973931657",
        Developer_Product = 3545777868,
        Tool = Pickaxe_Tools:WaitForChild("Yin Yang"),
    },

    -- Epic
    ["Candy"] = {
        Rarity = "Epic",
        Price = 25_000,
        Rebirth = 0,
        Power = 20,
        Image = "rbxassetid://126085895816695",
        Developer_Product = 3529456696,
        Tool = Pickaxe_Tools:WaitForChild("Candy"),
    },
    ["Shark"] = {
        Rarity = "Epic",
        Price = 40_000,
        Rebirth = 0,
        Power = 25,
        Image = "rbxassetid://133332192468677",
        Developer_Product = 3545777942,
        Tool = Pickaxe_Tools:WaitForChild("Shark"),
    },
    ["Toxic"] = {
        Rarity = "Epic",
        Price = 80_000,
        Rebirth = 0,
        Power = 30,
        Image = "rbxassetid://127007778356683",
        Developer_Product = 3529456796,
        Tool = Pickaxe_Tools:WaitForChild("Toxic"),
    },

    -- Legendary
    ["Lava"] = {
        Rarity = "Legendary",
        Price = 120_000,
        Rebirth = 0,
        Power = 36,
        Image = "rbxassetid://95702708325404",
        Developer_Product = 3529456895,
        Tool = Pickaxe_Tools:WaitForChild("Lava"),
    },
    ["Ice"] = {
        Rarity = "Legendary",
        Price = 300_000,
        Rebirth = 0,
        Power = 44,
        Image = "rbxassetid://91474283800298",
        Developer_Product = 3529457012,
        Tool = Pickaxe_Tools:WaitForChild("Ice"),
    },
    ["Glitch"] = {
        Rarity = "Legendary",
        Price = 700_000,
        Rebirth = 0,
        Power = 52,
        Image = "rbxassetid://112421977124033",
        Developer_Product = 3529457124,
        Tool = Pickaxe_Tools:WaitForChild("Glitch"),
    },

    -- Mythical
    ["67"] = {
        Rarity = "Mythical",
        Price = 1_000_000,
        Rebirth = 0,
        Power = 67,
        Image = "rbxassetid://77223024075900",
        Developer_Product = 3529457220,
        Tool = Pickaxe_Tools:WaitForChild("67"),
    },
    ["UFO"] = {
        Rarity = "Mythical",
        Price = 2_000_000,
        Rebirth = 0,
        Power = 85,
        Image = "rbxassetid://77362587488589",
        Developer_Product = 3529457345,
        Tool = Pickaxe_Tools:WaitForChild("UFO"),
    },
    ["Electro"] = {
        Rarity = "Mythical",
        Price = 4_000_000,
        Rebirth = 0,
        Power = 105,
        Image = "rbxassetid://81403123319089",
        Developer_Product = 3529457437,
        Tool = Pickaxe_Tools:WaitForChild("Electro"),
    },

    -- Secret
    ["Angel"] = {
        Rarity = "Secret",
        Price = 8_000_000,
        Rebirth = 0,
        Power = 120,
        Image = "rbxassetid://103777101628861",
        Developer_Product = 3529457565,
        Tool = Pickaxe_Tools:WaitForChild("Angel"),
    },

    ["Dragon"] = {
        Rarity = "Secret",
        Price = 15_000_000,
        Rebirth = 0,
        Power = 135,
        Image = "rbxassetid://131641452173182",
        Developer_Product = 3545778050,
        Tool = Pickaxe_Tools:WaitForChild("Dragon"),
    },

    ["Hacker"] = {
        Rarity = "Secret",
        Price = 20_000_000,
        Rebirth = 0,
        Power = 155,
        Image = "rbxassetid://112078578632696",
        Developer_Product = 3545778098,
        Tool = Pickaxe_Tools:WaitForChild("Hacker"),
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
