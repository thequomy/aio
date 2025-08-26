local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer;
local R15reanimated = false;
local AnimationActive = false;
local StopAnim = true;
local CurrentAnimConnection = nil;
local R15 = 1.0;
local EmoteSources = loadstring(game:HttpGet("https://raw.githubusercontent.com/thequomy/aio/main/list.lua"))()
local EmotesTable = {}
local LoadingQueue = {}
local LoadingPromises = {}
local PreloadedAnims = {}

local function LoadAll(animName)
	if EmotesTable[animName] then
		addToRecentlyUsed(animName)
		return EmotesTable[animName]
	end;
	if LoadingPromises[animName] then
		return LoadingPromises[animName]
	end;
	LoadingPromises[animName] = task.spawn(function()
		local url = EmoteSources[animName]
		if not url then
			LoadingPromises[animName] = nil;
			return nil
		end;
		local success, result = pcall(game.HttpGet, game, url, true)
		if not success or not result then
			LoadingPromises[animName] = nil;
			return nil
		end;
		local loaded;
		success, loaded = pcall(loadstring(result))
		if success and type(loaded) == "function" then success, loaded = pcall(loaded)end;
		if success and type(loaded) == "table" then
			for _, value in pairs(loaded) do
				if type(value) == "table" then
					EmotesTable[animName] = value;
					addToRecentlyUsed(animName)
					LoadingPromises[animName] = nil;
					return value
				end
			end
		end;
		LoadingPromises[animName] = nil;
		return nil
	end)
	return LoadingPromises[animName]
end;

local buttonConnections = {}
local FavoriteAnims = {}
local FavoritesLoaded = false;
local KeybindAnims = {}
local KeybindsLoaded = false;
local isListeningForKeybind = false;
local keybindAnimName = nil;
local ghostEnabled = false;
local ghostClone = nil;
local originalCharacter = nil;
local originalCFrame = nil;
local ghostOriginalHipHeight = nil;
local ghostOriginalSizes = {}
local ghostOriginalMotorCFrames = {}
local preservedGuis = {}
local cloneSize = 1;
local cloneWidth = 1;
local defaultWalkSpeed = 16;
local updateConnection = nil;
local function getJoints(character)
	local jointMap = {
		["Torso"] = "RootJoint",
		["Head"] = "Neck",
		["LeftUpperArm"] = "LeftShoulder",
		["RightUpperArm"] = "RightShoulder",
		["LeftUpperLeg"] = "LeftHip",
		["RightUpperLeg"] = "RightHip",
		["LeftFoot"] = "LeftAnkle",
		["RightFoot"] = "RightAnkle",
		["LeftHand"] = "LeftWrist",
		["RightHand"] = "RightWrist",
		["LeftLowerArm"] = "LeftElbow",
		["RightLowerArm"] = "RightElbow",
		["LeftLowerLeg"] = "LeftKnee",
		["RightLowerLeg"] = "RightKnee",
		["LowerTorso"] = "Root",
		["UpperTorso"] = "Waist"
	}
	local joints = {}
	for partName, jointName in pairs(jointMap) do
		local part = character:FindFirstChild(partName)
		if part then
			local joint = part:FindFirstChild(jointName)
			if joint then
				joints[partName] = joint
			end
		end
	end;
	return joints
end;
local function getClosestEmoteName(inputName)
	local bestMatch, highestSimilarity = nil, 0;
	for emoteName in pairs(EmoteSources) do
		local similarity = 0;
		local minLength = math.min(#inputName, #emoteName)
		for i = 1, minLength do
			if inputName:sub(i, i):lower() == emoteName:sub(i, i):lower() then
				similarity = similarity + 1
			end
		end;
		if similarity > highestSimilarity then
			highestSimilarity = similarity;
			bestMatch = emoteName
		end
	end;
	return bestMatch
end;
local function stopCurrentAnimation()
	AnimationActive = false;
	StopAnim = true;
	local character = Player.Character;
	if character and character:FindFirstChild("Humanoid") then
		local humanoid = character.Humanoid;
		local animator = humanoid:FindFirstChild("Animator")
		if animator then
			animator:Destroy()
		end;
		Instance.new("Animator", humanoid)
		wait(0.05)
	end;
	if character and character:FindFirstChild("Animate") then
		character.Animate.Enabled = true
	end
end;
local function beginPlayback(frames)
	if not frames or #frames == 0 then
		return
	end;
	local character = Player.Character or Player.CharacterAdded:Wait()
	local humanoid = character:FindFirstChild("Humanoid")
	if humanoid then
		local animator = humanoid:FindFirstChild("Animator")
		if animator then
			animator:Destroy()
		end
	end;
	local animate = character:FindFirstChild("Animate")
	if animate then
		animate.Enabled = false
	end;
	local elapsedTime = 0;
	local Joints = getJoints(character)
	local totalDuration = frames[#frames].Time;
	AnimationActive = true;
	StopAnim = false;
	if CurrentAnimConnection then
		CurrentAnimConnection:Disconnect()
	end;
	CurrentAnimConnection = RunService.Heartbeat:Connect(function(deltaTime)
		if not AnimationActive or StopAnim then
			AnimationActive = false;
			StopAnim = true;
			if CurrentAnimConnection then
				CurrentAnimConnection:Disconnect()
				CurrentAnimConnection = nil
			end;
			return
		end;
		local speed = math.clamp(R15, 0, 10)
		if speed == 0 then
			return
		end;
		elapsedTime = elapsedTime + deltaTime * speed;
		if elapsedTime > totalDuration then
			elapsedTime = 0
		end;
		local currentIndex = 1;
		for i = 1, #frames - 1 do
			if elapsedTime >= frames[i].Time and elapsedTime <= frames[i + 1].Time then
				currentIndex = i;
				break
			end
		end;
		local kf1, kf2 = frames[currentIndex], frames[currentIndex + 1]
		if not kf1 or not kf2 or not kf1.Time or not kf2.Time or not kf1.Data or not kf2.Data then
			return
		end;
		local alpha = math.clamp((elapsedTime - kf1.Time) / (kf2.Time - kf1.Time), 0, 1)
		for jointName, joint in pairs(Joints) do
			local cf1, cf2 = kf1.Data[jointName], kf2.Data[jointName]
			if cf1 and cf2 then
				joint.Transform = cf1:Lerp(cf2, alpha)
			elseif cf1 then
				joint.Transform = cf1
			end
		end
	end)
end;
local function preserveGuis()
	local playerGui = Player:FindFirstChildWhichIsA("PlayerGui")
	if playerGui then
		for _, gui in ipairs(playerGui:GetChildren()) do
			if gui:IsA("ScreenGui") and gui.ResetOnSpawn then
				table.insert(preservedGuis, gui)
				gui.ResetOnSpawn = false
			end
		end
	end
end;
local function restoreGuis()
	for _, gui in ipairs(preservedGuis) do
		if gui and gui.Parent then
			gui.ResetOnSpawn = true
		end
	end;
	table.clear(preservedGuis)
end;
local lastScaleUpdate = 0;
local function updateCloneScale()
	if not ghostClone then
		return
	end;
	local currentTime = tick()
	if currentTime - lastScaleUpdate < 0.1 then
		return
	end;
	lastScaleUpdate = currentTime;
	task.spawn(function()
		for part, origSize in pairs(ghostOriginalSizes) do
			if part and part:IsA("BasePart") and part.Parent then
				local isMainTorso = part.Name == "UpperTorso" or part.Name == "LowerTorso"
				part.Size = Vector3.new(origSize.X * (isMainTorso and cloneWidth or cloneSize), origSize.Y * cloneSize, origSize.Z * cloneSize)
			end
		end;
		for motor, orig in pairs(ghostOriginalMotorCFrames) do
			if motor and motor:IsA("Motor6D") then
				local c0 = orig.C0;
				local c1 = orig.C1;
				local isSideAttachment = motor.Name:find("Left") or motor.Name:find("Right")
				local newC0 = CFrame.new(c0.Position.X * (isSideAttachment and cloneWidth or cloneSize), c0.Position.Y * cloneSize, c0.Position.Z * cloneSize) * c0.Rotation;
				local newC1 = CFrame.new(c1.Position.X * cloneSize, c1.Position.Y * cloneSize, c1.Position.Z * cloneSize) * c1.Rotation;
				motor.C0 = newC0;
				motor.C1 = newC1
			end
		end;
		local ghostHumanoid = ghostClone:FindFirstChildWhichIsA("Humanoid")
		if ghostHumanoid and ghostOriginalHipHeight then
			ghostHumanoid.HipHeight = ghostOriginalHipHeight * cloneSize
		end
	end)
end;
local bodyParts = {
	"Head",
	"UpperTorso",
	"LowerTorso",
	"LeftUpperArm",
	"LeftLowerArm",
	"LeftHand",
	"RightUpperArm",
	"RightLowerArm",
	"RightHand",
	"LeftUpperLeg",
	"LeftLowerLeg",
	"LeftFoot",
	"RightUpperLeg",
	"RightLowerLeg",
	"RightFoot"
}
local function updateRagdolledParts()
	if not(ghostEnabled and originalCharacter and ghostClone) then
		return
	end;
	for _, partName in ipairs(bodyParts) do
		local originalPart, clonePart = originalCharacter:FindFirstChild(partName), ghostClone:FindFirstChild(partName)
		if originalPart and clonePart then
			originalPart.CFrame = clonePart.CFrame;
			originalPart.AssemblyLinearVelocity, originalPart.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
		end
	end
end;
local function setGhostEnabled(newState)
	ghostEnabled = newState;
	if newState then
		if not Player then
			return
		end;
		local char = Player.Character;
		if not char then
			return
		end;
		local humanoid = char:FindFirstChildWhichIsA("Humanoid")
		local root = char:FindFirstChild("HumanoidRootPart")
		if not humanoid or not root then
			return
		end;
		if ghostClone and ghostClone.Parent and originalCharacter == char then
			Player.Character = ghostClone;
			if ghostClone:FindFirstChildWhichIsA("Humanoid") then
				game.Workspace.CurrentCamera.CameraSubject = ghostClone:FindFirstChildWhichIsA("Humanoid")
			end;
			return
		end;
		originalCharacter = char;
		originalCFrame = root.CFrame;
		task.spawn(function()
			if ghostClone and ghostClone.Parent then
				ghostClone:Destroy()
				ghostClone = nil
			end;
			char.Archivable = true;
			ghostClone = char:Clone()
			char.Archivable = false;
			local originalName = char.Name;
			ghostClone.Name = originalName .. "_clone"
			local ghostHumanoid = ghostClone:FindFirstChildWhichIsA("Humanoid")
			if ghostHumanoid then
				ghostHumanoid.DisplayName = originalName .. "_clone"
				ghostOriginalHipHeight = ghostHumanoid.HipHeight;
				defaultWalkSpeed = ghostHumanoid.WalkSpeed or 16
			end;
			if not ghostClone.PrimaryPart then
				local hrp = ghostClone:FindFirstChild("HumanoidRootPart")
				if hrp then
					ghostClone.PrimaryPart = hrp
				end
			end;
			for _, part in ipairs(ghostClone:GetDescendants()) do
				if part:IsA("BasePart") then
					part.Transparency = 1
				end
			end;
			local head = ghostClone:FindFirstChild("Head")
			if head then
				for _, d in ipairs(head:GetChildren()) do
					if d:IsA("Decal") then
						d.Transparency = 1
					end
				end
			end;
			ghostOriginalSizes = {}
			ghostOriginalMotorCFrames = {}
			for _, desc in ipairs(ghostClone:GetDescendants()) do
				if desc:IsA("BasePart") then
					ghostOriginalSizes[desc] = desc.Size
				elseif desc:IsA("Motor6D") then
					ghostOriginalMotorCFrames[desc] = {
						C0 = desc.C0,
						C1 = desc.C1
					}
				end
			end;
			if cloneSize ~= 1 or cloneWidth ~= 1 then
				updateCloneScale()
			end;
			local animate = originalCharacter:FindFirstChild("Animate")
			if animate then
				animate.Disabled = true;
				animate.Parent = ghostClone
			end;
			preserveGuis()
			ghostClone.Parent = originalCharacter.Parent;
			Player.Character = ghostClone;
			if ghostHumanoid then
				game.Workspace.CurrentCamera.CameraSubject = ghostHumanoid
			end;
			restoreGuis()
			if animate then
				animate.Disabled = false
			end;
			task.spawn(function()
				if not ghostEnabled then
					return
				end;
				pcall(function()
					if ReplicatedStorage:FindFirstChild("Ragdoll") then
						ReplicatedStorage.Ragdoll:FireServer("Ball")
					elseif ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("RagdollState") then
						ReplicatedStorage.Events.RagdollState:FireServer("true")
					elseif ReplicatedStorage:FindFirstChild("_TheHatch") and ReplicatedStorage._TheHatch:FindFirstChild("Remotes") and ReplicatedStorage._TheHatch.Remotes:FindFirstChild("Despawn") then
						ReplicatedStorage._TheHatch.Remotes.Despawn:FireServer(true)
					end
				end)
				task.spawn(function()
					if not ghostEnabled then
						return
					end;
					if updateConnection then
						updateConnection:Disconnect()
					end;
					updateConnection = RunService.Heartbeat:Connect(updateRagdolledParts)
				end)
			end)
		end)
	else
		if updateConnection then
			updateConnection:Disconnect()
			updateConnection = nil
		end;
		if not originalCharacter or not ghostClone then
			return
		end;
		task.spawn(function()
			for i = 1, 2 do
				pcall(function()
					if ReplicatedStorage:FindFirstChild("Unragdoll") then
						ReplicatedStorage.Unragdoll:FireServer()
					elseif ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("RagdollState") then
						ReplicatedStorage.Events.RagdollState:FireServer("false")
					end
				end)
				RunService.Heartbeat:Wait()
			end;
			local origRoot = originalCharacter:FindFirstChild("HumanoidRootPart")
			local ghostRoot = ghostClone:FindFirstChild("HumanoidRootPart")
			local targetCFrame = ghostRoot and ghostRoot.CFrame or originalCFrame;
			local animate = ghostClone:FindFirstChild("Animate")
			if animate then
				animate.Disabled = true;
				animate.Parent = originalCharacter
			end;
			ghostClone:Destroy()
			if origRoot then
				origRoot.CFrame = targetCFrame;
				origRoot.AssemblyLinearVelocity = Vector3.zero;
				origRoot.AssemblyAngularVelocity = Vector3.zero
			end;
			local origHumanoid = originalCharacter:FindFirstChildWhichIsA("Humanoid")
			preserveGuis()
			Player.Character = originalCharacter;
			if origHumanoid then
				game.Workspace.CurrentCamera.CameraSubject = origHumanoid;
				origHumanoid.PlatformStand = false;
				origHumanoid.Sit = false;
				origHumanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
				task.wait(0.06)
				origHumanoid:ChangeState(Enum.HumanoidStateType.Running)
				for _, part in ipairs(originalCharacter:GetDescendants()) do
					if part:IsA("BasePart") then
						part.AssemblyLinearVelocity = Vector3.zero;
						part.AssemblyAngularVelocity = Vector3.zero
					end
				end;
				if origRoot then
					origRoot.CFrame = targetCFrame
				end
			end;
			restoreGuis()
			if animate then
				task.wait(0.5)
				animate.Disabled = false
			end;
			cloneSize = 1;
			cloneWidth = 1
		end)
	end
end;
local function activateR15Reanimation()
	if R15reanimated then
		return
	end;
	R15reanimated = true;
	setGhostEnabled(true)
end;
local function saveFavorites()
	return pcall(function()
		if not isfolder("AIO") then
			makefolder("AIO")
		end;
		writefile("AIO/favorites.json", HttpService:JSONEncode(FavoriteAnims))
	end)
end;
local function loadFavorites()
	if FavoritesLoaded then
		return
	end;
	local success, data = pcall(function()
		return isfile("AIO/favorites.json") and HttpService:JSONDecode(readfile("AIO/favorites.json")) or {}
	end)
	if success and data then
		FavoriteAnims = data;
		FavoritesLoaded = true
	end
end;
local function saveKeybinds()
	return pcall(function()
		if not isfolder("AIO") then
			makefolder("AIO")
		end;
		writefile("AIO/keybinds.json", HttpService:JSONEncode(KeybindAnims))
	end)
end;
local function loadKeybinds()
	if KeybindsLoaded then
		return
	end;
	local success, data = pcall(function()
		return isfile("AIO/keybinds.json") and HttpService:JSONDecode(readfile("AIO/keybinds.json")) or {}
	end)
	if success and data then
		KeybindAnims = data;
		KeybindsLoaded = true
	end
end;
local function toggleFavorite(animName)
	loadFavorites()
	if FavoriteAnims[animName] then
		FavoriteAnims[animName] = nil
	else
		FavoriteAnims[animName] = true
	end;
	saveFavorites()
end;
local function isFavorite(animName)
	loadFavorites()
	return FavoriteAnims[animName] == true
end;
local function setKeybind(animName, keyCode)
	loadKeybinds()
	for key, anim in pairs(KeybindAnims) do
		if anim == animName then
			KeybindAnims[key] = nil
		end
	end;
	if keyCode then
		KeybindAnims[keyCode.Name] = animName
	end;
	saveKeybinds()
end;

local function getKeybind(animName)
	loadKeybinds()
	for key, anim in pairs(KeybindAnims) do
		if anim == animName then
			return key
		end
	end;
	return nil
end;

local function removeKeybind(animName)
	loadKeybinds()
	for key, anim in pairs(KeybindAnims) do
		if anim == animName then
			KeybindAnims[key] = nil;
			break
		end
	end;
	saveKeybinds()
end;
local env = getgenv()

local Reanimation = {
	name = "reanim",
	gui = nil,
	animationListGui = nil,
	isOpen = false,
	isAnimationListOpen = false,
	api = env.API,
	selectedCategory = "All",
	searchText = "",
	currentValue = 1.0,
	currentPlayingAnimation = nil,
	activeAnimButtons = {},
	resetReanimationState = function(self)
		if ghostEnabled then
			setGhostEnabled(false)
		end;
		R15reanimated = false;
		AnimationActive = false;
		StopAnim = true;
		self.currentPlayingAnimation = nil;
		self.activeAnimButtons = {}
	end,
	UI = function(className, properties, parent)
		local element = Instance.new(className)
		for prop, value in pairs(properties) do
			element[prop] = value
		end;
		if parent then
			element.Parent = parent
		end;
		return element
	end,
	Corner = function(element, radius)
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, radius or 6)
		corner.Parent = element;
		return corner
	end,
	createGUI = function(self)
		if self.gui then
			self.gui:Destroy()
		end;
		local playerGui = Player:WaitForChild("PlayerGui")
		self.gui = self.UI("ScreenGui", {
			Name = "reanim",
			ResetOnSpawn = false,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			Parent = (syn and syn.protect_gui and game:GetService("CoreGui")) or playerGui
		})
		if syn and syn.protect_gui then
			syn.protect_gui(self.gui)
		end;
		local mainFrame = self.UI("Frame", {
			Name = "MainFrame",
			Size = UDim2.new(0, 280, 0, 120),
			Position = UDim2.new(0.5, -140, 0.5, -60),
			BackgroundColor3 = Color3.fromRGB(15, 15, 20),
			BackgroundTransparency = 0.3,
			Parent = self.gui
		})
		self.Corner(mainFrame, 12)
		local gradient = Instance.new("UIGradient", mainFrame)
		gradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(70, 20, 20)),
			ColorSequenceKeypoint.new(0.25, Color3.fromRGB(140, 40, 40)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200, 60, 60)),
			ColorSequenceKeypoint.new(0.75, Color3.fromRGB(140, 40, 40)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 20, 20))
		})
		gradient.Rotation = 45;
		task.spawn(function()
			while mainFrame.Parent do
				for i = 0, 360, 2 do
					if not mainFrame.Parent then
						break
					end;
					gradient.Rotation = i;
					task.wait(0.05)
				end
			end
		end)
		local topBar = self.UI("Frame", {
			Name = "TopBar",
			Size = UDim2.new(1, -2, 0, 40),
			Position = UDim2.new(0, 1, 0, 0),
			BackgroundTransparency = 1,
			Parent = mainFrame
		})
		local titleLabel = self.UI("TextLabel", {
			Size = UDim2.new(1, -50, 0, 40),
			Position = UDim2.new(0, -55, 0, 0),
			TextXAlignment = Enum.TextXAlignment.Center,
			BackgroundTransparency = 1,
			Text = "AL REANIM",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 20,
			Font = Enum.Font.GothamBold,
			Parent = topBar
		})
		local titleGradient = Instance.new("UIGradient", titleLabel)
		titleGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(0.4, Color3.fromRGB(250, 135, 135)),
			ColorSequenceKeypoint.new(0.6, Color3.fromRGB(250, 135, 135)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
		})
		titleGradient.Rotation = 15;
		RunService.Heartbeat:Connect(function()
			local t = tick() * 1;
			titleGradient.Offset = Vector2.new(math.sin(t) * 0.3, 0)
		end)
		local closeButton = self.UI("TextButton", {
			Size = UDim2.new(0, 30, 0, 30),
			Position = UDim2.new(1, -10, 0, 5),
			AnchorPoint = Vector2.new(1, 0),
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 1,
			Text = "×",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			Font = Enum.Font.GothamBold,
			TextSize = 25,
			Parent = topBar
		})
		self.Corner(closeButton, 6)
		local minimizeButton = self.UI("TextButton", {
			Size = UDim2.new(0, 30, 0, 30),
			Position = UDim2.new(1, -45, 0, 5),
			AnchorPoint = Vector2.new(1, 0),
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 1,
			Text = "−",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			Font = Enum.Font.GothamBold,
			TextSize = 24,
			Parent = topBar
		})
		self.Corner(minimizeButton, 6)
		local contentContainer = self.UI("Frame", {
			Name = "ContentContainer",
			Size = UDim2.new(1, 0, 1, -40),
			Position = UDim2.new(0, 0, 0, 40),
			BackgroundTransparency = 1,
			Parent = mainFrame
		})
		local reanimationLabel = self.UI("TextLabel", {
			Size = UDim2.new(0, 150, 0, 25),
			Position = UDim2.new(0, 10, 0, 5),
			BackgroundTransparency = 1,
			Text = "Enable Reanimation",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 14,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = contentContainer
		})
		local reanimationToggle = self.UI("Frame", {
			Name = "ReanimationToggle",
			Size = UDim2.new(0, 50, 0, 25),
			Position = UDim2.new(1, -60, 0, 5),
			BackgroundColor3 = Color3.fromRGB(60, 60, 60),
			BackgroundTransparency = 0.3,
			Parent = contentContainer
		})
		self.Corner(reanimationToggle, 12)
		local reanimationKnob = self.UI("Frame", {
			Name = "Knob",
			Size = UDim2.new(0, 21, 0, 21),
			Position = UDim2.new(0, 2, 0, 2),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Parent = reanimationToggle
		})
		self.Corner(reanimationKnob, 10)
		local animationListLabel = self.UI("TextLabel", {
			Size = UDim2.new(0, 150, 0, 25),
			Position = UDim2.new(0, 10, 0, 35),
			BackgroundTransparency = 1,
			Text = "Animation List",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 14,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = contentContainer
		})
		local animationListToggle = self.UI("Frame", {
			Name = "AnimationListToggle",
			Size = UDim2.new(0, 50, 0, 25),
			Position = UDim2.new(1, -60, 0, 35),
			BackgroundColor3 = Color3.fromRGB(60, 60, 60),
			BackgroundTransparency = 0.3,
			Parent = contentContainer
		})
		self.Corner(animationListToggle, 12)
		local animationListKnob = self.UI("Frame", {
			Name = "Knob",
			Size = UDim2.new(0, 21, 0, 21),
			Position = UDim2.new(0, 2, 0, 2),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Parent = animationListToggle
		})
		self.Corner(animationListKnob, 10)
		local credits = self.UI("TextLabel", {
			Name = "credits",
			Size = UDim2.new(1, -20, -0.1, 15),
			Position = UDim2.new(0, 10, 0, 65),
			BackgroundTransparency = 1,
			Text = "discord.gg/akadmin",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 14,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Center,
			Parent = contentContainer
		})
		local creditsGradient = Instance.new("UIGradient", credits)
		creditsGradient.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 69, 0)),
			ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 140, 0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 215, 0)),
			ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 140, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 69, 0))
		}
		TweenService:Create(creditsGradient, TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {
			Rotation = 360
		}):Play()
		self.mainFrame = mainFrame;
		self.topBar = topBar;
		self.contentContainer = contentContainer;
		self.closeButton = closeButton;
		self.minimizeButton = minimizeButton;
		self.reanimationToggle = reanimationToggle;
		self.reanimationKnob = reanimationKnob;
		self.animationListToggle = animationListToggle;
		self.animationListKnob = animationListKnob;
		self:setupEvents()
		self:makeDraggable()
		if self.api then
			self.api:addToActive("reanim_gui", self.gui)
		end
	end,
	createAnimationListGUI = function(self)
		if self.animationListGui then
			self.animationListGui:Destroy()
		end;
		local playerGui = Player:WaitForChild("PlayerGui")
		self.animationListGui = self.UI("ScreenGui", {
			Name = "listanim",
			ResetOnSpawn = false,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			Parent = (syn and syn.protect_gui and game:GetService("CoreGui")) or playerGui
		})
		if syn and syn.protect_gui then
			syn.protect_gui(self.animationListGui)
		end;
		local animListFrame = self.UI("Frame", {
			Name = "AnimListFrame",
			Size = UDim2.new(0, 300, 0, 420),
			Position = UDim2.new(0.5, 150, 0.5, -210),
			BackgroundColor3 = Color3.fromRGB(15, 15, 20),
			BackgroundTransparency = 0.3,
			Parent = self.animationListGui
		})
		self.Corner(animListFrame, 12)
		local animGradient = Instance.new("UIGradient", animListFrame)
		animGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(70, 20, 20)),
			ColorSequenceKeypoint.new(0.25, Color3.fromRGB(140, 40, 40)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200, 60, 60)),
			ColorSequenceKeypoint.new(0.75, Color3.fromRGB(140, 40, 40)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 20, 20))
		})
		animGradient.Rotation = 45;
		task.spawn(function()
			while animListFrame.Parent do
				for i = 0, 360, 2 do
					if not animListFrame.Parent then
						break
					end;
					animGradient.Rotation = i;
					task.wait(0.05)
				end
			end
		end)
		local animTopBar = self.UI("Frame", {
			Name = "AnimTopBar",
			Size = UDim2.new(1, -2, 0, 40),
			Position = UDim2.new(0, 1, 0, 0),
			BackgroundTransparency = 1,
			Parent = animListFrame
		})
		local animTitleLabel = self.UI("TextLabel", {
			Size = UDim2.new(1, 0, 0, 40),
			Position = UDim2.new(0, 0, 0, 0),
			TextXAlignment = Enum.TextXAlignment.Center,
			BackgroundTransparency = 1,
			Text = "Animations",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 20,
			Font = Enum.Font.GothamBold,
			Parent = animTopBar
		})
		local animContentContainer = self.UI("Frame", {
			Name = "AnimContentContainer",
			Size = UDim2.new(1, 0, 1, -40),
			Position = UDim2.new(0, 0, 0, 40),
			BackgroundTransparency = 1,
			Parent = animListFrame
		})
		local categoriesFrame = self.UI("Frame", {
			Name = "CategoriesFrame",
			Size = UDim2.new(1, -20, 0, 28),
			Position = UDim2.new(0.5, 0, 0, 5),
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = Color3.fromRGB(20, 20, 30),
			BackgroundTransparency = 1,
			Parent = animContentContainer
		})
		local allButton = self.UI("TextButton", {
			Size = UDim2.new(0.48, -2, 1, 0),
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundColor3 = Color3.fromRGB(15, 15, 20),
			BackgroundTransparency = 0.3,
			Text = "All",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			Font = Enum.Font.Gotham,
			TextSize = 12,
			Parent = categoriesFrame
		})
		self.Corner(allButton, 4)
		local favoritesButton = self.UI("TextButton", {
			Size = UDim2.new(0.48, -2, 1, 0),
			Position = UDim2.new(0.52, 0, 0, 0),
			BackgroundColor3 = Color3.fromRGB(15, 15, 20),
			BackgroundTransparency = 0.8,
			Text = "Favorites",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			Font = Enum.Font.Gotham,
			TextSize = 12,
			Parent = categoriesFrame
		})
		self.Corner(favoritesButton, 4)
		local searchBar = self.UI("TextBox", {
			Name = "SearchBar",
			Size = UDim2.new(1, -20, 0, 30),
			Position = UDim2.new(0.5, 0, 0, 38),
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = Color3.fromRGB(25, 25, 35),
			BackgroundTransparency = 0.2,
			PlaceholderText = "Search...",
			PlaceholderColor3 = Color3.fromRGB(150, 150, 150),
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 14,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Center,
			Text = "",
			ClearTextOnFocus = true,
			Parent = animContentContainer
		})
		self.Corner(searchBar, 6)
		local contentFrame = self.UI("Frame", {
			Name = "ContentFrame",
			Size = UDim2.new(1, -20, 1, -128),
			Position = UDim2.new(0, 10, 0, 73),
			BackgroundColor3 = Color3.fromRGB(20, 20, 25),
			BackgroundTransparency = 0.5,
			Parent = animContentContainer
		})
		self.Corner(contentFrame, 10)
		local scrollFrame = self.UI("ScrollingFrame", {
			Name = "AnimationsScroll",
			Size = UDim2.new(1, -10, 1, -10),
			Position = UDim2.new(0, 5, 0, 5),
			BackgroundTransparency = 1,
			ScrollBarThickness = 4,
			ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255),
			CanvasSize = UDim2.new(0, 0, 0, 0),
			Parent = contentFrame
		})
		local speedControlPanel = self.UI("Frame", {
			Name = "SpeedControlPanel",
			Size = UDim2.new(1, -20, 0, 40),
			Position = UDim2.new(0, 10, 1, -50),
			BackgroundColor3 = Color3.fromRGB(20, 20, 30),
			BackgroundTransparency = 0.5,
			Parent = animContentContainer
		})
		self.Corner(speedControlPanel, 10)
		local speedSlider = Instance.new("Frame")
		speedSlider.Name = "SpeedSlider"
		speedSlider.Size = UDim2.new(1, -20, 0, 30)
		speedSlider.Position = UDim2.new(0, 10, 0, 5)
		speedSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		speedSlider.BackgroundTransparency = 1;
		speedSlider.Parent = speedControlPanel;
		local sliderTrack = Instance.new("Frame")
		sliderTrack.Name = "Track"
		sliderTrack.Size = UDim2.new(0.7, 0, 0, 4)
		sliderTrack.Position = UDim2.new(0.15, 0, 0.5, 0)
		sliderTrack.AnchorPoint = Vector2.new(0, 0.5)
		sliderTrack.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
		sliderTrack.Parent = speedSlider;
		self.Corner(sliderTrack, 2)
		local sliderFill = Instance.new("Frame")
		sliderFill.Name = "Fill"
		sliderFill.Size = UDim2.new(0.5, 0, 1, 0)
		sliderFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		sliderFill.Parent = sliderTrack;
		self.Corner(sliderFill, 2)
		local sliderThumb = Instance.new("Frame")
		sliderThumb.Name = "Thumb"
		sliderThumb.Size = UDim2.new(0, 12, 0, 12)
		sliderThumb.Position = UDim2.new(0.5, -6, 0.5, 0)
		sliderThumb.AnchorPoint = Vector2.new(0, 0.5)
		sliderThumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		sliderThumb.Parent = sliderTrack;
		self.Corner(sliderThumb, 6)
		local speedLabel = Instance.new("TextLabel")
		speedLabel.Name = "SpeedValue"
		speedLabel.Size = UDim2.new(0, 60, 0, 20)
		speedLabel.Position = UDim2.new(1, -140, 0, -6)
		speedLabel.AnchorPoint = Vector2.new(0, 0)
		speedLabel.BackgroundTransparency = 1;
		speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		speedLabel.TextSize = 12;
		speedLabel.Font = Enum.Font.Gotham;
		speedLabel.Text = "Speed: 100%"
		speedLabel.TextXAlignment = Enum.TextXAlignment.Right;
		speedLabel.Parent = speedSlider;
		self.animListFrame = animListFrame;
		self.animTopBar = animTopBar;
		self.animContentContainer = animContentContainer;
		self.allButton = allButton;
		self.favoritesButton = favoritesButton;
		self.searchBar = searchBar;
		self.scrollFrame = scrollFrame;
		self.animSpeedSlider = speedSlider;
		self.animSpeedLabel = speedLabel;
		self.animSliderTrack = sliderTrack;
		self.animSliderFill = sliderFill;
		self.animSliderThumb = sliderThumb;
		self:Events()
		self:populateAnimations()
		self:makeAnimationListDraggable()
		if self.api then
			self.api:addToActive("reanim_animation_list_gui", self.animationListGui)
		end
	end,
	setupEvents = function(self)
		self.closeButton.MouseButton1Click:Connect(function()
			self:fullUnload()
		end)
		local isMinimized = false;
		self.minimizeButton.MouseButton1Click:Connect(function()
			isMinimized = not isMinimized;
			local newHeight = isMinimized and 40 or 120;
			TweenService:Create(self.mainFrame, TweenInfo.new(0.3), {
				Size = UDim2.new(0, 280, 0, newHeight)
			}):Play()
			if isMinimized then
				self.contentContainer.Visible = false
			else
				self.contentContainer.Visible = true
			end;
			self.minimizeButton.Text = isMinimized and "+" or "−"
		end)
		self.reanimationToggle.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				self:toggleR15()
			end
		end)
		self.animationListToggle.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				self:toggleAnimationList()
			end
		end)
		UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed then
				return
			end;
			if isListeningForKeybind and keybindAnimName then
				if input.UserInputType == Enum.UserInputType.Keyboard then
					setKeybind(keybindAnimName, input.KeyCode)
					self:updateKeybindDisplay(keybindAnimName, input.KeyCode.Name)
					isListeningForKeybind = false;
					keybindAnimName = nil
				end;
				return
			end;
			if input.UserInputType == Enum.UserInputType.Keyboard then
				loadKeybinds()
				local animName = KeybindAnims[input.KeyCode.Name]
				if animName and ghostEnabled then
					self:toggleAnimationById(animName)
				end
			end
		end)
	end,
	Events = function(self)
		self.allButton.MouseButton1Click:Connect(function()
			self:updateCategory("All")
		end)
		self.favoritesButton.MouseButton1Click:Connect(function()
			self:updateCategory("Favorites")
		end)
		self.searchBar:GetPropertyChangedSignal("Text"):Connect(function()
			self.searchText = self.searchBar.Text:lower()
			self:filterAnimations()
		end)
		local isDraggingAnimSlider = false;
		local currentValue = R15 or 1.0;
		local minValue = 0.05;
		local maxValue = 3.5;
		local defaultSpeed = 1.0;
		local function updateAnimSliderValue(value)
			value = math.clamp(value, minValue, maxValue)
			currentValue = value;
			R15 = value;
			local normalized = (value - minValue) / (maxValue - minValue)
			self.animSliderFill.Size = UDim2.new(normalized, 0, 1, 0)
			self.animSliderThumb.Position = UDim2.new(normalized, -6, 0.5, 0)
			self.animSpeedLabel.Text = string.format("Speed: %d%%", math.floor(value * 100 / defaultSpeed))
		end;
		local function animSliderInputBegan(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				isDraggingAnimSlider = true;
				local trackAbsPos = self.animSliderTrack.AbsolutePosition;
				local trackAbsSize = self.animSliderTrack.AbsoluteSize;
				local relX = math.clamp(input.Position.X - trackAbsPos.X, 0, trackAbsSize.X)
				local percentage = relX / trackAbsSize.X;
				local stepSize = defaultSpeed * 0.05;
				local rawValue = minValue + (maxValue - minValue) * percentage;
				local stepsCount = math.floor(rawValue / stepSize + 0.5)
				local value = stepsCount * stepSize;
				value = math.clamp(value, minValue, maxValue)
				updateAnimSliderValue(value)
			end
		end;
		local function animSliderInputEnded(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				isDraggingAnimSlider = false
			end
		end;
		self.animSliderTrack.InputBegan:Connect(animSliderInputBegan)
		self.animSliderThumb.InputBegan:Connect(animSliderInputBegan)
		self.animSliderTrack.InputEnded:Connect(animSliderInputEnded)
		self.animSliderThumb.InputEnded:Connect(animSliderInputEnded)
		UserInputService.InputChanged:Connect(function(input)
			if isDraggingAnimSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				local trackAbsPos = self.animSliderTrack.AbsolutePosition;
				local trackAbsSize = self.animSliderTrack.AbsoluteSize;
				local inputX = input.Position.X;
				if input.UserInputType == Enum.UserInputType.Touch and input.Position then
					inputX = input.Position.X
				end;
				local relX = math.clamp(inputX - trackAbsPos.X, 0, trackAbsSize.X)
				local percentage = relX / trackAbsSize.X;
				local stepSize = defaultSpeed * 0.05;
				local rawValue = minValue + (maxValue - minValue) * percentage;
				local stepsCount = math.floor(rawValue / stepSize + 0.5)
				local value = stepsCount * stepSize;
				value = math.clamp(value, minValue, maxValue)
				updateAnimSliderValue(value)
			end
		end)
		updateAnimSliderValue(currentValue or defaultSpeed)
	end,
	toggleAnimationList = function(self)
		if self.isAnimationListOpen then
			self:closeAnimationList()
			TweenService:Create(self.animationListKnob, TweenInfo.new(0.2), {
				Position = UDim2.new(0, 2, 0, 2)
			}):Play()
			TweenService:Create(self.animationListToggle, TweenInfo.new(0.2), {
				BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			}):Play()
		else
			self:openAnimationList()
			TweenService:Create(self.animationListKnob, TweenInfo.new(0.2), {
				Position = UDim2.new(0, 27, 0, 2)
			}):Play()
			TweenService:Create(self.animationListToggle, TweenInfo.new(0.2), {
				BackgroundColor3 = Color3.fromRGB(255, 100, 100)
			}):Play()
		end
	end,
	openAnimationList = function(self)
		if not self.animationListGui then
			self:createAnimationListGUI()
		end;
		self.isAnimationListOpen = true;
		self.animListFrame.Visible = true
	end,
	closeAnimationList = function(self)
		if not self.animationListGui then
			return
		end;
		self.isAnimationListOpen = false;
		self.animListFrame.Visible = false
	end,
	makeAnimationListDraggable = function(self)
		local dragging, dragInput, dragStart, startPos;
		local function setupDragHandlers(dragElement)
			dragElement.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true;
					dragStart = input.Position;
					startPos = self.animListFrame.Position;
					TweenService:Create(dragElement, TweenInfo.new(0.1), {
						BackgroundTransparency = dragElement.BackgroundTransparency
					}):Play()
					input.Changed:Connect(function()
						if input.UserInputState == Enum.UserInputState.End then
							dragging = false;
							TweenService:Create(dragElement, TweenInfo.new(0.2), {
								BackgroundTransparency = dragElement.BackgroundTransparency
							}):Play()
						end
					end)
				end
			end)
			dragElement.InputChanged:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
					dragInput = input
				end
			end)
		end;
		setupDragHandlers(self.animTopBar)
		UserInputService.InputChanged:Connect(function(input)
			if input == dragInput and dragging then
				local delta = input.Position - dragStart;
				self.animListFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			end
		end)
	end,
	updateKeybindDisplay = function(self, animName, keyName)
		if not self.scrollFrame then
			return
		end;
		for _, container in ipairs(self.scrollFrame:GetChildren()) do
			if container:IsA("Frame") then
				local animButton = container:FindFirstChild(animName)
				if animButton then
					local keybindButton = container:FindFirstChild("KeybindButton")
					if keybindButton then
						keybindButton.Text = keyName;
						keybindButton.TextColor3 = Color3.fromRGB(100, 255, 100)
						TweenService:Create(keybindButton, TweenInfo.new(0.3), {
							TextColor3 = Color3.fromRGB(150, 150, 150)
						}):Play()
					end;
					break
				end
			end
		end
	end,
	updateCategory = function(self, category)
		self.selectedCategory = category;
		for categoryName, button in pairs({
			["All"] = self.allButton,
			["Favorites"] = self.favoritesButton
		}) do
			if categoryName == category then
				button.BackgroundTransparency = 0.3
			else
				button.BackgroundTransparency = 0.8
			end
		end;
		task.wait(0.1)
		self:filterAnimations()
	end,
	toggleR15 = function(self)
		if ghostEnabled then
			if self.currentPlayingAnimation then
				stopCurrentAnimation()
			end;
			for animName, button in pairs(self.activeAnimButtons) do
				if button then
					button.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
				end
			end;
			self:resetReanimationState()
			TweenService:Create(self.reanimationKnob, TweenInfo.new(0.2), {
				Position = UDim2.new(0, 2, 0, 2)
			}):Play()
			TweenService:Create(self.reanimationToggle, TweenInfo.new(0.2), {
				BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			}):Play()
			task.wait(0.1)
		else
			activateR15Reanimation()
			TweenService:Create(self.reanimationKnob, TweenInfo.new(0.2), {
				Position = UDim2.new(0, 27, 0, 2)
			}):Play()
			TweenService:Create(self.reanimationToggle, TweenInfo.new(0.2), {
				BackgroundColor3 = Color3.fromRGB(255, 100, 100)
			}):Play()
		end
	end,
	toggleAnimationById = function(self, animationName)
		if not ghostEnabled then
			return
		end;
		local button = self.activeAnimButtons[animationName]
		if button then
			self:toggleAnimation(animationName, button)
		elseif EmoteSources[animationName] then
			for _, container in ipairs(self.scrollFrame:GetChildren()) do
				if container:IsA("Frame") then
					for _, child in pairs(container:GetChildren()) do
						if child:IsA("TextButton") and child.Name == animationName then
							self:toggleAnimation(animationName, child)
							return
						end
					end
				end
			end
		end
	end,
	toggleAnimation = function(self, animName, button)
		if not ghostEnabled then
			if self.api then
				self.api:Notify("AIO REANIM", "Enable Reanimation first", 2, "error")
			end;
			return
		end;
		for name, activeButton in pairs(self.activeAnimButtons) do
			if activeButton then
				activeButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
			end
		end;
		table.clear(self.activeAnimButtons)
		local isCurrentlyPlaying = self.currentPlayingAnimation == animName;
		if isCurrentlyPlaying then
			stopCurrentAnimation()
			self.currentPlayingAnimation = nil;
			button.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
		else
			if self.currentPlayingAnimation then
				stopCurrentAnimation()
			end;
			local matchedName = getClosestEmoteName(animName)
			if not matchedName then
				return
			end;
			if not EmotesTable[matchedName] then
				button.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
				task.spawn(function()
					local loadResult = LoadAll(matchedName)
					if loadResult and typeof(loadResult) == "thread" then
						task.wait()
						while LoadingPromises[matchedName] do
							task.wait(0.1)
						end
					end;
					local frames = EmotesTable[matchedName]
					if frames then
						beginPlayback(frames)
						self.currentPlayingAnimation = animName;
						button.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
						self.activeAnimButtons[animName] = button;
						Players:Chat("play_" .. matchedName)
					else
						button.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
					end
				end)
			else
				local frames = EmotesTable[matchedName]
				if frames then
					beginPlayback(frames)
					self.currentPlayingAnimation = animName;
					button.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
					self.activeAnimButtons[animName] = button;
					Players:Chat("play_" .. matchedName)
				end
			end
		end
	end,
	populateAnimations = function(self)
		self.scrollFrame:ClearAllChildren()
		local emotes = {}
		for name in pairs(EmoteSources) do
			table.insert(emotes, name)
		end;
		table.sort(emotes, function(a, b)
			return a:lower() < b:lower()
		end)
		local buttonHeight = 30;
		local buttonSpacing = 5;
		local yOffset = 5;
		for _, emoteName in ipairs(emotes) do
			local container = self.UI("Frame", {
				Name = emoteName .. "Container",
				Size = UDim2.new(1, 0, 0, buttonHeight),
				Position = UDim2.new(0, 0, 0, yOffset),
				BackgroundTransparency = 1,
				Parent = self.scrollFrame
			})
			local keybindButton = self.UI("TextButton", {
				Name = "KeybindButton",
				Size = UDim2.new(0, 35, 0, buttonHeight),
				Position = UDim2.new(0, 5, 0, 0),
				BackgroundColor3 = Color3.fromRGB(25, 25, 35),
				BackgroundTransparency = 0.8,
				TextColor3 = Color3.fromRGB(150, 150, 150),
				TextSize = 10,
				Font = Enum.Font.Gotham,
				Text = getKeybind(emoteName) or "KEY",
				Parent = container
			})
			local starButton = self.UI("TextButton", {
				Name = "StarButton",
				Size = UDim2.new(0, 22, 0, buttonHeight),
				Position = UDim2.new(0, 43, 0, 0),
				BackgroundColor3 = Color3.fromRGB(25, 25, 35),
				BackgroundTransparency = 0.8,
				TextColor3 = isFavorite(emoteName) and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(150, 150, 150),
				TextSize = 14,
				Font = Enum.Font.Gotham,
				Text = "★",
				Parent = container
			})
			local button = self.UI("TextButton", {
				Name = emoteName,
				Size = UDim2.new(1, -75, 1, 0),
				Position = UDim2.new(0, 70, 0, 0),
				BackgroundColor3 = Color3.fromRGB(30, 30, 40),
				BackgroundTransparency = 0.7,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = 14,
				Font = Enum.Font.Gotham,
				Text = emoteName,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = container
			})
			self.Corner(keybindButton, 4)
			self.Corner(starButton, 4)
			local textPadding = self.UI("UIPadding", {
				PaddingLeft = UDim.new(0, 10),
				Parent = button
			})
			self.Corner(button, 4)

			button.MouseButton1Click:Connect(function()
				self:toggleAnimation(emoteName, button)
			end)
			keybindButton.MouseButton1Click:Connect(function()
				if isListeningForKeybind then
					return
				end;
				isListeningForKeybind = true;
				keybindAnimName = emoteName;
				keybindButton.Text = "Press Key..."
				keybindButton.TextColor3 = Color3.fromRGB(255, 215, 0)
				local rightClickConnection;
				rightClickConnection = keybindButton.MouseButton2Click:Connect(function()
					removeKeybind(emoteName)
					keybindButton.Text = "KEY"
					keybindButton.TextColor3 = Color3.fromRGB(150, 150, 150)
					rightClickConnection:Disconnect()
				end)
			end)
			starButton.MouseButton1Click:Connect(function()
				toggleFavorite(emoteName)
				starButton.TextColor3 = isFavorite(emoteName) and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(150, 150, 150)
			end)
			self.activeAnimButtons[emoteName] = button;
			yOffset = yOffset + buttonHeight + buttonSpacing
		end;
		self.scrollFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset)
	end,
	filterAnimations = function(self)
		local function isAnimationInCategory(animationName, category)
			if category == "All" then
				return true
			elseif category == "Favorites" then
				return isFavorite(animationName)
			end;
			return true
		end;
		local searchText = self.searchBar.Text:lower()
		local yPos = 5;
		for _, container in ipairs(self.scrollFrame:GetChildren()) do
			if container:IsA("Frame") then
				local animationButton = nil;
				for _, child in pairs(container:GetChildren()) do
					if child:IsA("TextButton") and child.Name ~= "StarButton" and child.Name ~= "KeybindButton" then
						animationButton = child;
						break
					end
				end;
				if animationButton then
					local animationName = animationButton.Name;
					local matchesSearch = searchText == "" or animationName:lower():find(searchText)
					local matchesCategory = isAnimationInCategory(animationName, self.selectedCategory)
					if matchesSearch and matchesCategory then
						container.Visible = true;
						container.Position = UDim2.new(0, 0, 0, yPos)
						yPos = yPos + 35
					else
						container.Visible = false
					end
				end
			end
		end;
		self.scrollFrame.CanvasSize = UDim2.new(0, 0, 0, yPos)
	end,
	makeDraggable = function(self)
		local dragging, dragInput, dragStart, startPos;
		local function setupDragHandlers(dragElement)
			dragElement.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true;
					dragStart = input.Position;
					startPos = self.mainFrame.Position;
					TweenService:Create(dragElement, TweenInfo.new(0.1), {
						BackgroundTransparency = dragElement.BackgroundTransparency
					}):Play()
					input.Changed:Connect(function()
						if input.UserInputState == Enum.UserInputState.End then
							dragging = false;
							TweenService:Create(dragElement, TweenInfo.new(0.2), {
								BackgroundTransparency = dragElement.BackgroundTransparency
							}):Play()
						end
					end)
				end
			end)
			dragElement.InputChanged:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
					dragInput = input
				end
			end)
		end;
		setupDragHandlers(self.topBar)
		UserInputService.InputChanged:Connect(function(input)
			if input == dragInput and dragging then
				local delta = input.Position - dragStart;
				self.mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			end
		end)
	end,
	openGUI = function(self)
		if not self.gui then
			return
		end;
		self.isOpen = true;
		self.mainFrame.Visible = true;
		self.mainFrame.Size = UDim2.new(0, 50, 0, 50)
		self.mainFrame.Position = UDim2.new(0.5, -25, 0.5, -25)
		TweenService:Create(self.mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 280, 0, 120),
			Position = UDim2.new(0.5, -140, 0.5, -60)
		}):Play()
		task.spawn(function()
			task.wait(0.5)
			for animName in pairs(FavoriteAnims) do
				if not EmotesTable[animName] and not LoadingPromises[animName] then
					LoadAll(animName)
					task.wait(0.08)
				end
			end
		end)
	end,
	closeGUI = function(self)
		if not self.gui then
			return
		end;
		self.isOpen = false;
		self:closeAnimationList()
		TweenService:Create(self.mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
			Size = UDim2.new(0, 50, 0, 50),
			Position = UDim2.new(0.5, -25, 0.5, -25)
		}):Play()
		task.spawn(function()
			task.wait(0.3)
			self.mainFrame.Visible = false
		end)
	end,
	fullUnload = function(self)
		if AnimationActive or self.currentPlayingAnimation then
			stopCurrentAnimation()
			self.currentPlayingAnimation = nil
		end;
		if ghostEnabled then
			setGhostEnabled(false)
			R15reanimated = false
		end;
		if CurrentAnimConnection then
			CurrentAnimConnection:Disconnect()
			CurrentAnimConnection = nil
		end;
		if updateConnection then
			updateConnection:Disconnect()
			updateConnection = nil
		end;
		for _, conn in ipairs(buttonConnections) do
			if conn and typeof(conn) == "RBXScriptConnection" then
				conn:Disconnect()
			end
		end;
		self.currentPlayingAnimation = nil;
		self.activeAnimButtons = {}
		EmotesTable = {}
		LoadingQueue = {}
		LoadingPromises = {}
		ghostOriginalSizes = {}
		ghostOriginalMotorCFrames = {}
		table.clear(preservedGuis)
		cloneSize = 1;
		cloneWidth = 1;
		AnimationActive = false;
		StopAnim = true;
		isListeningForKeybind = false;
		keybindAnimName = nil;
		if self.gui then
			self.gui:Destroy()
			self.gui = nil
		end;
		if self.animationListGui then
			self.animationListGui:Destroy()
			self.animationListGui = nil
		end;
		if self.api then
			self.api:removeFromActive("twistie_gui")
			self.api:removeFromActive("twistie_animation_list_gui")
		end;
		self.isOpen = false;
		self.isAnimationListOpen = false
	end,
	execute = function(self, args)
		if not self.gui then
			self:createGUI()
			self:openGUI()
		else
			if self.isOpen then
				self:closeGUI()
			else
				self:openGUI()
			end
		end
	end,
	onUnload = function(self)
		self:fullUnload()
	end
}
loadFavorites()
loadKeybinds()
local function cleanupOnExit()
	task.spawn(function()
		pcall(function()
			if AnimationActive or Reanimation.currentPlayingAnimation then
				stopCurrentAnimation()
				Reanimation.currentPlayingAnimation = nil
			end;
			if ghostEnabled then
				setGhostEnabled(false)
				R15reanimated = false
			end;
			if CurrentAnimConnection then
				CurrentAnimConnection:Disconnect()
				CurrentAnimConnection = nil
			end;
			if updateConnection then
				updateConnection:Disconnect()
				updateConnection = nil
			end;
			EmotesTable = {}
			LoadingQueue = {}
			LoadingPromises = {}
			ghostOriginalSizes = {}
			ghostOriginalMotorCFrames = {}
			table.clear(preservedGuis)
			cloneSize = 1;
			cloneWidth = 1;
			AnimationActive = false;
			StopAnim = true;
			if Reanimation.gui then
				Reanimation.gui:Destroy()
				Reanimation.gui = nil
			end
		end)
	end)
end;

pcall(function()
	if Player then
		Player.OnTeleport:Connect(cleanupOnExit)
		game.Close:Connect(cleanupOnExit)
	end
end)

local env = getgenv()
if env.API and env.API.moduleExecute then
	env.API.moduleExecute:register("twistie", function(args)
		Reanimation:execute(args)
	end)
end;

Reanimation:createGUI()
Reanimation:openGUI()
return Reanimation