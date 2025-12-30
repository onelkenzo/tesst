	-- JPUFF GUI V15 - WITH BYPASS LOADING SCREEN
	-- =========================
	-- LOADING SCREEN & BYPASS
	-- =========================
	
	local Players = game:GetService("Players")
	local TweenService = game:GetService("TweenService")
	local player = Players.LocalPlayer
	local gui = player:WaitForChild("PlayerGui")
	
	-- Create loading screen GUI
	local loadingGui = Instance.new("ScreenGui", gui)
	loadingGui.Name = "BypassLoadingScreen"
	loadingGui.ResetOnSpawn = false
	loadingGui.IgnoreGuiInset = true
	loadingGui.DisplayOrder = 999
	
	-- Blur effect
	local blur = Instance.new("BlurEffect", game:GetService("Lighting"))
	blur.Size = 0
	
	-- Full screen background
	local loadingBg = Instance.new("Frame", loadingGui)
	loadingBg.Size = UDim2.fromScale(1, 1)
	loadingBg.Position = UDim2.fromScale(0, 0)
	loadingBg.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	loadingBg.BackgroundTransparency = 0.3
	loadingBg.BorderSizePixel = 0
	
	-- Center container
	local loadingFrame = Instance.new("Frame", loadingBg)
	loadingFrame.Size = UDim2.fromOffset(400, 200)
	loadingFrame.Position = UDim2.fromScale(0.5, 0.5)
	loadingFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	loadingFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	loadingFrame.BorderSizePixel = 0
	Instance.new("UICorner", loadingFrame).CornerRadius = UDim.new(0, 15)
	
	-- Loading text
	local loadingText = Instance.new("TextLabel", loadingFrame)
	loadingText.Size = UDim2.new(1, 0, 0, 50)
	loadingText.Position = UDim2.fromScale(0, 0.3)
	loadingText.BackgroundTransparency = 1
	loadingText.Text = "Loading Bypass..."
	loadingText.Font = Enum.Font.GothamBold
	loadingText.TextSize = 24
	loadingText.TextColor3 = Color3.fromRGB(255, 255, 255)
	loadingText.TextTransparency = 0
	
	-- Animated dots
	local dots = ""
	task.spawn(function()
		while loadingGui.Parent do
			dots = dots .. "."
			if #dots > 3 then dots = "" end
			loadingText.Text = "Loading Bypass" .. dots
			task.wait(0.5)
		end
	end)
	
	-- Progress bar background
	local progressBg = Instance.new("Frame", loadingFrame)
	progressBg.Size = UDim2.new(0.8, 0, 0, 6)
	progressBg.Position = UDim2.fromScale(0.5, 0.65)
	progressBg.AnchorPoint = Vector2.new(0.5, 0.5)
	progressBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	progressBg.BorderSizePixel = 0
	Instance.new("UICorner", progressBg).CornerRadius = UDim.new(1, 0)
	
	-- Progress bar fill
	local progressFill = Instance.new("Frame", progressBg)
	progressFill.Size = UDim2.fromScale(0, 1)
	progressFill.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
	progressFill.BorderSizePixel = 0
	Instance.new("UICorner", progressFill).CornerRadius = UDim.new(1, 0)
	
	-- Animate blur in
	TweenService:Create(blur, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = 24}):Play()
	
	-- Animate progress bar
	local progressTween = TweenService:Create(
		progressFill,
		TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Size = UDim2.fromScale(1, 1)}
	)
	progressTween:Play()
	
	-- =========================
	-- BYPASS EXECUTION
	-- =========================
	task.spawn(function()
		if game and not game:IsLoaded() then
			repeat wait() until game:IsLoaded()
		end
		
		local old_identity = getthreadidentity()
		
		setthreadidentity(2) -- prevents "Adonis_0x16471" kick
		local mt = getrawmetatable(game)
		setreadonly(mt, false)
		
		local oldNewIndex = mt.__newindex
		
		mt.__newindex = newcclosure(function(t, k, v)
			if typeof(t) == "Instance" then
				local className = t.ClassName or "Unknown"
				if k == "Parent" or k == "Name" then
					return
				end
			end
			return oldNewIndex(t, k, v)
		end)
		
		setreadonly(mt, true)
		
		task.spawn(function()
			local patched = 0
			
			for _, func in ipairs(getgc(true)) do
				if typeof(func) == "function" and islclosure(func) then
					local ok, consts = pcall(debug.getconstants, func)
					if ok and consts and #consts <= 2 then
						for i, c in ipairs(consts) do
							if tostring(c):lower():find("script") == nil and tostring(c):lower():find("rbx") == nil then
								local src = debug.info(func, "s") or ""
								if src:find("Anti") or src:lower():find("core") then
									hookfunction(func, function(...)
										return
									end)
									patched += 1
								end
							end
						end
					end
				end
			end
		end)
		
		task.defer(function()
			for _, v in getgc(true) do
				if typeof(v) == "table" and rawget(v, "Kill") and typeof(v.Kill) == "function" then
					hookfunction(v.Kill, function(...)
						return
					end)
				end
			end
		end)
		
		local old_debug_info = debug.info
		hookfunction(debug.info, newcclosure(function(func, what)
			if typeof(func) == "function" and debug.info(func, "s") and debug.info(func, "s"):find("Core.Anti") then
				if what == "n" then return "Detected" end
				if what == "f" then return func end
				if what == "s" then return debug.info(func, "s") end
				if what == "l" then return debug.info(func, "l") end
				if what == "a" then return debug.info(func, "a") end
			end
			return old_debug_info(func, what)
		end))
		
		setthreadidentity(old_identity)
	end)
	
	-- Wait for bypass to complete
	task.wait(2.5)
	
	-- Update loading text
	loadingText.Text = "Bypass Complete!"
	loadingText.TextColor3 = Color3.fromRGB(0, 255, 150)
	task.wait(0.5)
	
	-- Fade out loading screen and unblur
	local fadeOutTween = TweenService:Create(
		loadingBg,
		TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{BackgroundTransparency = 1}
	)
	
	local textFadeTween = TweenService:Create(
		loadingText,
		TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{TextTransparency = 1}
	)
	
	local frameFadeTween = TweenService:Create(
		loadingFrame,
		TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{BackgroundTransparency = 1}
	)
	
	local blurTween = TweenService:Create(
		blur,
		TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{Size = 0}
	)
	
	fadeOutTween:Play()
	textFadeTween:Play()
	frameFadeTween:Play()
	blurTween:Play()
	
	blurTween.Completed:Wait()
	blur:Destroy()
	loadingGui:Destroy()
	
	-- =========================
	-- MAIN GUI STARTS HERE
	-- =========================
	
	-- SERVICES
	local RunService = game:GetService("RunService")
	local VIM = game:GetService("VirtualInputManager")

	-- =========================
-- PERSISTENT CONFIG SYSTEM
-- =========================
local HttpService = game:GetService("HttpService")
local CONFIG_FILE = "fishing_config.json"

local DefaultConfig = {
	tapEnabled = false,
	barEnabled = false,
	castEnabled = true,
	fishLocEnabled = false,
	freezeEnabled = false,
	AutoEquipBestRod = false,
	autoRejoinEnabled = true
}

local function loadConfig()
	if isfile and isfile(CONFIG_FILE) then
		local ok, data = pcall(function()
			return HttpService:JSONDecode(readfile(CONFIG_FILE))
		end)

		if ok and type(data) == "table" then
			for k,v in pairs(DefaultConfig) do
				if data[k] ~= nil then
					DefaultConfig[k] = data[k]
				end
			end
		end
	end
end

local function saveConfig()
	if writefile then
		local encoded = HttpService:JSONEncode(DefaultConfig)
		writefile(CONFIG_FILE, encoded)
	end
end

loadConfig()


	-- =========================
	-- AUTO REJOIN SETUP
	-- =========================
	getgenv()._VIP_ACCESS_CODE = getgenv()._VIP_ACCESS_CODE or nil
	getgenv()._KickRejoinFired = getgenv()._KickRejoinFired or false

	-- Capture VIP access code
	local TeleportService = game:GetService("TeleportService")
	local mt = getrawmetatable(game)
	local old = mt.__namecall
	setreadonly(mt, false)

	mt.__namecall = newcclosure(function(self, ...)
		local method = getnamecallmethod()
		local args = {...}

		-- Detect VIP teleport
		if self == TeleportService and method == "TeleportToPrivateServer" then
			local placeId, accessCode = args[1], args[2]
			if type(accessCode) == "string" and accessCode ~= "" then
				getgenv()._VIP_ACCESS_CODE = accessCode
			end
		end

		-- Detect kick and rejoin
		if method == "Kick" and self == player then
			if DefaultConfig.autoRejoinEnabled and not getgenv()._KickRejoinFired then
				getgenv()._KickRejoinFired = true
				task.delay(2, function()
					if getgenv()._VIP_ACCESS_CODE then
						TeleportService:TeleportToPrivateServer(
							game.PlaceId,
							getgenv()._VIP_ACCESS_CODE,
							{ player }
						)
					else
						TeleportService:Teleport(game.PlaceId, player)
					end
				end)
				return
			end
		end

		return old(self, ...)
	end)

	setreadonly(mt, true)

	-- Queue on teleport
	if queue_on_teleport then
		queue_on_teleport([[
			loadstring(game:HttpGet("https://raw.githubusercontent.com/onelkenzo/tesst/main/test03.lua"))()
		]])
	end

	-- =========================
	-- CONFIG
	-- =========================
	local GREEN_THRESHOLD = 150
	local CLICK_INTERVAL = 0.05

	local HUMAN_DELAY_MIN = 0.15
	local HUMAN_DELAY_MAX = 0.27

	-- =========================
	-- ROD NAMES (IN-GAME)
	-- =========================
	local VALID_RODS = {
		["Plasma Strike Rod"] = true,
		["Basic Rod"] = true,
		["Jolly Prism Rod"] = true,
		["BETA Bronze Rod"] = true,
		["New Year Rod"] = true,
		["Steam Punk Rod"] = true,
		["Steel Sword Rod"] = true,
		["Red Candy Rod"] = true,
		["BETA Gold Rod"] = true,
		["Green Bamboo Rod"] = true,
		["BETA Diamond Rod"] = true,
		["Inferno Flame Rod"] = true,
		["Green Necromancer Rod"] = true,
		["Frozen Snowflake Rod"] = true,
		["Christmas Tree Rod"] = true,
		["Santa Sleigh Rod"] = true,
		["Mossy White Rod"] = true,
		["BETA Silver Rod"] = true,
		["Green Candy Rod"] 	= true,
		["Blue Candy Rod"] = true,
		["Angelic Wing Rod"] = true,
		["Charming Heart Rod"] = true,
		["Leafy Branch Rod"] = true,
		["Yellow Pencil Rod"] = true,
	}


	local AutoEquipBestRod = DefaultConfig.AutoEquipBestRod


local RodPriority = {
    "Basic Rod",
    "Leafy Branch Rod",
    "Jolly Prism Rod",
    "Mossy White Rod",
    "Green Bamboo Rod",
    "Yellow Pencil Rod",
    "Steam Punk Rod",
    "Steel Sword Rod"	,
    "Angelic Wing Rod",
    "Charming Heart Rod",
    "Inferno Flame Rod",
    "Plasma Strike Rod",
    "New Year Rod",
    "Santa Sleigh Rod",
    "Green Necromancer Rod",
    "Christmas Tree Rod",
    "Frozen Snowflake Rod"
}


-- =========================
-- STATE FLAGS (SAVED)
-- =========================
local running = true

local tapEnabled      = DefaultConfig.tapEnabled
local barEnabled      = DefaultConfig.barEnabled
local castEnabled     = DefaultConfig.castEnabled
local fishLocEnabled  = DefaultConfig.fishLocEnabled
local freezeEnabled   = DefaultConfig.freezeEnabled

local hasEnteredFishing = false
local allowRecastAfterFish = false

local savedCFrame = nil
local casting = false




	-- =========================
	-- UTILS
	-- =========================

	local function humanDelay()
		task.wait(math.random(
			HUMAN_DELAY_MIN * 1000,
			HUMAN_DELAY_MAX * 1000
		) / 1000)
	end

	local function clickGui(obj)
		if not obj or not obj:IsDescendantOf(game) then return end
		local pos = obj.AbsolutePosition + (obj.AbsoluteSize / 2)
		VIM:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
		task.wait()
		VIM:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
	end

	local function getChar()
		return player.Character or player.CharacterAdded:Wait()
	end

	local function setAnchored(state)
		for _, v in ipairs(getChar():GetDescendants()) do
			if v:IsA("BasePart") then
				v.Anchored = state
			end
		end
	end

	-- =========================
-- STARTUP STATE APPLY
-- =========================
local function applyStartupState()
	local char = getChar()
	local root = char:WaitForChild("HumanoidRootPart")

	-- Fish location restore
	if fishLocEnabled then
		savedCFrame = root.CFrame

		root.CFrame = CFrame.new(-2502.88, -13.00, -561.81)
			* CFrame.Angles(0, math.rad(-87.95), 0)
	end

	-- Freeze restore
	if freezeEnabled then
		setAnchored(true)
	end
end


	local function findRod()
		
		local char = getChar()
		local backpack = player:WaitForChild("Backpack")

		-- Check equipped tools first
		for _, tool in ipairs(char:GetChildren()) do
			if tool:IsA("Tool")
				and VALID_RODS[tool.Name]
				and tool:FindFirstChild("Cast")
				and tool:FindFirstChild("ToolReady") then
				return tool
			end
		end

		-- Check backpack
		for _, tool in ipairs(backpack:GetChildren()) do
			if tool:IsA("Tool")
				and VALID_RODS[tool.Name]
				and tool:FindFirstChild("Cast")
				and tool:FindFirstChild("ToolReady") then
				return tool
			end
		end

		return nil
	end
	local function playerOwnsRod(name)
	local backpack = player:WaitForChild("Backpack")
	if backpack:FindFirstChild(name) then
		return true
	end

	local char = getChar()
	if char:FindFirstChild(name) then
		return true
	end

	return false
end

local function equipRod(name)
	local char = getChar()
	local humanoid = char:WaitForChild("Humanoid")
	local backpack = player:WaitForChild("Backpack")

	local tool = backpack:FindFirstChild(name)
	if tool then
		humanoid:EquipTool(tool)
	end
end


	-- =========================
	-- GUI
	-- =========================

	
	local screenGui = Instance.new("ScreenGui", gui)
	screenGui.Name = "FishingControlGUI"
	screenGui.ResetOnSpawn = false

	local frame = Instance.new("Frame", screenGui)
	frame.Size = UDim2.fromOffset(220, 415)


	frame.Position = UDim2.fromScale(0.02, 0.4)
	frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
	frame.Active = true
	frame.Draggable = true
	frame.BackgroundTransparency = 1 -- Start invisible
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0,10)

	local function makeButton(text, y)
		local b = Instance.new("TextButton", frame)
		b.Size = UDim2.fromOffset(190,35)
		b.Position = UDim2.fromOffset(15,y)
		b.Text = text
		b.BackgroundColor3 = Color3.fromRGB(60,60,60)
		b.TextColor3 = Color3.new(1,1,1)
		b.Font = Enum.Font.GothamBold
		b.TextSize = 14
		b.BackgroundTransparency = 1 -- Start invisible
		b.TextTransparency = 1 -- Start invisible
		Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
		return b
	end

	local tapBtn    = makeButton("Tap Game: OFF", 15)
	local barBtn    = makeButton("Bar Game: OFF", 60)
	local castBtn   = makeButton("Auto Cast: ON", 105)
	local fishBtn   = makeButton("Fish Location: OFF", 195)
	local freezeBtn = makeButton("Freeze: OFF", 240)
	local closeBtn  = makeButton("CLOSE SCRIPT", 375)
	local sellBtn = makeButton("Sell All", 285)
	local equipBestBtn = makeButton("Equip Best Rod: OFF", 150)
	local rejoinBtn = makeButton("Auto Rejoin: ON", 330)

	tapBtn.Text    = "Tap Game: " .. (tapEnabled and "ON" or "OFF")
barBtn.Text    = "Bar Game: " .. (barEnabled and "ON" or "OFF")
castBtn.Text   = "Auto Cast: " .. (castEnabled and "ON" or "OFF")
fishBtn.Text   = "Fish Location: " .. (fishLocEnabled and "ON" or "OFF")
freezeBtn.Text = "Freeze: " .. (freezeEnabled and "ON" or "OFF")
equipBestBtn.Text = "Equip Best Rod: " .. (AutoEquipBestRod and "ON" or "OFF")
rejoinBtn.Text = "Auto Rejoin: " .. (DefaultConfig.autoRejoinEnabled and "ON" or "OFF")


applyStartupState()


	sellBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 60)
	closeBtn.BackgroundColor3 = Color3.fromRGB(140,40,40)

	local warningFrame = Instance.new("Frame", frame)
	warningFrame.Size = UDim2.fromOffset(190, 40)
	warningFrame.Position = UDim2.fromOffset(15, 235)
	warningFrame.BackgroundTransparency = 1
	warningFrame.ClipsDescendants = true

	local warningLabel = Instance.new("TextLabel", warningFrame)
	warningLabel.Size = UDim2.fromScale(1,1)
	warningLabel.Position = UDim2.fromOffset(0, 10) -- start lowered
	warningLabel.BackgroundTransparency = 1
	warningLabel.TextColor3 = Color3.fromRGB(255, 120, 120)
	warningLabel.Font = Enum.Font.GothamBold
	warningLabel.TextSize = 12
	warningLabel.TextWrapped = true
	warningLabel.TextYAlignment = Enum.TextYAlignment.Center
	warningLabel.TextTransparency = 1
	warningLabel.Text = ""


	local function showWarning(text)
		warningLabel.Text = text

		-- Reset
		warningLabel.Position = UDim2.fromOffset(0, 10)
		warningLabel.TextTransparency = 1

		-- Animate IN
		TweenService:Create(
			warningLabel,
			TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{Position = UDim2.fromOffset(0, 0), TextTransparency = 0}
		):Play()

		-- Animate OUT after delay
		task.delay(2, function()
			TweenService:Create(
				warningLabel,
				TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{Position = UDim2.fromOffset(0, -10), TextTransparency = 1}
			):Play()
		end)
	end

	-- =========================
	-- FADE IN GUI
	-- =========================
	task.wait(0.3)
	
	-- Fade in frame background
	TweenService:Create(
		frame,
		TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{BackgroundTransparency = 0}
	):Play()
	
	-- Fade in all buttons
	local allButtons = {tapBtn, barBtn, castBtn, fishBtn, freezeBtn, closeBtn, sellBtn, equipBestBtn, rejoinBtn}
	for i, btn in ipairs(allButtons) do
		task.wait(0.05)
		TweenService:Create(
			btn,
			TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{BackgroundTransparency = 0, TextTransparency = 0}
		):Play()
	end

	-- =========================
	-- BUTTON LOGIC
	-- =========================

	sellBtn.MouseButton1Click:Connect(function()
		local rs = game:GetService("ReplicatedStorage")
		local remotes = rs:WaitForChild("GameRemoteFunctions", 3)

		if not remotes then
			showWarning("Sell remote not found")
			return
		end

		local sellFunc = remotes:WaitForChild("SellAllFishFunction", 3)

		if not sellFunc then
			showWarning("Sell function missing")
			return
		end

		pcall(function()
			sellFunc:InvokeServer()
		end)
	end)


	tapBtn.MouseButton1Click:Connect(function()
	tapEnabled = not tapEnabled
	DefaultConfig.tapEnabled = tapEnabled
	tapBtn.Text = "Tap Game: " .. (tapEnabled and "ON" or "OFF")
	saveConfig()
end)


	barBtn.MouseButton1Click:Connect(function()
	barEnabled = not barEnabled
	DefaultConfig.barEnabled = barEnabled
	barBtn.Text = "Bar Game: " .. (barEnabled and "ON" or "OFF")
	saveConfig()
end)


	castBtn.MouseButton1Click:Connect(function()
	castEnabled = not castEnabled
	DefaultConfig.castEnabled = castEnabled

	if not castEnabled then
		hasEnteredFishing = false
	end

	castBtn.Text = "Auto Cast: " .. (castEnabled and "ON" or "OFF")
	saveConfig()
end)



	fishBtn.MouseButton1Click:Connect(function()
		warningLabel.Text = ""
		if freezeEnabled then
			showWarning("⚠ Enable Fishing Location before Freeze")		task.delay(2, function()
				warningLabel.Text = ""
			end)
			return
		end

		fishLocEnabled = not fishLocEnabled
		DefaultConfig.fishLocEnabled = fishLocEnabled
		saveConfig()
		local root = getChar():WaitForChild("HumanoidRootPart")

		if fishLocEnabled then
			savedCFrame = root.CFrame
			root.CFrame = CFrame.new(-2502.88, -13.00, -561.81)
				* CFrame.Angles(0, math.rad(-87.95), 0)
			fishBtn.Text = "Fish Location: ON"
		else
			if savedCFrame then
				root.CFrame = savedCFrame
			end
			fishBtn.Text = "Fish Location: OFF"
		end
	end)



	freezeBtn.MouseButton1Click:Connect(function()
	freezeEnabled = not freezeEnabled
	DefaultConfig.freezeEnabled = freezeEnabled
	setAnchored(freezeEnabled)
	freezeBtn.Text = "Freeze: " .. (freezeEnabled and "ON" or "OFF")
	saveConfig()
end)

equipBestBtn.MouseButton1Click:Connect(function()
	if not castEnabled then
		showWarning("AutoCast must be ON first!")
		return
	end

	AutoEquipBestRod = not AutoEquipBestRod
	DefaultConfig.AutoEquipBestRod = AutoEquipBestRod
	equipBestBtn.Text = "Equip Best Rod: " .. (AutoEquipBestRod and "ON" or "OFF")
	saveConfig()
end)

rejoinBtn.MouseButton1Click:Connect(function()
	DefaultConfig.autoRejoinEnabled = not DefaultConfig.autoRejoinEnabled
	rejoinBtn.Text = "Auto Rejoin: " .. (DefaultConfig.autoRejoinEnabled and "ON" or "OFF")
	saveConfig()
end)



	closeBtn.MouseButton1Click:Connect(function()
		running = false
		setAnchored(false)
		if savedCFrame then
			getChar():WaitForChild("HumanoidRootPart").CFrame = savedCFrame
		end
		screenGui:Destroy()
	end)

	-- =========================
	-- TAP GAME (NO DELAY)
	-- =========================
	task.spawn(function()
		while running do
			if tapEnabled then
				local ui = gui:FindFirstChild("FishingUI")
				local pre = ui and ui:FindFirstChild("PreFishingHolder")
				if pre and pre.Visible then
					for _, btn in ipairs(pre:GetDescendants()) do
						if btn:IsA("ImageButton")
						and btn.Name == "TapButton"
						and btn.Visible
						and btn.Active then
							pcall(function()
								firesignal(btn.Activated)
							end)
						end
					end
				end
			end
			task.wait(0.05)
		end
	end)

	-- =========================
	-- BAR GAME (HUMANIZED)
	-- =========================
	task.spawn(function()
		while running do
			if barEnabled then
				local ui = gui:FindFirstChild("FishingUI")
				local holder = ui and ui:FindFirstChild("FishingHolder")
				if holder and holder.Visible then
					local bar = holder:FindFirstChild("BarContainer", true)
					local fill = bar and bar:FindFirstChild("Bar", true)
					if fill then
						local c = fill.BackgroundColor3
						if c.G * 255 > GREEN_THRESHOLD and c.G > c.R then
							humanDelay()
							clickGui(fill)
						end
					end
				end
			end
			RunService.RenderStepped:Wait()
		end
	end)

	-- =========================
	-- FISHING ANIMATION LOCK
	-- =========================

	local FISHING_ANIMATIONS = {
		["rbxassetid://89023128565837"]  = true, -- Cast
		["rbxassetid://107858786510758"] = true, -- Fishing (waiting)
		["rbxassetid://136444937709795"] = true, -- Fish caught / pulling
	}

	local IDLE_EQUIP_ANIM = "rbxassetid://95097952328030" -- equip idle (allowed)

	local function isFishingAnimationPlaying()
		local char = getChar()
		local humanoid = char:FindFirstChildOfClass("Humanoid")
		if not humanoid then return false end

		local animator = humanoid:FindFirstChildOfClass("Animator")
		if not animator then return false end

		for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
			local anim = track.Animation
			if anim then
				local id = anim.AnimationId
				-- block ALL fishing states
				if FISHING_ANIMATIONS[id] then
					return true
				end
			end
		end

		return false
	end


	-- =========================
	-- AUTO CAST (YOUR EXACT VERSION)
	-- =========================

	local function getEquippedRod()
		local char = getChar()
		for _, tool in ipairs(char:GetChildren()) do
			if tool:IsA("Tool")
				and tool:FindFirstChild("Cast")
				and tool:FindFirstChild("ToolReady") then
				return tool
			end
		end
		return nil
	end


	local function CastOnce()
		if not castEnabled or casting then return end

		-- auto-loop lock (but allow post-fish recast)
		if hasEnteredFishing and not allowRecastAfterFish then
			return
		end

		casting = true

		-- WAIT for fishing animations to fully stop
		local timeoutAnim = tick() + 2
		while isFishingAnimationPlaying() and tick() < timeoutAnim do
			task.wait()
		end

		local char = getChar()
		local humanoid = char:WaitForChild("Humanoid")

		local tool = getEquippedRod()
		if not tool then
			hasEnteredFishing = false
			allowRecastAfterFish = false
			casting = false
			return
		end

		local cast = tool:WaitForChild("Cast")
		local toolReady = tool:WaitForChild("ToolReady")

		local token
		local conn
		conn = toolReady.OnClientEvent:Connect(function(t)
			token = t
		end)

		-- controlled re-equip (single time)
		humanoid:UnequipTools()
		task.wait(0.15)
		humanoid:EquipTool(tool)

		-- wait for server token
		local timeout = tick() + 5
		while not token and tick() < timeout do
			task.wait()
		end

		if token then
			humanDelay()
			cast:InvokeServer(math.random(30,190) / 100, token)

			-- consume post-fish permission
			allowRecastAfterFish = false
		end

		if conn then
			conn:Disconnect()
		end

		casting = false
	end



	-- auto loop

task.spawn(function()
	while running do
		if castEnabled
		and not casting
		and not hasEnteredFishing
		and not isFishingAnimationPlaying()
		then
			local ui = gui:FindFirstChild("FishingUI")
			local holder = ui and ui:FindFirstChild("FishingHolder")

			if not (holder and holder.Visible) then

				-- equip best BEFORE checking tool
				if AutoEquipBestRod and castEnabled then
					for i = #RodPriority, 1, -1 do
						local rodName = RodPriority[i]
						if playerOwnsRod(rodName) then
							equipRod(rodName)
							break
						end
					end
				end

				local tool = getEquippedRod()
				if tool then
					CastOnce()
				end
			end
		end

		task.wait(0.4)
	end
end)





	-- =========================
	-- SUCCESS DETECTION
	-- =========================
	task.spawn(function()
		local wasFishing = false
		while running do
			local ui = gui:FindFirstChild("FishingUI")
			local holder = ui and ui:FindFirstChild("FishingHolder")

			if holder then
				if holder.Visible then
					wasFishing = true
					hasEnteredFishing = true
				elseif wasFishing then
					wasFishing = false
					allowRecastAfterFish = true
					humanDelay()
					CastOnce()
				end
			end

			task.wait(0.1)
		end
	end)
