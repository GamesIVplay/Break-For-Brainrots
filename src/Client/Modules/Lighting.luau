local LightingService = game:GetService("Lighting")

local Lighting = {}

function Lighting.Save(Name: string)
    local Config = Instance.new("Configuration")
    Config.Name = Name

    Config:SetAttribute("Ambient", LightingService.Ambient)
    Config:SetAttribute("Brightness", LightingService.Brightness)
    Config:SetAttribute("ColorShift_Bottom", LightingService.ColorShift_Bottom)
    Config:SetAttribute("ColorShift_Top", LightingService.ColorShift_Top)
    Config:SetAttribute("EnvironmentDiffuseScale", LightingService.EnvironmentDiffuseScale)
    Config:SetAttribute("EnvironmentSpecularScale", LightingService.EnvironmentSpecularScale)
    Config:SetAttribute("GlobalShadows", LightingService.GlobalShadows)
    Config:SetAttribute("OutdoorAmbient", LightingService.OutdoorAmbient)
    Config:SetAttribute("ShadowSoftness", LightingService.ShadowSoftness)
    Config:SetAttribute("ClockTime", LightingService.ClockTime)
    Config:SetAttribute("GeographicLatitude", LightingService.GeographicLatitude)
    Config:SetAttribute("ExposureCompensation", LightingService.ExposureCompensation)

    return Config
end

function Lighting.Load(Config: Configuration)
    for _, Inst in LightingService:GetChildren() do
        Inst:Destroy()
    end

    for _, Inst in Config:GetChildren() do
        local Clone = Inst:Clone()
        Clone.Parent = LightingService
    end

    LightingService.Ambient = Config:GetAttribute("Ambient")
    LightingService.Brightness = Config:GetAttribute("Brightness")
    LightingService.ColorShift_Bottom = Config:GetAttribute("ColorShift_Bottom")
    LightingService.ColorShift_Top = Config:GetAttribute("ColorShift_Top")
    LightingService.EnvironmentDiffuseScale = Config:GetAttribute("EnvironmentDiffuseScale")
    LightingService.EnvironmentSpecularScale = Config:GetAttribute("EnvironmentSpecularScale")
    LightingService.GlobalShadows = Config:GetAttribute("GlobalShadows")
    LightingService.OutdoorAmbient = Config:GetAttribute("OutdoorAmbient")
    LightingService.ShadowSoftness = Config:GetAttribute("ShadowSoftness")
    LightingService.ClockTime = Config:GetAttribute("ClockTime")
    LightingService.GeographicLatitude = Config:GetAttribute("GeographicLatitude")
    LightingService.ExposureCompensation = Config:GetAttribute("ExposureCompensation")
end

return Lighting
