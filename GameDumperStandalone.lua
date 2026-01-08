-- ╔══════════════════════════════════════════════════════════════╗
-- ║     COMPREHENSIVE GAME DUMPER V2.0 - STANDALONE              ║
-- ║  Dumps EVERYTHING - Auto-executes immediately on load        ║
-- ╚══════════════════════════════════════════════════════════════╝

print("╔══════════════════════════════════════════════════════════════╗")
print("║     GAME DUMPER V2.0 - STARTING AUTO DUMP...                 ║")
print("╚══════════════════════════════════════════════════════════════╝")

local GameDumper = {}
GameDumper.DumpData = {}
GameDumper.Stats = {
    TotalInstances = 0,
    TotalProperties = 0,
    TotalRemotes = 0,
    TotalValues = 0,
    StartTime = 0,
    EndTime = 0
}

-- Services to dump
local services = {
    "Workspace",
    "Players",
    "ReplicatedStorage",
    "ReplicatedFirst", 
    "Lighting",
    "StarterGui",
    "StarterPlayer",
    "StarterPack",
    "Teams",
    "SoundService"
}

-- ═══════════════════════════════════════════════════════════════
-- HELPER FUNCTIONS
-- ═══════════════════════════════════════════════════════════════

local function SafeGetProperties(instance)
    local properties = {}
    
    -- Comprehensive property list
    local commonProps = {
        "Name", "ClassName", "Archivable",
        "Position", "Size", "CFrame", "Orientation", "Rotation",
        "Anchored", "CanCollide", "Transparency", "Reflectance",
        "Color", "Material", "Shape",
        "Text", "TextColor3", "BackgroundColor3", "BorderColor3",
        "BorderSizePixel", "Image", "ImageColor3", "ImageTransparency",
        "BackgroundTransparency", "Visible", "ZIndex",
        "Value",
        "Health", "MaxHealth", "WalkSpeed", "JumpPower", "JumpHeight",
        "HipHeight", "DisplayName",
        "Brightness", "Range",
        "Mass", "Velocity",
        "Volume", "Pitch", "Playing", "Looped", "SoundId",
        "AnimationId",
        "Enabled", "Disabled"
    }
    
    for _, propertyName in pairs(commonProps) do
        local success, result = pcall(function()
            return instance[propertyName]
        end)
        if success and result ~= nil then
            local valueStr = ""
            pcall(function()
                valueStr = tostring(result)
            end)
            properties[propertyName] = valueStr
            GameDumper.Stats.TotalProperties = GameDumper.Stats.TotalProperties + 1
        end
    end
    
    -- Try to get custom attributes
    local attrSuccess, attributes = pcall(function()
        return instance:GetAttributes()
    end)
    if attrSuccess and attributes and next(attributes) then
        properties["__ATTRIBUTES__"] = {}
        for attrName, attrValue in pairs(attributes) do
            properties["__ATTRIBUTES__"][attrName] = tostring(attrValue)
        end
    end
    
    return properties
end

local function GetFullPath(instance)
    local path = instance.Name
    local current = instance.Parent
    
    while current and current ~= game do
        path = current.Name .. "." .. path
        current = current.Parent
    end
    
    local root = instance
    while root.Parent and root.Parent ~= game do
        root = root.Parent
    end
    
    if root.Parent == game then
        path = "game." .. root.Name .. "." .. string.sub(path, string.len(root.Name) + 2)
    end
    
    return path
end

local function IsValueInstance(instance)
    local valueTypes = {
        "StringValue", "IntValue", "NumberValue", "BoolValue",
        "ObjectValue", "Vector3Value", "CFrameValue", "Color3Value"
    }
    for _, vType in pairs(valueTypes) do
        if instance.ClassName == vType then
            return true
        end
    end
    return false
end

local function IsRemote(instance)
    return instance:IsA("RemoteEvent") or instance:IsA("RemoteFunction") or 
           instance:IsA("BindableEvent") or instance:IsA("BindableFunction")
end

-- ═══════════════════════════════════════════════════════════════
-- DUMP FUNCTION
-- ═══════════════════════════════════════════════════════════════

local function DumpInstance(instance, depth)
    depth = depth or 0
    
    if not instance then return nil end
    if depth > 15 then return nil end -- Prevent too deep recursion
    
    GameDumper.Stats.TotalInstances = GameDumper.Stats.TotalInstances + 1
    
    local data = {
        Name = instance.Name,
        ClassName = instance.ClassName,
        FullPath = GetFullPath(instance),
        Depth = depth,
        Properties = SafeGetProperties(instance),
        Children = {},
        IsValue = IsValueInstance(instance),
        IsRemote = IsRemote(instance)
    }
    
    -- Special handling for Value instances
    if data.IsValue then
        GameDumper.Stats.TotalValues = GameDumper.Stats.TotalValues + 1
        local success, value = pcall(function() return instance.Value end)
        if success then
            data.ValueContent = tostring(value)
        end
    end
    
    -- Special handling for Remotes
    if data.IsRemote then
        GameDumper.Stats.TotalRemotes = GameDumper.Stats.TotalRemotes + 1
        data.RemoteType = instance.ClassName
    end
    
    -- Recursively dump children
    local success, children = pcall(function() return instance:GetChildren() end)
    if success then
        for _, child in ipairs(children) do
            local childData = DumpInstance(child, depth + 1)
            if childData then
                table.insert(data.Children, childData)
            end
        end
    end
    
    return data
end

local function DumpService(serviceName)
    print("[DUMPING] " .. serviceName .. "...")
    local success, service = pcall(function() return game:GetService(serviceName) end)
    
    if success and service then
        return DumpInstance(service, 0)
    else
        return {
            Name = serviceName,
            ClassName = "Service",
            Error = "Could not access",
            Children = {}
        }
    end
end

-- ═══════════════════════════════════════════════════════════════
-- EXPORT FUNCTIONS
-- ═══════════════════════════════════════════════════════════════

function GameDumper:ExportToString()
    local output = ""
    
    output = output .. "╔══════════════════════════════════════════════════════════════╗\n"
    output = output .. "║           GAME DUMP - COMPLETE HIERARCHY                     ║\n"
    output = output .. "╚══════════════════════════════════════════════════════════════╝\n\n"
    
    output = output .. "STATISTICS:\n"
    output = output .. string.format("  Total Instances: %d\n", self.Stats.TotalInstances)
    output = output .. string.format("  Total Properties: %d\n", self.Stats.TotalProperties)
    output = output .. string.format("  Total Remotes: %d\n", self.Stats.TotalRemotes)
    output = output .. string.format("  Total Values: %d\n", self.Stats.TotalValues)
    output = output .. string.format("  Dump Time: %.2f seconds\n\n", self.Stats.EndTime - self.Stats.StartTime)
    
    local function exportRecursive(data, indent)
        if not data then return end
        
        local line = string.rep("  ", indent)
        line = line .. "├─ " .. data.Name .. " [" .. data.ClassName .. "]"
        
        if data.IsValue and data.ValueContent then
            line = line .. " = " .. data.ValueContent
        end
        
        if data.IsRemote then
            line = line .. " <REMOTE>"
        end
        
        output = output .. line .. "\n"
        
        if data.FullPath then
            output = output .. string.rep("  ", indent + 1) .. "Path: " .. data.FullPath .. "\n"
        end
        
        if data.Properties and next(data.Properties) then
            for propName, propValue in pairs(data.Properties) do
                if propName ~= "__ATTRIBUTES__" then
                    output = output .. string.rep("  ", indent + 2) .. propName .. " = " .. tostring(propValue) .. "\n"
                end
            end
        end
        
        for _, child in ipairs(data.Children) do
            exportRecursive(child, indent + 1)
        end
    end
    
    for serviceName, serviceData in pairs(self.DumpData) do
        output = output .. "\n═══════════════ " .. serviceName .. " ═══════════════\n"
        exportRecursive(serviceData, 0)
    end
    
    return output
end

function GameDumper:ExportRemotesToString()
    local output = "╔══════════════════════════════════════════════════════════════╗\n"
    output = output .. "║                    ALL REMOTE EVENTS                         ║\n"
    output = output .. "╚══════════════════════════════════════════════════════════════╝\n\n"
    
    local remotes = {}
    
    local function findRemotes(data)
        if data.IsRemote then
            table.insert(remotes, {
                Type = data.RemoteType,
                Path = data.FullPath,
                Name = data.Name
            })
        end
        for _, child in ipairs(data.Children) do
            findRemotes(child)
        end
    end
    
    for _, serviceData in pairs(self.DumpData) do
        findRemotes(serviceData)
    end
    
    output = output .. "Total Remotes Found: " .. #remotes .. "\n\n"
    
    for i, remote in ipairs(remotes) do
        output = output .. string.format("%d. [%s] %s\n", i, remote.Type, remote.Path)
    end
    
    return output
end

function GameDumper:ExportValuesToString()
    local output = "╔══════════════════════════════════════════════════════════════╗\n"
    output = output .. "║                    ALL VALUE INSTANCES                        ║\n"
    output = output .. "╚══════════════════════════════════════════════════════════════╝\n\n"
    
    local values = {}
    
    local function findValues(data)
        if data.IsValue then
            table.insert(values, {
                Type = data.ClassName,
                Path = data.FullPath,
                Value = data.ValueContent or "nil"
            })
        end
        for _, child in ipairs(data.Children) do
            findValues(child)
        end
    end
    
    for _, serviceData in pairs(self.DumpData) do
        findValues(serviceData)
    end
    
    output = output .. "Total Values Found: " .. #values .. "\n\n"
    
    for i, value in ipairs(values) do
        output = output .. string.format("%d. [%s] %s = %s\n", i, value.Type, value.Path, value.Value)
    end
    
    return output
end

function GameDumper:SaveToFile()
    local hasWriteFile = writefile ~= nil
    
    if not hasWriteFile then
        warn("[DUMPER] writefile not available - printing to console instead")
        print("\n" .. self:ExportRemotesToString())
        print("\n" .. self:ExportValuesToString())
        return false
    end
    
    local success1 = pcall(function()
        writefile("GameDump.txt", self:ExportToString())
    end)
    
    local success2 = pcall(function()
        writefile("GameDump_Remotes.txt", self:ExportRemotesToString())
    end)
    
    local success3 = pcall(function()
        writefile("GameDump_Values.txt", self:ExportValuesToString())
    end)
    
    if success1 then
        print("✓ Saved: GameDump.txt")
    end
    if success2 then
        print("✓ Saved: GameDump_Remotes.txt")
    end
    if success3 then
        print("✓ Saved: GameDump_Values.txt")
    end
    
    return success1 or success2 or success3
end

-- ═══════════════════════════════════════════════════════════════
-- MAIN DUMP FUNCTION
-- ═══════════════════════════════════════════════════════════════

function GameDumper:DumpEverything()
    print("\n[DUMP] Starting comprehensive dump...")
    
    self.Stats.StartTime = tick()
    self.DumpData = {}
    self.Stats.TotalInstances = 0
    self.Stats.TotalProperties = 0
    self.Stats.TotalRemotes = 0
    self.Stats.TotalValues = 0
    
    for _, serviceName in ipairs(services) do
        local serviceData = DumpService(serviceName)
        self.DumpData[serviceName] = serviceData
    end
    
    self.Stats.EndTime = tick()
    
    print("\n╔══════════════════════════════════════════════════════════════╗")
    print("║                    DUMP COMPLETE!                             ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    print(string.format("Total Instances: %d", self.Stats.TotalInstances))
    print(string.format("Total Properties: %d", self.Stats.TotalProperties))
    print(string.format("Total Remotes: %d", self.Stats.TotalRemotes))
    print(string.format("Total Values: %d", self.Stats.TotalValues))
    print(string.format("Time Taken: %.2f seconds", self.Stats.EndTime - self.Stats.StartTime))
    
    return self.DumpData
end

-- ═══════════════════════════════════════════════════════════════
-- AUTO EXECUTE
-- ═══════════════════════════════════════════════════════════════

-- Run the dump
GameDumper:DumpEverything()

-- Try to save to files
GameDumper:SaveToFile()

-- Store in global for later access
getgenv().GameDumper = GameDumper

print("\n╔══════════════════════════════════════════════════════════════╗")
print("║  DUMPER READY! Data saved to GameDumper global variable     ║")
print("╚══════════════════════════════════════════════════════════════╝")
print("\nACCESS DATA:")
print("  GameDumper.DumpData          - All dumped data")
print("  GameDumper:SaveToFile()      - Save again")
print("  print(GameDumper:ExportRemotesToString())  - View remotes")
print("  print(GameDumper:ExportValuesToString())   - View values")
