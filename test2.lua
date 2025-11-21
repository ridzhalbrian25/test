local Player = game:GetService("Players").LocalPlayer

print("----- PLAYER CHILDREN -----")
for _, child in pairs(Player:GetChildren()) do
    print("Name: " .. child.Name .. " | Class: " .. child.ClassName)
    
    -- If it's a folder (like leaderstats or Data), look inside it
    if child:IsA("Folder") or child:IsA("Configuration") or child.Name == "leaderstats" then
        print("   > INSIDE " .. child.Name .. ":")
        for _, grandChild in pairs(child:GetChildren()) do
            -- Check if it has a 'Value' property
            if pcall(function() return grandChild.Value end) then
                 print("      - " .. grandChild.Name .. ": " .. tostring(grandChild.Value))
            else
                 print("      - " .. grandChild.Name)
            end
        end
    end
end
print("---------------------------")
