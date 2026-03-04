local Jecs = require(game:GetService("ReplicatedStorage").Packages.Jecs)

export type World = typeof(Jecs.world())
export type Entity<T = nil> = Jecs.Entity<T>
export type Id<T = nil> = Jecs.Id<T>

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
export type NotificationType = "Success" | "Info" | "Warning" | "Error" | "Reward"

export type Brainrot_Item = {
    Level: number,
    Experience: number,
    Name: string,
    Primary_Mutation: string?,
    Secondary_Mutations: { string },
    Weight: number,
    Cash: number,
    Offline_Cash: number,
}

export type Serialized_Brainrot = {
    Level: number?,
    Experience: number?,
    Name: string,
    Primary_Mutation: string?,
    Secondary_Mutations: { string },
    Weight: number,
    Cash: number,
    Offline_Cash: number,
}

export type Food_Item = {
    Xp: number,
}

return {}
