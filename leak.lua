local env = getgenv()
local HttpRequest = game:GetService("HttpService")
local GamePlayers = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local GameLoop = game:GetService("RunService")
local AudioService = game:GetService("SoundService")

local leakModule = {
    name = "leak",
    gui = nil,
    isOpen = false,
    Window = {},
    API = "https://leakcheck.io/api/public?check=",
    SUCCESS = "rbxassetid://105309724097406",
    cdActive = false,

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
        if self.gui then self.gui:Destroy() end
        local screenGui = self.UI("ScreenGui", {
            Name = "Scan",
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            ResetOnSpawn = false,
            Parent = game:GetService("CoreGui")
        })

        local mFrame = self.UI("Frame", {
            Name = "mFrame",
            Size = UDim2.new(0, 300, 0, 350),
            Position = UDim2.new(0.5, -150, 0.5, -175),
            BackgroundColor3 = Color3.fromRGB(15, 15, 20),
            BackgroundTransparency = 0.3,
            BorderSizePixel = 0,
            Visible = true,
            Parent = screenGui
        })
        self.Corner(mFrame, 8)

        local titleBar = self.UI("Frame", {
            Name = "TitleBar",
            Size = UDim2.new(1, -2, 0, 30),
            Position = UDim2.new(0, 1, 0, 0),
            BackgroundTransparency = 1,
            Parent = mFrame
        })

        local titleLabel = self.UI("TextLabel", {
            Size = UDim2.new(1, -60, 0, 30),
            Position = UDim2.new(0, 10, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            Text = "Leak Scanner",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            Font = Enum.Font.GothamBold,
            Parent = titleBar
        })

        local closeButton = self.UI("TextButton", {
            Size = UDim2.new(0, 25, 0, 25),
            Position = UDim2.new(1, -5, 0, 2.5),
            AnchorPoint = Vector2.new(1, 0),
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            Text = "×",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Font = Enum.Font.GothamBold,
            TextSize = 20,
            Parent = titleBar
        })
        self.Corner(closeButton, 4)

        local minimizeButton = self.UI("TextButton", {
            Size = UDim2.new(0, 25, 0, 25),
            Position = UDim2.new(1, -35, 0, 2.5),
            AnchorPoint = Vector2.new(1, 0),
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            Text = "−",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Font = Enum.Font.GothamBold,
            TextSize = 18,
            Parent = titleBar
        })
        self.Corner(minimizeButton, 4)

        local contentContainer = self.UI("Frame", {
            Name = "ContentContainer",
            Size = UDim2.new(1, 0, 1, -30),
            Position = UDim2.new(0, 0, 0, 30),
            BackgroundTransparency = 1,
            Parent = mFrame
        })

        local contentFrame = self.UI("Frame", {
            Name = "ContentFrame",
            Size = UDim2.new(1, -10, 1, -35),
            Position = UDim2.new(0, 5, 0, 5),
            BackgroundColor3 = Color3.fromRGB(20, 20, 25),
            BackgroundTransparency = 0.5,
            Parent = contentContainer
        })
        self.Corner(contentFrame, 6)

        local scrollFrame = self.UI("ScrollingFrame", {
            Name = "PlayersScroll",
            Size = UDim2.new(1, -5, 1, -5),
            Position = UDim2.new(0, 2.5, 0, 2.5),
            BackgroundTransparency = 1,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Parent = contentFrame
        })

        local credits = self.UI("TextLabel", {
            Name = "Credits",
            Size = UDim2.new(1, -10, 0, 20),
            Position = UDim2.new(0, 5, 1, -25),
            BackgroundTransparency = 1,
            Text = "Provided by leakcheck.io",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 10,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Center,
            Parent = contentContainer
        })

        self:populatePlayers(scrollFrame)

        closeButton.MouseButton1Click:Connect(function()
            self:closeGUI()
        end)

        local isMinimized = false
        minimizeButton.MouseButton1Click:Connect(function()
            isMinimized = not isMinimized
            local newHeight = isMinimized and 30 or 350
            TweenService:Create(mFrame, TweenInfo.new(0.3), {
                Size = UDim2.new(0, 300, 0, newHeight)
            }):Play()
            if isMinimized then
                contentContainer.Visible = false
            else
                contentContainer.Visible = true
            end
            minimizeButton.Text = isMinimized and "+" or "−"
        end)

        self:makeDraggable(mFrame, titleBar)

        self.gui = screenGui
        self.mFrame = mFrame
        self.scrollFrame = scrollFrame
        self.contentContainer = contentContainer

        self:openGUI()
    end,

    populatePlayers = function(self, parent)
        for _, child in ipairs(parent:GetChildren()) do
            if child:IsA("GuiObject") then
                child:Destroy()
            end
        end

        local players = GamePlayers:GetPlayers()
        local buttonHeight = 45
        local buttonSpacing = 5
        local yOffset = 5

        for _, player in ipairs(players) do
            if player ~= GamePlayers.LocalPlayer then
                local playerButton = self.UI("TextButton", {
                    Name = player.Name,
                    Size = UDim2.new(1, -10, 0, buttonHeight),
                    Position = UDim2.new(0, 5, 0, yOffset),
                    BackgroundColor3 = Color3.fromRGB(25, 25, 35),
                    BackgroundTransparency = 0.2,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    Text = "",
                    AutoButtonColor = false,
                    Parent = parent
                })
                self.Corner(playerButton, 4)

                local playerImage = self.UI("ImageLabel", {
                    Size = UDim2.new(0, 35, 0, 35),
                    Position = UDim2.new(0, 5, 0.5, -17.5),
                    BackgroundTransparency = 1,
                    Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=420&height=420&format=png",
                    Parent = playerButton
                })
                self.Corner(playerImage, 4)

                local playerName = self.UI("TextLabel", {
                    Size = UDim2.new(1, -50, 1, 0),
                    Position = UDim2.new(0, 45, 0, 0),
                    BackgroundTransparency = 1,
                    Text = player.Name,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 12,
                    Font = Enum.Font.GothamBold,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Center,
                    Parent = playerButton
                })

                playerButton.MouseEnter:Connect(function()
                    playerButton.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
                    playerButton.BackgroundTransparency = 0.1
                end)

                playerButton.MouseLeave:Connect(function()
                    playerButton.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
                    playerButton.BackgroundTransparency = 0.2
                end)

                playerButton.MouseButton1Click:Connect(function()
                    if self.cdActive then return end

                    self.cdActive = true
                    0 = tick() + 2
                    playerButton.BackgroundColor3 = Color3.fromRGB(60, 120, 200)

                    local scanResult = self:performLeakCheck(player.Name)
                    self:showResultWindow(player, scanResult)
                    task.wait(2)
                    self.cdActive = false
                end)

                yOffset = yOffset + buttonHeight + buttonSpacing
            end
        end

        parent.CanvasSize = UDim2.new(0, 0, 0, yOffset)
    end,

    performLeakCheck = function(self, username)
        local requestSuccess, apiResponse = pcall(function()
            local requestUrl = self.API .. HttpRequest:UrlEncode(username)
            return game:HttpGet(requestUrl)
        end)

        if not requestSuccess then
            return { status = "error", text = "Network error", color = Color3.fromRGB(255, 200, 100) }
        end

        local parsedData
        local parseSuccess, parseResult = pcall(function()
            return HttpRequest:JSONDecode(apiResponse)
        end)

        if not parseSuccess then
            return { status = "error", text = "Invalid API response", color = Color3.fromRGB(255, 200, 100) }
        end

        parsedData = parseResult

        if not parsedData.success then
            return { status = "no_leaks", text = "No leaks SUCCESS", color = Color3.fromRGB(100, 255, 150) }
        end

        local leakCount = parsedData.SUCCESS or 0
        local sourceList = parsedData.sources or {}

        if leakCount > 0 then
            local alertAudio = Instance.new("Sound")
            alertAudio.SoundId = self.SUCCESS
            alertAudio.Volume = 2
            alertAudio.Parent = AudioService
            alertAudio:Play()
            alertAudio.Ended:Connect(function()
                alertAudio:Destroy()
            end)

            local leakData = {}
            for _, source in ipairs(sourceList) do
                local breach = {
                    source = source.name or "Unknown",
                    date = source.date or "Unknown date",
                    fields = source.fields or {},
                    emails = source.emails or {},
                    phones = source.phones or {},
                    passwords = source.passwords or {},
                    ips = source.ips or {},
                    domains = source.domains or {},
                    usernames = source.usernames or {},
                    hashes = source.hashes or {},
                    social = source.social or {},
                    addresses = source.addresses or {},
                    names = source.names or {}
                }
                table.insert(leakData, breach)
            end

            local statusText = leakCount .. " leaks SUCCESS"
            return { status = "leaks", text = statusText, color = Color3.fromRGB(255, 100, 100), leaks = leakData, SUCCESS = leakCount }
        else
            return { status = "no_leaks", text = "No leaks SUCCESS", color = Color3.fromRGB(100, 255, 150) }
        end
    end,

    showResultWindow = function(self, targetPlayer, scanResult)
        if self.Window[targetPlayer] then
            self.Window[targetPlayer]:Destroy()
            self.Window[targetPlayer] = nil
        end

        local resultScreenGui = self.UI("ScreenGui", {
            Name = "LeakScannerResults",
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            ResetOnSpawn = false,
            Parent = game:GetService("CoreGui")
        })

        local resultWindow = self.UI("Frame", {
            Name = "ResultWindow",
            Size = UDim2.new(0, 300, 0, 350),
            Position = UDim2.new(0.5, -150, 0.5, -175),
            BackgroundColor3 = Color3.fromRGB(15, 15, 20),
            BackgroundTransparency = 0.3,
            BorderSizePixel = 0,
            Visible = true,
            Parent = resultScreenGui
        })
        self.Corner(resultWindow, 8)

        local resultTitleBar = self.UI("Frame", {
            Name = "TitleBar",
            Size = UDim2.new(1, -2, 0, 30),
            Position = UDim2.new(0, 1, 0, 0),
            BackgroundTransparency = 1,
            Parent = resultWindow
        })

        local resultTitle = self.UI("TextLabel", {
            Size = UDim2.new(1, -35, 0, 30),
            Position = UDim2.new(0, 10, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            Text = targetPlayer.Name .. " - Scan Results",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            Font = Enum.Font.GothamBold,
            Parent = resultTitleBar
        })

        local resultCloseBtn = self.UI("TextButton", {
            Size = UDim2.new(0, 25, 0, 25),
            Position = UDim2.new(1, -5, 0, 2.5),
            AnchorPoint = Vector2.new(1, 0),
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            Text = "×",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Font = Enum.Font.GothamBold,
            TextSize = 20,
            Parent = resultTitleBar
        })
        self.Corner(resultCloseBtn, 4)

        local resultContentContainer = self.UI("Frame", {
            Name = "ContentContainer",
            Size = UDim2.new(1, 0, 1, -30),
            Position = UDim2.new(0, 0, 0, 30),
            BackgroundTransparency = 1,
            Parent = resultWindow
        })

        local resultContentFrame = self.UI("Frame", {
            Name = "ContentFrame",
            Size = UDim2.new(1, -10, 1, -35),
            Position = UDim2.new(0, 5, 0, 5),
            BackgroundColor3 = Color3.fromRGB(20, 20, 25),
            BackgroundTransparency = 0.5,
            Parent = resultContentContainer
        })
        self.Corner(resultContentFrame, 6)

        local resultScroll = self.UI("ScrollingFrame", {
            Name = "ResultsScroll",
            Size = UDim2.new(1, -5, 1, -5),
            Position = UDim2.new(0, 2.5, 0, 2.5),
            BackgroundTransparency = 1,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            BorderSizePixel = 0,
            Parent = resultContentFrame
        })

        local resultCredits = self.UI("TextLabel", {
            Name = "Credits",
            Size = UDim2.new(1, -10, 0, 20),
            Position = UDim2.new(0, 5, 1, -25),
            BackgroundTransparency = 1,
            Text = "Provided by leakcheck.io",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 10,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Center,
            Parent = resultContentContainer
        })

        local yOffset = 5

        local statusFrame = self.UI("Frame", {
            Size = UDim2.new(1, -10, 0, 35),
            Position = UDim2.new(0, 5, 0, yOffset),
            BackgroundColor3 = Color3.fromRGB(25, 25, 35),
            BackgroundTransparency = 0.2,
            BorderSizePixel = 0,
            Parent = resultScroll
        })
        self.Corner(statusFrame, 4)

        local statusLabel = self.UI("TextLabel", {
            Size = UDim2.new(1, -10, 1, 0),
            Position = UDim2.new(0, 5, 0, 0),
            BackgroundTransparency = 1,
            Text = scanResult.text,
            TextColor3 = scanResult.color,
            TextSize = 12,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center,
            Parent = statusFrame
        })

        yOffset = yOffset + 40

        if scanResult.status == "leaks" and scanResult.leaks then
            for i, breach in ipairs(scanResult.leaks) do
                local dataEntries = {}
                
                if breach.emails and #breach.emails > 0 then
                    table.insert(dataEntries, {text = "📧 Emails: " .. table.concat(breach.emails, ", "), color = Color3.fromRGB(255, 150, 150)})
                end

                if breach.passwords and #breach.passwords > 0 then
                    local passwordText = #breach.passwords > 3 and "***HIDDEN***" or table.concat(breach.passwords, ", ")
                    table.insert(dataEntries, {text = "🔑 Passwords: " .. passwordText, color = Color3.fromRGB(255, 100, 100)})
                end
                
                if breach.ips and #breach.ips > 0 then
                    table.insert(dataEntries, {text = "🌍 IPs: " .. table.concat(breach.ips, ", "), color = Color3.fromRGB(150, 255, 200)})
                end
                
                if breach.usernames and #breach.usernames > 0 then
                    table.insert(dataEntries, {text = "👤 Usernames: " .. table.concat(breach.usernames, ", "), color = Color3.fromRGB(200, 200, 255)})
                end

                if breach.social and type(breach.social) == "table" and next(breach.social) then
                    local socialLinks = {}
                    for platform, link in pairs(breach.social) do
                        table.insert(socialLinks, platform .. ": " .. link)
                    end
                    table.insert(dataEntries, {text = "📱 Social: " .. table.concat(socialLinks, ", "), color = Color3.fromRGB(150, 200, 255)})
                end
                
                if breach.domains and #breach.domains > 0 then
                    table.insert(dataEntries, {text = "🌐 Domains: " .. table.concat(breach.domains, ", "), color = Color3.fromRGB(200, 255, 200)})
                end
                local frameHeight = 30 + (#dataEntries * 18) + 5
                
                local breachFrame = self.UI("Frame", {
                    Size = UDim2.new(1, -10, 0, frameHeight),
                    Position = UDim2.new(0, 5, 0, yOffset),
                    BackgroundColor3 = Color3.fromRGB(25, 25, 35),
                    BackgroundTransparency = 0.2,
                    BorderSizePixel = 0,
                    Parent = resultScroll
                })
                self.Corner(breachFrame, 4)

                local sourceLabel = self.UI("TextLabel", {
                    Size = UDim2.new(1, -10, 0, 15),
                    Position = UDim2.new(0, 5, 0, 5),
                    BackgroundTransparency = 1,
                    Text = "🌍 " .. (breach.source or "Unknown"),
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 11,
                    Font = Enum.Font.GothamBold,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Center,
                    Parent = breachFrame
                })

                local dateLabel = self.UI("TextLabel", {
                    Size = UDim2.new(1, -10, 0, 12),
                    Position = UDim2.new(0, 5, 0, 18),
                    BackgroundTransparency = 1,
                    Text = "📅 " .. (breach.date or "Unknown"),
                    TextColor3 = Color3.fromRGB(200, 200, 200),
                    TextSize = 9,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Center,
                    Parent = breachFrame
                })

                local dataY = 32
                for _, entry in ipairs(dataEntries) do
                    local dataLabel = self.UI("TextLabel", {
                        Size = UDim2.new(1, -10, 0, 16),
                        Position = UDim2.new(0, 5, 0, dataY),
                        BackgroundTransparency = 1,
                        Text = entry.text,
                        TextColor3 = entry.color,
                        TextSize = 9,
                        Font = Enum.Font.Gotham,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Center,
                        TextWrapped = true,
                        Parent = breachFrame
                    })
                    dataY = dataY + 16
                end

                yOffset = yOffset + frameHeight + 5
            end

        elseif scanResult.status == "error" then
            local errorFrame = self.UI("Frame", {
                Size = UDim2.new(1, -10, 0, 35),
                Position = UDim2.new(0, 5, 0, yOffset),
                BackgroundColor3 = Color3.fromRGB(25, 25, 35),
                BackgroundTransparency = 0.2,
                BorderSizePixel = 0,
                Parent = resultScroll
            })
            self.Corner(errorFrame, 4)

            local errorLabel = self.UI("TextLabel", {
                Size = UDim2.new(1, -10, 1, 0),
                Position = UDim2.new(0, 5, 0, 0),
                BackgroundTransparency = 1,
                Text = "Error: " .. scanResult.text,
                TextColor3 = Color3.fromRGB(255, 200, 100),
                TextSize = 11,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Center,
                TextYAlignment = Enum.TextYAlignment.Center,
                Parent = errorFrame
            })

            yOffset = yOffset + 40
        end

        resultScroll.CanvasSize = UDim2.new(0, 0, 0, yOffset + 5)

        resultCloseBtn.MouseButton1Click:Connect(function()
            resultScreenGui:Destroy()
            self.Window[targetPlayer] = nil
        end)

        self:makeDraggable(resultWindow, resultTitleBar)
        self.Window[targetPlayer] = resultScreenGui
    end,

    makeDraggable = function(self, frame, dragHandle)
        local dragging = false
        local dragStart = nil
        local startPos = nil

        dragHandle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = frame.Position
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
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

    openGUI = function(self)
        if not self.gui then return end

        self.isOpen = true
        self.mFrame.Visible = true

        GamePlayers.PlayerAdded:Connect(function()
            self:populatePlayers(self.scrollFrame)
        end)

        GamePlayers.PlayerRemoving:Connect(function()
            self:populatePlayers(self.scrollFrame)
        end)
    end,

    closeGUI = function(self)
        if not self.gui then return end
        self.isOpen = false
        self.mFrame.Visible = false
        if self.gui then
            self.gui:Destroy()
            self.gui = nil
        end
    end
}

leakModule:createGUI()
return leakModule
