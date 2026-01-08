local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- CLEANUP SYSTEM
if _G.DevTools then
    if _G.DevTools.Connections then
        for _, conn in ipairs(_G.DevTools.Connections) do
            conn:Disconnect()
        end
    end
    if _G.DevTools.Guis then
        for _, gui in ipairs(_G.DevTools.Guis) do
            if gui then gui:Destroy() end
        end
    end
end

_G.DevTools = {
    Connections = {},
    Guis = {}
}

-- Attempt to load UILib (Local First, then Web)
local UILib
local success, result = pcall(function()
    if isfile and isfile("UILIB.lua") then
        return loadstring(readfile("UILIB.lua"))()
    end
end)

if success and result then
    UILib = result
    print("Loaded UILIB from local file.")
else
    local repo = "https://raw.githubusercontent.com/onelkenzo/tesst/main/UILib/"
    local webSuccess, webResult = pcall(function()
        return loadstring(game:HttpGet(repo .. "UILIB.lua"))()
    end)
    
    if webSuccess and webResult then
        UILib = webResult
        print("Loaded UILIB from Web.")
    end
end

if not UILib then
    warn("Failed to load UILIB from Local or Web. Please check file/connection.")
    return
end

-- ═══════════════════════════════════════════════════════════════
-- GAME DUMPER MODULE (From GameDumperSafe.lua)
-- ═══════════════════════════════════════════════════════════════

local GameDumper = {}
GameDumper.DumpData = {}
GameDumper.Stats = {
    TotalInstances = 0,
    TotalRemotes = 0,
    TotalValues = 0,
    TotalScripts = 0,
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

-- Helper Functions
local function IsValueInstance(instance)
    local cn = instance.ClassName
    return cn == "StringValue" or cn == "IntValue" or cn == "NumberValue" or 
           cn == "BoolValue" or cn == "ObjectValue"
end

local function IsRemote(instance)
    return instance:IsA("RemoteEvent") or instance:IsA("RemoteFunction")
end

local function IsScript(instance)
    return instance:IsA("LocalScript") or instance:IsA("Script") or instance:IsA("ModuleScript")
end

-- Lightweight Dump Function
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
    
    -- Check if it's a script
    if IsScript(instance) then
        GameDumper.Stats.TotalScripts = GameDumper.Stats.TotalScripts + 1
        data.IsScript = true
        data.ScriptType = instance.ClassName
    end
    
    -- Recursively dump children (with yield)
    local success, children = pcall(function() return instance:GetChildren() end)
    if success and children then
        for i, child in ipairs(children) do
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
    -- Notification will be handled by DumpEverything
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
    local maxLines = 50000
    
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
        
        task.wait(0.01)
    end
    
    return output
end

function GameDumper:ExportScriptsToString()
    local output = "╔══════════════════════════════════════════════════════════════╗\n"
    output = output .. "║                    ALL SCRIPTS FOUND                         ║\n"
    output = output .. "╚══════════════════════════════════════════════════════════════╝\n\n"
    
    local scripts = {}
    
    local function findScripts(data)
        if data.IsScript then
            table.insert(scripts, {
                Type = data.ScriptType,
                Path = data.Path,
                Name = data.Name
            })
        end
        for _, child in ipairs(data.Children) do
            findScripts(child)
        end
    end
    
    for _, serviceData in pairs(self.DumpData) do
        findScripts(serviceData)
    end
    
    output = output .. "📜 Total Scripts Found: " .. #scripts .. "\n\n"
    
    for i, script in ipairs(scripts) do
        output = output .. string.format("%d. [%s] %s\n", i, script.Type, script.Path)
    end
    
    return output
end

function GameDumper:DecompileAllScripts()
    local hasDecompile = decompile ~= nil
    local scripts = {}
    
    local function findScriptsRecursive(instance, path)
        if not instance then return end
        
        local currentPath = path and (path .. "." .. instance.Name) or instance.Name
        
        if IsScript(instance) then
            table.insert(scripts, {
                Type = instance.ClassName,
                Path = currentPath,
                Name = instance.Name,
                Instance = instance
            })
        end
        
        -- Recursively check children
        local success, children = pcall(function() return instance:GetChildren() end)
        if success and children then
            for _, child in ipairs(children) do
                findScriptsRecursive(child, currentPath)
            end
        end
    end
    
    -- Find all scripts from the actual game services
    for _, serviceName in ipairs(services) do
        local success, service = pcall(function() return game:GetService(serviceName) end)
        if success and service then
            findScriptsRecursive(service, "game." .. serviceName)
        end
    end
    
    -- Decompile scripts
    local decompiledScripts = {}
    
    for i, scriptData in ipairs(scripts) do
        if i % 5 == 0 then
            task.wait(0.01)
        end
        
        local source = "-- Could not decompile"
        
        if hasDecompile and scriptData.Instance then
            local success, result = pcall(function()
                return decompile(scriptData.Instance)
            end)
            
            if success and result then
                source = result
            else
                source = "-- Decompile failed: " .. tostring(result)
            end
        elseif not hasDecompile then
            source = "-- decompile() function not available in this executor"
        end
        
        table.insert(decompiledScripts, {
            Path = scriptData.Path,
            Name = scriptData.Name,
            Type = scriptData.Type,
            Source = source
        })
    end
    
    return decompiledScripts
end

function GameDumper:SaveToFile()
    local hasWriteFile = writefile ~= nil
    local hasMakeFolder = makefolder ~= nil
    
    if not hasWriteFile then
        if UILib then
            UILib:CreateNotification({
                Text = "writefile not available!",
                Duration = 5,
                Color = UILib.Colors.ERROR
            })
        end
        return false, "writefile not available"
    end
    
    -- Get game name and sanitize it for filename
    local gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
    gameName = gameName:gsub("[^%w%s-]", ""):gsub("%s+", "_")
    
    local folderName = gameName .. "_GameDump"
    
    -- Create folder structure
    if hasMakeFolder then
        makefolder(folderName)
        makefolder(folderName .. "/Scripts")
    end
    
    local savedFiles = {}
    
    -- Save hierarchy
    if UILib then
        UILib:CreateNotification({
            Text = "Saving hierarchy...",
            Duration = 2,
            Color = UILib.Colors.INFO
        })
    end
    
    local success, err = pcall(function()
        local hierarchyData = self:ExportEverything()
        local fileName = hasMakeFolder and (folderName .. "/Hierarchy.txt") or (gameName .. "_Hierarchy.txt")
        writefile(fileName, hierarchyData)
        table.insert(savedFiles, fileName)
    end)
    
    if not success then
        return false, err
    end
    
    -- Save remotes list
    if UILib then
        UILib:CreateNotification({
            Text = "Saving remotes...",
            Duration = 2,
            Color = UILib.Colors.INFO
        })
    end
    
    pcall(function()
        local remotesData = self:ExportRemotesToString()
        local fileName = hasMakeFolder and (folderName .. "/Remotes.txt") or (gameName .. "_Remotes.txt")
        writefile(fileName, remotesData)
        table.insert(savedFiles, fileName)
    end)
    
    -- Save values list
    if UILib then
        UILib:CreateNotification({
            Text = "Saving values...",
            Duration = 2,
            Color = UILib.Colors.INFO
        })
    end
    
    pcall(function()
        local valuesData = self:ExportValuesToString()
        local fileName = hasMakeFolder and (folderName .. "/Values.txt") or (gameName .. "_Values.txt")
        writefile(fileName, valuesData)
        table.insert(savedFiles, fileName)
    end)
    
    -- Save scripts list
    if UILib then
        UILib:CreateNotification({
            Text = "Saving scripts list...",
            Duration = 2,
            Color = UILib.Colors.INFO
        })
    end
    
    pcall(function()
        local scriptsData = self:ExportScriptsToString()
        local fileName = hasMakeFolder and (folderName .. "/ScriptsList.txt") or (gameName .. "_Scripts.txt")
        writefile(fileName, scriptsData)
        table.insert(savedFiles, fileName)
    end)
    
    -- Decompile and save scripts
    if UILib then
        UILib:CreateNotification({
            Text = "Decompiling scripts...",
            Duration = 3,
            Color = UILib.Colors.INFO
        })
    end
    
    local decompiledScripts = self:DecompileAllScripts()
    
    if UILib then
        UILib:CreateNotification({
            Text = string.format("Saving %d scripts...", #decompiledScripts),
            Duration = 3,
            Color = UILib.Colors.INFO
        })
    end
    
    for i, script in ipairs(decompiledScripts) do
        if i % 10 == 0 then
            task.wait(0.01)
        end
        
        pcall(function()
            -- Sanitize script name for filename
            local safeName = script.Name:gsub("[^%w%s-]", ""):gsub("%s+", "_")
            local scriptFileName = string.format("%s_%s.lua", script.Type, safeName)
            
            local fullPath
            if hasMakeFolder then
                fullPath = folderName .. "/Scripts/" .. scriptFileName
            else
                fullPath = gameName .. "_" .. scriptFileName
            end
            
            -- Add header comment with path
            local content = string.format("-- Path: %s\n-- Type: %s\n\n%s", script.Path, script.Type, script.Source)
            
            writefile(fullPath, content)
            table.insert(savedFiles, fullPath)
        end)
    end
    
    -- Return success with folder location
    if hasMakeFolder then
        return true, folderName .. "/ (" .. #savedFiles .. " files)"
    else
        return true, gameName .. "_* (" .. #savedFiles .. " files)"
    end
end

function GameDumper:DumpEverything()
    self.Stats.StartTime = tick()
    self.DumpData = {}
    self.Stats.TotalInstances = 0
    self.Stats.TotalRemotes = 0
    self.Stats.TotalValues = 0
    self.Stats.TotalScripts = 0
    processedCount = 0
    
    for i, serviceName in ipairs(services) do
        task.wait(0.1)
        
        -- Show progress notification
        if UILib then
            UILib:CreateNotification({
                Text = string.format("%s Completed! (%d/%d)", serviceName, i, #services),
                Duration = 2,
                Color = UILib.Colors.INFO
            })
        end
        
        local serviceData = DumpService(serviceName)
        self.DumpData[serviceName] = serviceData
    end
    
    self.Stats.EndTime = tick()
    
    return self.DumpData
end

-- Store globally for access
getgenv().GameDumper = GameDumper

-- ═══════════════════════════════════════════════════════════════
-- END GAME DUMPER MODULE
-- ═══════════════════════════════════════════════════════════════

-- Create Window with Specific Name for Cleanup
local Window = UILib:CreateWindow({
    Name = "DevToolsMainGui", -- Used for internal identification if needed
    Title = "DevTools Helper",
    Size = UDim2.fromOffset(600, 400),
    Position = UDim2.fromOffset(100, 100),
    DisplayOrder = 2000000000 -- Maximize Z-Index
})

-- DEBUG: Check if methods were attached
print("DEBUG: Window.ShowPanel exists?", Window.ShowPanel ~= nil)
print("DEBUG: UILib.AddMethods exists?", UILib.AddMethods ~= nil)

-- SAFETY: Ensure methods are attached (in case UILIB version mismatch)
if not Window.ShowPanel and UILib.AddMethods then
    print("DEBUG: Manually calling AddMethods...")
    UILib:AddMethods(Window)
end

-- Track Window GUI for cleanup
if Window.ScreenGui then
    table.insert(_G.DevTools.Guis, Window.ScreenGui)
    -- Force DisplayOrder to match NEXUSV1's working setup
    Window.ScreenGui.DisplayOrder = 10000
end

-- Create Panel (Tab)
local MainPanel = UILib:CreatePanel(Window, {
    Name = "Main",
    DisplayName = "Inspectors"
})

-- State Variables
local InspectPartMode = false
local InspectGuiMode = false
local InspectClickableMode = false

local SelectedObject = nil
local ClickTPMode = false
local NoclipMode = false

local HighlightBox = Instance.new("SelectionBox")
HighlightBox.LineThickness = 0.05
HighlightBox.Color3 = Color3.fromRGB(255, 0, 0)
HighlightBox.Parent = CoreGui
table.insert(_G.DevTools.Guis, HighlightBox) -- Cleanup HighlightBox

-- Better GUI Highlight Logic
local HighlightScreenGui = Instance.new("ScreenGui")
HighlightScreenGui.Name = "DevToolsHighlight"
HighlightScreenGui.IgnoreGuiInset = true
HighlightScreenGui.DisplayOrder = 10001 -- Just above main window
HighlightScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
table.insert(_G.DevTools.Guis, HighlightScreenGui) -- Cleanup HighlightScreenGui

local GuiHighlightFrame = Instance.new("Frame")
GuiHighlightFrame.BackgroundTransparency = 0.7
GuiHighlightFrame.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
GuiHighlightFrame.BorderColor3 = Color3.fromRGB(0, 255, 0)
GuiHighlightFrame.BorderSizePixel = 2
GuiHighlightFrame.Visible = false
GuiHighlightFrame.Active = false -- IMPORTANT: Do not capture input
GuiHighlightFrame.Selectable = false
GuiHighlightFrame.Parent = HighlightScreenGui

-- Helper Functions
local function getTargetPart()
    return Mouse.Target
end

local function getTargetGui(onlyClickable)
    local guis = LocalPlayer.PlayerGui:GetGuiObjectsAtPosition(Mouse.X, Mouse.Y)
    for _, gui in ipairs(guis) do
        -- If we hit our own highlighter, ignore it and look deeper
        if gui:IsDescendantOf(HighlightScreenGui) then
            continue
        end
        
        -- If we hit our own Menu, STOP inspecting.
        if Window.ScreenGui and gui:IsDescendantOf(Window.ScreenGui) then
            return nil
        end
        
        -- Also ignore other common dev/admin panels if usually in CoreGui/PlayerGui, 
        -- but avoiding specific names unless known.

        if gui.Visible then
            if onlyClickable then
                if gui:IsA("GuiButton") or gui:IsA("TextBox") then
                    return gui
                end
            else
                return gui
            end
        end
    end
    return nil
end

local function setSelected(obj)
    SelectedObject = obj
    print("Selected:", obj:GetFullName())
    
    -- If it's a GUI, also print screen position
    if obj:IsA("GuiObject") then
        local absPos = obj.AbsolutePosition
        local absSize = obj.AbsoluteSize
        local centerX = absPos.X + absSize.X / 2
        local centerY = absPos.Y + absSize.Y / 2
        
        print(string.format("  Position: X=%d, Y=%d", absPos.X, absPos.Y))
        print(string.format("  Size: W=%d, H=%d", absSize.X, absSize.Y))
        print(string.format("  Center: X=%d, Y=%d", centerX, centerY))
    end
    
    -- Visual Feedback
    pcall(function()
        local notifText = "Selected: " .. obj.Name
        if obj:IsA("GuiObject") then
            local absPos = obj.AbsolutePosition
            notifText = notifText .. string.format(" @ (%d, %d)", absPos.X, absPos.Y)
        end
        UILib:CreateNotification({
            Text = notifText,
            Duration = 3
        })
    end)
end

-- Input Handling
local inputConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    -- Toggle GUI Visibility (Requested: Right Shift)
    if input.KeyCode == Enum.KeyCode.RightShift then
        if Window.ScreenGui then
            Window.ScreenGui.Enabled = not Window.ScreenGui.Enabled
        end
        return
    end

    -- PANIC KEY: Disable all modes (Swapped to Right Control)
    if input.KeyCode == Enum.KeyCode.RightControl then
        InspectPartMode = false
        InspectGuiMode = false
        InspectClickableMode = false
        SelectedObject = nil
        ClickTPMode = false
        NoclipMode = false
        
        pcall(function()
            UILib:CreateNotification({Text = "SAFE MODE: All Tools Disabled", Duration = 3, Color = UILib.Colors.WARNING})
        end)
        return
    end
    
    -- Click to Inspect/Select
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        
        -- Logic:
        -- If inspecting GUI, we WANT to capture clicks on GUI elements (so we ignore gameProcessed).
        -- If inspecting Parts, we DO NOT want to capture clicks on GUI elements (so we respect gameProcessed).
        
        if InspectGuiMode or InspectClickableMode then
            -- GUI Inspection Mode: Inspect regardless of gameProcessed
            local onlyClickable = InspectClickableMode
            local gui = getTargetGui(onlyClickable)
            if gui then 
                setSelected(gui) 
            end
            
        elseif InspectPartMode then
            -- Part Inspection Mode: Only inspect if we didn't click a UI
            if not gameProcessed then
                local part = getTargetPart()
                if part then setSelected(part) end
            end
            
        else
            -- Not inspecting anything? Respect gameProcessed
            if gameProcessed then return end
            
            -- Click TP logic
            if ClickTPMode and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                local pos = Mouse.Hit
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pos.X, pos.Y + 3, pos.Z)
                end
            end
        end
    end
end)
table.insert(_G.DevTools.Connections, inputConn)

-- Render Loop for Highlights & Noclip
local noclipConn = RunService.Stepped:Connect(function()
    if NoclipMode and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide == true then
                v.CanCollide = false
            end
        end
    end
end)
table.insert(_G.DevTools.Connections, noclipConn)

local renderConn = RunService.RenderStepped:Connect(function()
    HighlightBox.Adornee = nil
    GuiHighlightFrame.Visible = false
    
    -- Highlight hovered item
    if InspectPartMode then
        local part = getTargetPart()
        if part then HighlightBox.Adornee = part end
    elseif InspectGuiMode or InspectClickableMode then
        local gui = getTargetGui(InspectClickableMode)
        if gui then
            GuiHighlightFrame.Visible = true
            GuiHighlightFrame.Size = UDim2.fromOffset(gui.AbsoluteSize.X, gui.AbsoluteSize.Y)
            
            -- Fix Offset: Subtract TopBar Inset if necessary
            local inset = game:GetService("GuiService"):GetGuiInset()
            GuiHighlightFrame.Position = UDim2.fromOffset(gui.AbsolutePosition.X, gui.AbsolutePosition.Y + inset.Y) 
            -- Note: If IgnoreGuiInset=true (line 102), (0,0) is top-left of screen
        end
    end
end)
table.insert(_G.DevTools.Connections, renderConn)

-- UI Setup
UILib:CreateToggle(MainPanel, {
    Label = "Inspect Part",
    Callback = function(state)
        InspectPartMode = state
        InspectGuiMode = false
        InspectClickableMode = false
    end
})

UILib:CreateToggle(MainPanel, {
    Label = "Inspect GUI",
    Callback = function(state)
        InspectGuiMode = state
        InspectPartMode = false
        InspectClickableMode = false
    end
})

UILib:CreateToggle(MainPanel, {
    Label = "Inspect Clickable GUI",
    Callback = function(state)
        InspectClickableMode = state
        InspectPartMode = false
        InspectGuiMode = false
    end
})

-- Update Copy Path Button
UILib:CreateButton(MainPanel, {
    Text = "Copy Selected Path",
    Callback = function()
        if SelectedObject then
            local path = SelectedObject:GetFullName()
            setclipboard(path)
            UILib:CreateNotification({Text = "Copied: " .. path, Duration = 3})
        else
            UILib:CreateNotification({Text = "No object selected!", Duration = 2, Color = UILib.Colors.ERROR})
        end
    end
})

UILib:CreateButton(MainPanel, {
    Text = "Copy Position / UDim2",
    Callback = function()
        if SelectedObject then
            if SelectedObject:IsA("BasePart") then
                local p = SelectedObject.Position
                setclipboard(string.format("Vector3.new(%.3f, %.3f, %.3f)", p.X, p.Y, p.Z))
            elseif SelectedObject:IsA("GuiObject") then
                 local p = SelectedObject.Position
                 setclipboard(string.format("UDim2.new(%.3f, %.3f, %.3f, %.3f)", p.X.Scale, p.X.Offset, p.Y.Scale, p.Y.Offset))
            end
            UILib:CreateNotification({Text = "Copied Data!", Duration = 2})
        else
             UILib:CreateNotification({Text = "No object selected!", Duration = 2, Color = UILib.Colors.ERROR})
        end
    end
})

-- Utils Panel
local UtilsPanel = UILib:CreatePanel(Window, {
    Name = "Utils",
    DisplayName = "Utilities"
})

UILib:CreateToggle(UtilsPanel, {
    Label = "Click TP (Ctrl+Click)",
    Callback = function(state)
        ClickTPMode = state
    end
})

UILib:CreateToggle(UtilsPanel, {
    Label = "Noclip",
    Callback = function(state)
        NoclipMode = state
    end
})

UILib:CreateButton(UtilsPanel, {
    Text = "Copy Player Location",
    Callback = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local pos = LocalPlayer.Character.HumanoidRootPart.Position
            local str = string.format("Vector3.new(%.2f, %.2f, %.2f)", pos.X, pos.Y, pos.Z)
            setclipboard(str)
            UILib:CreateNotification({Text = "Copied location!", Duration = 3})
        end
    end
})

UILib:CreateButton(UtilsPanel, {
    Text = "Copy Player CFrame",
    Callback = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local cf = LocalPlayer.Character.HumanoidRootPart.CFrame
            local components = {cf:GetComponents()}
            local str = string.format(
                "CFrame.new(%.2f, %.2f, %.2f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f)",
                components[1], components[2], components[3],
                components[4], components[5], components[6],
                components[7], components[8], components[9],
                components[10], components[11], components[12]
            )
            setclipboard(str)
            UILib:CreateNotification({Text = "Copied CFrame (position + orientation)!", Duration = 3})
        end
    end
})

UILib:CreateButton(UtilsPanel, {
    Text = "Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end
})

UILib:CreateButton(UtilsPanel, {
    Text = "Close Script",
    Callback = function()
        -- Disconnect all connections
        if _G.DevTools and _G.DevTools.Connections then
            for _, conn in ipairs(_G.DevTools.Connections) do
                conn:Disconnect()
            end
        end
        
        -- Destroy all GUIs
        if _G.DevTools and _G.DevTools.Guis then
            for _, gui in ipairs(_G.DevTools.Guis) do
                if gui then gui:Destroy() end
            end
        end
        
        -- Clear the global table
        _G.DevTools = nil
        
        UILib:CreateNotification({
            Text = "DevTools Closed!",
            Duration = 2
        })
    end
})

-- ═══════════════════════════════════════════════════════════════
-- DUMPER PANEL
-- ═══════════════════════════════════════════════════════════════

local DumperPanel = UILib:CreatePanel(Window, {
    Name = "Dumper",
    DisplayName = "Game Dumper"
})

UILib:CreateButton(DumperPanel, {
    Text = "Dump Game",
    Callback = function()
        UILib:CreateNotification({
            Text = "Starting dump...",
            Duration = 3,
            Color = UILib.Colors.INFO
        })
        
        task.spawn(function()
            local success, err = pcall(function()
                -- Dump everything
                GameDumper:DumpEverything()
                
                -- Immediately save to file
                local saveSuccess, result = GameDumper:SaveToFile()
                
                if saveSuccess then
                    -- Show completion notification with file location
                    local statsText = string.format(
                        "Dump Complete! Saved to: %s | Instances: %d | Scripts: %d | Remotes: %d | Values: %d",
                        result,
                        GameDumper.Stats.TotalInstances,
                        GameDumper.Stats.TotalScripts,
                        GameDumper.Stats.TotalRemotes,
                        GameDumper.Stats.TotalValues
                    )
                    
                    UILib:CreateNotification({
                        Text = statsText,
                        Duration = 8,
                        Color = UILib.Colors.SUCCESS
                    })
                else
                    UILib:CreateNotification({
                        Text = "Failed to save: " .. tostring(result),
                        Duration = 5,
                        Color = UILib.Colors.ERROR
                    })
                end
            end)
            
            if not success then
                UILib:CreateNotification({
                    Text = "Dump failed: " .. tostring(err),
                    Duration = 5,
                    Color = UILib.Colors.ERROR
                })
            end
        end)
    end
})

-- Show the first panel by default
Window:ShowPanel("Main")
