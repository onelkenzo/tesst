--FIXED AUTOFISSH

-- FULL UPDATED SCRIPT HERE
-- JPUFF GUI V18 - POLISHED UI WITH CLEAN AESTHETICS & ARROW ALIGNMENT
-- =========================
-- LOADING SCREEN & BYPASS
-- =========================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui")
local Lighting = game:GetService("Lighting")

-- SAFETY WATCHDOG: Ensures Blur is removed and GUI is shown even if script errors
task.spawn(function()
    task.wait(8) -- Max wait time
    local stuckBlur = Lighting:FindFirstChild("JPuffLoadBlur")
    if stuckBlur then stuckBlur:Destroy() end
    
    local stuckLoading = gui:FindFirstChild("BypassLoadingScreen")
    if stuckLoading then stuckLoading:Destroy() end
    
    local mainGui = gui:FindFirstChild("FishingControlGUI")
    if mainGui then 
        mainGui.Enabled = true 
        -- Force verify frame visibility if they stuck invisible
        local sel = mainGui:FindFirstChild("Frame") -- Selector
        if sel then 
            sel.Visible = true 
            sel.BackgroundTransparency = 0.15 
        end
    end
end)

-- Create loading screen GUI
local loadingGui = Instance.new("ScreenGui", gui)
loadingGui.Name = "BypassLoadingScreen"
loadingGui.ResetOnSpawn = false
loadingGui.IgnoreGuiInset = true
loadingGui.DisplayOrder = 999

-- Blur effect
local blur = Instance.new("BlurEffect", Lighting)
blur.Name = "JPuffLoadBlur"
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
loadingText.Text = "Loading JPuff..."
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
        loadingText.Text = 'Loading <font color="rgb(255,105,180)">JPuff</font>' .. dots
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
progressFill.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
progressFill.BorderSizePixel = 0
Instance.new("UICorner", progressFill).CornerRadius = UDim.new(1, 0)

-- Animate blur in
TweenService:Create(blur, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = 24}):Play()

-- Animate progress bar
local progressTween = TweenService:Create(
    progressFill,
    TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    {Size = UDim2.fromScale(1, 1)}
)
progressTween:Play()

-- =========================
-- BYPASS EXECUTION
-- =========================
task.spawn(function()
    pcall(function() -- Safe wrap bypass
        if game and not game:IsLoaded() then
            repeat wait() until game:IsLoaded()
        end
        
        local old_identity = getthreadidentity()
        
        setthreadidentity(2) 
        
        task.spawn(function()
            for _, func in ipairs(getgc(true)) do
                if typeof(func) == "function" and islclosure(func) then
                    local ok, consts = pcall(debug.getconstants, func)
                    if ok and consts and #consts <= 2 then
                        for i, c in ipairs(consts) do
                            if tostring(c):lower():find("script") == nil and tostring(c):lower():find("rbx") == nil then
                                local src = debug.info(func, "s") or ""
                                if src:find("Anti") or src:lower():find("core") then
                                    hookfunction(func, function(...) return end)
                                end
                            end
                        end
                    end
                end
            end
        end)
        
        task.defer(function()
            for _, v in getgc(true) do
                if typeof(v) == "table" and rawget(v, "Kill") and typeof(v.Kill) == "function" then
                    hookfunction(v.Kill, function(...) return end)
                end
            end
        end)
        
        local old_debug_info = debug.info
        hookfunction(debug.info, newcclosure(function(func, what)
            if typeof(func) == "function" and debug.info(func, "s") and debug.info(func, "s"):find("Core.Anti") then
                if what == "n" then return "Detected" end
                if what == "f" then return func end
                if what == "s" then return debug.info(func, "s") end
                if what == "l" then return debug.info(func, "l") end
                if what == "a" then return debug.info(func, "a") end
            end
            return old_debug_info(func, what)
        end))
        
        setthreadidentity(old_identity)
    end)
end)

-- Wait for bypass to complete
task.wait(2.5)

-- Update loading text
loadingText.Text = '<font color="rgb(255,105,180)">JPuff Loaded!</font>'
task.wait(0.5)

-- Fade out loading screen and unblur
local fadeOutTween = TweenService:Create(
    loadingBg,
    TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
    {BackgroundTransparency = 1}
)

local textFadeTween = TweenService:Create(
    loadingText,
    TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
    {TextTransparency = 1}
)

local frameFadeTween = TweenService:Create(
    loadingFrame,
    TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
    {BackgroundTransparency = 1}
)

local blurTween = TweenService:Create(
    blur,
    TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
    {Size = 0}
)

fadeOutTween:Play()
textFadeTween:Play()
frameFadeTween:Play()
blurTween:Play()

-- NON-BLOCKING WAIT
task.wait(0.9) 
if blur then blur:Destroy() end
if loadingGui then loadingGui:Destroy() end

-- =========================
-- MAIN GUI STARTS HERE
-- =========================

-- SERVICES
local RunService = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")

-- =========================
-- PERSISTENT CONFIG SYSTEM
-- =========================
local HttpService = game:GetService("HttpService")
local CONFIG_FILE = "fishing_config.json"

local DefaultConfig = {
    tapEnabled = false,
    barEnabled = false,
    castEnabled = true,
    fishLocEnabled = false,
    freezeEnabled = false,
    AutoEquipBestRod = false,
    autoRejoinEnabled = true,
    reduceMemoryEnabled = false
}

local function loadConfig()
    if isfile and isfile(CONFIG_FILE) then
        local ok, data = pcall(function()
            return HttpService:JSONDecode(readfile(CONFIG_FILE))
        end)

        if ok and type(data) == "table" then
            for k,v in pairs(DefaultConfig) do
                if data[k] ~= nil then
                    DefaultConfig[k] = data[k]
                end
            end
        end
    end
end

local function saveConfig()
    if writefile then
        local encoded = HttpService:JSONEncode(DefaultConfig)
        writefile(CONFIG_FILE, encoded)
    end
end

loadConfig()

-- =========================
-- AUTO REJOIN SETUP
-- =========================
getgenv()._VIP_ACCESS_CODE = getgenv()._VIP_ACCESS_CODE or nil
getgenv()._KickRejoinFired = getgenv()._KickRejoinFired or false

-- Capture VIP access code
local TeleportService = game:GetService("TeleportService")
local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    -- Detect VIP teleport
    if self == TeleportService and method == "TeleportToPrivateServer" then
        local placeId, accessCode = args[1], args[2]
        if type(accessCode) == "string" and accessCode ~= "" then
            getgenv()._VIP_ACCESS_CODE = accessCode
        end
    end

    -- Detect kick and rejoin
    if method == "Kick" and self == player then
        if DefaultConfig.autoRejoinEnabled and not getgenv()._KickRejoinFired then
            getgenv()._KickRejoinFired = true
            task.delay(2, function()
                if getgenv()._VIP_ACCESS_CODE then
                    TeleportService:TeleportToPrivateServer(
                        game.PlaceId,
                        getgenv()._VIP_ACCESS_CODE,
                        { player }
                    )
                else
                    TeleportService:Teleport(game.PlaceId, player)
                end
            end)
            return
        end
    end

    return old(self, ...)
end)

setreadonly(mt, true)

if queue_on_teleport then
    queue_on_teleport([[
        loadstring(game:HttpGet("https://raw.githubusercontent.com/onelkenzo/tesst/main/test03.lua"))()
    ]])
end

-- =========================
-- CONFIG
-- =========================
local GREEN_THRESHOLD = 150
local CLICK_INTERVAL = 0.05

local HUMAN_DELAY_MIN = 0.2
local HUMAN_DELAY_MAX = 0.3

-- =========================
-- ROD NAMES (IN-GAME)
-- =========================
local VALID_RODS = {
    ["Plasma Strike Rod"] = true,
    ["Basic Rod"] = true,
    ["Jolly Prism Rod"] = true,
    ["BETA Bronze Rod"] = true,
    ["New Year Rod"] = true,
    ["Steam Punk Rod"] = true,
    ["Steel Sword Rod"] = true,
    ["Red Candy Rod"] = true,
    ["BETA Gold Rod"] = true,
    ["Green Bamboo Rod"] = true,
    ["BETA Diamond Rod"] = true,
    ["Inferno Flame Rod"] = true,
    ["Green Necromancer Rod"] = true,
    ["Frozen Snowflake Rod"] = true,
    ["Christmas Tree Rod"] = true,
    ["Santa Sleigh Rod"] = true,
    ["Mossy White Rod"] = true,
    ["BETA Silver Rod"] = true,
    ["Green Candy Rod"]     = true,
    ["Blue Candy Rod"] = true,
    ["Angelic Wing Rod"] = true,
    ["Charming Heart Rod"] = true,
    ["Leafy Branch Rod"] = true,
    ["Yellow Pencil Rod"] = true,
}


local AutoEquipBestRod = DefaultConfig.AutoEquipBestRod


local RodPriority = {
    "Basic Rod",
    "Leafy Branch Rod",
    "Jolly Prism Rod",
    "Mossy White Rod",
    "Green Bamboo Rod",
    "Yellow Pencil Rod",
    "Steam Punk Rod",
    "Steel Sword Rod"   ,
    "Angelic Wing Rod",
    "Charming Heart Rod",
    "Inferno Flame Rod",
    "Plasma Strike Rod",
    "New Year Rod",
    "Santa Sleigh Rod",
    "Green Necromancer Rod",
    "Christmas Tree Rod",
    "Frozen Snowflake Rod"
}


-- =========================
-- STATE FLAGS
-- =========================
local running = true

local tapEnabled      = DefaultConfig.tapEnabled
local barEnabled      = DefaultConfig.barEnabled
local castEnabled     = DefaultConfig.castEnabled
local fishLocEnabled  = DefaultConfig.fishLocEnabled
local freezeEnabled   = DefaultConfig.freezeEnabled
local reduceMemoryEnabled = DefaultConfig.reduceMemoryEnabled

local hasEnteredFishing = false
local allowRecastAfterFish = false

local savedCFrame = nil
local casting = false

-- =========================
-- UTILS
-- =========================

local function humanDelay()
    task.wait(math.random(
        HUMAN_DELAY_MIN * 1000,
        HUMAN_DELAY_MAX * 1000
    ) / 1000)
end

local function clickGui(obj)
    if not obj or not obj:IsDescendantOf(game) then return end
    local pos = obj.AbsolutePosition + (obj.AbsoluteSize / 2)
    VIM:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
    task.wait()
    VIM:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
end

local function getChar()
    return player.Character or player.CharacterAdded:Wait()
end

local function setAnchored(state)
    for _, v in ipairs(getChar():GetDescendants()) do
        if v:IsA("BasePart") then
            v.Anchored = state
        end
    end
end

-- =========================
-- STARTUP STATE APPLY
-- =========================
local function applyStartupState()
    local char = getChar()
    local root = char:WaitForChild("HumanoidRootPart")

    if fishLocEnabled then
        savedCFrame = root.CFrame
        root.CFrame = CFrame.new(-2502.88, -13.00, -561.81)
            * CFrame.Angles(0, math.rad(-87.95), 0)
    end

    if freezeEnabled then
        setAnchored(true)
    end
    
    if reduceMemoryEnabled then
        pcall(function()
            game:GetService("RunService"):Set3dRenderingEnabled(false)
        end)
    end
end

local function findRod()
    local char = getChar()
    local backpack = player:WaitForChild("Backpack")
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") and VALID_RODS[tool.Name] and tool:FindFirstChild("Cast") and tool:FindFirstChild("ToolReady") then
            return tool
        end
    end
    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") and VALID_RODS[tool.Name] and tool:FindFirstChild("Cast") and tool:FindFirstChild("ToolReady") then
            return tool
        end
    end
    return nil
end

local function playerOwnsRod(name)
    local backpack = player:WaitForChild("Backpack")
    if backpack:FindFirstChild(name) then return true end
    local char = getChar()
    if char:FindFirstChild(name) then return true end
    return false
end

local function equipRod(name)
    local char = getChar()
    local humanoid = char:WaitForChild("Humanoid")
    local backpack = player:WaitForChild("Backpack")
    local tool = backpack:FindFirstChild(name)
    if tool then humanoid:EquipTool(tool) end
end

-- =========================
-- POLISHED TRIPLE PANEL GUI SYSTEM
-- =========================

-- Jigglypuff Color Palette
local JPUFF_PINK = Color3.fromRGB(255, 182, 193)
local JPUFF_HOT_PINK = Color3.fromRGB(255, 105, 180)
local JPUFF_DARK_PINK = Color3.fromRGB(255, 140, 170)
local BG_DARK = Color3.fromRGB(25, 25, 35)
local BG_CARD = Color3.fromRGB(35, 35, 45)
local TEXT_PRIMARY = Color3.fromRGB(255, 255, 255)
local TEXT_SECONDARY = Color3.fromRGB(200, 200, 210)
local TOGGLE_OFF = Color3.fromRGB(60, 60, 70)

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui", gui)
screenGui.Name = "FishingControlGUI"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 100 
screenGui.Enabled = true

local currentPanel = nil -- Defined early for access by UI functions

-- =========================
-- LEFT PANEL (SELECTOR) - REFACTORED
-- =========================
local selectorFrame = Instance.new("Frame", screenGui)
selectorFrame.Size = UDim2.fromOffset(220, 275) 
selectorFrame.Position = UDim2.fromOffset(50, 50)
selectorFrame.BackgroundColor3 = BG_DARK
selectorFrame.Active = true
selectorFrame.Draggable = true
selectorFrame.BackgroundTransparency = 1
local selectorCorner = Instance.new("UICorner", selectorFrame)
selectorCorner.CornerRadius = UDim.new(0, 20)

local selectorStroke = Instance.new("UIStroke", selectorFrame)
selectorStroke.Color = JPUFF_PINK
selectorStroke.Thickness = 2
selectorStroke.Transparency = 1

-- Selector header
local selectorHeader = Instance.new("TextLabel", selectorFrame)
selectorHeader.Size = UDim2.new(1, -20, 0, 40)
selectorHeader.Position = UDim2.fromOffset(10, 10)
selectorHeader.BackgroundTransparency = 1
selectorHeader.Text = "Select Option"
selectorHeader.Font = Enum.Font.GothamBold
selectorHeader.TextSize = 18
selectorHeader.TextColor3 = JPUFF_PINK
selectorHeader.TextXAlignment = Enum.TextXAlignment.Center
selectorHeader.TextTransparency = 1

-- Buttons Container with UIListLayout
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

-- Function to create aligned button with arrow on right
-- Function to create aligned button with arrow on right
local function makeAlignedButton(parent, text, color, layoutOrder, panelKey)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, 0, 0, 45)
    btn.BackgroundColor3 = color
    btn.Text = ""
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.BorderSizePixel = 0
    btn.BackgroundTransparency = 1
    btn.LayoutOrder = layoutOrder
    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0, 12)
    
    local mainText = Instance.new("TextLabel", btn)
    mainText.Size = UDim2.new(1, -50, 1, 0)
    mainText.Position = UDim2.fromOffset(15, 0)
    mainText.BackgroundTransparency = 1
    mainText.Text = text
    mainText.Font = Enum.Font.GothamBold
    mainText.TextSize = 16
    mainText.TextColor3 = Color3.fromRGB(150, 150, 160) -- Dim default (Secondary)
    mainText.TextXAlignment = Enum.TextXAlignment.Left
    mainText.TextTransparency = 1
    
    local arrow = Instance.new("TextLabel", btn)
    arrow.Size = UDim2.fromOffset(30, 45)
    arrow.Position = UDim2.fromOffset(10, 0) -- Start Left (Hidden position for slide anim)
    arrow.BackgroundTransparency = 1
    arrow.Text = "→"
    arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 20
    arrow.TextColor3 = color -- Use theme color
    arrow.TextXAlignment = Enum.TextXAlignment.Center
    arrow.TextTransparency = 1 -- Hidden by default
    
    -- Special logic for Close Button (no arrow text, keep background)
    if text:find("Close") then
        arrow.Text = ""
        btn.BackgroundTransparency = 0 -- Keep red background
        btn.TextTransparency = 0 -- Keep text visible (though mainText handles it)
        mainText.TextColor3 = TEXT_PRIMARY -- Start White
    end
    
    -- Hover Effect
    btn.MouseEnter:Connect(function()
        -- Glow text on hover
        TweenService:Create(mainText, TweenInfo.new(0.2), {TextColor3 = TEXT_PRIMARY}):Play()
    end)
    btn.MouseLeave:Connect(function()
        if text:find("Close") then
            -- Close button: Always stay White
             TweenService:Create(mainText, TweenInfo.new(0.2), {TextColor3 = TEXT_PRIMARY}):Play()
        else
            -- Normal buttons: Fade back to dimmed if not active.
            -- Check currentPanel directly to be robust against animation delays
            if currentPanel == panelKey then
                  -- Active: Revert to theme color
                 TweenService:Create(mainText, TweenInfo.new(0.2), {TextColor3 = color}):Play()
            else
                 -- Inactive: Fade to dim
                 TweenService:Create(mainText, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(150, 150, 160)}):Play()
            end
        end
    end)
    
    return btn, mainText, arrow
end

local autoFishBtn, autoFishText, autoFishArrow = makeAlignedButton(selectorButtonsContainer, "Auto Fish", JPUFF_HOT_PINK, 1, "autoFish")
local moneyGiverBtn, moneyGiverText, moneyGiverArrow = makeAlignedButton(selectorButtonsContainer, "Money Giver", Color3.fromRGB(255, 215, 0), 2, "moneyGiver")
local miscBtn, miscText, miscArrow = makeAlignedButton(selectorButtonsContainer, "Misc", Color3.fromRGB(120, 180, 255), 3, "misc")
local closeSelectorBtn, closeSelectorText, closeSelectorArrow = makeAlignedButton(selectorButtonsContainer, "❌ Close Script", Color3.fromRGB(220, 80, 100), 4, nil)

-- =========================
-- HELPER: TOGGLES
-- =========================
local function makeToggle(parentFrame, labelText, y, initialState)
    local label = Instance.new("TextLabel", parentFrame)
    label.Size = UDim2.new(1, -150, 0, 45)
    label.Position = UDim2.fromOffset(30, y)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 16
    label.TextColor3 = TEXT_PRIMARY
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.TextTransparency = 0
    
    local track = Instance.new("Frame", parentFrame)
    track.Size = UDim2.fromOffset(90, 40)
    track.Position = UDim2.new(1, -120, 0, y + 2.5)
    track.BackgroundColor3 = initialState and JPUFF_HOT_PINK or TOGGLE_OFF
    track.BorderSizePixel = 0
    track.BackgroundTransparency = 0
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
    
    local ballBg = Instance.new("Frame", track)
    ballBg.Size = UDim2.fromOffset(34, 34)
    ballBg.AnchorPoint = Vector2.new(0.5, 0.5) -- Center pivot for rotation
    ballBg.Position = initialState and UDim2.fromOffset(70, 20) or UDim2.fromOffset(20, 20) -- Recalculated for center anchor
    ballBg.BackgroundColor3 = TOGGLE_OFF 
    ballBg.BackgroundTransparency = 1 -- Keep transparency
    ballBg.BorderSizePixel = 0
    Instance.new("UICorner", ballBg).CornerRadius = UDim.new(1, 0)
    
    -- Two ImageLabels for CROSS-FADE animation
    -- We use Visible property to firmly hide the unused state
    
    -- OFF IMAGE (Sleep)
    local imgOff = Instance.new("ImageLabel", ballBg)
    imgOff.Name = "ImgOff"
    imgOff.Size = UDim2.fromScale(1.2, 1.2)
    imgOff.Position = UDim2.fromScale(-0.1, -0.1)
    imgOff.BackgroundTransparency = 1
    imgOff.Image = "rbxthumb://type=Asset&id=134295060007569&w=150&h=150" -- Sleep
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
    imgOn.Image = "rbxthumb://type=Asset&id=111028440784816&w=150&h=150" -- Awake
    imgOn.ScaleType = Enum.ScaleType.Crop
    imgOn.BorderSizePixel = 0
    imgOn.ZIndex = 2
    Instance.new("UICorner", imgOn).CornerRadius = UDim.new(1, 0)
    
    -- Explicit Logic for Initial State (Hard Visibility Enforcement)
    if initialState then
        -- STATE IS ON: Show Awake, Hide Sleep
        imgOn.ImageTransparency = 0
        imgOn.Visible = true
        
        imgOff.ImageTransparency = 1
        imgOff.Visible = false 
    else
        -- STATE IS OFF: Show Sleep, Hide Awake
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
        if isAnimating then return state end -- Debounce
        isAnimating = true
        
        state = not state
        
        -- Enable both and FORCE start values to prevent "pop"
        imgOn.Visible = true
        imgOn.ImageTransparency = state and 1 or 0
        
        imgOff.Visible = true
        imgOff.ImageTransparency = state and 0 or 1
        
        -- Animate track color
        TweenService:Create(track, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = state and JPUFF_HOT_PINK or TOGGLE_OFF}):Play()
        
        -- Animate ball background position (Visible acceleration)
        TweenService:Create(ballBg, TweenInfo.new(0.65, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = state and UDim2.fromOffset(70, 20) or UDim2.fromOffset(20, 20)}):Play()
        
        -- Reliable Spin: Spin forward (CW) for ON, backward (CCW) for OFF
        local rotationChange = state and 360 or -360
        accumulatedRotation = accumulatedRotation + rotationChange
        TweenService:Create(ballBg, TweenInfo.new(0.65, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Rotation = accumulatedRotation}):Play()
        
        -- CROSS-FADE ANIMATION (Synced with Spin)
        local targetOnTrans = state and 0 or 1
        local targetOffTrans = state and 1 or 0
        
        TweenService:Create(imgOn, TweenInfo.new(0.65, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = targetOnTrans}):Play()
        TweenService:Create(imgOff, TweenInfo.new(0.65, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = targetOffTrans}):Play()
        
        -- Unlock debounce and cleanup visibility
        task.delay(0.65, function()
            isAnimating = false
            -- HIDE unused image after animation to prevent ghosts
            -- Wait, if transparency is 1, it should be fine, but let's be safe.
            if state then
                imgOff.Visible = false
            else
                imgOn.Visible = false
            end
        end)
        
        return state
    end
    
    return label, track, ballBg, button, toggle, function() return state end
end

-- HELPER: ACTION BUTTON
local function makeActionButton(parentFrame, text, y, color)
    local btn = Instance.new("TextButton", parentFrame)
    btn.Size = UDim2.new(1, -60, 0, 45)
    btn.Position = UDim2.fromOffset(30, y)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.TextColor3 = TEXT_PRIMARY
    btn.BorderSizePixel = 0
    if text:find("Sell All") then
        btn.BackgroundTransparency = 0.1
        btn.TextTransparency = 0
    else
        btn.BackgroundTransparency = 1
        btn.TextTransparency = 1
    end
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(math.min(255, color.R*255+20), math.min(255, color.G*255+20), math.min(255, color.B*255+20))}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = color}):Play()
    end)
    
    return btn
end

-- =========================
-- RIGHT PANEL A (AUTO FISH)
-- =========================
local autoFishFrame = Instance.new("Frame", screenGui)
autoFishFrame.Size = UDim2.fromOffset(340, 530)
autoFishFrame.Position = UDim2.fromOffset(290, 50)
autoFishFrame.BackgroundColor3 = BG_DARK
autoFishFrame.Active = true
autoFishFrame.BackgroundTransparency = 1
autoFishFrame.Visible = false
local autoFishCornerFrame = Instance.new("UICorner", autoFishFrame)
autoFishCornerFrame.CornerRadius = UDim.new(0, 20)
local autoFishStroke = Instance.new("UIStroke", autoFishFrame)
autoFishStroke.Color = JPUFF_PINK
autoFishStroke.Thickness = 2
autoFishStroke.Transparency = 1

local autoFishHeader = Instance.new("TextLabel", autoFishFrame)
autoFishHeader.Size = UDim2.new(1, -40, 0, 50)
autoFishHeader.Position = UDim2.fromOffset(20, 15)
autoFishHeader.BackgroundTransparency = 1
autoFishHeader.Text = "JPUFF FISHING"
autoFishHeader.Font = Enum.Font.GothamBold
autoFishHeader.TextSize = 22
autoFishHeader.TextColor3 = JPUFF_PINK
autoFishHeader.TextXAlignment = Enum.TextXAlignment.Left
autoFishHeader.TextTransparency = 1

local autoFishDivider = Instance.new("Frame", autoFishFrame)
autoFishDivider.Size = UDim2.new(1, -40, 0, 2)
autoFishDivider.Position = UDim2.fromOffset(20, 70)
autoFishDivider.BackgroundColor3 = JPUFF_PINK
autoFishDivider.BorderSizePixel = 0
autoFishDivider.BackgroundTransparency = 1
Instance.new("UICorner", autoFishDivider).CornerRadius = UDim.new(1, 0)

-- Auto Fish toggles
local tapLabel, tapTrack, tapBall, tapBtn, tapToggleFn, tapGetState = makeToggle(autoFishFrame, "Tap Game", 90, tapEnabled)
local barLabel, barTrack, barBall, barBtn, barToggleFn, barGetState = makeToggle(autoFishFrame, "Bar Game", 145, barEnabled)
local castLabel, castTrack, castBall, castBtn, castToggleFn, castGetState = makeToggle(autoFishFrame, "Auto Cast", 200, castEnabled)
local equipLabel, equipTrack, equipBall, equipBtn, equipToggleFn, equipGetState = makeToggle(autoFishFrame, "Equip Best Rod", 255, AutoEquipBestRod)
local fishLabel, fishTrack, fishBall, fishBtn, fishToggleFn, fishGetState = makeToggle(autoFishFrame, "Fish Location", 310, fishLocEnabled)
local freezeLabel, freezeTrack, freezeBall, freezeBtn, freezeToggleFn, freezeGetState = makeToggle(autoFishFrame, "Freeze", 365, freezeEnabled)
local rejoinLabel, rejoinTrack, rejoinBall, rejoinBtn, rejoinToggleFn, rejoinGetState = makeToggle(autoFishFrame, "Auto Rejoin", 420, DefaultConfig.autoRejoinEnabled)

local sellBtn = makeActionButton(autoFishFrame, "💰 Sell All", 475, Color3.fromRGB(80, 200, 120))

-- =========================
-- RIGHT PANEL B (MISC)
-- =========================
local miscFrame = Instance.new("Frame", screenGui)
miscFrame.Size = UDim2.fromOffset(340, 280)
miscFrame.Position = UDim2.fromOffset(290, 50)
miscFrame.BackgroundColor3 = BG_DARK
miscFrame.Active = true
miscFrame.BackgroundTransparency = 1
miscFrame.Visible = false
local miscCornerFrame = Instance.new("UICorner", miscFrame)
miscCornerFrame.CornerRadius = UDim.new(0, 20)
local miscStroke = Instance.new("UIStroke", miscFrame)
miscStroke.Color = JPUFF_PINK
miscStroke.Thickness = 2
miscStroke.Transparency = 1

local miscHeader = Instance.new("TextLabel", miscFrame)
miscHeader.Size = UDim2.new(1, -40, 0, 50)
miscHeader.Position = UDim2.fromOffset(20, 15)
miscHeader.BackgroundTransparency = 1
miscHeader.Text = "⚙️ MISC OPTIONS"
miscHeader.Font = Enum.Font.GothamBold
miscHeader.TextSize = 22
miscHeader.TextColor3 = JPUFF_PINK
miscHeader.TextXAlignment = Enum.TextXAlignment.Left
miscHeader.TextTransparency = 1

local miscDivider = Instance.new("Frame", miscFrame)
miscDivider.Size = UDim2.new(1, -40, 0, 2)
miscDivider.Position = UDim2.fromOffset(20, 70)
miscDivider.BackgroundColor3 = JPUFF_PINK
miscDivider.BorderSizePixel = 0
miscDivider.BackgroundTransparency = 1
Instance.new("UICorner", miscDivider).CornerRadius = UDim.new(1, 0)

-- Misc Buttons (Boost FPS as Toggle)
local boostFpsLabel, boostFpsTrack, boostFpsBall, boostFpsBtn, boostFpsToggleFn, boostFpsGetState = makeToggle(miscFrame, "🚀 Boost FPS", 90, false)
local memoryLabel, memoryTrack, memoryBall, memoryBtn, memoryToggleFn, memoryGetState = makeToggle(miscFrame, "🧠 Reduce Memory", 145, reduceMemoryEnabled)

-- =========================
-- RIGHT PANEL C (MONEY GIVER)
-- =========================
local moneyGiverFrame = Instance.new("Frame", screenGui)
moneyGiverFrame.Size = UDim2.fromOffset(340, 325) 
moneyGiverFrame.Position = UDim2.fromOffset(290, 50)
moneyGiverFrame.BackgroundColor3 = BG_DARK
moneyGiverFrame.Active = true
moneyGiverFrame.BackgroundTransparency = 1
moneyGiverFrame.Visible = false
local moneyCorner = Instance.new("UICorner", moneyGiverFrame)
moneyCorner.CornerRadius = UDim.new(0, 20)
local moneyStroke = Instance.new("UIStroke", moneyGiverFrame)
moneyStroke.Color = JPUFF_PINK
moneyStroke.Thickness = 2
moneyStroke.Transparency = 1

local moneyHeader = Instance.new("TextLabel", moneyGiverFrame)
moneyHeader.Size = UDim2.new(1, -40, 0, 50)
moneyHeader.Position = UDim2.fromOffset(20, 15)
moneyHeader.BackgroundTransparency = 1
moneyHeader.Text = "MONEY GIVER"
moneyHeader.Font = Enum.Font.GothamBold
moneyHeader.TextSize = 22
moneyHeader.TextColor3 = JPUFF_PINK
moneyHeader.TextXAlignment = Enum.TextXAlignment.Left
moneyHeader.TextTransparency = 1

local moneyDivider = Instance.new("Frame", moneyGiverFrame)
moneyDivider.Size = UDim2.new(1, -40, 0, 2)
moneyDivider.Position = UDim2.fromOffset(20, 70)
moneyDivider.BackgroundColor3 = JPUFF_PINK
moneyDivider.BorderSizePixel = 0
moneyDivider.BackgroundTransparency = 1
Instance.new("UICorner", moneyDivider).CornerRadius = UDim.new(1, 0)

-- Money Input
local moneyInput = Instance.new("TextBox", moneyGiverFrame)
moneyInput.Size = UDim2.new(1, -60, 0, 45)
moneyInput.Position = UDim2.fromOffset(30, 100) 
moneyInput.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
moneyInput.Text = ""
moneyInput.PlaceholderText = "Enter Amount (e.g. 1.325M)"
moneyInput.Font = Enum.Font.GothamBold
moneyInput.TextSize = 16
moneyInput.TextColor3 = TEXT_PRIMARY
moneyInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 160)
moneyInput.BorderSizePixel = 0
moneyInput.BackgroundTransparency = 0.2
moneyInput.TextTransparency = 1
local moneyInputCorner = Instance.new("UICorner", moneyInput)
moneyInputCorner.CornerRadius = UDim.new(0, 12)

-- Helper text
local helperText = Instance.new("TextLabel", moneyGiverFrame)
helperText.Size = UDim2.new(1, -60, 0, 15)
helperText.Position = UDim2.fromOffset(30, 150) 
helperText.BackgroundTransparency = 1
helperText.Text = "Supports: 1.5M, 1B, 1,325,000, 1k"
helperText.Font = Enum.Font.Gotham
helperText.TextSize = 11
helperText.TextColor3 = Color3.fromRGB(150, 150, 160)
helperText.TextTransparency = 1

-- Shortcut Container
local shortcutFrame = Instance.new("Frame", moneyGiverFrame)
shortcutFrame.Size = UDim2.new(1, -60, 0, 40)
shortcutFrame.Position = UDim2.fromOffset(30, 180) 
shortcutFrame.BackgroundTransparency = 1

local prevPresetBtn = Instance.new("TextButton", shortcutFrame)
prevPresetBtn.Size = UDim2.fromOffset(40, 40)
prevPresetBtn.Position = UDim2.fromScale(0, 0)
prevPresetBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
prevPresetBtn.Text = "<"
prevPresetBtn.Font = Enum.Font.GothamBold
prevPresetBtn.TextSize = 18
prevPresetBtn.TextColor3 = TEXT_PRIMARY
prevPresetBtn.BackgroundTransparency = 1
prevPresetBtn.TextTransparency = 1
Instance.new("UICorner", prevPresetBtn).CornerRadius = UDim.new(0, 10)

local nextPresetBtn = Instance.new("TextButton", shortcutFrame)
nextPresetBtn.Size = UDim2.fromOffset(40, 40)
nextPresetBtn.Position = UDim2.fromScale(1, 0)
nextPresetBtn.AnchorPoint = Vector2.new(1, 0)
nextPresetBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
nextPresetBtn.Text = ">"
nextPresetBtn.Font = Enum.Font.GothamBold
nextPresetBtn.TextSize = 18
nextPresetBtn.TextColor3 = TEXT_PRIMARY
nextPresetBtn.BackgroundTransparency = 1
nextPresetBtn.TextTransparency = 1
Instance.new("UICorner", nextPresetBtn).CornerRadius = UDim.new(0, 10)

local presetLabel = Instance.new("TextLabel", shortcutFrame)
presetLabel.Size = UDim2.new(1, -100, 1, 0)
presetLabel.Position = UDim2.fromScale(0.5, 0)
presetLabel.AnchorPoint = Vector2.new(0.5, 0)
presetLabel.BackgroundTransparency = 1
presetLabel.Text = "Preset: 1M"
presetLabel.Font = Enum.Font.GothamMedium
presetLabel.TextSize = 16
presetLabel.TextColor3 = TEXT_SECONDARY
presetLabel.TextTransparency = 1

-- DROP CONTAINER (Card)
local dropCard = Instance.new("Frame", moneyGiverFrame)
dropCard.Size = UDim2.new(1, -40, 0, 70)
dropCard.Position = UDim2.fromOffset(20, 235) 
dropCard.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
dropCard.BackgroundTransparency = 1 
Instance.new("UICorner", dropCard).CornerRadius = UDim.new(0, 15)

-- Drop Button (INITIALIZED VISIBLE YELLOW)
local dropBtn = Instance.new("TextButton", dropCard)
dropBtn.Size = UDim2.new(1, -20, 0, 40)
dropBtn.Position = UDim2.fromOffset(10, 10)
dropBtn.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
dropBtn.Text = "DROP"
dropBtn.Font = Enum.Font.GothamBold
dropBtn.TextSize = 18
dropBtn.TextColor3 = Color3.fromRGB(25, 25, 35)
dropBtn.BorderSizePixel = 0
dropBtn.BackgroundTransparency = 0 
dropBtn.TextTransparency = 1
local dropBtnCorner = Instance.new("UICorner", dropBtn)
dropBtnCorner.CornerRadius = UDim.new(0, 12)

-- Progress Bar Container
local dropProgressBg = Instance.new("Frame", dropCard)
dropProgressBg.Size = UDim2.new(1, -20, 0, 6)
dropProgressBg.Position = UDim2.fromOffset(10, 58)
dropProgressBg.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
dropProgressBg.BorderSizePixel = 0
dropProgressBg.BackgroundTransparency = 1
Instance.new("UICorner", dropProgressBg).CornerRadius = UDim.new(1, 0)

-- Progress Bar Fill
local dropProgressFill = Instance.new("Frame", dropProgressBg)
dropProgressFill.Size = UDim2.fromScale(0, 1)
dropProgressFill.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
dropProgressFill.BorderSizePixel = 0
dropProgressFill.BackgroundTransparency = 1
Instance.new("UICorner", dropProgressFill).CornerRadius = UDim.new(1, 0)

-- Warning label
local warningLabel = Instance.new("TextLabel", autoFishFrame)
warningLabel.Size = UDim2.new(1, -60, 0, 35)
warningLabel.Position = UDim2.fromOffset(30, 380)
warningLabel.BackgroundColor3 = Color3.fromRGB(40, 30, 30)
warningLabel.BackgroundTransparency = 1
warningLabel.TextColor3 = Color3.fromRGB(255, 150, 150)
warningLabel.Font = Enum.Font.GothamBold
warningLabel.TextSize = 13
warningLabel.TextWrapped = true
warningLabel.TextYAlignment = Enum.TextYAlignment.Center
warningLabel.TextTransparency = 1
warningLabel.Text = ""
warningLabel.Visible = false
warningLabel.ZIndex = 10
Instance.new("UICorner", warningLabel).CornerRadius = UDim.new(0, 8)

local function showWarning(text)
    warningLabel.Text = text
    warningLabel.Visible = true
    warningLabel.TextTransparency = 1
    warningLabel.BackgroundTransparency = 1
    TweenService:Create(warningLabel, TweenInfo.new(0.25), {TextTransparency = 0, BackgroundTransparency = 0.3}):Play()
    task.delay(2.5, function()
        TweenService:Create(warningLabel, TweenInfo.new(0.25), {TextTransparency = 1, BackgroundTransparency = 1}):Play()
        task.wait(0.25)
        warningLabel.Visible = false
    end)
end

-- Misc notification label
local miscNotifLabel = Instance.new("TextLabel", miscFrame)
miscNotifLabel.Size = UDim2.new(1, -60, 0, 60)
miscNotifLabel.Position = UDim2.fromOffset(30, 210)
miscNotifLabel.BackgroundColor3 = Color3.fromRGB(30, 40, 50)
miscNotifLabel.BackgroundTransparency = 1
miscNotifLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
miscNotifLabel.Font = Enum.Font.GothamBold
miscNotifLabel.TextSize = 13
miscNotifLabel.TextWrapped = true
miscNotifLabel.TextYAlignment = Enum.TextYAlignment.Center
miscNotifLabel.TextTransparency = 1
miscNotifLabel.Text = ""
miscNotifLabel.Visible = false
miscNotifLabel.ZIndex = 10
Instance.new("UICorner", miscNotifLabel).CornerRadius = UDim.new(0, 8)

local function showMiscNotif(text)
    miscNotifLabel.Parent = (currentPanel == "moneyGiver" and moneyGiverFrame) or miscFrame
    miscNotifLabel.Position = (currentPanel == "moneyGiver" and UDim2.fromOffset(30, 280)) or UDim2.fromOffset(30, 210)
    miscNotifLabel.Text = text
    miscNotifLabel.Visible = true
    miscNotifLabel.TextTransparency = 1
    miscNotifLabel.BackgroundTransparency = 1
    TweenService:Create(miscNotifLabel, TweenInfo.new(0.25), {TextTransparency = 0, BackgroundTransparency = 0.3}):Play()
    task.delay(3, function()
        TweenService:Create(miscNotifLabel, TweenInfo.new(0.25), {TextTransparency = 1, BackgroundTransparency = 1}):Play()
        task.wait(0.25)
        miscNotifLabel.Visible = false
    end)
end

-- =========================
-- MONEY GIVER LOGIC
-- =========================
local MoneyPresets = {"1M", "5M", "10M", "50M", "100M", "500M", "1B", "5B", "10B"}
local currentPresetIndex = 1
local isDroppingMoney = false
local DENOMS = {100000, 50000, 20000, 10000, 5000, 2000}

local function updateShortcutLabelOnly()
    presetLabel.Text = "Preset: " .. MoneyPresets[currentPresetIndex]
end

local function applyPresetToInput()
    moneyInput.Text = MoneyPresets[currentPresetIndex]
end

-- Robust parser
local function robustParse(str)
    if not str then return nil end
    local clean = str:gsub("%s+", ""):gsub(",", "")
    -- Check for suffix
    local numStr, suffix = clean:match("^([%d%.]+)([%a]*)$")
    if not numStr then return nil end
    
    local val = tonumber(numStr)
    local dotCount = 0
    for _ in numStr:gmatch("%.") do dotCount = dotCount + 1 end
    
    if dotCount > 1 then
        numStr = numStr:gsub("%.", "")
        val = tonumber(numStr)
    end
    
    if not val then return nil end
    
    if suffix and suffix ~= "" then
        local s = suffix:lower()
        if s == "k" then val = val * 1000
        elseif s == "m" then val = val * 1000000
        elseif s == "b" then val = val * 1000000000 end
    end
    
    return math.floor(val)
end

prevPresetBtn.MouseButton1Click:Connect(function()
    currentPresetIndex = currentPresetIndex - 1
    if currentPresetIndex < 1 then currentPresetIndex = #MoneyPresets end
    updateShortcutLabelOnly()
    applyPresetToInput()
end)

nextPresetBtn.MouseButton1Click:Connect(function()
    currentPresetIndex = currentPresetIndex + 1
    if currentPresetIndex > #MoneyPresets then currentPresetIndex = 1 end
    updateShortcutLabelOnly()
    applyPresetToInput()
end)

local function clickOnce()
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 1)
    task.wait(0.02)
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 1)
end

dropBtn.MouseButton1Click:Connect(function()
    if isDroppingMoney then return end
    local amount = robustParse(moneyInput.Text)
    if not amount or amount < 2000 then
        showMiscNotif("Invalid Amount! Min: 2000")
        return
    end
    
    isDroppingMoney = true
    dropBtn.BackgroundTransparency = 0.5
    dropBtn.Text = "DROPPING..."
    dropProgressBg.BackgroundTransparency = 0
    dropProgressFill.BackgroundTransparency = 0
    dropProgressFill.Size = UDim2.fromScale(0, 1)
    
    task.spawn(function()
        local success, err = pcall(function()
            local char = getChar()
            local backpack = player:WaitForChild("Backpack")
            local tool = char:FindFirstChild("Money") or backpack:FindFirstChild("Money")
            
            if not tool then
                error("Money tool not found in Backpack or Character")
            end
            
            if tool.Parent ~= char then
                char.Humanoid:EquipTool(tool)
                tool = char:WaitForChild("Money", 2) 
            end
            
            if not tool then error("Failed to equip Money tool") end
            
            local remote = tool:FindFirstChildWhichIsA("RemoteFunction", true)
            if not remote then error("RemoteFunction not found in Money tool") end
            
            -- Pre-calculate total drops
            local totalDrops = 0
            local tempAmount = amount
            for _, d in ipairs(DENOMS) do
                local c = math.floor(tempAmount / d)
                if c > 0 then
                    totalDrops = totalDrops + c
                    tempAmount = tempAmount - (c * d)
                end
            end
            
            local currentDrop = 0
            local remaining = amount
            for _, d in ipairs(DENOMS) do
                local count = math.floor(remaining / d)
                if count > 0 then
                    for i = 1, count do
                        if not running then break end
                        remote:InvokeServer(d)
                        task.wait(0.1) 
                        clickOnce()
                        task.wait(0.1)
                        
                        currentDrop = currentDrop + 1
                        local pct = math.clamp(currentDrop / totalDrops, 0, 1)
                        TweenService:Create(dropProgressFill, TweenInfo.new(0.1), {Size = UDim2.fromScale(pct, 1)}):Play()
                    end
                    remaining = remaining - (count * d)
                end
            end
            showMiscNotif("Drop Complete!")
        end)
        
        if not success then showMiscNotif(tostring(err)) end
        
        isDroppingMoney = false
        dropBtn.BackgroundTransparency = 0
        dropBtn.Text = "DROP"
        task.wait(1)
        dropProgressBg.BackgroundTransparency = 1
        dropProgressFill.BackgroundTransparency = 1
    end)
end)

updateShortcutLabelOnly()

-- =========================
-- FADE IN SELECTOR
-- =========================
task.spawn(function()
    pcall(function()
        task.wait(0.3)
        TweenService:Create(selectorFrame, TweenInfo.new(0.6), {BackgroundTransparency = 0.15}):Play()
        TweenService:Create(selectorStroke, TweenInfo.new(0.6), {Transparency = 0.5}):Play()
        TweenService:Create(selectorHeader, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
        
        for _, child in ipairs(selectorButtonsContainer:GetChildren()) do
            if child:IsA("TextButton") then
                -- TweenService:Create(child, TweenInfo.new(0.5), {BackgroundTransparency = 0}):Play() -- REMOVED: Keep transparent
                for _, desc in ipairs(child:GetDescendants()) do
                    if desc:IsA("TextLabel") then 
                         -- Only fade in text if it's meant to be visible (arrow might be hidden)
                         if desc.Text ~= "→" or (desc.Text == "→" and desc.TextTransparency < 1) then
                             TweenService:Create(desc, TweenInfo.new(0.5), {TextTransparency = (desc.Text == "→" and 0 or 1)}):Play()
                             -- Actually, let's just fade in the MAIN text. The arrow state is handled by showPanel defaults.
                         end
                         -- Simpler: Just set main text to visible. Arrow stays hidden by default from creation.
                         if desc.Name ~= "Arrow" then -- We didn't name them, but we can check properties or text
                            if desc.Text ~= "→" then 
                                TweenService:Create(desc, TweenInfo.new(0.5), {TextTransparency = (desc.TextColor3 == TEXT_PRIMARY or desc.TextColor3 == JPUFF_HOT_PINK) and 0 or 0}):Play() 
                                -- Wait, mainText starts with transparency 1. We should fade it to 0.
                                TweenService:Create(desc, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
                            end
                         end
                    end
                end
            end
        end
    end)
end)

-- =========================
-- PANEL SWITCHING LOGIC
-- =========================
-- currentPanel is defined at top of file

local function hidePanel(panelFrame, panelName)
    if currentPanel ~= panelName then return end
    TweenService:Create(panelFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.fromOffset(0, 0), Position = UDim2.fromOffset(selectorFrame.AbsolutePosition.X + selectorFrame.AbsoluteSize.X / 2, selectorFrame.AbsolutePosition.Y + 80)}):Play()
    task.wait(0.4)
    panelFrame.Visible = false
    currentPanel = nil
end

local function showPanel(panelFrame, panelName, targetSize, buttonY)
    -- Map for animations
    local targetArrow, targetText, targetColor
    if panelName == "autoFish" then targetArrow = autoFishArrow; targetText = autoFishText; targetColor = JPUFF_HOT_PINK
    elseif panelName == "moneyGiver" then targetArrow = moneyGiverArrow; targetText = moneyGiverText; targetColor = Color3.fromRGB(255, 215, 0)
    elseif panelName == "misc" then targetArrow = miscArrow; targetText = miscText; targetColor = Color3.fromRGB(120, 180, 255)
    end

    if currentPanel and currentPanel ~= panelName then
        local oldFrame, oldArrow, oldText
        if currentPanel == "autoFish" then oldFrame = autoFishFrame; oldArrow = autoFishArrow; oldText = autoFishText
        elseif currentPanel == "moneyGiver" then oldFrame = moneyGiverFrame; oldArrow = moneyGiverArrow; oldText = moneyGiverText
        elseif currentPanel == "misc" then oldFrame = miscFrame; oldArrow = miscArrow; oldText = miscText
        end
        
        -- Animate OLD OUT
        if oldFrame then
             hidePanel(oldFrame, currentPanel)
        end
        if oldArrow then
             TweenService:Create(oldArrow, TweenInfo.new(0.3), {TextTransparency = 1, Position = UDim2.fromOffset(10, 0)}):Play()
        end
        if oldText then
             TweenService:Create(oldText, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(150, 150, 160), Position = UDim2.fromOffset(15, 0)}):Play()
        end
        
        task.wait(0.4)
    end
    
    if currentPanel == panelName then
        hidePanel(panelFrame, panelName)
        -- Toggle OFF animation
        if targetArrow then TweenService:Create(targetArrow, TweenInfo.new(0.3), {TextTransparency = 1, Position = UDim2.fromOffset(10, 0)}):Play() end
        if targetText then TweenService:Create(targetText, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(150, 150, 160), Position = UDim2.fromOffset(15, 0)}):Play() end
    else
        currentPanel = panelName
        panelFrame.Visible = true
        panelFrame.Size = UDim2.fromOffset(0, 0)
        panelFrame.Position = UDim2.fromOffset(selectorFrame.AbsolutePosition.X + selectorFrame.AbsoluteSize.X / 2, selectorFrame.AbsolutePosition.Y + buttonY)
        
        -- Animate NEW IN
        -- Text moves FIRST to clear path
        if targetText then 
            TweenService:Create(targetText, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = targetColor, Position = UDim2.fromOffset(45, 0)}):Play() 
        end 

        -- Arrow appears slightly AFTER text moves
        if targetArrow then 
            task.delay(0.12, function()
                if currentPanel == panelName then -- Ensure still active
                    TweenService:Create(targetArrow, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {TextTransparency = 0, Position = UDim2.fromOffset(15, 0)}):Play() 
                end
            end)
        end

        TweenService:Create(panelFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = targetSize, Position = UDim2.fromOffset(selectorFrame.AbsolutePosition.X + selectorFrame.AbsoluteSize.X + 20, selectorFrame.AbsolutePosition.Y)}):Play()
        TweenService:Create(panelFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.15}):Play()
        
        local panelStroke = panelFrame:FindFirstChildOfClass("UIStroke")
        if panelStroke then TweenService:Create(panelStroke, TweenInfo.new(0.6), {Transparency = 0.5}):Play() end
        
        for _, child in ipairs(panelFrame:GetDescendants()) do
            if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
                TweenService:Create(child, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
            end
            if child:IsA("Frame") and child.Parent ~= screenGui then
                -- FIX: Explicitly handle DROP BUTTON background to ensure it stays yellow (0)
                local goalBg = 0
                if child == moneyInput or child == dropCard then goalBg = 0.2
                elseif child == dropBtn then goalBg = 0 
                elseif child == dropProgressBg or child == dropProgressFill then goalBg = 1
                end
                
                TweenService:Create(child, TweenInfo.new(0.5), {BackgroundTransparency = goalBg}):Play()
            end
            if child:IsA("ImageLabel") then
                TweenService:Create(child, TweenInfo.new(0.5), {ImageTransparency = 0}):Play()
            end
        end
    end
end

autoFishBtn.MouseButton1Click:Connect(function() showPanel(autoFishFrame, "autoFish", UDim2.fromOffset(340, 530), 60) end)
moneyGiverBtn.MouseButton1Click:Connect(function() showPanel(moneyGiverFrame, "moneyGiver", UDim2.fromOffset(340, 325), 115) end) -- Height Updated
miscBtn.MouseButton1Click:Connect(function() showPanel(miscFrame, "misc", UDim2.fromOffset(340, 280), 170) end)

-- =========================
-- DRAGGABLE SYNC
-- =========================
local dragging = false
local dragStart = nil
local startPos = nil

selectorFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = selectorFrame.Position
    end
end)

selectorFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        selectorFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        if currentPanel then
            local target = (currentPanel == "autoFish" and autoFishFrame) or (currentPanel == "moneyGiver" and moneyGiverFrame) or miscFrame
            target.Position = UDim2.fromOffset(selectorFrame.AbsolutePosition.X + selectorFrame.AbsoluteSize.X + 20, selectorFrame.AbsolutePosition.Y)
        end
    end
end)

-- =========================
-- BUTTON LOGIC & MISC
-- =========================
sellBtn.MouseButton1Click:Connect(function()
    local rs = game:GetService("ReplicatedStorage")
    local remotes = rs:WaitForChild("GameRemoteFunctions", 3)
    if remotes then
        local sellFunc = remotes:WaitForChild("SellAllFishFunction", 3)
        if sellFunc then pcall(function() sellFunc:InvokeServer() end) end
    end
end)

-- Tap Game Toggle
tapBtn.MouseButton1Click:Connect(function()
    tapEnabled = tapToggleFn()
    DefaultConfig.tapEnabled = tapEnabled
    saveConfig()
end)

-- Bar Game Toggle
barBtn.MouseButton1Click:Connect(function()
    barEnabled = barToggleFn()
    DefaultConfig.barEnabled = barEnabled
    saveConfig()
end)

-- Auto Cast Toggle
castBtn.MouseButton1Click:Connect(function()
    castEnabled = castToggleFn()
    DefaultConfig.castEnabled = castEnabled
    if not castEnabled then
        hasEnteredFishing = false
    end
    saveConfig()
end)

-- Fish Location Toggle
fishBtn.MouseButton1Click:Connect(function()
    if freezeEnabled then
        showWarning("⚠ Disable Freeze first!")
        return
    end
    
    fishLocEnabled = fishToggleFn()
    DefaultConfig.fishLocEnabled = fishLocEnabled
    saveConfig()
    
    local root = getChar():WaitForChild("HumanoidRootPart")
    if fishLocEnabled then
        savedCFrame = root.CFrame
        root.CFrame = CFrame.new(-2502.88, -13.00, -561.81) * CFrame.Angles(0, math.rad(-87.95), 0)
    else
        if savedCFrame then
            root.CFrame = savedCFrame
        end
    end
end)

-- Freeze Toggle
freezeBtn.MouseButton1Click:Connect(function()
    freezeEnabled = freezeToggleFn()
    DefaultConfig.freezeEnabled = freezeEnabled
    setAnchored(freezeEnabled)
    saveConfig()
end)

-- Equip Best Rod Toggle
equipBtn.MouseButton1Click:Connect(function()
    if not castEnabled and not equipGetState() then
        showWarning("⚠ AutoCast must be ON first!")
        return
    end
    AutoEquipBestRod = equipToggleFn()
    DefaultConfig.AutoEquipBestRod = AutoEquipBestRod
    saveConfig()
end)

-- Auto Rejoin Toggle
rejoinBtn.MouseButton1Click:Connect(function()
    DefaultConfig.autoRejoinEnabled = rejoinToggleFn()
    saveConfig()
end)

-- Boost FPS Toggle Logic (FIXED BUG)
boostFpsBtn.MouseButton1Click:Connect(function()
    local isOn = boostFpsToggleFn() 
    if not isOn then return end 
    showMiscNotif("🚀 Boosting FPS...\nPlease wait...")
    task.spawn(function()
        pcall(function()
            local Lighting = game:GetService("Lighting")
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            Lighting.ShadowSoftness = 0
            if sethiddenproperty then sethiddenproperty(Lighting, "Technology", 2) end
            local t = workspace:FindFirstChildOfClass("Terrain")
            if t then
                t.WaterWaveSize = 0
                t.WaterWaveSpeed = 0
                t.WaterReflectance = 0
                t.WaterTransparency = 0
                if sethiddenproperty then sethiddenproperty(t, "Decoration", false) end
            end
            if setfpscap then setfpscap(1e6) end
            for _, v in pairs(game:GetDescendants()) do
                if v:IsA("BasePart") and not v:IsA("MeshPart") then
                    v.Material = Enum.Material.Plastic
                    v.Reflectance = 0
                elseif v:IsA("MeshPart") then
                    v.Material = Enum.Material.Plastic
                    v.Reflectance = 0
                    v.RenderFidelity = Enum.RenderFidelity.Performance
                elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                    v.Lifetime = NumberRange.new(0)
                elseif v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
                    v.Enabled = false
                end
            end
        end)
        showMiscNotif("✅ FPS Boost Applied!")
        if boostFpsGetState() then boostFpsToggleFn() end
    end)
end)

memoryBtn.MouseButton1Click:Connect(function()
    reduceMemoryEnabled = memoryToggleFn()
    DefaultConfig.reduceMemoryEnabled = reduceMemoryEnabled
    saveConfig()
    pcall(function() game:GetService("RunService"):Set3dRenderingEnabled(not reduceMemoryEnabled) end)
    showMiscNotif(reduceMemoryEnabled and "🧠 3D Rendering Disabled" or "🧠 3D Rendering Enabled")
end)

-- =========================
-- CONFIRMATION POPUP
-- =========================
local confirmationGui = Instance.new("ScreenGui", gui)
confirmationGui.Name = "ConfirmationPopup"
confirmationGui.ResetOnSpawn = false
confirmationGui.IgnoreGuiInset = true
confirmationGui.DisplayOrder = 1000
confirmationGui.Enabled = false

local confirmBlur = Instance.new("BlurEffect", game:GetService("Lighting"))
confirmBlur.Size = 0
confirmBlur.Name = "ConfirmationBlur"

local confirmOverlay = Instance.new("Frame", confirmationGui)
confirmOverlay.Size = UDim2.fromScale(1, 1)
confirmOverlay.BackgroundColor3 = Color3.fromRGB(0,0,0)
confirmOverlay.BackgroundTransparency = 1

local confirmDialog = Instance.new("Frame", confirmOverlay)
confirmDialog.Size = UDim2.fromOffset(420, 240)
confirmDialog.Position = UDim2.fromScale(0.5, 0.5)
confirmDialog.AnchorPoint = Vector2.new(0.5, 0.5)
confirmDialog.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
confirmDialog.BackgroundTransparency = 1
Instance.new("UICorner", confirmDialog).CornerRadius = UDim.new(0, 20)
local confirmStroke = Instance.new("UIStroke", confirmDialog)
confirmStroke.Color = JPUFF_HOT_PINK
confirmStroke.Thickness = 2
confirmStroke.Transparency = 1

local confirmTitle = Instance.new("TextLabel", confirmDialog)
confirmTitle.Size = UDim2.new(1, -40, 0, 45)
confirmTitle.Position = UDim2.fromOffset(20, 20)
confirmTitle.BackgroundTransparency = 1
confirmTitle.Text = "⚠️ WARNING"
confirmTitle.Font = Enum.Font.GothamBold
confirmTitle.TextSize = 24
confirmTitle.TextColor3 = JPUFF_HOT_PINK
confirmTitle.TextXAlignment = Enum.TextXAlignment.Left
confirmTitle.TextTransparency = 1

local confirmMessage = Instance.new("TextLabel", confirmDialog)
confirmMessage.Size = UDim2.new(1, -40, 0, 90)
confirmMessage.Position = UDim2.fromOffset(20, 75)
confirmMessage.BackgroundTransparency = 1
confirmMessage.Text = "Are you sure you wanna close the gui, this will completely remove the script."
confirmMessage.Font = Enum.Font.GothamMedium
confirmMessage.TextSize = 16
confirmMessage.TextColor3 = Color3.fromRGB(255, 255, 255)
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
cancelBtn.Text = "Cancel"
cancelBtn.Font = Enum.Font.GothamBold
cancelBtn.TextSize = 17
cancelBtn.TextColor3 = TEXT_PRIMARY
cancelBtn.BackgroundTransparency = 1
cancelBtn.TextTransparency = 1
Instance.new("UICorner", cancelBtn).CornerRadius = UDim.new(0, 12)

local sureBtn = Instance.new("TextButton", buttonContainer)
sureBtn.Size = UDim2.new(0.48, 0, 1, 0)
sureBtn.Position = UDim2.fromScale(0.52, 0)
sureBtn.BackgroundColor3 = Color3.fromRGB(220, 80, 100)
sureBtn.Text = "I'm sure"
sureBtn.Font = Enum.Font.GothamBold
sureBtn.TextSize = 17
sureBtn.TextColor3 = TEXT_PRIMARY
sureBtn.BackgroundTransparency = 1
sureBtn.TextTransparency = 1
Instance.new("UICorner", sureBtn).CornerRadius = UDim.new(0, 12)

for _, child in ipairs(confirmDialog:GetDescendants()) do
    if child:IsA("Frame") and child ~= buttonContainer and child ~= confirmDialog then child:Destroy() end
end

local function showConfirmation()
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

local function hideConfirmation()
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

cancelBtn.MouseButton1Click:Connect(hideConfirmation)
sureBtn.MouseButton1Click:Connect(function()
    running = false
    hideConfirmation()
    task.wait(0.3)
    if screenGui then screenGui:Destroy() end
    if confirmationGui then confirmationGui:Destroy() end
    if loadingGui then loadingGui:Destroy() end
    if confirmBlur then confirmBlur:Destroy() end
end)
closeSelectorBtn.MouseButton1Click:Connect(showConfirmation)

do
	-- =========================
	-- TAP GAME (NO DELAY) - PORTED
	-- =========================
	task.spawn(function()
		while running do
			if tapEnabled then
				local ui = gui:FindFirstChild("FishingUI")
				local pre = ui and ui:FindFirstChild("PreFishingHolder")
				if pre and pre.Visible then
					for _, btn in ipairs(pre:GetDescendants()) do
						if btn:IsA("ImageButton")
						and btn.Name == "TapButton"
						and btn.Visible
						and btn.Active then
							pcall(function()
								firesignal(btn.Activated)
							end)
						end
					end
				end
			end
			task.wait(0.05)
		end
	end)

	-- =========================
	-- BAR GAME (HUMANIZED) - PORTED
	-- =========================
	task.spawn(function()
		while running do
			if barEnabled then
				local ui = gui:FindFirstChild("FishingUI")
				local holder = ui and ui:FindFirstChild("FishingHolder")
				if holder and holder.Visible then
					local bar = holder:FindFirstChild("BarContainer", true)
					local fill = bar and bar:FindFirstChild("Bar", true)
					if fill then
						local c = fill.BackgroundColor3
						if c.G * 255 > GREEN_THRESHOLD and c.G > c.R then
							humanDelay()
							clickGui(fill)
						end
					end
				end
			end
			RunService.RenderStepped:Wait()
		end
	end)

	-- =========================
	-- FISHING ANIMATION LOCK - PORTED
	-- =========================

	local FISHING_ANIMATIONS = {
		["rbxassetid://89023128565837"]  = true, -- Cast
		["rbxassetid://107858786510758"] = true, -- Fishing (waiting)
		["rbxassetid://136444937709795"] = true, -- Fish caught / pulling
	}

	local function isFishingAnimationPlaying()
		local char = getChar()
		local humanoid = char:FindFirstChildOfClass("Humanoid")
		if not humanoid then return false end

		local animator = humanoid:FindFirstChildOfClass("Animator")
		if not animator then return false end

		for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
			local anim = track.Animation
			if anim then
				local id = anim.AnimationId
				-- block ALL fishing states
				if FISHING_ANIMATIONS[id] then
					return true
				end
			end
		end

		return false
	end


	-- =========================
	-- AUTO CAST - PORTED
	-- =========================

	local function getEquippedRod()
		local char = getChar()
		for _, tool in ipairs(char:GetChildren()) do
			if tool:IsA("Tool")
				and tool:FindFirstChild("Cast")
				and tool:FindFirstChild("ToolReady") then
				return tool
			end
		end
		return nil
	end


	local function CastOnce()
		if not castEnabled or casting then return end

		-- auto-loop lock (but allow post-fish recast)
		if hasEnteredFishing and not allowRecastAfterFish then
			return
		end

		casting = true

		-- WAIT for fishing animations to fully stop
		local timeoutAnim = tick() + 2
		while isFishingAnimationPlaying() and tick() < timeoutAnim do
			task.wait()
		end

		local char = getChar()
		local humanoid = char:WaitForChild("Humanoid")

		local tool = getEquippedRod()
		if not tool then
			hasEnteredFishing = false
			allowRecastAfterFish = false
			casting = false
			return
		end

		local cast = tool:WaitForChild("Cast")
		local toolReady = tool:WaitForChild("ToolReady")

		local token
		local conn
		conn = toolReady.OnClientEvent:Connect(function(t)
			token = t
		end)

		-- controlled re-equip (single time)
		humanoid:UnequipTools()
		task.wait(0.15)
		humanoid:EquipTool(tool)

		-- wait for server token
		local timeout = tick() + 5
		while not token and tick() < timeout do
			task.wait()
		end

		if token then
			humanDelay()
			cast:InvokeServer(math.random(30,190) / 100, token)

			-- consume post-fish permission
			allowRecastAfterFish = false
		end

		if conn then
			conn:Disconnect()
		end

		casting = false
	end

	-- auto loop
	task.spawn(function()
		while running do
			if castEnabled
			and not casting
			and not hasEnteredFishing
			and not isFishingAnimationPlaying()
			then
				local ui = gui:FindFirstChild("FishingUI")
				local holder = ui and ui:FindFirstChild("FishingHolder")

				if not (holder and holder.Visible) then

					-- equip best BEFORE checking tool
					if AutoEquipBestRod and castEnabled then
						for i = #RodPriority, 1, -1 do
							local rodName = RodPriority[i]
							if playerOwnsRod(rodName) then
								equipRod(rodName)
								break
							end
						end
					end

					local tool = getEquippedRod()
					if tool then
						CastOnce()
					end
				end
			end

			task.wait(0.4)
		end
	end)


	-- =========================
	-- SUCCESS DETECTION - PORTED
	-- =========================
	task.spawn(function()
		local wasFishing = false
		while running do
			local ui = gui:FindFirstChild("FishingUI")
			local holder = ui and ui:FindFirstChild("FishingHolder")

			if holder then
				if holder.Visible then
					wasFishing = true
					hasEnteredFishing = true
				elseif wasFishing then
					wasFishing = false
					allowRecastAfterFish = true
					humanDelay()
					CastOnce()
				end
			end

			task.wait(0.1)
		end
	end)
end

local guiVisible = true
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.RightShift then
        guiVisible = not guiVisible
        if guiVisible then
            screenGui.Enabled = true
            TweenService:Create(selectorFrame, TweenInfo.new(0.3), {BackgroundTransparency = 0.15}):Play()
            if currentPanel then 
                local t = (currentPanel=="autoFish" and autoFishFrame) or (currentPanel=="moneyGiver" and moneyGiverFrame) or miscFrame
                t.Visible = true; TweenService:Create(t, TweenInfo.new(0.3), {BackgroundTransparency = 0.15}):Play()
            end
        else
            TweenService:Create(selectorFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            if currentPanel then
                local t = (currentPanel=="autoFish" and autoFishFrame) or (currentPanel=="moneyGiver" and moneyGiverFrame) or miscFrame
                TweenService:Create(t, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            end
            task.wait(0.3)
            screenGui.Enabled = false
        end
    end
end)    