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
    -- Common ($1-50/sec)
    ["Fluri Flura"] = { Rarity = "Common", IncomePerSec = 10 },
    ["Pipi Kiwi"] = { Rarity = "Common", IncomePerSec = 12 },
    ["Garamararam"] = { Rarity = "Common", IncomePerSec = 15 },
    ["Tim Cheese"] = { Rarity = "Common", IncomePerSec = 18 },
    ["Svinina Bombardino"] = { Rarity = "Common", IncomePerSec = 20 },
    ["Madudung"] = { Rarity = "Common", IncomePerSec = 25 },
    ["Talpa Di Fero"] = { Rarity = "Common", IncomePerSec = 30 },
    ["Lirili Larila"] = { Rarity = "Common", IncomePerSec = 35 },

    -- Uncommon ($50-200/sec)
    -- Add if you have Uncommon Brainrots

    -- Rare ($200-1K/sec)
    ["Trulimero Trulicina"] = { Rarity = "Rare", IncomePerSec = 250 },
    ["Bobrito Bandito"] = { Rarity = "Rare", IncomePerSec = 300 },
    ["Gangster Footera"] = { Rarity = "Rare", IncomePerSec = 350 },
    ["Ta Ta Ta Ta Sahur"] = { Rarity = "Rare", IncomePerSec = 400 },
    ["Cacto Hipopotamo"] = { Rarity = "Rare", IncomePerSec = 450 },
    ["Boneca Ambalabu"] = { Rarity = "Rare", IncomePerSec = 500 },
    ["Trippi Troppi"] = { Rarity = "Rare", IncomePerSec = 550 },

    -- Epic ($1K-5K/sec)
    ["Brr Brr Patapim"] = { Rarity = "Epic", IncomePerSec = 1200 },
    ["Bambini Crostini"] = { Rarity = "Epic", IncomePerSec = 1500 },
    ["Brri Brri Bicus Dicus"] = { Rarity = "Epic", IncomePerSec = 1800 },
    ["Cappuccino Assassino"] = { Rarity = "Epic", IncomePerSec = 2000 },
    ["Bananita Dolphinita"] = { Rarity = "Epic", IncomePerSec = 2300 },
    ["Pandaccini Bananini"] = { Rarity = "Epic", IncomePerSec = 2500 },
    ["Chimpanzini Bananini"] = { Rarity = "Epic", IncomePerSec = 2800 },
    ["Blueberrinni Octopusini"] = { Rarity = "Epic", IncomePerSec = 3000 },
    ["Tung Sahur"] = { Rarity = "Epic", IncomePerSec = 3200 },
    ["Burbaloni Luliloli"] = { Rarity = "Epic", IncomePerSec = 3500 },
    ["Ballerino Lololo"] = { Rarity = "Epic", IncomePerSec = 3800 },

    -- Legendary ($5K-25K/sec)
    ["Chef Crabracadabra"] = { Rarity = "Legendary", IncomePerSec = 5500 },
    ["Pipi Potato"] = { Rarity = "Legendary", IncomePerSec = 6000 },
    ["Ballerina Cappuccina"] = { Rarity = "Legendary", IncomePerSec = 6500 },
    ["Glorbo Fruttodrillo"] = { Rarity = "Legendary", IncomePerSec = 7000 },
    ["Tralalita Tralala"] = { Rarity = "Legendary", IncomePerSec = 7500 },
    ["Gorillo Watermelondrillo"] = { Rarity = "Legendary", IncomePerSec = 8000 },
    ["Cocofanto Elefanto"] = { Rarity = "Legendary", IncomePerSec = 8500 },
    ["Matteo"] = { Rarity = "Legendary", IncomePerSec = 9000 },
    ["Job Job Job Sahur"] = { Rarity = "Legendary", IncomePerSec = 9500 },
    ["Zibra Zubra Zibralini"] = { Rarity = "Legendary", IncomePerSec = 10000 },
    ["Trippi Troppi Troppa Trippa"] = { Rarity = "Legendary", IncomePerSec = 11000 },
    ["Pakrahmatmamat"] = { Rarity = "Legendary", IncomePerSec = 12000 },
    ["Girafa Celeste"] = { Rarity = "Legendary", IncomePerSec = 13000 },
    ["Tigroligre Frutonni"] = { Rarity = "Legendary", IncomePerSec = 14000 },
    ["Orcalero Orcala"] = { Rarity = "Legendary", IncomePerSec = 15000 },
    ["Odin Din Din Dun"] = { Rarity = "Legendary", IncomePerSec = 16000 },
    ["Tralalero Tralala"] = { Rarity = "Legendary", IncomePerSec = 17000 },

    -- Mythical ($25K-100K/sec)
    ["Rhino Toasterino"] = { Rarity = "Mythical", IncomePerSec = 30000 },
    ["Avocadini Guffo"] = { Rarity = "Mythical", IncomePerSec = 35000 },
    ["Bombombini Gusini"] = { Rarity = "Mythical", IncomePerSec = 40000 },
    ["Frigo Camelo"] = { Rarity = "Mythical", IncomePerSec = 45000 },
    ["Orangutini Ananassini"] = { Rarity = "Mythical", IncomePerSec = 50000 },
    ["Cavallo Virtuoso"] = { Rarity = "Mythical", IncomePerSec = 55000 },
    ["Strawberrelli Flamingelli"] = { Rarity = "Mythical", IncomePerSec = 60000 },
    ["Bombardiro Crocodilo"] = { Rarity = "Mythical", IncomePerSec = 65000 },
    ["Lerulerulerule"] = { Rarity = "Mythical", IncomePerSec = 70000 },

    -- Secret ($100K+/sec)
    ["Pakrahmatmatina"] = { Rarity = "Secret", IncomePerSec = 110000 },
    ["Espresso Signora"] = { Rarity = "Secret", IncomePerSec = 120000 },
    ["Los Tralaleritos"] = { Rarity = "Secret", IncomePerSec = 130000 },
    ["Karkerkar Kurkur"] = { Rarity = "Secret", IncomePerSec = 140000 },
    ["Six Seven"] = { Rarity = "Secret", IncomePerSec = 150000 },
    ["Agarrini La Pallini"] = { Rarity = "Secret", IncomePerSec = 160000 },
    ["Dragon Cannelloni"] = { Rarity = "Secret", IncomePerSec = 170000 },
    ["Pot Hotspot"] = { Rarity = "Secret", IncomePerSec = 180000 },
    ["Chicleteira Bicicleteira"] = { Rarity = "Secret", IncomePerSec = 190000 },
    ["Esok Sekolah"] = { Rarity = "Secret", IncomePerSec = 200000 },
    ["Torrtuginni Dragonfrutini"] = { Rarity = "Secret", IncomePerSec = 210000 },
    ["La Vacca Saturno Saturnita"] = { Rarity = "Secret", IncomePerSec = 220000 },
    ["Strawberry Elephant"] = { Rarity = "Secret", IncomePerSec = 230000 },
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
