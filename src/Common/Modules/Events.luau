local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Lightings = Assets:WaitForChild("Lightings")
local Event_VFX = Assets:WaitForChild("VFX"):WaitForChild("Events")
local Music = Assets:WaitForChild("Sounds"):WaitForChild("Music")

type Event = {
    Duration: number,
    Image: string,
    Lighting: Configuration,
    VFX: Part,
    Music: { Sound },
    Grass_Color: Color3?,
    Water_Color: Color3?,
}

local Events: { [string]: Event } = {
    ["YinYang"] = {
        Duration = 60 * 5,
        Image = "rbxassetid://135371654931726",
        Lighting = Lightings:WaitForChild("YinYang"),
        VFX = Event_VFX:WaitForChild("YinYang"),
        Music = Music:WaitForChild("YinYang"):GetChildren(),
        Grass_Color = Color3.fromRGB(153, 153, 153),
        Water_Color = Color3.fromRGB(212, 212, 212),
    },
    ["Hacker"] = {
        Duration = 60 * 5,
        Image = "rbxassetid://140099576560562",
        Lighting = Lightings:WaitForChild("Hacker"),
        VFX = Event_VFX:WaitForChild("Hacker"),
        Music = Music:WaitForChild("Hacker"):GetChildren(),
        Grass_Color = Color3.fromRGB(66, 66, 66),
        Water_Color = Color3.fromRGB(29, 29, 29),
    },
    ["Volcanic"] = {
        Duration = 60 * 5,
        Image = "rbxassetid://112422836214373",
        Lighting = Lightings:WaitForChild("Volcanic"),
        VFX = Event_VFX:WaitForChild("Volcanic"),
        Music = Music:WaitForChild("Volcanic"):GetChildren(),
        Grass_Color = Color3.fromRGB(79, 55, 38),
        Water_Color = Color3.fromRGB(212, 174, 58),
    },
    ["Candy"] = {
        Duration = 60 * 5,
        Image = "rbxassetid://127536426524827",
        Lighting = Lightings:WaitForChild("Candy"),
        VFX = Event_VFX:WaitForChild("Candy"),
        Music = Music:WaitForChild("Candy"):GetChildren(),
        Grass_Color = Color3.fromRGB(162, 116, 170),
        Water_Color = Color3.fromRGB(212, 150, 171),
    },
    ["Toxic"] = {
        Duration = 60 * 5,
        Image = "rbxassetid://73251144399969",
        Lighting = Lightings:WaitForChild("Toxic"),
        VFX = Event_VFX:WaitForChild("Toxic"),
        Music = Music:WaitForChild("Toxic"):GetChildren(),
        Grass_Color = Color3.fromRGB(153, 170, 76),
        Water_Color = Color3.fromRGB(159, 212, 73),
    },
}

return table.freeze(Events)
