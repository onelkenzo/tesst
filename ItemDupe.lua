--[[
    Optimized Item Dupe Script
    Dupes 10,000 items with batching and delays to prevent crashes.
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Configuration
local ITEM_TO_DUPE = "Dynalar Sandevistan" -- Change this to the item you want to dupe
local TOTAL_DUPES = 10000
local BATCH_SIZE = 100 -- Dupe in batches to prevent lag
local BATCH_DELAY = 0.5 -- Wait between batches
local ITEM_DELAY = 0.01 -- Wait between individual items

-- Get the Replicate remote
local Replicate = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Replicate")

local function dupeItems()
    local duped = 0
    local batches = math.ceil(TOTAL_DUPES / BATCH_SIZE)
    
    print("🔄 Starting Optimized Item Dupe...")
    print("📦 Target:", ITEM_TO_DUPE)
    print("🎯 Total:", TOTAL_DUPES)
    print("📊 Batches:", batches, "x", BATCH_SIZE)
    
    for batch = 1, batches do
        local itemsInBatch = math.min(BATCH_SIZE, TOTAL_DUPES - duped)
        
        print("⚙️ Batch", batch .. "/" .. batches, "- Duping", itemsInBatch, "items...")
        
        for i = 1, itemsInBatch do
            local success = pcall(function()
                Replicate:FireServer(
                    "RequireModule",
                    "CraftingFunctions",
                    {
                        Action = "CraftItem",
                        Item = ITEM_TO_DUPE
                    }
                )
            end)
            
            if success then
                duped = duped + 1
            else
                warn("❌ Failed to dupe item", duped + 1)
            end
            
            -- Small delay between items
            task.wait(ITEM_DELAY)
        end
        
        -- Progress update
        local progress = math.floor((duped / TOTAL_DUPES) * 100)
        print("✅ Progress:", duped .. "/" .. TOTAL_DUPES, "(" .. progress .. "%)")
        
        -- Wait between batches to prevent server throttling
        if batch < batches then
            print("⏳ Waiting", BATCH_DELAY, "seconds before next batch...")
            task.wait(BATCH_DELAY)
        end
    end
    
    print("🎉 Finished! Successfully duped", duped .. "/" .. TOTAL_DUPES, "items!")
end

-- Run it
dupeItems()
