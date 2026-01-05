local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

-- Hardcoded Y-Axis Offset for Breach Protocol (calibrated to 50)
local BREACH_Y_OFFSET = 50

-- Attempt to load UILib (Local First, then Web)
local UILib
local success, result = pcall(function()
    if isfile and isfile("UILIB.lua") then
        print("[DEBUG] Found UILIB.lua in executor workspace")
        local code = readfile("UILIB.lua")
        print("[DEBUG] Read UILIB.lua, length: " .. #code)
        local loadFunc, loadErr = loadstring(code)
        if not loadFunc then
            error("Loadstring failed: " .. tostring(loadErr))
        end
        print("[DEBUG] Loadstring successful, executing...")
        return loadFunc()
    else
        print("[DEBUG] UILIB.lua not found in executor workspace (isfile check failed)")
        return nil
    end
end)

if success and result then
    UILib = result
    print("✓ Loaded UILIB from local file.")
elseif not success then
    warn("✗ Local load error: " .. tostring(result))
end

if not UILib then
    print("[DEBUG] Attempting to load from GitHub...")
    local repo = "https://raw.githubusercontent.com/onelkenzo/tesst/refs/heads/main/UILIB.lua"
    local webSuccess, webResult = pcall(function()
        print("[DEBUG] Fetching: " .. repo)
        local code = game:HttpGet(repo)
        print("[DEBUG] Downloaded code, length: " .. #code)
        local loadFunc, loadErr = loadstring(code)
        if not loadFunc then
            error("Loadstring failed: " .. tostring(loadErr))
        end
        print("[DEBUG] Loadstring successful, executing...")
        return loadFunc()
    end)
    
    if webSuccess and webResult then
        UILib = webResult
        print("✓ Loaded UILIB from Web.")
    else
        warn("✗ Web load error: " .. tostring(webResult))
    end
end

if not UILib then
    warn("✗ FAILED to load UILIB. Both local and web loading failed.")
    warn("Please either:")
    warn("  1. Copy UILIB.lua to your executor's workspace folder, OR")
    warn("  2. Check your internet connection and GitHub URL")
    return
end

print("✓ UILIB successfully loaded!")

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
    
        local label = Instance.new("TextLabel", panel.ScrollingFrame)
        label.Size = UDim2.new(1, -40, 0, 20)
        label.Position = UDim2.fromOffset(30, y)
        label.BackgroundTransparency = 1
        label.Text = text
        label.Font = Enum.Font.GothamMedium
        label.TextSize = 14
        label.TextColor3 = UILib.Colors.TEXT_PRIMARY
        label.TextXAlignment = Enum.TextXAlignment.Left
        
        local valueLabel = Instance.new("TextLabel", panel.ScrollingFrame)
        valueLabel.Size = UDim2.new(0, 50, 0, 20)
        valueLabel.Position = UDim2.new(1, -80, 0, y)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = tostring(default)
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.TextSize = 14
        valueLabel.TextColor3 = UILib.Colors.JPUFF_PINK
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        
        local sliderBg = Instance.new("Frame", panel.ScrollingFrame)
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
        panel:UpdateCanvasSize()
    
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
        
        local label = Instance.new("TextLabel", panel.ScrollingFrame)
        label.Size = UDim2.new(1, -40, 0, 20)
        label.Position = UDim2.fromOffset(30, y)
        label.BackgroundTransparency = 1
        label.Text = text
        label.Font = Enum.Font.GothamMedium
        label.TextSize = 14
        label.TextColor3 = color
        label.TextXAlignment = Enum.TextXAlignment.Left
        
        panel.ContentY = panel.ContentY + 25
        panel:UpdateCanvasSize()
        
        return {
            SetText = function(self, newText)
                label.Text = newText
            end
        }
    end
end

-- PATCH: CreateDropdown if missing (e.g. loaded from web)
if not UILib.CreateDropdown then
    UILib.CreateDropdown = function(self, panel, config)
        config = config or {}
        local label = config.Label or "Dropdown"
        local options = config.Options or {"Option 1", "Option 2", "Option 3"}
        local callback = config.Callback or function() end
        local y = panel.ContentY
        
        local TweenService = game:GetService("TweenService")
        
        -- Label
        local labelText = Instance.new("TextLabel", panel.ScrollingFrame)
        labelText.Size = UDim2.new(1, -60, 0, 20)
        labelText.Position = UDim2.fromOffset(30, y)
        labelText.BackgroundTransparency = 1
        labelText.Text = label
        labelText.Font = Enum.Font.GothamMedium
        labelText.TextSize = 14
        labelText.TextColor3 = UILib.Colors.TEXT_PRIMARY
        labelText.TextXAlignment = Enum.TextXAlignment.Left
        labelText.TextTransparency = 0
        
        -- Dropdown button
        local dropdownBtn = Instance.new("TextButton", panel.ScrollingFrame)
        dropdownBtn.Size = UDim2.new(1, -60, 0, 45)
        dropdownBtn.Position = UDim2.fromOffset(30, y + 25)
        dropdownBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        dropdownBtn.Text = ""
        dropdownBtn.BorderSizePixel = 0
        dropdownBtn.BackgroundTransparency = 0.2
        Instance.new("UICorner", dropdownBtn).CornerRadius = UDim.new(0, 12)
        
        local dropdownStroke = Instance.new("UIStroke", dropdownBtn)
        dropdownStroke.Color = UILib.Colors.JPUFF_PINK
        dropdownStroke.Transparency = 0.8
        
        -- Selected text
        local selectedText = Instance.new("TextLabel", dropdownBtn)
        selectedText.Size = UDim2.new(1, -40, 1, 0)
        selectedText.Position = UDim2.fromOffset(15, 0)
        selectedText.BackgroundTransparency = 1
        selectedText.Text = "Select..."
        selectedText.Font = Enum.Font.GothamMedium
        selectedText.TextSize = 15
        selectedText.TextColor3 = UILib.Colors.TEXT_SECONDARY
        selectedText.TextXAlignment = Enum.TextXAlignment.Left
        selectedText.TextTransparency = 0
        
        -- Arrow indicator
        local arrow = Instance.new("TextLabel", dropdownBtn)
        arrow.Size = UDim2.fromOffset(30, 45)
        arrow.Position = UDim2.new(1, -35, 0, 0)
        arrow.BackgroundTransparency = 1
        arrow.Text = "▼"
        arrow.Font = Enum.Font.GothamBold
        arrow.TextSize = 12
        arrow.TextColor3 = UILib.Colors.JPUFF_PINK
        arrow.TextXAlignment = Enum.TextXAlignment.Center
        arrow.TextTransparency = 0
        
        -- Options container (hidden by default)
        local optionsContainer = Instance.new("Frame", panel.ScrollingFrame)
        optionsContainer.Size = UDim2.new(1, -60, 0, 0)
        optionsContainer.Position = UDim2.fromOffset(30, y + 75)
        optionsContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        optionsContainer.BorderSizePixel = 0
        optionsContainer.Visible = false
        optionsContainer.ClipsDescendants = true
        optionsContainer.ZIndex = 100
        Instance.new("UICorner", optionsContainer).CornerRadius = UDim.new(0, 12)
        
        local optionsStroke = Instance.new("UIStroke", optionsContainer)
        optionsStroke.Color = UILib.Colors.JPUFF_PINK
        optionsStroke.Transparency = 0.6
        
        -- Scrolling frame for options
        local scrollFrame = Instance.new("ScrollingFrame", optionsContainer)
        scrollFrame.Size = UDim2.fromScale(1, 1)
        scrollFrame.Position = UDim2.fromOffset(0, 0)
        scrollFrame.BackgroundTransparency = 1
        scrollFrame.BorderSizePixel = 0
        scrollFrame.ScrollBarThickness = 4
        scrollFrame.ScrollBarImageColor3 = UILib.Colors.JPUFF_PINK
        scrollFrame.ZIndex = 101
        
        local listLayout = Instance.new("UIListLayout", scrollFrame)
        listLayout.FillDirection = Enum.FillDirection.Vertical
        listLayout.Padding = UDim.new(0, 2)
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        
        local isOpen = false
        local selectedOption = nil
        
        -- Create option buttons
        for i, option in ipairs(options) do
            local optionBtn = Instance.new("TextButton", scrollFrame)
            optionBtn.Size = UDim2.new(1, -10, 0, 40)
            optionBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            optionBtn.Text = option
            optionBtn.Font = Enum.Font.GothamMedium
            optionBtn.TextSize = 14
            optionBtn.TextColor3 = UILib.Colors.TEXT_PRIMARY
            optionBtn.BorderSizePixel = 0
            optionBtn.BackgroundTransparency = 0.3
            optionBtn.ZIndex = 102
            Instance.new("UICorner", optionBtn).CornerRadius = UDim.new(0, 8)
            
            -- Hover effect
            optionBtn.MouseEnter:Connect(function()
                TweenService:Create(optionBtn, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(60, 60, 70),
                    BackgroundTransparency = 0
                }):Play()
            end)
            
            optionBtn.MouseLeave:Connect(function()
                TweenService:Create(optionBtn, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(40, 40, 50),
                    BackgroundTransparency = 0.3
                }):Play()
            end)
            
            -- Click handler
            optionBtn.MouseButton1Click:Connect(function()
                selectedOption = option
                selectedText.Text = option
                selectedText.TextColor3 = UILib.Colors.TEXT_PRIMARY
                
                -- Close dropdown
                isOpen = false
                TweenService:Create(arrow, TweenInfo.new(0.3), {Rotation = 0}):Play()
                TweenService:Create(optionsContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                    Size = UDim2.new(1, -60, 0, 0)
                }):Play()
                
                task.delay(0.3, function()
                    optionsContainer.Visible = false
                end)
                
                -- Execute callback
                callback(option)
            end)
        end
        
        -- Update scroll canvas size
        listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
        end)
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
        
        -- Toggle dropdown
        dropdownBtn.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            
            if isOpen then
                optionsContainer.Visible = true
                local maxHeight = math.min(#options * 42, 200)
                
                TweenService:Create(arrow, TweenInfo.new(0.3), {Rotation = 180}):Play()
                TweenService:Create(optionsContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = UDim2.new(1, -60, 0, maxHeight)
                }):Play()
            else
                TweenService:Create(arrow, TweenInfo.new(0.3), {Rotation = 0}):Play()
                TweenService:Create(optionsContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                    Size = UDim2.new(1, -60, 0, 0)
                }):Play()
                
                task.delay(0.3, function()
                    optionsContainer.Visible = false
                end)
            end
        end)
        
        panel.ContentY = panel.ContentY + 80
        panel:UpdateCanvasSize()
        
        return {
            SetValue = function(value)
                selectedOption = value
                selectedText.Text = value
                selectedText.TextColor3 = UILib.Colors.TEXT_PRIMARY
            end,
            GetValue = function()
                return selectedOption
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
getgenv().BreachFailCount = getgenv().BreachFailCount or 0 -- Track consecutive failures

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
    
    -- READ GOAL SEQUENCE WITH VALIDATION
    -- CRITICAL: Wait for goal sequence to fully load (fixes spam/lag issue)
    local goalSequence = {}
    local goalLoadStart = tick()
    local maxGoalWait = 3 -- Wait up to 3 seconds for goals to populate
    
    while (tick() - goalLoadStart < maxGoalWait) do
        goalSequence = {}
        local goalIndex = 1
        while true do
            local goalBtn = goalFolder:FindFirstChild(tostring(goalIndex))
            if not goalBtn then break end
            local goalText = goalBtn.Text or ""
            -- Only count valid goals (non-empty text)
            if goalText ~= "" and goalText ~= "?" then
                table.insert(goalSequence, goalText)
            else
                break -- Stop if we hit an empty/placeholder goal
            end
            goalIndex = goalIndex + 1
        end
        
        -- If we have at least one valid goal, we're good
        if #goalSequence > 0 then
            break
        end
        
        task.wait(0.2) -- Check every 200ms
    end
    
    if #goalSequence == 0 then
        UILib:CreateNotification({Text = "No goals found! (Timed out waiting for sequence to load)", Duration = 3, Color = UILib.Colors.ERROR})
        return
    end
    
    UILib:CreateNotification({Text = "Goals loaded: " .. #goalSequence .. " codes", Duration = 2})
    
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

    -- TIMEOUT PROTECTION: Prevent solver from hanging
    local solveStartTime = tick()
    local maxSolveTime = 8 -- Max 8 seconds to find solution
    local iterationCount = 0
    local maxIterations = 10000 -- Prevent infinite loops
    
    local function solve(currentIdx, currentType, used, goalIndex, path)
        iterationCount = iterationCount + 1
        
        -- Timeout checks
        if tick() - solveStartTime > maxSolveTime then
            return nil -- Timeout
        end
        if iterationCount > maxIterations then
            return nil -- Too many iterations
        end
        
        -- Periodic yield to prevent freezing
        if iterationCount % 100 == 0 then
            task.wait(0.01) -- Small yield every 100 iterations
        end
        
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
            getgenv().BreachFailCount = 0 -- Reset on success
            UILib:CreateNotification({Text = "Execution Complete!", Duration = 3})
        end)
    else
        UILib:CreateNotification({Text = "No solution found. Auto-retrying...", Duration = 2, Color = UILib.Colors.WARNING})
        
        -- Increment failure counter
        getgenv().BreachFailCount = (getgenv().BreachFailCount or 0) + 1
        
        task.spawn(function()
            SafeExecute("BreachRetry", function()
                -- RELOAD UI AFTER 3 CONSECUTIVE FAILS
                if getgenv().BreachFailCount >= 3 then
                    UILib:CreateNotification({Text = "3 Fails! Reloading minigame UI...", Duration = 3, Color = UILib.Colors.WARNING})
                    getgenv().BreachFailCount = 0 -- Reset counter
                    
                    -- Close breach UI by teleporting away briefly
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local currentPos = LocalPlayer.Character.HumanoidRootPart.CFrame
                        LocalPlayer.Character.HumanoidRootPart.CFrame = currentPos + Vector3.new(0, 20, 0)
                        task.wait(1)
                        LocalPlayer.Character.HumanoidRootPart.CFrame = currentPos
                        task.wait(2)
                    end
                    
                    -- Wait for breach UI to close and reopen
                    task.wait(1)
                    return -- Exit this retry, new minigame will trigger from auto-loot
                end
                
                -- Standard retry (click button 1)
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
    
    -- CRITICAL FIX: Wait for dialogue to finish rendering (Reduced from 6s to 3s for speed)
    UILib:CreateNotification({Text = "Waiting for dialogue to load...", Duration = 2})
    task.wait(3)
    
    -- Helper to click button (Safe & Reliable)
    local function clickGui(btn)
        if not btn.Visible then return end
        
        -- Method 1: VirtualUser (Most reliable for clicks)
        if game:GetService("VirtualUser") then
            pcall(function()
                game:GetService("VirtualUser"):ClickButton1(Vector2.new(btn.AbsolutePosition.X + btn.AbsoluteSize.X/2, btn.AbsolutePosition.Y + btn.AbsoluteSize.Y/2))
            end)
        end

        -- Method 2: Executor firesignal (Direct execution)
        if getgenv and getgenv().firesignal then
            pcall(function() getgenv().firesignal(btn.MouseButton1Click) end)
            pcall(function() getgenv().firesignal(btn.Activated) end)
        end
        
        -- Method 3: VirtualInputManager (Fallback - wrapped in pcall to prevent crash)
        pcall(function()
            local absPos = btn.AbsolutePosition
            local absSize = btn.AbsoluteSize
            local cx = absPos.X + absSize.X/2
            local cy = absPos.Y + absSize.Y/2
            
            local vim = game:GetService("VirtualInputManager")
            vim:SendMouseButtonEvent(cx, cy, 0, true, game, 1)
            vim:SendMouseButtonEvent(cx, cy, 0, false, game, 1)
        end)
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
    
    -- 5. Sell Items (Robust Debug Mode)
    local selling = true
    local sellCount = 0
    local failsafe = 0
    
    while selling do
        local foundSell = false
        local replyChildren = replyFrame:GetChildren()
        
        -- Diagnostic: Print all buttons found to console/notify
        if sellCount == 0 and failsafe == 0 then
            local debugMsg = "UI Scan: " .. #replyChildren .. " elements. "
            for _, gui in ipairs(replyChildren) do
                if gui:IsA("GuiButton") and gui.Visible then
                    debugMsg = debugMsg .. "[" .. gui.Name .. ": " .. (gui.Text or "nil") .. "] "
                end
            end
            print(debugMsg) -- Check F9 console
            UILib:CreateNotification({Text = "Scanning UI...", Duration = 1})
        end

        for _, btn in ipairs(replyChildren) do
            if btn:IsA("GuiButton") and btn.Visible then
                local txt = string.lower(btn.Text or "")
                -- Broad check: "sell" OR "confirm" OR price (contains "$")
                if string.find(txt, "sell") or string.find(txt, "confirm") or string.find(txt, "%$") then
                    
                    UILib:CreateNotification({Text = "Selling: " .. (btn.Text or "Unknown"), Duration = 1})
                    
                    -- Use clickGui function (already defined earlier)
                    clickGui(btn)
                    
                    sellCount = sellCount + 1
                    foundSell = true
                    task.wait(0.15) -- Wait for game to process sale
                    break -- Process one at a time for stability
                end
            end
        end
        
        if not foundSell then
            -- Double check failsafe
            if failsafe > 5 then
                selling = false
            else
                 task.wait(0.5)
                 failsafe = failsafe + 1
            end
        else
            failsafe = 0 -- Reset failsafe if we found something
        end
    end
    
    UILib:CreateNotification({Text = "Sold " .. sellCount .. " items. Finished loop.", Duration = 3})

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

-- =====================================================
-- PANELS
-- =====================================================

-- Automation Panel
local AutomationPanel = Window:CreatePanel({
    Name = "Automation",
    DisplayName = "Automation"
})



UILib:CreateButton(AutomationPanel, {
    Text = "Manual Auto Sell (V2)",
    Callback = function()
        PerformAutoSell()
    end
})

-- Auto Loot Toggle
UILib:CreateToggle(AutomationPanel, {
    Label = "Enable Auto Sell",
    Default = true,
    Callback = function(state)
        getgenv().EnableAutoSell = state
    end
})

UILib:CreateSlider(AutomationPanel, {
    Text = "Sell Threshold",
    Min = 10,
    Max = 200,
    Default = 50,
    Callback = function(val)
        getgenv().SellThreshold = val
    end
})

local StatusLabel = UILib:CreateLabel(AutomationPanel, {
    Text = "Looted: 0 / 50",
    Color = UILib.Colors.TEXT_SECONDARY
})

UILib:CreateToggle(AutomationPanel, {
    Label = "Auto Farm Crates (Beta)",
    Callback = function(state)
        getgenv().AutoLoot = state
        getgenv().ItemsLooted = 0 
        
        if state then
            -- Save current position
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                getgenv().SavedFarmPosition = LocalPlayer.Character.HumanoidRootPart.CFrame
                UILib:CreateNotification({Text = "Position saved! Will return here on toggle off.", Duration = 3})
            end
            
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
        else
            -- Restore saved position when toggling OFF
            if getgenv().SavedFarmPosition then
                task.wait(0.5) -- Small delay to ensure loop stopped
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = getgenv().SavedFarmPosition
                    UILib:CreateNotification({Text = "Returned to original position!", Duration = 3})
                end
            end
        end
    end
})

-- Combat Panel
local CombatPanel = Window:CreatePanel({
    Name = "Combat",
    DisplayName = "Combat"
})

UILib:CreateToggle(CombatPanel, {
    Label = "Infinite Stamina",
    Default = false,
    Callback = function(state)
        getgenv().InfStamina = state
        if state then
            task.spawn(function()
                while getgenv().InfStamina do
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Values") and LocalPlayer.Character.Values:FindFirstChild("Stamina") then
                        local args = {
                            LocalPlayer.Character.Values.Stamina,
                            100
                        }
                        local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
                        if remotes and remotes:FindFirstChild("Stamina") then
                            remotes.Stamina:FireServer(unpack(args))
                        end
                    end
                    task.wait(1)
                end
            end)
            UILib:CreateNotification({Text = "Infinite Stamina Enabled", Duration = 2})
        else
            UILib:CreateNotification({Text = "Infinite Stamina Disabled", Duration = 2})
        end
    end
})

-- Auto Heal Logic
getgenv().AutoHeal = false
getgenv().HealItemName = "Health Inhaler" -- Default

UILib:CreateToggle(CombatPanel, {
    Label = "Auto Heal (Diff < 50%)",
    Default = false,
    Callback = function(state)
        getgenv().AutoHeal = state
        if state then
            -- Spawn AGGRESSIVE Cleaner Loop (Removes locks/cooldowns continuously)
            task.spawn(function()
                while getgenv().AutoHeal do
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Values") then
                        for _, val in ipairs(LocalPlayer.Character.Values:GetChildren()) do
                            local name = string.lower(val.Name)
                            -- Remove ANY lock/debuff values
                            if name == "inactiveinventory" or name == "usingitem" or name == "busy" or name == "slowmove" or name == "using move" then
                                val:Destroy()
                            -- Remove ANY cooldown values
                            elseif string.find(name, "cooldown") or string.find(name, "cd") or string.find(name, "health") and string.find(name, "cd") then
                                val:Destroy()
                            -- Remove inhaler-specific cooldowns
                            elseif string.find(name, "inhaler") or string.find(name, "doc") then
                                val:Destroy()
                            end
                        end
                    end
                    
                    -- Also aggressively stop any animation that might lock movement
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                        for _, track in ipairs(LocalPlayer.Character.Humanoid:GetPlayingAnimationTracks()) do
                            if track.Animation then
                                local animName = string.lower(track.Animation.Name)
                                if string.find(animName, "use") or string.find(animName, "heal") or string.find(animName, "drink") or string.find(animName, "eat") or string.find(animName, "inhale") then
                                    track:Stop()
                                end
                            end
                        end
                    end
                    
                    task.wait(0.05) -- Check every 50ms
                end
            end)
            
            -- Spawn Healing Loop
            task.spawn(function()
                while getgenv().AutoHeal do
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                        local hum = LocalPlayer.Character.Humanoid
                        if hum.Health < (hum.MaxHealth * 0.5) and hum.Health > 0 then
                            local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
                            if remotes and remotes:FindFirstChild("QuickItem") then
                                local targetItem = getgenv().HealItemName
                                
                                -- DEBUG: Notify once every 5 seconds
                                if not getgenv().LastHealNotify or (tick() - getgenv().LastHealNotify > 5) then
                                    UILib:CreateNotification({Text = "Healing with: " .. tostring(targetItem), Duration = 1})
                                    getgenv().LastHealNotify = tick()
                                end
                                
                                -- Fire healing remote
                                remotes.QuickItem:FireServer(targetItem)
                            end
                        end
                    end
                    task.wait(0.1)
                end
            end)
            
            UILib:CreateNotification({Text = "Auto Heal Enabled (No Lock/CD)", Duration = 2})
        else
            UILib:CreateNotification({Text = "Auto Heal Disabled", Duration = 2})
        end
    end
})

-- Auto-Revive Toggle
UILib:CreateToggle(CombatPanel, {
    Label = "Auto-Revive",
    Default = false,
    Callback = function(state)
        getgenv().AutoRevive = state
        
        if state then
            task.spawn(function()
                while getgenv().AutoRevive do
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                        local hum = LocalPlayer.Character.Humanoid
                        
                        -- When HP reaches 0 or is very low (downed state)
                        if hum.Health <= 0 or hum.Health < 5 then
                            local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
                            if remotes and remotes:FindFirstChild("QuickItem") then
                                local healItem = getgenv().HealItemName or "Health Inhaler"
                                
                                -- Spam heal to revive
                                for i = 1, 10 do
                                    remotes.QuickItem:FireServer(healItem)
                                    task.wait(0.05)
                                end
                                
                                UILib:CreateNotification({Text = "Auto-Revive activated!", Duration = 2, Color = UILib.Colors.SUCCESS})
                                task.wait(2) -- Cooldown before next attempt
                            end
                        end
                    end
                   task.wait(0.1)
                end
            end)
            UILib:CreateNotification({Text = "Auto-Revive Enabled", Duration = 2})
        else
            UILib:CreateNotification({Text = "Auto-Revive Disabled", Duration = 2})
        end
    end
})

UILib:CreateButton(CombatPanel, {
    Text = "Auto-Detect Heal Item",
    Callback = function()
         local foundName = nil
         
         -- Method 1: Check PlayerGui (Visual Hotbar)
         pcall(function()
             local qItems = LocalPlayer.PlayerGui.Main.MainFrame.QuickItems
             for _, item in ipairs(qItems:GetChildren()) do
                 if item:IsA("ImageLabel") and item.Name ~= "Template" then
                     -- Check if it looks like a heal item
                     if string.find(string.lower(item.Name), "doc") or string.find(string.lower(item.Name), "inhaler") or string.find(string.lower(item.Name), "heal") then
                         foundName = item.Name
                         print("Found in GUI:", foundName)
                     end
                 end
             end
         end)
         
         -- Method 2: Check Data (Internal Inventory)
         if not foundName then
             local data = LocalPlayer:FindFirstChild("Data")
             local quickItems = data and data:FindFirstChild("QuickItems")
             if quickItems then
                 for _, item in ipairs(quickItems:GetChildren()) do
                     if item.Value > 0 and (string.find(string.lower(item.Name), "doc") or string.find(string.lower(item.Name), "inhaler") or string.find(string.lower(item.Name), "heal")) then
                         foundName = item.Name
                         print("Found in Data:", foundName)
                         break
                     end
                 end
             end
         end
         
         if foundName then
             getgenv().HealItemName = foundName
             UILib:CreateNotification({Text = "Set Heal Item: " .. foundName, Duration = 3})
         else
             UILib:CreateNotification({Text = "Could not find any 'Doc' or 'Inhaler'. Make sure it's equipped!", Duration = 3, Color = UILib.Colors.ERROR})
         end
    end
})

-- God Mode Toggle
getgenv().GodMode = false

UILib:CreateToggle(CombatPanel, {
    Label = "God Mode",
    Default = false,
    Callback = function(state)
        getgenv().GodMode = state
        
        if state then
            -- Method 1: Health lock loop (backup)
            task.spawn(function()
                while getgenv().GodMode do
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                        local hum = LocalPlayer.Character.Humanoid
                        if hum.Health < hum.MaxHealth then
                            hum.Health = hum.MaxHealth
                        end
                    end
                    task.wait(0.05) -- Fast refresh (20 FPS)
                end
            end)
            
            -- Method 2: Health change listener (instant reaction)
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                local hum = LocalPlayer.Character.Humanoid
                getgenv().GodModeConnection = hum:GetPropertyChangedSignal("Health"):Connect(function()
                    if getgenv().GodMode and hum.Health < hum.MaxHealth then
                        hum.Health = hum.MaxHealth
                    end
                end)
            end
            
            -- Listen for character respawn to re-attach listener
            getgenv().CharacterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(char)
                if getgenv().GodMode then
                    task.wait(0.5) -- Wait for humanoid to load
                    local hum = char:FindFirstChild("Humanoid")
                    if hum then
                        getgenv().GodModeConnection = hum:GetPropertyChangedSignal("Health"):Connect(function()
                            if getgenv().GodMode and hum.Health < hum.MaxHealth then
                                hum.Health = hum.MaxHealth
                            end
                        end)
                    end
                end
            end)
            
            UILib:CreateNotification({Text = "God Mode ENABLED 🛡️", Duration = 2, Color = UILib.Colors.SUCCESS})
        else
            -- Disconnect listeners
            if getgenv().GodModeConnection then
                getgenv().GodModeConnection:Disconnect()
                getgenv().GodModeConnection = nil
            end
            if getgenv().CharacterAddedConnection then
                getgenv().CharacterAddedConnection:Disconnect()
                getgenv().CharacterAddedConnection = nil
            end
            
            UILib:CreateNotification({Text = "God Mode Disabled", Duration = 2})
        end
    end
})

-- Anti-Downed Toggle (Prevents Knockdown)
getgenv().AntiDowned = false

UILib:CreateToggle(CombatPanel, {
    Label = "Anti-Downed",
    Default = false,
    Callback = function(state)
        getgenv().AntiDowned = state
        
        if state then
            task.spawn(function()
                while getgenv().AntiDowned do
                    if LocalPlayer.Character then
                        local char = LocalPlayer.Character
                        local values = char:FindFirstChild("Values")
                        
                        if values then
                            -- Prevent knockdown
                            local knocked = values:FindFirstChild("Knocked")
                            if knocked and knocked.Value == true then
                                knocked.Value = false
                            end
                            
                            -- Prevent stun
                            local stun = values:FindFirstChild("Stun")
                            if stun and stun.Value == true then
                                stun.Value = false
                            end
                        end
                        
                        -- Keep humanoid in running state
                        local hum = char:FindFirstChild("Humanoid")
                        if hum then
                            local state = hum:GetState()
                            -- If in ragdoll/dead state, force back to running
                            if state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.Dead then
                                hum:ChangeState(Enum.HumanoidStateType.Running)
                            end
                        end
                    end
                    task.wait(0.05) -- Check every 50ms
                end
            end)
            
            UILib:CreateNotification({Text = "Anti-Downed ENABLED ✊", Duration = 2, Color = UILib.Colors.SUCCESS})
        else
            UILib:CreateNotification({Text = "Anti-Downed Disabled", Duration = 2})
        end
    end
})

-- ========================================
-- Misc Panel (Formerly Netrunner Hacks)
-- ========================================
local MiscPanel = Window:CreatePanel({
    Name = "Misc",
    DisplayName = "Misc"
})

-- Cyberpsycho Button (One-time execution)
UILib:CreateButton(MiscPanel, {
    Text = "Cyberpsycho",
    Color = UILib.Colors.ERROR,
    Callback = function()
        local MyChar = LocalPlayer.Character
        local MyRoot = MyChar and MyChar:FindFirstChild("HumanoidRootPart")
        
        if MyRoot then
            local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
            local combatRemote = remotes and remotes:FindFirstChild("Combat") and remotes.Combat:FindFirstChild("NetrunnerHack")
            
            if combatRemote then
                -- Get all targets
                local allTargets = {}
                if workspace:FindFirstChild("Characters") then
                    for _, char in ipairs(workspace.Characters:GetChildren()) do
                        if char ~= MyChar and char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
                            table.insert(allTargets, char)
                        end
                    end
                end
                
                for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local char = player.Character
                        if char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
                            table.insert(allTargets, char)
                        end
                    end
                end
                
                -- Hack all targets with random hacks
                local hacks = {"PLACE-MARKER", "CREDIT-LIFT", "BLINDSHOT", "SHORT-CIRCUIT"}
                for _, targetChar in ipairs(allTargets) do
                    local hum = targetChar:FindFirstChild("Humanoid")
                    if hum and hum.Health > 0 then
                        local randomHack = hacks[math.random(1, #hacks)]
                        combatRemote:FireServer(randomHack, targetChar)
                    end
                end
                
                -- Execute SELF-SABOTAGE on yourself (triggers cyberpsycho)
                combatRemote:FireServer("SELF-SABOTAGE", MyChar)
                
                UILib:CreateNotification({Text = "Cyberpsycho activated! 🔥", Duration = 3, Color = UILib.Colors.ERROR})
            end
        else
            UILib:CreateNotification({Text = "Character not found!", Duration = 2, Color = UILib.Colors.ERROR})
        end
    end
})

-- ========================================
-- Exploits Panel (keeping original)
-- ========================================
local ExploitsPanel = Window:CreatePanel({
    Name = "Exploits",
    DisplayName = "Exploits"
})

UILib:CreateButton(ExploitsPanel, {
    Text = "Teleport to Accessory Crate",
    Callback = function()
        local cratesFolder = Workspace:FindFirstChild("Crates") and Workspace.Crates:FindFirstChild("AccessoryCrates")
        
        if cratesFolder then
            local found = false
            for _, crate in ipairs(cratesFolder:GetChildren()) do
                if crate.Name == "AccessoryCrate" and crate:FindFirstChild("colorable") then
                    local targetPart = crate.colorable
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = targetPart.CFrame + Vector3.new(0, 5, 0)
                        UILib:CreateNotification({Text = "Teleported to Crate!", Duration = 3})
                        found = true
                        break
                    end
                end
            end
            
            if not found then
                 UILib:CreateNotification({Text = "No available Accessory Crates found.", Duration = 3, Color = UILib.Colors.ERROR})
            end
        else
            UILib:CreateNotification({Text = "Crates folder not found!", Duration = 3, Color = UILib.Colors.ERROR})
        end
    end
})

local teleportLocations = {
    {Name = "Bartender", Position = Vector3.new(-60.30, 375.63, 118.52)},
    {Name = "Crate Quest", Position = Vector3.new(141.79, 354.63, 107.71)},
    {Name = "Disable Cameras Quest", Position = Vector3.new(5.68, 367.63, 345.74)},
    {Name = "Gun Dealer", Position = Vector3.new(174.78, 372.88, 283.32)},
    {Name = "Insurance Dealer 1", Position = Vector3.new(-42.88, 360.13, 208.93)},
    {Name = "Insurance Dealer 2", Position = Vector3.new(41.96, 365.88, 374.00)},
    {Name = "Sell NPC", Position = Vector3.new(-152.36, 361.37, 280.54)},
    {Name = "Kill Target Quest", Position = Vector3.new(76.42, 388.13, 62.22)},
    {Name = "Inhaler Dealer", Position = Vector3.new(93.37, 363.88, 214.98)},
    {Name = "Cyberware Npc", Position = Vector3.new(11.98, 390.48, 108.79)},
    {Name = "Melee Dealer", Position = Vector3.new(1.92, 337.62, 468.07)},
}

local locationNames = {}
local locationMap = {}
for _, location in ipairs(teleportLocations) do
    table.insert(locationNames, location.Name)
    locationMap[location.Name] = location.Position
end

UILib:CreateDropdown(ExploitsPanel, {
    Label = "Quick Teleport to NPCs",
    Options = locationNames,
    Callback = function(selectedLocation)
        local position = locationMap[selectedLocation]
        if position then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(position)
                UILib:CreateNotification({Text = "Teleported to " .. selectedLocation, Duration = 2})
            else
                UILib:CreateNotification({Text = "Character not found!", Duration = 2, Color = UILib.Colors.ERROR})
            end
        end
    end
})

-- Cash Steal Logic
local function PerformCashSteal(targetPlayer)
    if not targetPlayer or not targetPlayer:FindFirstChild("HumanoidRootPart") then
        return false
    end
    
    -- Check if we have a character
    if not (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) then
        return false
    end
    
    -- Check distance
    local dist = (LocalPlayer.Character.HumanoidRootPart.Position - targetPlayer.HumanoidRootPart.Position).Magnitude
    if dist > 50 then
        return false -- Too far
    end
    
    -- Teleport UNDER the target (stealth - they won't see you)
    local targetPos = targetPlayer.HumanoidRootPart.CFrame
    LocalPlayer.Character.HumanoidRootPart.CFrame = targetPos * CFrame.new(0, -10, 0) -- 10 studs below them
    task.wait(0.2)
    
    -- Simulate pressing C to enable hack mode
    local vim = game:GetService("VirtualInputManager")
    vim:SendKeyEvent(true, Enum.KeyCode.C, false, game)
    task.wait(0.05)
    vim:SendKeyEvent(false, Enum.KeyCode.C, false, game)
    task.wait(1) -- Wait for hack UI to appear
    
    -- Look for the NetrunnerHackButton in PlayerGui
    local hackButton = nil
    for _, gui in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
        if gui.Name == targetPlayer.Name or gui:HasTag("NetrunnerHackList") then
            -- Find CASH STEAL button (or similar name)
            for _, btn in ipairs(gui:GetDescendants()) do
                if btn:IsA("GuiButton") and btn.Name == "NetrunnerHackButton" then
                    local nameLabel = btn:FindFirstChild("NameLabel")
                    if nameLabel and (string.find(string.upper(nameLabel.Text), "CASH") or string.find(string.upper(nameLabel.Text), "CREDIT")) then
                        hackButton = btn
                        break
                    end
                end
            end
            if hackButton then break end
        end
    end
    
    if hackButton and hackButton.Active then
        -- Click the button
        if getgenv and getgenv().firesignal then
            pcall(function() getgenv().firesignal(hackButton.Activated) end)
        end
        
        -- Fallback: VIM click
        local absPos = hackButton.AbsolutePosition
        local absSize = hackButton.AbsoluteSize
        local cx, cy = absPos.X + absSize.X/2, absPos.Y + absSize.Y/2
        vim:SendMouseButtonEvent(cx, cy, 0, true, game, 1)
        task.wait(0.05)
        vim:SendMouseButtonEvent(cx, cy, 0, false, game, 1)
        
        return true
    end
    
    return false
end

local function CollectDroppedMoney()
    local droppedItems = Workspace:FindFirstChild("Misc")
    if droppedItems then
        droppedItems = droppedItems:FindFirstChild("DroppedItems")
    end
    
    if not droppedItems then return 0 end
    
    -- Check if we have a character
    if not (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) then
        return 0
    end
    
    local myPos = LocalPlayer.Character.HumanoidRootPart.Position
    local collected = 0
    
    for _, item in ipairs(droppedItems:GetChildren()) do
        if item.Name == "Part" and item:FindFirstChild("ProximityPrompt") then
            -- Distance check - only collect money close to us (20 studs)
            local dist = (item.Position - myPos).Magnitude
            if dist <= 20 then
                local prompt = item.ProximityPrompt
                
                -- Teleport to money
                LocalPlayer.Character.HumanoidRootPart.CFrame = item.CFrame
                task.wait(0.1) -- Wait for teleport to register
                
                -- DUPLICATION EXPLOIT: Fire prompt multiple times INSTANTLY before server deletes it
                -- NO DELAYS between fires = all execute before server responds = DUPES!
                local dupeCount = getgenv().DupeCount or 100
                for i=1,dupeCount do
                    fireproximityprompt(prompt)
                end
                
                collected = collected + 1
                task.wait(0.15) -- Short wait before next item
            end
        end
    end
    
    return collected
end

-- Dupe Count Slider
getgenv().DupeCount = 100

UILib:CreateSlider(ExploitsPanel, {
    Text = "Dupe Count",
    Min = 10,
    Max = 500,
    Default = 100,
    Callback = function(val)
        getgenv().DupeCount = val
    end
})

UILib:CreateButton(ExploitsPanel, {
    Text = "Dupe",
    Callback = function()
        local collected = CollectDroppedMoney()
        if collected > 0 then
            UILib:CreateNotification({Text = "Duped " .. collected .. " items!", Duration = 3})
        else
            UILib:CreateNotification({Text = "No money found nearby!", Duration = 2, Color = UILib.Colors.WARNING})
        end
    end
})

UILib:CreateButton(ExploitsPanel, {
    Text = "Solve Breach Protocol",
    Callback = function()
        SafeSolveBreach()
    end
})

UILib:CreateButton(ExploitsPanel, {
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

-- Performance Settings
UILib:CreateToggle(SettingsPanel, {
    Label = "Disable 3D Rendering (Reduce CPU)",
    Default = false,
    Callback = function(state)
        local RunService = game:GetService("RunService")
        RunService:Set3dRenderingEnabled(not state)
        if state then
            UILib:CreateNotification({Text = "3D Rendering Disabled (CPU Saver Mode)", Duration = 3})
        else
            UILib:CreateNotification({Text = "3D Rendering Enabled", Duration = 2})
        end
    end
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



-- Dismantle All Helper Functions
local DISMANTLE_LIST_PATH = "RipperdocUpgrades.Main.CraftScene.DismantleList"
local REWARD_PATH = "RipperdocUpgrades.Main.RewardScene.ContinueButton"
local CLICK_DELAY = 0.05

local function getDismantleList()
    local current = LocalPlayer.PlayerGui
    for segment in string.gmatch(DISMANTLE_LIST_PATH, "([^.]+)") do
        current = current:FindFirstChild(segment)
        if not current then
            return nil
        end
    end
    return current
end

local function clickDismantleButton(btn)
    if not btn:IsA("GuiButton") or not btn.Visible then return end
    
    -- Method 1: firesignal (Standard for most executors)
    if firesignal then
        pcall(function() firesignal(btn.MouseButton1Click) end)
        pcall(function() firesignal(btn.Activated) end)
    end
    
    -- Method 2: getconnections fallback
    if getconnections then
        for _, connection in pairs(getconnections(btn.MouseButton1Click)) do
            if connection.Fire then connection:Fire() end
        end
        for _, connection in pairs(getconnections(btn.Activated)) do
            if connection.Fire then connection:Fire() end
        end
    end
end

local function handleRewardScene()
    local current = LocalPlayer.PlayerGui
    for segment in string.gmatch(REWARD_PATH, "([^.]+)") do
        current = current:FindFirstChild(segment)
        if not current then break end
    end
    
    if current and current:IsA("GuiButton") and current.Visible then
        task.wait(0.2)
        clickDismantleButton(current)
        local start = tick()
        while current.Visible and tick() - start < 1 do
            task.wait(0.1)
        end
        return true
    end
    return false
end

local function DismantleAll()
    SafeExecute("DismantleAll", function()
        local list = getDismantleList()
        
        if not list then
            UILib:CreateNotification({Text = "DismantleList not found! Open Ripperdoc first.", Duration = 3, Color = UILib.Colors.ERROR})
            return
        end
        
        local items = list:GetChildren()
        local clickedCount = 0
        
        UILib:CreateNotification({Text = "Starting Dismantle All...", Duration = 2})
        
        for _, item in ipairs(items) do
            if item:IsA("GuiButton") then
                clickDismantleButton(item)
                clickedCount = clickedCount + 1
                handleRewardScene()
                task.wait(CLICK_DELAY)
            else
                for _, descendant in ipairs(item:GetDescendants()) do
                    if descendant:IsA("GuiButton") then
                        clickDismantleButton(descendant)
                        clickedCount = clickedCount + 1
                        handleRewardScene()
                        task.wait(CLICK_DELAY)
                    end
                end
            end
        end
        
        UILib:CreateNotification({Text = "Finished! Dismantled " .. clickedCount .. " items.", Duration = 3})
    end)
end

UILib:CreateButton(SettingsPanel, {
    Text = "Dismantle All Items",
    Color = UILib.Colors.JPUFF_HOT_PINK,
    Callback = function()
        DismantleAll()
    end
})

-- ========================================
-- Keybinds Panel
-- ========================================
local KeybindsPanel = Window:CreatePanel({
    Name = "Keybinds",
    DisplayName = "Keybinds"
})

UILib:CreateKeybind(KeybindsPanel, {
    ActionName = "Cyberpsycho",
    DefaultKey = Enum.KeyCode.P,
    Callback = function()
        local MyChar = LocalPlayer.Character
        local MyRoot = MyChar and MyChar:FindFirstChild("HumanoidRootPart")
        
        if MyRoot then
            local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
            local combatRemote = remotes and remotes:FindFirstChild("Combat") and remotes.Combat:FindFirstChild("NetrunnerHack")
            
            if combatRemote then
                -- Get all targets
                local allTargets = {}
                if workspace:FindFirstChild("Characters") then
                    for _, char in ipairs(workspace.Characters:GetChildren()) do
                        if char ~= MyChar and char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
                            table.insert(allTargets, char)
                        end
                    end
                end
                
                for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local char = player.Character
                        if char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
                            table.insert(allTargets, char)
                        end
                    end
                end
                
                -- Hack all targets with random hacks
                local hacks = {"PLACE-MARKER", "CREDIT-LIFT", "BLINDSHOT", "SHORT-CIRCUIT"}
                for _, targetChar in ipairs(allTargets) do
                    local hum = targetChar:FindFirstChild("Humanoid")
                    if hum and hum.Health > 0 then
                        local randomHack = hacks[math.random(1, #hacks)]
                        combatRemote:FireServer(randomHack, targetChar)
                    end
                end
                
                -- Execute SELF-SABOTAGE on yourself (triggers cyberpsycho)
                combatRemote:FireServer("SELF-SABOTAGE", MyChar)
                
                UILib:CreateNotification({Text = "Cyberpsycho activated! 🔥", Duration = 3, Color = UILib.Colors.ERROR})
            end
        else
            UILib:CreateNotification({Text = "Character not found!", Duration = 2, Color = UILib.Colors.ERROR})
        end
    end
})

-- Show default panel
Window:ShowPanel("Automation")
