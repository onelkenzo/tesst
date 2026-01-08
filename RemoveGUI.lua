--[[
    GUI Remover
    Removes MoneyGeneratorGUI and ComponentFarmerGUI from screen.
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Remove MoneyGeneratorGUI
local moneyGUI = PlayerGui:FindFirstChild("MoneyGeneratorGUI")
if moneyGUI then
    moneyGUI:Destroy()
    print("✅ Removed MoneyGeneratorGUI")
else
    print("❌ MoneyGeneratorGUI not found")
end

-- Remove ComponentFarmerGUI
local componentGUI = PlayerGui:FindFirstChild("ComponentFarmerGUI")
if componentGUI then
    componentGUI:Destroy()
    print("✅ Removed ComponentFarmerGUI")
else
    print("❌ ComponentFarmerGUI not found")
end

print("🎯 GUI removal complete!")
