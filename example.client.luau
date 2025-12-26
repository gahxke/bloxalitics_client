getgenv().Bloxalitics = {
    APIUri = "http://127.0.0.1:8000",
    TrackEndpoint = "/track",
}
loadstring(game:HttpGet("https://github.com/gahxke/bloxalitics_client/raw/refs/heads/gahxke/client-rewrite/src/main.luau"))()

Bloxalitics()
local rbxmSuite = loadstring(game:HttpGetAsync(
    "https://github.com/richie0866/rbxm-suite/releases/latest/download/rbxm-suite.lua"
))()

local ReGui_Path = rbxmSuite.download("depthso/Dear-ReGui@1.3.7", "ReGui.rbxm")
local ReGui_Model = rbxmSuite.launch(ReGui_Path)
local ReGui = rbxmSuite.require(ReGui_Model)

ReGui:Init()

local Window = ReGui:Window({
    Title = "Telemetry",
    Size = UDim2.fromOffset(300, 100),
    NoCollapse = true,
    NoResize = true,
    NoClose = true,
})

Window:Button({
    Text = "Agree",
    Callback = function()
        Bloxalitics.Consent(true)
    end
})

Window:Button({
    Text = "Disagree",
    Callback = function()
        Bloxalitics.Consent(false)
    end
})

Window:Radiobox({
    Value = Bloxalitics.RememberOption,
    Label = "Remember my option",
    Callback = function(_, v)
        Bloxalitics.RememberOption = v
    end
})

if isfile(".Bloxalitics") and Bloxalitics.RememberNow then
    Window:Close()
end
