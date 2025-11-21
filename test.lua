--[[
    FISH IT! - AUTO WEBHOOK LOGGER WITH GUI
    Author: Gemini
    Instructions:
    1. Execute script.
    2. Paste Webhook URL in the box.
    3. Click "Test Webhook" to verify.
    4. Minimize GUI and start fishing!
]]

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

-- [1] EXECUTOR CHECK
local httpRequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
if not httpRequest then
    game.StarterGui:SetCore("SendNotification", {
        Title = "Error";
        Text = "Your executor does not support HTTP requests!";
        Duration = 10;
    })
    return
end

-- [2] GUI CREATION
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TitleLabel = Instance.new("TextLabel")
local UrlInput = Instance.new("TextBox")
local TestButton = Instance.new("TextButton")
local StatusLabel = Instance.new("TextLabel")
local ToggleButton = Instance.new("TextButton")
local MinimizeBtn = Instance.new("TextButton")

-- Protect GUI (Anti-Detection / Organization)
if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
elseif gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = CoreGui
end

ScreenGui.Name = "FishItWebhookGUI"

-- Styling Main Frame
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
MainFrame.Size = UDim2.new(0, 300, 0, 180)
MainFrame.Active = true
MainFrame.Draggable = true -- Makes it movable

-- Title
TitleLabel.Parent = MainFrame
TitleLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
TitleLabel.Size = UDim2.new(1, 0, 0, 30)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "🎣 Fish It! Webhook Config"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 14

-- Minimize Button (X)
MinimizeBtn.Parent = TitleLabel
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Position = UDim2.new(1, -30, 0, 0)
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MinimizeBtn.TextSize = 18
MinimizeBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    ToggleButton.Visible = true
end)

-- Input Box
UrlInput.Parent = MainFrame
UrlInput.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
UrlInput.BorderSizePixel = 0
UrlInput.Position = UDim2.new(0.05, 0, 0.25, 0)
UrlInput.Size = UDim2.new(0.9, 0, 0, 40)
UrlInput.Font = Enum.Font.Gotham
UrlInput.PlaceholderText = "Paste Discord Webhook URL Here..."
UrlInput.Text = ""
UrlInput.TextColor3 = Color3.fromRGB(200, 200, 200)
UrlInput.TextSize = 12
UrlInput.TextWrapped = true

-- Test Button
TestButton.Parent = MainFrame
TestButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
TestButton.BorderSizePixel = 0
TestButton.Position = UDim2.new(0.05, 0, 0.55, 0)
TestButton.Size = UDim2.new(0.9, 0, 0, 35)
TestButton.Font = Enum.Font.GothamBold
TestButton.Text = "TEST WEBHOOK"
TestButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TestButton.TextSize = 14

-- Status Label
StatusLabel.Parent = MainFrame
StatusLabel.BackgroundTransparency = 1
StatusLabel.Position = UDim2.new(0, 0, 0.8, 0)
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Text = "Status: Idle"
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
StatusLabel.TextSize = 12

-- Toggle Button (Small button to open menu back up)
ToggleButton.Name = "OpenGUI"
ToggleButton.Parent = ScreenGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
ToggleButton.Position = UDim2.new(0, 10, 0.9, -40)
ToggleButton.Size = UDim2.new(0, 100, 0, 30)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "Webhook UI"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Visible = false
ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    ToggleButton.Visible = false
end)

-- [3] FUNCTIONS

local function sendToDiscord(url, title, description, color)
    if url == "" or not url:find("http") then
        StatusLabel.Text = "Status: Invalid URL!"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        return
    end

    local payload = {
        ["content"] = "",
        ["embeds"] = {{
            ["title"] = title,
            ["description"] = description,
            ["type"] = "rich",
            ["color"] = color,
            ["footer"] = { ["text"] = "Fish It! Logger | " .. os.date("%X") }
        }}
    }

    local success, err = pcall(function()
        httpRequest({
            Url = url,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode(payload)
        })
    end)

    if success then
        StatusLabel.Text = "Status: Sent Successfully!"
        StatusLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
        task.wait(2)
        StatusLabel.Text = "Status: Ready"
        StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    else
        StatusLabel.Text = "Status: Request Failed"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        warn(err)
    end
end

-- [4] EVENT CONNECTIONS

-- Test Button Logic
TestButton.MouseButton1Click:Connect(function()
    StatusLabel.Text = "Status: Sending..."
    StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    sendToDiscord(
        UrlInput.Text,
        "🔔 Test Notification",
        "If you see this, your Webhook is working correctly!",
        65280 -- Green decimal color
    )
end)

-- Game Logic (Detecting Fish)
local Player = Players.LocalPlayer
local Backpack = Player:WaitForChild("Backpack")

local function onItemAdded(item)
    -- Small wait to ensure properties load
    task.wait(0.5)

    game.StarterGui:SetCore("SendNotification", {
        Title = "Error";
        Text = item.Name;
        Duration = 5;
    })

    -- FILTER: Ignore common items (Customize this list)
    if item.Name == "Fishing Rod" or item.Name == "Bait" then return end

    -- Try to get Rarity
    local rarity = "Unknown"
    if item:FindFirstChild("Rarity") then
        rarity = item.Rarity.Value
    end
    
    -- Send to Discord using the URL currently in the TextBox
    sendToDiscord(
        UrlInput.Text,
        "🎣 Fish Caught!",
        "**Player:** " .. Player.Name .. "\n**Item:** " .. item.Name .. "\n**Rarity:** " .. rarity,
        3447003 -- Blue decimal color
    )
end

Backpack.ChildAdded:Connect(onItemAdded)

-- Cleanup (Optional: Remove old GUI if script runs twice)
for _, v in pairs(CoreGui:GetChildren()) do
    if v.Name == "FishItWebhookGUI" and v ~= ScreenGui then
        v:Destroy()
    end
end
