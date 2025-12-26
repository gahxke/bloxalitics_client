--[[
    Bloxalitics is licensed under the GNU General Public License v3.0 or later.
    This software is provided without warranty. The software author or license can 
    not be held liable for any damages inflicted by the software.
]]--
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local LocalizationService = game:GetService("LocalizationService")
local ExecutorName, ExecutorVersion = identifyexecutor()
local LocalPlayer = game:GetService("Players").LocalPlayer

type BloxaliticsSettingsType = {
    EnableTelemetry: boolean,
    APIUri: string,
    TrackingEndpoint: string,
}

getgenv().Bloxalitics = getgenv().Bloxalitics or {
    EnableTelemetry = true,
    APIUri = "http://127.0.0.1:8000",
    TrackingEndpoint = "/track",
} :: BloxaliticsSettingsType

getgenv().BloxaliticsVersion = "0.0.1-rc1"

local BloxaliticsSettings = getgenv().Bloxalitics

local function GetPlatformName(): string
    local Success, PlatformEnum = pcall(UserInputService.GetPlatform, UserInputService)

    if Success then
        if PlatformEnum == Enum.Platform.Android
           or PlatformEnum == Enum.Platform.AndroidTV
           or PlatformEnum == Enum.Platform.Chromecast then
            return "Android"
        elseif PlatformEnum == Enum.Platform.Windows then
            return "Windows"
        elseif PlatformEnum == Enum.Platform.OSX then
            return "macOS"
        elseif PlatformEnum == Enum.Platform.SteamOS then   --
            return "SteamOS"                                --     Despite them being the same platform, it's better if we
        elseif PlatformEnum == Enum.Platform.Linux then     --     emphasize it's SteamOS instead of generic Linux.
            return "Linux"                                  --
        elseif PlatformEnum == Enum.Platform.UWP then
            return "UWP"
        elseif PlatformEnum == Enum.Platform.MetaOS then
            return "Meta Quest"
        elseif PlatformEnum == Enum.Platform.PS3
           or PlatformEnum == Enum.Platform.PS4
           or PlatformEnum == Enum.Platform.PS5 then
            return "Playstation"
        elseif PlatformEnum == Enum.Platform.XBox360
           or PlatformEnum == Enum.Platform.XBoxOne then
            return "XBox"
        elseif PlatformEnum == Enum.Platform.None then
            return "Unknown"
        end
    else
        warn(":GetPlatform() not working. Current identity level is: " .. tostring(getthreadidentity()) .. ", might be why?")
    end
    return "Unknown"
end

local function GetCountryCode(): string
    local Success, CountryCode = pcall(function()
        LocalizationService:GetCountryRegionForPlayerAsync(LocalPlayer)
    end)

    if Success then
        return CountryCode
    else
        warn(":GetCountryRegionForPlayerAsync() didn't work, returning Unknown")
    end
    return "Unknown"
end

while not BloxaliticsSettings.EnableTelemetry do
    warn("User has not opted-in for telemetry! Looping...")
    task.wait(300)
end

local Payload = {
    executor = ExecutorName,
    platform = GetPlatformName(),
    libraryVersion = BloxaliticsSettings.BloxaliticsVersion,
    country = GetCountryCode(),
}

local TelemetryData = {
    Url = BloxaliticsSettings.APIUri .. BloxaliticsSettings.TrackingEndpoint,
    Method = "POST",
    Headers = {
        ["Content-Type"] = "application/json"
    },
    Body = HttpService:JSONEncode(Payload)
}

if ExecutorName == "Hydrogen" then
    warn("Current executor is Hydrogen, applying request fix.")
    getgenv().request = http_request
    http.request = http_request
end

local req = request(TelemetryData)

if req.StatusCode == 429 or req.StatusCode == 400 or not req.Success then
    warn(req.Body)
end

if req.Success then
    print("Sent data to " .. BloxaliticsSettings.APIUri .. "!")
end