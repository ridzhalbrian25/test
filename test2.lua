--[[
    FISH IT! - GLASSY TELEPORT MANAGER (V2 RE-SKIN)
    Author: Gemini
    
    Style: Glassmorphism (Transparent, Dark, Rounded, Subtle Strokes)
    Features: Same V2 features (Reorder, Map-Specific, Loop)
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local PlaceID = tostring(game.PlaceId)
local FileName = "FishIt_Teleports_V2.json"

-- [1] DATA MANAGEMENT (Unchanged from V2)
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

-- [2] GUI SETUP (Glass Style)
for _, v in pairs(CoreGui:GetChildren()) do
    if v.Name == "FishItGlassGui" then v:Destroy() end
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
ScreenGui.Name = "FishItGlassGui"

-- --> UTILITY FOR GLASS STYLING <--
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
    instance.BackgroundTransparency = bgTransparency or 0.3
    instance.BorderSizePixel = 0
end

-- Main Window
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.Position = UDim2.new(0.7, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 280, 0, 460)
MainFrame.Active = true
MainFrame.Draggable = true
MakeGlass(MainFrame, 8, Color3.fromRGB(0, 150, 200), 0.2)

-- Top Bar
TopBar.Parent = MainFrame
TopBar.Size = UDim2.new(1, 0, 0, 30)
MakeGlass(TopBar, 8, nil, 0.5)
-- Remove bottom corners for top bar to blend
TopBar.UICorner:Destroy()
local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 8)
TopCorner.Parent = TopBar
local TopCover = Instance.new("Frame") -- Covers bottom rounded corners
TopCover.Size = UDim2.new(1, 0, 0, 5)
TopCover.Position = UDim2.new(0, 0, 1, -5)
TopCover.BackgroundColor3 = TopBar.BackgroundColor3
TopCover.BackgroundTransparency = TopBar.BackgroundTransparency
TopCover.BorderSizePixel = 0
TopCover.Parent = TopBar

Title.Parent = TopBar
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Size = UDim2.new(0.6, 0, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "💎 Glass Pathfinder"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Controls
CloseBtn.Parent = TopBar
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1,1,1)
MakeGlass(CloseBtn, 8, Color3.fromRGB(200, 50, 50), 0.5)

MinBtn.Parent = TopBar
MinBtn.Position = UDim2.new(1, -60, 0, 0)
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.new(1,1,1)
MakeGlass(MinBtn, 8, nil, 0.5)

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
Instance.new("UIStroke", CoordsLbl).Thickness = 1; CoordsLbl.UIStroke.Transparency = 0.8; CoordsLbl.UIStroke.Color = CoordsLbl.TextColor3

local NameBox = Instance.new("TextBox", Content)
NameBox.Position = UDim2.new(0,0,0,25)
NameBox.Size = UDim2.new(0.65, 0, 0, 30)
NameBox.TextColor3 = Color3.new(1,1,1)
NameBox.PlaceholderText = "Location Name"
NameBox.Font = Enum.Font.Gotham
NameBox.TextSize = 12
MakeGlass(NameBox, 6, nil, 0.5)

local SaveBtn = Instance.new("TextButton", Content)
SaveBtn.Position = UDim2.new(0.7,0,0,25)
SaveBtn.Size = UDim2.new(0.3, 0, 0, 30)
SaveBtn.Text = "ADD"
SaveBtn.Font = Enum.Font.GothamBold
SaveBtn.TextColor3 = Color3.new(1,1,1)
SaveBtn.TextSize = 11
MakeGlass(SaveBtn, 6, Color3.fromRGB(0, 255, 150), 0.4)
SaveBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 80) -- Slight tint

-- LIST
local ScrollFrameBg = Instance.new("Frame", Content) -- Background for scroll
ScrollFrameBg.Position = UDim2.new(0,0,0,65)
ScrollFrameBg.Size = UDim2.new(1,0,0,230)
MakeGlass(ScrollFrameBg, 6, nil, 0.6)

local Scroll = Instance.new("ScrollingFrame", ScrollFrameBg)
Scroll.Size = UDim2.new(1,0,1,0)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 4
Scroll.ScrollBarImageColor3 = Color3.fromRGB(100, 150, 200)

local ListLayout = Instance.new("UIListLayout", Scroll)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0, 4)
local ListPadding = Instance.new("UIPadding", Scroll)
ListPadding.PaddingTop = UDim.new(0,5); ListPadding.PaddingLeft = UDim.new(0,5)

-- LOOP CONTROLS
local Divider = Instance.new("Frame", Content)
Divider.Position = UDim2.new(0,0,0,310)
Divider.Size = UDim2.new(1,0,0,1)
MakeGlass(Divider, 0, nil, 0.8)

local DelayLbl = Instance.new("TextLabel", Content)
DelayLbl.Position = UDim2.new(0,0,0,325)
DelayLbl.Size = UDim2.new(0.4, 0, 0, 25)
DelayLbl.BackgroundTransparency = 1
DelayLbl.TextColor3 = Color3.new(1,1,1)
DelayLbl.Text = "Delay (Sec):"
DelayLbl.Font = Enum.Font.Gotham
DelayLbl.TextXAlignment = Enum.TextXAlignment.Left
DelayLbl.TextSize = 12

local DelayInput = Instance.new("TextBox", Content)
DelayInput.Position = UDim2.new(0.4, 0, 0, 325)
DelayInput.Size = UDim2.new(0.2, 0, 0, 25)
DelayInput.TextColor3 = Color3.new(1,1,1)
DelayInput.Text = "5"
DelayInput.Font = Enum.Font.Gotham
MakeGlass(DelayInput, 6, nil, 0.5)

local LoopBtn = Instance.new("TextButton", Content)
LoopBtn.Position = UDim2.new(0.65, 0, 0, 320)
LoopBtn.Size = UDim2.new(0.35, 0, 0, 35)
LoopBtn.Text = "START LOOP"
LoopBtn.Font = Enum.Font.GothamBold
LoopBtn.TextColor3 = Color3.new(1,1,1)
LoopBtn.TextSize = 10
MakeGlass(LoopBtn, 6, Color3.fromRGB(0, 150, 255), 0.4)
LoopBtn.BackgroundColor3 = Color3.fromRGB(0, 60, 120)

local StatusLbl = Instance.new("TextLabel", Content)
StatusLbl.Position = UDim2.new(0,0,0,370)
StatusLbl.Size = UDim2.new(1,0,0,20)
StatusLbl.BackgroundTransparency = 1
StatusLbl.TextColor3 = Color3.fromRGB(150,150,150)
StatusLbl.Font = Enum.Font.Gotham
StatusLbl.Text = "Map ID: " .. PlaceID
StatusLbl.TextSize = 10
Instance.new("UIStroke", StatusLbl).Thickness = 1; StatusLbl.UIStroke.Transparency = 0.8; StatusLbl.UIStroke.Color = StatusLbl.TextColor3

-- Restore Button
OpenBtn.Parent = ScreenGui
OpenBtn.Position = UDim2.new(0, 10, 0.9, -40)
OpenBtn.Size = UDim2.new(0, 100, 0, 30)
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.Text = "💎 Open"
OpenBtn.TextColor3 = Color3.new(1,1,1)
OpenBtn.Visible = false
MakeGlass(OpenBtn, 8, Color3.fromRGB(0, 150, 255), 0.3)

-- [3] LOGIC (Unchanged from V2, just applying styles)

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
        item.Size = UDim2.new(1, -10, 0, 30)
        item.LayoutOrder = i
        MakeGlass(item, 6, nil, 0.5) -- Glass style items

        local lbl = Instance.new("TextLabel", item)
        lbl.Size = UDim2.new(0.45, 0, 1, 0)
        lbl.Position = UDim2.new(0, 8, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = Color3.new(1,1,1)
        lbl.Text = i .. ". " .. data.Name
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 12
        lbl.TextTruncate = Enum.TextTruncate.AtEnd

        local function MakeSmallBtn(text, pos, color)
            local btn = Instance.new("TextButton", item)
            btn.Size = UDim2.new(0, 25, 0, 25)
            btn.Position = UDim2.new(0, pos, 0.5, -12.5)
            btn.Text = text
            btn.TextColor3 = Color3.new(1,1,1)
            btn.Font = Enum.Font.GothamBold
            MakeGlass(btn, 4, color, 0.5)
            if color then btn.BackgroundColor3 = color end
            return btn
        end

        local upBtn = MakeSmallBtn("▲", 135)
        local dwnBtn = MakeSmallBtn("▼", 165)
        local tpBtn = MakeSmallBtn("TP", 200, Color3.fromRGB(0, 100, 180))
        local delBtn = MakeSmallBtn("X", 235, Color3.fromRGB(180, 50, 50))
        
        upBtn.MouseButton1Click:Connect(function() MoveItem(i, -1) end)
        dwnBtn.MouseButton1Click:Connect(function() MoveItem(i, 1) end)
        delBtn.MouseButton1Click:Connect(function() DeleteItem(i) end)
        tpBtn.MouseButton1Click:Connect(function()
            if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                Player.Character.HumanoidRootPart.CFrame = CFrame.new(unpack(data.Pos))
            end
        end)
    end
    Scroll.CanvasSize = UDim2.new(0, 0, 0, #CurrentList * 35)
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
        LoopBtn.BackgroundColor3 = Color3.fromRGB(0, 60, 120)
        StatusLbl.Text = "Status: Idle"
        return
    end
    if #CurrentList == 0 then return end
    LoopRunning = true
    LoopBtn.Text = "STOP LOOP"
    LoopBtn.UIStroke.Color = Color3.fromRGB(255, 50, 50)
    LoopBtn.BackgroundColor3 = Color3.fromRGB(120, 30, 30)

    task.spawn(function()
        while LoopRunning do
            for i, data in ipairs(CurrentList) do
                if not LoopRunning then break end
                if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                    StatusLbl.Text = "Moving to: " .. data.Name
                    Player.Character.HumanoidRootPart.CFrame = CFrame.new(unpack(data.Pos))
                    task.wait(tonumber(DelayInput.Text) or 5)
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
