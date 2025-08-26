local Players = cloneref(game:GetService("Players"))
local StarterGui = cloneref(game:GetService("StarterGui"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local uScale = function(xScale, yScale)
	local screen = workspace.CurrentCamera.ViewportSize
	return UDim2.new(0, screen.X * xScale, 0, screen.Y * (yScale or xScale))
end
local uPos = function(xScale, yScale)
	local screen = workspace.CurrentCamera.ViewportSize
	return UDim2.new(0, screen.X * xScale, 0, screen.Y * yScale)
end
local uSize = function(widthScale, heightScale)
	local screen = workspace.CurrentCamera.ViewportSize
	return UDim2.new(0, screen.X * widthScale, 0, screen.Y * (heightScale or widthScale))
end
local char = Players.LocalPlayer.Character
if char and char:FindFirstChild("Humanoid") and char.Humanoid.RigType == Enum.HumanoidRigType.R6 then
	return
end
if getgenv().CarExecuted then
	return
end
getgenv().CarExecuted = true
wait()
carstop = false
local plr = Players.LocalPlayer
local cg = cloneref(game:GetService("CoreGui"))
local runService = game:GetService("RunService")
local animData = {
	{
		id = "76503595759461",
		mult = 1
	},
	{
		id = "115245341767944",
		mult = 2
	},
	{
		id = "127805235430271",
		mult = 4
	},
	{
		id = "138003068153218",
		mult = 1
	},
	{
		id = "116772752010894",
		mult = 1
	},
	{
		id = "116625361313832",
		mult = 1
	},
	{
		id = "81388785824317",
		mult = 1
	},
	{
		id = "108747312576405",
		mult = 2
	},
	{
		id = "113181071290859",
		mult = 1
	},
	{
		id = "134681712937413",
		mult = 1
	},
	{
		id = "115260380433565",
		mult = 2
	},
	{
		id = "72382226286301",
		mult = 1
	}
}
local currentIndex = 1
local activeTrack
local activeConn
local isAnimationActive = false
local sg = Instance.new("ScreenGui", cg)
sg.ResetOnSpawn = false
sg.Name = "SillyCarUI"
mainFrame = Instance.new("Frame", sg)
mainFrame.Size = uSize(0.25, 0.4)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -140)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
mainFrame.BackgroundTransparency = 0.3
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
local corner = Instance.new("UICorner", mainFrame)
corner.CornerRadius = UDim.new(0, 12)
local shadow = Instance.new("ImageLabel", mainFrame)
shadow.Name = "Shadow"
shadow.BackgroundTransparency = 1
shadow.Size = UDim2.new(1, 10, 1, 10)
shadow.Position = UDim2.new(0, -5, 0, -5)
shadow.Image = "rbxassetid://1316045217"
shadow.ImageColor3 = Color3.new(0, 0, 0)
shadow.ImageTransparency = 0.8
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(10, 10, 118, 118)
shadow.ZIndex = -1
title = Instance.new("Frame", mainFrame)
title.Size = UDim2.new(1, -2, 0, 35)
title.Position = UDim2.new(0, 1, 0, 0)
title.BackgroundTransparency = 1
title.BorderSizePixel = 0
local titleCorner = Instance.new("UICorner", title)
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Name = "TitleCorner"
local titleText = Instance.new("TextLabel", title)
titleText.Size = UDim2.new(1, -80, 1, 0)
titleText.Position = UDim2.new(0, -140, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "Car Animations"
titleText.Font = Enum.Font.GothamBold
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.TextSize = 14
titleText.TextXAlignment = Enum.TextXAlignment.Center
minBtn = Instance.new("TextButton", title)
minBtn.Size = UDim2.new(0, 25, 0, 25)
minBtn.Position = UDim2.new(1, -38, 0, 5)
minBtn.AnchorPoint = Vector2.new(1, 0)
minBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
minBtn.BackgroundTransparency = 1
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.Text = "−"
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 20
local minCorner = Instance.new("UICorner", minBtn)
minCorner.CornerRadius = UDim.new(0, 6)
closeBtn = Instance.new("TextButton", title)
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -8, 0, 5)
closeBtn.AnchorPoint = Vector2.new(1, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
closeBtn.BackgroundTransparency = 1
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Text = "×"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 21
local closeCorner = Instance.new("UICorner", closeBtn)
closeCorner.CornerRadius = UDim.new(0, 6)
vp = Instance.new("Frame", mainFrame)
vp.Size = UDim2.new(1, -16, 1, -100)
vp.Position = UDim2.new(0, 8, 0, 42)
vp.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
vp.BackgroundTransparency = 0.5
vp.BorderSizePixel = 0
local vpCorner = Instance.new("UICorner", vp)
vpCorner.CornerRadius = UDim.new(0, 10)
local innerVp = Instance.new("ViewportFrame", vp)
innerVp.Size = UDim2.new(1, -4, 1, -4)
innerVp.Position = UDim2.new(0, 2, 0, 2)
innerVp.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
innerVp.BackgroundTransparency = 0.3
innerVp.BorderSizePixel = 0
cam = Instance.new("Camera")
cam.CameraType = Enum.CameraType.Scriptable
innerVp.CurrentCamera = cam
local buttonContainer = Instance.new("Frame", mainFrame)
buttonContainer.Size = UDim2.new(1, -16, 0, 32)
buttonContainer.Position = UDim2.new(0, 8, 1, -40)
buttonContainer.BackgroundTransparency = 1
prevBtn = Instance.new("TextButton", buttonContainer)
prevBtn.Size = UDim2.new(0, 65, 1, 0)
prevBtn.Position = UDim2.new(0, 0, 0, 0)
prevBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
prevBtn.BackgroundTransparency = 0.3
prevBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
prevBtn.Text = "◄"
prevBtn.Font = Enum.Font.Gotham
prevBtn.TextSize = 14
local prevCorner = Instance.new("UICorner", prevBtn)
prevCorner.CornerRadius = UDim.new(0, 4)
nextBtn = Instance.new("TextButton", buttonContainer)
nextBtn.Size = UDim2.new(0, 65, 1, 0)
nextBtn.Position = UDim2.new(1, -65, 0, 0)
nextBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
nextBtn.BackgroundTransparency = 0.3
nextBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
nextBtn.Text = "►"
nextBtn.Font = Enum.Font.Gotham
nextBtn.TextSize = 14
local nextCorner = Instance.new("UICorner", nextBtn)
nextCorner.CornerRadius = UDim.new(0, 4)

selectBtn = Instance.new("TextButton", mainFrame)
selectBtn.Size = UDim2.new(0.5, 0, 0, 25)
selectBtn.Position = UDim2.new(0, 120, 1, -35)
selectBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
selectBtn.BackgroundTransparency = 0.4
selectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
selectBtn.Text = "SELECT ANIMATION"
selectBtn.Font = Enum.Font.GothamBold
selectBtn.TextSize = 12
local selectCorner = Instance.new("UICorner", selectBtn)
selectCorner.CornerRadius = UDim.new(0, 6)

local function setupButtonHover(button)
	button.MouseEnter:Connect(function()
		game:GetService("TweenService"):Create(button, TweenInfo.new(0.2), {
			TextColor3 = Color3.fromRGB(200, 200, 200)
		}):Play()
	end)
	button.MouseLeave:Connect(function()
		game:GetService("TweenService"):Create(button, TweenInfo.new(0.2), {
			TextColor3 = Color3.fromRGB(255, 255, 255)
		}):Play()
	end)
end

setupButtonHover(prevBtn)
setupButtonHover(nextBtn)
setupButtonHover(selectBtn)
setupButtonHover(minBtn)
setupButtonHover(closeBtn)
ensurePrimaryPart = function(m)
	if not m then
		return
	end
	if not m.PrimaryPart then
		local root = m:FindFirstChild("HumanoidRootPart") or m:FindFirstChildWhichIsA("BasePart")
		if root then
			m.PrimaryPart = root
		end
	end
end

realDummy = Players:CreateHumanoidModelFromUserId(9160453052)
realDummy.Parent = workspace
ensurePrimaryPart(realDummy)
repeat
	task.wait()
	ensurePrimaryPart(realDummy)
until realDummy.PrimaryPart
realDummy:SetPrimaryPartCFrame(CFrame.new(0, 0, 0))

vpDummy = realDummy:Clone()
ensurePrimaryPart(vpDummy)
vpDummy.Parent = innerVp
if vpDummy.PrimaryPart and realDummy.PrimaryPart then
	vpDummy:SetPrimaryPartCFrame(realDummy.PrimaryPart.CFrame)
end
local hrp = vpDummy:FindFirstChild("HumanoidRootPart")
if hrp then
	hrp.Transparency = 1
end

for _, part in ipairs(vpDummy:GetDescendants()) do
	if part:IsA("BasePart") then
		part.CanCollide = false
	end
end
for _, part in ipairs(realDummy:GetDescendants()) do
	if part:IsA("BasePart") then
		part.Transparency = 1
		part.CanCollide = false
	end
end

rotationAngle = 0
rotationSpeed = math.rad(30)
radius = 6
height = 3

runService.RenderStepped:Connect(function(deltaTime)
	if not realDummy.Parent or not vpDummy.Parent then
		return
	end
	for _, part in ipairs(realDummy:GetDescendants()) do
		if part:IsA("BasePart") then
			local clonePart = vpDummy:FindFirstChild(part.Name, true)
			if clonePart and part:IsDescendantOf(realDummy) then
				clonePart.CFrame = part.CFrame
			end
		end
	end
	rotationAngle = rotationAngle + rotationSpeed * deltaTime
	local x = math.sin(rotationAngle) * radius
	local z = math.cos(rotationAngle) * radius
	local targetPos = (vpDummy.PrimaryPart and vpDummy.PrimaryPart.Position) or Vector3.new(0, 1, 0)
	cam.CFrame = CFrame.new(targetPos + Vector3.new(x, height, z), targetPos)
end)

hum = realDummy:FindFirstChildWhichIsA("Humanoid")
animator = hum and (hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum))
previewAnimTrack = nil

loadAnim = function(index)
	if previewAnimTrack then
		previewAnimTrack:Stop()
		previewAnimTrack:Destroy()
	end
	local anim = Instance.new("Animation")
	anim.AnimationId = "rbxassetid://" .. animData[index].id
	if animator then
		previewAnimTrack = animator:LoadAnimation(anim)
		previewAnimTrack.Priority = Enum.AnimationPriority.Action
		previewAnimTrack.Looped = true
		previewAnimTrack:Play()
		previewAnimTrack:AdjustWeight(1)
		previewAnimTrack:AdjustSpeed(1)
	end
end
loadAnim(currentIndex)
stopAll = function()
	if activeTrack then
		activeTrack:Stop()
		activeTrack:Destroy()
		activeTrack = nil
	end
	if activeConn then
		activeConn:Disconnect()
		activeConn = nil
	end
	isAnimationActive = false
	if selectBtn then
		selectBtn.Text = "SELECT ANIMATION"
		selectBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
	end
end

playCarAnim = function(char)
	stopAll()
	local hum = char:WaitForChild("Humanoid")
	local root = char:WaitForChild("HumanoidRootPart")
	local anim = Instance.new("Animation")
	anim.AnimationId = "rbxassetid://" .. animData[currentIndex].id
	local track = hum:LoadAnimation(anim)
	activeTrack = track
	track.Priority = Enum.AnimationPriority.Action
	track:Play()
	track.Looped = true
	track:AdjustWeight(1)
	isAnimationActive = true
	workspace.CurrentCamera.CameraSubject = plr.Character:WaitForChild("Head")
	activeConn = runService.Heartbeat:Connect(function()
		local v = root.Velocity
		local speed = v.Magnitude
		if speed > 0.1 then
			local dot = root.CFrame.LookVector:Dot(v.Unit)
			track:AdjustSpeed((speed / 16) * animData[currentIndex].mult * (dot >= 0 and 1 or -1))
		else
			track:AdjustSpeed(0)
		end
	end)
end

UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then
		return
	end
	if input.KeyCode == Enum.KeyCode.K then
		sg.Enabled = not sg.Enabled
	elseif input.KeyCode == Enum.KeyCode.Left then
		currentIndex = (currentIndex - 2) % #animData + 1
		loadAnim(currentIndex)
	elseif input.KeyCode == Enum.KeyCode.Right then
		currentIndex = currentIndex % #animData + 1
		loadAnim(currentIndex)
	elseif input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.KeypadEnter then
		playCarAnim(plr.Character)
	end
end)

prevBtn.MouseButton1Click:Connect(function()
	currentIndex = (currentIndex - 2) % #animData + 1
	loadAnim(currentIndex)
end)

nextBtn.MouseButton1Click:Connect(function()
	currentIndex = currentIndex % #animData + 1
	loadAnim(currentIndex)
end)

selectBtn.MouseButton1Click:Connect(function()
	if isAnimationActive then
		stopAll()
		selectBtn.Text = "SELECT ANIMATION"
		selectBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
	else
		playCarAnim(plr.Character)
		selectBtn.Text = "STOP ANIMATION"
		selectBtn.BackgroundColor3 = Color3.fromRGB(40, 15, 15)
	end
end)

local minimized = false
minBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	local newHeight = minimized and 35 or uSize(0.25, 0.4).Y.Offset
	game:GetService("TweenService"):Create(mainFrame, TweenInfo.new(0.3), {
		Size = UDim2.new(0.25, 0, 0, newHeight)
	}):Play()
	if minimized then
		for _, child in ipairs(mainFrame:GetChildren()) do
			if child ~= title and not child:IsA("UICorner") and child.Name ~= "Shadow" then
				child.Visible = false
			end
		end
	else
		for _, child in ipairs(mainFrame:GetChildren()) do
			if not child:IsA("UICorner") then
				child.Visible = true
			end
		end
	end
	minBtn.Text = minimized and "+" or "−"
end)

closeAll = function()
	stopAll()
	sg:Destroy()
end

closeBtn.MouseButton1Click:Connect(function()
	carstop = true
	closeAll()
	getgenv().CarExecuted = false
end)

plr.CharacterAdded:Connect(function(char)
	if carstop == true then return end
	task.wait(1)
	playCarAnim(char)
	getgenv().TiltForCarLoaded = false
	wait()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/Gazer-Ha/Gaze-stuff/refs/heads/main/Tilt%20for%20car"))()
end)
