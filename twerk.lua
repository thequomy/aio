local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local env = getgenv()

local twerkModule = {
    name = "twerk",
    gui = nil,
    isOpen = false,
    api = env.API,
    
    twerkEnabled = false,
    twerkSpeed = 1.0,
    currentTrack = nil,
    originalRot = nil,
    isMinimized = false,
    isDraggingSlider = false,
    squareIcon = nil,
    
    ANIM_ID = 136720812089001,
    LOOPED = true,
    ANIM_WEIGHT = 99,
    
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
            Name = "TwerkGui",
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
            Text = "TWERK",
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

        local speedSlider = self.UI("Frame", {
            Size = UDim2.new(1, -20, 0, 25),
            Position = UDim2.new(0, 10, 0, 95),
            BackgroundColor3 = Color3.fromRGB(20, 20, 25),
            BackgroundTransparency = 0.5,
            BorderSizePixel = 0,
            Parent = main
        })
        self.Corner(speedSlider, 4)

        local speedTrack = self.UI("Frame", {
            Size = UDim2.new(1, -20, 0, 6),
            Position = UDim2.new(0, 10, 0.5, -3),
            BackgroundColor3 = Color3.fromRGB(40, 40, 50),
            BorderSizePixel = 0,
            Parent = speedSlider
        })
        self.Corner(speedTrack, 3)

        local speedFill = self.UI("Frame", {
            Size = UDim2.new(0.2, 0, 1, 0),
            BackgroundColor3 = Color3.fromRGB(100, 150, 255),
            BorderSizePixel = 0,
            Parent = speedTrack
        })
        self.Corner(speedFill, 3)

        self.gui = gui
        self.main = main
        self.toggle = toggle
        self.speedSlider = speedSlider
        self.speedTrack = speedTrack
        self.speedFill = speedFill
        self.titleBar = titleBar
        self.closeButton = closeButton
        self.minimizeButton = minimizeButton

        self:setupEvents()
        self.api:addToActive("twerk_gui", gui)
    end,
    setupEvents = function(self)
        self.isDraggingSlider = false

        self.toggle.MouseButton1Click:Connect(function()
            self:toggleTwerk()
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
            local color = self.twerkEnabled and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(25, 25, 35)
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

        self.speedSlider.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                self.isDraggingSlider = true
                local percentage = math.clamp(
                    (input.Position.X - self.speedTrack.AbsolutePosition.X) / self.speedTrack.AbsoluteSize.X,
                    0,
                    1
                )
                self:updateSpeedSlider(percentage)
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if self.isDraggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
                local percentage = math.clamp(
                    (input.Position.X - self.speedTrack.AbsolutePosition.X) / self.speedTrack.AbsoluteSize.X,
                    0,
                    1
                )
                self:updateSpeedSlider(percentage)
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

    updateSpeedSlider = function(self, percentage)
        percentage = math.clamp(percentage, 0, 1)
        self.twerkSpeed = 0.5 + percentage * 2.5
        self.speedFill.Size = UDim2.new(percentage, 0, 1, 0)
        
        if self.currentTrack then
            self.currentTrack:AdjustSpeed(self.twerkSpeed)
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
                iconLabel.Text = "T"
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
                        if not self.isDraggingSlider then
                            dragging = true
                            dragStart = input.Position
                            startPos = self.squareIcon.Position
                        end
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement and not self.isDraggingSlider then
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
            self.speedSlider.Visible = false
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
                self.speedSlider.Visible = true
                self.minimizeButton.Visible = true
                self.titleBar.Visible = true
            end)
        end
    end,
    
    loadAnimation = function(self, char)
        local humanoid = char:WaitForChild("Humanoid")
        local animator = humanoid:FindFirstChildOfClass("Animator")
        if not animator then
            animator = Instance.new("Animator")
            animator.Parent = humanoid
        end
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://" .. self.ANIM_ID
        return animator:LoadAnimation(anim)
    end,
    
    rotateCharacter = function(self, char, degrees)
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(degrees), 0)
        end
    end,
    
    startTwerk = function(self)
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            return
        end
        
        local char = LocalPlayer.Character
        local hrp = char:FindFirstChild("HumanoidRootPart")
        
        if hrp then
            self.originalRot = hrp.CFrame - hrp.Position
        end
        
        self.currentTrack = self:loadAnimation(char)
        self.currentTrack.Looped = self.LOOPED
        self.currentTrack.Priority = Enum.AnimationPriority.Action
        self.currentTrack:Play(0, self.ANIM_WEIGHT)
        self.currentTrack:AdjustSpeed(self.twerkSpeed)
        self:rotateCharacter(char, 180)
        
        self.twerkEnabled = true
        self.toggle.Text = "ON"
        TweenService:Create(self.toggle, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(80, 200, 120)
        }):Play()
    end,
    
    stopTwerk = function(self)
        if self.currentTrack then
            self.currentTrack:Stop(0)
            self.currentTrack:Destroy()
            self.currentTrack = nil
        end
        
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and self.originalRot then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(LocalPlayer.Character.HumanoidRootPart.Position) * self.originalRot
        end
        
        self.twerkEnabled = false
        self.toggle.Text = "OFF"
        TweenService:Create(self.toggle, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        }):Play()
    end,
    
    toggleTwerk = function(self)
        if self.twerkEnabled then
            self:stopTwerk()
        else
            self:startTwerk()
        end
    end,
    
    closeGUI = function(self)
        if self.twerkEnabled then
            self:stopTwerk()
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
            self:toggleTwerk()
        end
    end,
    
    onUnload = function(self)
        if self.twerkEnabled then
            self:stopTwerk()
        end
        if self.gui then
            self.gui:Destroy()
        end
    end
}

twerkModule:createGUI()
return twerkModule
