--[[
    Fast Dismantle All Script
    Uses direct server remotes instead of UI clicking for instant results.
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Get the Replicate remote
local Replicate = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Replicate")

local function dismantleAll()
    local dismantled = 0
    
    print("🔧 Starting Fast Dismantle All...")
    
    -- Get all items in backpack
    for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if item:IsA("Tool") then
            -- Check if it's a dismantleable item (has tags or is cyberware/weapon)
            local canDismantle = item:HasTag("Cyberware") or item:HasTag("MainWeapon") or item:HasTag("Gun")
            
            if canDismantle then
                -- Use the Replicate remote to dismantle instantly
                local success = pcall(function()
                    Replicate:FireServer(
                        "RequireModule",
                        "CraftingFunctions",
                        {
                            Action = "DismantleItem",
                            Item = item.Name
                        }
                    )
                end)
                
                if success then
                    dismantled = dismantled + 1
                    print("✅ Dismantled:", item.Name)
                else
                    warn("❌ Failed to dismantle:", item.Name)
                end
                
                -- Small delay to prevent server throttling
                task.wait(0.01)
            end
        end
    end
    
    print("🎉 Finished! Dismantled " .. dismantled .. " items.")
end

-- Run it
dismantleAll()

