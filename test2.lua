-- This only works on specific Executors with high permissions
local Player = game:GetService("Players").LocalPlayer

if gethiddenproperties then
    local props = gethiddenproperties(Player)
    print("----- HIDDEN PROPERTIES -----")
    for name, val in pairs(props) do
        print(name, ":", tostring(val))
    end
elseif getproperties then
    local props = getproperties(Player)
    print("----- PROPERTIES -----")
    for name, val in pairs(props) do
        print(name, ":", tostring(val))
    end
else
    warn("Your executor does not support 'getproperties'")
end
