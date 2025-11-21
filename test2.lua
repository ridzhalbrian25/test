--[[
    FISH IT! - TELEPORT LOOP MANAGER
    Author: Gemini
    
    Features:
    1. Save/Load Coordinates.
    2. Auto-Teleport Loop (Pathing).
    3. Custom Delay between teleports.
    4. Draggable GUI.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local FileName = "FishIt_Teleports.json"

-- [1] DATA MANAGEMENT
local SavedLocations = {}

local function LoadData()
    if isfile and isfile(FileName) then
        local content = readfile(FileName)
        local success, decoded = pcall(function() return HttpService:JSONDecode(content) end)
        if success then SavedLocations = decoded end
    end
end

local function SaveData()
    if writefile then
        local encoded = HttpService:JSONEncode(SavedLocations)
        writefile(FileName, encoded)
    end
end

LoadData()

-- [2] GUI CREATION
for _, v in pairs(CoreGui:GetChildren()) do
    if v.Name == "FishItTeleportLoop" then v:Destroy() end
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
ScreenGui.Name = "FishItTeleportLoop"

-- Main Style
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.7, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 260, 0, 400) -- Taller for new controls
MainFrame.Active = true
MainFrame.Draggable = true

TopBar.Parent = MainFrame
TopBar.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.BorderSizePixel = 0

Title.Parent = TopBar
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Size = UDim2.new(0.6, 0, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "📍 Teleport Pathing"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Window Controls
CloseBtn.Parent = TopBar
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1,1,1)

MinBtn.Parent = TopBar
MinBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
MinBtn.Position = UDim2.new(1, -60, 0, 0)
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.new(1,1,1)

Content.Parent = MainFrame
Content.BackgroundTransparency = 1
Content.Position = UDim2.new(0, 10, 0, 40)
Content.Size = UDim2.new(1, -20, 1, -50)

-- INPUTS
local CoordsLbl = Instance.new("TextLabel", Content)
CoordsLbl.Size = UDim2.new(1,0,0,20)
CoordsLbl.BackgroundTransparency = 1
CoordsLbl.TextColor3 = Color3.fromRGB(0, 255, 200)
CoordsLbl.Font = Enum.Font.Code
CoordsLbl.Text = "X:0 Y:0 Z:0"
CoordsLbl.TextSize = 12

local NameBox = Instance.new("TextBox", Content)
NameBox.Position = UDim2.new(0,0,0,25)
NameBox.Size = UDim2.new(0.65, 0, 0, 30)
NameBox.BackgroundColor3 = Color3.fromRGB(50,50,55)
NameBox.TextColor3 = Color3.new(1,1,1)
NameBox.PlaceholderText = "Name (e.g. '1. Lake')"
NameBox.Font = Enum.Font.Gotham
NameBox.TextSize = 12

local SaveBtn = Instance.new("TextButton", Content)
SaveBtn.Position = UDim2.new(0.7,0,0,25)
SaveBtn.Size = UDim2.new(0.3, 0, 0, 30)
SaveBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 100)
SaveBtn.Text = "SAVE"
SaveBtn.Font = Enum.Font.GothamBold
SaveBtn.TextColor3 = Color3.new(1,1,1)
SaveBtn.TextSize = 11

-- LOCATION LIST
local Scroll = Instance.new("ScrollingFrame", Content)
Scroll.Position = UDim2.new(0,0,0,65)
Scroll.Size = UDim2.new(1,0,0,180)
Scroll.BackgroundColor3 = Color3.fromRGB(30,30,35)
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 4

local ListLayout = Instance.new("UIListLayout", Scroll)
ListLayout.SortOrder = Enum.SortOrder.Name
ListLayout.Padding = UDim.new(0, 4)

-- LOOP CONTROLS (New Section)
local Divider = Instance.new("Frame", Content)
Divider.Position = UDim2.new(0,0,0,255)
Divider.Size = UDim2.new(1,0,0,2)
Divider.BackgroundColor3 = Color3.fromRGB(50,50,60)
Divider.BorderSizePixel = 0

local DelayLbl = Instance.new("TextLabel", Content)
DelayLbl.Position = UDim2.new(0,0,0,265)
DelayLbl.Size = UDim2.new(0.4, 0, 0, 25)
DelayLbl.BackgroundTransparency = 1
DelayLbl.TextColor3 = Color3.new(1,1,1)
DelayLbl.Text = "Delay (Sec):"
DelayLbl.Font = Enum.Font.Gotham
DelayLbl.TextXAlignment = Enum.TextXAlignment.Left
DelayLbl.TextSize = 12

local DelayInput = Instance.new("TextBox", Content)
DelayInput.Position = UDim2.new(0.4, 0, 0, 265)
DelayInput.Size = UDim2.new(0.2, 0, 0, 25)
DelayInput.BackgroundColor3 = Color3.fromRGB(50,50,55)
DelayInput.TextColor3 = Color3.new(1,1,1)
DelayInput.Text = "5" -- Default delay
DelayInput.Font = Enum.Font.Gotham

local LoopBtn = Instance.new("TextButton", Content)
LoopBtn.Position = UDim2.new(0.65, 0, 0, 260)
LoopBtn.Size = UDim2.new(0.35, 0, 0, 35)
LoopBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
LoopBtn.Text = "START LOOP"
LoopBtn.Font = Enum.Font.GothamBold
LoopBtn.TextColor3 = Color3.new(1,1,1)
LoopBtn.TextSize = 10

local StatusLbl = Instance.new("TextLabel", Content)
StatusLbl.Position = UDim2.new(0,0,0,300)
StatusLbl.Size = UDim2.new(1,0,0,20)
StatusLbl.BackgroundTransparency = 1
StatusLbl.TextColor3 = Color3.fromRGB(150,150,150)
StatusLbl.Font = Enum.Font.Gotham
StatusLbl.Text = "Status: Idle"
StatusLbl.TextSize = 11

-- Restore Button
OpenBtn.Parent = ScreenGui
OpenBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
OpenBtn.Position = UDim2.new(0, 10, 0.9, -40)
OpenBtn.Size = UDim2.new(0, 100, 0, 30)
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.Text = "Teleporter"
OpenBtn.TextColor3 = Color3.new(1,1,1)
OpenBtn.Visible = false

-- [3] FUNCTIONS & LOGIC

-- 1. Refresh List
local function UpdateList()
    for _, v in pairs(Scroll:GetChildren()) do
        if v:IsA("Frame") then v:Destroy() end
    end

    local count = 0
    for name, pos in pairs(SavedLocations) do
        count = count + 1
        local item = Instance.new("Frame", Scroll)
        item.Size = UDim2.new(1, -5, 0, 25)
        item.BackgroundColor3 = Color3.fromRGB(45,45,50)
        item.Name = name -- Sorts by this name

        local lbl = Instance.new("TextLabel", item)
        lbl.Size = UDim2.new(0.65, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = Color3.new(1,1,1)
        lbl.Text = "  " .. name
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 12

        local tp = Instance.new("TextButton", item)
        tp.Size = UDim2.new(0.2, 0, 1, 0)
        tp.Position = UDim2.new(0.65, 0, 0, 0)
        tp.BackgroundColor3 = Color3.fromRGB(60,60,70)
        tp.Text = "TP"
        tp.TextColor3 = Color3.new(1,1,1)
        tp.Font = Enum.Font.GothamBold

        local del = Instance.new("TextButton", item)
        del.Size = UDim2.new(0.15, 0, 1, 0)
        del.Position = UDim2.new(0.85, 0, 0, 0)
        del.BackgroundColor3 = Color3.fromRGB(200,60,60)
        del.Text = "X"
        del.TextColor3 = Color3.new(1,1,1)
        del.Font = Enum.Font.GothamBold

        -- Single TP
        tp.MouseButton1Click:Connect(function()
            if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                Player.Character.HumanoidRootPart.CFrame = CFrame.new(unpack(pos))
            end
        end)

        -- Delete
        del.MouseButton1Click:Connect(function()
            SavedLocations[name] = nil
            SaveData()
            UpdateList()
        end)
    end
    Scroll.CanvasSize = UDim2.new(0, 0, 0, count * 29)
end

-- 2. Loop Logic
local LoopRunning = false

local function StartLoop()
    if LoopRunning then
        -- Stop Logic
        LoopRunning = false
        LoopBtn.Text = "START LOOP"
        LoopBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
        StatusLbl.Text = "Status: Stopped"
        return
    end

    -- Start Logic
    LoopRunning = true
    LoopBtn.Text = "STOP LOOP"
    LoopBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)

    task.spawn(function()
        while LoopRunning do
            -- Get children in order (Sorted by Name because of UIListLayout)
            local items = Scroll:GetChildren()
            
            -- Filter only frames and sort manually to ensure order matches visual
            local sortedItems = {}
            for _, v in pairs(items) do
                if v:IsA("Frame") then
                    table.insert(sortedItems, v)
                end
            end
            
            -- Sort alphabetical (same as UI List)
            table.sort(sortedItems, function(a,b) return a.Name < b.Name end)

            if #sortedItems == 0 then
                StatusLbl.Text = "Status: No locations saved!"
                LoopRunning = false
                break
            end

            for _, itemFrame in ipairs(sortedItems) do
                if not LoopRunning then break end

                local locName = itemFrame.Name
                local coords = SavedLocations[locName]

                if coords and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                    StatusLbl.Text = "Going to: " .. locName
                    StatusLbl.TextColor3 = Color3.fromRGB(0, 255, 100)
                    
                    -- Teleport
                    Player.Character.HumanoidRootPart.CFrame = CFrame.new(unpack(coords))
                    
                    -- Wait Delay
                    local delayTime = tonumber(DelayInput.Text) or 5
                    task.wait(delayTime)
                end
            end
            
            -- Safety wait if list is empty/broken to prevent crash
            task.wait(0.1)
        end
        -- Reset UI when loop breaks
        LoopBtn.Text = "START LOOP"
        LoopBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
    end)
end

-- [4] CONNECTIONS

-- Save Button
SaveBtn.MouseButton1Click:Connect(function()
    local name = NameBox.Text
    if name ~= "" and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        local pos = Player.Character.HumanoidRootPart.Position
        SavedLocations[name] = {pos.X, pos.Y, pos.Z}
        SaveData()
        UpdateList()
        NameBox.Text = ""
    end
end)

-- Coords Updater
local RunConn = RunService.RenderStepped:Connect(function()
    if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        local p = Player.Character.HumanoidRootPart.Position
        CoordsLbl.Text = string.format("X:%.0f  Y:%.0f  Z:%.0f", p.X, p.Y, p.Z)
    end
end)

LoopBtn.MouseButton1Click:Connect(StartLoop)

-- Window Buttons
MinBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; OpenBtn.Visible = true end)
OpenBtn.MouseButton1Click:Connect(function() MainFrame.Visible = true; OpenBtn.Visible = false end)
CloseBtn.MouseButton1Click:Connect(function()
    LoopRunning = false
    if RunConn then RunConn:Disconnect() end
    ScreenGui:Destroy()
end)

-- Init
UpdateList()
