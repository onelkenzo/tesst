--[[
    Fast Sell All Script
    Uses direct server remotes to instantly sell all items in backpack.
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Get the Replicate remote
local Replicate = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Replicate")

local function sellAll()
    local sold = 0
    local totalValue = 0
    
    print("💰 Starting Fast Sell All...")
    
    -- Get all items in backpack
    for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if item:IsA("Tool") then
            -- Sell everything except equipped items
            local success = pcall(function()
                Replicate:FireServer("SellItem", item.Name)
            end)
            
            if success then
                sold = sold + 1
                print("✅ Sold:", item.Name)
            else
                warn("❌ Failed to sell:", item.Name)
            end
            
            -- Small delay to prevent server throttling
            task.wait(0.01)
        end
    end
    
    print("🎉 Finished! Sold " .. sold .. " items.")
end

-- Run it
sellAll()
