--[[
    Bloxalitics is licensed under the GNU General Public License v3.0 or later.
    This software is provided without warranty. The software author or license can 
    not be held liable for any damages inflicted by the software.
]]--

getgenv().Bloxalitics = {
    Version = "1.0.0",
    EnableTelemetry = false,
    APIUri = "http://127.0.0.1:8000",
    TrackEndpoint = "/track",
    RememberOption = false,
    RememberNow = true,

    UserDisagreed = false,
}

-- Cache
local game = game
local getrawmetatable, getmetatable, setmetatable, pcall, getgenv, getthreadidentity = getrawmetatable, getmetatable, setmetatable, pcall, getgenv, getthreadidentity
local tostring, warn, error = tostring, warn, error
local httpRequest = request or http_request or (http and http.request)
local readfile, writefile, isfile, isfolder = readfile, writefile, isfile, isfolder
local identifyexecutor = identifyexecutor

local GameMetatable = getrawmetatable and getrawmetatable(game) or {
	__index = function(self, Index)
		return self[Index]
	end,

	__newindex = function(self, Index, Value)
		self[Index] = Value
	end
}

local __index = GameMetatable.__index
local __newindex = GameMetatable.__newindex

local GetService = __index(game, "GetService")

-- Services
local HttpService = GetService(game, "HttpService")
local UserInputService = GetService(game, "UserInputService")
local LocalizationService = GetService(game, "LocalizationService")
local Players = GetService(game, "Players")

-- Methods
local LocalPlayer = __index(Players, "LocalPlayer")
local GetPlatform = __index(UserInputService, "GetPlatform")
local GetCountryRegionForPlayerAsync = __index(LocalizationService, "GetCountryRegionForPlayerAsync")
local JSONEncode = __index(HttpService, "JSONEncode")

function Bloxalitics.GetPlatformName(): string
    local Success, PlatformEnum = pcall(GetPlatform, UserInputService)
    local PlatformOverrides = {
        ["AndroidTV"]  = "Android",
        ["Chromecast"] = "Android",
        ["OSX"]        = "macOS",
        ["MetaOS"]     = "Meta Quest",
        ["PS3"]        = "Playstation",
        ["PS4"]        = "Playstation",
        ["PS5"]        = "Playstation",
        ["XBox360"]    = "XBox",
        ["XBoxOne"]    = "XBox",
        ["None"]       = "Unknown",
    }
    if Success then
        local PlatformName = PlatformEnum.Name
        return PlatformOverrides[PlatformName] or PlatformName
    else
        local identity = getthreadidentity and getthreadidentity() or "unknown"
        warn(":GetPlatform() not working. Current identity level is: " .. tostring(identity) .. ", might be why?")
    end
    return "Unknown"
end

function Bloxalitics.GetCountryCode(): string
    local Success, CountryCode = pcall(GetCountryRegionForPlayerAsync, LocalizationService, LocalPlayer)

    if Success and CountryCode then
        return CountryCode
    else
        local identity = getthreadidentity and getthreadidentity() or "unknown"
        warn(":GetCountryRegionForPlayerAsync() didn't work. Identity: " .. tostring(identity) .. ", returning unknown.")
    end

    return "Unknown"
end

local TelemetryData, RequestData
local TelemetryRunning = true

local Load = function()
    if identifyexecutor and identifyexecutor() == "Hydrogen" then
        getgenv().request = http_request
        http.request = http_request
    end
    -- Prepare data to send
    TelemetryData = {
        executor = identifyexecutor and identifyexecutor() or "Unknown",
        platform = Bloxalitics.GetPlatformName(),
        libraryVersion = Bloxalitics.Version,
        country = Bloxalitics.GetCountryCode(),
    }
    if Bloxalitics.RememberNow and isfile(".Bloxalitics") then
        Bloxalitics.EnableTelemetry = true
    end
    local Success, EncodedTelemetryData = pcall(JSONEncode, HttpService, TelemetryData)
    if not Success then error("Failed to encode telemetry payload! Bailing...") end
    RequestData = {
        Url = Bloxalitics.APIUri,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = EncodedTelemetryData
    }
    task.spawn(function()
        while TelemetryRunning do
            if Bloxalitics.EnableTelemetry and not Bloxalitics.UserDisagreed then
                local Request = httpRequest(RequestData)
                if Request and Request.Success then
                    TelemetryRunning = false
                    break
                elseif Request then
                    warn(Request.Body)
                end
            end
            task.wait(10)
        end
    end)
end

local function StopTelemetryLoop()
    TelemetryRunning = false
end

function Bloxalitics.Close() 
    StopTelemetryLoop()
end

function Bloxalitics.Consent(v) 
    if v then
        print("User agreed to telemetry.")
        Bloxalitics.UserDisagreed = false
        Bloxalitics.EnableTelemetry = true
        if Bloxalitics.RememberOption then writefile(".Bloxalitics", "") end
    else
        warn("User disagreed to telemetry...")
        Bloxalitics.UserDisagreed = true
        StopTelemetryLoop()
    end
end

setmetatable(Bloxalitics, {__call = Load})
return Bloxalitics