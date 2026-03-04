local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Food_Models = Assets:WaitForChild("Foods")

type Food = {
    Starting_Experience: number,
    Model: Model,
}

local Foods: { [string]: Food } = {
    ["Apple"] = {
        Starting_Experience = 0,
        Model = Food_Models:WaitForChild("Apple"),
    },
    ["Orange"] = {
        Starting_Experience = 50,
        Model = Food_Models:WaitForChild("Orange"),
    },
    ["Coconut"] = {
        Starting_Experience = 100,
        Model = Food_Models:WaitForChild("Coconut"),
    },
    ["Watermelon"] = {
        Starting_Experience = 150,
        Model = Food_Models:WaitForChild("Watermelon"),
    },
}

local GROWTH_PER_XP = 0.01
local LAST_TIER_MAX_XP = 200

local Food = {}

function Food.Get_Data_From_Xp(Xp: number): {
    Name: string,
    Model: Model,
    Scale: number,
    Tier_Start_Xp: number,
    Next_Tier_Xp: number?,
    Xp_To_Next: number,
    Is_Max: boolean,
}
    local Best_Food_Name: string? = nil
    local Highest_XP = -math.huge
    local Next_Tier_XP = math.huge

    for Name, Data in Foods do
        if Xp >= Data.Starting_Experience and Data.Starting_Experience > Highest_XP then
            Highest_XP = Data.Starting_Experience
            Best_Food_Name = Name
        end

        if Data.Starting_Experience > Xp and Data.Starting_Experience < Next_Tier_XP then
            Next_Tier_XP = Data.Starting_Experience
        end
    end

    local Is_Last_Tier = Next_Tier_XP == math.huge

    local Tier_Start_Xp = Highest_XP
    local Tier_End_Xp = Is_Last_Tier and LAST_TIER_MAX_XP or Next_Tier_XP

    local XpSinceTier = math.clamp(Xp - Tier_Start_Xp, 0, Tier_End_Xp - Tier_Start_Xp)
    local Scale = 1 + (XpSinceTier * GROWTH_PER_XP)

    local Is_Max = Is_Last_Tier and Xp >= LAST_TIER_MAX_XP
    local Xp_To_Next = math.max(Tier_End_Xp - Xp, 0)

    return {
        Name = Best_Food_Name :: string,
        Model = Foods[Best_Food_Name :: string].Model,
        Scale = Scale,
        Tier_Start_Xp = Tier_Start_Xp,
        Next_Tier_Xp = Tier_End_Xp,
        Xp_To_Next = Xp_To_Next,
        Is_Max = Is_Max,
    }
end

return table.freeze(Food)
