--[[
    Money Generator with GUI
    Continuously dupes and sells money until toggled off.
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Configuration
local DUPE_COUNT = 1000
local DISTANCE = 30

-- Create simple GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MoneyGeneratorGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 250, 0, 150)
Frame.Position = UDim2.new(0.5, -125, 0.5, -75)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "💰 Money Generator"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 200, 0, 50)
ToggleButton.Position = UDim2.new(0.5, -100, 0, 60)
ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleButton.Text = "Start Generator"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 18
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Parent = Frame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 8)
ButtonCorner.Parent = ToggleButton

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 30)
StatusLabel.Position = UDim2.new(0, 0, 1, -35)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Idle"
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.TextSize = 14
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Parent = Frame

-- State
local isRunning = false

local function generateMoney()
    -- First, drop 1 item from backpack to dupe
    local DropTool = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Player"):WaitForChild("DropTool")
    local droppedItem = nil
    
    for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if item:IsA("Tool") then
            StatusLabel.Text = "📤 Dropping item..."
            DropTool:FireServer(item.Name)
            droppedItem = item.Name
            task.wait(0.5) -- Wait for item to drop
            break
        end
    end
    
    if not droppedItem then
        StatusLabel.Text = "⚠️ No items in backpack to drop!"
        return 0
    end
    
    local droppedItems = Workspace:FindFirstChild("Misc")
    if droppedItems then
        droppedItems = droppedItems:FindFirstChild("DroppedItems")
    end
    
    if not droppedItems then
        StatusLabel.Text = "⚠️ No money found!"
        return 0
    end
    
    if not (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) then
        return 0
    end
    
    local myPos = LocalPlayer.Character.HumanoidRootPart.Position
    
    -- Find the CLOSEST item only
    local closestItem = nil
    local closestDist = DISTANCE
    
    for _, item in ipairs(droppedItems:GetChildren()) do
        if item.Name == "Part" and item:FindFirstChild("ProximityPrompt") then
            local dist = (item.Position - myPos).Magnitude
            if dist <= closestDist then
                closestItem = item
                closestDist = dist
            end
        end
    end
    
    -- Only dupe the closest item
    if closestItem then
        StatusLabel.Text = "🔄 Duping closest item..."
        
        LocalPlayer.Character.HumanoidRootPart.CFrame = closestItem.CFrame
        task.wait(0.1)
        
        local prompt = closestItem.ProximityPrompt
        for i = 1, DUPE_COUNT do
            if not isRunning then break end
            fireproximityprompt(prompt)
        end
        
        task.wait(0.2)
        
        -- Sell all duped items
        StatusLabel.Text = "💵 Selling..."
        task.wait(0.5)
        
        local Replicate = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Replicate")
        local sold = 0
        
        for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if not isRunning then break end
            
            if item:IsA("Tool") then
                pcall(function()
                    Replicate:FireServer("SellItem", item.Name)
                end)
                sold = sold + 1
                task.wait(0.01)
            end
        end
        
        StatusLabel.Text = "✅ Sold " .. sold .. " items!"
        
        -- Drop 1 item for next cycle
        task.wait(0.3)
        StatusLabel.Text = "📤 Preparing next cycle..."
        
        for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if item:IsA("Tool") then
                DropTool:FireServer(item.Name)
                task.wait(0.5)
                break
            end
        end
        
        return 1
    else
        StatusLabel.Text = "⚠️ No items nearby!"
        return 0
    end
end

ToggleButton.MouseButton1Click:Connect(function()
    isRunning = not isRunning
    
    if isRunning then
        ToggleButton.Text = "Stop Generator"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        StatusLabel.Text = "Status: Running..."
        
        task.spawn(function()
            while isRunning do
                generateMoney()
                if isRunning then
                    task.wait(1)
                end
            end
            StatusLabel.Text = "Status: Stopped"
        end)
    else
        ToggleButton.Text = "Start Generator"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        StatusLabel.Text = "Status: Idle"
    end
end)

print("💰 Money Generator GUI loaded!")
