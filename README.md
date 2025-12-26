# Bloxalitics Client
The client for Bloxalitics.

### Prerequisites
- `request()` or `http.request()`
> [!WARNING] 
> `http.request()` must send a `PREFIX-Fingerprint` header as per [UNC standards](https://github.com/unified-naming-convention/NamingStandard/blob/main/api/misc.md#request)!

- Thread identity ≥ 7 (for [`:GetPlatform()`](https://devforum.roblox.com/t/allow-us-to-use-getplatform/2840962))

### Getting started
Running the client is as easy with a loadstring with your configuration.

Example:
```lua
getgenv().Bloxalitics = {
	EnableTelemetry = true, -- Make sure the user has control over their data! Add a GUI 
    						-- asking if they consent for telemetry.
	APIUri = "https://example.com:8000"
}
loadstring(game:HttpGet("https://raw.githubusercontent.com/gahxke/bloxalitics_client/refs/heads/main/src/main.client.luau"))()
```