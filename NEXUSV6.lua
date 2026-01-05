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

-- PATCH: CreateSlider if missing (e.g. loaded from web)
if not UILib.CreateSlider then
    UILib.CreateSlider = function(self, panel, config)
        config = config or {}
        local text = config.Text or "Slider"
        local min = config.Min or 0
        local max = config.Max or 100
        local default = config.Default or min
        local callback = config.Callback or function() end
        local y = panel.ContentY
    
        local label = Instance.new("TextLabel", panel.Frame)
        label.Size = UDim2.new(1, -40, 0, 20)
        label.Position = UDim2.fromOffset(30, y)
        label.BackgroundTransparency = 1
        label.Text = text
        label.Font = Enum.Font.GothamMedium
        label.TextSize = 14
        label.TextColor3 = UILib.Colors.TEXT_PRIMARY
        label.TextXAlignment = Enum.TextXAlignment.Left
        
        local valueLabel = Instance.new("TextLabel", panel.Frame)
        valueLabel.Size = UDim2.new(0, 50, 0, 20)
        valueLabel.Position = UDim2.new(1, -80, 0, y)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = tostring(default)
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.TextSize = 14
        valueLabel.TextColor3 = UILib.Colors.JPUFF_PINK
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        
        local sliderBg = Instance.new("Frame", panel.Frame)
        sliderBg.Size = UDim2.new(1, -60, 0, 8)
        sliderBg.Position = UDim2.fromOffset(30, y + 25)
        sliderBg.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        sliderBg.BorderSizePixel = 0
        Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)
        
        local sliderFill = Instance.new("Frame", sliderBg)
        sliderFill.Size = UDim2.fromScale((default - min) / (max - min), 1)
        sliderFill.BackgroundColor3 = UILib.Colors.JPUFF_HOT_PINK
        sliderFill.BorderSizePixel = 0
        Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)
        
        local sliderKnob = Instance.new("Frame", sliderBg)
        sliderKnob.Size = UDim2.fromOffset(16, 16)
        sliderKnob.AnchorPoint = Vector2.new(0.5, 0.5)
        sliderKnob.Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
        sliderKnob.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
        sliderKnob.BorderSizePixel = 0
        Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(1, 0)
        
        local btn = Instance.new("TextButton", sliderBg)
        btn.Size = UDim2.fromScale(1, 1)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        
        local dragging = false
        local TweenService = game:GetService("TweenService")
        local UserInputService = game:GetService("UserInputService")
        
        local function update(input)
            local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + ((max - min) * pos))
            
            TweenService:Create(sliderFill, TweenInfo.new(0.05), {Size = UDim2.fromScale(pos, 1)}):Play()
            TweenService:Create(sliderKnob, TweenInfo.new(0.05), {Position = UDim2.new(pos, 0, 0.5, 0)}):Play()
            valueLabel.Text = tostring(value)
            
            callback(value)
        end
        
        btn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                update(input)
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                update(input)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        
        panel.ContentY = panel.ContentY + 50
    
        return {
            SetValue = function(val)
                local pos = math.clamp((val - min) / (max - min), 0, 1)
                TweenService:Create(sliderFill, TweenInfo.new(0.2), {Size = UDim2.fromScale(pos, 1)}):Play()
                TweenService:Create(sliderKnob, TweenInfo.new(0.2), {Position = UDim2.new(pos, 0, 0.5, 0)}):Play()
                valueLabel.Text = tostring(val)
            end
        }
    end
end

-- PATCH: CreateLabel if missing (e.g. loaded from web)
if not UILib.CreateLabel then
    UILib.CreateLabel = function(self, panel, config)
        config = config or {}
        local text = config.Text or "Label"
        local color = config.Color or UILib.Colors.TEXT_PRIMARY
        local y = panel.ContentY
        
        local label = Instance.new("TextLabel", panel.Frame)
        label.Size = UDim2.new(1, -40, 0, 20)
        label.Position = UDim2.fromOffset(30, y)
        label.BackgroundTransparency = 1
        label.Text = text
        label.Font = Enum.Font.GothamMedium
        label.TextSize = 14
        label.TextColor3 = color
        label.TextXAlignment = Enum.TextXAlignment.Left
        
        panel.ContentY = panel.ContentY + 25
        
        return {
            SetText = function(self, newText)
                label.Text = newText
            end
        }
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
print("Window Created. Adding Panels...")

-- V6 Stability: Thread Management
getgenv().AutoLootUID = (getgenv().AutoLootUID or 0) + 1
getgenv().EnableAutoSell = (getgenv().EnableAutoSell == nil and true or getgenv().EnableAutoSell)

-- Helper: Safe Execution Wrapper
local function SafeExecute(name, func, ...)
    local success, err = pcall(func, ...)
    if not success then
        warn("Nexus V6 [ERROR in " .. name .. "]:", err)
        UILib:CreateNotification({Text = "Error in " .. name .. ": Check console", Duration = 3, Color = UILib.Colors.ERROR})
    end
    return success
end

-- Helper: Freeze Player (BodyVelocity for Interaction Compatibility)
local function FreezePlayer(freeze)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        if freeze then
            -- Use BodyVelocity to hold place but allow interactions (Anchored prevents Prompt triggering)
            if not hrp:FindFirstChild("HoldPos") then
                local bv = Instance.new("BodyVelocity", hrp)
                bv.Name = "HoldPos"
                bv.Velocity = Vector3.new(0,0,0)
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bv.P = 10000
            end
        else
            if hrp:FindFirstChild("HoldPos") then
                hrp.HoldPos:Destroy()
            end
        end
    end
end

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
            SafeExecute("BreachRetry", function()
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
        end)
    end
end
local function SafeSolveBreach() SafeExecute("SolveBreach", SolveBreach) end

-- Auto Sell Logic (Fixed)
local function PerformAutoSell()
    if Window.ScreenGui then Window.ScreenGui.Enabled = false end
    UILib:CreateNotification({Text = "Starting Auto Sell...", Duration = 3})
    
    -- 1. Locate Dealer (User: Workspace.DialogueNPC.ItemSell.Torso)
    local dealerLoc = Workspace:FindFirstChild("DialogueNPC") and Workspace.DialogueNPC:FindFirstChild("ItemSell")
    if not dealerLoc then
         -- Fallback search
         for _, child in ipairs(Workspace:GetChildren()) do
             if child.Name == "DialogueNPC" and child:FindFirstChild("ItemSell") then
                 dealerLoc = child.ItemSell
                 break
             end
         end
    end
    
    if not dealerLoc or not dealerLoc:FindFirstChild("Torso") then
        UILib:CreateNotification({Text = "Dealer 'ItemSell' not found!", Duration = 3, Color = UILib.Colors.ERROR})
        return
    end
    
    -- 2. Teleport
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        -- Teleport ON TOP of the seller (5 studs up) as requested
        LocalPlayer.Character.HumanoidRootPart.CFrame = dealerLoc.Torso.CFrame + Vector3.new(0, 5, 0)
        FreezePlayer(true) 
        -- Optimization: Reduced Wait
        task.wait(0.2)
    end
    
    -- 3. Interact (Find Prompt)
    local prompt = nil
    for _, desc in ipairs(dealerLoc:GetDescendants()) do
        if desc:IsA("ProximityPrompt") then
            prompt = desc
            break
        end
    end
    
    if prompt then
        fireproximityprompt(prompt)
        -- Optimization: Reduced Wait
        task.wait(0.3)
    else
        UILib:CreateNotification({Text = "Dealer Prompt not found!", Duration = 3, Color = UILib.Colors.ERROR})
        return
    end
    
    -- 4. Hande Dialogue (Robust Clicking)
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    local dialogUI = playerGui:WaitForChild("Dialogue", 5)
    
    if not dialogUI then
        UILib:CreateNotification({Text = "Dialogue UI did not open!", Duration = 3, Color = UILib.Colors.ERROR})
        return
    end
    
    local mainFrame = dialogUI:WaitForChild("MainFrame", 5)
    if not mainFrame then 
        UILib:CreateNotification({Text = "MainFrame not found", Duration = 3})
        return 
    end
    
    local replyFrame = mainFrame:WaitForChild("ReplyFrame", 5)
    if not replyFrame then return end
    
    -- Initial interaction: "Take a look"
    task.wait(1)
    
    -- Helper to click button (High Reliability)
    local function clickGui(btn)
        if not btn.Visible then return end
        UILib:CreateNotification({Text = "Clicking: " .. (btn.Text or btn.Name), Duration = 1})
        
        -- Method 1: Executor firesignal (Best)
        if getgenv and getgenv().firesignal then
            pcall(function() getgenv().firesignal(btn.MouseButton1Click) end)
            pcall(function() getgenv().firesignal(btn.Activated) end)
            task.wait(0.1)
        end
        
        -- Method 2: VirtualInputManager (Screen coordinates with variants)
        local absPos = btn.AbsolutePosition
        local absSize = btn.AbsoluteSize
        local cx = absPos.X + absSize.X/2
        local cy = absPos.Y + absSize.Y/2
        
        local vim = game:GetService("VirtualInputManager")
        local offsets = {0, 36, 58} -- Standard, Inset, Topbar
        
        for _, off in ipairs(offsets) do
            vim:SendMouseButtonEvent(cx, cy + off, 0, true, game, 1)
            task.wait(0.02)
            vim:SendMouseButtonEvent(cx, cy + off, 0, false, game, 1)
        end
        task.wait(0.3)
    end
    
    -- Find and click 'Take a look' with Retry Loop
    local entrySuccess = false
    local tStart = tick()
    while (tick() - tStart < 8) do
        -- Check if sell buttons appeared
        local hasSellBtn = false
        for _, btn in ipairs(replyFrame:GetChildren()) do
             if btn:IsA("GuiButton") and btn.Visible and string.find(string.lower(btn.Text or ""), "sell") then
                 hasSellBtn = true
                 break
             end
        end
        if hasSellBtn then 
            entrySuccess = true
            break 
        end
        
        -- Try clicking introduction button
        for _, child in ipairs(replyFrame:GetChildren()) do
            if child:IsA("GuiButton") and child.Visible then
                 local text = string.lower(child.Text or "")
                 if string.find(text, "take a look") or child.Name == "Reply1" then
                     clickGui(child)
                     break
                 end
            end
        end
        task.wait(0.5)
    end
    
    if not entrySuccess then
        UILib:CreateNotification({Text = "Failed to enter Sell Menu", Duration = 3, Color = UILib.Colors.WARNING})
    end
    
    task.wait(1)
    
    -- 5. Sell Items (Spam Click Sell buttons)
    local selling = true
    local sellCount = 0
    local failsafe = 0
    
    while selling do
        local foundSell = false
        local replyChildren = replyFrame:GetChildren()
        
        for _, btn in ipairs(replyChildren) do
            if btn:IsA("GuiButton") and btn.Visible then
                local txt = string.lower(btn.Text or "")
                if string.find(txt, "sell") then
                    clickGui(btn)
                    sellCount = sellCount + 1
                    foundSell = true
                    task.wait(0.1)
                end
            end
        end
        
        if not foundSell then
            selling = false
        else
            task.wait(0.5)
            failsafe = failsafe + 1
            if failsafe > 20 then selling = false end -- Avoid infinite loop
        end
    end
    
    UILib:CreateNotification({Text = "Sold ~" .. sellCount .. " items.", Duration = 3})

    -- 6. Close Dialogue (Blue Reply / Exit) with Retry
    task.wait(0.5)
    local tExit = tick()
    while (tick() - tExit < 5) do
        if not mainFrame.Visible then break end
        local rFrame = mainFrame:FindFirstChild("ReplyFrame")
        if not rFrame then break end
        
        local clickedExit = false
        for _, btn in ipairs(rFrame:GetChildren()) do
            if btn:IsA("GuiButton") and btn.Visible then
                -- Click any remaining button (usually Exit/Goodbye)
                clickGui(btn)
                clickedExit = true
                -- Don't break immediately, might need a moment
            end
        end
        
        if not clickedExit then break end -- No buttons left
        task.wait(0.5)
    end
    
    FreezePlayer(false) -- Unanchor
    
    -- Walk away to close logic
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
         LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 0, 10)
    end
    
    if Window.ScreenGui then Window.ScreenGui.Enabled = true end
end
local function SafePerformAutoSell() SafeExecute("PerformAutoSell", PerformAutoSell) end

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

UILib:CreateButton(TeleportPanel, {
    Text = "Manual Auto Sell (V2)",
    Callback = function()
        PerformAutoSell()
    end
})

-- Auto Loot Toggle
UILib:CreateToggle(TeleportPanel, {
    Label = "Enable Auto Sell",
    Default = true,
    Callback = function(state)
        getgenv().EnableAutoSell = state
    end
})

UILib:CreateSlider(TeleportPanel, {
    Text = "Sell Threshold",
    Min = 10,
    Max = 200,
    Default = 50,
    Callback = function(val)
        getgenv().SellThreshold = val
    end
})

local StatusLabel = UILib:CreateLabel(TeleportPanel, {
    Text = "Looted: 0 / 50",
    Color = UILib.Colors.TEXT_SECONDARY
})

UILib:CreateToggle(TeleportPanel, {
    Label = "Auto Farm Crates (Beta)",
    Callback = function(state)
        getgenv().AutoLoot = state
        getgenv().ItemsLooted = 0 
        
        if state then
            -- Singleton Protection: New UID kills old threads
            local myUID = math.random(1, 1000000)
            getgenv().AutoLootUID = myUID
            
            task.spawn(function()
                while getgenv().AutoLoot and getgenv().AutoLootUID == myUID do
                    SafeExecute("AutoFarmLoop", function()
                        -- Update Status Label
                        local currentItems = getgenv().ItemsLooted or 0
                        local threshold = getgenv().SellThreshold or 50
                        if StatusLabel and StatusLabel.SetText then
                            StatusLabel:SetText("Looted: " .. currentItems .. " / " .. threshold)
                        end
    
                        -- Check Auto Sell
                        if currentItems >= threshold then
                            if getgenv().EnableAutoSell then
                                SafePerformAutoSell()
                            else
                                UILib:CreateNotification({Text = "Threshold Reached! (Auto-Sell Disabled)", Duration = 2})
                            end
                            getgenv().ItemsLooted = 0
                            task.wait(1)
                        end
    
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
                        
                        if targetCrate and targetCrate.Model and targetCrate.Model.PrimaryPart then
                            UILib:CreateNotification({Text = "Target Found. Teleporting...", Duration = 1})
                            
                            -- 2. Teleport
                            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                local tPos = targetCrate.Model.PrimaryPart.CFrame
                                -- Optimization: Teleport deeper (Head in Chest: -2.5 studs)
                                LocalPlayer.Character.HumanoidRootPart.CFrame = tPos + Vector3.new(0, -2.5, 0)
                                FreezePlayer(true) 
                                task.wait(0.1) -- Fast TP wait
                            end
                             
                            -- 3. Interact (Aggressive)
                            if targetCrate.Prompt and targetCrate.Prompt.Enabled then
                                -- Spam prompt to ensure interaction while frozen
                                for i=1,5 do
                                    fireproximityprompt(targetCrate.Prompt)
                                end
                                getgenv().ItemsLooted = (getgenv().ItemsLooted or 0) + 1
                                -- Optimization: Reduced prompt wait (User requested 3s)
                                task.wait(3)
                            end
                            
                            -- 4. Check for Outcomes
                            -- A: Minigame
                            local pg = LocalPlayer.PlayerGui
                            local breach = pg:FindFirstChild("NeoHotbar") and pg.NeoHotbar:FindFirstChild("BreachProtocol") and pg.NeoHotbar.BreachProtocol:FindFirstChild("Main")
                            
                            if breach and breach.Visible then
                                 UILib:CreateNotification({Text = "Minigame Detected! Solving...", Duration = 2})
                                 SafeSolveBreach()
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
                                    -- Optimization: Loop until container is empty (Wait for loot to be taken)
                                    local waitStart = tick()
                                    -- Loop for up to 5 seconds or until empty
                                    while lootUI.Visible and (tick() - waitStart < 5) do
                                        local items = container:GetChildren()
                                        local validItemCount = 0
                                        
                                        for _, item in ipairs(items) do
                                            if item:IsA("GuiObject") and item.Visible then 
                                                validItemCount = validItemCount + 1
                                                local absPos = item.AbsolutePosition
                                                local absSize = item.AbsoluteSize
                                                local cx, cy = absPos.X + absSize.X/2, absPos.Y + absSize.Y/2 + 36 
                                                
                                                game:GetService("VirtualInputManager"):SendMouseButtonEvent(cx, cy, 0, true, game, 1)
                                                task.wait(0.01)
                                                game:GetService("VirtualInputManager"):SendMouseButtonEvent(cx, cy, 0, false, game, 1)
                                            end
                                        end
                                        
                                        if validItemCount == 0 then break end -- All items gone
                                        task.wait(0.1) -- Small wait before re-checking
                                    end
                                end
                            end
                        else
                            UILib:CreateNotification({Text = "No crates found. Waiting...", Duration = 2})
                            task.wait(3)
                        end
                        
                        FreezePlayer(false)
                    end)
                    task.wait(0.1) -- Fast loop cycle
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
        SafeSolveBreach()
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
