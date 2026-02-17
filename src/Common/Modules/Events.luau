local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Lightings = Assets:WaitForChild("Lightings")
local Event_VFX = Assets:WaitForChild("VFX"):WaitForChild("Events")
local Music = Assets:WaitForChild("Sounds"):WaitForChild("Music")

type Event = {
    Priority: number,
    Duration: number,
    Image: string,
    Lighting: Configuration,
    VFX: Part,
    Music: { Sound },
}

local Events: { [string]: Event } = {
    ["YinYang"] = {
        Priority = 5,
        Duration = 60 * 5,
        Image = "rbxassetid://135371654931726",
        Lighting = Lightings:WaitForChild("YinYang"),
        VFX = Event_VFX:WaitForChild("YinYang"),
        Music = Music:WaitForChild("YinYang"):GetChildren(),
    },
    ["Hacker"] = {
        Priority = 4,
        Duration = 60 * 5,
        Image = "rbxassetid://140099576560562",
        Lighting = Lightings:WaitForChild("Hacker"),
        VFX = Event_VFX:WaitForChild("Hacker"),
        Music = Music:WaitForChild("Hacker"):GetChildren(),
    },
    ["Volcanic"] = {
        Priority = 3,
        Duration = 60 * 5,
        Image = "rbxassetid://112422836214373",
        Lighting = Lightings:WaitForChild("Volcanic"),
        VFX = Event_VFX:WaitForChild("Volcanic"),
        Music = Music:WaitForChild("Volcanic"):GetChildren(),
    },
    ["Candy"] = {
        Priority = 2,
        Duration = 60 * 5,
        Image = "rbxassetid://127536426524827",
        Lighting = Lightings:WaitForChild("Candy"),
        VFX = Event_VFX:WaitForChild("Candy"),
        Music = Music:WaitForChild("Candy"):GetChildren(),
    },
    ["Toxic"] = {
        Priority = 1,
        Duration = 60 * 5,
        Image = "rbxassetid://73251144399969",
        Lighting = Lightings:WaitForChild("Toxic"),
        VFX = Event_VFX:WaitForChild("Toxic"),
        Music = Music:WaitForChild("Toxic"):GetChildren(),
    },
}

return table.freeze(Events)
