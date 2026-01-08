-- =====================================================
-- JPUFF UI LIBRARY V1.0
-- A comprehensive UI library for creating beautiful GUIs
-- Extracted from JPUFF GUI V26
-- =====================================================

local UILib = {}

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

-- Wait for player to load
local player = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait() and Players.LocalPlayer
repeat task.wait() until player
local gui = player:WaitForChild("PlayerGui")

-- =====================================================
-- METHODS FOR WINDOW (Defined early)
-- =====================================================
function UILib:AddMethods(window)
    -- Window Navigation
    window.ShowPanel = function(self, panelName)
        UILib:ShowPanel(self, panelName)
    end
    
    window.HidePanel = function(self, panelName)
        UILib:HidePanel(self, panelName)
    end

    window.CreatePanel = function(self, config)
        return UILib:CreatePanel(self, config)
    end
    
    window.AddToggleKey = function(self, keyCode)
        UILib:AddToggleKey(self, keyCode)
    end

    -- Global Helpers accessible via Window
    window.Notify = function(self, config)
        return UILib:CreateNotification(config)
    end
    
    window.Confirm = function(self, config)
        return UILib:CreateConfirmation(config)
    end

    window.Destroy = function(self)
        if self.DragConnection then
            self.DragConnection:Disconnect()
            self.DragConnection = nil
        end
        if self.ScreenGui then
            self.ScreenGui:Destroy()
        end
    end
end


-- =====================================================
-- COLOR PALETTE
-- =====================================================
UILib.Colors = {
    JPUFF_PINK = Color3.fromRGB(255, 182, 193),
    JPUFF_HOT_PINK = Color3.fromRGB(255, 105, 180),
    JPUFF_DARK_PINK = Color3.fromRGB(255, 140, 170),
    BG_DARK = Color3.fromRGB(25, 25, 35),
    BG_CARD = Color3.fromRGB(35, 35, 45),
    TEXT_PRIMARY = Color3.fromRGB(255, 255, 255),
    TEXT_SECONDARY = Color3.fromRGB(200, 200, 210),
    TOGGLE_OFF = Color3.fromRGB(60, 60, 70),
    SUCCESS = Color3.fromRGB(80, 200, 120),
    WARNING = Color3.fromRGB(255, 215, 0),
    ERROR = Color3.fromRGB(220, 80, 100),
}

-- =====================================================
-- KEYBINDING SYSTEM
-- =====================================================
UILib.Keybinds = {} -- Storage for all keybinds: {ActionName = {Key = Enum.KeyCode, Callback = function}}
UILib.KeybindListener = nil -- Global listener connection
UILib.ListeningForKeybind = false -- Flag to prevent triggering during rebind
UILib.KeybindStorageFile = "UILib_Keybinds.json" -- File to save keybinds

-- Helper: Convert KeyCode to readable name
function UILib:GetKeyName(keyCode)
    if not keyCode then return "None" end
    local name = tostring(keyCode):gsub("Enum.KeyCode.", "")
    return name
end

-- Helper: Save keybinds to file
function UILib:SaveKeybinds()
    if not writefile then return end -- Executor doesn't support file writing
    
    local saveData = {}
    for actionName, keybind in pairs(self.Keybinds) do
        if keybind.Key then
            saveData[actionName] = tostring(keybind.Key)
        end
    end
    
    local success, err = pcall(function()
        writefile(self.KeybindStorageFile, game:GetService("HttpService"):JSONEncode(saveData))
    end)
    
    if not success then
        warn("Failed to save keybinds:", err)
    end
end

-- Helper: Load keybinds from file
function UILib:LoadKeybinds()
    if not readfile or not isfile then return {} end
    
    if not isfile(self.KeybindStorageFile) then return {} end
    
    local success, result = pcall(function()
        local data = readfile(self.KeybindStorageFile)
        return game:GetService("HttpService"):JSONDecode(data)
    end)
    
    if success and type(result) == "table" then
        return result
    else
        warn("Failed to load keybinds:", result)
        return {}
    end
end

-- Helper: Start global keybind listener
function UILib:StartKeybindListener()
    if self.KeybindListener then return end -- Already running
    
    self.KeybindListener = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end -- Ignore if typing in textbox
        if self.ListeningForKeybind then return end -- Ignore if changing a keybind
        
        for actionName, keybind in pairs(self.Keybinds) do
            if keybind.Key and input.KeyCode == keybind.Key then
                if keybind.Callback then
                    keybind.Callback()
                end
            end
        end
    end)
end


-- =====================================================
-- LOADING SCREEN
-- =====================================================
function UILib:CreateLoadingScreen(config)
    config = config or {}
    local title = config.Title or "Loading"
    local accentColor = config.AccentColor or self.Colors.JPUFF_HOT_PINK
    local duration = config.Duration or 2.5
    local onComplete = config.OnComplete or function() end

    -- Safety watchdog
    task.spawn(function()
        task.wait(duration + 5)
        local stuckBlur = Lighting:FindFirstChild("UILibLoadBlur")
        if stuckBlur then stuckBlur:Destroy() end
        local stuckLoading = gui:FindFirstChild("UILibLoadingScreen")
        if stuckLoading then stuckLoading:Destroy() end
    end)

    -- Create loading screen GUI
    local loadingGui = Instance.new("ScreenGui", gui)
    loadingGui.Name = "UILibLoadingScreen"
    loadingGui.ResetOnSpawn = false
    loadingGui.IgnoreGuiInset = true
    loadingGui.DisplayOrder = 999

    -- Blur effect
    local blur = Instance.new("BlurEffect", Lighting)
    blur.Name = "UILibLoadBlur"
    blur.Size = 0

    -- Full screen background
    local loadingBg = Instance.new("Frame", loadingGui)
    loadingBg.Size = UDim2.fromScale(1, 1)
    loadingBg.Position = UDim2.fromScale(0, 0)
    loadingBg.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    loadingBg.BackgroundTransparency = 0.3
    loadingBg.BorderSizePixel = 0

    -- Center container
    local loadingFrame = Instance.new("Frame", loadingBg)
    loadingFrame.Size = UDim2.fromOffset(400, 200)
    loadingFrame.Position = UDim2.fromScale(0.5, 0.5)
    loadingFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    loadingFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    loadingFrame.BorderSizePixel = 0
    Instance.new("UICorner", loadingFrame).CornerRadius = UDim.new(0, 15)

    -- Loading text
    local loadingText = Instance.new("TextLabel", loadingFrame)
    loadingText.Size = UDim2.new(1, 0, 0, 50)
    loadingText.Position = UDim2.fromScale(0, 0.3)
    loadingText.BackgroundTransparency = 1
    loadingText.Text = title .. "..."
    loadingText.Font = Enum.Font.GothamBold
    loadingText.TextSize = 24
    loadingText.TextColor3 = Color3.fromRGB(255, 255, 255)
    loadingText.TextTransparency = 0
    loadingText.RichText = true

    -- Animated dots
    local dots = ""
    task.spawn(function()
        while loadingGui.Parent do
            dots = dots .. "."
            if #dots > 3 then dots = "" end
            loadingText.Text = string.format('Loading <font color="rgb(%d,%d,%d)">%s</font>%s', 
                accentColor.R * 255, accentColor.G * 255, accentColor.B * 255, title, dots)
            task.wait(0.5)
        end
    end)

    -- Progress bar background
    local progressBg = Instance.new("Frame", loadingFrame)
    progressBg.Size = UDim2.new(0.8, 0, 0, 6)
    progressBg.Position = UDim2.fromScale(0.5, 0.65)
    progressBg.AnchorPoint = Vector2.new(0.5, 0.5)
    progressBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    progressBg.BorderSizePixel = 0
    Instance.new("UICorner", progressBg).CornerRadius = UDim.new(1, 0)

    -- Progress bar fill
    local progressFill = Instance.new("Frame", progressBg)
    progressFill.Size = UDim2.fromScale(0, 1)
    progressFill.BackgroundColor3 = accentColor
    progressFill.BorderSizePixel = 0
    Instance.new("UICorner", progressFill).CornerRadius = UDim.new(1, 0)

    -- Animate blur in
    TweenService:Create(blur, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = 24}):Play()

    -- Animate progress bar
    local progressTween = TweenService:Create(
        progressFill,
        TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = UDim2.fromScale(1, 1)}
    )
    progressTween:Play()

    -- Wait and fade out
    task.spawn(function()
        task.wait(duration)

        loadingText.Text = string.format('<font color="rgb(%d,%d,%d)">%s Loaded!</font>', 
            accentColor.R * 255, accentColor.G * 255, accentColor.B * 255, title)
        task.wait(0.5)

        -- Fade out
        TweenService:Create(loadingBg, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
        TweenService:Create(loadingText, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1}):Play()
        TweenService:Create(loadingFrame, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
        TweenService:Create(blur, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = 0}):Play()

        task.wait(0.9)
        if blur then blur:Destroy() end
        if loadingGui then loadingGui:Destroy() end

        onComplete()
    end)

    return {
        Gui = loadingGui,
        Blur = blur,
        Destroy = function()
            if blur then blur:Destroy() end
            if loadingGui then loadingGui:Destroy() end
        end
    }
end

-- =====================================================
-- MAIN WINDOW
-- =====================================================
function UILib:CreateWindow(config)
    config = config or {}
    local title = config.Title or "UI Window"
    local accentColor = config.AccentColor or self.Colors.JPUFF_HOT_PINK
    local size = config.Size or UDim2.fromOffset(600, 400)
    local position = config.Position or UDim2.fromOffset(50, 50)
    local winName = config.Name or "UILibWindow"

    -- Create ScreenGui
    local screenGui = Instance.new("ScreenGui", gui)
    screenGui.Name = winName
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = config.DisplayOrder or 10000
    screenGui.Enabled = true

    local window = {
        ScreenGui = screenGui,
        Panels = {},
        CurrentPanel = nil,
        AccentColor = accentColor,
        SelectorFrame = nil,
    }

    -- Create selector frame (left panel)
    local selectorFrame = Instance.new("Frame", screenGui)
    selectorFrame.Size = UDim2.fromOffset(220, 375)
    selectorFrame.Position = position
    selectorFrame.BackgroundColor3 = self.Colors.BG_DARK
    selectorFrame.Active = true
    selectorFrame.Draggable = true -- Match V26 behavior for executor compatibility
    selectorFrame.BackgroundTransparency = 1
    Instance.new("UICorner", selectorFrame).CornerRadius = UDim.new(0, 20)

    local selectorStroke = Instance.new("UIStroke", selectorFrame)
    selectorStroke.Color = accentColor
    selectorStroke.Thickness = 2
    selectorStroke.Transparency = 1

    -- Selector header
    local selectorHeader = Instance.new("TextLabel", selectorFrame)
    selectorHeader.Size = UDim2.new(1, -20, 0, 40)
    selectorHeader.Position = UDim2.fromOffset(10, 10)
    selectorHeader.BackgroundTransparency = 1
    selectorHeader.Text = title
    selectorHeader.Font = Enum.Font.GothamBold
    selectorHeader.TextSize = 18
    selectorHeader.TextColor3 = accentColor
    selectorHeader.TextXAlignment = Enum.TextXAlignment.Center
    selectorHeader.TextTransparency = 1

    -- Buttons container
    local selectorButtonsContainer = Instance.new("Frame", selectorFrame)
    selectorButtonsContainer.Size = UDim2.new(1, -20, 0, 315)
    selectorButtonsContainer.Position = UDim2.fromOffset(10, 55)
    selectorButtonsContainer.BackgroundTransparency = 1

    local selectorListLayout = Instance.new("UIListLayout", selectorButtonsContainer)
    selectorListLayout.FillDirection = Enum.FillDirection.Vertical
    selectorListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    selectorListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    selectorListLayout.Padding = UDim.new(0, 10)
    selectorListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    window.SelectorFrame = selectorFrame
    window.SelectorButtonsContainer = selectorButtonsContainer
    window.SelectorStroke = selectorStroke
    window.SelectorHeader = selectorHeader

    -- Custom Drag Logic with Panel Sync
    local dragging, dragInput, dragStart, startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        local newPos = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
        selectorFrame.Position = newPos
        
        -- SYNC ALL VISIBLE PANELS
        if window.Panels then
            for _, panel in pairs(window.Panels) do
                if panel.Frame and panel.Frame.Visible then
                    panel.Frame.Position = UDim2.new(
                        newPos.X.Scale, newPos.X.Offset + selectorFrame.AbsoluteSize.X + 20,
                        newPos.Y.Scale, newPos.Y.Offset
                    )
                end
            end
        end
    end

    local function enableDrag(frame)
        frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = selectorFrame.Position
                
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
    
        frame.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)
    end

    -- Enable drag on both Frame and Header to ensure input is captured
    selectorHeader.Active = true 
    enableDrag(selectorFrame)
    enableDrag(selectorHeader)

    local dragConnection = UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            -- print("DEBUG: Drag Update loop")
            update(input)
        end
    end)
    
    window.DragConnection = dragConnection

    -- Attach methods to window
    UILib:AddMethods(window)

    -- Fade in animation
    task.spawn(function()
        task.wait(0.3)
        TweenService:Create(selectorFrame, TweenInfo.new(0.6), {BackgroundTransparency = 0.15}):Play()
        TweenService:Create(selectorStroke, TweenInfo.new(0.6), {Transparency = 0.5}):Play()
        TweenService:Create(selectorHeader, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
    end)

    return window
end

-- =====================================================
-- PANEL (TAB)
-- =====================================================
function UILib:CreatePanel(window, config)
    config = config or {}
    local name = config.Name or "Panel"
    local displayName = config.DisplayName or name
    local color = config.Color or window.AccentColor
    local size = config.Size or UDim2.fromOffset(340, 530)
    local layoutOrder = config.LayoutOrder or 1

    -- Create panel frame
    local panelFrame = Instance.new("Frame", window.ScreenGui)
    panelFrame.Size = size
    panelFrame.Position = UDim2.fromOffset(290, 50)
    panelFrame.BackgroundColor3 = UILib.Colors.BG_DARK
    panelFrame.Active = true
    panelFrame.BackgroundTransparency = 1
    panelFrame.Visible = false
    Instance.new("UICorner", panelFrame).CornerRadius = UDim.new(0, 20)

    local panelStroke = Instance.new("UIStroke", panelFrame)
    panelStroke.Color = UILib.Colors.JPUFF_PINK
    panelStroke.Thickness = 2
    panelStroke.Transparency = 1

    -- Panel header
    local panelHeader = Instance.new("TextLabel", panelFrame)
    panelHeader.Size = UDim2.new(1, -40, 0, 50)
    panelHeader.Position = UDim2.fromOffset(20, 15)
    panelHeader.BackgroundTransparency = 1
    panelHeader.Text = displayName
    panelHeader.Font = Enum.Font.GothamBold
    panelHeader.TextSize = 22
    panelHeader.TextColor3 = UILib.Colors.JPUFF_PINK
    panelHeader.TextXAlignment = Enum.TextXAlignment.Left
    panelHeader.TextTransparency = 1

    -- Panel divider
    local panelDivider = Instance.new("Frame", panelFrame)
    panelDivider.Size = UDim2.new(1, -40, 0, 2)
    panelDivider.Position = UDim2.fromOffset(20, 70)
    panelDivider.BackgroundColor3 = UILib.Colors.JPUFF_PINK
    panelDivider.BorderSizePixel = 0
    panelDivider.BackgroundTransparency = 1
    Instance.new("UICorner", panelDivider).CornerRadius = UDim.new(1, 0)

    -- Scrolling container for panel content
    local scrollingFrame = Instance.new("ScrollingFrame", panelFrame)
    scrollingFrame.Size = UDim2.new(1, 0, 1, -85) -- Full width, height minus header
    scrollingFrame.Position = UDim2.fromOffset(0, 85)
    scrollingFrame.BackgroundTransparency = 1
    scrollingFrame.BorderSizePixel = 0
    scrollingFrame.ScrollBarThickness = 6
    scrollingFrame.ScrollBarImageColor3 = UILib.Colors.JPUFF_PINK
    scrollingFrame.CanvasSize = UDim2.fromOffset(0, 0) -- Will auto-adjust
    scrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    scrollingFrame.ClipsDescendants = true

    -- Create selector button
    local btn = Instance.new("TextButton", window.SelectorButtonsContainer)
    btn.Size = UDim2.new(1, 0, 0, 45)
    btn.BackgroundColor3 = color
    btn.Text = ""
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.BorderSizePixel = 0
    btn.BackgroundTransparency = 1
    btn.LayoutOrder = layoutOrder
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)

    local mainText = Instance.new("TextLabel", btn)
    mainText.Size = UDim2.new(1, -50, 1, 0)
    mainText.Position = UDim2.fromOffset(15, 0)
    mainText.BackgroundTransparency = 1
    mainText.Text = displayName
    mainText.Font = Enum.Font.GothamBold
    mainText.TextSize = 16
    mainText.TextColor3 = Color3.fromRGB(150, 150, 160)
    mainText.TextXAlignment = Enum.TextXAlignment.Left
    mainText.TextTransparency = 1

    local arrow = Instance.new("TextLabel", btn)
    arrow.Size = UDim2.fromOffset(30, 45)
    arrow.Position = UDim2.fromOffset(10, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "→"
    arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 20
    arrow.TextColor3 = color
    arrow.TextXAlignment = Enum.TextXAlignment.Center
    arrow.TextTransparency = 1

    -- Hover effects
    btn.MouseEnter:Connect(function()
        TweenService:Create(mainText, TweenInfo.new(0.2), {TextColor3 = UILib.Colors.TEXT_PRIMARY}):Play()
    end)

    btn.MouseLeave:Connect(function()
        if window.CurrentPanel == name then
            TweenService:Create(mainText, TweenInfo.new(0.2), {TextColor3 = color}):Play()
        else
            TweenService:Create(mainText, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(150, 150, 160)}):Play()
        end
    end)

    -- Fade in button text
    task.spawn(function()
        task.wait(0.5)
        TweenService:Create(mainText, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
    end)

    local panel = {
        Name = name,
        Frame = panelFrame,
        ScrollingFrame = scrollingFrame,
        Button = btn,
        Arrow = arrow,
        MainText = mainText,
        Color = color,
        Size = size,
        ContentY = 0, -- Starting Y position for content (relative to scrolling frame)
        UpdateCanvasSize = function(self)
            -- Auto-adjust canvas size based on ContentY
            scrollingFrame.CanvasSize = UDim2.fromOffset(0, math.max(self.ContentY + 20, scrollingFrame.AbsoluteSize.Y or 400))
        end
    }

    -- Panel switching logic
    btn.MouseButton1Click:Connect(function()
        window:ShowPanel(name)
    end)

    window.Panels[name] = panel

    return panel
end

-- =====================================================
-- SHOW/HIDE PANEL
-- =====================================================
function UILib:ShowPanel(window, panelName)
    local panel = window.Panels[panelName]
    if not panel then return end

    -- If clicking the same panel, hide it
    if window.CurrentPanel == panelName then
        window:HidePanel(panelName)
        TweenService:Create(panel.Arrow, TweenInfo.new(0.3), {TextTransparency = 1, Position = UDim2.fromOffset(10, 0)}):Play()
        TweenService:Create(panel.MainText, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(150, 150, 160), Position = UDim2.fromOffset(15, 0)}):Play()
        return
    end

    -- Hide current panel if exists
    if window.CurrentPanel then
        local oldPanel = window.Panels[window.CurrentPanel]
        if oldPanel then
            window:HidePanel(window.CurrentPanel)
            TweenService:Create(oldPanel.Arrow, TweenInfo.new(0.3), {TextTransparency = 1, Position = UDim2.fromOffset(10, 0)}):Play()
            TweenService:Create(oldPanel.MainText, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(150, 150, 160), Position = UDim2.fromOffset(15, 0)}):Play()
        end
        task.wait(0.4)
    end

    -- Show new panel
    window.CurrentPanel = panelName
    panel.Frame.Visible = true
    panel.Frame.Size = UDim2.fromOffset(0, 0)
    panel.Frame.Position = UDim2.fromOffset(
        window.SelectorFrame.AbsolutePosition.X + window.SelectorFrame.AbsoluteSize.X / 2,
        window.SelectorFrame.AbsolutePosition.Y + 80
    )

    -- Animate text and arrow
    TweenService:Create(panel.MainText, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
        {TextColor3 = panel.Color, Position = UDim2.fromOffset(45, 0)}):Play()

    task.delay(0.12, function()
        if window.CurrentPanel == panelName then
            TweenService:Create(panel.Arrow, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), 
                {TextTransparency = 0, Position = UDim2.fromOffset(15, 0)}):Play()
        end
    end)

    -- Animate panel
    TweenService:Create(panel.Frame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), 
        {Size = panel.Size, Position = UDim2.fromOffset(
            window.SelectorFrame.AbsolutePosition.X + window.SelectorFrame.AbsoluteSize.X + 20,
            window.SelectorFrame.AbsolutePosition.Y
        )}):Play()
    TweenService:Create(panel.Frame, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
        {BackgroundTransparency = 0.15}):Play()

    local panelStroke = panel.Frame:FindFirstChildOfClass("UIStroke")
    if panelStroke then
        TweenService:Create(panelStroke, TweenInfo.new(0.6), {Transparency = 0.5}):Play()
    end

    -- Fade in all content
    for _, child in ipairs(panel.Frame:GetDescendants()) do
        if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
            TweenService:Create(child, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
        end
        if child:IsA("Frame") and child.Parent ~= window.ScreenGui then
            local goalBg = 0
            if child:FindFirstChild("IsTransparent") then
                goalBg = 0.2
            end
            TweenService:Create(child, TweenInfo.new(0.5), {BackgroundTransparency = goalBg}):Play()
        end
        if child:IsA("ImageLabel") then
            TweenService:Create(child, TweenInfo.new(0.5), {ImageTransparency = 0}):Play()
        end
    end
end

function UILib:HidePanel(window, panelName)
    local panel = window.Panels[panelName]
    if not panel or window.CurrentPanel ~= panelName then return end

    TweenService:Create(panel.Frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), 
        {Size = UDim2.fromOffset(0, 0), Position = UDim2.fromOffset(
            window.SelectorFrame.AbsolutePosition.X + window.SelectorFrame.AbsoluteSize.X / 2,
            window.SelectorFrame.AbsolutePosition.Y + 80
        )}):Play()

    task.wait(0.4)
    panel.Frame.Visible = false
    window.CurrentPanel = nil
end

-- =====================================================
-- TOGGLE
-- =====================================================
function UILib:CreateToggle(panel, config)
    config = config or {}
    local labelText = config.Label or "Toggle"
    local initialState = config.Default or false
    local callback = config.Callback or function() end
    local y = panel.ContentY

    local label = Instance.new("TextLabel", panel.ScrollingFrame)
    label.Size = UDim2.new(1, -150, 0, 45)
    label.Position = UDim2.fromOffset(30, y)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 16
    label.TextColor3 = UILib.Colors.TEXT_PRIMARY
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.TextTransparency = 0

    local track = Instance.new("Frame", panel.ScrollingFrame)
    track.Size = UDim2.fromOffset(90, 40)
    track.Position = UDim2.new(1, -120, 0, y + 2.5)
    track.BackgroundColor3 = initialState and UILib.Colors.JPUFF_HOT_PINK or UILib.Colors.TOGGLE_OFF
    track.BorderSizePixel = 0
    track.BackgroundTransparency = 0
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local ballBg = Instance.new("Frame", track)
    ballBg.Size = UDim2.fromOffset(34, 34)
    ballBg.AnchorPoint = Vector2.new(0.5, 0.5)
    ballBg.Position = initialState and UDim2.fromOffset(70, 20) or UDim2.fromOffset(20, 20)
    ballBg.BackgroundColor3 = UILib.Colors.TOGGLE_OFF
    ballBg.BackgroundTransparency = 1
    ballBg.BorderSizePixel = 0
    Instance.new("UICorner", ballBg).CornerRadius = UDim.new(1, 0)

    -- OFF IMAGE (Sleep)
    local imgOff = Instance.new("ImageLabel", ballBg)
    imgOff.Name = "ImgOff"
    imgOff.Size = UDim2.fromScale(1.2, 1.2)
    imgOff.Position = UDim2.fromScale(-0.1, -0.1)
    imgOff.BackgroundTransparency = 1
    imgOff.Image = "rbxthumb://type=Asset&id=134295060007569&w=150&h=150"
    imgOff.ScaleType = Enum.ScaleType.Crop
    imgOff.BorderSizePixel = 0
    imgOff.ZIndex = 2
    Instance.new("UICorner", imgOff).CornerRadius = UDim.new(1, 0)

    -- ON IMAGE (Awake)
    local imgOn = Instance.new("ImageLabel", ballBg)
    imgOn.Name = "ImgOn"
    imgOn.Size = UDim2.fromScale(1.2, 1.2)
    imgOn.Position = UDim2.fromScale(-0.1, -0.1)
    imgOn.BackgroundTransparency = 1
    imgOn.Image = "rbxthumb://type=Asset&id=111028440784816&w=150&h=150"
    imgOn.ScaleType = Enum.ScaleType.Crop
    imgOn.BorderSizePixel = 0
    imgOn.ZIndex = 2
    Instance.new("UICorner", imgOn).CornerRadius = UDim.new(1, 0)

    -- Set initial visibility
    if initialState then
        imgOn.ImageTransparency = 0
        imgOn.Visible = true
        imgOff.ImageTransparency = 1
        imgOff.Visible = false
    else
        imgOn.ImageTransparency = 1
        imgOn.Visible = false
        imgOff.ImageTransparency = 0
        imgOff.Visible = true
    end

    local button = Instance.new("TextButton", track)
    button.Size = UDim2.fromScale(1, 1)
    button.BackgroundTransparency = 1
    button.Text = ""

    local state = initialState
    local accumulatedRotation = 0
    local isAnimating = false

    local function toggle()
        if isAnimating then return state end
        isAnimating = true

        state = not state

        -- Enable both and force start values
        imgOn.Visible = true
        imgOn.ImageTransparency = state and 1 or 0
        imgOff.Visible = true
        imgOff.ImageTransparency = state and 0 or 1

        -- Animate track color
        TweenService:Create(track, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
            {BackgroundColor3 = state and UILib.Colors.JPUFF_HOT_PINK or UILib.Colors.TOGGLE_OFF}):Play()

        -- Animate ball position
        TweenService:Create(ballBg, TweenInfo.new(0.65, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), 
            {Position = state and UDim2.fromOffset(70, 20) or UDim2.fromOffset(20, 20)}):Play()

        -- Spin animation
        local rotationChange = state and 360 or -360
        accumulatedRotation = accumulatedRotation + rotationChange
        TweenService:Create(ballBg, TweenInfo.new(0.65, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), 
            {Rotation = accumulatedRotation}):Play()

        -- Cross-fade images
        TweenService:Create(imgOn, TweenInfo.new(0.65, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), 
            {ImageTransparency = state and 0 or 1}):Play()
        TweenService:Create(imgOff, TweenInfo.new(0.65, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), 
            {ImageTransparency = state and 1 or 0}):Play()

        task.delay(0.65, function()
            isAnimating = false
            if state then
                imgOff.Visible = false
            else
                imgOn.Visible = false
            end
        end)

        callback(state)
        return state
    end

    button.MouseButton1Click:Connect(toggle)

    panel.ContentY = panel.ContentY + 55
    panel:UpdateCanvasSize()

    return {
        Toggle = toggle,
        GetState = function() return state end,
        SetState = function(newState)
            if newState ~= state then
                toggle()
            end
        end
    }
end

-- =====================================================
-- BUTTON
-- =====================================================
function UILib:CreateButton(panel, config)
    config = config or {}
    local text = config.Text or "Button"
    local color = config.Color or UILib.Colors.SUCCESS
    local callback = config.Callback or function() end
    local y = panel.ContentY

    local btn = Instance.new("TextButton", panel.ScrollingFrame)
    btn.Size = UDim2.new(1, -60, 0, 45)
    btn.Position = UDim2.fromOffset(30, y)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.TextColor3 = UILib.Colors.TEXT_PRIMARY
    btn.BorderSizePixel = 0
    btn.BackgroundTransparency = 0.1
    btn.TextTransparency = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(
                math.min(255, color.R * 255 + 20),
                math.min(255, color.G * 255 + 20),
                math.min(255, color.B * 255 + 20)
            )
        }):Play()
    end)

    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = color}):Play()
    end)

    btn.MouseButton1Click:Connect(callback)

    panel.ContentY = panel.ContentY + 55
    panel:UpdateCanvasSize()

    return btn
end

-- =====================================================
-- TEXT INPUT
-- =====================================================
function UILib:CreateTextInput(panel, config)
    config = config or {}
    local placeholder = config.Placeholder or "Enter text..."
    local y = panel.ContentY

    local input = Instance.new("TextBox", panel.ScrollingFrame)
    input.Size = UDim2.new(1, -40, 0, 45)
    input.Position = UDim2.fromOffset(20, y)
    input.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    input.Text = ""
    input.PlaceholderText = placeholder
    input.Font = Enum.Font.GothamBold
    input.TextSize = 16
    input.TextColor3 = UILib.Colors.TEXT_PRIMARY
    input.PlaceholderColor3 = Color3.fromRGB(150, 150, 160)
    input.BorderSizePixel = 0
    input.BackgroundTransparency = 0.2
    input.TextTransparency = 1
    Instance.new("UICorner", input).CornerRadius = UDim.new(0, 12)

    local stroke = Instance.new("UIStroke", input)
    stroke.Color = UILib.Colors.JPUFF_PINK
    stroke.Transparency = 0.8

    panel.ContentY = panel.ContentY + 55
    panel:UpdateCanvasSize()

    return input
end

-- =====================================================
-- SLIDER
-- =====================================================
function UILib:CreateSlider(panel, config)
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
    
    local UserInputService = game:GetService("UserInputService")
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

-- =====================================================
-- DROPDOWN
-- =====================================================
function UILib:CreateDropdown(panel, config)
    config = config or {}
    local label = config.Label or "Dropdown"
    local options = config.Options or {"Option 1", "Option 2", "Option 3"}
    local callback = config.Callback or function() end
    local y = panel.ContentY
    
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

-- =====================================================
-- KEYBIND
-- =====================================================
function UILib:CreateKeybind(panel, config)
    config = config or {}
    local actionName = config.ActionName or "Action"
    local defaultKey = config.DefaultKey or nil
    local callback = config.Callback or function() end
    local y = panel.ContentY
    
    -- Start the global listener if not already started
    self:StartKeybindListener()
    
    -- Load saved keybinds
    local savedKeybinds = self:LoadKeybinds()
    local savedKey = savedKeybinds[actionName]
    if savedKey then
        -- Convert string back to KeyCode
        local keyCodeStr = savedKey:gsub("Enum.KeyCode.", "")
        defaultKey = Enum.KeyCode[keyCodeStr]
    end
    
    -- Register keybind
    self.Keybinds[actionName] = {
        Key = defaultKey,
        Callback = callback
    }
    
    -- Container for the keybind row (pink background with rounded corners)
    local container = Instance.new("Frame", panel.ScrollingFrame)
    container.Size = UDim2.new(1, -20, 0, 35)
    container.Position = UDim2.fromOffset(10, y)
    container.BackgroundColor3 = self.Colors.JPUFF_PINK
    container.BackgroundTransparency = 0.85 -- Slightly transparent pink
    container.BorderSizePixel = 0
    
    -- Rounded corners
    local corner = Instance.new("UICorner", container)
    corner.CornerRadius = UDim.new(0, 8)
    
    -- Dark pink outline
    local stroke = Instance.new("UIStroke", container)
    stroke.Color = self.Colors.JPUFF_DARK_PINK
    stroke.Thickness = 2
    
    -- Action name label (left side)
    local label = Instance.new("TextLabel", container)
    label.Size = UDim2.new(1, -80, 1, 0)
    label.Position = UDim2.fromOffset(20, 0)
    label.BackgroundColor3 = self.Colors.BG_DARK
    label.BackgroundTransparency = 1
    label.Text = actionName
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 15
    label.TextColor3 = self.Colors.TEXT_PRIMARY
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    
    -- Keybind display (right side) - Simple text like panel selector
    local keybindText = Instance.new("TextLabel", container)
    keybindText.Size = UDim2.fromOffset(60, 35)
    keybindText.Position = UDim2.new(1, -70, 0, 0)
    keybindText.BackgroundColor3 = self.Colors.BG_DARK
    keybindText.BackgroundTransparency = 1
    keybindText.Text = self:GetKeyName(defaultKey)
    keybindText.Font = Enum.Font.GothamBold
    keybindText.TextSize = 14
    keybindText.TextColor3 = self.Colors.TEXT_SECONDARY
    keybindText.TextXAlignment = Enum.TextXAlignment.Right
    keybindText.TextYAlignment = Enum.TextYAlignment.Center
    
    -- Invisible button for clicking
    local clickBtn = Instance.new("TextButton", container)
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.BackgroundColor3 = self.Colors.BG_DARK
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.ZIndex = 2
    
    -- Hover effect
    local listening = false
    clickBtn.MouseEnter:Connect(function()
        if not listening then
            keybindText.TextColor3 = self.Colors.JPUFF_HOT_PINK
        end
    end)
    
    clickBtn.MouseLeave:Connect(function()
        if not listening then
            keybindText.TextColor3 = self.Colors.TEXT_SECONDARY
        end
    end)
    
    -- Click to rebind
    clickBtn.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        self.ListeningForKeybind = true -- Disable global keybind listener
        keybindText.Text = "..."
        keybindText.TextColor3 = self.Colors.JPUFF_PINK
        
        -- Small delay to ensure flag is set before accepting input
        task.wait(0.1)
        
        -- Wait for key press
        local connection
        connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
            
            connection:Disconnect()
            listening = false
            self.ListeningForKeybind = false -- Re-enable global keybind listener
            
            -- ESC = unbind
            if input.KeyCode == Enum.KeyCode.Escape then
                self.Keybinds[actionName].Key = nil
                keybindText.Text = "None"
                keybindText.TextColor3 = self.Colors.TEXT_SECONDARY
                self:SaveKeybinds() -- Save after unbind
            else
                -- Set new key (DO NOT trigger callback here!)
                self.Keybinds[actionName].Key = input.KeyCode
                keybindText.Text = self:GetKeyName(input.KeyCode)
                keybindText.TextColor3 = self.Colors.TEXT_SECONDARY
                self:SaveKeybinds() -- Save after binding
            end
        end)
    end)
    
    panel.ContentY = panel.ContentY + 40
    panel:UpdateCanvasSize()
    
    return {
        SetKey = function(keyCode)
            self.Keybinds[actionName].Key = keyCode
            keybindText.Text = self:GetKeyName(keyCode)
        end,
        GetKey = function()
            return self.Keybinds[actionName].Key
        end,
        Remove = function()
            self.Keybinds[actionName] = nil
            container:Destroy()
        end
    }
end

-- =====================================================
-- NOTIFICATION
-- =====================================================
function UILib:CreateNotification(config)
    config = config or {}
    local text = config.Text or "Notification"
    local duration = config.Duration or 3
    local color = config.Color or UILib.Colors.SUCCESS

    local notif = Instance.new("ScreenGui", gui)
    notif.Name = "UILibNotification"
    notif.ResetOnSpawn = false
    notif.DisplayOrder = 200

    local frame = Instance.new("Frame", notif)
    frame.Size = UDim2.new(0, 300, 0, 80)
    frame.Position = UDim2.new(1, -320, 0, 20)
    frame.BackgroundColor3 = UILib.Colors.BG_DARK
    frame.BackgroundTransparency = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = color
    stroke.Thickness = 2

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -20, 1, -20)
    label.Position = UDim2.fromOffset(10, 10)
    label.BackgroundTransparency = 1
    label.Text = text
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextColor3 = UILib.Colors.TEXT_PRIMARY
    label.TextWrapped = true
    label.TextYAlignment = Enum.TextYAlignment.Center

    -- Slide in
    frame.Position = UDim2.new(1, 0, 0, 20)
    TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), 
        {Position = UDim2.new(1, -320, 0, 20)}):Play()

    -- Slide out and destroy
    task.delay(duration, function()
        TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), 
            {Position = UDim2.new(1, 0, 0, 20)}):Play()
        task.wait(0.3)
        notif:Destroy()
    end)

    return notif
end

-- =====================================================
-- TOGGLE GUI VISIBILITY (RIGHT SHIFT)
-- =====================================================
function UILib:AddToggleKey(window, keyCode)
    keyCode = keyCode or Enum.KeyCode.RightShift
    local guiVisible = true

    UserInputService.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == keyCode then
            guiVisible = not guiVisible
            if guiVisible then
                window.ScreenGui.Enabled = true
                TweenService:Create(window.SelectorFrame, TweenInfo.new(0.3), {BackgroundTransparency = 0.15}):Play()
                if window.CurrentPanel then
                    local panel = window.Panels[window.CurrentPanel]
                    if panel then
                        panel.Frame.Visible = true
                        TweenService:Create(panel.Frame, TweenInfo.new(0.3), {BackgroundTransparency = 0.15}):Play()
                    end
                end
            else
                TweenService:Create(window.SelectorFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
                if window.CurrentPanel then
                    local panel = window.Panels[window.CurrentPanel]
                    if panel then
                        TweenService:Create(panel.Frame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
                    end
                end
                task.wait(0.3)
                window.ScreenGui.Enabled = false
            end
        end
    end)
end



return UILib
