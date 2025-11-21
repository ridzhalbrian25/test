--[[
    FISH IT! - EPIC+ RARITY WEBHOOK LOGGER
    Author: Gemini
    
    Function: Scans UI for catch messages.
    Filter: ONLY sends if text contains "Epic", "Legendary", "Mythical", etc.
]]

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- [1] RARITY CONFIGURATION
-- Only these words will trigger the webhook. Add more if the game uses different names.
local HighRarityKeywords = {
    "Epic",
    "Legendary",
    "Mythical",
    "Divine",
    "Exotic",
    "Godly",
    "Secret",
    "Ancient",
    "Limited",
    "Huge",
    "Shiny"
}

-- [2] VARIABLES
local Webhook_URL = "" 
local LastCatchTime = 0

-- [3] EXECUTOR CHECK
local httpRequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
if not httpRequest then
    return game.StarterGui:SetCore("SendNotification", {Title="Error", Text="Executor not supported!", Duration=10})
end

-- [4] GUI SETUP (Draggable & Minimal)
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TitleLabel = Instance.new("TextLabel")
local UrlInput = Instance.new("TextBox")
local TestButton = Instance.new("TextButton")
local StatusLabel = Instance.new("TextLabel")

if syn and syn.protect_gui then syn.protect_gui(ScreenGui) end
ScreenGui.Parent = gethui and gethui() or CoreGui
ScreenGui.Name = "FishItRarityLogger"

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 25, 40) -- Purple theme for Epic
MainFrame.BorderColor3 = Color3.fromRGB(170, 0, 255)
MainFrame.BorderSizePixel = 2
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
MainFrame.Size = UDim2.new(0, 300, 0, 160)
MainFrame.Active = true
MainFrame.Draggable = true

TitleLabel.Parent = MainFrame
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0,0,0,5)
TitleLabel.Size = UDim2.new(1, 0, 0, 20)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "🟣 Epic+ Fish Logger"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 16

UrlInput.Parent = MainFrame
UrlInput.BackgroundColor3 = Color3.fromRGB(45, 40, 55)
UrlInput.Position = UDim2.new(0.05, 0, 0.25, 0)
UrlInput.Size = UDim2.new(0.9, 0, 0, 35)
UrlInput.Font = Enum.Font.Gotham
UrlInput.PlaceholderText = "Paste Webhook URL Here..."
UrlInput.Text = ""
UrlInput.TextColor3 = Color3.fromRGB(200, 200, 200)
UrlInput.TextSize = 11

TestButton.Parent = MainFrame
TestButton.BackgroundColor3 = Color3.fromRGB(170, 0, 255)
TestButton.Position = UDim2.new(0.05, 0, 0.55, 0)
TestButton.Size = UDim2.new(0.9, 0, 0, 30)
TestButton.Font = Enum.Font.GothamBold
TestButton.Text = "START LOGGING"
TestButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TestButton.TextSize = 12

StatusLabel.Parent = MainFrame
StatusLabel.BackgroundTransparency = 1
StatusLabel.Position = UDim2.new(0, 0, 0.8, 0)
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Text = "Scanning for high rarity..."
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
StatusLabel.TextSize = 12

-- [5] WEBHOOK SENDER
local function sendToDiscord(fishText, rarityFound)
    if Webhook_URL == "" then return end
    
    -- Choose color based on rarity string
    local embedColor = 10181046 -- Default Purple
    if string.find(rarityFound, "Legendary") then embedColor = 16766720 end -- Gold
    if string.find(rarityFound, "Mythical") then embedColor = 15158332 end -- Red
    
    local payload = {
        ["content"] = "Some lucky catch!", -- Optional ping message
        ["embeds"] = {{
            ["title"] = "💎 High Rarity Catch!",
            ["description"] = "**Player:** " .. Player.Name .. "\n**Message:** " .. fishText .. "\n**Rarity Detected:** " .. rarityFound,
            ["color"] = embedColor,
            ["footer"] = { ["text"] = "Fish It! Rarity Scanner" },
            ["timestamp"] = DateTime.now():ToIsoDate()
        }}
    }

    pcall(function()
        httpRequest({
            Url = Webhook_URL,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode(payload)
        })
    end)
end

TestButton.MouseButton1Click:Connect(function()
    Webhook_URL = UrlInput.Text
    StatusLabel.Text = "Testing..."
    sendToDiscord("Test Catch (Epic Tuna)", "Epic")
    task.wait(1)
    StatusLabel.Text = "Scanning for Epics+..."
end)

-- [6] SMART RARITY SCANNER

local function checkRarity(text)
    -- Clean the text for easier checking
    local cleanText = text -- You can add :lower() here if you lowercase your keywords list
    
    for _, rarity in ipairs(HighRarityKeywords) do
        -- Check if the text contains any of our special words
        if string.find(cleanText, rarity) then
            return rarity -- Return the rarity found (e.g., "Legendary")
        end
    end
    return nil
end

PlayerGui.DescendantAdded:Connect(function(descendant)
    if descendant:IsA("TextLabel") then
        -- Wait for text to populate
        task.wait(0.1)
        
        local text = descendant.Text
        if text ~= "" then
            -- 1. Check if it's a high rarity
            local rarityFound = checkRarity(text)
            
            if rarityFound then
                -- 2. Anti-Spam (2 second cooldown)
                if (tick() - LastCatchTime) > 2 then
                    LastCatchTime = tick()
                    
                    print("[FishIt] High Rarity Found: " .. text)
                    StatusLabel.Text = "Sent: " .. rarityFound
                    StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
                    
                    sendToDiscord(text, rarityFound)
                    
                    task.wait(3)
                    StatusLabel.Text = "Scanning for Epics+..."
                    StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
                end
            else
                -- Debug: Uncomment the line below to see what text the script ignores
                -- print("Ignored (Low Rarity): " .. text)
            end
        end
    end
end)

-- Notify Loaded
game.StarterGui:SetCore("SendNotification", {
    Title = "Rarity Filter ON";
    Text = "Only sending Epic+ fish now.";
    Duration = 5;
})
