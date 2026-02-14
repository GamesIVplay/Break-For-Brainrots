if not game:IsLoaded() then
    game.Loaded:Wait()
end

local CollectionService = game:GetService("CollectionService")

local function RainbowColor(Hue: number): Color3
    return Color3.fromHSV(Hue % 1, 1, 1)
end

local function GetTargetParts(Inst: Instance): { BasePart }
    if Inst:IsA("BasePart") then
        return { Inst }
    elseif Inst:IsA("Model") then
        return Inst:GetDescendants()
    end
    return {}
end

local function StartRainbow(Inst: Instance)
    if not CollectionService:HasTag(Inst, "Rainbow") then
        return
    end

    local Parts: { BasePart } = {}

    for _, Obj in ipairs(GetTargetParts(Inst)) do
        if Obj:IsA("BasePart") then
            table.insert(Parts, Obj)
        end
    end

    if #Parts == 0 then
        return
    end

    task.spawn(function()
        local Hue = 0
        while Inst.Parent do
            if Inst:IsDescendantOf(workspace) then
                local Color = RainbowColor(Hue)
                for _, Part in ipairs(Parts) do
                    if Part.Parent then
                        Part.Color = Color
                    end
                end
                Hue += 0.002
            end
            task.wait(0.01)
        end
    end)
end

for _, Inst in workspace:GetDescendants() do
    StartRainbow(Inst)
end

workspace.DescendantAdded:Connect(StartRainbow)
CollectionService:GetInstanceAddedSignal("Rainbow"):Connect(StartRainbow)
