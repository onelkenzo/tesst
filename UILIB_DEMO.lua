-- =====================================================
-- JPUFF UI LIBRARY - WORKING DEMO
-- This is a runnable version that demonstrates the library
-- =====================================================

-- Load the library from GitHub
local UILib = loadstring(game:HttpGet("https://raw.githubusercontent.com/onelkenzo/tesst/main/UILIB.lua"))()

-- =====================================================
-- CREATE LOADING SCREEN
-- =====================================================
local loading = UILib:CreateLoadingScreen({
    Title = "Demo Script",
    Duration = 2
})

task.wait(2.5)

-- =====================================================
-- CREATE WINDOW
-- =====================================================
local window = UILib:CreateWindow({
    Title = "UI Library Demo"
})
UILib:AddMethods(window)

-- =====================================================
-- CREATE PANELS
-- =====================================================
local mainPanel = window:CreatePanel({
    Name = "main",
    DisplayName = "Main",
    Color = UILib.Colors.JPUFF_HOT_PINK,
    LayoutOrder = 1
})

local settingsPanel = window:CreatePanel({
    Name = "settings",
    DisplayName = "Settings",
    Color = UILib.Colors.WARNING,
    LayoutOrder = 2
})

-- =====================================================
-- ADD TOGGLES TO MAIN PANEL
-- =====================================================
local autoFarmToggle = UILib:CreateToggle(mainPanel, {
    Label = "Auto Farm",
    Default = false,
    Callback = function(state)
        print("Auto Farm:", state)
    end
})

local espToggle = UILib:CreateToggle(mainPanel, {
    Label = "ESP",
    Default = false,
    Callback = function(state)
        print("ESP:", state)
    end
})

-- =====================================================
-- ADD BUTTON TO MAIN PANEL
-- =====================================================
UILib:CreateButton(mainPanel, {
    Text = "🚀 Teleport to Spawn",
    Color = UILib.Colors.SUCCESS,
    Callback = function()
        print("Teleporting!")
        UILib:CreateNotification({
            Text = "✅ Teleported to spawn!",
            Duration = 2,
            Color = UILib.Colors.SUCCESS
        })
    end
})

-- =====================================================
-- ADD TOGGLES TO SETTINGS PANEL
-- =====================================================
local speedToggle = UILib:CreateToggle(settingsPanel, {
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

local jumpToggle = UILib:CreateToggle(settingsPanel, {
    Label = "Jump Boost",
    Default = false,
    Callback = function(state)
        if state then
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = 100
        else
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = 50
        end
        print("Jump Boost:", state)
    end
})

-- =====================================================
-- ADD TEXT INPUT TO SETTINGS PANEL
-- =====================================================
local playerInput = UILib:CreateTextInput(settingsPanel, {
    Placeholder = "Enter player name..."
})

UILib:CreateButton(settingsPanel, {
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

-- =====================================================
-- ADD TOGGLE KEY (RIGHT SHIFT TO HIDE/SHOW)
-- =====================================================
window:AddToggleKey(Enum.KeyCode.RightShift)

-- =====================================================
-- AUTO FARM LOOP EXAMPLE
-- =====================================================
task.spawn(function()
    while task.wait(1) do
        if autoFarmToggle.GetState() then
            print("Auto farming...")
            -- Your auto farm logic here
        end
    end
end)

-- =====================================================
-- SUCCESS NOTIFICATION
-- =====================================================
UILib:CreateNotification({
    Text = "✅ Demo loaded!\nPress Right Shift to toggle GUI",
    Duration = 4,
    Color = UILib.Colors.SUCCESS
})

print("UI Library Demo loaded successfully!")
