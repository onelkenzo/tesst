-- ╔══════════════════════════════════════════════════════════════╗
-- ║     SAFE GAME DUMPER V3.0 - Won't Crash Your Game!          ║
-- ║  Progressive dump with yields - Auto-executes on load        ║
-- ╚══════════════════════════════════════════════════════════════╝

print("╔══════════════════════════════════════════════════════════════╗")
print("║     SAFE DUMPER V3.0 - STARTING (Won't crash!)               ║")
print("╚══════════════════════════════════════════════════════════════╝")

local GameDumper = {}
GameDumper.DumpData = {}
GameDumper.Stats = {
    TotalInstances = 0,
    TotalRemotes = 0,
    TotalValues = 0,
    StartTime = 0,
    EndTime = 0
}

-- Only dump essential services (lighter load)
local services = {
    "ReplicatedStorage",
    "Players",
    "Workspace"
}

local processedCount = 0

-- ═══════════════════════════════════════════════════════════════
-- HELPER FUNCTIONS
-- ═══════════════════════════════════════════════════════════════

local function IsValueInstance(instance)
    local cn = instance.ClassName
    return cn == "StringValue" or cn == "IntValue" or cn == "NumberValue" or 
           cn == "BoolValue" or cn == "ObjectValue"
end

local function IsRemote(instance)
    return instance:IsA("RemoteEvent") or instance:IsA("RemoteFunction")
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
        return "game." .. root.Name .. "." .. string.sub(path, string.len(root.Name) + 2)
    end
    
    return path
end

-- ═══════════════════════════════════════════════════════════════
-- LIGHTWEIGHT DUMP FUNCTION
-- ═══════════════════════════════════════════════════════════════

local function DumpInstance(instance, depth, parentPath)
    depth = depth or 0
    
    if not instance then return nil end
    if depth > 8 then return nil end -- Limit depth to prevent crash
    
    -- Yield every 50 instances to prevent timeout
    processedCount = processedCount + 1
    if processedCount % 50 == 0 then
        task.wait(0.01) -- Small yield
    end
    
    GameDumper.Stats.TotalInstances = GameDumper.Stats.TotalInstances + 1
    
    local fullPath = parentPath and (parentPath .. "." .. instance.Name) or instance.Name
    
    local data = {
        Name = instance.Name,
        ClassName = instance.ClassName,
        Path = fullPath,
        Children = {}
    }
    
    -- Check if it's a value
    if IsValueInstance(instance) then
        GameDumper.Stats.TotalValues = GameDumper.Stats.TotalValues + 1
        local success, value = pcall(function() return instance.Value end)
        if success then
            data.Value = tostring(value)
        end
    end
    
    -- Check if it's a remote
    if IsRemote(instance) then
        GameDumper.Stats.TotalRemotes = GameDumper.Stats.TotalRemotes + 1
        data.IsRemote = true
        data.RemoteType = instance.ClassName
    end
    
    -- Get important properties only
    local props = {}
    
    -- Try to get Health (for humanoids)
    if instance:IsA("Humanoid") then
        local s1, h = pcall(function() return instance.Health end)
        local s2, mh = pcall(function() return instance.MaxHealth end)
        local s3, ws = pcall(function() return instance.WalkSpeed end)
        if s1 then props.Health = tostring(h) end
        if s2 then props.MaxHealth = tostring(mh) end
        if s3 then props.WalkSpeed = tostring(ws) end
    end
    
    if next(props) then
        data.Properties = props
    end
    
    -- Recursively dump children (with yield)
    local success, children = pcall(function() return instance:GetChildren() end)
    if success and children then
        for i, child in ipairs(children) do
            -- Yield every 10 children
            if i % 10 == 0 then
                task.wait(0.001)
            end
            
            local childData = DumpInstance(child, depth + 1, fullPath)
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
        return DumpInstance(service, 0, "game." .. serviceName)
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
-- EXPORT FUNCTIONS (Optimized)
-- ═══════════════════════════════════════════════════════════════

function GameDumper:ExportRemotesToString()
    local output = "╔══════════════════════════════════════════════════════════════╗\n"
    output = output .. "║                    ALL REMOTE EVENTS                         ║\n"
    output = output .. "╚══════════════════════════════════════════════════════════════╝\n\n"
    
    local remotes = {}
    
    local function findRemotes(data)
        if data.IsRemote then
            table.insert(remotes, {
                Type = data.RemoteType,
                Path = data.Path,
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
    
    output = output .. "🎯 Total Remotes Found: " .. #remotes .. "\n\n"
    
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
        if data.Value then
            table.insert(values, {
                Type = data.ClassName,
                Path = data.Path,
                Value = data.Value
            })
        end
        for _, child in ipairs(data.Children) do
            findValues(child)
        end
    end
    
    for _, serviceData in pairs(self.DumpData) do
        findValues(serviceData)
    end
    
    output = output .. "💰 Total Values Found: " .. #values .. "\n\n"
    
    for i, value in ipairs(values) do
        output = output .. string.format("%d. [%s] %s = %s\n", i, value.Type, value.Path, value.Value)
    end
    
    return output
end

function GameDumper:ExportEverything()
    local output = "╔══════════════════════════════════════════════════════════════╗\n"
    output = output .. "║           GAME DUMP - HIERARCHY                              ║\n"
    output = output .. "╚══════════════════════════════════════════════════════════════╝\n\n"
    
    output = output .. "📊 STATISTICS:\n"
    output = output .. string.format("  Instances: %d\n", self.Stats.TotalInstances)
    output = output .. string.format("  Remotes: %d\n", self.Stats.TotalRemotes)
    output = output .. string.format("  Values: %d\n", self.Stats.TotalValues)
    output = output .. string.format("  Time: %.2fs\n\n", self.Stats.EndTime - self.Stats.StartTime)
    
    local lineCount = 0
    local maxLines = 50000 -- Limit to prevent massive files
    
    local function exportTree(data, indent)
        if not data then return end
        if lineCount >= maxLines then 
            if lineCount == maxLines then
                output = output .. "\n⚠️ OUTPUT TRUNCATED - Too much data! Use specific exports instead.\n"
                lineCount = lineCount + 1
            end
            return 
        end
        
        local line = string.rep("  ", indent) .. "├─ " .. data.Name .. " [" .. data.ClassName .. "]"
        
        if data.Value then
            line = line .. " = " .. data.Value
        end
        
        if data.IsRemote then
            line = line .. " 🎯 <REMOTE>"
        end
        
        output = output .. line .. "\n"
        lineCount = lineCount + 1
        
        -- Yield every 100 lines to prevent freezing
        if lineCount % 100 == 0 then
            task.wait(0.001)
        end
        
        if data.Path then
            output = output .. string.rep("  ", indent + 1) .. "📍 " .. data.Path .. "\n"
            lineCount = lineCount + 1
        end
        
        for _, child in ipairs(data.Children) do
            exportTree(child, indent + 1)
        end
    end
    
    for serviceName, serviceData in pairs(self.DumpData) do
        if lineCount >= maxLines then break end
        
        output = output .. "\n" .. string.rep("═", 40) .. "\n"
        output = output .. "SERVICE: " .. serviceName .. "\n"
        output = output .. string.rep("═", 40) .. "\n"
        lineCount = lineCount + 3
        exportTree(serviceData, 0)
        
        -- Yield after each service
        task.wait(0.01)
    end
    
    return output
end

function GameDumper:SaveToFile()
    local hasWriteFile = writefile ~= nil
    
    if not hasWriteFile then
        warn("⚠️ writefile not available - printing to console")
        print("\n" .. self:ExportRemotesToString())
        print("\n" .. self:ExportValuesToString())
        return false
    end
    
    print("\n💾 Saving files...")
    
    -- Save remotes first (smaller file)
    local success, err = pcall(function()
        print("  📝 Generating remotes export...")
        local remotesData = self:ExportRemotesToString()
        task.wait(0.1) -- Small delay
        writefile("GameDump_Remotes.txt", remotesData)
        print("  ✅ Saved: GameDump_Remotes.txt")
    end)
    if not success then
        warn("  ❌ Failed to save remotes: " .. tostring(err))
    end
    
    -- Save values (smaller file)
    success, err = pcall(function()
        print("  📝 Generating values export...")
        local valuesData = self:ExportValuesToString()
        task.wait(0.1) -- Small delay
        writefile("GameDump_Values.txt", valuesData)
        print("  ✅ Saved: GameDump_Values.txt")
    end)
    if not success then
        warn("  ❌ Failed to save values: " .. tostring(err))
    end
    
    -- Save full dump last (largest file - most likely to crash)
    success, err = pcall(function()
        print("  📝 Generating full export (this may take a moment)...")
        local fullData = self:ExportEverything()
        task.wait(0.2) -- Longer delay for big file
        print("  💾 Writing full dump...")
        writefile("GameDump_Full.txt", fullData)
        print("  ✅ Saved: GameDump_Full.txt")
    end)
    if not success then
        warn("  ❌ Failed to save full dump: " .. tostring(err))
        warn("  💡 Try using specific exports instead (remotes/values)")
    end
    
    return true
end

-- ═══════════════════════════════════════════════════════════════
-- MAIN DUMP FUNCTION (With Progress Updates)
-- ═══════════════════════════════════════════════════════════════

function GameDumper:DumpEverything()
    print("\n⏳ Starting safe dump (with delays to prevent crash)...\n")
    
    self.Stats.StartTime = tick()
    self.DumpData = {}
    self.Stats.TotalInstances = 0
    self.Stats.TotalRemotes = 0
    self.Stats.TotalValues = 0
    processedCount = 0
    
    for i, serviceName in ipairs(services) do
        task.wait(0.1) -- Delay between services
        local serviceData = DumpService(serviceName)
        self.DumpData[serviceName] = serviceData
        
        print(string.format("  ✓ %s complete (%d/%d)", serviceName, i, #services))
    end
    
    self.Stats.EndTime = tick()
    
    print("\n╔══════════════════════════════════════════════════════════════╗")
    print("║                    ✅ DUMP COMPLETE!                          ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    print(string.format("📦 Instances: %d", self.Stats.TotalInstances))
    print(string.format("🎯 Remotes: %d", self.Stats.TotalRemotes))
    print(string.format("💰 Values: %d", self.Stats.TotalValues))
    print(string.format("⏱️  Time: %.2f seconds", self.Stats.EndTime - self.Stats.StartTime))
    
    return self.DumpData
end

-- ═══════════════════════════════════════════════════════════════
-- AUTO EXECUTE (Async to prevent blocking)
-- ═══════════════════════════════════════════════════════════════

task.spawn(function()
    local success, err = pcall(function()
        task.wait(1) -- Small delay before starting
        
        -- Run the dump
        print("🔄 Starting dump...")
        GameDumper:DumpEverything()
        
        -- Save files
        print("\n🔄 Preparing to save files...")
        task.wait(0.5)
        GameDumper:SaveToFile()
        
        -- Store globally
        getgenv().GameDumper = GameDumper
        
        print("\n╔══════════════════════════════════════════════════════════════╗")
        print("║  ✅ DUMPER COMPLETE! Check workspace for .txt files          ║")
        print("╚══════════════════════════════════════════════════════════════╝")
        print("\n📋 Quick Commands:")
        print("  print(GameDumper:ExportRemotesToString())")
        print("  print(GameDumper:ExportValuesToString())")
        print("  GameDumper:SaveToFile()")
    end)
    
    if not success then
        warn("\n╔══════════════════════════════════════════════════════════════╗")
        warn("║  ❌ DUMPER CRASHED! Error details below:                     ║")
        warn("╚══════════════════════════════════════════════════════════════╝")
        warn("Error: " .. tostring(err))
        warn("\n💡 The dumper may have collected too much data.")
        warn("📋 You can still access partial data via:")
        warn("  getgenv().GameDumper")
        
        -- Store whatever we got
        getgenv().GameDumper = GameDumper
    end
end)

print("\n⏳ Dumper will start in 1 second...")
