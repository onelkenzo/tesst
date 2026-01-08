--[[
    Money Generator Script
    Dupes dropped money and immediately converts to cash at maximum speed.
    
    HOW TO USE:
    1. Drop money on the ground near you
    2. Run this script
    3. Watch money multiply and sell automatically!
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Configuration
local DUPE_COUNT = 1000 -- How many times to dupe each money item
local DISTANCE = 30 -- Max distance to collect money (studs)

print("💰 Money Generator Started!")
print("⚙️ Dupe Count:", DUPE_COUNT)

local function generateMoney()
    local droppedItems = Workspace:FindFirstChild("Misc")
    if droppedItems then
        droppedItems = droppedItems:FindFirstChild("DroppedItems")
    end
    
    if not droppedItems then
        warn("❌ DroppedItems folder not found! Drop money on the ground first.")
        return 0
    end
    
    if not (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) then
        warn("❌ Character not found!")
        return 0
    end
    
    local myPos = LocalPlayer.Character.HumanoidRootPart.Position
    local moneyGenerated = 0
    
    -- Find and dupe all nearby money
    for _, item in ipairs(droppedItems:GetChildren()) do
        if item.Name == "Part" and item:FindFirstChild("ProximityPrompt") then
            local dist = (item.Position - myPos).Magnitude
            
            if dist <= DISTANCE then
                print("💵 Found money -", math.floor(dist), "studs away")
                
                -- Teleport to money
                LocalPlayer.Character.HumanoidRootPart.CFrame = item.CFrame
                task.wait(0.1)
                
                -- ULTRA FAST DUPE - No batching for max speed
                local prompt = item.ProximityPrompt
                print("🔄 Duping", DUPE_COUNT, "times...")
                
                for i = 1, DUPE_COUNT do
                    fireproximityprompt(prompt)
                end
                
                moneyGenerated = moneyGenerated + 1
                print("✅ Duped money item", moneyGenerated)
                
                task.wait(0.2) -- Short wait before next item
            end
        end
    end
    
    if moneyGenerated > 0 then
        print("🎉 Generated money from", moneyGenerated, "items!")
        print("💰 Total items duped:", moneyGenerated * DUPE_COUNT)
        
        -- Now sell everything in backpack to convert to cash
        print("💵 Auto-selling all items...")
        task.wait(0.5) -- Wait for items to land in backpack
        
        local Replicate = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Replicate")
        local sold = 0
        
        for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if item:IsA("Tool") then
                local success = pcall(function()
                    Replicate:FireServer("SellItem", item.Name)
                end)
                
                if success then
                    sold = sold + 1
                end
                
                task.wait(0.01)
            end
        end
        
        print("✅ Sold", sold, "items for cash!")
        print("🎉 Money generation complete!")
    else
        warn("❌ No money found! Drop money on the ground within", DISTANCE, "studs.")
    end
    
    return moneyGenerated
end

-- Run the generator
generateMoney()
