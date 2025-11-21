--[[
    VARIABLE HUNTER
    Author: Gemini
    
    Scans: LocalPlayer (Attributes, Children, Descendants)
    Target: Finds hidden stats like Luck, Mutation, etc.
]]

local Players = game:GetService("Players")
local Player = Players.LocalPlayer

-- [CONFIGURATION] Keywords to highlight in the log
local Keywords = {
    "Luck",
    "Chance",
    "Mutation",
    "Rate",
    "Percent",
    "Multi",
    "Stat"
}

print("---------------------------------------------")
print("🔍 STARTING VARIABLE SCAN FOR: " .. Player.Name)
print("---------------------------------------------")

-- Helper function to check keywords
local function isImportant(name)
    for _, key in pairs(Keywords) do
        if string.find(string.lower(name), string.lower(key)) then
            return true
        end
    end
    return false
end

-- 1. SCAN ATTRIBUTES (Modern games use this most)
print("\n[1] SCANNING ATTRIBUTES:")
local attrs = Player:GetAttributes()
local foundAttr = false

for name, val in pairs(attrs) do
    foundAttr = true
    if isImportant(name) then
        warn(">>> 💎 FOUND ATTRIBUTE: " .. name .. " = " .. tostring(val))
    else
        print("    [Attr] " .. name .. ": " .. tostring(val))
    end
end
if not foundAttr then print("    No Attributes found on Player.") end

-- 2. SCAN VALUE OBJECTS (IntValues, NumberValues inside folders)
print("\n[2] SCANNING FOLDERS & VALUES:")

local function deepScan(parent, depth)
    if depth > 3 then return end -- Prevent crashing on deep folders
    
    for _, child in pairs(parent:GetChildren()) do
        -- We are looking for containers (Folders, Configurations) or Values
        if child:IsA("Folder") or child:IsA("Configuration") or child:IsA("Model") then
            print(string.rep("  ", depth) .. "📂 " .. child.Name)
            deepScan(child, depth + 1)
            
        elseif child:IsA("ValueBase") then -- IntValue, StringValue, BoolValue, etc.
            local val = child.Value
            if isImportant(child.Name) then
                warn(string.rep("  ", depth) .. ">>> 💎 FOUND VALUE: " .. child.Name .. " = " .. tostring(val))
            else
                print(string.rep("  ", depth) .. "    ["..child.ClassName.."] " .. child.Name .. ": " .. tostring(val))
            end
        end
    end
end

deepScan(Player, 1)

-- 3. SCAN PLAYERGUI (Sometimes stats are hidden in UI attributes)
print("\n[3] SCANNING GUI ATTRIBUTES (Brief):")
local PlayerGui = Player:FindFirstChild("PlayerGui")
if PlayerGui then
    for _, gui in pairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") then
            local gAttrs = gui:GetAttributes()
            for name, val in pairs(gAttrs) do
                if isImportant(name) then
                    warn(">>> 💎 FOUND GUI ATTRIBUTE ("..gui.Name.."): " .. name .. " = " .. tostring(val))
                end
            end
        end
    end
end

print("---------------------------------------------")
print("✅ SCAN COMPLETE")
print("---------------------------------------------")
