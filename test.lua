--[[
    FISH IT! - DEEP SCAN LOGGER V3 (FINAL)
    Author: Gemini
    
    Features: 
    1. Deep Scan (Values & Attributes)
    2. Rarity Filters & Custom Colors (inc. Tosca for Secret)
    3. Proper Minimize & Close/Destroy Logic
]]

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local Backpack = Player:WaitForChild("Backpack")

-- [1] CONNECTION HOLDER
-- We store the listener here so we can disconnect it later
local BackpackConnection = nil

-- [2] CONFIGURATION
local HighRarityKeywords = {
    "Epic", "Legendary", "Mythical", "Divine", "Exotic", 
    "Godly", "Secret", "Ancient", "Limited", "Huge", "Shiny", 
    "Aurora", "Albino", "Big"
}

local Webhook_URL = "" 
local LastCatchTime = 0

-- [3] EXECUTOR CHECK
local httpRequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
if not httpRequest then
    return game.StarterGui:SetCore("SendNotification", {Title="Error", Text="Executor not supported!", Duration=10})
end

-- [4] GUI SETUP
-- Remove old GUI if it exists to prevent duplicates
for _, v in pairs(CoreGui:GetChildren()) do
    if v.Name == "FishItFinalLogger" then v:Destroy() end
end

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TopBar = Instance.new("Frame") -- For dragging and buttons
local TitleLabel = Instance.new("TextLabel")
local UrlInput = Instance.new("TextBox")
local TestButton = Instance.new("TextButton")
local StatusLabel = Instance.new("TextLabel")
local CloseBtn = Instance.new("TextButton")
local MinBtn = Instance.new("TextButton")
local OpenBtn = Instance.new("TextButton")

if syn and syn.protect_gui then syn.protect_gui(ScreenGui) end
ScreenGui.Parent = gethui and gethui() or CoreGui
ScreenGui.Name = "FishItFinalLogger"

-- Main Window
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
MainFrame.Size = UDim2.new(0, 300, 0, 170)
MainFrame.Active = true
MainFrame.Draggable = true -- Drag via the whole frame

-- Top Bar (Visual Header)
TopBar.Name = "TopBar"
TopBar.Parent = MainFrame
TopBar.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
TopBar.BorderSizePixel = 0
TopBar.Size = UDim2.new(1, 0, 0, 30)

-- Title
TitleLabel.Parent = TopBar
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.Size = UDim2.new(0.7, 0, 1, 0)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "🎒 Fish Logger V3"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 14
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- [X] Close Button
CloseBtn.Name = "Close"
CloseBtn.Parent = TopBar
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
CloseBtn.BorderSizePixel = 0
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14

-- [-] Minimize Button
MinBtn.Name = "Minimize"
MinBtn.Parent = TopBar
MinBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
MinBtn.BorderSizePixel = 0
MinBtn.Position = UDim2.new(1, -60, 0, 0)
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize = 14

-- Small Open Button (Hidden by default)
OpenBtn.Name = "OpenBtn"
OpenBtn.Parent = ScreenGui
OpenBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 150)
OpenBtn.Position = UDim2.new(0, 20, 0.9, -40)
OpenBtn.Size = UDim2.new(0, 100, 0, 30)
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.Text = "Open Logger"
OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenBtn.TextSize = 12
OpenBtn.Visible = false

-- Inputs
UrlInput.Parent = MainFrame
UrlInput.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
UrlInput.BorderSizePixel = 0
UrlInput.Position = UDim2.new(0.05, 0, 0.25, 0)
UrlInput.Size = UDim2.new(0.9, 0, 0, 35)
UrlInput.Font = Enum.Font.Gotham
UrlInput.PlaceholderText = "Paste Webhook URL Here..."
UrlInput.Text = ""
UrlInput.TextColor3 = Color3.fromRGB(200, 200, 200)
UrlInput.TextSize = 11

TestButton.Parent = MainFrame
TestButton.BackgroundColor3 = Color3.fromRGB(0, 200, 150) -- Tosca accent
TestButton.BorderSizePixel = 0
TestButton.Position = UDim2.new(0.05, 0, 0.55, 0)
TestButton.Size = UDim2.new(0.9, 0, 0, 30)
TestButton.Font = Enum.Font.GothamBold
TestButton.Text = "START MONITORING"
TestButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TestButton.TextSize = 12

StatusLabel.Parent = MainFrame
StatusLabel.BackgroundTransparency = 1
StatusLabel.Position = UDim2.new(0, 0, 0.8, 0)
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Text = "Status: Idle"
StatusLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
StatusLabel.TextSize = 12

-- [5] GUI BUTTON LOGIC

-- Minimize Logic
MinBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    OpenBtn.Visible = true
end)

-- Restore Logic
OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    OpenBtn.Visible = false
end)

-- Close / Destroy Logic (IMPORTANT)
CloseBtn.MouseButton1Click:Connect(function()
    -- 1. Stop the listener
    if BackpackConnection then
        BackpackConnection:Disconnect()
        BackpackConnection = nil
        print("[FishIt] Listener Disconnected.")
    end
    
    -- 2. Destroy the GUI
    ScreenGui:Destroy()
    print("[FishIt] Script Terminated.")
end)

-- [6] WEBHOOK SENDER
local function sendToDiscord(itemObj, rarityFound)
    if Webhook_URL == "" then return end
    
    -- Color Logic
    local embedColor = 10181046 -- Default Purple
    if string.find(rarityFound, "Legendary") then embedColor = 16766720 end -- Gold
    if string.find(rarityFound, "Mythical") then embedColor = 15158332 end -- Red
    if string.find(rarityFound, "Secret") then embedColor = 4251856 end -- Tosca
    
    local payload = {
        ["content"] = "", 
        ["embeds"] = {{
            ["title"] = "💎 Rare Catch Detected!",
            ["description"] = "**Player:** " .. Player.Name .. "\n**Item:** " .. itemObj.Name .. "\n**Rarity Tag:** " .. rarityFound,
            ["color"] = embedColor,
            ["thumbnail"] = {["url"] = "https://www.roblox.com/asset-thumbnail/image?assetId="..(itemObj.TextureId:match("%d+") or 0).."&width=420&height=420&format=png"},
            ["footer"] = { ["text"] = "Fish It! Logger" },
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
    StatusLabel.Text = "Monitoring Active"
    StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
end)

-- [7] DEEP SCAN LOGIC
local function scanItemForRarity(item)
    -- 1. Name Scan
    for _, keyword in ipairs(HighRarityKeywords) do
        if string.find(item.Name, keyword) then return keyword end
    end

    -- 2. Value Scan (Descendants)
    for _, descendant in pairs(item:GetDescendants()) do
        if descendant:IsA("StringValue") then
            for _, keyword in ipairs(HighRarityKeywords) do
                if string.find(descendant.Value, keyword) then return keyword end
            end
        end
    end
    
    -- 3. Attribute Scan
    local attributes = item:GetAttributes()
    for name, value in pairs(attributes) do
        if type(value) == "string" then
             for _, keyword in ipairs(HighRarityKeywords) do
                if string.find(value, keyword) then return keyword end
            end
        end
    end

    return nil
end

local function onItemAdded(item)
    print(item)
    if item:IsA("Tool") then
        task.wait(0.5) 
        local rarity = scanItemForRarity(item)
        
        if rarity then
            if (tick() - LastCatchTime) > 1 then
                LastCatchTime = tick()
                StatusLabel.Text = "Sent: " .. rarity
                StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
                sendToDiscord(item, rarity)
                
                task.wait(2)
                StatusLabel.Text = "Monitoring Active"
                StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
            end
        end
    end
end

-- [8] ACTIVATE LISTENER
-- We assign this to the variable we defined at the very top.
-- This allows the Close button to access it and turn it off.
BackpackConnection = Backpack.ChildAdded:Connect(onItemAdded)

-- Notification
game.StarterGui:SetCore("SendNotification", {
    Title = "Logger Loaded";
    Text = "Use the GUI to set URL. Press X to stop script completely.";
    Duration = 5;
})
