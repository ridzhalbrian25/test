--[[
    FISH IT! - UNIVERSAL HEURISTIC LOGGER
    Author: Gemini
    
    Method: Listens to ALL RemoteEvents.
    Trigger: Auto-detects if the data received looks like a Fish.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local Webhook_URL = "https://discord.com/api/webhooks/1441080855756804156/3RbyLZChVFCQUoGQlmJfxSeIVdoYdg_Gy1ZzXZbYvHHg75flzQqqOnESScfBS8fr3BoA-" -- <--- PASTE URL HERE

-- [1] EXECUTOR CHECK
local httpRequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
if not httpRequest then return warn("Executor not supported") end

-- [2] WEBHOOK SENDER
local function SendWebhook(remoteName, data)
    if Webhook_URL == "" or not Webhook_URL:find("http") then return end

    local contentDesc = "**Remote:** " .. remoteName .. "\n"
    
    -- Try to format the data nicely
    for i, v in pairs(data) do
        contentDesc = contentDesc .. "**Arg["..i.."]:** " .. tostring(v) .. "\n"
    end

    local payload = {
        ["embeds"] = {{
            ["title"] = "🎣 Fish Caught (Auto-Detected)",
            ["description"] = contentDesc,
            ["color"] = 65280,
            ["footer"] = { ["text"] = "Universal Scanner" },
            ["timestamp"] = DateTime.now():ToIsoDate()
        }}
    }

    httpRequest({
        Url = Webhook_URL,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = HttpService:JSONEncode(payload)
    })
end

-- [3] DATA ANALYSIS
local function IsFishData(args)
    -- We check the arguments to see if they look like fish data
    -- Based on your code: Arg2 is ID, Arg3 is Metadata (Table)
    
    for _, v in pairs(args) do
        if type(v) == "table" then
            -- Does this table have fish-like properties?
            if v.Weight or v.VariantId or v.Tier or v.Rarity then
                return true
            end
        end
        
        -- Or is it a string that sounds like a fish?
        if type(v) == "string" and (v:match("Fish") or v:match("Tuna") or v:match("Shark") or v:match("Rarity")) then
            return true
        end
    end
    return false
end

-- [4] CONNECT TO EVERYTHING
print("---------------------------------------------")
print("📡 CONNECTING TO ALL REMOTES...")

local ConnectedRemotes = {}

local function HookRemote(remote)
    if ConnectedRemotes[remote] then return end
    ConnectedRemotes[remote] = true
    
    remote.OnClientEvent:Connect(function(...)
        local args = {...}
        
        -- Check if this event looks like a fish catch
        if IsFishData(args) then
            print("✅ MATCH FOUND: " .. remote:GetFullName())
            SendWebhook(remote.Name, args)
        end
    end)
end

-- Scan existing remotes
for _, v in pairs(ReplicatedStorage:GetDescendants()) do
    if v:IsA("RemoteEvent") then
        HookRemote(v)
    end
end

-- Scan new remotes (in case they are created late)
ReplicatedStorage.DescendantAdded:Connect(function(v)
    if v:IsA("RemoteEvent") then
        HookRemote(v)
    end
end)

print("✅ SCANNER ACTIVE. CATCH A FISH!")
print("---------------------------------------------")
