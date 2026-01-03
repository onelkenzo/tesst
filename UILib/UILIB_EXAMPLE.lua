-- =====================================================
-- UI LIBRARY EXAMPLE USAGE
-- This demonstrates how to use the JPUFF UI Library
-- =====================================================

-- Load the UI Library from GitHub
local UILib = loadstring(game:HttpGet("https://raw.githubusercontent.com/onelkenzo/tesst/main/UILIB.lua"))()

-- =====================================================
-- STEP 1: CREATE LOADING SCREEN (OPTIONAL)
-- =====================================================
local loading = UILib:CreateLoadingScreen({
    Title = "My Script",
    AccentColor = UILib.Colors.JPUFF_HOT_PINK,
    Duration = 2.5,
    OnComplete = function()
        print("Loading complete!")
    end
})

-- Wait for loading to finish
task.wait(3)

-- =====================================================
-- STEP 2: CREATE MAIN WINDOW
-- =====================================================
local window = UILib:CreateWindow({
    Title = "My Script",
    Name = "MyScriptGUI",
    AccentColor = UILib.Colors.JPUFF_HOT_PINK,
    Size = UDim2.fromOffset(600, 400),
    Position = UDim2.fromOffset(50, 50)
})

-- Add methods to window
UILib:AddMethods(window)

-- =====================================================
-- STEP 3: CREATE PANELS (TABS)
-- =====================================================

-- Main Panel
local mainPanel = window:CreatePanel({
    Name = "main",
    DisplayName = "Main",
    Color = UILib.Colors.JPUFF_HOT_PINK,
    Size = UDim2.fromOffset(340, 530),
    LayoutOrder = 1
})

-- Settings Panel
local settingsPanel = window:CreatePanel({
    Name = "settings",
    DisplayName = "Settings",
    Color = UILib.Colors.WARNING,
    Size = UDim2.fromOffset(340, 400),
    LayoutOrder = 2
})

-- Misc Panel
local miscPanel = window:CreatePanel({
    Name = "misc",
    DisplayName = "Misc",
    Color = Color3.fromRGB(120, 180, 255),
    Size = UDim2.fromOffset(340, 350),
    LayoutOrder = 3
})

-- =====================================================
-- STEP 4: ADD ELEMENTS TO PANELS
-- =====================================================

-- Add toggles to Main Panel
local autoFarmToggle = UILib:CreateToggle(mainPanel, {
    Label = "Auto Farm",
    Default = false,
    Callback = function(state)
        print("Auto Farm:", state)
        -- Your auto farm logic here
    end
})

local autoCollectToggle = UILib:CreateToggle(mainPanel, {
    Label = "Auto Collect",
    Default = true,
    Callback = function(state)
        print("Auto Collect:", state)
        -- Your auto collect logic here
    end
})

local espToggle = UILib:CreateToggle(mainPanel, {
    Label = "ESP",
    Default = false,
    Callback = function(state)
        print("ESP:", state)
        -- Your ESP logic here
    end
})

-- Add button to Main Panel
local teleportButton = UILib:CreateButton(mainPanel, {
    Text = "🚀 Teleport to Spawn",
    Color = UILib.Colors.SUCCESS,
    Callback = function()
        print("Teleporting to spawn!")
        UILib:CreateNotification({
            Text = "✅ Teleported to spawn!",
            Duration = 2,
            Color = UILib.Colors.SUCCESS
        })
        -- Your teleport logic here
    end
})

-- Add text input to Settings Panel
local playerInput = UILib:CreateTextInput(settingsPanel, {
    Placeholder = "Enter player name..."
})

-- Add button to use the input
local targetButton = UILib:CreateButton(settingsPanel, {
    Text = "Target Player",
    Color = UILib.Colors.WARNING,
    Callback = function()
        local playerName = playerInput.Text
        if playerName ~= "" then
            print("Targeting player:", playerName)
            UILib:CreateNotification({
                Text = "🎯 Targeting: " .. playerName,
                Duration = 2,
                Color = UILib.Colors.WARNING
            })
        else
            UILib:CreateNotification({
                Text = "⚠️ Please enter a player name!",
                Duration = 2,
                Color = UILib.Colors.ERROR
            })
        end
    end
})

-- Add toggles to Settings Panel
local speedToggle = UILib:CreateToggle(settingsPanel, {
    Label = "Speed Boost",
    Default = false,
    Callback = function(state)
        print("Speed Boost:", state)
        if state then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 50
        else
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
        end
    end
})

local jumpToggle = UILib:CreateToggle(settingsPanel, {
    Label = "Jump Boost",
    Default = false,
    Callback = function(state)
        print("Jump Boost:", state)
        if state then
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = 100
        else
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = 50
        end
    end
})

-- Add toggles to Misc Panel
local noClipToggle = UILib:CreateToggle(miscPanel, {
    Label = "No Clip",
    Default = false,
    Callback = function(state)
        print("No Clip:", state)
        -- Your no clip logic here
    end
})

local flyToggle = UILib:CreateToggle(miscPanel, {
    Label = "Fly",
    Default = false,
    Callback = function(state)
        print("Fly:", state)
        -- Your fly logic here
    end
})

-- Add a dangerous button with confirmation
local resetButton = UILib:CreateButton(miscPanel, {
    Text = "⚠️ Reset Character",
    Color = UILib.Colors.ERROR,
    Callback = function()
        UILib:CreateConfirmation({
            Title = "⚠️ WARNING",
            Message = "Are you sure you want to reset your character? This cannot be undone!",
            ConfirmText = "Reset",
            CancelText = "Cancel",
            OnConfirm = function()
                print("Resetting character...")
                game.Players.LocalPlayer.Character.Humanoid.Health = 0
            end,
            OnCancel = function()
                print("Reset cancelled")
            end
        })
    end
})

-- =====================================================
-- STEP 5: ADD TOGGLE KEY (RIGHT SHIFT TO HIDE/SHOW)
-- =====================================================
window:AddToggleKey(Enum.KeyCode.RightShift)

-- =====================================================
-- STEP 6: SHOW A NOTIFICATION
-- =====================================================
UILib:CreateNotification({
    Text = "✅ Script loaded successfully!\nPress Right Shift to toggle GUI",
    Duration = 4,
    Color = UILib.Colors.SUCCESS
})

-- =====================================================
-- ACCESSING TOGGLE STATES
-- =====================================================
-- You can get the current state of toggles:
print("Auto Farm is currently:", autoFarmToggle.GetState())

-- You can also set the state programmatically:
-- autoFarmToggle.SetState(true)

-- =====================================================
-- EXAMPLE: AUTO FARM LOOP
-- =====================================================
task.spawn(function()
    while task.wait(1) do
        if autoFarmToggle.GetState() then
            print("Auto farming...")
            -- Your auto farm logic here
        end
    end
end)

print("UI Library Example loaded successfully!")
