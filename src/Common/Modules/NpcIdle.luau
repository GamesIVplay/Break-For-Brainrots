--!strict
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local NpcIdleAnimator = {}
local active: { [Model]: any } = {}

local function stopForModel(model: Model)
    local data = active[model]
    if not data then
        return
    end
    if data.lrTween then
        data.lrTween:Cancel()
    end
    if data.glideTween then
        data.glideTween:Cancel()
    end
    if data.conn then
        data.conn:Disconnect()
    end
    if data.ancestryConn then
        data.ancestryConn:Disconnect()
    end
    if data.offsetValue then
        data.offsetValue:Destroy()
    end
    if data.verticalValue then
        data.verticalValue:Destroy()
    end
    if data.bounceValue then
        data.bounceValue:Destroy()
    end
    active[model] = nil
end

function NpcIdleAnimator.Start(model: Model, options: any?)
    if not model or not model:IsA("Model") then
        return
    end
    stopForModel(model)
    options = options or {}

    local distance = options.Distance or 1.5
    local duration = options.Duration or 2.5

    local bobHeight = options.BobHeight or 0.25
    local bobSpeed = options.BobSpeed or 1.2

    local glideHeight = options.GlideHeight or 1.2
    local glideSpeed = options.GlideSpeed or 4

    local wagSpeed = options.WagSpeed or 1.2
    local yawDegrees = options.YawAngleDegrees or 18
    local rollDegrees = options.RollAngleDegrees or 8

    local basePart = model.Parent
    local follow: BasePart? = nil
    if typeof(basePart) == "Instance" and basePart:IsA("BasePart") then
        follow = basePart
    end

    local baseCF0 = model:GetPivot()
    local localOffset: CFrame? = nil
    if follow then
        localOffset = follow.CFrame:ToObjectSpace(baseCF0)
    end

    local offsetValue = Instance.new("NumberValue")
    offsetValue.Value = 0

    local verticalValue = Instance.new("NumberValue")
    verticalValue.Value = 0

    local lrTween = TweenService:Create(
        offsetValue,
        TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true, 0),
        { Value = distance }
    )

    local glideTween = TweenService:Create(
        verticalValue,
        TweenInfo.new(glideSpeed, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true, 0),
        { Value = glideHeight }
    )

    local data = {
        lrTween = lrTween,
        glideTween = glideTween,
        offsetValue = offsetValue,
        verticalValue = verticalValue,
        bounceOffset = 0,
        bounceValue = nil,
        bouncing = false,
        follow = follow,
        localOffset = localOffset,
        baseCF0 = baseCF0,
    }
    active[model] = data

    data.conn = RunService.Heartbeat:Connect(function()
        if not model.Parent then
            stopForModel(model)
            return
        end

        local now = os.clock()

        local baseCF = data.baseCF0
        if data.follow and data.localOffset then
            baseCF = data.follow.CFrame * data.localOffset
        end

        local x = offsetValue.Value
        local glideY = verticalValue.Value
        local bobY = math.sin(now * bobSpeed) * bobHeight
        local bounceY = data.bounceOffset or 0

        local wag = now * wagSpeed
        local yaw = math.sin(wag) * math.rad(yawDegrees)
        local roll = math.sin(wag * 1.3) * math.rad(rollDegrees)

        local idleLocal = CFrame.new(x, glideY + bobY + bounceY, 0) * CFrame.Angles(0, yaw, roll)

        model:PivotTo(baseCF * idleLocal)
    end)

    data.ancestryConn = model.AncestryChanged:Connect(function(_, parent)
        if not parent then
            stopForModel(model)
        end
    end)

    lrTween:Play()
    glideTween:Play()
end

function NpcIdleAnimator.Bounce(model: Model, height: number?, timeUp: number?, timeDown: number?)
    local data = active[model]
    if not data then
        return
    end
    if data.bouncing then
        return
    end
    data.bouncing = true

    height = height or 2
    timeUp = timeUp or 0.15
    timeDown = timeDown or timeUp

    local bounceValue = Instance.new("NumberValue")
    bounceValue.Value = 0
    data.bounceValue = bounceValue

    local changedConn
    changedConn = bounceValue.Changed:Connect(function(v)
        if active[model] ~= data then
            if changedConn then
                changedConn:Disconnect()
            end
            return
        end
        data.bounceOffset = v
    end)

    local upTween = TweenService:Create(
        bounceValue,
        TweenInfo.new(timeUp, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { Value = height }
    )
    local downTween = TweenService:Create(
        bounceValue,
        TweenInfo.new(timeDown, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        { Value = 0 }
    )

    upTween.Completed:Connect(function()
        downTween:Play()
    end)

    downTween.Completed:Connect(function()
        data.bouncing = false
        data.bounceOffset = 0
        if changedConn then
            changedConn:Disconnect()
        end
        if data.bounceValue == bounceValue then
            data.bounceValue = nil
        end
        bounceValue:Destroy()
    end)

    upTween:Play()
end

function NpcIdleAnimator.Stop(model: Model)
    if not model then
        return
    end
    stopForModel(model)
end

return NpcIdleAnimator
