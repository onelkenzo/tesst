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
    
    -- Create ScreenGui
    local screenGui = Instance.new("ScreenGui", gui)
    screenGui.Name = config.Name or "UILibWindow"
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 100
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
    selectorFrame.Size = UDim2.fromOffset(220, 275)
    selectorFrame.Position = position
    selectorFrame.BackgroundColor3 = self.Colors.BG_DARK
    selectorFrame.Active = true
    selectorFrame.Draggable = true
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
    selectorButtonsContainer.Size = UDim2.new(1, -20, 0, 215)
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
        Button = btn,
        Arrow = arrow,
        MainText = mainText,
        Color = color,
        Size = size,
        ContentY = 90, -- Starting Y position for content
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
    
    local label = Instance.new("TextLabel", panel.Frame)
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
    
    local track = Instance.new("Frame", panel.Frame)
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
    
    local btn = Instance.new("TextButton", panel.Frame)
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
    
    return btn
end

-- =====================================================
-- TEXT INPUT
-- =====================================================
function UILib:CreateTextInput(panel, config)
    config = config or {}
    local placeholder = config.Placeholder or "Enter text..."
    local y = panel.ContentY
    
    local input = Instance.new("TextBox", panel.Frame)
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
    
    return input
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
-- CONFIRMATION DIALOG
-- =====================================================
function UILib:CreateConfirmation(config)
    config = config or {}
    local title = config.Title or "⚠️ WARNING"
    local message = config.Message or "Are you sure?"
    local confirmText = config.ConfirmText or "I'm sure"
    local cancelText = config.CancelText or "Cancel"
    local onConfirm = config.OnConfirm or function() end
    local onCancel = config.OnCancel or function() end
    
    local confirmationGui = Instance.new("ScreenGui", gui)
    confirmationGui.Name = "UILibConfirmation"
    confirmationGui.ResetOnSpawn = false
    confirmationGui.IgnoreGuiInset = true
    confirmationGui.DisplayOrder = 1000
    confirmationGui.Enabled = true
    
    local confirmBlur = Instance.new("BlurEffect", Lighting)
    confirmBlur.Size = 0
    confirmBlur.Name = "UILibConfirmBlur"
    
    local confirmOverlay = Instance.new("Frame", confirmationGui)
    confirmOverlay.Size = UDim2.fromScale(1, 1)
    confirmOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    confirmOverlay.BackgroundTransparency = 1
    
    local confirmDialog = Instance.new("Frame", confirmOverlay)
    confirmDialog.Size = UDim2.fromOffset(420, 240)
    confirmDialog.Position = UDim2.fromScale(0.5, 0.5)
    confirmDialog.AnchorPoint = Vector2.new(0.5, 0.5)
    confirmDialog.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    confirmDialog.BackgroundTransparency = 1
    Instance.new("UICorner", confirmDialog).CornerRadius = UDim.new(0, 20)
    
    local confirmStroke = Instance.new("UIStroke", confirmDialog)
    confirmStroke.Color = UILib.Colors.JPUFF_HOT_PINK
    confirmStroke.Thickness = 2
    confirmStroke.Transparency = 1
    
    local confirmTitle = Instance.new("TextLabel", confirmDialog)
    confirmTitle.Size = UDim2.new(1, -40, 0, 45)
    confirmTitle.Position = UDim2.fromOffset(20, 20)
    confirmTitle.BackgroundTransparency = 1
    confirmTitle.Text = title
    confirmTitle.Font = Enum.Font.GothamBold
    confirmTitle.TextSize = 24
    confirmTitle.TextColor3 = UILib.Colors.JPUFF_HOT_PINK
    confirmTitle.TextXAlignment = Enum.TextXAlignment.Left
    confirmTitle.TextTransparency = 1
    
    local confirmMessage = Instance.new("TextLabel", confirmDialog)
    confirmMessage.Size = UDim2.new(1, -40, 0, 90)
    confirmMessage.Position = UDim2.fromOffset(20, 75)
    confirmMessage.BackgroundTransparency = 1
    confirmMessage.Text = message
    confirmMessage.Font = Enum.Font.GothamMedium
    confirmMessage.TextSize = 16
    confirmMessage.TextColor3 = UILib.Colors.TEXT_PRIMARY
    confirmMessage.TextWrapped = true
    confirmMessage.TextXAlignment = Enum.TextXAlignment.Left
    confirmMessage.TextYAlignment = Enum.TextYAlignment.Top
    confirmMessage.TextTransparency = 1
    
    local buttonContainer = Instance.new("Frame", confirmDialog)
    buttonContainer.Size = UDim2.new(1, -40, 0, 50)
    buttonContainer.Position = UDim2.fromOffset(20, 175)
    buttonContainer.BackgroundTransparency = 1
    
    local cancelBtn = Instance.new("TextButton", buttonContainer)
    cancelBtn.Size = UDim2.new(0.48, 0, 1, 0)
    cancelBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
    cancelBtn.Text = cancelText
    cancelBtn.Font = Enum.Font.GothamBold
    cancelBtn.TextSize = 17
    cancelBtn.TextColor3 = UILib.Colors.TEXT_PRIMARY
    cancelBtn.BackgroundTransparency = 1
    cancelBtn.TextTransparency = 1
    Instance.new("UICorner", cancelBtn).CornerRadius = UDim.new(0, 12)
    
    local sureBtn = Instance.new("TextButton", buttonContainer)
    sureBtn.Size = UDim2.new(0.48, 0, 1, 0)
    sureBtn.Position = UDim2.fromScale(0.52, 0)
    sureBtn.BackgroundColor3 = UILib.Colors.ERROR
    sureBtn.Text = confirmText
    sureBtn.Font = Enum.Font.GothamBold
    sureBtn.TextSize = 17
    sureBtn.TextColor3 = UILib.Colors.TEXT_PRIMARY
    sureBtn.BackgroundTransparency = 1
    sureBtn.TextTransparency = 1
    Instance.new("UICorner", sureBtn).CornerRadius = UDim.new(0, 12)
    
    local function show()
        if not confirmBlur or not confirmBlur.Parent then
            confirmBlur = Instance.new("BlurEffect", Lighting)
            confirmBlur.Name = "UILibConfirmBlur"
            confirmBlur.Size = 0
        end
        
        confirmationGui.Enabled = true
        TweenService:Create(confirmBlur, TweenInfo.new(0.4), {Size = 20}):Play()
        TweenService:Create(confirmOverlay, TweenInfo.new(0.4), {BackgroundTransparency = 0.6}):Play()
        TweenService:Create(confirmDialog, TweenInfo.new(0.4), {BackgroundTransparency = 0.05}):Play()
        TweenService:Create(confirmStroke, TweenInfo.new(0.4), {Transparency = 0.3}):Play()
        TweenService:Create(confirmTitle, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
        TweenService:Create(confirmMessage, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
        TweenService:Create(cancelBtn, TweenInfo.new(0.4), {BackgroundTransparency = 0, TextTransparency = 0}):Play()
        TweenService:Create(sureBtn, TweenInfo.new(0.4), {BackgroundTransparency = 0, TextTransparency = 0}):Play()
    end
    
    local function hide()
        TweenService:Create(confirmBlur, TweenInfo.new(0.3), {Size = 0}):Play()
        TweenService:Create(confirmOverlay, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        TweenService:Create(confirmDialog, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        TweenService:Create(confirmTitle, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        TweenService:Create(confirmMessage, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        TweenService:Create(cancelBtn, TweenInfo.new(0.3), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
        TweenService:Create(sureBtn, TweenInfo.new(0.3), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
        task.wait(0.3)
        confirmationGui.Enabled = false
    end
    
    cancelBtn.MouseButton1Click:Connect(function()
        hide()
        onCancel()
    end)
    
    sureBtn.MouseButton1Click:Connect(function()
        hide()
        onConfirm()
    end)
    
    show()
    
    return {
        Show = show,
        Hide = hide,
        Destroy = function()
            if confirmBlur then confirmBlur:Destroy() end
            if confirmationGui then confirmationGui:Destroy() end
        end
    }
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

-- =====================================================
-- METHODS FOR WINDOW
-- =====================================================
function UILib:AddMethods(window)
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
    
    window.Destroy = function(self)
        if self.ScreenGui then
            self.ScreenGui:Destroy()
        end
    end
end

return UILib