-- Loader for Hexa Hub
local Loader = {}

-- Configuration
Loader.ScriptName = "Hexa Hub"
Loader.Version = "V3.0"
Loader.Author = "kn4ght"
Loader.Discord = "https://discord.gg/rKEJtwEMUd"

-- Your Script URLs (UPDATED)
Loader.ScriptURL = "https://rblxscripts-getscripts.base44.app/functions/loaderScript?post_id=6a75f4202b690aa2ef545062"
Loader.ScriptURL2 = "https://rblxscripts-getscripts.base44.app/functions/loaderScript?post_id=6a75f4202b690aa2ef545062"

-- Supported Game IDs
Loader.SupportedGames = {
    ["6035872082"] = "Kn4ght Rivals",
    ["2404080894"] = "Funky Friday",
}

-- UI Setup
Loader.Window = nil
Loader.Tabs = {}
Loader.Notifications = {}
Loader.ConfirmChoice = nil

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local NotificationService = game:GetService("NotificationService") or game:GetService("StarterGui")

-- Roblox Notification function
local function showRobloxNotification(title, text, icon, duration)
    pcall(function()
        if game:GetService("NotificationService") then
            game:GetService("NotificationService"):SetNotificationText(
                text,
                title or "Hexa Hub",
                icon or "",
                duration or 5
            )
        end
    end)
    
    pcall(function()
        if Players.LocalPlayer then
            local gui = Players.LocalPlayer:WaitForChild("PlayerGui")
            if gui then
                local notification = Instance.new("ScreenGui")
                notification.Name = "RobloxNotification"
                notification.Parent = gui
                
                local frame = Instance.new("Frame")
                frame.Size = UDim2.new(0, 400, 0, 100)
                frame.Position = UDim2.new(0.5, -200, 0, 50)
                frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
                frame.BorderSizePixel = 0
                frame.BackgroundTransparency = 0.1
                frame.Parent = notification
                
                local corner = Instance.new("UICorner")
                corner.CornerRadius = UDim.new(0, 8)
                corner.Parent = frame
                
                local titleLabel = Instance.new("TextLabel")
                titleLabel.Size = UDim2.new(1, -20, 0, 30)
                titleLabel.Position = UDim2.new(0, 10, 0, 5)
                titleLabel.BackgroundTransparency = 1
                titleLabel.Text = title or "Hexa Hub"
                titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                titleLabel.TextSize = 16
                titleLabel.TextXAlignment = Enum.TextXAlignment.Left
                titleLabel.Font = Enum.Font.GothamBold
                titleLabel.Parent = frame
                
                local textLabel = Instance.new("TextLabel")
                textLabel.Size = UDim2.new(1, -20, 0, 50)
                textLabel.Position = UDim2.new(0, 10, 0, 35)
                textLabel.BackgroundTransparency = 1
                textLabel.Text = text or "Welcome to Hexa Hub!"
                textLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
                textLabel.TextSize = 14
                textLabel.TextXAlignment = Enum.TextXAlignment.Left
                textLabel.TextWrapped = true
                textLabel.Font = Enum.Font.Gotham
                textLabel.Parent = frame
                
                if icon then
                    local iconLabel = Instance.new("TextLabel")
                    iconLabel.Size = UDim2.new(0, 30, 0, 30)
                    iconLabel.Position = UDim2.new(1, -40, 0, 5)
                    iconLabel.BackgroundTransparency = 1
                    iconLabel.Text = icon
                    iconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                    iconLabel.TextSize = 24
                    iconLabel.Font = Enum.Font.Gotham
                    iconLabel.Parent = frame
                end
                
                task.wait(duration or 5)
                notification:Destroy()
            end
        end
    end)
end

-- Create Confirmation Dialog
local function createConfirmationDialog(callback)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ConfirmationGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer.PlayerGui
    
    -- Background
    local background = Instance.new("Frame")
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    background.BackgroundTransparency = 0.6
    background.Parent = screenGui
    
    -- Main frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 450, 0, 250)
    mainFrame.Position = UDim2.new(0.5, -225, 0.5, -125)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = background
    
    -- Corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    -- Glow effect
    local glow = Instance.new("Frame")
    glow.Size = UDim2.new(1, 10, 1, 10)
    glow.Position = UDim2.new(0, -5, 0, -5)
    glow.BackgroundColor3 = Color3.fromRGB(100, 50, 255)
    glow.BackgroundTransparency = 0.7
    glow.BorderSizePixel = 0
    glow.Parent = mainFrame
    
    local glowCorner = Instance.new("UICorner")
    glowCorner.CornerRadius = UDim.new(0, 15)
    glowCorner.Parent = glow
    
    -- Warning Icon
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(1, 0, 0, 60)
    icon.Position = UDim2.new(0, 0, 0, 15)
    icon.BackgroundTransparency = 1
    icon.Text = "⚠️"
    icon.TextColor3 = Color3.fromRGB(255, 200, 0)
    icon.TextSize = 50
    icon.Font = Enum.Font.GothamBold
    icon.Parent = mainFrame
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 80)
    title.BackgroundTransparency = 1
    title.Text = "Are you sure?"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 22
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    -- Description
    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(1, -40, 0, 40)
    desc.Position = UDim2.new(0, 20, 0, 115)
    desc.BackgroundTransparency = 1
    desc.Text = "Are you sure you want to execute this script?"
    desc.TextColor3 = Color3.fromRGB(200, 200, 220)
    desc.TextSize = 16
    desc.Font = Enum.Font.Gotham
    desc.TextWrapped = true
    desc.Parent = mainFrame
    
    -- Button Frame
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Size = UDim2.new(0.8, 0, 0, 45)
    buttonFrame.Position = UDim2.new(0.1, 0, 0, 175)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.Parent = mainFrame
    
    -- Yes Button
    local yesButton = Instance.new("TextButton")
    yesButton.Size = UDim2.new(0.45, -5, 1, 0)
    yesButton.Position = UDim2.new(0, 0, 0, 0)
    yesButton.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
    yesButton.BackgroundTransparency = 0.2
    yesButton.BorderSizePixel = 0
    yesButton.Text = "✅ Yes"
    yesButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    yesButton.TextSize = 18
    yesButton.Font = Enum.Font.GothamBold
    yesButton.Parent = buttonFrame
    
    local yesCorner = Instance.new("UICorner")
    yesCorner.CornerRadius = UDim.new(0, 6)
    yesCorner.Parent = yesButton
    
    -- No Button
    local noButton = Instance.new("TextButton")
    noButton.Size = UDim2.new(0.45, -5, 1, 0)
    noButton.Position = UDim2.new(0.55, 0, 0, 0)
    noButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    noButton.BackgroundTransparency = 0.2
    noButton.BorderSizePixel = 0
    noButton.Text = "❌ No"
    noButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    noButton.TextSize = 18
    noButton.Font = Enum.Font.GothamBold
    noButton.Parent = buttonFrame
    
    local noCorner = Instance.new("UICorner")
    noCorner.CornerRadius = UDim.new(0, 6)
    noCorner.Parent = noButton
    
    -- Hover effects
    yesButton.MouseEnter:Connect(function()
        yesButton.BackgroundTransparency = 0.1
    end)
    yesButton.MouseLeave:Connect(function()
        yesButton.BackgroundTransparency = 0.2
    end)
    
    noButton.MouseEnter:Connect(function()
        noButton.BackgroundTransparency = 0.1
    end)
    noButton.MouseLeave:Connect(function()
        noButton.BackgroundTransparency = 0.2
    end)
    
    -- Button clicks
    yesButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        if callback then
            callback(true)
        end
    end)
    
    noButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        if callback then
            callback(false)
        end
    end)
    
    -- Close on background click
    background.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        if callback then
            callback(false)
        end
    end)
    
    return screenGui
end

-- Check if current game is supported
function Loader:IsGameSupported()
    local gameId = tostring(game.GameId)
    return Loader.SupportedGames[gameId] ~= nil
end

-- Create loading screen
local function createLoadingScreen()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LoaderGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer.PlayerGui
    
    -- Background
    local background = Instance.new("Frame")
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    background.BackgroundTransparency = 0.85
    background.Parent = screenGui
    
    -- Main loading frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 500, 0, 450)
    mainFrame.Position = UDim2.new(0.5, -250, 0.5, -225)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = background
    
    -- Corner for main frame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    -- Glow effect
    local glow = Instance.new("Frame")
    glow.Size = UDim2.new(1, 10, 1, 10)
    glow.Position = UDim2.new(0, -5, 0, -5)
    glow.BackgroundColor3 = Color3.fromRGB(100, 50, 255)
    glow.BackgroundTransparency = 0.8
    glow.BorderSizePixel = 0
    glow.Parent = mainFrame
    
    -- Glow corner
    local glowCorner = Instance.new("UICorner")
    glowCorner.CornerRadius = UDim.new(0, 15)
    glowCorner.Parent = glow
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 60)
    title.Position = UDim2.new(0, 0, 0, 20)
    title.BackgroundTransparency = 1
    title.Text = "🔷 " .. Loader.ScriptName
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 28
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    -- Version
    local version = Instance.new("TextLabel")
    version.Size = UDim2.new(1, 0, 0, 25)
    version.Position = UDim2.new(0, 0, 0, 75)
    version.BackgroundTransparency = 1
    version.Text = Loader.Version .. " | by " .. Loader.Author
    version.TextColor3 = Color3.fromRGB(150, 150, 200)
    version.TextSize = 16
    version.Font = Enum.Font.Gotham
    version.Parent = mainFrame
    
    -- Game Info
    local gameInfo = Instance.new("TextLabel")
    gameInfo.Size = UDim2.new(1, 0, 0, 25)
    gameInfo.Position = UDim2.new(0, 0, 0, 100)
    gameInfo.BackgroundTransparency = 1
    gameInfo.Text = "Game: " .. (Loader.SupportedGames[tostring(game.GameId)] or "Unknown")
    gameInfo.TextColor3 = Color3.fromRGB(150, 150, 200)
    gameInfo.TextSize = 14
    gameInfo.Font = Enum.Font.Gotham
    gameInfo.Parent = mainFrame
    
    -- Progress bar background
    local progressBg = Instance.new("Frame")
    progressBg.Size = UDim2.new(0.9, 0, 0, 12)
    progressBg.Position = UDim2.new(0.05, 0, 0, 140)
    progressBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    progressBg.BorderSizePixel = 0
    progressBg.Parent = mainFrame
    
    local progressCorner = Instance.new("UICorner")
    progressCorner.CornerRadius = UDim.new(0, 6)
    progressCorner.Parent = progressBg
    
    -- Progress bar fill
    local progressFill = Instance.new("Frame")
    progressFill.Size = UDim2.new(0, 0, 1, 0)
    progressFill.BackgroundColor3 = Color3.fromRGB(100, 50, 255)
    progressFill.BorderSizePixel = 0
    progressFill.Parent = progressBg
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 6)
    fillCorner.Parent = progressFill
    
    -- Gradient for progress bar
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 50, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 50, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 50, 255))
    })
    gradient.Parent = progressFill
    
    -- Percentage text
    local percentText = Instance.new("TextLabel")
    percentText.Size = UDim2.new(1, 0, 0, 30)
    percentText.Position = UDim2.new(0, 0, 0, 160)
    percentText.BackgroundTransparency = 1
    percentText.Text = "0%"
    percentText.TextColor3 = Color3.fromRGB(255, 255, 255)
    percentText.TextSize = 18
    percentText.Font = Enum.Font.GothamBold
    percentText.Parent = mainFrame
    
    -- Status text
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, 0, 0, 30)
    status.Position = UDim2.new(0, 0, 0, 195)
    status.BackgroundTransparency = 1
    status.Text = "Initializing..."
    status.TextColor3 = Color3.fromRGB(200, 200, 220)
    status.TextSize = 14
    status.Font = Enum.Font.Gotham
    status.Parent = mainFrame
    
    -- Loading icon (spinning)
    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, 30, 0, 30)
    icon.Position = UDim2.new(0.5, -15, 0, 245)
    icon.BackgroundTransparency = 1
    icon.Image = "rbxassetid://6031094673"
    icon.ImageColor3 = Color3.fromRGB(100, 50, 255)
    icon.Parent = mainFrame
    
    -- Spinning animation
    local spinTween = TweenService:Create(
        icon,
        TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true),
        {Rotation = 360}
    )
    spinTween:Play()
    
    -- Discord invite button
    local discordButton = Instance.new("TextButton")
    discordButton.Size = UDim2.new(0.8, 0, 0, 35)
    discordButton.Position = UDim2.new(0.1, 0, 0, 300)
    discordButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    discordButton.BackgroundTransparency = 0.2
    discordButton.BorderSizePixel = 0
    discordButton.Text = "Join Discord: " .. Loader.Discord
    discordButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    discordButton.TextSize = 14
    discordButton.Font = Enum.Font.GothamBold
    discordButton.Parent = mainFrame
    
    local discordCorner = Instance.new("UICorner")
    discordCorner.CornerRadius = UDim.new(0, 6)
    discordCorner.Parent = discordButton
    
    -- Discord hover effect
    discordButton.MouseEnter:Connect(function()
        discordButton.BackgroundTransparency = 0.1
    end)
    
    discordButton.MouseLeave:Connect(function()
        discordButton.BackgroundTransparency = 0.2
    end)
    
    discordButton.MouseButton1Click:Connect(function()
        setclipboard(Loader.Discord)
        pcall(function()
            game:GetService("GuiService"):OpenBrowserWindow(Loader.Discord)
        end)
    end)
    
    -- Credits
    local credits = Instance.new("TextLabel")
    credits.Size = UDim2.new(1, 0, 0, 20)
    credits.Position = UDim2.new(0, 0, 0, 420)
    credits.BackgroundTransparency = 1
    credits.Text = "Click the Discord button to join!"
    credits.TextColor3 = Color3.fromRGB(100, 100, 150)
    credits.TextSize = 12
    credits.Font = Enum.Font.Gotham
    credits.Parent = mainFrame
    
    return {
        ScreenGui = screenGui,
        MainFrame = mainFrame,
        ProgressFill = progressFill,
        PercentText = percentText,
        Status = status,
        Icon = icon,
        DiscordButton = discordButton,
        Background = background,
        GameInfo = gameInfo
    }
end

-- Create error screen for unsupported game
local function createErrorScreen()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LoaderGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer.PlayerGui
    
    -- Background
    local background = Instance.new("Frame")
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    background.BackgroundTransparency = 0.85
    background.Parent = screenGui
    
    -- Main frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 500, 0, 350)
    mainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = background
    
    -- Corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    -- Error icon
    local errorIcon = Instance.new("TextLabel")
    errorIcon.Size = UDim2.new(1, 0, 0, 80)
    errorIcon.Position = UDim2.new(0, 0, 0, 30)
    errorIcon.BackgroundTransparency = 1
    errorIcon.Text = "❌"
    errorIcon.TextColor3 = Color3.fromRGB(255, 50, 50)
    errorIcon.TextSize = 60
    errorIcon.Font = Enum.Font.GothamBold
    errorIcon.Parent = mainFrame
    
    -- Error title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 110)
    title.BackgroundTransparency = 1
    title.Text = "Unsupported Game"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 24
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    -- Error message
    local message = Instance.new("TextLabel")
    message.Size = UDim2.new(1, 0, 0, 60)
    message.Position = UDim2.new(0, 0, 0, 150)
    message.BackgroundTransparency = 1
    message.Text = "This script is not supported in this game.\nGame ID: " .. tostring(game.GameId)
    message.TextColor3 = Color3.fromRGB(200, 200, 220)
    message.TextSize = 16
    message.Font = Enum.Font.Gotham
    message.TextWrapped = true
    message.Parent = mainFrame
    
    -- Supported games list
    local supportedText = "Supported Games:\n"
    for id, name in pairs(Loader.SupportedGames) do
        supportedText = supportedText .. "• " .. name .. " (ID: " .. id .. ")\n"
    end
    
    local supported = Instance.new("TextLabel")
    supported.Size = UDim2.new(1, 0, 0, 80)
    supported.Position = UDim2.new(0, 0, 0, 220)
    supported.BackgroundTransparency = 1
    supported.Text = supportedText
    supported.TextColor3 = Color3.fromRGB(150, 150, 200)
    supported.TextSize = 13
    supported.Font = Enum.Font.Gotham
    supported.TextWrapped = true
    supported.Parent = mainFrame
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0.3, 0, 0, 35)
    closeButton.Position = UDim2.new(0.35, 0, 0, 310)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeButton.BackgroundTransparency = 0.2
    closeButton.BorderSizePixel = 0
    closeButton.Text = "Close"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 16
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = mainFrame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeButton
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    return screenGui
end

-- Update progress
function Loader:UpdateProgress(percentage, statusText)
    if not self.UI then return end
    
    percentage = math.clamp(percentage, 0, 100)
    
    self.UI.ProgressFill:TweenSize(
        UDim2.new(percentage / 100, 0, 1, 0),
        Enum.EasingDirection.Out,
        Enum.EasingStyle.Quad,
        0.3,
        true
    )
    
    self.UI.PercentText.Text = math.floor(percentage) .. "%"
    
    if statusText then
        self.UI.Status.Text = statusText
    end
end

-- Animate progress from 1 to 100
function Loader:AnimateProgress(fromValue, toValue, duration, statusText)
    fromValue = math.clamp(fromValue, 0, 100)
    toValue = math.clamp(toValue, 0, 100)
    
    local startTime = tick()
    local endTime = startTime + duration
    local startPercent = fromValue
    local endPercent = toValue
    
    while tick() < endTime do
        local elapsed = tick() - startTime
        local progress = elapsed / duration
        
        local eased = progress < 0.5 and 2 * progress * progress or 1 - math.pow(-2 * progress + 2, 2) / 2
        
        local currentPercent = startPercent + (endPercent - startPercent) * eased
        self:UpdateProgress(currentPercent, statusText)
        
        task.wait()
    end
    
    self:UpdateProgress(endPercent, statusText)
end

-- Destroy loader with fade effect
function Loader:DestroyLoader()
    if not self.UI then return end
    
    local tween = TweenService:Create(
        self.UI.Background,
        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundTransparency = 1}
    )
    tween:Play()
    
    local frameTween = TweenService:Create(
        self.UI.MainFrame,
        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundTransparency = 1}
    )
    frameTween:Play()
    
    task.wait(0.5)
    
    if self.UI.ScreenGui then
        self.UI.ScreenGui:Destroy()
    end
    
    self.UI = nil
end

-- Finish loading and show main UI
function Loader:Finish()
    if not self.UI then return end
    
    self:AnimateProgress(85, 100, 0.5, "Loading Complete!")
    
    -- Send Roblox notification
    local gameName = Loader.SupportedGames[tostring(game.GameId)] or "Unknown Game"
    showRobloxNotification(
        "✅ Hexa Hub Loaded",
        "Successfully loaded in " .. gameName .. "!\nEnjoy the script! | Discord: " .. Loader.Discord,
        "✅",
        6
    )
    
    task.wait(0.3)
    
    self:DestroyLoader()
    self:LoadMainScript()
end

-- Load the main script
function Loader:LoadMainScript()
    local success, err = pcall(function()
        -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        -- YOUR SCRIPTS LOADSTRING (UPDATED)
        -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        
        -- Check if in Funky Friday
        if tostring(game.GameId) == "6447798030" then
            print("Loading Funky Friday scripts...")
            showRobloxNotification(
                "🎵 Funky Friday",
                "Loading Funky Friday scripts...",
                "🎵",
                3
            )
        end
        
        -- Check if in Kn4ght Rivals
        if tostring(game.GameId) == "6035872082" then
            print("Loading Kn4ght Rivals scripts...")
            showRobloxNotification(
                "⚔️ Kn4ght Rivals",
                "Loading Kn4ght Rivals scripts...",
                "⚔️",
                3
            )
        end
        
        -- YOUR UPDATED SCRIPT
        print("Loading Hexa Hub FF script...")
        showRobloxNotification(
            "🔥 Hexa Hub FF",
            "Loading Hexa Hub FF script (Updated)...",
            "🔥",
            3
        )
        loadstring(game:HttpGet(Loader.ScriptURL))()
        
        -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        -- END OF YOUR SCRIPTS
        -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        
        showRobloxNotification(
            "✅ Success",
            "Hexa Hub loaded successfully! Enjoy!",
            "✅",
            4
        )
        
        print("Hexa Hub loaded successfully!")
    end)
    
    if not success then
        warn("Failed to load main script:", err)
        showRobloxNotification(
            "❌ Error",
            "Failed to load script. Please try again.\nError: " .. tostring(err),
            "❌",
            6
        )
        if self.UI then
            self:DestroyLoader()
        end
    end
end

-- Start loading sequence
function Loader:Start()
    print("Starting Loader for " .. Loader.ScriptName)
    
    -- Show confirmation dialog first
    createConfirmationDialog(function(confirmed)
        if confirmed then
            -- User clicked Yes
            showRobloxNotification(
                "✅ Confirmed",
                "Starting " .. Loader.ScriptName .. " " .. Loader.Version,
                "✅",
                3
            )
            
            -- Check if game is supported
            if not self:IsGameSupported() then
                print("Unsupported game detected! Game ID: " .. tostring(game.GameId))
                showRobloxNotification(
                    "❌ Unsupported Game",
                    "This script is not supported in this game.\nGame ID: " .. tostring(game.GameId),
                    "❌",
                    8
                )
                createErrorScreen()
                return
            end
            
            local gameName = Loader.SupportedGames[tostring(game.GameId)]
            print("Game supported: " .. gameName)
            
            showRobloxNotification(
                "✅ Supported Game",
                "Detected: " .. gameName .. "\nLoading Hexa Hub...",
                "✅",
                3
            )
            
            -- Create UI
            self.UI = createLoadingScreen()
            
            -- Define loading steps
            local steps = {
                {progress = 10, text = "Loading UI Components..."},
                {progress = 20, text = "Initializing Modules..."},
                {progress = 30, text = "Connecting Services..."},
                {progress = 40, text = "Loading Configurations..."},
                {progress = 50, text = "Verifying Dependencies..."},
                {progress = 60, text = "Preparing Features..."},
                {progress = 70, text = "Optimizing Performance..."},
                {progress = 80, text = "Finalizing Setup..."},
                {progress = 85, text = "Almost Done..."},
            }
            
            local currentProgress = 0
            
            for _, step in ipairs(steps) do
                local duration = 0.4 + math.random() * 0.3
                self:AnimateProgress(currentProgress, step.progress, duration, step.text)
                currentProgress = step.progress
                task.wait(0.1)
            end
            
            self:Finish()
        else
            -- User clicked No
            showRobloxNotification(
                "❌ Cancelled",
                "Script execution cancelled.",
                "❌",
                3
            )
            print("Script execution cancelled by user.")
        end
    end)
end

-- Execute the loader
Loader:Start()
