-- Simple loader for GameDumper
print("[LOADER] Loading GameDumper.lua...")

local success, result = pcall(function()
    if readfile then
        local code = readfile("GameDumper.lua")
        local func, err = loadstring(code)
        if not func then
            error("Failed to load GameDumper: " .. tostring(err))
        end
        return func()
    else
        error("readfile not available")
    end
end)

if not success then
    warn("[LOADER] Error loading GameDumper:", result)
else
    print("[LOADER] GameDumper loaded successfully!")
end
