-- =====================================================
-- JPUFF UI LIBRARY - QUICK REFERENCE
-- ⚠️ THIS IS A REFERENCE GUIDE, NOT A RUNNABLE SCRIPT!
-- Copy and paste individual snippets as needed.
-- To see a working example, run UILIB_DEMO.lua or UILIB_EXAMPLE.lua
-- =====================================================

-- =====================================================
-- 1. BASIC SETUP (COPY THIS TO START)
-- =====================================================
local UILib = loadstring(game:HttpGet("https://raw.githubusercontent.com/onelkenzo/tesst/main/UILIB.lua"))()

local window = UILib:CreateWindow({Title = "My Script"})
UILib:AddMethods(window)

local panel = window:CreatePanel({
    Name = "main",
    DisplayName = "Main",
    Color = UILib.Colors.JPUFF_HOT_PINK
})

window:AddToggleKey(Enum.KeyCode.RightShift)

-- =====================================================
-- 2. LOADING SCREEN
-- =====================================================
local loading = UILib:CreateLoadingScreen({
    Title = "My Script",
    Duration = 2.5
})
task.wait(3)

-- =====================================================
-- 3. TOGGLE
-- =====================================================
local myToggle = UILib:CreateToggle(panel, {
    Label = "Feature Name",
    Default = false,
    Callback = function(state)
        print("State:", state)
        -- Your code here
    end
})

-- Get state: myToggle.GetState()
-- Set state: myToggle.SetState(true)

-- =====================================================
-- 4. BUTTON
-- =====================================================
UILib:CreateButton(panel, {
    Text = "Button Text",
    Color = UILib.Colors.SUCCESS,
    Callback = function()
        print("Clicked!")
        -- Your code here
    end
})

-- =====================================================
-- 5. TEXT INPUT
-- =====================================================
local input = UILib:CreateTextInput(panel, {
    Placeholder = "Enter text..."
})

-- Get text: input.Text

-- =====================================================
-- 6. NOTIFICATION
-- =====================================================
UILib:CreateNotification({
    Text = "✅ Success!",
    Duration = 3,
    Color = UILib.Colors.SUCCESS
})

-- =====================================================
-- 7. CONFIRMATION DIALOG
-- =====================================================
UILib:CreateConfirmation({
    Title = "⚠️ WARNING",
    Message = "Are you sure?",
    OnConfirm = function()
        print("Confirmed!")
    end,
    OnCancel = function()
        print("Cancelled!")
    end
})

-- =====================================================
-- 8. MULTIPLE PANELS
-- =====================================================
local panel1 = window:CreatePanel({
    Name = "main",
    DisplayName = "Main",
    Color = UILib.Colors.JPUFF_HOT_PINK,
    LayoutOrder = 1
})

local panel2 = window:CreatePanel({
    Name = "settings",
    DisplayName = "Settings",
    Color = UILib.Colors.WARNING,
    LayoutOrder = 2
})

-- =====================================================
-- 9. COLORS
-- =====================================================
-- UILib.Colors.JPUFF_PINK       -- Light pink
-- UILib.Colors.JPUFF_HOT_PINK   -- Hot pink
-- UILib.Colors.SUCCESS          -- Green
-- UILib.Colors.WARNING          -- Yellow
-- UILib.Colors.ERROR            -- Red

-- Custom: Color3.fromRGB(R, G, B)

-- =====================================================
-- 10. COMPLETE TEMPLATE
-- =====================================================
--[[
local UILib = loadstring(game:HttpGet("https://raw.githubusercontent.com/onelkenzo/tesst/main/UILIB.lua"))()

-- Loading screen
local loading = UILib:CreateLoadingScreen({
    Title = "My Script",
    Duration = 2
})
task.wait(2.5)

-- Create window
local window = UILib:CreateWindow({Title = "My Script"})
UILib:AddMethods(window)

-- Create panel
local mainPanel = window:CreatePanel({
    Name = "main",
    DisplayName = "Main",
    Color = UILib.Colors.JPUFF_HOT_PINK
})

-- Add toggle
local autoFarm = UILib:CreateToggle(mainPanel, {
    Label = "Auto Farm",
    Default = false,
    Callback = function(state)
        print("Auto Farm:", state)
    end
})

-- Add button
UILib:CreateButton(mainPanel, {
    Text = "Teleport",
    Color = UILib.Colors.SUCCESS,
    Callback = function()
        UILib:CreateNotification({
            Text = "✅ Teleported!",
            Color = UILib.Colors.SUCCESS
        })
    end
})

-- Add input
local playerInput = UILib:CreateTextInput(mainPanel, {
    Placeholder = "Player name..."
})

-- Add toggle key
window:AddToggleKey(Enum.KeyCode.RightShift)

-- Auto farm loop
task.spawn(function()
    while task.wait(1) do
        if autoFarm.GetState() then
            print("Farming...")
        end
    end
end)

-- Success notification
UILib:CreateNotification({
    Text = "✅ Script loaded!",
    Duration = 3,
    Color = UILib.Colors.SUCCESS
})
]]

-- =====================================================
-- 11. COMMON PATTERNS
-- =====================================================

-- Pattern 1: Toggle with notification
local speedToggle = UILib:CreateToggle(panel, {
    Label = "Speed Boost",
    Default = false,
    Callback = function(state)
        if state then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 50
            UILib:CreateNotification({
                Text = "✅ Speed enabled!",
                Color = UILib.Colors.SUCCESS
            })
        else
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
            UILib:CreateNotification({
                Text = "⚠️ Speed disabled!",
                Color = UILib.Colors.WARNING
            })
        end
    end
})

-- Pattern 2: Button with input
local playerInput = UILib:CreateTextInput(panel, {
    Placeholder = "Enter player name..."
})

UILib:CreateButton(panel, {
    Text = "Target Player",
    Color = UILib.Colors.WARNING,
    Callback = function()
        if playerInput.Text ~= "" then
            print("Targeting:", playerInput.Text)
            UILib:CreateNotification({
                Text = "🎯 Targeting: " .. playerInput.Text,
                Color = UILib.Colors.SUCCESS
            })
        else
            UILib:CreateNotification({
                Text = "⚠️ Enter a player name!",
                Color = UILib.Colors.ERROR
            })
        end
    end
})

-- Pattern 3: Dangerous action with confirmation
UILib:CreateButton(panel, {
    Text = "⚠️ Reset Character",
    Color = UILib.Colors.ERROR,
    Callback = function()
        UILib:CreateConfirmation({
            Title = "⚠️ WARNING",
            Message = "Reset your character?",
            OnConfirm = function()
                game.Players.LocalPlayer.Character.Humanoid.Health = 0
            end
        })
    end
})

-- Pattern 4: Auto-farm loop with toggle
local farmToggle = UILib:CreateToggle(panel, {
    Label = "Auto Farm",
    Default = false,
    Callback = function(state)
        print("Auto Farm:", state)
    end
})

task.spawn(function()
    while task.wait(1) do
        if farmToggle.GetState() then
            -- Your farming logic here
            print("Farming...")
        end
    end
end)

-- =====================================================
-- 12. TIPS & TRICKS
-- =====================================================

-- Tip 1: Access toggle state anywhere
-- local isEnabled = myToggle.GetState()

-- Tip 2: Set toggle state programmatically
-- myToggle.SetState(true)

-- Tip 3: Show specific panel
-- window:ShowPanel("main")

-- Tip 4: Get current panel
-- print(window.CurrentPanel)

-- Tip 5: Destroy window
-- window:Destroy()

-- Tip 6: Custom colors
-- Color = Color3.fromRGB(100, 200, 255)

-- Tip 7: Different panel sizes
-- Size = UDim2.fromOffset(340, 400)

-- Tip 8: Change toggle key
-- window:AddToggleKey(Enum.KeyCode.LeftControl)

-- =====================================================
-- 13. EMOJI REFERENCE
-- =====================================================
-- ✅ Success/Enabled
-- ⚠️ Warning
-- ❌ Error/Disabled
-- 🚀 Teleport/Speed
-- 🎯 Target
-- 💰 Money
-- 🔧 Settings
-- ⚙️ Config
-- 📊 Stats
-- 🎨 Theme
-- 🔔 Notification
-- 🎮 Game
-- 👤 Player
-- 🌟 Special

print("UI Library Quick Reference Loaded!")
