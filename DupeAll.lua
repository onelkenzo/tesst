-- Configuration
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local DUPE_COUNT = 10000
local DISTANCE = 20

local function CollectDroppedMoney()
    local droppedItems = game:GetService("Workspace"):FindFirstChild("Misc")
    if droppedItems then
        droppedItems = droppedItems:FindFirstChild("DroppedItems")
    end
    
    if not droppedItems then
        return 0
    end
    
    -- Check if we have a character
    if not (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) then
        return 0
    end
    
    local myPos = LocalPlayer.Character.HumanoidRootPart.Position
    local collected = 0
    
    for _, item in ipairs(droppedItems:GetChildren()) do
        if item.Name == "Part" and item:FindFirstChild("ProximityPrompt") then
            -- Distance check
            local dist = (item.Position - myPos).Magnitude
            if dist <= DISTANCE then
                local prompt = item.ProximityPrompt
                
                -- Teleport to money
                LocalPlayer.Character.HumanoidRootPart.CFrame = item.CFrame
                task.wait(0.1)
                
                -- OPTIMIZED DUPLICATION EXPLOIT
                local dupeCount = DUPE_COUNT
                local batchSize = 1000
                
                if dupeCount <= 1000 then
                    -- Small count: fire all at once (fastest)
                    for i=1,dupeCount do
                        fireproximityprompt(prompt)
                    end
                else
                    -- Large count: use batching with parallel execution
                    local batches = math.ceil(dupeCount / batchSize)
                    for batch = 1, batches do
                        local itemsInBatch = math.min(batchSize, dupeCount - ((batch - 1) * batchSize))
                        
                        -- Fire batch in parallel
                        task.spawn(function()
                            for i = 1, itemsInBatch do
                                fireproximityprompt(prompt)
                            end
                        end)
                        
                        -- Tiny yield to prevent executor hang
                        if batch % 10 == 0 then
                            task.wait()
                        end
                    end
                    
                    -- Wait for all batches to complete
                    task.wait(0.5)
                end
                
                collected = collected + 1
                task.wait(0.15)
            end
        end
    end
    
    return collected
end

print("💰 Starting DupeAll (Dupe Count:", DUPE_COUNT, ")")
local result = CollectDroppedMoney()
if result > 0 then
    print("🎉 Finished! Duped", result, "items!")
else
    warn("❌ No money found nearby! Drop money on the ground first.")
end

