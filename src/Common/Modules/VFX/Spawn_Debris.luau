local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local Debris_Folder = workspace:FindFirstChild("Debris")

return function(Position: Vector3, Color: Color3, Count: number, Use_Rainbow_Colors: boolean?)
    for _ = 1, Count do
        local Particle = Instance.new("Part")
        Particle.Size = Vector3.new(0.001, 0.001, 0.001)
        Particle.Color = Color
        Particle.Material = Enum.Material.Plastic
        Particle.Anchored = false
        Particle.CollisionGroup = "Debris"
        Particle.Position = Position + Vector3.new(0, 1, 0)
        Particle.Parent = Debris_Folder

        if Use_Rainbow_Colors then
            Particle:AddTag("Rainbow")
        end

        Particle.TopSurface = Enum.SurfaceType.Studs
        Particle.BottomSurface = Enum.SurfaceType.Studs
        Particle.LeftSurface = Enum.SurfaceType.Studs
        Particle.RightSurface = Enum.SurfaceType.Studs
        Particle.FrontSurface = Enum.SurfaceType.Studs
        Particle.BackSurface = Enum.SurfaceType.Studs

        TweenService:Create(Particle, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = Vector3.new(1, 1, 1),
        }):Play()

        Particle.AssemblyLinearVelocity = Vector3.new(math.random() - 0.5, math.random() + 0.5, math.random() - 0.5).Unit
            * math.random(25, 45)

        Particle.AssemblyAngularVelocity = Vector3.new(math.random(-15, 15), math.random(15, 25), math.random(-15, 15))

        task.delay(1.5, function()
            if Particle and Particle.Parent then
                TweenService:Create(Particle, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                    Size = Vector3.new(0, 0, 0),
                }):Play()
            end
        end)

        Debris:AddItem(Particle, 4)
    end
end
