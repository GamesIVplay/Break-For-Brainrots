local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Brainrot_Models = Assets:WaitForChild("Brainrots")

local Primary_Mutations = require(ReplicatedStorage.Common.Modules.Primary_Mutations)
local Types = require(ReplicatedStorage.Common.Types)

type Brainrot = {
    Rarity: Types.Rarity,
    IncomePerSec: number,
}

local Brainrots: { [string]: Brainrot } = {
    -- Common (4 → 18)
    ["Fluri Flura"] = { Rarity = "Common", IncomePerSec = 4 },
    ["Pipi Kiwi"] = { Rarity = "Common", IncomePerSec = 6 },
    ["Garamararam"] = { Rarity = "Common", IncomePerSec = 8 },
    ["Tim Cheese"] = { Rarity = "Common", IncomePerSec = 10 },
    ["Svinina Bombardino"] = { Rarity = "Common", IncomePerSec = 12 },
    ["Madudung"] = { Rarity = "Common", IncomePerSec = 14 },
    ["Talpa Di Fero"] = { Rarity = "Common", IncomePerSec = 16 },
    ["Lirili Larila"] = { Rarity = "Common", IncomePerSec = 18 },

    -- Rare (20 → 76)
    ["Trulimero Trulicina"] = { Rarity = "Rare", IncomePerSec = 20 },
    ["Bobrito Bandito"] = { Rarity = "Rare", IncomePerSec = 26 },
    ["Gangster Footera"] = { Rarity = "Rare", IncomePerSec = 36 },
    ["Ta Ta Ta Ta Sahur"] = { Rarity = "Rare", IncomePerSec = 44 },
    ["Cacto Hipopotamo"] = { Rarity = "Rare", IncomePerSec = 56 },
    ["Boneca Ambalabu"] = { Rarity = "Rare", IncomePerSec = 68 },
    ["Trippi Troppi"] = { Rarity = "Rare", IncomePerSec = 76 },

    -- Epic (96 → 225)
    ["Brr Brr Patapim"] = { Rarity = "Epic", IncomePerSec = 96 },
    ["Bambini Crostini"] = { Rarity = "Epic", IncomePerSec = 108 },
    ["Brri Brri Bicus Dicus"] = { Rarity = "Epic", IncomePerSec = 116 },
    ["Cappuccino Assassino"] = { Rarity = "Epic", IncomePerSec = 126 },
    ["Bananita Dolphinita"] = { Rarity = "Epic", IncomePerSec = 144 },
    ["Pandaccini Bananini"] = { Rarity = "Epic", IncomePerSec = 156 },
    ["Chimpanzini Bananini"] = { Rarity = "Epic", IncomePerSec = 180 },
    ["Blueberrinni Octopusini"] = { Rarity = "Epic", IncomePerSec = 190 },
    ["Tung Sahur"] = { Rarity = "Epic", IncomePerSec = 200 },
    ["Burbaloni Luliloli"] = { Rarity = "Epic", IncomePerSec = 210 },
    ["Ballerino Lololo"] = { Rarity = "Epic", IncomePerSec = 225 },

    -- Legendary (200 → 1,200)
    ["Chef Crabracadabra"] = { Rarity = "Legendary", IncomePerSec = 200 },
    ["Pipi Potato"] = { Rarity = "Legendary", IncomePerSec = 280 },
    ["Ballerina Cappuccina"] = { Rarity = "Legendary", IncomePerSec = 360 },
    ["Glorbo Fruttodrillo"] = { Rarity = "Legendary", IncomePerSec = 420 },
    ["Tralalita Tralala"] = { Rarity = "Legendary", IncomePerSec = 520 },
    ["Gorillo Watermelondrillo"] = { Rarity = "Legendary", IncomePerSec = 600 },
    ["Cocofanto Elefanto"] = { Rarity = "Legendary", IncomePerSec = 700 },
    ["Matteo"] = { Rarity = "Legendary", IncomePerSec = 760 },
    ["Job Job Job Sahur"] = { Rarity = "Legendary", IncomePerSec = 900 },
    ["Zibra Zubra Zibralini"] = { Rarity = "Legendary", IncomePerSec = 920 },
    ["Trippi Troppi Troppa Trippa"] = { Rarity = "Legendary", IncomePerSec = 1_000 },
    ["Pakrahmatmamat"] = { Rarity = "Legendary", IncomePerSec = 1_080 },
    ["Girafa Celeste"] = { Rarity = "Legendary", IncomePerSec = 1_160 },

    -- Mythical (1,200 → 2,400)
    ["Rhino Toasterino"] = { Rarity = "Mythical", IncomePerSec = 1_200 },
    ["Avocadini Guffo"] = { Rarity = "Mythical", IncomePerSec = 1_300 },
    ["Bombombini Gusini"] = { Rarity = "Mythical", IncomePerSec = 1_400 },
    ["Frigo Camelo"] = { Rarity = "Mythical", IncomePerSec = 1_500 },
    ["Orangutini Ananassini"] = { Rarity = "Mythical", IncomePerSec = 1_620 },
    ["Cavallo Virtuoso"] = { Rarity = "Mythical", IncomePerSec = 1_700 },
    ["Strawberrelli Flamingelli"] = { Rarity = "Mythical", IncomePerSec = 1_820 },
    ["Bombardiro Crocodilo"] = { Rarity = "Mythical", IncomePerSec = 2_000 },
    ["Lerulerulerule"] = { Rarity = "Mythical", IncomePerSec = 2_200 },

    -- Secret (2,600 → 3,400)
    ["Pakrahmatmatina"] = { Rarity = "Secret", IncomePerSec = 2_600 },
    ["Espresso Signora"] = { Rarity = "Secret", IncomePerSec = 2_680 },
    ["Los Tralaleritos"] = { Rarity = "Secret", IncomePerSec = 400 },
    ["Karkerkar Kurkur"] = { Rarity = "Secret", IncomePerSec = 2_840 },
    ["Six Seven"] = { Rarity = "Secret", IncomePerSec = 2_920 },
    ["Agarrini La Pallini"] = { Rarity = "Secret", IncomePerSec = 3_000 },
    ["Dragon Cannelloni"] = { Rarity = "Secret", IncomePerSec = 3_080 },
    ["Pot Hotspot"] = { Rarity = "Secret", IncomePerSec = 3_160 },
    ["Chicleteira Bicicleteira"] = { Rarity = "Secret", IncomePerSec = 3_240 },
    ["Esok Sekolah"] = { Rarity = "Secret", IncomePerSec = 3_320 },
    ["Torrtuginni Dragonfrutini"] = { Rarity = "Secret", IncomePerSec = 3_400 },
}

local function Verify_Integrity()
    for Brainrot_Name in Brainrots do
        for Primary_Mutation_Name in Primary_Mutations do
            local MutationFolder = Brainrot_Models:FindFirstChild(Primary_Mutation_Name)
            if not MutationFolder then
                error(("[Brainrots Integrity] Missing Primary Mutation folder: '%s'"):format(Primary_Mutation_Name))
            end

            local Brainrot_Model = MutationFolder:FindFirstChild(Brainrot_Name)
            if not Brainrot_Model then
                error(
                    ("[Brainrots Integrity] Missing Brainrot model '%s' in Primary Mutation '%s'"):format(
                        Brainrot_Name,
                        Primary_Mutation_Name
                    )
                )
            end

            -- Check PrimaryPart
            if not Brainrot_Model.PrimaryPart then
                error(
                    ("[Brainrots Integrity] Model '%s' in Primary Mutation '%s' has no PrimaryPart set"):format(
                        Brainrot_Name,
                        Primary_Mutation_Name
                    )
                )
            end

            local NormalFolder = Brainrot_Models:FindFirstChild("Normal")
            if not NormalFolder then
                error("[Brainrots Integrity] Missing Normal folder")
            end

            local Normal_Model = NormalFolder:FindFirstChild(Brainrot_Name)
            if not Normal_Model then
                error(("[Brainrots Integrity] Missing Brainrot model '%s' in Normal folder"):format(Brainrot_Name))
            end

            if not Normal_Model.PrimaryPart then
                error(("[Brainrots Integrity] Normal model '%s' has no PrimaryPart set"):format(Brainrot_Name))
            end
        end
    end
end

Verify_Integrity()

return table.freeze(Brainrots)
