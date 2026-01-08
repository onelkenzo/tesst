-- ╔══════════════════════════════════════════════════════════════╗
-- ║           COMPREHENSIVE GAME DUMPER V2.0                     ║
-- ║  Dumps EVERYTHING from the game - Objects, Values, Remotes   ║
-- ╚══════════════════════════════════════════════════════════════╝

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
local game = game
local services = {
    "Workspace",
    "Players",
    "ReplicatedStorage",
    "ReplicatedFirst", 
    "ServerStorage",
    "ServerScriptService",
    "Lighting",
    "StarterGui",
    "StarterPlayer",
    "StarterPack",
    "Teams",
    "SoundService",
    "Chat",
    "LocalizationService",
    "TestService"
}

-- Property blacklist (properties that might error or are not useful)
local propertyBlacklist = {
    "Parent", "DataCost", "RobloxLocked"
}

-- ═══════════════════════════════════════════════════════════════
-- HELPER FUNCTIONS
-- ═══════════════════════════════════════════════════════════════

local function SafeGetProperties(instance)
    local properties = {}
    
    -- Get ALL properties using the game's property listing
    local success, allProperties = pcall(function()
        local props = {}
        -- Try to get all property names via different methods
        
        -- Method 1: Try GetProperties if available (some executors)
        local s1, r1 = pcall(function()
            for _, prop in pairs(instance:GetProperties()) do
                table.insert(props, prop)
            end
        end)
        
        -- Method 2: Common properties enumeration (comprehensive list)
        local commonProps = {
            -- Basic
            "Name", "ClassName", "Archivable",
            
            -- 3D Properties
            "Position", "Size", "CFrame", "Orientation", "Rotation",
            "Anchored", "CanCollide", "Transparency", "Reflectance",
            "Color", "Material", "Shape", "TopSurface", "BottomSurface",
            "LeftSurface", "RightSurface", "FrontSurface", "BackSurface",
            
            -- GUI Properties
            "Text", "TextColor3", "BackgroundColor3", "BorderColor3",
            "BorderSizePixel", "Image", "ImageColor3", "ImageTransparency",
            "BackgroundTransparency", "Visible", "ZIndex", "ClipsDescendants",
            "Active", "AnchorPoint", "AutomaticSize", "LayoutOrder",
            "SizeConstraint", "TextScaled", "TextSize", "TextStrokeTransparency",
            "TextTransparency", "TextWrapped", "Font", "TextXAlignment", "TextYAlignment",
            
            -- Value Properties
            "Value",
            
            -- Humanoid Properties
            "Health", "MaxHealth", "WalkSpeed", "JumpPower", "JumpHeight",
            "HipHeight", "AutoRotate", "DisplayName",
            
            -- Light Properties
            "Brightness", "Range", "Shadows",
            
            -- Physics
            "Mass", "Velocity", "RotVelocity", "AssemblyLinearVelocity",
            "AssemblyAngularVelocity", "Density",
            
            -- Sound
            "Volume", "Pitch", "Playing", "Looped", "SoundId",
            
            -- Animation
            "AnimationId",
            
            -- Model
            "PrimaryPart",
            
            -- Attributes (try to get custom attributes)
            "Enabled", "Disabled"
        }
        
        for _, propName in pairs(commonProps) do
            if not table.find(props, propName) then
                table.insert(props, propName)
            end
        end
        
        return props
    end)
    
    local propertyList = (success and allProperties) or {}
    
    -- Try to get each property value
    for _, propertyName in pairs(propertyList) do
        if not table.find(propertyBlacklist, propertyName) then
            local success2, result = pcall(function()
                return instance[propertyName]
            end)
            if success2 and result ~= nil then
                -- Convert to string safely
                local valueStr = ""
                pcall(function()
                    valueStr = tostring(result)
                end)
                properties[propertyName] = valueStr
                GameDumper.Stats.TotalProperties = GameDumper.Stats.TotalProperties + 1
            end
        end
    end
    
    -- Try to get custom attributes
    local attrSuccess, attributes = pcall(function()
        return instance:GetAttributes()
    end)
    if attrSuccess and attributes then
        properties["__ATTRIBUTES__"] = {}
        for attrName, attrValue in pairs(attributes) do
            properties["__ATTRIBUTES__"][attrName] = tostring(attrValue)
            GameDumper.Stats.TotalProperties = GameDumper.Stats.TotalProperties + 1
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
    
    if instance:IsA("ServiceProvider") then
        return "game"
    end
    
    -- Find which service this belongs to
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
        "ObjectValue", "Vector3Value", "CFrameValue", "Color3Value",
        "BrickColorValue", "RayValue"
    }
    return table.find(valueTypes, instance.ClassName) ~= nil
end

local function IsRemote(instance)
    return instance:IsA("RemoteEvent") or instance:IsA("RemoteFunction") or 
           instance:IsA("BindableEvent") or instance:IsA("BindableFunction")
end

-- ═══════════════════════════════════════════════════════════════
-- DUMP FUNCTIONS
-- ═══════════════════════════════════════════════════════════════

local function DumpInstance(instance, depth)
    depth = depth or 0
    
    if not instance then return nil end
    
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
            data.Value = tostring(value)
        end
    end
    
    -- Special handling for Remotes
    if data.IsRemote then
        GameDumper.Stats.TotalRemotes = GameDumper.Stats.TotalRemotes + 1
        data.RemoteType = instance.ClassName
    end
    
    -- Special handling for ModuleScripts
    if instance:IsA("ModuleScript") then
        local success, source = pcall(function()
            return instance.Source or "-- Source not accessible"
        end)
        if success then
            data.Source = source
        end
    end
    
    -- Special handling for LocalScripts and Scripts
    if instance:IsA("LocalScript") or instance:IsA("Script") then
        local success, source = pcall(function()
            return instance.Source or "-- Source not accessible"
        end)
        if success then
            data.Source = source
        end
    end
    
    -- Recursively dump children
    local success, children = pcall(function() return instance:GetChildren() end)
    if success then
        for _, child in ipairs(children) do
            table.insert(data.Children, DumpInstance(child, depth + 1))
        end
    end
    
    return data
end

local function DumpService(serviceName)
    print("[GameDumper] Dumping service:", serviceName)
    local success, service = pcall(function() return game:GetService(serviceName) end)
    
    if success and service then
        return DumpInstance(service, 0)
    else
        return {
            Name = serviceName,
            ClassName = "Service",
            Error = "Could not access service",
            Children = {}
        }
    end
end

-- ═══════════════════════════════════════════════════════════════
-- SEARCH AND FILTER FUNCTIONS
-- ═══════════════════════════════════════════════════════════════

function GameDumper:FindByName(name)
    local results = {}
    
    local function searchRecursive(data)
        if data.Name == name then
            table.insert(results, data)
        end
        
        for _, child in ipairs(data.Children) do
            searchRecursive(child)
        end
    end
    
    for _, serviceData in pairs(self.DumpData) do
        searchRecursive(serviceData)
    end
    
    return results
end

function GameDumper:FindByClassName(className)
    local results = {}
    
    local function searchRecursive(data)
        if data.ClassName == className then
            table.insert(results, data)
        end
        
        for _, child in ipairs(data.Children) do
            searchRecursive(child)
        end
    end
    
    for _, serviceData in pairs(self.DumpData) do
        searchRecursive(serviceData)
    end
    
    return results
end

function GameDumper:FindByPath(path)
    local function searchRecursive(data)
        if data.FullPath == path then
            return data
        end
        
        for _, child in ipairs(data.Children) do
            local result = searchRecursive(child)
            if result then return result end
        end
    end
    
    for _, serviceData in pairs(self.DumpData) do
        local result = searchRecursive(serviceData)
        if result then return result end
    end
    
    return nil
end

function GameDumper:GetAllRemotes()
    return self:FindByClassName("RemoteEvent") and self:FindByClassName("RemoteFunction")
end

function GameDumper:GetAllValues()
    local results = {}
    
    local function searchRecursive(data)
        if data.IsValue then
            table.insert(results, data)
        end
        
        for _, child in ipairs(data.Children) do
            searchRecursive(child)
        end
    end
    
    for _, serviceData in pairs(self.DumpData) do
        searchRecursive(serviceData)
    end
    
    return results
end

-- ═══════════════════════════════════════════════════════════════
-- EXPORT FUNCTIONS
-- ═══════════════════════════════════════════════════════════════

function GameDumper:ExportToString()
    local output = ""
    
    output = output .. "╔══════════════════════════════════════════════════════════════╗\n"
    output = output .. "║           GAME DUMP - COMPLETE HIERARCHY                     ║\n"
    output = output .. "╚══════════════════════════════════════════════════════════════╝\n\n"
    
    output = output .. "Statistics:\n"
    output = output .. string.format("  Total Instances: %d\n", self.Stats.TotalInstances)
    output = output .. string.format("  Total Properties: %d\n", self.Stats.TotalProperties)
    output = output .. string.format("  Total Remotes: %d\n", self.Stats.TotalRemotes)
    output = output .. string.format("  Total Values: %d\n", self.Stats.TotalValues)
    output = output .. string.format("  Dump Time: %.2f seconds\n\n", self.Stats.EndTime - self.Stats.StartTime)
    
    local function exportRecursive(data, indent)
        local line = string.rep("  ", indent)
        
        -- Instance name and class
        line = line .. "├─ " .. data.Name .. " [" .. data.ClassName .. "]"
        
        -- Add value indicator
        if data.IsValue and data.Value then
            line = line .. " = " .. data.Value
        end
        
        -- Add remote indicator
        if data.IsRemote then
            line = line .. " <REMOTE>"
        end
        
        output = output .. line .. "\n"
        
        -- Add full path
        if data.FullPath then
            output = output .. string.rep("  ", indent + 1) .. "Path: " .. data.FullPath .. "\n"
        end
        
        -- Add properties
        if data.Properties and next(data.Properties) then
            output = output .. string.rep("  ", indent + 1) .. "Properties:\n"
            for propName, propValue in pairs(data.Properties) do
                output = output .. string.rep("  ", indent + 2) .. propName .. " = " .. propValue .. "\n"
            end
        end
        
        -- Add children
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
    
    local remoteEvents = self:FindByClassName("RemoteEvent")
    local remoteFunctions = self:FindByClassName("RemoteFunction")
    
    output = output .. "RemoteEvents (" .. #remoteEvents .. "):\n"
    for i, remote in ipairs(remoteEvents) do
        output = output .. string.format("  %d. %s\n", i, remote.FullPath)
    end
    
    output = output .. "\nRemoteFunctions (" .. #remoteFunctions .. "):\n"
    for i, remote in ipairs(remoteFunctions) do
        output = output .. string.format("  %d. %s\n", i, remote.FullPath)
    end
    
    return output
end

function GameDumper:ExportValuesToString()
    local output = "╔══════════════════════════════════════════════════════════════╗\n"
    output = output .. "║                    ALL VALUE INSTANCES                        ║\n"
    output = output .. "╚══════════════════════════════════════════════════════════════╝\n\n"
    
    local values = self:GetAllValues()
    
    for i, value in ipairs(values) do
        output = output .. string.format("%d. [%s] %s = %s\n", i, value.ClassName, value.FullPath, value.Value or "nil")
    end
    
    return output
end

function GameDumper:SaveToFile(filename)
    filename = filename or "GameDump.txt"
    local content = self:ExportToString()
    
    writefile(filename, content)
    print("[GameDumper] Saved complete dump to:", filename)
    
    writefile("GameDump_Remotes.txt", self:ExportRemotesToString())
    print("[GameDumper] Saved remotes to: GameDump_Remotes.txt")
    
    writefile("GameDump_Values.txt", self:ExportValuesToString())
    print("[GameDumper] Saved values to: GameDump_Values.txt")
end

-- ═══════════════════════════════════════════════════════════════
-- MAIN DUMP FUNCTION
-- ═══════════════════════════════════════════════════════════════

function GameDumper:DumpEverything()
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║           STARTING COMPREHENSIVE GAME DUMP                   ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    
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
-- AUTO-EXECUTION - DUMPS IMMEDIATELY ON LOAD
-- ═══════════════════════════════════════════════════════════════

print([[
╔══════════════════════════════════════════════════════════════╗
║           GAME DUMPER V2.0 - AUTO DUMPING...                 ║
╚══════════════════════════════════════════════════════════════╝
]])

-- Automatically start dumping everything
spawn(function()
    wait(0.5) -- Small delay to ensure everything is loaded
    
    print("[AUTO-DUMP] Starting comprehensive game dump...")
    GameDumper:DumpEverything()
    
    print("[AUTO-DUMP] Saving to files...")
    GameDumper:SaveToFile()
    
    print([[
    
╔══════════════════════════════════════════════════════════════╗
║           DUMP COMPLETE - FILES SAVED!                        ║
╚══════════════════════════════════════════════════════════════╝

Check your executor's workspace folder for:
  ✓ GameDump.txt          - Complete game hierarchy
  ✓ GameDump_Remotes.txt  - All RemoteEvents/Functions
  ✓ GameDump_Values.txt   - All Value instances

ADDITIONAL COMMANDS:
--------------------
Search for objects:
  GameDumper:FindByName("ObjectName")
  GameDumper:FindByClassName("RemoteEvent")
  GameDumper:FindByPath("game.ReplicatedStorage.SomePath")

Get specific data:
  GameDumper:GetAllRemotes()
  GameDumper:GetAllValues()

Export to console:
  print(GameDumper:ExportRemotesToString())
  print(GameDumper:ExportValuesToString())

Re-dump if needed:
  GameDumper:DumpEverything()
  GameDumper:SaveToFile()
]])
end)

return GameDumper
