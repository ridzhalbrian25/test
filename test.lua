--[[
    FISH IT! - WEBHOOK GUI + CONSOLE LOGS
    Author: Gemini
    
    Updates:
    - Prints every catch to F9 Console
    - Hooks into game ItemUtility for accurate data
    - Full GUI Control
]]

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

-- [1] GAME MODULES & REMOTES
local ItemUtility = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ItemUtility"))
local StringLibrary = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("StringLibrary"))

local function GetRemote()
    local targetName = "ObtainedNewFishNotification"
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") and v.Name == targetName then
            return v
        end
    end
    return nil
end

local FishRemote = GetRemote()

-- [2] VARIABLES
local Webhook_URL = ""
local ListenerConnection = nil
local IsRunning = false
local Player = Players.LocalPlayer

-- [3] EXECUTOR CHECK
local httpRequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
if not httpRequest then
    return game.StarterGui:SetCore("SendNotification", {Title="Error", Text="Executor not supported!", Duration=10})
end

-- [4] GUI SETUP
for _, v in pairs(CoreGui:GetChildren()) do
    if v.Name == "FishItWebhookUI" then v:Destroy() end
end

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TopBar = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local MinBtn = Instance.new("TextButton")
local CloseBtn = Instance.new("TextButton")
local Content = Instance.new("Frame")
local OpenBtn = Instance.new("TextButton")

if syn and syn.protect_gui then syn.protect_gui(ScreenGui) end
ScreenGui.Parent = gethui and gethui() or CoreGui
ScreenGui.Name = "FishItWebhookUI"

-- Styling Function
local function StyleObj(obj, radius, strokeCol, bgTrans)
    local corner = Instance.new("UICorner", obj)
    corner.CornerRadius = UDim.new(0, radius or 6)
    local stroke = Instance.new("UIStroke", obj)
    stroke.Color = strokeCol or Color3.fromRGB(80, 100, 120)
    stroke.Transparency = 0.6
    obj.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    obj.BackgroundTransparency = bgTrans or 0.1
    obj.BorderSizePixel = 0
end

-- Main Frame
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -100)
MainFrame.Size = UDim2.new(0, 250, 0, 220)
MainFrame.Active = true; MainFrame.Draggable = true
StyleObj(MainFrame, 8, Color3.fromRGB(0, 150, 255))

-- Top Bar
TopBar.Parent = MainFrame
TopBar.Size = UDim2.new(1, 0, 0, 30)
StyleObj(TopBar, 8, nil, 0.5)
local cover = Instance.new("Frame", TopBar)
cover.Size = UDim2.new(1,0,0,5); cover.Position = UDim2.new(0,0,1,-5); cover.BackgroundTransparency = 1

Title.Parent = TopBar
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Size = UDim2.new(0.7, 0, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "🎣 Fish It! Logger"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Buttons
CloseBtn.Parent = TopBar; CloseBtn.Text = "X"; CloseBtn.Position = UDim2.new(1, -25, 0, 0); CloseBtn.Size = UDim2.new(0, 25, 0, 30)
CloseBtn.BackgroundTransparency = 1; CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80); CloseBtn.Font = Enum.Font.GothamBold

MinBtn.Parent = TopBar; MinBtn.Text = "-"; MinBtn.Position = UDim2.new(1, -50, 0, 0); MinBtn.Size = UDim2.new(0, 25, 0, 30)
MinBtn.BackgroundTransparency = 1; MinBtn.TextColor3 = Color3.new(1,1,1); MinBtn.Font = Enum.Font.GothamBold

-- Content Area
Content.Parent = MainFrame
Content.Position = UDim2.new(0, 10, 0, 40)
Content.Size = UDim2.new(1, -20, 1, -50)
Content.BackgroundTransparency = 1

-- URL Input
local UrlBox = Instance.new("TextBox", Content)
UrlBox.Size = UDim2.new(1, 0, 0, 35)
UrlBox.PlaceholderText = "Paste Webhook URL..."
UrlBox.Text = ""
UrlBox.TextColor3 = Color3.new(1,1,1)
UrlBox.Font = Enum.Font.Gotham
StyleObj(UrlBox, 6, nil, 0.4)

-- Status Label
local StatusLbl = Instance.new("TextLabel", Content)
StatusLbl.Position = UDim2.new(0, 0, 0, 45)
StatusLbl.Size = UDim2.new(1, 0, 0, 20)
StatusLbl.BackgroundTransparency = 1
StatusLbl.Text = "Status: Stopped"
StatusLbl.TextColor3 = Color3.fromRGB(150, 150, 150)
StatusLbl.Font = Enum.Font.GothamBold
StatusLbl.TextSize = 12

-- Start Button
local StartBtn = Instance.new("TextButton", Content)
StartBtn.Position = UDim2.new(0, 0, 0, 75)
StartBtn.Size = UDim2.new(0.48, 0, 0, 35)
StartBtn.Text = "START"
StartBtn.TextColor3 = Color3.new(1,1,1)
StartBtn.Font = Enum.Font.GothamBold
StyleObj(StartBtn, 6, Color3.fromRGB(0, 255, 100), 0.5)
StartBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 50)

-- Stop Button
local StopBtn = Instance.new("TextButton", Content)
StopBtn.Position = UDim2.new(0.52, 0, 0, 75)
StopBtn.Size = UDim2.new(0.48, 0, 0, 35)
StopBtn.Text = "STOP"
StopBtn.TextColor3 = Color3.new(1,1,1)
StopBtn.Font = Enum.Font.GothamBold
StyleObj(StopBtn, 6, Color3.fromRGB(255, 50, 50), 0.5)
StopBtn.BackgroundColor3 = Color3.fromRGB(100, 30, 30)

-- Test Button
local TestBtn = Instance.new("TextButton", Content)
TestBtn.Position = UDim2.new(0, 0, 0, 120)
TestBtn.Size = UDim2.new(1, 0, 0, 25)
TestBtn.Text = "Send Test Message"
TestBtn.TextColor3 = Color3.fromRGB(200, 200, 255)
TestBtn.Font = Enum.Font.Gotham
TestBtn.BackgroundTransparency = 1

-- Open Button
OpenBtn.Name = "OpenUI"
OpenBtn.Parent = ScreenGui
OpenBtn.Position = UDim2.new(0, 20, 0.9, -40)
OpenBtn.Size = UDim2.new(0, 80, 0, 30)
OpenBtn.Text = "Logger"
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.TextColor3 = Color3.new(1,1,1)
OpenBtn.Visible = false
StyleObj(OpenBtn, 8, Color3.fromRGB(0, 150, 255))


-- [5] LOGIC FUNCTIONS

local function ColorToDec(c)
    return math.floor(c.R * 255) * 65536 + math.floor(c.G * 255) * 256 + math.floor(c.B * 255)
end

local function SendToDiscord(payload)
    if Webhook_URL == "" then return end
    pcall(function()
        httpRequest({
            Url = Webhook_URL,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode(payload)
        })
    end)
end

local function OnFishCaught(id, metadata, textNotification, isNew)
    -- 1. Get Item Data
    local itemData = ItemUtility:GetItemData(id)
    if not itemData then return end
    
    local fishName = itemData.Data.Name
    local rarityText = "Unknown"
    local weightText = "N/A"
    local colorDec = 16777215
    local colorRgb = Color3.new(1,1,1) -- Default White
    
    -- 2. Calculate Rarity
    if itemData.Probability and itemData.Probability.Chance then
         local chance = math.round(1 / itemData.Probability.Chance * 10) / 10
         rarityText = "1 in " .. tostring(chance)
    end
    
    -- 3. Handle Variant
    if metadata and metadata.VariantId then
        local variantData = ItemUtility:GetVariantData(metadata.VariantId)
        if variantData then
            fishName = variantData.Data.Name .. " " .. fishName
            colorDec = ColorToDec(variantData.Data.TierColor)
            colorRgb = variantData.Data.TierColor
        end
    end
    
    -- 4. Format Weight
    if metadata and metadata.Weight then
        if StringLibrary and StringLibrary.AddWeight then
             pcall(function() weightText = StringLibrary:AddWeight(metadata.Weight) end)
        else
             weightText = string.format("%.1f", metadata.Weight)
        end
    end
    
    -- [CONSOLE LOG]
    -- This prints to F9 every time a fish is caught
    print("------------------------------------------------")
    print("🎣 [FishIt] NEW CATCH:")
    print("   🐟 Name:   " .. fishName)
    print("   ✨ Rarity: " .. rarityText)
    print("   ⚖️ Weight: " .. weightText)
    warn("   🎨 Color:  " .. tostring(colorRgb)) -- Prints RGB for debugging colors
    print("------------------------------------------------")

    -- 5. Build Embed
    local embed = {
        ["embeds"] = {{
            ["title"] = "🎣 New Catch!",
            ["color"] = colorDec,
            ["thumbnail"] = { ["url"] = itemData.Data.Icon or "" },
            ["fields"] = {
                { ["name"] = "Fish", ["value"] = "**" .. fishName .. "**", ["inline"] = true },
                { ["name"] = "Rarity", ["value"] = rarityText, ["inline"] = true },
                { ["name"] = "Weight", ["value"] = weightText, ["inline"] = true },
                { ["name"] = "Is New?", ["value"] = isNew and "✨ YES" or "No", ["inline"] = true }
            },
            ["footer"] = { ["text"] = "Fish It! Logger | " .. Player.Name },
            ["timestamp"] = DateTime.now():ToIsoDate()
        }}
    }
    
    SendToDiscord(embed)
end

-- [6] BUTTON EVENTS

StartBtn.MouseButton1Click:Connect(function()
    Webhook_URL = UrlBox.Text
    if Webhook_URL == "" then
        StatusLbl.Text = "Error: No URL!"
        StatusLbl.TextColor3 = Color3.fromRGB(255, 50, 50)
        return
    end
    
    if IsRunning then return end
    
    if not FishRemote then
        StatusLbl.Text = "Error: Remote Not Found"
        return
    end
    
    -- Connect Listener
    ListenerConnection = FishRemote.OnClientEvent:Connect(OnFishCaught)
    IsRunning = true
    
    StatusLbl.Text = "Status: ● Listening..."
    StatusLbl.TextColor3 = Color3.fromRGB(50, 255, 100)
    UrlBox.Editable = false
    
    print("[FishIt] Logger Started! Check console for catches.")
end)

StopBtn.MouseButton1Click:Connect(function()
    if ListenerConnection then
        ListenerConnection:Disconnect()
        ListenerConnection = nil
    end
    IsRunning = false
    
    StatusLbl.Text = "Status: Stopped"
    StatusLbl.TextColor3 = Color3.fromRGB(255, 100, 100)
    UrlBox.Editable = true
    print("[FishIt] Logger Stopped.")
end)

TestBtn.MouseButton1Click:Connect(function()
    Webhook_URL = UrlBox.Text
    if Webhook_URL == "" then return end
    
    SendToDiscord({
        ["content"] = "🔔 **Webhook Test Successful!**"
    })
end)

MinBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    OpenBtn.Visible = true
end)

OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    OpenBtn.Visible = false
end)

CloseBtn.MouseButton1Click:Connect(function()
    if ListenerConnection then ListenerConnection:Disconnect() end
    ScreenGui:Destroy()
end)
