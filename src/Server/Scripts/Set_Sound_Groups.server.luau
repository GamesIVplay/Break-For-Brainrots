local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage:WaitForChild("Assets") :: Folder

local Sounds = Assets:WaitForChild("Sounds") :: Folder

for _, Inst in Sounds:GetChildren() do
    if not Inst:IsA("SoundGroup") then
        continue
    end

    for _, Descendant in Inst:GetDescendants() do
        if not Descendant:IsA("Sound") then
            continue
        end

        Descendant.SoundGroup = Inst
    end
end
