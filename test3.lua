--[[
    FISH IT! - PRECISION LOGGER V4
    Author: Gemini
    
    Target: "RE/ObtainedNewFishNotification"
    Method: ID Decoding via ItemUtility
]]

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer

-- [1] GAME MODULES
-- We need these to convert ID "117" into "Bandit Angelfish"
local ItemUtility = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ItemUtility"))
local StringLibrary = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("StringLibrary"))

-- [2] FIND THE SPECIFIC REMOTE
-- The log showed "RE/ObtainedNewFishNotification", likely inside Packages/Net
local function GetTargetRemote()
    local TargetName = "RE/ObtainedNewFishNotification"
    
    -- Scan ReplicatedStorage recursively
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") and v.Name == TargetName then
            return v
        end
    end
    
    -- Fallback: Try to find just by the end of the name
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") and v.Name:match("ObtainedNewFishNotification") then
            return v
        end
    end
    return nil
end

local FishRemote = GetTargetRemote()

-- [3] VARIABLES & GUI STATE
local Webhook_URL = ""
local ListenerConnection = nil
local IsRunning = false

-- [4] GUI CREATION
for _, v in pairs(CoreGui:GetChildren()) do
    if v.Name == "FishItPrecisionGUI" then v:Destroy() end
end

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TopBar = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local CloseBtn = Instance.new("TextButton")
local MinBtn = Instance.new("TextButton")
local Content = Instance.new("Frame")
local OpenBtn = Instance.new("TextButton")

if syn and syn.protect_gui then syn.protect_gui(ScreenGui) end
ScreenGui.Parent = gethui and gethui() or CoreGui
ScreenGui.Name = "FishItPrecisionGUI"

-- Styles
local function Style(obj, col)
    local c = Instance.new("UICorner", obj); c.CornerRadius = UDim.new(0,6)
    obj.BackgroundColor3 = col or Color3.fromRGB(25,25,30)
    obj.BorderSizePixel = 0
end

-- Main
MainFrame.Parent = ScreenGui
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -110)
MainFrame.Size = UDim2.new(0, 250, 0, 220)
MainFrame.Active = true; MainFrame.Draggable = true
Style(MainFrame)

-- Top
TopBar.Parent = MainFrame; TopBar.Size = UDim2.new(1,0,0,30)
Style(TopBar, Color3.fromRGB(35,35,40))
Title.Parent = TopBar; Title.Text = "🎣 Precision Logger"; Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.new(1,1,1); Title.Size = UDim2.new(1,0,1,0); Title.BackgroundTransparency = 1

CloseBtn.Parent = TopBar; CloseBtn.Text = "X"; CloseBtn.TextColor3 = Color3.fromRGB(255,80,80)
CloseBtn.BackgroundTransparency = 1; CloseBtn.Position = UDim2.new(1,-25,0,0); CloseBtn.Size = UDim2.new(0,25,1,0)
CloseBtn.Font = Enum.Font.GothamBold

MinBtn.Parent = TopBar; MinBtn.Text = "-"; MinBtn.TextColor3 = Color3.new(1,1,1)
MinBtn.BackgroundTransparency = 1; MinBtn.Position = UDim2.new(1,-50,0,0); MinBtn.Size = UDim2.new(0,25,1,0)
MinBtn.Font = Enum.Font.GothamBold

-- Content
Content.Parent = MainFrame; Content.Position = UDim2.new(0,10,0,40); Content.Size = UDim2.new(1,-20,1,-50)
Content.BackgroundTransparency = 1

local UrlBox = Instance.new("TextBox", Content)
UrlBox.Size = UDim2.new(1,0,0,35); UrlBox.PlaceholderText = "Webhook URL..."
UrlBox.Text = ""; UrlBox.TextColor3 = Color3.new(1,1,1); UrlBox.Font = Enum.Font.Gotham
Style(UrlBox, Color3.fromRGB(45,45,50))

local Status = Instance.new("TextLabel", Content)
Status.Size = UDim2.new(1,0,0,20); Status.Position = UDim2.new(0,0,0,40)
Status.BackgroundTransparency = 1; Status.Text = "Status: Idle"; Status.TextColor3 = Color3.fromRGB(150,150,150)
Status.Font = Enum.Font.Gotham

local StartBtn = Instance.new("TextButton", Content)
StartBtn.Size = UDim2.new(0.48,0,0,35); StartBtn.Position = UDim2.new(0,0,0,70)
StartBtn.Text = "START"; StartBtn.TextColor3 = Color3.new(1,1,1); StartBtn.Font = Enum.Font.GothamBold
Style(StartBtn, Color3.fromRGB(0,150,100))

local StopBtn = Instance.new("TextButton", Content)
StopBtn.Size = UDim2.new(0.48,0,0,35); StopBtn.Position = UDim2.new(0.52,0,0,70)
StopBtn.Text = "STOP"; StopBtn.TextColor3 = Color3.new(1,1,1); StopBtn.Font = Enum.Font.GothamBold
Style(StopBtn, Color3.fromRGB(150,50,50))

local TestBtn = Instance.new("TextButton", Content)
TestBtn.Size = UDim2.new(1,0,0,25); TestBtn.Position = UDim2.new(0,0,0,120)
TestBtn.Text = "Test Webhook"; TestBtn.TextColor3 = Color3.fromRGB(100,200,255); TestBtn.BackgroundTransparency = 1
TestBtn.Font = Enum.Font.Gotham

-- Minimized
OpenBtn.Parent = ScreenGui; OpenBtn.Size = UDim2.new(0,100,0,30); OpenBtn.Position = UDim2.new(0,10,0.9,-40)
OpenBtn.Text = "Open Logger"; OpenBtn.Visible = false; OpenBtn.TextColor3 = Color3.new(1,1,1); OpenBtn.Font = Enum.Font.GothamBold
Style(OpenBtn, Color3.fromRGB(0,150,255))

-- [5] LOGIC

local function ColorToDec(c)
    return math.floor(c.R*255)*65536 + math.floor(c.G*255)*256 + math.floor(c.B*255)
end

local function SendWebhook(embed)
    if Webhook_URL == "" then return end
    local request = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    if request then
        request({
            Url = Webhook_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({["embeds"] = {embed}})
        })
    end
end

-- The Core Processing Function
local function OnEventFired(...)
    local args = {...}
    
    -- MAPPING FROM YOUR LOGS:
    -- Arg[1]: Item ID (117)
    -- Arg[2]: Metadata Table (Weight, Variant)
    -- Arg[4]: IsNew (Boolean)
    
    local itemId = args[1]
    local metadata = args[2]
    local isNew = args[4]
    
    -- 1. Use Game Utility to decode ID -> Name
    local itemData = ItemUtility:GetItemData(itemId)
    if not itemData then return end
    
    local fishName = itemData.Data.Name
    local rarityText = "Unknown"
    local weightText = "N/A"
    local icon = itemData.Data.Icon or ""
    
    -- 2. Calculate Rarity
    if itemData.Probability and itemData.Probability.Chance then
        local chance = math.round(1 / itemData.Probability.Chance * 10) / 10
        rarityText = "1 in " .. tostring(chance)
    end

    -- 3. Variant & Color
    local colorDec = 16777215 -- White
    
    if metadata and metadata.VariantId then
        local variantData = ItemUtility:GetVariantData(metadata.VariantId)
        if variantData then
            fishName = variantData.Data.Name .. " " .. fishName
            colorDec = ColorToDec(variantData.Data.TierColor)
        end
    end
    
    -- [CUSTOM COLORS] - Override logic for specific rarities
    if string.find(rarityText, "Legendary") then colorDec = 16766720 end -- Gold
    if string.find(rarityText, "Mythical") then colorDec = 15158332 end -- Red
    if string.find(rarityText, "Secret") then colorDec = 4251856 end   -- Tosca/Turquoise (#40E0D0)
    
    -- 4. Weight
    if metadata and metadata.Weight then
        weightText = tostring(math.round(metadata.Weight * 10) / 10) .. " kg"
    end

    -- Console Log
    print("🐟 CAUGHT: " .. fishName .. " | " .. rarityText .. " | " .. weightText .. " | " .. icon .. " | " .. colorDec)
    
    -- 5. Send
    SendWebhook({
        ["title"] = "🎣 Catch Detected!",
        ["description"] = "**Fish:** " .. fishName .. "\n**Rarity:** " .. rarityText .. "\n**Weight:** " .. weightText,
        ["color"] = colorDec,
        ["thumbnail"] = { ["url"] = icon },
        ["footer"] = { ["text"] = "Fish It! Logger | " .. Player.Name },
        ["timestamp"] = DateTime.now():ToIsoDate()
    })
end

-- [6] BUTTONS

StartBtn.MouseButton1Click:Connect(function()
    if IsRunning then return end
    if not FishRemote then Status.Text = "Remote Not Found!"; return end
    
    Webhook_URL = UrlBox.Text
    if Webhook_URL == "" then Status.Text = "Paste URL first!"; return end

    ListenerConnection = FishRemote.OnClientEvent:Connect(OnEventFired)
    IsRunning = true
    Status.Text = "Status: Listening..."
    Status.TextColor3 = Color3.fromRGB(50, 255, 50)
    UrlBox.Editable = false
end)

StopBtn.MouseButton1Click:Connect(function()
    if ListenerConnection then ListenerConnection:Disconnect() end
    IsRunning = false
    Status.Text = "Status: Stopped"
    Status.TextColor3 = Color3.fromRGB(255, 50, 50)
    UrlBox.Editable = true
end)

TestBtn.MouseButton1Click:Connect(function()
    Webhook_URL = UrlBox.Text
    if Webhook_URL ~= "" then
        SendWebhook({["title"] = "🔔 Test Message", ["description"] = "Logger is working!", ["color"] = 65280})
    end
end)

MinBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; OpenBtn.Visible = true end)
OpenBtn.MouseButton1Click:Connect(function() MainFrame.Visible = true; OpenBtn.Visible = false end)
CloseBtn.MouseButton1Click:Connect(function()
    if ListenerConnection then ListenerConnection:Disconnect() end
    ScreenGui:Destroy()
end)
