local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Packages = ReplicatedStorage.Packages
local Fusion = require(Packages.Fusion)

type Fusion = Fusion.Fusion
type Scope<T> = Fusion.Scope<T>

return function(Scope: Scope<Fusion>)
    local LastInputType = Scope:Value(UserInputService:GetLastInputType())

    table.insert(
        Scope,
        UserInputService.LastInputTypeChanged:Connect(function()
            LastInputType:set(UserInputService:GetLastInputType())
        end)
    )

    return Scope:Computed(function(use)
        local Last: Enum.UserInputType = use(LastInputType)
        return if (
                GuiService:IsTenFootInterface()
                or (UserInputService.GamepadEnabled and Last.Name:sub(1, 7) == "Gamepad")
            )
            then "Console"
            elseif
                UserInputService.TouchEnabled
                and not UserInputService.KeyboardEnabled
                and (
                    Last == Enum.UserInputType.Touch
                    or Last == Enum.UserInputType.Gyro
                    or Last == Enum.UserInputType.Accelerometer
                )
            then "Mobile"
            elseif
                UserInputService.KeyboardEnabled
                and (Last == Enum.UserInputType.Keyboard or Last.Name:sub(1, 5) == "Mouse")
            then "Desktop"
            else "Unknown" :: any
    end)
end
