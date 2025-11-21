--[[
    FISH IT! - REMOTE EVENT SNIFFER
    Author: Gemini
    
    Instructions:
    1. Run Script.
    2. Catch a fish.
    3. Open Console (F9).
    4. Look for the log that contains your Fish's name.
    5. Copy the "Path" shown.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("------------------------------------------------")
print("📡 SNIFFER STARTED: Catch a fish now!")
print("------------------------------------------------")

-- Recursive function to find all RemoteEvents
local function hookRemotes(parent)
    for _, child in pairs(parent:GetChildren()) do
        if child:IsA("RemoteEvent") then
            child.OnClientEvent:Connect(function(...)
                local args = {...}
                -- Convert args to string for easy reading
                local argString = ""
                for i, v in pairs(args) do
                    argString = argString .. tostring(v) .. ", "
                end
                
                print("🔔 FIRED: " .. child.Name)
                print("📂 PATH: " .. child:GetFullName())
                print("📦 DATA: " .. argString)
                print("------------------------------------------------")
            end)
        end
        -- Scan subfolders
        if child:IsA("Folder") or child:IsA("Model") then
            hookRemotes(child)
        end
    end
end

hookRemotes(ReplicatedStorage)
