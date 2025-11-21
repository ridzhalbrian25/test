--[[
    FISH IT! - INVENTORY DIAGNOSTIC TOOL
    Author: Gemini
    
    Instructions:
    1. Execute Script.
    2. Catch ONE fish manually.
    3. Look at the "Diagnostic Log" window.
    4. Screenshot or copy the text to understand how the game stores fish.
]]

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local Backpack = Player:WaitForChild("Backpack")
local PlayerGui = Player:WaitForChild("PlayerGui")

-- [1] GUI SETUP (Log Window)
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ScrollFrame = Instance.new("ScrollingFrame")
local ClearBtn = Instance.new("TextButton")
local CloseBtn = Instance.new("TextButton")
local UIListLayout = Instance.new("UIListLayout")

if syn and syn.protect_gui then syn.protect_gui(ScreenGui) end
ScreenGui.Parent = gethui and gethui() or CoreGui
ScreenGui.Name = "FishDiagnostic"

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Position = UDim2.new(0.6, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 400, 0, 300)
MainFrame.Active = true
MainFrame.Draggable = true

Title.Parent = MainFrame
Title.Size = UDim2.new(1, -60, 0, 25)
Title.BackgroundTransparency = 1
Title.Text = "🕵️ Inventory Diagnostic Log"
Title.TextColor3 = Color3.fromRGB(255, 255, 0)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14

ScrollFrame.Parent = MainFrame
ScrollFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
ScrollFrame.Position = UDim2.new(0, 5, 0, 30)
ScrollFrame.Size = UDim2.new(1, -10, 1, -35)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 10, 0)
ScrollFrame.ScrollBarThickness = 6

UIListLayout.Parent = ScrollFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

CloseBtn.Parent = MainFrame
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Position = UDim2.new(1, -25, 0, 0)
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Text = "X"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextColor3 = Color3.new(1,1,1)

ClearBtn.Parent = MainFrame
ClearBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 200)
ClearBtn.Position = UDim2.new(1, -80, 0, 0)
ClearBtn.Size = UDim2.new(0, 50, 0, 25)
ClearBtn.Text = "CLR"
ClearBtn.Font = Enum.Font.GothamBold
ClearBtn.TextColor3 = Color3.new(1,1,1)

-- [2] LOGGING FUNCTION
local function Log(text, color)
    local label = Instance.new("TextLabel")
    label.Parent = ScrollFrame
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Code
    label.TextSize = 12
    label.Text = text
    label.TextWrapped = true
    -- Auto scroll
    ScrollFrame.CanvasPosition = Vector2.new(0, 99999)
end

local function InspectObject(obj, prefix)
    prefix = prefix or ""
    -- Check Attributes
    local attrs = obj:GetAttributes()
    for name, val in pairs(attrs) do
        Log(prefix .. "[ATTR] " .. name .. ": " .. tostring(val), Color3.fromRGB(255, 170, 255))
    end

    -- Check Children (Values)
    for _, child in pairs(obj:GetChildren()) do
        if child:IsA("ValueBase") then
            Log(prefix .. "[VAL] " .. child.Name .. " ("..child.ClassName.."): " .. tostring(child.Value), Color3.fromRGB(100, 255, 100))
        end
    end
end

-- [3] LISTENERS

-- A. BACKPACK LISTENER
Backpack.ChildAdded:Connect(function(child)
    task.wait(0.2) -- Give it time to load data
    Log("---------------------------", Color3.fromRGB(100,100,100))
    Log("🎒 ADDED TO BACKPACK:", Color3.fromRGB(0, 255, 255))
    Log("Name: " .. child.Name, Color3.fromRGB(255, 255, 255))
    Log("Class: " .. child.ClassName, Color3.fromRGB(255, 255, 255))
    InspectObject(child, "  ")
end)

-- B. PLAYER CHILDREN LISTENER (Custom Folders)
Player.ChildAdded:Connect(function(child)
    if child.Name == "Backpack" or child.Name == "PlayerGui" or child.Name == "PlayerScripts" then return end
    
    task.wait(0.2)
    Log("---------------------------", Color3.fromRGB(100,100,100))
    Log("👤 ADDED TO PLAYER:", Color3.fromRGB(255, 170, 0))
    Log("Name: " .. child.Name .. " [" .. child.ClassName .. "]", Color3.fromRGB(255, 255, 255))
    InspectObject(child, "  ")
end)

-- C. CHARACTER LISTENER (Auto-Equipped Items)
local function ConnectChar(char)
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            task.wait(0.2)
            Log("---------------------------", Color3.fromRGB(100,100,100))
            Log("👕 EQUIPPED (CHARACTER):", Color3.fromRGB(255, 100, 100))
            Log("Name: " .. child.Name, Color3.fromRGB(255, 255, 255))
            InspectObject(child, "  ")
        end
    end)
end

if Player.Character then ConnectChar(Player.Character) end
Player.CharacterAdded:Connect(ConnectChar)

-- [4] BUTTON LOGIC
ClearBtn.MouseButton1Click:Connect(function()
    for _, v in pairs(ScrollFrame:GetChildren()) do
        if v:IsA("TextLabel") then v:Destroy() end
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

Log("Diagnostic Started. Catch a fish now...", Color3.fromRGB(0, 255, 0))
