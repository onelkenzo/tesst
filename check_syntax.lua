-- Simple Lua syntax checker
local function checkSyntax(filename)
    local file = io.open(filename, "r")
    if not file then
        print("Error: Cannot open file " .. filename)
        return false
    end
    
    local content = file:read("*all")
    file:close()
    
    local func, err = load(content)
    if not func then
        print("Syntax Error:")
        print(err)
        return false
    end
    
    print("✓ Syntax is valid!")
    return true
end

checkSyntax("UILIB.lua")
