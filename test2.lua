--[[
    FISH IT! - COMPACT GLASS MANAGER (V2.1)
    Author: Gemini
    
    Updates:
    - Reduced Height (300px default)
    - Auto-Resizing List (Stretches to fit window)
    - Cleaned up spacing
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local PlaceID = tostring(game.PlaceId)
local FileName = "FishIt_Teleports_V2.json"

-- [1] DATA MANAGEMENT
local GlobalData = {} 
local CurrentList = {}

local function SaveData()
    if writefile then
        GlobalData[PlaceID] = CurrentList
        local encoded = HttpService:JSONEncode(GlobalData)
        writefile(FileName, encoded)
    end
end

local function LoadData()
    if isfile and isfile(FileName) then
        local content = readfile(FileName)
        local success, decoded = pcall(function() return HttpService:JSONDecode(content) end)
        if success then 
            GlobalData = decoded
            CurrentList = GlobalData[PlaceID] or {}
        end
    end
end

LoadData()

-- [2] GUI SETUP
for _, v in pairs(CoreGui:GetChildren()) do
    if v.Name == "FishItGlassCompact" then v:Destroy() end
end

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TopBar = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local MinBtn = Instance.new("TextButton")
local CloseBtn = Instance.new("TextButton")
local Content = Instance.new("Frame") -- Container for everything below header
local OpenBtn = Instance.new("TextButton")

if syn and syn.protect_gui then syn.protect_gui(ScreenGui) end
ScreenGui.Parent = gethui and gethui() or CoreGui
ScreenGui.Name = "FishItGlassCompact"

-- --> UTILITY <--
local function MakeGlass(instance, cornerRadius, strokeColor, bgTransparency)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, cornerRadius or 6)
    corner.Parent = instance
    
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = strokeColor or Color3.fromRGB(100, 120, 150)
    stroke.Transparency = 0.6
    stroke.Parent = instance

    instance.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    instance.BackgroundTransparency = bgTransparency or 0.2
    instance.BorderSizePixel = 0
end

-- Main Window (Smaller Height)
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.Position = UDim2.new(0.7, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 260, 0, 300) -- Reduced from 460 to 300
MainFrame.Active = true
MainFrame.Draggable = true
MakeGlass(MainFrame, 8, Color3.fromRGB(0, 150, 200), 0.15)

-- Top Bar
TopBar.Parent = MainFrame
TopBar.Size = UDim2.new(1, 0, 0, 25) -- Thinner header
MakeGlass(TopBar, 8, nil, 0.5)
TopBar.UICorner:Destroy()
local TopCorner = Instance.new("UICorner", TopBar); TopCorner.CornerRadius = UDim.new(0, 8)
local TopCover = Instance.new("Frame", TopBar); TopCover.Size = UDim2.new(1,0,0,5); TopCover.Position = UDim2.new(0,0,1,-5); TopCover.BackgroundTransparency = 1

Title.Parent = TopBar
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Size = UDim2.new(0.6, 0, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "💎 Path Manager"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextSize = 12
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Controls
CloseBtn.Parent = TopBar
CloseBtn.Position = UDim2.new(1, -25, 0, 0)
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.BackgroundTransparency = 1

MinBtn.Parent = TopBar
MinBtn.Position = UDim2.new(1, -50, 0, 0)
MinBtn.Size = UDim2.new(0, 25, 0, 25)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.new(1,1,1)
MinBtn.BackgroundTransparency = 1

-- Content Container (Fills rest of frame)
Content.Parent = MainFrame
Content.BackgroundTransparency = 1
Content.Position = UDim2.new(0, 5, 0, 30)
Content.Size = UDim2.new(1, -10, 1, -35)

-- 1. INPUTS SECTION (Top)
local InputFrame = Instance.new("Frame", Content)
InputFrame.Size = UDim2.new(1, 0, 0, 55)
InputFrame.BackgroundTransparency = 1

local CoordsLbl = Instance.new("TextLabel", InputFrame)
CoordsLbl.Size = UDim2.new(1,0,0,15)
CoordsLbl.BackgroundTransparency = 1
CoordsLbl.TextColor3 = Color3.fromRGB(0, 255, 200)
CoordsLbl.Font = Enum.Font.Code
CoordsLbl.Text = "X:0 Y:0 Z:0"
CoordsLbl.TextSize = 10

local NameBox = Instance.new("TextBox", InputFrame)
NameBox.Position = UDim2.new(0,0,0,20)
NameBox.Size = UDim2.new(0.65, 0, 0, 25)
NameBox.TextColor3 = Color3.new(1,1,1)
NameBox.PlaceholderText = "Location Name"
NameBox.Font = Enum.Font.Gotham
NameBox.TextSize = 11
MakeGlass(NameBox, 4, nil, 0.5)

local SaveBtn = Instance.new("TextButton", InputFrame)
SaveBtn.Position = UDim2.new(0.68,0,0,20)
SaveBtn.Size = UDim2.new(0.32, 0, 0, 25)
SaveBtn.Text = "ADD"
SaveBtn.Font = Enum.Font.GothamBold
SaveBtn.TextColor3 = Color3.new(1,1,1)
SaveBtn.TextSize = 10
MakeGlass(SaveBtn, 4, Color3.fromRGB(0, 255, 150), 0.4)

-- 3. BOTTOM CONTROLS (Anchored Bottom)
local BottomFrame = Instance.new("Frame", Content)
BottomFrame.Size = UDim2.new(1, 0, 0, 50)
BottomFrame.Position = UDim2.new(0, 0, 1, -50)
BottomFrame.BackgroundTransparency = 1

local Divider = Instance.new("Frame", BottomFrame)
Divider.Size = UDim2.new(1,0,0,1)
Divider.BackgroundColor3 = Color3.fromRGB(100,120,150)
Divider.BackgroundTransparency = 0.7
Divider.BorderSizePixel = 0

local DelayInput = Instance.new("TextBox", BottomFrame)
DelayInput.Position = UDim2.new(0, 0, 0.2, 0)
DelayInput.Size = UDim2.new(0.25, 0, 0, 25)
DelayInput.TextColor3 = Color3.new(1,1,1)
DelayInput.Text = "5s"
DelayInput.Font = Enum.Font.Gotham
DelayInput.TextSize = 11
MakeGlass(DelayInput, 4, nil, 0.5)

local LoopBtn = Instance.new("TextButton", BottomFrame)
LoopBtn.Position = UDim2.new(0.3, 0, 0.2, 0)
LoopBtn.Size = UDim2.new(0.7, 0, 0, 25)
LoopBtn.Text = "START LOOP"
LoopBtn.Font = Enum.Font.GothamBold
LoopBtn.TextColor3 = Color3.new(1,1,1)
LoopBtn.TextSize = 10
MakeGlass(LoopBtn, 4, Color3.fromRGB(0, 150, 255), 0.4)

local StatusLbl = Instance.new("TextLabel", BottomFrame)
StatusLbl.Position = UDim2.new(0,0,0.8,0)
StatusLbl.Size = UDim2.new(1,0,0,10)
StatusLbl.BackgroundTransparency = 1
StatusLbl.TextColor3 = Color3.fromRGB(150,150,150)
StatusLbl.Font = Enum.Font.Gotham
StatusLbl.Text = "Map ID: " .. PlaceID
StatusLbl.TextSize = 9

-- 2. LIST (Middle - Stretches automatically)
local ScrollFrameBg = Instance.new("Frame", Content) 
ScrollFrameBg.Position = UDim2.new(0,0,0,60) -- Starts after Inputs
ScrollFrameBg.Size = UDim2.new(1,0,1, -115) -- Height = Total - (Inputs + Bottom)
MakeGlass(ScrollFrameBg, 4, nil, 0.7)

local Scroll = Instance.new("ScrollingFrame", ScrollFrameBg)
Scroll.Size = UDim2.new(1,0,1,0)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 2
Scroll.ScrollBarImageColor3 = Color3.fromRGB(100, 200, 255)

local ListLayout = Instance.new("UIListLayout", Scroll)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0, 3)
local ListPadding = Instance.new("UIPadding", Scroll)
ListPadding.PaddingTop = UDim.new(0,3); ListPadding.PaddingLeft = UDim.new(0,3)

-- Restore Button
OpenBtn.Parent = ScreenGui
OpenBtn.Position = UDim2.new(0, 10, 0.9, -30)
OpenBtn.Size = UDim2.new(0, 80, 0, 25)
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.Text = "💎 Show"
OpenBtn.TextColor3 = Color3.new(1,1,1)
OpenBtn.Visible = false
MakeGlass(OpenBtn, 6, Color3.fromRGB(0, 150, 255), 0.3)

-- [3] LOGIC

local function MoveItem(index, direction)
    local newIndex = index + direction
    if newIndex < 1 or newIndex > #CurrentList then return end
    CurrentList[newIndex], CurrentList[index] = CurrentList[index], CurrentList[newIndex]
    SaveData()
    RefreshUI()
end

local function DeleteItem(index)
    table.remove(CurrentList, index)
    SaveData()
    RefreshUI()
end

function RefreshUI()
    for _, v in pairs(Scroll:GetChildren()) do
        if v:IsA("Frame") then v:Destroy() end
    end

    for i, data in ipairs(CurrentList) do
        local item = Instance.new("Frame", Scroll)
        item.Size = UDim2.new(1, -6, 0, 22) -- Compact item height
        item.LayoutOrder = i
        MakeGlass(item, 4, nil, 0.6) 

        local lbl = Instance.new("TextLabel", item)
        lbl.Size = UDim2.new(0.4, 0, 1, 0)
        lbl.Position = UDim2.new(0, 5, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = Color3.new(1,1,1)
        lbl.Text = i .. ". " .. data.Name
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 10
        lbl.TextTruncate = Enum.TextTruncate.AtEnd

        local function MakeSmallBtn(text, xPos, w, col)
            local btn = Instance.new("TextButton", item)
            btn.Size = UDim2.new(0, w, 0, 18)
            btn.Position = UDim2.new(0, xPos, 0.5, -9)
            btn.Text = text
            btn.TextColor3 = Color3.new(1,1,1)
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 9
            MakeGlass(btn, 3, col, 0.5)
            if col then btn.BackgroundColor3 = col end
            return btn
        end

        -- Adjusted positions for compact width
        local upBtn = MakeSmallBtn("▲", 120, 18)
        local dwnBtn = MakeSmallBtn("▼", 140, 18)
        local tpBtn = MakeSmallBtn("TP", 165, 35, Color3.fromRGB(0, 100, 180))
        local delBtn = MakeSmallBtn("X", 205, 18, Color3.fromRGB(180, 50, 50))
        
        upBtn.MouseButton1Click:Connect(function() MoveItem(i, -1) end)
        dwnBtn.MouseButton1Click:Connect(function() MoveItem(i, 1) end)
        delBtn.MouseButton1Click:Connect(function() DeleteItem(i) end)
        tpBtn.MouseButton1Click:Connect(function()
            if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                Player.Character.HumanoidRootPart.CFrame = CFrame.new(unpack(data.Pos))
            end
        end)
    end
    Scroll.CanvasSize = UDim2.new(0, 0, 0, #CurrentList * 26)
end

SaveBtn.MouseButton1Click:Connect(function()
    local name = NameBox.Text
    if name ~= "" and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        local p = Player.Character.HumanoidRootPart.Position
        table.insert(CurrentList, {Name = name, Pos = {p.X, p.Y, p.Z}})
        SaveData()
        RefreshUI()
        NameBox.Text = ""
    end
end)

local LoopRunning = false
LoopBtn.MouseButton1Click:Connect(function()
    if LoopRunning then
        LoopRunning = false
        LoopBtn.Text = "START LOOP"
        LoopBtn.UIStroke.Color = Color3.fromRGB(0, 150, 255)
        StatusLbl.Text = "Status: Idle"
        return
    end
    if #CurrentList == 0 then return end
    LoopRunning = true
    LoopBtn.Text = "STOP LOOP"
    LoopBtn.UIStroke.Color = Color3.fromRGB(255, 50, 50)

    task.spawn(function()
        while LoopRunning do
            for i, data in ipairs(CurrentList) do
                if not LoopRunning then break end
                if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                    StatusLbl.Text = "Moving to: " .. data.Name
                    Player.Character.HumanoidRootPart.CFrame = CFrame.new(unpack(data.Pos))
                    
                    -- Extract number from "5s" string
                    local dTime = tonumber(DelayInput.Text:match("%d+")) or 5
                    task.wait(dTime)
                end
            end
            task.wait(0.1)
        end
    end)
end)

local RunConn = RunService.RenderStepped:Connect(function()
    if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        local p = Player.Character.HumanoidRootPart.Position
        CoordsLbl.Text = string.format("X:%.0f  Y:%.0f  Z:%.0f", p.X, p.Y, p.Z)
    end
end)

MinBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; OpenBtn.Visible = true end)
OpenBtn.MouseButton1Click:Connect(function() MainFrame.Visible = true; OpenBtn.Visible = false end)
CloseBtn.MouseButton1Click:Connect(function()
    LoopRunning = false
    if RunConn then RunConn:Disconnect() end
    ScreenGui:Destroy()
end)

RefreshUI()
