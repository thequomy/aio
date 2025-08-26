local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local env = getgenv()

local espModule = {
    name = "esp",
    gui = nil,
    isOpen = false,
    api = env.API,
    espEnabled = false,
    isMinimized = false,
    isDraggingSlider = false,
    espConnections = {},
    espBoxes = {},
    playerConnections = {},
    maxDistance = 1000,
    updateCounter = 0,
    lastUpdateTime = 0,
    
    UI = function(className, properties, parent)
        local element = Instance.new(className)
        for prop, value in pairs(properties) do
            element[prop] = value
        end
        if parent then
            element.Parent = parent
        end
        return element
    end,

    Corner = function(element, radius)
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, radius or 6)
        corner.Parent = element
        return corner
    end,
    
    createGUI = function(self)
        if self.gui then
            self.gui:Destroy()
        end

        local gui = self.UI("ScreenGui", {
            Name = "EspGui",
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            ResetOnSpawn = false,
            Parent = game:GetService("CoreGui")
        })

        local main = self.UI("Frame", {
            Size = UDim2.new(0, 280, 0, 130),
            Position = UDim2.new(0.5, -140, 0.5, -65),
            BackgroundColor3 = Color3.fromRGB(15, 15, 20),
            BackgroundTransparency = 0.3,
            BorderSizePixel = 0,
            Parent = gui
        })
        self.Corner(main, 12)

        local titleBar = self.UI("Frame", {
            Name = "TitleBar",
            Size = UDim2.new(1, -2, 0, 40),
            Position = UDim2.new(0, 1, 0, 0),
            BackgroundTransparency = 1,
            Parent = main
        })

        local title = self.UI("TextLabel", {
            Size = UDim2.new(1, -80, 0, 40),
            Position = UDim2.new(0, 15, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            Text = "ESP",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 18,
            Font = Enum.Font.GothamBold,
            Parent = titleBar
        })

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
            Parent = titleBar
        })
        self.Corner(minimizeButton, 6)
        
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
            Parent = titleBar
        })
        self.Corner(closeButton, 6)

        local toggle = self.UI("TextButton", {
            Size = UDim2.new(1, -20, 0, 35),
            Position = UDim2.new(0, 10, 0, 50),
            BackgroundColor3 = Color3.fromRGB(25, 25, 35),
            BackgroundTransparency = 0.2,
            Text = "OFF",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            Font = Enum.Font.GothamBold,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Parent = main
        })
        self.Corner(toggle, 6)

        local distanceSlider = self.UI("Frame", {
            Size = UDim2.new(1, -20, 0, 25),
            Position = UDim2.new(0, 10, 0, 95),
            BackgroundColor3 = Color3.fromRGB(20, 20, 25),
            BackgroundTransparency = 0.5,
            BorderSizePixel = 0,
            Parent = main
        })
        self.Corner(distanceSlider, 4)

        local distanceTrack = self.UI("Frame", {
            Size = UDim2.new(1, -20, 0, 6),
            Position = UDim2.new(0, 10, 0.5, -3),
            BackgroundColor3 = Color3.fromRGB(40, 40, 50),
            BorderSizePixel = 0,
            Parent = distanceSlider
        })
        self.Corner(distanceTrack, 3)

        local distanceFill = self.UI("Frame", {
            Size = UDim2.new(0.5, 0, 1, 0),
            BackgroundColor3 = Color3.fromRGB(100, 150, 255),
            BorderSizePixel = 0,
            Parent = distanceTrack
        })
        self.Corner(distanceFill, 3)

        self.gui = gui
        self.main = main
        self.toggle = toggle
        self.distanceSlider = distanceSlider
        self.distanceTrack = distanceTrack
        self.distanceFill = distanceFill
        self.titleBar = titleBar
        self.closeButton = closeButton
        self.minimizeButton = minimizeButton

        self:setupEvents()
        self.api:addToActive("esp_gui", gui)
    end,
    
    setupEvents = function(self)
        self.toggle.MouseButton1Click:Connect(function()
            self:toggleESP()
        end)

        self.toggle.MouseEnter:Connect(function()
            TweenService:Create(self.toggle, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(35, 35, 45),
                BackgroundTransparency = 0.1
            }):Play()
            
            TweenService:Create(self.toggle, TweenInfo.new(0.15), {
                TextColor3 = Color3.fromRGB(220, 220, 220)
            }):Play()
        end)

        self.toggle.MouseLeave:Connect(function()
            local color = self.espEnabled and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(25, 25, 35)
            TweenService:Create(self.toggle, TweenInfo.new(0.2), {
                BackgroundColor3 = color,
                BackgroundTransparency = 0.2
            }):Play()
            
            TweenService:Create(self.toggle, TweenInfo.new(0.2), {
                TextColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
        end)

        self.closeButton.MouseButton1Click:Connect(function()
            self:closeGUI()
        end)

        self.minimizeButton.MouseButton1Click:Connect(function()
            self:minimizeToggle()
        end)

        self.distanceSlider.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                self.isDraggingSlider = true
                local percentage = math.clamp(
                    (input.Position.X - self.distanceTrack.AbsolutePosition.X) / self.distanceTrack.AbsoluteSize.X,
                    0,
                    1
                )
                self:updateDistanceSlider(percentage)
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if self.isDraggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
                local percentage = math.clamp(
                    (input.Position.X - self.distanceTrack.AbsolutePosition.X) / self.distanceTrack.AbsoluteSize.X,
                    0,
                    1
                )
                self:updateDistanceSlider(percentage)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                self.isDraggingSlider = false
            end
        end)

        self:makeDraggable(self.main, self.titleBar)
    end,
    
    makeDraggable = function(self, frame, dragHandle)
        local dragging = false
        local dragStart = nil
        local startPos = nil

        dragHandle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and not self.isDraggingSlider then
                dragging = true
                dragStart = input.Position
                startPos = frame.Position
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement and not self.isDraggingSlider then
                local delta = input.Position - dragStart
                frame.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
    end,
    
    updateDistanceSlider = function(self, percentage)
        percentage = math.clamp(percentage, 0, 1)
        self.maxDistance = math.floor(100 + percentage * 1900)
        self.distanceFill.Size = UDim2.new(percentage, 0, 1, 0)
    end,
    
    isPlayerInCamera = function(self, player)
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            return false
        end

        local camera = Workspace.CurrentCamera
        if not camera then
            return false
        end

        local playerPosition = player.Character.HumanoidRootPart.Position
        local cameraPosition = camera.CFrame.Position
        local cameraLookVector = camera.CFrame.LookVector

        local toPlayer = (playerPosition - cameraPosition).Unit
        local dotProduct = cameraLookVector:Dot(toPlayer)

        return dotProduct > 0.2
    end,

    createESPBox = function(self, player)
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            return
        end

        if self.espBoxes[player] then
            pcall(function()
                self.espBoxes[player]:Destroy()
            end)
        end

        local espGui = self.UI("BillboardGui", {
            Name = "ESP_" .. player.Name,
            Size = UDim2.new(4, 0, 6, 0),
            StudsOffset = Vector3.new(0, 0, 0),
            AlwaysOnTop = true,
            Parent = player.Character.HumanoidRootPart
        })

        local frame = self.UI("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Parent = espGui
        })

        self.UI("UIStroke", {
            Color = Color3.fromRGB(255, 0, 0),
            Thickness = 2,
            Transparency = 0,
            Parent = frame
        })

        local nameLabel = self.UI("TextLabel", {
            Size = UDim2.new(1, 0, 0, 20),
            Position = UDim2.new(0, 0, -0.2, 0),
            BackgroundTransparency = 1,
            Text = player.Name,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            Font = Enum.Font.GothamBold,
            TextStrokeTransparency = 0,
            TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
            Parent = frame
        })

        self.espBoxes[player] = espGui
    end,
    
    removeESPBox = function(self, player)
        if self.espBoxes[player] then
            pcall(function()
                self.espBoxes[player]:Destroy()
            end)
            self.espBoxes[player] = nil
        end
    end,
    
    updateESP = function(self)
        if not self.espEnabled or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            return
        end

        local currentTime = tick()
        local playerCount = #Players:GetPlayers()
        local updateInterval = 0.1

        if playerCount > 20 then
            updateInterval = 0.3
        elseif playerCount > 10 then
            updateInterval = 0.2
        end

        if currentTime - self.lastUpdateTime < updateInterval then
            return
        end

        self.lastUpdateTime = currentTime
        local localPosition = LocalPlayer.Character.HumanoidRootPart.Position

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local distance = (player.Character.HumanoidRootPart.Position - localPosition).Magnitude
                local inCamera = self:isPlayerInCamera(player)

                if distance <= self.maxDistance and inCamera then
                    if not self.espBoxes[player] then
                        self:createESPBox(player)
                    elseif not self.espBoxes[player].Parent then
                        self:createESPBox(player)
                    end
                else
                    self:removeESPBox(player)
                end
            elseif self.espBoxes[player] then
                self:removeESPBox(player)
            end
        end
    end,
    
    startESP = function(self)
        self.espEnabled = true
        self.toggle.Text = "ON"
        TweenService:Create(self.toggle, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(80, 200, 120)
        }):Play()

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                self:createESPBox(player)
            end
        end

        self.espConnections.playerAdded = Players.PlayerAdded:Connect(function(player)
            if self.espEnabled then
                local function onCharacterAdded(character)
                    if self.espEnabled then
                        local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
                        if humanoidRootPart and self.espEnabled then
                            self:createESPBox(player)
                        end
                    end
                end

                if player.Character then
                    onCharacterAdded(player.Character)
                end

                player.CharacterAdded:Connect(onCharacterAdded)
            end
        end)

        self.espConnections.playerRemoving = Players.PlayerRemoving:Connect(function(player)
            self:removeESPBox(player)
        end)

        self.espConnections.renderStepped = RunService.RenderStepped:Connect(function()
            self:updateESP()
        end)
    end,
    
    stopESP = function(self)
        self.espEnabled = false
        self.toggle.Text = "OFF"
        TweenService:Create(self.toggle, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        }):Play()

        for player, _ in pairs(self.espBoxes) do
            self:removeESPBox(player)
        end

        for _, connection in pairs(self.espConnections) do
            if connection then
                pcall(function()
                    connection:Disconnect()
                end)
            end
        end
        self.espConnections = {}
    end,
    
    toggleESP = function(self)
        if self.espEnabled then
            self:stopESP()
        else
            self:startESP()
        end
    end,
    
    minimizeToggle = function(self)
        self.isMinimized = not self.isMinimized

        if self.isMinimized then
            if not self.squareIcon then
                self.squareIcon = Instance.new("Frame")
                self.squareIcon.Size = UDim2.new(0, 50, 0, 50)
                self.squareIcon.Position = self.main.Position
                self.squareIcon.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
                self.squareIcon.BackgroundTransparency = 0.3
                self.squareIcon.BorderSizePixel = 0
                self.squareIcon.ZIndex = 100
                self.squareIcon.Visible = false
                self.squareIcon.Parent = self.main.Parent
                self.Corner(self.squareIcon, 12)

                local iconLabel = Instance.new("TextLabel")
                iconLabel.Size = UDim2.new(1, 0, 1, 0)
                iconLabel.BackgroundTransparency = 1
                iconLabel.Text = "E"
                iconLabel.Font = Enum.Font.GothamBold
                iconLabel.TextSize = 20
                iconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                iconLabel.TextXAlignment = Enum.TextXAlignment.Center
                iconLabel.TextYAlignment = Enum.TextYAlignment.Center
                iconLabel.ZIndex = 101
                iconLabel.Parent = self.squareIcon
                
                local dragging = false
                local dragStart = nil
                local startPos = nil

                self.squareIcon.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        dragStart = input.Position
                        startPos = self.squareIcon.Position
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local delta = input.Position - dragStart
                        self.squareIcon.Position = UDim2.new(
                            startPos.X.Scale,
                            startPos.X.Offset + delta.X,
                            startPos.Y.Scale,
                            startPos.Y.Offset + delta.Y
                        )
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                
                local clickConnection
                clickConnection = self.squareIcon.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 and not dragging then
                        task.wait(0.1)
                        if not dragging then
                            self:minimizeToggle()
                        end
                    end
                end)
            end

            self.toggle.Visible = false
            self.distanceSlider.Visible = false
            self.minimizeButton.Visible = false
            self.titleBar.Visible = false

            self.squareIcon.Position = self.main.Position
            self.squareIcon.Size = self.main.Size
            self.squareIcon.Visible = true
            
            local mainTween = TweenService:Create(self.main, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 50, 0, 50)
            })

            local squareTween = TweenService:Create(self.squareIcon, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 50, 0, 50)
            })

            mainTween:Play()
            squareTween:Play()

            task.spawn(function()
                task.wait(0.4)
                self.main.Visible = false
            end)
        else
            if self.squareIcon then
                self.main.Position = self.squareIcon.Position
                self.main.Size = UDim2.new(0, 50, 0, 50)
                self.squareIcon.Visible = false
            end

            self.main.Visible = true
            local expandTween = TweenService:Create(self.main, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 280, 0, 130)
            })
            expandTween:Play()

            expandTween.Completed:Connect(function()
                self.toggle.Visible = true
                self.distanceSlider.Visible = true
                self.minimizeButton.Visible = true
                self.titleBar.Visible = true
            end)
        end
    end,
    
    closeGUI = function(self)
        if self.espEnabled then
            self:stopESP()
        end
        if self.gui then
            self.gui:Destroy()
            self.gui = nil
        end
    end,
    
    execute = function(self, args)
        if not self.gui then
            self:createGUI()
        else
            self:toggleESP()
        end
    end,
    
    onUnload = function(self)
        if self.espEnabled then
            self:stopESP()
        end
        if self.gui then
            self.gui:Destroy()
        end
    end
}

espModule:createGUI()
return espModule