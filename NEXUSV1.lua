local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

-- Hardcoded Y-Axis Offset for Breach Protocol (calibrated to 50)
local BREACH_Y_OFFSET = 50

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
    warn("Failed to load UILIB. Please check file/connection.")
    return
end

-- Create Window
local Window = UILib:CreateWindow({
    Name = "NexusHubMain",
    Title = "Cyberpunk Nexus",
    Size = UDim2.fromOffset(600, 400),
    Position = UDim2.fromOffset(100, 100),
    AccentColor = UILib.Colors.JPUFF_HOT_PINK
})

-- MONKEY PATCH: Ensure Window has necessary methods if UILib didn't attach them (e.g. loading from Web)
if not Window.ShowPanel then
    Window.ShowPanel = function(self, panelName)
        if UILib.ShowPanel then
            UILib:ShowPanel(self, panelName)
        end
    end
end
if not Window.HidePanel then
    Window.HidePanel = function(self, panelName)
        if UILib.HidePanel then
            UILib:HidePanel(self, panelName)
        end
    end
end
if not Window.Destroy then
    Window.Destroy = function(self)
        if self.ScreenGui then self.ScreenGui:Destroy() end
    end
end
if not Window.CreatePanel then
    Window.CreatePanel = function(self, config)
        if UILib.CreatePanel then
            return UILib:CreatePanel(self, config)
        end
    end
end
if not Window.AddToggleKey then
    Window.AddToggleKey = function(self, keyCode)
        if UILib.AddToggleKey then
            UILib:AddToggleKey(self, keyCode)
        end
    end
end

-- Ensure GUI is on top of Game UIs (Safeguarded)
if Window.ScreenGui then
    Window.ScreenGui.DisplayOrder = 10000
end

-- Add Toggle Key
Window:AddToggleKey(Enum.KeyCode.RightShift)
UILib:CreateNotification({Text = "Press Right Shift to Toggle UI", Duration = 5})

print("Window Created. Adding Panels...")

-- Shared Solver Logic (Refactored)
local function SolveBreach()
    -- 1. Locate the UI
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    local breachUI = nil
    local neoHotbar = playerGui:FindFirstChild("NeoHotbar")
    if neoHotbar then
        local breachProtocol = neoHotbar:FindFirstChild("BreachProtocol")
        if breachProtocol then
            breachUI = breachProtocol:FindFirstChild("Main")
        end
    end

    if not breachUI then
        UILib:CreateNotification({Text = "Breach Protocol UI not found! Open the minigame first.", Duration = 3, Color = UILib.Colors.ERROR})
        return
    end

    local gridFolder = breachUI:FindFirstChild("Grid")
    local goalFolder = breachUI:FindFirstChild("GoalSequence")
    
    if not gridFolder or not goalFolder then
        UILib:CreateNotification({Text = "Grid or GoalSequence not found!", Duration = 3, Color = UILib.Colors.ERROR})
        return
    end

    UILib:CreateNotification({Text = "Breach UI Found. Reading grid...", Duration = 1})
    
    -- 2. Read Grid & Goals
    local matrix = {} -- [row][col] = code string
    
    -- Initialize 5x5 grid
    for r = 1, 5 do
        matrix[r] = {}
    end
    
    -- Read all 25 buttons
    for buttonNum = 1, 25 do
        local btn = gridFolder:FindFirstChild(tostring(buttonNum))
        if btn then
            local row = math.ceil(buttonNum / 5)
            local col = ((buttonNum - 1) % 5) + 1
            matrix[row][col] = btn.Text or ""
        end
    end
    
    -- Read goal sequence
    local goalSequence = {}
    local goalIndex = 1
    while true do
        local goalBtn = goalFolder:FindFirstChild(tostring(goalIndex))
        if not goalBtn then break end
        table.insert(goalSequence, goalBtn.Text or "")
        goalIndex = goalIndex + 1
    end
    
    if #goalSequence == 0 then
        UILib:CreateNotification({Text = "No goals found!", Duration = 3, Color = UILib.Colors.ERROR})
        return
    end
    
    -- 3. Solve (DFS) with Auto-Detection
    local activeRow = nil
    local activeCol = nil
    local maxGreenCount = 0
    local GREEN_COLOR = Color3.fromRGB(71, 98, 58)
    
    -- Check Rows
    for r = 1, 5 do
        local count = 0
        for c = 1, 5 do
            local btn = gridFolder:FindFirstChild(tostring((r-1)*5 + c))
            if btn and btn.BackgroundColor3 == GREEN_COLOR then count = count + 1 end
        end
        if count > maxGreenCount then
            maxGreenCount = count
            activeRow = r
            activeCol = nil
        end
    end
    
    -- Check Cols
    for c = 1, 5 do
        local count = 0
        for r = 1, 5 do
            local btn = gridFolder:FindFirstChild(tostring((r-1)*5 + c))
            if btn and btn.BackgroundColor3 == GREEN_COLOR then count = count + 1 end
        end
        if count > maxGreenCount then
            maxGreenCount = count
            activeCol = c
            activeRow = nil
        end
    end
    
    if not activeRow and not activeCol then activeRow = 1 end
    
    UILib:CreateNotification({Text = "Detected Start: " .. (activeRow and ("Row " .. activeRow) or ("Col " .. activeCol)), Duration = 2})

    local function solve(currentIdx, currentType, used, goalIndex, path)
        if goalIndex > #goalSequence then return path end
        local targetCode = goalSequence[goalIndex]
        if #path == 0 then
            if currentType == "Row" then
                for c = 1, 5 do
                    if matrix[currentIdx][c] == targetCode then
                        local res = solve(c, "Col", {[currentIdx .. "," .. c] = true}, goalIndex + 1, {{currentIdx, c}})
                        if res then return res end
                    end
                end
            else
                for r = 1, 5 do
                    if matrix[r][currentIdx] == targetCode then
                        local res = solve(r, "Row", {[r .. "," .. currentIdx] = true}, goalIndex + 1, {{r, currentIdx}})
                        if res then return res end
                    end
                end
            end
            return nil
        end
        if currentType == "Row" then
            for c = 1, 5 do
                 local key = currentIdx .. "," .. c
                 if not used[key] and matrix[currentIdx][c] == targetCode then
                     local newUsed = {}
                     for k,v in pairs(used) do newUsed[k]=v end
                     newUsed[key] = true
                     local newPath = {}
                     for _,v in ipairs(path) do table.insert(newPath, v) end
                     table.insert(newPath, {currentIdx, c})
                     local res = solve(c, "Col", newUsed, goalIndex + 1, newPath)
                     if res then return res end
                 end
            end
        else
            for r = 1, 5 do
                 local key = r .. "," .. currentIdx
                 if not used[key] and matrix[r][currentIdx] == targetCode then
                     local newUsed = {}
                     for k,v in pairs(used) do newUsed[k]=v end
                     newUsed[key] = true
                     local newPath = {}
                     for _,v in ipairs(path) do table.insert(newPath, v) end
                     table.insert(newPath, {r, currentIdx})
                     local res = solve(r, "Row", newUsed, goalIndex + 1, newPath)
                     if res then return res end
                 end
            end
        end
        return nil
    end
    
    local solutionPath = activeRow and solve(activeRow, "Row", {}, 1, {}) or solve(activeCol, "Col", {}, 1, {})
    
    if solutionPath then
        UILib:CreateNotification({Text = "Solution found! Executing...", Duration = 2})
        task.spawn(function()
            if Window.ScreenGui then Window.ScreenGui.Enabled = false end
            task.wait(0.3)
            
            local vim = game:GetService("VirtualInputManager")
            local debugGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
            debugGui.Name = "BreachSolverDebug"
            debugGui.IgnoreGuiInset = true 
            debugGui.DisplayOrder = 10000

            local manualOffset = BREACH_Y_OFFSET

            for i, coords in ipairs(solutionPath) do
                local r_logic, c_logic = coords[1], coords[2]
                local buttonNum = (r_logic - 1) * 5 + c_logic
                
                local btn = gridFolder:FindFirstChild(tostring(buttonNum))
                if btn then
                    local absPos = btn.AbsolutePosition
                    local absSize = btn.AbsoluteSize
                    local center = absPos + absSize/2
                    local centerX = center.X
                    local centerY = center.Y + manualOffset
                    
                    local marker = Instance.new("Frame", debugGui)
                    marker.Size = UDim2.fromOffset(6, 6)
                    marker.Position = UDim2.fromOffset(centerX - 3, centerY - 3) 
                    marker.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                    Instance.new("UICorner", marker).CornerRadius = UDim.new(1,0)
                    
                    vim:SendMouseMoveEvent(centerX, centerY, game)
                    local jitterCount = (i == 1) and 2 or 1 
                    for j = 1, jitterCount do
                        vim:SendMouseMoveEvent(centerX + 5, centerY + 5, game)
                        task.wait(0.03)
                        vim:SendMouseMoveEvent(centerX - 5, centerY - 5, game)
                        task.wait(0.03)
                        vim:SendMouseMoveEvent(centerX, centerY, game)
                        task.wait(0.03)
                    end
                    task.wait(0.1)
                    vim:SendMouseButtonEvent(centerX, centerY, 0, true, game, 1)
                    task.wait(0.1) 
                    vim:SendMouseButtonEvent(centerX, centerY, 0, false, game, 1)
                    marker:Destroy()
                end
                task.wait(0.4) 
            end
            debugGui:Destroy() 
            task.wait(0.5)
            if Window.ScreenGui then Window.ScreenGui.Enabled = true end
            UILib:CreateNotification({Text = "Execution Complete!", Duration = 3})
        end)
    else
        UILib:CreateNotification({Text = "No solution found. Auto-retrying...", Duration = 2, Color = UILib.Colors.WARNING})
        task.spawn(function()
            if Window.ScreenGui then Window.ScreenGui.Enabled = false end
            task.wait(0.3)
            local vim = game:GetService("VirtualInputManager")
            local firstBtn = gridFolder:FindFirstChild("1")
            if firstBtn then
                local absPos = firstBtn.AbsolutePosition
                local absSize = firstBtn.AbsoluteSize
                local center = absPos + absSize/2
                local clickX = center.X
                local clickY = center.Y + BREACH_Y_OFFSET
                vim:SendMouseMoveEvent(clickX, clickY, game)
                task.wait(0.1)
                vim:SendMouseButtonEvent(clickX, clickY, 0, true, game, 1)
                task.wait(0.1)
                vim:SendMouseButtonEvent(clickX, clickY, 0, false, game, 1)
            end
            task.wait(1.5)
            if Window.ScreenGui then Window.ScreenGui.Enabled = true end
            task.wait(0.5)
            SolveBreach() -- Recursive call
        end)
    end
end

-- Teleports Panel
local TeleportPanel = Window:CreatePanel({
    Name = "Teleports",
    DisplayName = "Teleports"
})




UILib:CreateButton(TeleportPanel, {
    Text = "Teleport to Accessory Crate",
    Callback = function()
        local cratesFolder = Workspace:FindFirstChild("Crates") and Workspace.Crates:FindFirstChild("AccessoryCrates")
        
        if cratesFolder then
            local found = false
            for _, crate in ipairs(cratesFolder:GetChildren()) do
                -- User mentioned "AccessoryCrate" as a name, but we can search for any valid model with "colorable"
                if crate.Name == "AccessoryCrate" and crate:FindFirstChild("colorable") then
                    local targetPart = crate.colorable
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        -- Teleport slightly above the target part to avoid getting stuck
                        LocalPlayer.Character.HumanoidRootPart.CFrame = targetPart.CFrame + Vector3.new(0, 5, 0)
                        UILib:CreateNotification({
                            Text = "Teleported to Crate!",
                            Duration = 3
                        })
                        found = true
                        break -- Found one, so stop
                    end
                end
            end
            
            if not found then
                 UILib:CreateNotification({
                    Text = "No available Accessory Crates found.",
                    Duration = 3,
                    Color = UILib.Colors.ERROR
                })
            end
        else
            UILib:CreateNotification({
                Text = "Crates folder not found!",
                Duration = 3,
                Color = UILib.Colors.ERROR
            })
        end
    end
})

-- Auto Loot Toggle
UILib:CreateToggle(TeleportPanel, {
    Label = "Auto Farm Crates (Beta)",
    Callback = function(state)
        getgenv().AutoLoot = state
        if state then
            task.spawn(function()
                while getgenv().AutoLoot do
                    -- 1. Scan for Crates (Unopened)
                    local cratesFolder = Workspace:FindFirstChild("Crates") and Workspace.Crates:FindFirstChild("AccessoryCrates")
                    local targetCrate = nil
                    
                    if cratesFolder then
                        -- Find closest crate that has ProximityPrompt
                        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if myRoot then
                            local shortestDist = math.huge
                            
                            for _, crate in ipairs(cratesFolder:GetChildren()) do
                                if crate.Name == "AccessoryCrate" then
                                    local prompt = nil
                                    for _, desc in ipairs(crate:GetDescendants()) do
                                        if desc:IsA("ProximityPrompt") and desc.Enabled then
                                            prompt = desc
                                            break
                                        end
                                    end
                                    
                                    if prompt then
                                        local dist = (crate.PrimaryPart.Position - myRoot.Position).Magnitude
                                        if dist < shortestDist then
                                            shortestDist = dist
                                            targetCrate = {Model = crate, Prompt = prompt}
                                        end
                                    end
                                end
                            end
                        end
                    end
                    
                    if targetCrate then
                        UILib:CreateNotification({Text = "Target Found. Teleporting...", Duration = 1})
                        
                        -- 2. Teleport
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            local tPos = targetCrate.Model.PrimaryPart.CFrame
                            LocalPlayer.Character.HumanoidRootPart.CFrame = tPos + Vector3.new(0, 3, 0)
                            task.wait(0.5)
                        end
                         
                        -- 3. Interact
                        if targetCrate.Prompt and targetCrate.Prompt.Enabled then
                            fireproximityprompt(targetCrate.Prompt)
                            task.wait(1.5)
                        end
                        
                        -- 4. Check for Outcomes
                        -- A: Minigame
                        local pg = LocalPlayer.PlayerGui
                        local breach = pg:FindFirstChild("NeoHotbar") and pg.NeoHotbar:FindFirstChild("BreachProtocol") and pg.NeoHotbar.BreachProtocol:FindFirstChild("Main")
                        
                        if breach and breach.Visible then
                             UILib:CreateNotification({Text = "Minigame Detected! Solving...", Duration = 2})
                             SolveBreach()
                             task.wait(2)
                             local start = tick()
                             while (tick() - start < 10) do
                                 if not breach.Visible then break end
                                 task.wait(0.5)
                             end
                        end
                        
                        -- B: Loot UI
                        local mainFrame = pg:FindFirstChild("Main") and pg.Main:FindFirstChild("MainFrame")
                        local lootUI = mainFrame and mainFrame:FindFirstChild("LootCrate")
                        
                        if lootUI and lootUI.Visible then
                            local container = lootUI:FindFirstChild("Container")
                            if container then
                                for _, item in ipairs(container:GetChildren()) do
                                    if item:IsA("GuiObject") and item.Visible then 
                                        local absPos = item.AbsolutePosition
                                        local absSize = item.AbsoluteSize
                                        local cx, cy = absPos.X + absSize.X/2, absPos.Y + absSize.Y/2 + 36 
                                        
                                        game:GetService("VirtualInputManager"):SendMouseButtonEvent(cx, cy, 0, true, game, 1)
                                        task.wait(0.05)
                                        game:GetService("VirtualInputManager"):SendMouseButtonEvent(cx, cy, 0, false, game, 1)
                                        task.wait(0.2)
                                    end
                                end
                            end
                            task.wait(0.5)
                        end
                    else
                        UILib:CreateNotification({Text = "No crates found. Waiting...", Duration = 2})
                        task.wait(3)
                    end
                    
                    task.wait(1)
                end
            end)
        end
    end
})

-- Minigames Panel
local MinigamesPanel = Window:CreatePanel({
    Name = "Minigames",
    DisplayName = "Minigames"
})

UILib:CreateButton(MinigamesPanel, {
    Text = "Solve Breach Protocol",
    Callback = function()
        SolveBreach()
    end
})

UILib:CreateButton(MinigamesPanel, {
    Text = "Copy Breach Debug Info",
    Callback = function()
        local playerGui = LocalPlayer:WaitForChild("PlayerGui")
        local breachUI = nil
        local neoHotbar = playerGui:FindFirstChild("NeoHotbar")
        if neoHotbar then
            local breachProtocol = neoHotbar:FindFirstChild("BreachProtocol")
            if breachProtocol then
                breachUI = breachProtocol:FindFirstChild("Main")
            end
        end

        if not breachUI then
            UILib:CreateNotification({Text = "Open the Breach Protocol minigame first!", Duration = 2, Color = UILib.Colors.ERROR})
            return
        end

        local gridFolder = breachUI:FindFirstChild("Grid")
        local goalFolder = breachUI:FindFirstChild("GoalSequence")
        
        if not gridFolder or not goalFolder then
            UILib:CreateNotification({Text = "Grid or GoalSequence not found!", Duration = 2, Color = UILib.Colors.ERROR})
            return
        end

        local output = "=== BREACH PROTOCOL DEBUG ===\n\n"
        
        -- Read Grid
        output = output .. "GRID (5x5) [Values | Colors]:\n"
        for row = 1, 5 do
            local rowCodes = {}
            local rowColors = {}
            for col = 1, 5 do
                local buttonNum = (row - 1) * 5 + col
                local btn = gridFolder:FindFirstChild(tostring(buttonNum))
                if btn then
                    table.insert(rowCodes, btn.Text or "??")
                    local col3 = btn.BackgroundColor3
                    local hex = string.format("#%02X%02X%02X", math.floor(col3.R*255), math.floor(col3.G*255), math.floor(col3.B*255))
                    table.insert(rowColors, hex)
                else
                    table.insert(rowCodes, "??")
                    table.insert(rowColors, "??")
                end
            end
            output = output .. "Row " .. row .. ": " .. table.concat(rowCodes, " | ") .. "   [Colors: " .. table.concat(rowColors, ", ") .. "]\n"
        end
        
        -- Read Goals
        output = output .. "\nGOAL SEQUENCE:\n"
        local goalIndex = 1
        while true do
            local goalBtn = goalFolder:FindFirstChild(tostring(goalIndex))
            if not goalBtn then break end
            output = output .. goalIndex .. ". " .. (goalBtn.Text or "??") .. "\n"
            goalIndex = goalIndex + 1
        end
        
        output = output .. "\n=== END DEBUG ==="
        
        setclipboard(output)
        UILib:CreateNotification({Text = "Debug info copied to clipboard!", Duration = 2})
    end
})


-- Settings Panel
local SettingsPanel = Window:CreatePanel({
    Name = "Settings",
    DisplayName = "Settings"
})

UILib:CreateButton(SettingsPanel, {
    Text = "Close GUI",
    Color = UILib.Colors.ERROR,
    Callback = function()
        Window:Destroy()
        -- Also clear global to allow re-execution
        if _G.DevTools and _G.DevTools.Guis then
             -- This logic is specific to DevTools wrapper, but NEXUSV1 might run standalone.
             -- If standard UILib usage:
             -- Window:Destroy() handles ScreenGui destroy.
        end
    end
})

-- Show default panel
Window:ShowPanel("Teleports")
