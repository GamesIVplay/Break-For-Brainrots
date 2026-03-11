local Jecs = require(game:GetService("ReplicatedStorage").Packages.Jecs)

export type World = typeof(Jecs.world())
export type Entity = Jecs.Entity
export type Id<T> = Jecs.Id<T>

export type AnimationInfo = {
    Name: string,
    Weight: number?,
    Priority: Enum.AnimationPriority?,
    Loop: boolean?,
    Speed: number?,
    Fadetime: number?,
    Stack: boolean?,
}

export type Rarity = "Common" | "Rare" | "Epic" | "Legendary" | "Mythical" | "Secret" | "Limited"
export type NotificationType = "Success" | "Info" | "Warning" | "Error" | "Reward" | "Announcement"

export type Brainrot_Item = {
    Name: string,
    Primary_Mutation: string?,
    Secondary_Mutations: { string },
    Weight: number,
    Cash: number,
    Offline_Cash: number,
}

export type Serialized_Brainrot = {
    Name: string,
    Primary_Mutation: string?,
    Secondary_Mutations: { string },
    Weight: number,
    Cash: number,
    Offline_Cash: number,
}

export type Start_Global_Event_Data = {
    Executor: string,
    Name: string,
    Duration: number,
    Luck_Bonus: number,
}

export type Stop_Global_Event_Data = {
    Name: string,
}

return {}
