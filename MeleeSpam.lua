--[[
    Melee Spam Ragdoll Exploit
    Rapidly spams melee attacks to ragdoll and launch nearby players
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Configuration
local SPAM_DELAY = 0.01 -- 10ms between hits (100 hits/sec)
local SPAM_ACTIVE = false

-- Get combat remote
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local CombatRemote = Remotes:WaitForChild("Combat"):WaitForChild("Input")

-- Simple GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MeleeSpamGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 100)
Frame.Position = UDim2.new(0.5, -100, 0.1, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "⚔️ Melee Ragdoll"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 160, 0, 50)
ToggleButton.Position = UDim2.new(0.5, -80, 0, 40)
ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleButton.Text = "Start Spam"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 16
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Parent = Frame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 8)
ButtonCorner.Parent = ToggleButton

-- Melee spam function
local function spamMelee()
    while SPAM_ACTIVE do
        -- Try different melee input types
        pcall(function()
            -- Method 1: Basic melee attack
            CombatRemote:FireServer("LMB") -- Left mouse button (melee)
        end)
        
        pcall(function()
            -- Method 2: Direct melee command
            CombatRemote:FireServer("MELEE_ATTACK")
        end)
        
        pcall(function()
            -- Method 3: Melee hit with target
            if LocalPlayer.Character then
                -- Find nearby players to hit
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local dist = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                        if dist <= 10 then
                            CombatRemote:FireServer("MELEE", player.Character)
                        end
                    end
                end
            end
        end)
        
        task.wait(SPAM_DELAY)
    end
end

ToggleButton.MouseButton1Click:Connect(function()
    SPAM_ACTIVE = not SPAM_ACTIVE
    
    if SPAM_ACTIVE then
        ToggleButton.Text = "Stop Spam"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        
        task.spawn(spamMelee)
        print("⚔️ Melee spam started! Stand near players to ragdoll them.")
    else
        ToggleButton.Text = "Start Spam"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        print("⏸️ Melee spam stopped")
    end
end)

print("⚔️ Melee Ragdoll GUI loaded!")
print("💡 Toggle to start spamming melee attacks")
print("🎯 Stand near players to launch them!")
