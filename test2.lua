--[[
    FISH IT! - WAYPOINT & TELEPORT MANAGER
    Author: Gemini
    
    Features:
    1. Real-time Coordinate Display
    2. Save/Load Locations (JSON File Storage)
    3. Teleport to saved spots
    4. Draggable GUI with Minimize/Close
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local FileName = "FishIt_Teleports.json"

-- [1] FILE SYSTEM (STORAGE)
local function LoadData()
    if isfile and isfile(FileName) then
        local content = readfile(FileName)
        local success, decoded = pcall(function() return HttpService:JSONDecode(content) end)
        if success then return decoded end
    end
    return {} -- Return empty table if no file exists
end

local function SaveData(data)
    if writefile then
        local encoded = HttpService:JSONEncode(data)
        writefile(FileName, encoded)
    end
end

-- Initialize Data
local SavedLocations = LoadData()

-- [2] GUI SETUP
-- Cleanup old GUI
for _, v in pairs(CoreGui:GetChildren()) do
    if v.Name == "FishItTeleportGUI" then v:Destroy() end
end

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TopBar = Instance.new("Frame")
local TitleLabel = Instance.new("TextLabel")
local CloseBtn = Instance.new("TextButton")
local MinBtn = Instance.new("TextButton")
local ContentFrame = Instance.new("Frame")

-- Elements
local CoordsLabel = Instance.new("TextLabel")
local NameInput = Instance.new("TextBox")
local SaveButton = Instance.new("TextButton")
local ScrollFrame = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")
local OpenBtn = Instance.new("TextButton") -- Minimized button

if syn and syn.protect_gui then syn.protect_gui(ScreenGui) end
ScreenGui.Parent = gethui and gethui() or CoreGui
ScreenGui.Name = "FishItTeleportGUI"

-- Main Window Styling
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.7, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 250, 0, 350)
MainFrame.Active = true
MainFrame.Draggable = true

TopBar.Name = "TopBar"
TopBar.Parent = MainFrame
TopBar.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
TopBar.BorderSizePixel = 0
TopBar.Size = UDim2.new(1, 0, 0, 30)

TitleLabel.Parent = TopBar
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.Size = UDim2.new(0.6, 0, 1, 0)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "📍 Teleport Manager"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 14
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Control Buttons
CloseBtn.Parent = TopBar
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
CloseBtn.BorderSizePixel = 0
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1,1,1)

MinBtn.Parent = TopBar
MinBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
MinBtn.BorderSizePixel = 0
MinBtn.Position = UDim2.new(1, -60, 0, 0)
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.new(1,1,1)

-- Content Area
ContentFrame.Parent = MainFrame
ContentFrame.BackgroundTransparency = 1
ContentFrame.Position = UDim2.new(0, 10, 0, 40)
ContentFrame.Size = UDim2.new(1, -20, 1, -50)

-- 1. Realtime Coords
CoordsLabel.Parent = ContentFrame
CoordsLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
CoordsLabel.Size = UDim2.new(1, 0, 0, 25)
CoordsLabel.Font = Enum.Font.Code
CoordsLabel.Text = "X: 0, Y: 0, Z: 0"
CoordsLabel.TextColor3 = Color3.fromRGB(0, 255, 200)
CoordsLabel.TextSize = 12

-- 2. Input
NameInput.Parent = ContentFrame
NameInput.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
NameInput.BorderSizePixel = 0
NameInput.Position = UDim2.new(0, 0, 0, 35)
NameInput.Size = UDim2.new(0.7, 0, 0, 30)
NameInput.Font = Enum.Font.Gotham
NameInput.PlaceholderText = "Location Name..."
NameInput.Text = ""
NameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
NameInput.TextSize = 12

-- 3. Save Button
SaveButton.Parent = ContentFrame
SaveButton.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
SaveButton.BorderSizePixel = 0
SaveButton.Position = UDim2.new(0.72, 0, 0, 35)
SaveButton.Size = UDim2.new(0.28, 0, 0, 30)
SaveButton.Font = Enum.Font.GothamBold
SaveButton.Text = "SAVE"
SaveButton.TextColor3 = Color3.new(1,1,1)
SaveButton.TextSize = 11

-- 4. List
ScrollFrame.Parent = ContentFrame
ScrollFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ScrollFrame.BorderSizePixel = 0
ScrollFrame.Position = UDim2.new(0, 0, 0, 75)
ScrollFrame.Size = UDim2.new(1, 0, 1, -75)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.ScrollBarThickness = 4

UIListLayout.Parent = ScrollFrame
UIListLayout.SortOrder = Enum.SortOrder.Name
UIListLayout.Padding = UDim.new(0, 5)

-- Minimized Button
OpenBtn.Name = "OpenTeleport"
OpenBtn.Parent = ScreenGui
OpenBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
OpenBtn.Position = UDim2.new(0, 125, 0.9, -40)
OpenBtn.Size = UDim2.new(0, 100, 0, 30)
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.Text = "Teleports"
OpenBtn.TextColor3 = Color3.new(1,1,1)
OpenBtn.Visible = false

-- [3] LOGIC FUNCTIONS

-- Update Coordinate Display Loop
local CoordsConnection = RunService.RenderStepped:Connect(function()
    if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        local pos = Player.Character.HumanoidRootPart.Position
        CoordsLabel.Text = string.format("X: %.0f, Y: %.0f, Z: %.0f", pos.X, pos.Y, pos.Z)
    end
end)

-- Refresh the List in the GUI
local function RefreshList()
    -- Clear old buttons
    for _, v in pairs(ScrollFrame:GetChildren()) do
        if v:IsA("Frame") then v:Destroy() end
    end
    
    local count = 0
    for name, posData in pairs(SavedLocations) do
        count = count + 1
        
        local entry = Instance.new("Frame")
        entry.Parent = ScrollFrame
        entry.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        entry.BorderSizePixel = 0
        entry.Size = UDim2.new(1, -5, 0, 30)
        entry.Name = name -- For sorting
        
        local nameLbl = Instance.new("TextLabel")
        nameLbl.Parent = entry
        nameLbl.BackgroundTransparency = 1
        nameLbl.Position = UDim2.new(0, 5, 0, 0)
        nameLbl.Size = UDim2.new(0.6, 0, 1, 0)
        nameLbl.Font = Enum.Font.Gotham
        nameLbl.Text = name
        nameLbl.TextColor3 = Color3.new(1,1,1)
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left
        nameLbl.TextSize = 12
        
        local tpBtn = Instance.new("TextButton")
        tpBtn.Parent = entry
        tpBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
        tpBtn.Position = UDim2.new(0.65, 0, 0.1, 0)
        tpBtn.Size = UDim2.new(0.2, 0, 0.8, 0)
        tpBtn.Text = "TP"
        tpBtn.TextColor3 = Color3.new(1,1,1)
        tpBtn.Font = Enum.Font.GothamBold
        tpBtn.TextSize = 11
        
        local delBtn = Instance.new("TextButton")
        delBtn.Parent = entry
        delBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        delBtn.Position = UDim2.new(0.87, 0, 0.1, 0)
        delBtn.Size = UDim2.new(0.1, 0, 0.8, 0)
        delBtn.Text = "X"
        delBtn.TextColor3 = Color3.new(1,1,1)
        delBtn.Font = Enum.Font.GothamBold
        
        -- Teleport Logic
        tpBtn.MouseButton1Click:Connect(function()
            if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                -- posData is {x, y, z}
                local targetCFrame = CFrame.new(posData[1], posData[2], posData[3])
                Player.Character.HumanoidRootPart.CFrame = targetCFrame
            end
        end)
        
        -- Delete Logic
        delBtn.MouseButton1Click:Connect(function()
            SavedLocations[name] = nil
            SaveData(SavedLocations)
            RefreshList()
        end)
    end
    
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, count * 35)
end

-- Save Current Position
SaveButton.MouseButton1Click:Connect(function()
    local name = NameInput.Text
    if name == "" then return end
    if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local pos = Player.Character.HumanoidRootPart.Position
    
    -- Save as a table {x, y, z} because JSON cant save Vector3
    SavedLocations[name] = {pos.X, pos.Y, pos.Z}
    
    SaveData(SavedLocations)
    RefreshList()
    NameInput.Text = "" -- Clear input
end)

-- [4] BUTTON ACTIONS

MinBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    OpenBtn.Visible = true
end)

OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    OpenBtn.Visible = false
end)

CloseBtn.MouseButton1Click:Connect(function()
    if CoordsConnection then CoordsConnection:Disconnect() end
    ScreenGui:Destroy()
end)

-- Initial Load
RefreshList()
