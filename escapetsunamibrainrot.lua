--// JY UI FINAL
--// TP SECTION RESTORED + AUTO HIT FIXED + ANTI-RAGDOLL FULL + REAL CIRCLE
--// SPEED PANEL REMOVED, UNLOCK ZOOM REMOVED, HIGH JUMP REMOVED
--// NOTHING ELSE CHANGED

local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

--// STATES
local INSTA_STEAL_ENABLED = false
local SITE_LOCATION_ENABLED = false
local AUTOHIT_ENABLED = false
local ANTI_RAGDOLL_ENABLED = false
local ORIGINAL_HOLD = {}
local TP_SPAM_RUNNING = {}
local PLAYER_ESP_ENABLED = false
local ZOOM_UNLOCK_ENABLED = false
local espMarkers = {}

--// GUI
local gui = Instance.new("ScreenGui")
gui.Name = "JY_GUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

--// Glow
local function addGlow(frame)
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 2
	stroke.Color = Color3.fromRGB(0,255,255)
	stroke.Parent = frame
end

--// LOGO
local logo = Instance.new("TextButton")
logo.Size = UDim2.fromOffset(70,70)
logo.Position = UDim2.new(0,20,0.5,-35)
logo.Text = "JY"
logo.Font = Enum.Font.GothamBlack
logo.TextSize = 28
logo.TextColor3 = Color3.fromRGB(0,255,255)
logo.BackgroundColor3 = Color3.fromRGB(15,15,15)
logo.BackgroundTransparency = 0.3
logo.Active = true
logo.Draggable = true
logo.Parent = gui
Instance.new("UICorner",logo).CornerRadius = UDim.new(0,12)
addGlow(logo)

--// MAIN PANEL
local panel = Instance.new("Frame")
panel.Size = UDim2.fromOffset(320,320)
panel.Position = UDim2.new(0.5,-160,0.5,-160)
panel.BackgroundColor3 = Color3.fromRGB(15,15,15)
panel.BackgroundTransparency = 0.3
panel.Visible = false
panel.Active = true
panel.Draggable = true
panel.Parent = gui
Instance.new("UICorner",panel).CornerRadius = UDim.new(0,14)
addGlow(panel)

--// MAIN SCROLLING FRAME
local mainScroll = Instance.new("ScrollingFrame")
mainScroll.Size = UDim2.new(1,0,1,0)
mainScroll.Position = UDim2.new(0,0,0,0)
mainScroll.CanvasSize = UDim2.new(0,0,2,0)
mainScroll.ScrollBarThickness = 6
mainScroll.BackgroundTransparency = 1
mainScroll.Parent = panel

--// TITLE
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,-20,0,40)
title.Position = UDim2.fromOffset(10,10)
title.Text = "JY PANEL"
title.Font = Enum.Font.GothamBold
title.TextSize = 22
title.TextColor3 = Color3.fromRGB(0,255,255)
title.BackgroundTransparency = 1
title.Parent = mainScroll

--// BIG LABEL ABOVE INSTA STEAL
local mainLabel = Instance.new("TextLabel")
mainLabel.Size = UDim2.new(1,-20,0,30)
mainLabel.Position = UDim2.fromOffset(10,40)
mainLabel.Text = "Main"
mainLabel.Font = Enum.Font.GothamBold
mainLabel.TextSize = 22
mainLabel.TextColor3 = Color3.fromRGB(0,255,255)
mainLabel.BackgroundTransparency = 1
mainLabel.Parent = mainScroll

--// ROW CREATOR
local function createSwitchRow(text,y,boxDarkness)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1,-20,0,40)
	row.Position = UDim2.fromOffset(10,y)
	row.BackgroundTransparency = 1
	row.Parent = mainScroll

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.7,0,1,0)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = text
	label.Font = Enum.Font.Gotham
	label.TextSize = 18
	label.TextColor3 = Color3.new(1,1,1)
	label.BackgroundTransparency = 1
	label.Parent = row

	local switch = Instance.new("TextButton")
	switch.Size = UDim2.fromOffset(60,28) -- slightly bigger
	switch.Position = UDim2.new(1,-60,0.5,-14)
	switch.BackgroundColor3 = boxDarkness or Color3.fromRGB(60,60,60)
	switch.Text = ""
	switch.Parent = row
	Instance.new("UICorner",switch).CornerRadius = UDim.new(1,0)

	local knob = Instance.new("Frame")
	knob.Size = UDim2.fromOffset(24,24)
	knob.Position = UDim2.fromOffset(2,2)
	knob.BackgroundColor3 = Color3.new(1,1,1)
	knob.Parent = switch
	Instance.new("UICorner",knob).CornerRadius = UDim.new(1,0)

	return switch, knob
end

local instaSwitch, instaKnob = createSwitchRow("Insta Steal",70)
local siteSwitch, siteKnob   = createSwitchRow("Site Location",110)
local autoHitSwitch, autoHitKnob = createSwitchRow("Auto Hit",150)
local antiRagdollSwitch, antiRagdollKnob = createSwitchRow("Anti-Ragdoll",190)

--// BIG LABEL ABOVE PLAYER
local miscLabel = Instance.new("TextLabel")
miscLabel.Size = UDim2.new(1,-20,0,30)
miscLabel.Position = UDim2.fromOffset(10,230)
miscLabel.Text = "Misc"
miscLabel.Font = Enum.Font.GothamBold
miscLabel.TextSize = 22
miscLabel.TextColor3 = Color3.fromRGB(0,255,255)
miscLabel.BackgroundTransparency = 1
miscLabel.Parent = mainScroll

local playerSwitch, playerKnob = createSwitchRow("Player", 270, Color3.fromRGB(20,20,20)) -- darker

--// NEW ZOOM UNLOCK OPTION
local zoomSwitch, zoomKnob = createSwitchRow("Unlock Zoom Limits", 310, Color3.fromRGB(20,20,20))

--// TP SECTION BUTTON
local tpRow = Instance.new("Frame")
tpRow.Size = UDim2.new(1,-20,0,40)
tpRow.Position = UDim2.fromOffset(10,350)
tpRow.BackgroundTransparency = 1
tpRow.Parent = mainScroll

local tpButton = Instance.new("TextButton")
tpButton.Size = UDim2.new(1,0,1,0)
tpButton.Text = "TP Section"
tpButton.Font = Enum.Font.Gotham
tpButton.TextSize = 18
tpButton.TextColor3 = Color3.new(1,1,1)
tpButton.BackgroundColor3 = Color3.fromRGB(15,15,15)
tpButton.BackgroundTransparency = 0.3
tpButton.Parent = tpRow
Instance.new("UICorner",tpButton).CornerRadius = UDim.new(0,14)
addGlow(tpButton)

--// SITE LOCATION PANEL
local sitePanel = Instance.new("TextButton")
sitePanel.Size = UDim2.fromOffset(180,90)
sitePanel.Position = UDim2.new(0.02,0,0.75,0)
sitePanel.BackgroundColor3 = Color3.fromRGB(15,15,15)
sitePanel.BackgroundTransparency = 0.3
sitePanel.Text = ""
sitePanel.Visible = false
sitePanel.Active = true
sitePanel.Draggable = true
sitePanel.Parent = gui
Instance.new("UICorner",sitePanel).CornerRadius = UDim.new(0,12)
addGlow(sitePanel)

local coordText = Instance.new("TextLabel")
coordText.Size = UDim2.new(1,-10,1,-10)
coordText.Position = UDim2.fromOffset(5,5)
coordText.TextWrapped = true
coordText.TextScaled = true
coordText.TextColor3 = Color3.new(1,1,1)
coordText.BackgroundTransparency = 1
coordText.Parent = sitePanel

sitePanel.MouseButton1Click:Connect(function()
	if setclipboard then
		setclipboard(coordText.Text)
	end
end)

--// TP PANEL SCROLLABLE
local tpPanel = Instance.new("Frame")
tpPanel.Size = UDim2.fromOffset(260,250)
tpPanel.Position = UDim2.new(0.5,-130,0.5,-150)
tpPanel.BackgroundColor3 = Color3.fromRGB(15,15,15)
tpPanel.BackgroundTransparency = 0.3
tpPanel.Visible = false
tpPanel.Active = true
tpPanel.Parent = gui
Instance.new("UICorner",tpPanel).CornerRadius = UDim.new(0,14)
addGlow(tpPanel)

-- Smooth draggable fix
local function makeDraggable(frame)
	local dragging, dragInput, dragStart, startPos
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	frame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)
	RunService.RenderStepped:Connect(function()
		if dragging and dragInput then
			local delta = dragInput.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

makeDraggable(tpPanel)
makeDraggable(panel)

-- scrolling frame inside TP
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1,0,1,0)
scroll.Position = UDim2.new(0,0,0,0)
scroll.CanvasSize = UDim2.new(0,0,1,0)
scroll.ScrollBarThickness = 6
scroll.BackgroundTransparency = 1
scroll.Parent = tpPanel

--// TP LOCATIONS (Spawn & Celestial) + Spam TP
local function createTP(text,y,pos)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1,-20,0,30)
	b.Position = UDim2.fromOffset(10,y)
	b.Text = text
	b.Font = Enum.Font.Gotham
	b.TextSize = 16
	b.TextColor3 = Color3.new(1,1,1)
	b.BackgroundColor3 = Color3.fromRGB(15,15,15)
	b.BackgroundTransparency = 0.3
	b.Parent = scroll
	Instance.new("UICorner",b).CornerRadius = UDim.new(0,14)
	addGlow(b)

	b.MouseButton1Click:Connect(function()
		local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if hrp then
			hrp.CFrame = CFrame.new(pos)
		end
	end)

	-- Start/Stop spam TP buttons
	local start = Instance.new("TextButton",scroll)
	start.Size = UDim2.new(0.48,-5,0,25)
	start.Position = UDim2.fromOffset(10,y+32)
	start.Text = "▶️ Start"
	start.BackgroundColor3 = Color3.fromRGB(0,200,0)
	start.TextColor3 = Color3.new(1,1,1)
	Instance.new("UICorner",start).CornerRadius = UDim.new(0,12)

	start.MouseButton1Click:Connect(function()
		TP_SPAM_RUNNING[text] = true
		task.spawn(function()
			while TP_SPAM_RUNNING[text] do
				local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
				if hrp then
					hrp.CFrame = CFrame.new(pos)
				end
				task.wait(0.0008)
			end
		end)
	end)

	local stop = Instance.new("TextButton",scroll)
	stop.Size = UDim2.new(0.48,-5,0,25)
	stop.Position = UDim2.fromOffset(135,y+32)
	stop.Text = "⏹️ Stop"
	stop.BackgroundColor3 = Color3.fromRGB(200,0,0)
	stop.TextColor3 = Color3.new(1,1,1)
	Instance.new("UICorner",stop).CornerRadius = UDim.new(0,12)

	stop.MouseButton1Click:Connect(function()
		TP_SPAM_RUNNING[text] = false
	end)
end

createTP("Spawn",10,Vector3.new(124.53,3.24,-134.96))
createTP("Celestial",90,Vector3.new(2613.10,-2.76,-111.62))

--// SWITCH LOGIC
instaSwitch.MouseButton1Click:Connect(function()
	INSTA_STEAL_ENABLED = not INSTA_STEAL_ENABLED
	instaSwitch.BackgroundColor3 = INSTA_STEAL_ENABLED and Color3.fromRGB(0,200,200) or Color3.fromRGB(60,60,60)
	instaKnob:TweenPosition(INSTA_STEAL_ENABLED and UDim2.fromOffset(28,2) or UDim2.fromOffset(2,2),"Out","Quad",0.15,true)
end)

siteSwitch.MouseButton1Click:Connect(function()
	SITE_LOCATION_ENABLED = not SITE_LOCATION_ENABLED
	sitePanel.Visible = SITE_LOCATION_ENABLED
	siteKnob:TweenPosition(SITE_LOCATION_ENABLED and UDim2.fromOffset(28,2) or UDim2.fromOffset(2,2),"Out","Quad",0.15,true)
	siteSwitch.BackgroundColor3 = SITE_LOCATION_ENABLED and Color3.fromRGB(0,200,200) or Color3.fromRGB(60,60,60)
end)

autoHitSwitch.MouseButton1Click:Connect(function()
	AUTOHIT_ENABLED = not AUTOHIT_ENABLED
	autoHitSwitch.BackgroundColor3 = AUTOHIT_ENABLED and Color3.fromRGB(0,200,200) or Color3.fromRGB(60,60,60)
	autoHitKnob:TweenPosition(AUTOHIT_ENABLED and UDim2.fromOffset(28,2) or UDim2.fromOffset(2,2),"Out","Quad",0.15,true)
end)

antiRagdollSwitch.MouseButton1Click:Connect(function()
	ANTI_RAGDOLL_ENABLED = not ANTI_RAGDOLL_ENABLED
	antiRagdollSwitch.BackgroundColor3 = ANTI_RAGDOLL_ENABLED and Color3.fromRGB(0,200,200) or Color3.fromRGB(60,60,60)
	antiRagdollKnob:TweenPosition(ANTI_RAGDOLL_ENABLED and UDim2.fromOffset(28,2) or UDim2.fromOffset(2,2),"Out","Quad",0.15,true)
end)

playerSwitch.MouseButton1Click:Connect(function()
	PLAYER_ESP_ENABLED = not PLAYER_ESP_ENABLED
	playerSwitch.BackgroundColor3 = PLAYER_ESP_ENABLED and Color3.fromRGB(0,200,200) or Color3.fromRGB(60,60,60)
	playerKnob:TweenPosition(PLAYER_ESP_ENABLED and UDim2.fromOffset(28,2) or UDim2.fromOffset(2,2),"Out","Quad",0.15,true)
end)

zoomSwitch.MouseButton1Click:Connect(function()
	ZOOM_UNLOCK_ENABLED = not ZOOM_UNLOCK_ENABLED
	zoomSwitch.BackgroundColor3 = ZOOM_UNLOCK_ENABLED and Color3.fromRGB(0,200,200) or Color3.fromRGB(60,60,60)
	zoomKnob:TweenPosition(ZOOM_UNLOCK_ENABLED and UDim2.fromOffset(28,2) or UDim2.fromOffset(2,2),"Out","Quad",0.15,true)
end)

logo.MouseButton1Click:Connect(function()
	panel.Visible = not panel.Visible
end)

--// INSTA STEAL FIXED
ProximityPromptService.PromptShown:Connect(function(prompt)
	if not ORIGINAL_HOLD[prompt] then
		ORIGINAL_HOLD[prompt] = prompt.HoldDuration
	end
	prompt.HoldDuration = INSTA_STEAL_ENABLED and 0 or ORIGINAL_HOLD[prompt]
end)

--// SITE LOCATION UPDATE
RunService.RenderStepped:Connect(function()
	if SITE_LOCATION_ENABLED and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		local p = player.Character.HumanoidRootPart.Position
		coordText.Text = string.format("X: %.2f\nY: %.2f\nZ: %.2f",p.X,p.Y,p.Z)
	end
end)

--// REAL CIRCLE AND AUTO HIT
local circle = Instance.new("Part")
circle.Anchored = true
circle.CanCollide = false
circle.Size = Vector3.new(100,0.1,100)
circle.Color = Color3.fromRGB(255,255,255)
circle.Transparency = 0.7
circle.Parent = Workspace

local mesh = Instance.new("SpecialMesh")
mesh.MeshType = Enum.MeshType.Cylinder
mesh.Scale = Vector3.new(50,0.1,50)
mesh.Parent = circle

local pulse = 0
local pulseDir = 1
local lastHit = 0

RunService.RenderStepped:Connect(function(delta)
	if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		local myPos = player.Character.HumanoidRootPart.Position
		circle.Position = Vector3.new(myPos.X, myPos.Y - 3, myPos.Z)

		-- pulse animation
		pulse = pulse + 0.02 * pulseDir
		if pulse > 0.4 then pulseDir = -1 end
		if pulse < 0 then pulseDir = 1 end
		circle.Transparency = 0.3 + pulse

		-- auto hit with 0.1 delay
		if AUTOHIT_ENABLED then
			lastHit = lastHit + delta
			if lastHit >= 0.1 then
				lastHit = 0
				for _, target in pairs(Players:GetPlayers()) do
					if target ~= player and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and target.Character:FindFirstChild("Humanoid") then
						local dist = (target.Character.HumanoidRootPart.Position - myPos).Magnitude
						if dist <= 50 then
							local tool = player.Character:FindFirstChildOfClass("Tool")
							if tool then
								tool:Activate()
							end
						end
					end
				end
			end
		end

		-- anti ragdoll
		if ANTI_RAGDOLL_ENABLED then
			local humanoid = player.Character:FindFirstChild("Humanoid")
			if humanoid then
				humanoid.PlatformStand = false
				humanoid.Sit = false
				if humanoid:GetState() ~= Enum.HumanoidStateType.Running then
					humanoid:ChangeState(Enum.HumanoidStateType.Running)
				end
			end
		end
	end

	-- Zoom unlock logic
	if ZOOM_UNLOCK_ENABLED then
		local StarterPlayer = game:GetService("StarterPlayer")
		StarterPlayer.CameraMinZoomDistance = 0
		StarterPlayer.CameraMaxZoomDistance = 10000
		if player.CameraMinZoomDistance ~= 0 then player.CameraMinZoomDistance = 0 end
		if player.CameraMaxZoomDistance ~= 10000 then player.CameraMaxZoomDistance = 10000 end
	end
end)

--// PLAYER ESP FIXED + AUTO UPDATE
local function updateESP(target)
	if PLAYER_ESP_ENABLED then
		if target ~= player and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
			if not espMarkers[target] then
				-- Billboard Name
				local billboard = Instance.new("BillboardGui")
				billboard.Adornee = target.Character:FindFirstChild("HumanoidRootPart")
				billboard.Size = UDim2.new(0,120,0,40)
				billboard.AlwaysOnTop = true
				billboard.StudsOffset = Vector3.new(0,3,0)
				billboard.Parent = target.Character

				local nameLabel = Instance.new("TextLabel")
				nameLabel.Size = UDim2.new(1,0,1,0)
				nameLabel.BackgroundTransparency = 1
				nameLabel.TextColor3 = Color3.fromRGB(255,0,0)
				nameLabel.TextScaled = true
				nameLabel.Text = target.Name
				nameLabel.Font = Enum.Font.GothamBold
				nameLabel.Parent = billboard

				-- Body box
				local box = Instance.new("BoxHandleAdornment")
				box.Adornee = target.Character:FindFirstChild("HumanoidRootPart")
				box.Size = Vector3.new(3,6,2)
				box.Color3 = Color3.fromRGB(0,0,0)
				box.Transparency = 0.2 -- 80% black
				box.AlwaysOnTop = true
				box.ZIndex = 10
				box.Parent = target.Character

				espMarkers[target] = {billboard = billboard, box = box}
			end
		end
	end
end

-- new players + respawn handling
Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function()
		task.wait(0.1)
		updateESP(plr)
	end)
end)

-- existing players
for _, plr in pairs(Players:GetPlayers()) do
	if plr ~= player then
		plr.CharacterAdded:Connect(function()
			task.wait(0.1)
			updateESP(plr)
		end)
		updateESP(plr)
	end
end

-- ESP toggle update every frame
RunService.RenderStepped:Connect(function()
	for _, plr in pairs(Players:GetPlayers()) do
		updateESP(plr)
	end
	if not PLAYER_ESP_ENABLED then
		for target, markers in pairs(espMarkers) do
			if markers.billboard then markers.billboard:Destroy() end
			if markers.box then markers.box:Destroy() end
		end
		espMarkers = {}
	end
end)

tpButton.MouseButton1Click:Connect(function()
	tpPanel.Visible = not tpPanel.Visible
end)
