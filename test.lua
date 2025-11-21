--[[
    FISH IT! - SMART WEBHOOK LOGGER (UI DETECTION VERSION)
    Author: Gemini
    
    Fix: Uses PlayerGui detection instead of Backpack detection.
]]

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- [1] CONFIGURATION & STATE
local Webhook_URL = "" -- Will be set via GUI
local Debounce = false
local LastCatchTime = 0

-- [2] EXECUTOR CHECK
local httpRequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
if not httpRequest then
    return game.StarterGui:SetCore("SendNotification", {Title="Error", Text="Executor not supported!", Duration=10})
end

-- [3] GUI CREATION
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TitleLabel = Instance.new("TextLabel")
local UrlInput = Instance.new("TextBox")
local TestButton = Instance.new("TextButton")
local StatusLabel = Instance.new("TextLabel")
local ToggleBtn = Instance.new("TextButton")

if syn and syn.protect_gui then syn.protect_gui(ScreenGui) end
ScreenGui.Parent = gethui and gethui() or CoreGui
ScreenGui.Name = "FishItSmartLogger"

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
MainFrame.Size = UDim2.new(0, 300, 0, 160)
MainFrame.Active = true
MainFrame.Draggable = true

TitleLabel.Parent = MainFrame
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0,0,0,5)
TitleLabel.Size = UDim2.new(1, 0, 0, 20)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "🎣 Fish Logger (UI Scan)"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 16

UrlInput.Parent = MainFrame
UrlInput.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
UrlInput.Position = UDim2.new(0.05, 0, 0.25, 0)
UrlInput.Size = UDim2.new(0.9, 0, 0, 35)
UrlInput.Font = Enum.Font.Gotham
UrlInput.PlaceholderText = "Paste Webhook URL Here..."
UrlInput.Text = ""
UrlInput.TextColor3 = Color3.fromRGB(200, 200, 200)
UrlInput.TextSize = 11

TestButton.Parent = MainFrame
TestButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
TestButton.Position = UDim2.new(0.05, 0, 0.55, 0)
TestButton.Size = UDim2.new(0.9, 0, 0, 30)
TestButton.Font = Enum.Font.GothamBold
TestButton.Text = "TEST & SAVE"
TestButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TestButton.TextSize = 12

StatusLabel.Parent = MainFrame
StatusLabel.BackgroundTransparency = 1
StatusLabel.Position = UDim2.new(0, 0, 0.8, 0)
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Text = "Waiting for catch..."
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
StatusLabel.TextSize = 12

-- [4] WEBHOOK FUNCTION
local function sendToDiscord(fishName, details)
    if Webhook_URL == "" then return end
    
    local payload = {
        ["embeds"] = {{
            ["title"] = "🎣 Catch Detected!",
            ["description"] = "**Player:** " .. Player.Name .. "\n**Catch:** " .. fishName .. "\n**Details:** " .. details,
            ["color"] = 65280,
            ["footer"] = { ["text"] = "UI Scanner Log" },
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
    StatusLabel.Text = "Sending Test..."
    sendToDiscord("Test Fish", "System Check")
    task.wait(1)
    StatusLabel.Text = "Active! Go catch fish."
end)

-- [5] SMART DETECTION LOGIC (The Fix)

local function isValidCatch(text)
    -- List of keywords that usually appear when you catch something
    local keywords = {"Caught", "Rarity", "Weight", "lb", "kg", "You received"}
    for _, keyword in ipairs(keywords) do
        if string.find(text, keyword) then
            return true
        end
    end
    return false
end

-- Scan for new UI elements appearing (The Notification Popup)
PlayerGui.DescendantAdded:Connect(function(descendant)
    -- 1. We only care about TextLabels (Text)
    if descendant:IsA("TextLabel") then
        
        -- 2. Wait a tiny bit for the game to set the text
        task.wait(0.1) 
        
        -- 3. Check if the text looks like a catch
        if descendant.Text ~= "" and isValidCatch(descendant.Text) then
            
            -- 4. Anti-Spam Check (Prevent double firing for same fish)
            if (tick() - LastCatchTime) > 2 then
                LastCatchTime = tick()
                
                print("[FishIt Logger] Text Detected: " .. descendant.Text)
                StatusLabel.Text = "Catch Detected!"
                
                -- Try to clean up the text
                local cleanText = descendant.Text:gsub("You caught a ", ""):gsub("!", "")
                
                sendToDiscord(cleanText, "Detected via UI Notification")
                
                task.wait(2)
                StatusLabel.Text = "Ready..."
            end
        end
    end
end)

-- Alternative: Leaderstats Detection (Backup)
-- If the game uses Leaderstats for "Total Fish", we watch that too.
if Player:FindFirstChild("leaderstats") then
    for _, stat in pairs(Player.leaderstats:GetChildren()) do
        stat.Changed:Connect(function(newVal)
            if (tick() - LastCatchTime) > 2 then
                LastCatchTime = tick()
                sendToDiscord("Unknown Fish (Stat Update)", stat.Name .. ": " .. tostring(newVal))
            end
        end)
    end
end
