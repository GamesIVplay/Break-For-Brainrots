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
    -- Common
    ["Fluri Flura"] = { Rarity = "Common", IncomePerSec = 1 },
    ["Pipi Kiwi"] = { Rarity = "Common", IncomePerSec = 1 },
    ["Garamararam"] = { Rarity = "Common", IncomePerSec = 1 },
    ["Tim Cheese"] = { Rarity = "Common", IncomePerSec = 1 },
    ["Svinina Bombardino"] = { Rarity = "Common", IncomePerSec = 1 },
    ["Madudung"] = { Rarity = "Common", IncomePerSec = 1 },
    ["Talpa Di Fero"] = { Rarity = "Common", IncomePerSec = 1 },
    ["Lirili Larila"] = { Rarity = "Common", IncomePerSec = 1 },

    -- Rare
    ["Trulimero Trulicina"] = { Rarity = "Rare", IncomePerSec = 5 },
    ["Bobrito Bandito"] = { Rarity = "Rare", IncomePerSec = 5 },
    ["Gangster Footera"] = { Rarity = "Rare", IncomePerSec = 5 },
    ["Ta Ta Ta Ta Sahur"] = { Rarity = "Rare", IncomePerSec = 5 },
    ["Cacto Hipopotamo"] = { Rarity = "Rare", IncomePerSec = 5 },
    ["Boneca Ambalabu"] = { Rarity = "Rare", IncomePerSec = 5 },
    ["Trippi Troppi"] = { Rarity = "Rare", IncomePerSec = 5 },

    -- Epic
    ["Brr Brr Patapim"] = { Rarity = "Epic", IncomePerSec = 25 },
    ["Bambini Crostini"] = { Rarity = "Epic", IncomePerSec = 25 },
    ["Brri Brri Bicus Dicus"] = { Rarity = "Epic", IncomePerSec = 25 },
    ["Cappuccino Assassino"] = { Rarity = "Epic", IncomePerSec = 25 },
    ["Bananita Dolphinita"] = { Rarity = "Epic", IncomePerSec = 25 },
    ["Pandaccini Bananini"] = { Rarity = "Epic", IncomePerSec = 25 },
    ["Chimpanzini Bananini"] = { Rarity = "Epic", IncomePerSec = 25 },
    ["Blueberrinni Octopusini"] = { Rarity = "Epic", IncomePerSec = 25 },
    ["Tung Sahur"] = { Rarity = "Epic", IncomePerSec = 25 },
    ["Burbaloni Luliloli"] = { Rarity = "Epic", IncomePerSec = 25 },
    ["Ballerino Lololo"] = { Rarity = "Epic", IncomePerSec = 25 },

    -- Legendary
    ["Chef Crabracadabra"] = { Rarity = "Legendary", IncomePerSec = 100 },
    ["Pipi Potato"] = { Rarity = "Legendary", IncomePerSec = 100 },
    ["Ballerina Cappuccina"] = { Rarity = "Legendary", IncomePerSec = 100 },
    ["Glorbo Fruttodrillo"] = { Rarity = "Legendary", IncomePerSec = 100 },
    ["Tralalita Tralala"] = { Rarity = "Legendary", IncomePerSec = 100 },
    ["Gorillo Watermelondrillo"] = { Rarity = "Legendary", IncomePerSec = 100 },
    ["Cocofanto Elefanto"] = { Rarity = "Legendary", IncomePerSec = 100 },
    ["Matteo"] = { Rarity = "Legendary", IncomePerSec = 100 },
    ["Job Job Job Sahur"] = { Rarity = "Legendary", IncomePerSec = 100 },
    ["Zibra Zubra Zibralini"] = { Rarity = "Legendary", IncomePerSec = 100 },
    ["Trippi Troppi Troppa Trippa"] = { Rarity = "Legendary", IncomePerSec = 100 },
    ["Pakrahmatmamat"] = { Rarity = "Legendary", IncomePerSec = 100 },
    ["Girafa Celeste"] = { Rarity = "Legendary", IncomePerSec = 100 },
    ["Tigroligre Frutonni"] = { Rarity = "Legendary", IncomePerSec = 100 },
    ["Orcalero Orcala"] = { Rarity = "Legendary", IncomePerSec = 100 },
    ["Odin Din Din Dun"] = { Rarity = "Legendary", IncomePerSec = 100 },
    ["Tralalero Tralala"] = { Rarity = "Legendary", IncomePerSec = 100 },

    -- Mythical
    ["Rhino Toasterino"] = { Rarity = "Mythical", IncomePerSec = 500 },
    ["Avocadini Guffo"] = { Rarity = "Mythical", IncomePerSec = 500 },
    ["Bombombini Gusini"] = { Rarity = "Mythical", IncomePerSec = 500 },
    ["Frigo Camelo"] = { Rarity = "Mythical", IncomePerSec = 500 },
    ["Orangutini Ananassini"] = { Rarity = "Mythical", IncomePerSec = 500 },
    ["Cavallo Virtuoso"] = { Rarity = "Mythical", IncomePerSec = 500 },
    ["Strawberrelli Flamingelli"] = { Rarity = "Mythical", IncomePerSec = 500 },
    ["Bombardiro Crocodilo"] = { Rarity = "Mythical", IncomePerSec = 500 },
    ["Lerulerulerule"] = { Rarity = "Mythical", IncomePerSec = 500 },

    -- Secret
    ["Pakrahmatmatina"] = { Rarity = "Secret", IncomePerSec = 2500 },
    ["Espresso Signora"] = { Rarity = "Secret", IncomePerSec = 2500 },
    ["Los Tralaleritos"] = { Rarity = "Secret", IncomePerSec = 2500 },
    ["Karkerkar Kurkur"] = { Rarity = "Secret", IncomePerSec = 2500 },
    ["Six Seven"] = { Rarity = "Secret", IncomePerSec = 2500 },
    ["Agarrini La Pallini"] = { Rarity = "Secret", IncomePerSec = 2500 },
    ["Dragon Cannelloni"] = { Rarity = "Secret", IncomePerSec = 2500 },
    ["Pot Hotspot"] = { Rarity = "Secret", IncomePerSec = 2500 },
    ["Chicleteira Bicicleteira"] = { Rarity = "Secret", IncomePerSec = 2500 },
    ["Esok Sekolah"] = { Rarity = "Secret", IncomePerSec = 2500 },
    ["Torrtuginni Dragonfrutini"] = { Rarity = "Secret", IncomePerSec = 2500 },
    ["La Vacca Saturno Saturnita"] = { Rarity = "Secret", IncomePerSec = 2500 },
    ["Strawberry Elephant"] = { Rarity = "Secret", IncomePerSec = 2500 },
}

local function Verify_Integrity()
    for Brainrot_Name in Brainrots do
        for Primary_Mutation_Name in Primary_Mutations do
            local MutationFolder = Brainrot_Models:FindFirstChild(Primary_Mutation_Name)
            if not MutationFolder then
                error(("[Brainrots Integrity] Missing Primary Mutation folder: '%s'"):format(Primary_Mutation_Name))
            end

            if not MutationFolder:FindFirstChild(Brainrot_Name) then
                error(
                    ("[Brainrots Integrity] Missing Brainrot model '%s' in Primary Mutation '%s'"):format(
                        Brainrot_Name,
                        Primary_Mutation_Name
                    )
                )
            end

            local NormalFolder = Brainrot_Models:FindFirstChild("Normal")
            if not NormalFolder then
                error("[Brainrots Integrity] Missing Normal folder")
            end

            if not NormalFolder:FindFirstChild(Brainrot_Name) then
                error(("[Brainrots Integrity] Missing Brainrot model '%s' in Normal folder"):format(Brainrot_Name))
            end
        end
    end
end

Verify_Integrity()

return table.freeze(Brainrots)
