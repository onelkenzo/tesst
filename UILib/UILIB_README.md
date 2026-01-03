# JPUFF UI LIBRARY V1.0 📚

A beautiful, feature-rich UI library for Roblox scripts with smooth animations and the iconic Jigglypuff pink theme.

## ✨ Features

- 🎨 **Beautiful Design** - Jigglypuff-themed color palette with smooth animations
- 🔄 **Loading Screens** - Animated loading screens with progress bars
- 📑 **Multi-Panel System** - Organize your UI with multiple tabs/panels
- 🎚️ **Animated Toggles** - Smooth toggle switches with Jigglypuff images
- 🔘 **Buttons** - Customizable buttons with hover effects
- 📝 **Text Inputs** - Styled text input fields
- 🔔 **Notifications** - Slide-in notification system
- ⚠️ **Confirmations** - Modal confirmation dialogs
- ⌨️ **Toggle Key** - Hide/show GUI with a hotkey (default: Right Shift)
- 🎭 **Smooth Animations** - TweenService-powered animations throughout

## 📦 Installation

### Method 1: Load from GitHub (Recommended)
```lua
local UILib = loadstring(game:HttpGet("https://raw.githubusercontent.com/onelkenzo/tesst/main/UILIB.lua"))()
```

### Method 2: Local File
```lua
local UILib = require(script.Parent.UILIB)
```

## 🚀 Quick Start

```lua
-- Load the library
local UILib = loadstring(game:HttpGet("https://raw.githubusercontent.com/onelkenzo/tesst/main/UILIB.lua"))()

-- Create a window
local window = UILib:CreateWindow({
    Title = "My Script",
    AccentColor = UILib.Colors.JPUFF_HOT_PINK
})

-- Add methods
UILib:AddMethods(window)

-- Create a panel
local mainPanel = window:CreatePanel({
    Name = "main",
    DisplayName = "Main",
    Color = UILib.Colors.JPUFF_HOT_PINK
})

-- Add a toggle
local toggle = UILib:CreateToggle(mainPanel, {
    Label = "Auto Farm",
    Default = false,
    Callback = function(state)
        print("Auto Farm:", state)
    end
})

-- Add toggle key
window:AddToggleKey(Enum.KeyCode.RightShift)
```

## 📖 Documentation

### Colors

The library includes a pre-defined color palette:

```lua
UILib.Colors.JPUFF_PINK          -- Light pink
UILib.Colors.JPUFF_HOT_PINK      -- Hot pink (default accent)
UILib.Colors.JPUFF_DARK_PINK     -- Dark pink
UILib.Colors.BG_DARK             -- Dark background
UILib.Colors.BG_CARD             -- Card background
UILib.Colors.TEXT_PRIMARY        -- White text
UILib.Colors.TEXT_SECONDARY      -- Gray text
UILib.Colors.TOGGLE_OFF          -- Toggle off color
UILib.Colors.SUCCESS             -- Green (success)
UILib.Colors.WARNING             -- Yellow (warning)
UILib.Colors.ERROR               -- Red (error)
```

### Loading Screen

Create an animated loading screen:

```lua
local loading = UILib:CreateLoadingScreen({
    Title = "My Script",              -- Loading text
    AccentColor = UILib.Colors.JPUFF_HOT_PINK,  -- Accent color
    Duration = 2.5,                   -- Duration in seconds
    OnComplete = function()           -- Callback when complete
        print("Loading done!")
    end
})

-- Returns: { Gui, Blur, Destroy() }
```

### Window

Create the main window:

```lua
local window = UILib:CreateWindow({
    Title = "My Script",              -- Window title
    Name = "MyScriptGUI",             -- ScreenGui name
    AccentColor = UILib.Colors.JPUFF_HOT_PINK,  -- Accent color
    Size = UDim2.fromOffset(600, 400),  -- Window size (optional)
    Position = UDim2.fromOffset(50, 50) -- Window position (optional)
})

-- Add methods to window
UILib:AddMethods(window)
```

### Panel (Tab)

Create panels to organize your UI:

```lua
local panel = window:CreatePanel({
    Name = "main",                    -- Internal name (unique)
    DisplayName = "Main",             -- Display name
    Color = UILib.Colors.JPUFF_HOT_PINK,  -- Panel color
    Size = UDim2.fromOffset(340, 530),    -- Panel size (optional)
    LayoutOrder = 1                   -- Button order (optional)
})
```

### Toggle

Create animated toggle switches:

```lua
local toggle = UILib:CreateToggle(panel, {
    Label = "Auto Farm",              -- Toggle label
    Default = false,                  -- Initial state
    Callback = function(state)        -- Called when toggled
        print("State:", state)
    end
})

-- Methods:
toggle.GetState()                     -- Get current state
toggle.SetState(true)                 -- Set state programmatically
toggle.Toggle()                       -- Toggle the switch
```

### Button

Create clickable buttons:

```lua
local button = UILib:CreateButton(panel, {
    Text = "Click Me!",               -- Button text
    Color = UILib.Colors.SUCCESS,     -- Button color
    Callback = function()             -- Called when clicked
        print("Button clicked!")
    end
})
```

### Text Input

Create text input fields:

```lua
local input = UILib:CreateTextInput(panel, {
    Placeholder = "Enter text..."     -- Placeholder text
})

-- Access the text:
print(input.Text)
```

### Notification

Show slide-in notifications:

```lua
UILib:CreateNotification({
    Text = "✅ Success!",              -- Notification text
    Duration = 3,                     -- Duration in seconds
    Color = UILib.Colors.SUCCESS      -- Border color
})
```

### Confirmation Dialog

Show confirmation dialogs:

```lua
UILib:CreateConfirmation({
    Title = "⚠️ WARNING",             -- Dialog title
    Message = "Are you sure?",        -- Dialog message
    ConfirmText = "Yes",              -- Confirm button text
    CancelText = "No",                -- Cancel button text
    OnConfirm = function()            -- Called when confirmed
        print("Confirmed!")
    end,
    OnCancel = function()             -- Called when cancelled
        print("Cancelled!")
    end
})
```

### Toggle Key

Add a hotkey to show/hide the GUI:

```lua
window:AddToggleKey(Enum.KeyCode.RightShift)
```

## 💡 Complete Example

```lua
-- Load library
local UILib = loadstring(game:HttpGet("https://raw.githubusercontent.com/onelkenzo/tesst/main/UILIB.lua"))()

-- Create loading screen
local loading = UILib:CreateLoadingScreen({
    Title = "My Script",
    Duration = 2
})

task.wait(2.5)

-- Create window
local window = UILib:CreateWindow({
    Title = "My Script"
})
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
```

## 🎨 Customization

### Custom Colors

You can use custom colors for any element:

```lua
local panel = window:CreatePanel({
    Name = "custom",
    DisplayName = "Custom",
    Color = Color3.fromRGB(100, 200, 255)  -- Custom color
})
```

### Panel Sizes

Adjust panel sizes based on content:

```lua
local smallPanel = window:CreatePanel({
    Name = "small",
    DisplayName = "Small",
    Size = UDim2.fromOffset(340, 300)  -- Smaller panel
})

local largePanel = window:CreatePanel({
    Name = "large",
    DisplayName = "Large",
    Size = UDim2.fromOffset(340, 600)  -- Larger panel
})
```

## 🔧 Advanced Usage

### Programmatic Toggle Control

```lua
-- Get current state
local isEnabled = toggle.GetState()

-- Set state without triggering callback
toggle.SetState(true)

-- Toggle (triggers callback)
toggle.Toggle()
```

### Dynamic Panel Switching

```lua
-- Show a specific panel
window:ShowPanel("main")

-- Hide current panel
window:HidePanel(window.CurrentPanel)
```

### Destroy Window

```lua
window:Destroy()
```

## 📝 Notes

- The library automatically handles animations and transitions
- All UI elements are automatically positioned (ContentY tracking)
- Toggle images use Jigglypuff assets (sleep/awake states)
- The selector frame is draggable by default
- Panels sync position with the selector when dragged

## 🐛 Troubleshooting

**UI not showing:**
- Make sure you called `UILib:AddMethods(window)`
- Check if the GUI is hidden (press Right Shift)

**Toggles not animating:**
- Ensure the Jigglypuff image assets are accessible
- Check console for errors

**Panels not switching:**
- Verify panel names are unique
- Make sure you're using the correct panel name in `ShowPanel()`

## 📄 License

Free to use and modify for your Roblox scripts!

## 🙏 Credits

Created from JPUFF GUI V26 by extracting and modularizing the UI system.

---

**Enjoy creating beautiful UIs! 🎨✨**
