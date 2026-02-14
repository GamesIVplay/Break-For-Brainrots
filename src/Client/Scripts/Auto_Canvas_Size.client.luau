local CollectionService = game:GetService("CollectionService")

local UIListLayoutScrolling = {}

function UIListLayoutScrolling._init()
    local function setupScrollingFrame(scrollingFrame)
        if not scrollingFrame:IsA("ScrollingFrame") then
            return
        end

        local layout = scrollingFrame:FindFirstChildWhichIsA("UIListLayout")
            or scrollingFrame:FindFirstChildWhichIsA("UIGridLayout")
        if not layout then
            return
        end

        local function updateCanvas()
            scrollingFrame.CanvasSize =
                UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y * (scrollingFrame:GetAttribute("Scale") or 1.015))
        end
        -- Update on resize
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
        -- Initial update
        updateCanvas()
    end
    -- Apply to already-tagged UI
    for _, inst in CollectionService:GetTagged("UIListLayoutScrolling") do
        setupScrollingFrame(inst)
    end
    -- Apply to future tagged items
    CollectionService:GetInstanceAddedSignal("UIListLayoutScrolling"):Connect(setupScrollingFrame)
end

UIListLayoutScrolling._init()

return UIListLayoutScrolling
