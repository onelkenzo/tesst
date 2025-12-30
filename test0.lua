-- ==================================================
-- AUTO REJOIN GUI (BUNNI)
-- ONE-SHOT | LOOP-PROOF | STABLE
-- ==================================================

-- ===== QUEUE ON TELEPORT =====
if queue_on_teleport then
    queue_on_teleport([[
        loadstring(game:HttpGet("https://raw.githubusercontent.com/onelkenzo/tesst/main/test0"))()
    ]])
end

repeat task.wait() until game:IsLoaded()

-- ===== SINGLE INSTANCE =====
if getgenv().AutoRejoinLoaded then return end
getgenv().AutoRejoinLoaded = true

-- ===== SERVICES =====
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local placeId = game.PlaceId

-- ===== SETTINGS =====
local AutoRejoin = true
local Delay = 3

-- ===== HARD FUSE (NEVER RESETS) =====
getgenv()._RejoinFired = false

-- ===== REJOIN FUNCTION =====
local function Rejoin()
    if not AutoRejoin then return end
    if getgenv()._RejoinFired then return end

    getgenv()._RejoinFired = true

    task.spawn(function()
        task.wait(Delay)
        TeleportService:Teleport(placeId, player)
    end)
end

-- ===== DISCONNECT DETECTION =====
CoreGui.DescendantAdded:Connect(function(v)
    if not AutoRejoin or getgenv()._RejoinFired then return end
    if not v:IsA("TextLabel") then return end

    local t = string.lower(v.Text)
    if t:find("kicked")
    or t:find("disconnected")
    or t:find("connection")
    or t:find("error") then
        Rejoin()
    end
end)

player.AncestryChanged:Connect(function(_, parent)
    if parent == nil then
        Rejoin()
    end
end)

-- ==================================================
-- GUI
-- ==================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "AutoRejoinGUI"
Gui.ResetOnSpawn = false
Gui.Parent = CoreGui

local Frame = Instance.new("Frame", Gui)
Frame.Size = UDim2.fromOffset(230, 140)
Frame.Position = UDim2.fromScale(0.4, 0.4)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "Auto Rejoin"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextColor3 = Color3.new(1, 1, 1)

local Status = Instance.new("TextLabel", Frame)
Status.Position = UDim2.fromOffset(0, 30)
Status.Size = UDim2.new(1, 0, 0, 20)
Status.BackgroundTransparency = 1
Status.Text = "Status: ON"
Status.Font = Enum.Font.Gotham
Status.TextSize = 13
Status.TextColor3 = Color3.fromRGB(0, 200, 0)

local Toggle = Instance.new("TextButton", Frame)
Toggle.Position = UDim2.fromOffset(20, 70)
Toggle.Size = UDim2.fromOffset(190, 45)
Toggle.Text = "AUTO REJOIN: ON"
Toggle.Font = Enum.Font.GothamBold
Toggle.TextSize = 16
Toggle.TextColor3 = Color3.new(1, 1, 1)
Toggle.BackgroundColor3 = Color3.fromRGB(0, 170, 0)

Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0, 8)

Toggle.MouseButton1Click:Connect(function()
    AutoRejoin = not AutoRejoin
    if AutoRejoin then
        Toggle.Text = "AUTO REJOIN: ON"
        Toggle.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        Status.Text = "Status: ON"
        Status.TextColor3 = Color3.fromRGB(0, 200, 0)
    else
        Toggle.Text = "AUTO REJOIN: OFF"
        Toggle.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
        Status.Text = "Status: OFF"
        Status.TextColor3 = Color3.fromRGB(200, 0, 0)
    end
end)
