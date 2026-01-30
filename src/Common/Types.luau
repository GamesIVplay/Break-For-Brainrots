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

export type Rarity = "Common" | "Uncommon" | "Rare" | "Legendary" | "Mythical"

export type Difficulty = "Easy" | "Normal" | "Hard" | "Insane"

export type NotificationType = "Success" | "Info" | "Warning" | "Error" | "Reward"

return {}
