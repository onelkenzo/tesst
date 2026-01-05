--[[
    Dismantle All Script
    Automates clicking all buttons within the DismantleList in RipperdocUpgrades.
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Configuration
local LIST_PATH = "RipperdocUpgrades.Main.CraftScene.DismantleList"
local REWARD_PATH = "RipperdocUpgrades.Main.RewardScene.ContinueButton"
local CLICK_DELAY = 0.05 -- Delay between clicks to prevent lag/errors

-- Helper function to find the list safely
local function getDismantleList()
    local current = PlayerGui
    for segment in string.gmatch(LIST_PATH, "([^.]+)") do
        current = current:FindFirstChild(segment)
        if not current then
            return nil
        end
    end
    return current
end

-- Robust click function for executors
local function clickButton(btn)
    if not btn:IsA("GuiButton") or not btn.Visible then return end
    
    -- Method 1: firesignal (Standard for most executors)
    if firesignal then
        pcall(function() firesignal(btn.MouseButton1Click) end)
        pcall(function() firesignal(btn.Activated) end)
    end
    
    -- Method 2: getconnections fallback
    if getconnections then
        for _, connection in pairs(getconnections(btn.MouseButton1Click)) do
            if connection.Fire then connection:Fire() end
        end
        for _, connection in pairs(getconnections(btn.Activated)) do
            if connection.Fire then connection:Fire() end
        end
    end
end

-- Helper to handle the Reward Scene popup
local function handleRewardScene()
    local current = PlayerGui
    for segment in string.gmatch(REWARD_PATH, "([^.]+)") do
        current = current:FindFirstChild(segment)
        if not current then break end
    end
    
    if current and current:IsA("GuiButton") and current.Visible then
        -- Wait a tiny bit for UI to be stable
        task.wait(0.2)
        clickButton(current)
        -- Wait for it to disappear
        local start = tick()
        while current.Visible and tick() - start < 1 do
            task.wait(0.1)
        end
        return true
    end
    return false
end

local function dismantleAll()
    local list = getDismantleList()
    
    if not list then
        warn("DismantleList not found at path: " .. LIST_PATH)
        return
    end
    
    local items = list:GetChildren()
    local clickedCount = 0
    
    print("Starting Dismantle All...")
    
    for _, item in ipairs(items) do
        -- If the child itself is a button, click it
        if item:IsA("GuiButton") then
            clickButton(item)
            clickedCount = clickedCount + 1
            handleRewardScene()
            task.wait(CLICK_DELAY)
        else
            -- If it's a container, search for buttons inside it
            for _, descendant in ipairs(item:GetDescendants()) do
                if descendant:IsA("GuiButton") then
                    clickButton(descendant)
                    clickedCount = clickedCount + 1
                    handleRewardScene()
                    task.wait(CLICK_DELAY)
                end
            end
        end
    end
    
    print("Finished! Clicked " .. clickedCount .. " buttons.")
end

-- Run it
dismantleAll()
