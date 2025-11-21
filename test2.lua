--[[
    FISH IT! - NETWORK INTERCEPTOR (DIAGNOSTIC)
    Author: Gemini
    
    This script hooks into the game engine to spy on "RemoteFunctions".
    It prints what the server sends back to you (The Fish).
]]

local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Check if your executor supports hooking
if not getgenv or not hookmetatable then
    return warn("❌ Your executor does not support 'hookmetatable'. You cannot spy on this game.")
end

local Client = Players.LocalPlayer
local OldNamecall = nil

print("---------------------------------------------")
print("🕵️ NETWORK INTERCEPTOR ACTIVE")
print("Catch a fish now and watch the console (F9)!")
print("---------------------------------------------")

-- The Hook
local mt = getrawmetatable(game)
if setreadonly then setreadonly(mt, false) end

OldNamecall = hookmetatable(game, newcclosure(function(Self, ...)
    local Method = getnamecallmethod()
    local Args = {...}

    -- We only care about interactions with the Server
    if Method == "InvokeServer" or Method == "FireServer" then
        
        -- FILTER: Ignore movement/animation spam to keep logs clean
        if tostring(Self) ~= "Badge" and not tostring(Self):find("Move") and not tostring(Self):find("Anim") then
            
            -- 1. Log what we SENT to the server
            print("📤 [OUTGOING] " .. tostring(Self.Name) .. " ("..Self.ClassName..")")
            
            -- 2. If it is a Function, wait for the REPLY (The Fish)
            if Method == "InvokeServer" then
                task.spawn(function()
                    -- We run the original function to get the result
                    local Result = OldNamecall(Self, unpack(Args))
                    
                    print("✅ [RETURN DATA] from " .. tostring(Self.Name))
                    
                    -- Print the data the server gave back
                    if type(Result) == "table" then
                        for k, v in pairs(Result) do
                            print("   [Key]: " .. tostring(k) .. " = [Value]: " .. tostring(v))
                            -- Deep print for nested tables (common in fish stats)
                            if type(v) == "table" then
                                for k2, v2 in pairs(v) do
                                    print("      -> " .. tostring(k2) .. ": " .. tostring(v2))
                                end
                            end
                        end
                    else
                        print("   [Value]: " .. tostring(Result))
                    end
                    print("---------------------------------------------")
                end)
            end
        end
    end

    return OldNamecall(Self, ...)
end))

if setreadonly then setreadonly(mt, true) end
