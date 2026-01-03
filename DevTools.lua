local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- CLEANUP SYSTEM
if _G.DevTools then
    if _G.DevTools.Connections then
        for _, conn in ipairs(_G.DevTools.Connections) do
            conn:Disconnect()
        end
    end
    if _G.DevTools.Guis then
        for _, gui in ipairs(_G.DevTools.Guis) do
            if gui then gui:Destroy() end
        end
    end
end

_G.DevTools = {
    Connections = {},
    Guis = {}
}

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
    warn("Failed to load UILIB from Local or Web. Please check file/connection.")
    return
end

-- Create Window with Specific Name for Cleanup
local Window = UILib:CreateWindow({
    Name = "DevToolsMainGui", -- Used for internal identification if needed
    Title = "DevTools Helper",
    Size = UDim2.fromOffset(600, 400),
    Position = UDim2.fromOffset(100, 100)
})

-- DEBUG: Check if methods were attached
print("DEBUG: Window.ShowPanel exists?", Window.ShowPanel ~= nil)
print("DEBUG: UILib.AddMethods exists?", UILib.AddMethods ~= nil)

-- SAFETY: Ensure methods are attached (in case UILIB version mismatch)
if not Window.ShowPanel and UILib.AddMethods then
    print("DEBUG: Manually calling AddMethods...")
    UILib:AddMethods(Window)
end

-- Track Window GUI for cleanup
if Window.ScreenGui then
    table.insert(_G.DevTools.Guis, Window.ScreenGui)
end

-- Create Panel (Tab)
local MainPanel = UILib:CreatePanel(Window, {
    Name = "Main",
    DisplayName = "Inspectors"
})

-- State Variables
local InspectPartMode = false
local InspectGuiMode = false
local InspectClickableMode = false

local SelectedObject = nil
local ClickTPMode = false
local NoclipMode = false

local HighlightBox = Instance.new("SelectionBox")
HighlightBox.LineThickness = 0.05
HighlightBox.Color3 = Color3.fromRGB(255, 0, 0)
HighlightBox.Parent = CoreGui
table.insert(_G.DevTools.Guis, HighlightBox) -- Cleanup HighlightBox

-- Better GUI Highlight Logic
local HighlightScreenGui = Instance.new("ScreenGui")
HighlightScreenGui.Name = "DevToolsHighlight"
HighlightScreenGui.IgnoreGuiInset = true
HighlightScreenGui.DisplayOrder = 9999
HighlightScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
table.insert(_G.DevTools.Guis, HighlightScreenGui) -- Cleanup HighlightScreenGui

local GuiHighlightFrame = Instance.new("Frame")
GuiHighlightFrame.BackgroundTransparency = 0.7
GuiHighlightFrame.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
GuiHighlightFrame.BorderColor3 = Color3.fromRGB(0, 255, 0)
GuiHighlightFrame.BorderSizePixel = 2
GuiHighlightFrame.Visible = false
GuiHighlightFrame.Active = false -- IMPORTANT: Do not capture input
GuiHighlightFrame.Selectable = false
GuiHighlightFrame.Parent = HighlightScreenGui

-- Helper Functions
local function getTargetPart()
    return Mouse.Target
end

local function getTargetGui(onlyClickable)
    local guis = LocalPlayer.PlayerGui:GetGuiObjectsAtPosition(Mouse.X, Mouse.Y)
    for _, gui in ipairs(guis) do
        -- If we hit our own highlighter, ignore it and look deeper
        if gui:IsDescendantOf(HighlightScreenGui) then
            continue
        end
        
        -- If we hit our own Menu, STOP inspecting.
        if Window.ScreenGui and gui:IsDescendantOf(Window.ScreenGui) then
            return nil
        end
        
        -- Also ignore other common dev/admin panels if usually in CoreGui/PlayerGui, 
        -- but avoiding specific names unless known.

        if gui.Visible then
            if onlyClickable then
                if gui:IsA("GuiButton") or gui:IsA("TextBox") then
                    return gui
                end
            else
                return gui
            end
        end
    end
    return nil
end

local function setSelected(obj)
    SelectedObject = obj
    print("Selected:", obj:GetFullName())
    
    -- Visual Feedback
    pcall(function()
        UILib:CreateNotification({
            Text = "Selected: " .. obj.Name,
            Duration = 2
        })
    end)
end

-- Input Handling
local inputConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    -- Toggle GUI Visibility (Requested: Right Shift)
    if input.KeyCode == Enum.KeyCode.RightShift then
        if Window.ScreenGui then
            Window.ScreenGui.Enabled = not Window.ScreenGui.Enabled
        end
        return
    end

    -- PANIC KEY: Disable all modes (Swapped to Right Control)
    if input.KeyCode == Enum.KeyCode.RightControl then
        InspectPartMode = false
        InspectGuiMode = false
        InspectClickableMode = false
        SelectedObject = nil
        ClickTPMode = false
        NoclipMode = false
        
        pcall(function()
            UILib:CreateNotification({Text = "SAFE MODE: All Tools Disabled", Duration = 3, Color = UILib.Colors.WARNING})
        end)
        return
    end
    
    -- Click to Inspect/Select
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        
        -- Logic:
        -- If inspecting GUI, we WANT to capture clicks on GUI elements (so we ignore gameProcessed).
        -- If inspecting Parts, we DO NOT want to capture clicks on GUI elements (so we respect gameProcessed).
        
        if InspectGuiMode or InspectClickableMode then
            -- GUI Inspection Mode: Inspect regardless of gameProcessed
            local onlyClickable = InspectClickableMode
            local gui = getTargetGui(onlyClickable)
            if gui then 
                setSelected(gui) 
            end
            
        elseif InspectPartMode then
            -- Part Inspection Mode: Only inspect if we didn't click a UI
            if not gameProcessed then
                local part = getTargetPart()
                if part then setSelected(part) end
            end
            
        else
            -- Not inspecting anything? Respect gameProcessed
            if gameProcessed then return end
            
            -- Click TP logic
            if ClickTPMode and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                local pos = Mouse.Hit
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pos.X, pos.Y + 3, pos.Z)
                end
            end
        end
    end
end)
table.insert(_G.DevTools.Connections, inputConn)

-- Render Loop for Highlights & Noclip
local noclipConn = RunService.Stepped:Connect(function()
    if NoclipMode and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide == true then
                v.CanCollide = false
            end
        end
    end
end)
table.insert(_G.DevTools.Connections, noclipConn)

local renderConn = RunService.RenderStepped:Connect(function()
    HighlightBox.Adornee = nil
    GuiHighlightFrame.Visible = false
    
    -- Highlight hovered item
    if InspectPartMode then
        local part = getTargetPart()
        if part then HighlightBox.Adornee = part end
    elseif InspectGuiMode or InspectClickableMode then
        local gui = getTargetGui(InspectClickableMode)
        if gui then
            GuiHighlightFrame.Visible = true
            GuiHighlightFrame.Size = UDim2.fromOffset(gui.AbsoluteSize.X, gui.AbsoluteSize.Y)
            GuiHighlightFrame.Position = UDim2.fromOffset(gui.AbsolutePosition.X, gui.AbsolutePosition.Y)
        end
    end
    
    -- If we wanted to highlight selected object permanently, we'd need another box. 
    -- For now, we just rely on the notification.
end)
table.insert(_G.DevTools.Connections, renderConn)

-- UI Setup
UILib:CreateToggle(MainPanel, {
    Label = "Inspect Part",
    Callback = function(state)
        InspectPartMode = state
        InspectGuiMode = false
        InspectClickableMode = false
    end
})

UILib:CreateToggle(MainPanel, {
    Label = "Inspect GUI",
    Callback = function(state)
        InspectGuiMode = state
        InspectPartMode = false
        InspectClickableMode = false
    end
})

UILib:CreateToggle(MainPanel, {
    Label = "Inspect Clickable GUI",
    Callback = function(state)
        InspectClickableMode = state
        InspectPartMode = false
        InspectGuiMode = false
    end
})

UILib:CreateButton(MainPanel, {
    Text = "Copy Selected Name",
    Callback = function()
        if SelectedObject then
            setclipboard(SelectedObject.Name)
            UILib:CreateNotification({Text = "Copied Name!", Duration = 2})
        else
            UILib:CreateNotification({Text = "No object selected!", Duration = 2, Color = UILib.Colors.ERROR})
        end
    end
})

UILib:CreateButton(MainPanel, {
    Text = "Copy Selected Path",
    Callback = function()
        if SelectedObject then
            setclipboard(SelectedObject:GetFullName())
            UILib:CreateNotification({Text = "Copied Path!", Duration = 2})
        else
            UILib:CreateNotification({Text = "No object selected!", Duration = 2, Color = UILib.Colors.ERROR})
        end
    end
})

UILib:CreateButton(MainPanel, {
    Text = "Copy Position / UDim2",
    Callback = function()
        if SelectedObject then
            if SelectedObject:IsA("BasePart") then
                local p = SelectedObject.Position
                setclipboard(string.format("Vector3.new(%.3f, %.3f, %.3f)", p.X, p.Y, p.Z))
            elseif SelectedObject:IsA("GuiObject") then
                 local p = SelectedObject.Position
                 setclipboard(string.format("UDim2.new(%.3f, %.3f, %.3f, %.3f)", p.X.Scale, p.X.Offset, p.Y.Scale, p.Y.Offset))
            end
            UILib:CreateNotification({Text = "Copied Data!", Duration = 2})
        else
             UILib:CreateNotification({Text = "No object selected!", Duration = 2, Color = UILib.Colors.ERROR})
        end
    end
})

-- Utils Panel
local UtilsPanel = UILib:CreatePanel(Window, {
    Name = "Utils",
    DisplayName = "Utilities"
})

UILib:CreateToggle(UtilsPanel, {
    Label = "Click TP (Ctrl+Click)",
    Callback = function(state)
        ClickTPMode = state
    end
})

UILib:CreateToggle(UtilsPanel, {
    Label = "Noclip",
    Callback = function(state)
        NoclipMode = state
    end
})

UILib:CreateButton(UtilsPanel, {
    Text = "Copy Player Location",
    Callback = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local pos = LocalPlayer.Character.HumanoidRootPart.Position
            local str = string.format("Vector3.new(%.2f, %.2f, %.2f)", pos.X, pos.Y, pos.Z)
            setclipboard(str)
            UILib:CreateNotification({Text = "Copied location!", Duration = 3})
        end
    end
})

UILib:CreateButton(UtilsPanel, {
    Text = "Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end
})

-- Show the first panel by default
Window:ShowPanel("Main")
