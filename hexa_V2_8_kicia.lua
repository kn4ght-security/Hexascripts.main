local repo = 'https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Options = Library.Options
local Toggles = Library.Toggles

Library.ShowToggleFrameInKeybinds = true
Library.ShowCustomCursor = false
Library.NotifySide = "Left"

Library.AccentColor     = Color3.fromRGB(70, 130, 220)
Library.MainColor       = Color3.fromRGB(18, 18, 20)
Library.BackgroundColor = Color3.fromRGB(12, 12, 14)
Library.OutlineColor    = Color3.fromRGB(32, 32, 36)
Library.FontColor       = Color3.fromRGB(225, 225, 230)
Library.RiskColor       = Color3.fromRGB(220, 60, 60)

local Window = Library:CreateWindow({
    Title = 'hexa hub | https://dc.gg/hexahubscripts',
    Center = true,
    AutoShow = true,
    Resizable = true,
    ShowCustomCursor = false,
    UnlockMouseWhileOpen = true,
    TabPadding = 8,
    MenuFadeTime = 0.2,
    Size = UDim2.fromOffset(520, 400)
})

local Tabs = {
    Main = Window:AddTab('Main'),
    Combat = Window:AddTab('Combat'),
    Visual = Window:AddTab('Visual'),
    Spoofer = Window:AddTab('Spoofer'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local lplr = Players.LocalPlayer

--  LOBBY CHECK



do
    local Utility = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Utility"))

    local MechanicsController
    pcall(function()
        MechanicsController = require(lplr.PlayerScripts:WaitForChild("Controllers"):WaitForChild("MechanicsController"))
    end)

    getgenv().RagebotTriggerShoot = function(targetPlayer)
        if targetPlayer then
            getgenv().RagebotAimTarget = targetPlayer
        end
        if MechanicsController then
            pcall(function()
                MechanicsController:EquippedItemInput("StartShooting")
            end)
        end
    end
end

local AimbotFOV = {
    Enabled = false,
    Radius  = 150,
    AimToggle  = false,
    SilentToggle = false,
}

local function refreshFOVVisibility()
    AimbotFOV.Enabled = AimbotFOV.AimToggle or AimbotFOV.SilentToggle
end

local fovRenderGui = Instance.new("ScreenGui")
fovRenderGui.Name = "hexa_AimbotFOV"
fovRenderGui.ResetOnSpawn = false
fovRenderGui.IgnoreGuiInset = true
fovRenderGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
fovRenderGui.DisplayOrder = 999
pcall(function() fovRenderGui.Parent = game:GetService("CoreGui") end)
if not fovRenderGui.Parent then fovRenderGui.Parent = lplr:WaitForChild("PlayerGui") end

local fovCircle = Instance.new("Frame")
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
fovCircle.BackgroundTransparency = 1
fovCircle.Visible = false
fovCircle.Parent = fovRenderGui

local fovCircleCorner = Instance.new("UICorner")
fovCircleCorner.CornerRadius = UDim.new(0.5, 0)
fovCircleCorner.Parent = fovCircle

local fovCircleStroke = Instance.new("UIStroke")
fovCircleStroke.Color = Color3.fromRGB(70, 130, 220)
fovCircleStroke.Thickness = 1.5
fovCircleStroke.Transparency = 0.2
fovCircleStroke.Parent = fovCircle

RunService.RenderStepped:Connect(function()
    if not AimbotFOV.Enabled then
        if fovCircle.Visible then fovCircle.Visible = false end
        return
    end
    fovCircle.Visible = true
    fovCircle.Size = UDim2.fromOffset(AimbotFOV.Radius * 2, AimbotFOV.Radius * 2)
end)

local hudGui = Instance.new("ScreenGui")
hudGui.Name = "AsteroidHUD"
hudGui.ResetOnSpawn = false
hudGui.IgnoreGuiInset = true
hudGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() hudGui.Parent = game:GetService("CoreGui") end)
if not hudGui.Parent then hudGui.Parent = lplr:WaitForChild("PlayerGui") end

local container = Instance.new("Frame")
container.Name = "StatusContainer"
container.AnchorPoint = Vector2.new(0.5, 1)
container.Position = UDim2.new(0.5, 0, 1, -60)
container.Size = UDim2.fromOffset(220, 20)
container.BackgroundTransparency = 1
container.Parent = hudGui

local statusText = Instance.new("TextLabel")
statusText.AnchorPoint = Vector2.new(0.5, 0.5)
statusText.Position = UDim2.new(0.5, 0, 0.5, 0)
statusText.Size = UDim2.fromOffset(220, 16)
statusText.BackgroundTransparency = 1
statusText.Text = "Status: Idle"
statusText.Font = Enum.Font.Gotham
statusText.TextSize = 12
statusText.TextColor3 = Color3.fromRGB(220, 220, 230)
statusText.TextStrokeTransparency = 0.3
statusText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
statusText.TextXAlignment = Enum.TextXAlignment.Center
statusText.Parent = container

RunService.RenderStepped:Connect(function()
    local status = getgenv().RagebotStatusText or 'Idle'

    local manipAt   = getgenv().SilentAimManipulatedAt
    local shotFlash = manipAt ~= nil and (os.clock() - manipAt) < 0.15
    local nearEnemy = getgenv().ManipulateActive == true

    if nearEnemy or shotFlash then
        status = "Manipulating"
    end

    statusText.Text = "Status: " .. status

    if nearEnemy or shotFlash then
        statusText.TextColor3 = Color3.fromRGB(255, 100, 200)
    elseif status:find('Killing') then
        statusText.TextColor3 = Color3.fromRGB(255, 90, 90)
    elseif status:find('Anti-FF') then
        statusText.TextColor3 = Color3.fromRGB(255, 140, 0)
    elseif status:find('Anti-hit') then
        statusText.TextColor3 = Color3.fromRGB(255, 220, 80)
    elseif status:find('Waiting') then
        statusText.TextColor3 = Color3.fromRGB(255, 180, 80)
    elseif status:find('Voidspam') then
        statusText.TextColor3 = Color3.fromRGB(200, 150, 255)
    elseif status:find('Voiding') then
        statusText.TextColor3 = Color3.fromRGB(150, 150, 255)
    elseif status:find('Reloading') then
        statusText.TextColor3 = Color3.fromRGB(255, 200, 100)
    elseif status:find('Scanning') then
        statusText.TextColor3 = Color3.fromRGB(180, 180, 180)
    elseif status:find('Underground') then
        statusText.TextColor3 = Color3.fromRGB(255, 150, 50)
    elseif status:find('Anti-Katana') then
        statusText.TextColor3 = Color3.fromRGB(255, 100, 100)
    else
        statusText.TextColor3 = Color3.fromRGB(220, 220, 230)
    end
end)

local ScriptsGroup = Tabs.Main:AddLeftGroupbox('Scripts')
local AimbotGroup = Tabs.Main:AddRightGroupbox('Aimbot')

ScriptsGroup:AddButton('Fast Melee', function()
    loadstring([[
--!native
--!optimize 2
if game.GameId == 6035872082 then
    local Storage = game:GetService("ReplicatedStorage")
    local Items = require(Storage.Modules.ItemLibrary).Items
    for name, data in pairs(Items) do
        if typeof(data) == "table" then
            local isMelee = data.AttackCooldown or data.SwingCooldown or data.MeleeCooldown or data.Cooldown
            local isGun = data.ShootSpread or data.ShootAccuracy or data.ShootRecoil or data.ShootCooldown
            if isMelee and not isGun then
                if data.AttackCooldown then data.AttackCooldown = 0.001 end
                if data.SwingCooldown then data.SwingCooldown = 0.001 end
                if data.MeleeCooldown then data.MeleeCooldown = 0.001 end
                if data.Cooldown then data.Cooldown = 0.001 end
                if data.RecoveryTime then data.RecoveryTime = 0.001 end
                if data.ResetTime then data.ResetTime = 0.001 end
                if data.SwingTime then data.SwingTime = 0.05 end
                if data.HitboxDuration then data.HitboxDuration = 0.05 end
            end
        end
    end
end
]])()
    Library:Notify('Fast Melee applied', 3)
end)

ScriptsGroup:AddButton('Fast Firing', function()
    loadstring([[
--!native
--!optimize 2
if game.GameId == 6035872082 then
    local Storage = game:GetService("ReplicatedStorage")
    local Items = require(Storage.Modules.ItemLibrary).Items
    local gunExceptions = { ["Sniper"] = false, ["Crossbow"] = false, ["Bow"] = false, ["RPG"] = false }
    for name, data in pairs(Items) do
        if typeof(data) == "table" and not gunExceptions[name] then
            if data.ShootSpread then data.ShootSpread = 0 end
            if data.ShootAccuracy then data.ShootAccuracy = 0 end
            if data.ShootRecoil then data.ShootRecoil = 0 end
            if data.ShootCooldown then data.ShootCooldown = 0.001 end
            if data.ShootBurstCooldown then data.ShootBurstCooldown = 0.001 end
        end
    end
end
]])()
    Library:Notify('Fast Firing applied', 3)
end)

ScriptsGroup:AddButton('Hexa unlock all V1', function()
    loadstring(game:HttpGet("https://bestsecurity.lovable.app/api/public/l/p7HSB8BAc7?t=TIin-BRu5LGVsoKI5yGU_4Psxj2DzMrB"))()
    Library:Notify('hexa unlock all loaded loaded', 3)
end)

ScriptsGroup:AddButton('yabujin', function()
    loadstring(game:HttpGet("https://bestsecurity.lovable.app/api/public/l/IgLcRDe0Hn?t=QcYytSVGOqUifKvl15yEk_YZgnR7_iWo"))()
    Library:Notify('yabujin loaded', 3)
end)

-- aimbot.
local AimbotService = {
    Instant = false,
    Smooth = false,
    SmoothFactor = 0.3,
    CacheDuration = 0.1,
    CachedTarget = nil,
    CacheTime = 0,
}

do
    local player = lplr
    repeat task.wait() until player and player.Character
    local ctrl = player.PlayerScripts:WaitForChild("Controllers", math.huge)
    local cc = require(ctrl:WaitForChild("CameraController", math.huge))

    local function isEnemy(target)
        if target == player then return false end
        local char = target.Character
        if not char then return false end
        local hum = char:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then return false end
        local myTeam = player.Team or player:GetAttribute("Team") or player:GetAttribute("TeamID")
        local theirTeam = target.Team or target:GetAttribute("Team") or target:GetAttribute("TeamID")
        if myTeam and theirTeam then return myTeam ~= theirTeam end
        return true
    end

    local function isVisible(targetChar, part)
        local cam = workspace.CurrentCamera
        if not cam or not part then return false end
        local startPos = cam.CFrame.Position
        local direction = (part.Position - startPos).Unit
        local distance = (part.Position - startPos).Magnitude
        if distance < 1 then return true end
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Blacklist
        params.FilterDescendantsInstances = { player.Character, targetChar }
        params.IgnoreWater = true
        local result = workspace:Raycast(startPos, direction * distance, params)
        if not result then return true end
        local hit = result.Instance
        if hit == part or hit:IsDescendantOf(targetChar) then return true end
        return false
    end

    local function getTarget()
        local cam = workspace.CurrentCamera
        if not cam then return nil end

        local now = tick()
        local cached = AimbotService.CachedTarget
        if cached and (now - AimbotService.CacheTime) < AimbotService.CacheDuration then
            local char = cached.Character
            if char then
                local head = char:FindFirstChild("Head")
                local hum = char:FindFirstChild("Humanoid")
                if head and hum and hum.Health > 0 then
                    local sp, onscreen = cam:WorldToViewportPoint(head.Position)
                    if onscreen then
                        local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
                        local d = (center - Vector2.new(sp.X, sp.Y)).Magnitude
                        if d <= AimbotFOV.Radius then
                            return cached
                        end
                    end
                end
            end
            AimbotService.CachedTarget = nil
        end

        local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
        local maxRadius = AimbotFOV.Radius
        local best, bestDist = nil, maxRadius + 1

        for _, plr in ipairs(Players:GetPlayers()) do
            if isEnemy(plr) then
                local char = plr.Character
                if char then
                    local head = char:FindFirstChild("Head")
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if head and hum and hum.Health > 0 then
                        local sp, onscreen = cam:WorldToViewportPoint(head.Position)
                        if onscreen then
                            local d = (center - Vector2.new(sp.X, sp.Y)).Magnitude
                            if d < bestDist and isVisible(char, head) then
                                best = plr
                                bestDist = d
                            end
                        end
                    end
                end
            end
        end

        AimbotService.CachedTarget = best
        AimbotService.CacheTime = now
        return best
    end

    RunService.RenderStepped:Connect(function(deltaTime)
        if not AimbotService.Instant and not AimbotService.Smooth then return end

        local cam = workspace.CurrentCamera
        if not cam then return end

        local target = getTarget()
        if not target or not target.Character then return end

        local head = target.Character:FindFirstChild("Head")
        if not head then return end

        -- smooth aimbot I take a look.
        local smoothing = AimbotService.Instant and 1 or AimbotService.SmoothFactor
        local step = 1 - (1 - smoothing) ^ (deltaTime / (1/60))
        local aimed = cam.CFrame:Lerp(CFrame.lookAt(cam.CFrame.Position, head.Position), step)

        if aimed ~= aimed then return end  -- NaN guard

        local pitch, yaw = aimed:ToOrientation()
        cc:SetRotation(Vector2.new(pitch, yaw))

        -- aimbot sway
        local item = krFighterController and krFighterController.LocalFighter
            and rawget(krFighterController.LocalFighter, "EquippedItem")
        local viewModel = item and rawget(item, "ViewModel")
        if viewModel and viewModel._sway_spring then
            local sway = (cam.CFrame:Inverse() * aimed).LookVector
            local swayMag = Vector2.new(sway.X, sway.Y).Magnitude
            viewModel._sway_spring.Value = viewModel._sway_spring.Value + swayMag * 35
        end
    end)
end

AimbotGroup:AddToggle('InstantAimbotEnabled', {
    Text = 'Instant Aimbot',
    Default = false,
    Callback = function(v)
        AimbotService.Instant = v
        if not v and not AimbotService.Smooth then
            AimbotService.CachedTarget = nil
        end
    end
})

AimbotGroup:AddToggle('SmoothAimbotEnabled', {
    Text = 'Smooth Aimbot',
    Default = false,
    Callback = function(v)
        AimbotService.Smooth = v
        if not v and not AimbotService.Instant then
            AimbotService.CachedTarget = nil
        end
    end
})

AimbotGroup:AddSlider('SmoothAimbotFactor', {
    Text = 'Smoothness',
    Default = 0.3,
    Min = 0.05,
    Max = 1,
    Rounding = 2,
    Callback = function(v)
        AimbotService.SmoothFactor = v
    end
})

AimbotGroup:AddToggle('AimbotFOVToggle', {
    Text = 'Show FOV Circle',
    Default = false,
    Callback = function(v)
        AimbotFOV.AimToggle = v
        refreshFOVVisibility()
    end
})

local SilentAimGroup = Tabs.Combat:AddRightGroupbox('Silent Aim')

local silentAimEnabled         = false
local silentAimHitChance       = 100
local silentAimHeadshotChance  = 70
local silentAimForgetTime      = 1
local silentAimClosestPart     = false
local silentAimVisibleOnly     = false
local silentAimIgnoreProtected = true

local _saTarget, _saTargetPart
local _saLastSeen = 0

local saRng = Random.new()

local SA_R15Parts = {
    "Head","UpperTorso","LowerTorso","HumanoidRootPart",
    "LeftUpperArm","LeftLowerArm","LeftHand",
    "RightUpperArm","RightLowerArm","RightHand",
    "LeftUpperLeg","LeftLowerLeg","LeftFoot",
    "RightUpperLeg","RightLowerLeg","RightFoot",
}
local SA_LimbParts = {
    LeftUpperArm=true,LeftLowerArm=true,LeftHand=true,
    RightUpperArm=true,RightLowerArm=true,RightHand=true,
    LeftUpperLeg=true,LeftLowerLeg=true,LeftFoot=true,
    RightUpperLeg=true,RightLowerLeg=true,RightFoot=true,
}

local saRayParams = RaycastParams.new()
saRayParams.FilterType = Enum.RaycastFilterType.Exclude
saRayParams.IgnoreWater = true

local saUseItemRemote, saEnumLib, saUtil
task.spawn(function()
    local reps = game:GetService("ReplicatedStorage")
    saUseItemRemote = reps:WaitForChild("Remotes"):WaitForChild("Replication"):WaitForChild("Fighter"):WaitForChild("UseItem")
    local ok = pcall(function() saEnumLib = require(reps:WaitForChild("Modules"):WaitForChild("EnumLibrary")) end)
    if not ok then saEnumLib = nil end
    local ok2 = pcall(function() saUtil = require(reps:WaitForChild("Modules"):WaitForChild("Utility")) end)
    if not ok2 then saUtil = nil end
end)

local saActionTokens = {}
local saActionTokensBuilt = false

local function saBuildActionTokens()
    if saActionTokensBuilt or not saEnumLib then return end
    saActionTokensBuilt = true
    for _, name in ipairs({
        "StartShooting", "StopShooting",
        "StartAiming", "StopAiming", "StartAim", "AimStart",
        "Shoot", "Fire", "Attack", "StartAttack", "StopAttack",
        "HeavyAttack", "LightAttack", "PrimaryAttack", "SecondaryAttack",
    }) do
        local ok, tok = pcall(function() return saEnumLib:ToEnum(name) end)
        if ok and tok ~= nil then
            table.insert(saActionTokens, tok)
        end
    end
end

local function saIsShootAction(action)
    if action == nil then return false end
    if not saEnumLib then return false end
    saBuildActionTokens()

    local ok, name = pcall(function() return saEnumLib:FromEnum(action) end)
    if ok and type(name) == "string" then
        local lower = name:lower()
        if lower:find("shoot", 1, true)
            or lower:find("fire", 1, true)
            or lower:find("attack", 1, true)
            or lower:find("aim", 1, true) then
            return true
        end
    end

    for _, tok in ipairs(saActionTokens) do
        if action == tok then return true end
    end
    return false
end

local function saIsProtected(char)
    if char:FindFirstChild("InvincibilityParticles", true) then return true end
    local root = char:FindFirstChild("HumanoidRootPart")
    if root then
        for _, obj in root:GetChildren() do
            if obj:IsA("Attachment") and obj.Name == "Attachment" then return true end
        end
    end
    return false
end

local function saCanSee(char, part)
    local cam = workspace.CurrentCamera
    if not cam then return false end
    saRayParams.FilterDescendantsInstances = { lplr.Character, char, cam }
    local r = workspace:Raycast(cam.CFrame.Position, part.Position - cam.CFrame.Position, saRayParams)
    return not r or r.Instance:IsDescendantOf(char)
end

local function saClosestPart(char, origin)
    local cam = workspace.CurrentCamera
    if not cam then return nil end
    local best, bestD = nil, math.huge
    for _, name in ipairs(SA_R15Parts) do
        if not SA_LimbParts[name] then
            local p = char:FindFirstChild(name)
            if p and p:IsA("BasePart") then
                local sp, sv = cam:WorldToViewportPoint(p.Position)
                if sv then
                    local d = (Vector2.new(sp.X, sp.Y) - origin).Magnitude
                    if d < bestD then best, bestD = p, d end
                end
            end
        end
    end
    return best
end

local function saAcquire()
    local cam = workspace.CurrentCamera
    if not cam then return nil, nil end
    local center = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
    local radius = AimbotFOV.Radius
    local best, bestPart, bestD = nil, nil, radius
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lplr and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                if not (silentAimIgnoreProtected and saIsProtected(p.Character)) then
                    local part
                    if silentAimClosestPart then
                        part = saClosestPart(p.Character, center)
                    else
                        part = p.Character:FindFirstChild("Head")
                    end
                    if part then
                        local sp, sv = cam:WorldToViewportPoint(part.Position)
                        if sv then
                            local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                            if d < bestD then
                                if not silentAimVisibleOnly or saCanSee(p.Character, part) then
                                    best, bestPart, bestD = p.Character, part, d
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return best, bestPart
end

local function saGetTarget()
    local char, part = saAcquire()
    local now = tick()
    if char then
        _saTarget, _saTargetPart, _saLastSeen = char, part, now
    end
    if _saTarget and now - _saLastSeen <= silentAimForgetTime then
        local hum = _saTarget:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 and _saTargetPart and _saTargetPart.Parent then
            return _saTarget, _saTargetPart
        end
    end
    _saTarget, _saTargetPart = nil, nil
    return nil, nil
end

local saOldFire
local function saInstall()
    if saOldFire or not saUseItemRemote or not hookfunction then return end
    saOldFire = hookfunction(saUseItemRemote.FireServer, newcclosure(function(self, oid, action, cameradata, ...)
        if silentAimEnabled and saUtil and saIsShootAction(action) then
            local target, part = saGetTarget()
            if target and part and saRng:NextNumber(0, 100) <= silentAimHitChance then
                if not silentAimClosestPart then
                    if saRng:NextNumber(0, 100) <= silentAimHeadshotChance then
                        part = target:FindFirstChild("Head") or part
                    else
                        part = target:FindFirstChild("HumanoidRootPart") or part
                    end
                end
                local cam = workspace.CurrentCamera
                if cam and part then
                    local look = CFrame.new(cam.CFrame.Position, part.Position)
                    local data
                    if typeof(cameradata) == "table" then
                        data = cameradata
                    else
                        data = {}
                    end
                    data[utf8.char(1)] = {
                        [utf8.char(0)] = saUtil:EncodeCFrame(look),
                        [utf8.char(1)] = saUtil:EncodeCFrame(look),
                        [utf8.char(2)] = part,
                        [utf8.char(3)] = saUtil:EncodeCFrame(part.CFrame:ToObjectSpace(CFrame.new(part.Position))),
                    }
                    return saOldFire(self, oid, action, data, ...)
                end
            end
        end
        return saOldFire(self, oid, action, cameradata, ...)
    end))
end

local function saUninstall()
    if saOldFire and saUseItemRemote and hookfunction then
        pcall(function() hookfunction(saUseItemRemote.FireServer, saOldFire) end)
        saOldFire = nil
    end
end

SilentAimGroup:AddToggle('SilentAimEnabled', {
    Text = 'Enable Silent Aim',
    Default = false,
    Callback = function(v)
        silentAimEnabled = v
        if v then saInstall() else saUninstall() end
    end
})

SilentAimGroup:AddToggle('SilentAimFOVToggle', {
    Text = 'Show FOV Circle',
    Default = false,
    Callback = function(v)
        AimbotFOV.SilentToggle = v
        refreshFOVVisibility()
    end
})

SilentAimGroup:AddSlider('SilentAimFOVRadius', {
    Text = 'FOV Radius',
    Default = 150,
    Min = 20,
    Max = 500,
    Rounding = 0,
    Callback = function(v)
        AimbotFOV.Radius = v
    end
})

SilentAimGroup:AddSlider('SilentAimHitChance', {
    Text = 'Hit Chance %', Default = 100, Min = 0, Max = 100, Rounding = 0,
    Callback = function(v) silentAimHitChance = v end
})

SilentAimGroup:AddSlider('SilentAimHeadChance', {
    Text = 'Headshot Chance %', Default = 70, Min = 0, Max = 100, Rounding = 0,
    Callback = function(v) silentAimHeadshotChance = v end
})

SilentAimGroup:AddSlider('SilentAimForget', {
    Text = 'Forget Time (s)', Default = 1, Min = 0, Max = 5, Rounding = 2,
    Callback = function(v) silentAimForgetTime = v end
})

SilentAimGroup:AddToggle('SilentAimClosestPart', {
    Text = 'Closest Part',
    Default = false,
    Callback = function(v) silentAimClosestPart = v end
})

SilentAimGroup:AddToggle('SilentAimVisibleOnly', {
    Text = 'Visible Only',
    Default = false,
    Callback = function(v) silentAimVisibleOnly = v end
})

SilentAimGroup:AddToggle('SilentAimIgnoreProtected', {
    Text = 'Ignore Protected',
    Default = true,
    Callback = function(v) silentAimIgnoreProtected = v end
})

local ManipulateGroup = Tabs.Combat:AddRightGroupbox('Manipulate')

local mnpEnabled        = false
local mnpHitChance      = 100
local mnpFovRadius      = 150
local mnpForgetTime     = 1
local mnpRadius         = 10

local _mnpTarget, _mnpTargetPart, _mnpLastSeen = nil, nil, 0
local _mnpRng = Random.new()

local mnpRayParams = RaycastParams.new()
mnpRayParams.FilterType = Enum.RaycastFilterType.Exclude
mnpRayParams.IgnoreWater = true

local mnpUtil
task.spawn(function()
    local ok = pcall(function()
        mnpUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Utility"))
    end)
    if not ok then mnpUtil = nil end
end)

local function mnpIsProtected(char)
    if char:FindFirstChild("InvincibilityParticles", true) then return true end
    local root = char:FindFirstChild("HumanoidRootPart")
    if root then
        for _, obj in root:GetChildren() do
            if obj:IsA("Attachment") and obj.Name == "Attachment" then return true end
        end
    end
    return false
end

local function mnpVisibleFrom(origin, part, char)
    local cam = workspace.CurrentCamera
    mnpRayParams.FilterDescendantsInstances = { lplr.Character, char, cam }
    local r = workspace:Raycast(origin, part.Position - origin, mnpRayParams)
    return not r or r.Instance:IsDescendantOf(char)
end

local function mnpFindOrigin(camPos, part, char)
    if mnpVisibleFrom(camPos, part, char) then
        return camPos, false
    end

    local toPart = part.Position - camPos
    local dist = toPart.Magnitude
    if dist < 1e-4 then return nil end
    local dir = toPart / dist
    local halfSize = part.Size.Magnitude / 2
    local safeDist = math.min(mnpRadius, dist - halfSize)
    if safeDist <= 0 then return nil end

    local ahead = camPos + dir * safeDist
    if mnpVisibleFrom(ahead, part, char) then
        return ahead, true
    end

    local up = Vector3.yAxis
    local basis = math.abs(dir:Dot(up)) > 0.99 and Vector3.xAxis or up
    local axis1 = dir:Cross(basis).Unit
    local axis2 = axis1:Cross(dir).Unit
    local samples = 7
    for i = 0, samples - 1 do
        local a = math.tau * i / samples
        local test = camPos + (axis1 * math.cos(a) + axis2 * math.sin(a)) * safeDist
        if mnpVisibleFrom(test, part, char) then
            return test, true
        end
    end

    return nil
end

local function mnpAcquire()
    local cam = workspace.CurrentCamera
    if not cam then return nil, nil end
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local best, bestPart, bestD = nil, nil, mnpFovRadius
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lplr and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 and not mnpIsProtected(p.Character) then
                local head = p.Character:FindFirstChild("Head")
                if head then
                    local sp, sv = cam:WorldToViewportPoint(head.Position)
                    if sv then
                        local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                        if d < bestD then
                            best, bestPart, bestD = p.Character, head, d
                        end
                    end
                end
            end
        end
    end
    return best, bestPart
end

local function mnpGetTarget()
    local char, part = mnpAcquire()
    local now = tick()
    if char then
        _mnpTarget, _mnpTargetPart, _mnpLastSeen = char, part, now
    end
    if _mnpTarget and now - _mnpLastSeen <= mnpForgetTime then
        local hum = _mnpTarget:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 and _mnpTargetPart and _mnpTargetPart.Parent then
            return _mnpTarget, _mnpTargetPart
        end
    end
    _mnpTarget, _mnpTargetPart = nil, nil
    return nil, nil
end

local mnpOldFire

local function mnpInstall()
    if mnpOldFire or not saUseItemRemote or not hookfunction then
        warn("[manipulate] Could not install — missing hookfunction or UseItem remote")
        return
    end

    mnpOldFire = hookfunction(saUseItemRemote.FireServer, newcclosure(function(self, oid, action, cameradata, ...)
        if not mnpEnabled or not mnpUtil or not saIsShootAction(action) then
            return mnpOldFire(self, oid, action, cameradata, ...)
        end

        local target, part = mnpGetTarget()

        if not target or not part or _mnpRng:NextNumber(0, 100) > mnpHitChance then
            return mnpOldFire(self, oid, action, cameradata, ...)
        end

        local cam = workspace.CurrentCamera
        if not cam then
            return mnpOldFire(self, oid, action, cameradata, ...)
        end

        local usePart, originPos, manipulated
        for _, name in ipairs({ "Head", "UpperTorso", "LowerTorso", "HumanoidRootPart" }) do
            local p = target:FindFirstChild(name)
            if p then
                local origin, moved = mnpFindOrigin(cam.CFrame.Position, p, target)
                if origin then
                    usePart = p
                    originPos = origin
                    manipulated = moved
                    break
                end
            end
        end

        if not usePart then
            usePart = part
            originPos = cam.CFrame.Position
            manipulated = false
        end

        if manipulated then
            getgenv().SilentAimManipulatedAt = os.clock()
        end

        local aimCF = CFrame.lookAt(originPos, usePart.Position)
        local data = typeof(cameradata) == "table" and cameradata or {}

        data[utf8.char(1)] = {
            [utf8.char(0)] = mnpUtil:EncodeCFrame(aimCF),
            [utf8.char(1)] = mnpUtil:EncodeCFrame(aimCF),
            [utf8.char(2)] = usePart,
            [utf8.char(3)] = mnpUtil:EncodeCFrame(usePart.CFrame:ToObjectSpace(CFrame.new(usePart.Position))),
        }

        return mnpOldFire(self, oid, action, data, ...)
    end))
end

local function mnpUninstall()
    if mnpOldFire and saUseItemRemote and hookfunction then
        pcall(function() hookfunction(saUseItemRemote.FireServer, mnpOldFire) end)
        mnpOldFire = nil
    end
end

RunService.RenderStepped:Connect(function()
    if not mnpEnabled then
        if getgenv().ManipulateActive then
            getgenv().ManipulateActive = false
        end
        return
    end

    local cam = workspace.CurrentCamera
    if not cam then
        getgenv().ManipulateActive = false
        return
    end

    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local radius = mnpFovRadius
    local near   = false

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lplr and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 and not mnpIsProtected(p.Character) then
                local head = p.Character:FindFirstChild("Head")
                if head then
                    local sp, sv = cam:WorldToViewportPoint(head.Position)
                    if sv then
                        local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                        if d <= radius then
                            near = true
                            break
                        end
                    end
                end
            end
        end
    end

    getgenv().ManipulateActive = near
end)

ManipulateGroup:AddToggle('MNPEnabled', {
    Text = 'Enable Manipulate',
    Default = false,
    Callback = function(v)
        mnpEnabled = v
        if v then
            mnpInstall()
        else
            mnpUninstall()
            getgenv().ManipulateActive = false
        end
    end
})

ManipulateGroup:AddSlider('MNPFOV', {
    Text = 'FOV Radius', Default = 150, Min = 20, Max = 500, Rounding = 0,
    Callback = function(v) mnpFovRadius = v end
})

ManipulateGroup:AddSlider('MNPRadius', {
    Text = 'Origin Search Radius (studs)', Default = 10, Min = 0, Max = 30, Rounding = 1,
    Callback = function(v) mnpRadius = v end
})

ManipulateGroup:AddSlider('MNPHit', {
    Text = 'Hit Chance %', Default = 100, Min = 0, Max = 100, Rounding = 0,
    Callback = function(v) mnpHitChance = v end
})

ManipulateGroup:AddSlider('MNPForget', {
    Text = 'Forget Time (s)', Default = 1, Min = 0, Max = 5, Rounding = 2,
    Callback = function(v) mnpForgetTime = v end
})

pcall(function()
    Library:OnUnload(function() mnpUninstall() end)
end)

-- ── KICIA MELEE vW knife rage ───────────────────────────────────
local KnifeRageGroup = Tabs.Combat:AddLeftGroupbox('Knife Rage')
local knifeRageEnabled = false


-- ============================================================
-- Signal / Trove (değişmedi)
-- ============================================================
local Signal = {}
Signal.__index = Signal
function Signal.new() return setmetatable({ _handlers = {} }, Signal) end
function Signal:Connect(fn)
    local h = { fn = fn, connected = true }
    table.insert(self._handlers, h)
    local sig = self
    return {
        Connected = true,
        Disconnect = function(c)
            if not h.connected then return end
            h.connected = false
            c.Connected = false
            local i = table.find(sig._handlers, h)
            if i then table.remove(sig._handlers, i) end
        end,
    }
end
function Signal:Fire(...)
    local list = table.clone(self._handlers)
    for _, h in ipairs(list) do
        if h.connected then task.spawn(h.fn, ...) end
    end
end
function Signal:Destroy() table.clear(self._handlers) end

local Trove = {}
Trove.__index = Trove
function Trove.new(name) return setmetatable({ _name = name, _items = {}, _cleaning = false }, Trove) end
local function cleanItem(o)
    local t = typeof(o)
    if t == "RBXScriptConnection" then pcall(function() o:Disconnect() end)
    elseif t == "Instance" then pcall(function() o:Destroy() end)
    elseif t == "thread" then pcall(task.cancel, o)
    elseif type(o) == "function" then pcall(o)
    elseif type(o) == "table" then
        local destroy = o.Destroy or o.Disconnect
        if type(destroy) == "function" then pcall(destroy, o) end
    end
end
function Trove:Add(o) table.insert(self._items, o); return o end
function Trove:Connect(sig, fn) return self:Add(sig:Connect(fn)) end
function Trove:Clean()
    if self._cleaning then return end
    self._cleaning = true
    local items = self._items
    self._items = {}
    for i = #items, 1, -1 do cleanItem(items[i]) end
    self._cleaning = false
end
Trove.Destroy = Trove.Clean

local MainTrove = Trove.new("KiciaMelee")

-- ============================================================
-- FAST FLAGS (değişmedi)
-- ============================================================
pcall(function()
    if setfflag then
        setfflag("DFIntS2PhysicsSenderRate", "240")
        setfflag("DFIntAssemblyHistoryBufferSize", "2147483648")
        setfflag("DFIntAssemblyHistorySkipSize", "0")
    end
end)

-- ============================================================
-- MODÜL YÜKLEMELERİ (değişmedi)
-- ============================================================
local EnumLibrary = require(ReplicatedStorage.Modules.EnumLibrary)
local UseItem     = ReplicatedStorage.Remotes.Replication.Fighter:WaitForChild("UseItem", 10)
local FC          = require(lplr.PlayerScripts.Controllers:WaitForChild("FighterController", 30))
local function localFighter() return FC and FC.LocalFighter end

local CameraController
pcall(function()
    CameraController = require(lplr.PlayerScripts.Controllers.CameraController)
end)

local setRotationFn = nil
if CameraController then
    pcall(function()
        local mt = getmetatable(CameraController)
        if mt and type(mt.__index) == "table" then
            setRotationFn = mt.__index.SetRotation
        end
    end)
end

local function applyCameraRotation(pitch, yaw)
    local rot = Vector2.new(pitch, yaw)
    if setRotationFn then
        pcall(function() coroutine.wrap(setRotationFn)(CameraController, rot) end)
    else
        pcall(function() CameraController.Rotation = rot end)
    end
end

local _to_enum = rawget(EnumLibrary, "_to_enum")
local function toEnum(name)
    if _to_enum then return _to_enum[name] end
    local ok, v = pcall(function() return EnumLibrary:ToEnum(name) end)
    if ok and v ~= nil then return v end
    return nil
end

local START_SHOOTING = toEnum("StartShooting")
local START_AIMING   = toEnum("StartAiming")
local ANIM_ATTACK    = toEnum("AttackAnimation1") or toEnum("Attack1")
local ANIM_HEAVY     = toEnum("HeavyAttackAnimation1") or toEnum("HeavyAttack1")

-- ============================================================
-- CONFIG (değişmedi, sadece TARGET_MODE ve PRIORITY eklendi)
-- ============================================================
local CONFIG = {
    ATTACK_DURATION  = 0.15,
    VOID_DURATION    = 0.34,
    FIRE_DELAY       = 0.01,
    KNIFE_COOLDOWN   = 0.75,
    MELEE_COOLDOWN   = 0.15,

    TP_BACK          = 2.0,
    TP_FRONT         = 2.0,
    TP_SIDE          = 2.0,
    RANGE            = math.huge,
    AIM_SMOOTHING    = 0,

    -- Zero-Ping
    PREDICTION_STRENGTH = 1.0,
    MAX_PING            = 0.3,

    -- Voidspam (DEĞİŞMEDİ)
    VOID_TRACK_RADIUS   = 5000,
    VOID_TP_PER_FRAME   = 100,
    VOID_MIN_Y          = 5000,
    VOID_MAX_Y          = 10000,

    BACKSTAB_SPEED      = 120,
    SMART_BACKSTAB      = true,

    -- YENİ: Hedef seçim parametreleri
    TARGET_MODE         = "Closest",  -- "Closest" | "LowestHealth"
    PRIORITY_VOIDED     = true,       -- void'deki hedeflere öncelik
    PRIORITY_ATTACKERS  = true,       -- silah tutanlara öncelik
    NEAR_OTHER_MATCH_R  = 1000,       -- başka maç yakınlık eşiği

    DEBUG = true,
}

-- ============================================================
-- FALLEN PARTS (değişmedi)
-- ============================================================
local function disableFallenParts()
    pcall(function() workspace.FallenPartsDestroyHeight = 0/0 end)
end
disableFallenParts()
task.spawn(function()
    while true do task.wait(0.5) disableFallenParts() end
end)

-- ============================================================
-- FAST CFrame WRITE (değişmedi)
-- ============================================================
local _ni_cache = nil
local _ni_checked = false
local function getHRPNewIndex(hrp)
    if not _ni_checked then
        pcall(function()
            if type(setthreadidentity) == "function" then setthreadidentity(6) end
            local mt = getrawmetatable(hrp)
            _ni_cache = mt and rawget(mt, "__newindex")
            if type(setthreadidentity) == "function" then setthreadidentity(2) end
        end)
        _ni_checked = true
    end
    return _ni_cache
end

local V0 = Vector3.zero
local function fastSetCF(hrp, cf)
    local ni = getHRPNewIndex(hrp)
    if ni then
        pcall(ni, hrp, "AssemblyLinearVelocity", V0)
        pcall(ni, hrp, "AssemblyAngularVelocity", V0)
        pcall(ni, hrp, "CFrame", cf)
        pcall(ni, hrp, "AssemblyLinearVelocity", V0)
    else
        pcall(function()
            hrp.AssemblyLinearVelocity = V0
            hrp.AssemblyAngularVelocity = V0
            hrp.CFrame = cf
        end)
    end
    if sethiddenproperty then
        pcall(sethiddenproperty, hrp, "CFrame", cf)
        pcall(sethiddenproperty, hrp, "AssemblyLinearVelocity", V0)
    end
end

-- ============================================================
-- ENEMY TRACKER (değişmedi)
-- ============================================================
local enemyTrackers    = setmetatable({}, { __mode = "k" })
local enemyTrackerChar = setmetatable({}, { __mode = "k" })
local MAX_TRACK_SAMPLES = 8

local function updateEnemyTracker(plr)
    local char = plr.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local tracker = enemyTrackers[plr]
    if not tracker or enemyTrackerChar[plr] ~= char then
        tracker = { positions = {}, cframes = {}, times = {} }
        enemyTrackers[plr]  = tracker
        enemyTrackerChar[plr] = char
    end

    local now = workspace:GetServerTimeNow()
    table.insert(tracker.positions, root.Position)
    table.insert(tracker.cframes,   root.CFrame)
    table.insert(tracker.times,     now)

    while #tracker.positions > MAX_TRACK_SAMPLES do
        table.remove(tracker.positions, 1)
        table.remove(tracker.cframes,   1)
        table.remove(tracker.times,     1)
    end
end

-- ============================================================
-- PREDICTION (değişmedi)
-- ============================================================
local function getPredictedState(plr)
    local char = plr.Character
    local fbPos, fbCF = Vector3.zero, CFrame.new()
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then fbPos, fbCF = root.Position, root.CFrame end
    end

    local tracker = enemyTrackers[plr]
    if not tracker or #tracker.positions < 2 then
        return {
            Position = fbPos, CFrame = fbCF,
            Velocity = Vector3.zero, Speed = 0,
            PredictionTime = 0, Confidence = 0,
            RealPosition = fbPos, RealCFrame = fbCF,
        }
    end

    local n = #tracker.positions
    local totalW, sumVel = 0, Vector3.zero
    local velocities = {}

    for i = 2, n do
        local dt = tracker.times[i] - tracker.times[i - 1]
        if dt > 0.001 then
            local v = (tracker.positions[i] - tracker.positions[i - 1]) / dt
            table.insert(velocities, v)
            local w = i - 1
            sumVel  = sumVel + v * w
            totalW  = totalW + w
        end
    end

    local avgVel = totalW > 0 and (sumVel / totalW) or Vector3.zero

    local sigma = 0
    if #velocities >= 2 then
        local acc = 0
        for _, v in velocities do
            acc = acc + (v - avgVel).Magnitude ^ 2
        end
        sigma = math.sqrt(acc / #velocities)
    end

    local sampleConf   = math.clamp((n - 1) / 3, 0.35, 1)
    local varianceConf = math.clamp(1 - sigma / 80, 0.30, 1)
    local confidence   = sampleConf * varianceConf

    local lastPos, lastCF, lastT = tracker.positions[n], tracker.cframes[n], tracker.times[n]
    local sampleAge = math.max(0, workspace:GetServerTimeNow() - lastT)

    local rawPing = lplr:GetNetworkPing()
    local rtt = rawPing > 1 and (rawPing / 1000) or rawPing

    local rawPredTime = (rtt + sampleAge) * CONFIG.PREDICTION_STRENGTH * confidence
    local predictionTime = math.clamp(rawPredTime, 0, CONFIG.MAX_PING)

    local predictedPos = lastPos + avgVel * predictionTime
    local horizVel     = Vector3.new(avgVel.X, 0, avgVel.Z)

    return {
        Position        = predictedPos,
        CFrame          = lastCF,
        Velocity        = avgVel,
        Speed           = horizVel.Magnitude,
        PredictionTime  = predictionTime,
        Confidence      = confidence,
        RealPosition    = lastPos,
        RealCFrame      = lastCF,
    }
end

-- ============================================================
-- YENİ: RAGEBOT'DAN ALINAN FİLTRELEME HELPERLARI
-- ============================================================
local function getRoot(char)
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- Silah ismi (ViewModels üzerinden)
local function scanWeapon(plr)
    local vms = workspace:FindFirstChild("ViewModels")
    if not vms then return "" end
    for _, model in ipairs(vms:GetChildren()) do
        if model:IsA("Model") then
            local sp = model.Name:find(" - ", 1, true)
            if sp and model.Name:sub(1, sp-1) == plr.Name then
                return model.Name:sub(sp+3):lower()
            end
        end
    end
    return ""
end

local function isKatana(plr) return scanWeapon(plr):find("katana", 1, true) ~= nil end

-- Invincible: attachment + particle kontrolü
local function isInvincible(plr)
    local char = plr and plr.Character
    local root = getRoot(char)
    if not root then return true end
    for _, obj in ipairs(root:GetChildren()) do
        if obj:IsA("Attachment") and obj.Name == "Attachment" then return true end
    end
    return char:FindFirstChild("InvincibilityParticles", true) ~= nil
end

-- Başka maçtaki oyuncular yakınsa hedef alma
local function isNearOtherMatch(pos, ignore)
    if typeof(pos) ~= "Vector3" then return false end
    local myEnv = lplr:GetAttribute("EnvironmentID")
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lplr and plr ~= ignore and plr:GetAttribute("EnvironmentID") ~= myEnv then
            local r = getRoot(plr.Character)
            if r and (r.Position - pos).Magnitude <= CONFIG.NEAR_OTHER_MATCH_R then
                return true
            end
        end
    end
    return false
end

-- Shooting range / firing range tespit
local function isShootingRange()
    for _, obj in ipairs({workspace, lplr}) do
        for _, attr in ipairs({"ShootingRange", "Mode", "Map", "MapName"}) do
            local v = obj:GetAttribute(attr)
            if v == true and attr == "ShootingRange" then return true end
            if type(v) == "string" then
                local t = v:lower():gsub("[%s_%-]", "")
                if t:find("shootingrange", 1, true) or t:find("firingrange", 1, true) then
                    return true
                end
            end
        end
    end
    return false
end

-- AllyLabel / TeammateLabel vs.
local function hasAllyLabels(plr)
    local char = plr.Character
    if not char then return false end
    for _, n in ipairs({"HumanoidRootPart", "Head", "HitboxHead"}) do
        local part = char:FindFirstChild(n)
        if part then
            for _, l in ipairs({"AllyLabel", "TeammateLabel", "TeamLabel", "FriendLabel"}) do
                if part:FindFirstChild(l) then return true end
            end
        end
    end
    return false
end

-- ============================================================
-- TEAMCHECK (korundu + güçlendirildi)
-- ============================================================
local function isTeamMate(plr)
    if plr == lplr then return true end
    if lplr.Team and plr.Team and lplr.Team == plr.Team then return true end
    local myTid = lplr:GetAttribute("TeamID")
    local theirTid = plr:GetAttribute("TeamID")
    if myTid ~= nil and theirTid ~= nil and myTid == theirTid then return true end
    return false
end

-- YENİ: Ragebot tarzı kapsamlı canAttack
local function canAttack(plr)
    if plr == lplr or isTeamMate(plr) then return false end
    local myEnv = lplr:GetAttribute("EnvironmentID")
    if not myEnv or plr:GetAttribute("EnvironmentID") ~= myEnv then return false end
    local char = plr.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    if char:FindFirstChildWhichIsA("ForceField", true) then return false end
    if plr:GetAttribute("IsInvincible") == true then return false end
    if isInvincible(plr) then return false end
    if hasAllyLabels(plr) then return false end
    if isKatana(plr) then return false end  -- katana kullanıcıları parry'ler, atla
    local r = getRoot(char)
    if r and isNearOtherMatch(r.Position, plr) then return false end
    return true
end

-- YENİ: Priority'li hedef seçimi (ragebot getBestTarget)
local function findBestTarget(pos)
    local best, bestV = nil, math.huge
    local useHP = CONFIG.TARGET_MODE == "LowestHealth"
    for _, plr in ipairs(Players:GetPlayers()) do
        if canAttack(plr) then
            local root = getRoot(plr.Character)
            if root then
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                local v = useHP and (hum and hum.Health or math.huge)
                    or (root.Position - pos).Magnitude
                if CONFIG.PRIORITY_VOIDED and root.Position.Magnitude > 1000000 then
                    v = v - 2000000000
                end
                if CONFIG.PRIORITY_ATTACKERS and scanWeapon(plr) ~= "" then
                    v = v - 1000000000
                end
                if v < bestV then
                    bestV = v
                    best = { Player = plr, Root = root, Char = plr.Character }
                end
            end
        end
    end
    return best
end

-- Eski findClosest -> findBestTarget'a yönlendirildi
local function findClosest(pos) return findBestTarget(pos) end

-- ============================================================
-- VOIDSPAM (DEĞİŞMEDİ)
-- ============================================================
local function voidSpam(hrp, center)
    local hum = hrp.Parent and hrp.Parent:FindFirstChildOfClass("Humanoid")
    if hum then pcall(function() hum:ChangeState(Enum.HumanoidStateType.Physics) end) end

    for i = 1, CONFIG.VOID_TP_PER_FRAME do
        local angle = (i / CONFIG.VOID_TP_PER_FRAME) * math.pi * 2
        local radius = math.random(100, CONFIG.VOID_TRACK_RADIUS)
        local x = center.X + math.cos(angle) * radius
        local z = center.Z + math.sin(angle) * radius
        local y = math.random(CONFIG.VOID_MIN_Y, CONFIG.VOID_MAX_Y)
        fastSetCF(hrp, CFrame.new(x, y, z))
    end
end

-- ============================================================
-- PAYLOAD (değişmedi)
-- ============================================================
local function orient(base, pitch, yaw, roll)
    return {
        ["\0"]=base["\0"], ["\1"]=base["\1"], ["\2"]=base["\2"],
        ["\3"]=pitch,     ["\4"]=yaw or 0,     ["\5"]=roll or 0
    }
end

local KNIFE_SURFACE         = { ["\0"]=0,     ["\1"]=1,    ["\2"]=0, ["\3"]=0,          ["\4"]=0,       ["\5"]=0 }
local KNIFE_ABOVE_PRIMARY   = { ["\0"]=-9e37, ["\1"]=0,    ["\2"]=0, ["\3"]=-math.pi/2, ["\4"]=math.pi, ["\5"]=math.pi }
local KNIFE_ABOVE_SECONDARY = { ["\0"]=0,     ["\1"]=-9e7, ["\2"]=0, ["\3"]=-math.pi/2, ["\4"]=math.pi, ["\5"]=math.pi }
local PRIMARY_BASE          = { ["\0"]=-9e37, ["\1"]=0,    ["\2"]=0 }
local SECONDARY_BASE        = { ["\0"]=0,     ["\1"]=-9e7, ["\2"]=0 }

local function itemField(item, key)
    if not item then return nil end
    local ok, v = pcall(function() return item:Get(key) end)
    if ok and v ~= nil then return v end
    return rawget(item, key)
end

local function isMeleeItem(item)
    if type(item) ~= "table" then return false end
    local info = rawget(item, "Info")
    if type(info) ~= "table" then return false end
    return (rawget(info, "Type") or rawget(info, "Class")) == "Melee"
end

local function hasRiotShield(enemy)
    if not enemy or not enemy.Char then return false end
    for _, child in ipairs(enemy.Char:GetChildren()) do
        if child:IsA("Tool") and child.Name == "Riot Shield" then return true end
    end
    return false
end

local function computeTPPosFromState(state, isKnife, shieldFront)
    local ep   = state.Position
    local look = Vector3.new(state.CFrame.LookVector.X, 0, state.CFrame.LookVector.Z)
    if look.Magnitude > 0.01 then look = look.Unit end

    if shieldFront then
        return Vector3.new(ep.X + look.X * CONFIG.TP_FRONT,  ep.Y + 0.5, ep.Z + look.Z * CONFIG.TP_FRONT)
    elseif isKnife then
        return Vector3.new(ep.X - look.X * CONFIG.TP_BACK,   ep.Y + 0.5, ep.Z - look.Z * CONFIG.TP_BACK)
    else
        local right = Vector3.new(state.CFrame.RightVector.X, 0, state.CFrame.RightVector.Z)
        if right.Magnitude > 0.01 then right = right.Unit end
        return Vector3.new(ep.X + right.X * CONFIG.TP_SIDE,  ep.Y + 0.5, ep.Z + right.Z * CONFIG.TP_SIDE)
    end
end

local function buildPayload(predictedCF, targetPart, isKnife)
    local _, eYaw, eRoll = predictedCF:ToOrientation()
    local pitch = -math.pi / 2
    local primary, secondary, anim, fireType
    if isKnife then
        primary   = orient(KNIFE_ABOVE_PRIMARY,   pitch, eYaw, eRoll)
        secondary = orient(KNIFE_ABOVE_SECONDARY, pitch, eYaw, eRoll)
        anim      = ANIM_HEAVY
        fireType  = START_AIMING or START_SHOOTING
    else
        primary   = orient(PRIMARY_BASE,   pitch, eYaw, eRoll)
        secondary = orient(SECONDARY_BASE, pitch, eYaw, eRoll)
        anim      = ANIM_ATTACK
        fireType  = START_SHOOTING
    end
    return {
        [utf8.char(1)] = {
            [utf8.char(0)] = primary,
            [utf8.char(1)] = secondary,
            [utf8.char(2)] = targetPart,
            [utf8.char(3)] = KNIFE_SURFACE,
        },
        [utf8.char(2)] = anim,
    }, fireType
end

local function tryEquipMelee()
    local f = localFighter()
    local items = f and rawget(f, "Items")
    if type(items) ~= "table" then return end
    for i, it in ipairs(items) do
        if isMeleeItem(it) then
            pcall(function() f:EquipItem(i) end)
            return
        end
    end
end

-- YENİ: canAttackNow'a ek doğrulama (hız + geçerlilik)
local function canAttackNow(predState)
    if predState.Speed >= CONFIG.BACKSTAB_SPEED then return false end
    return true
end

-- ============================================================
-- STATE (değişmedi)
-- ============================================================
local state          = "VOID"
local stateEndsAt    = 0
local currentEnemy   = nil
local firedThisAtk   = false
local lastEquip      = 0
local cycleCount     = 0
local successCount   = 0
local lastGroundPos  = nil
local nextKnifeReadyAt = 0
local nextMeleeReadyAt = 0
local aimPitch, aimYaw = 0, 0

-- YENİ: cache'i invalidasyona açık hale getir
local cachedEnemy, cachedEnemyAt = nil, 0
local function getClosestEnemy()
    local now = tick()
    if now - cachedEnemyAt < 0.05 then
        if cachedEnemy and canAttack(cachedEnemy.Player) then
            return cachedEnemy
        end
        -- cache invalid: temizle ve yeniden hesapla
        cachedEnemy, cachedEnemyAt = nil, 0
    end
    cachedEnemyAt = now
    local searchFrom = lastGroundPos
    if not searchFrom then
        local lpRoot = lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart")
        searchFrom = lpRoot and lpRoot.Position
    end
    if not searchFrom then cachedEnemy = nil; return nil end
    cachedEnemy = findBestTarget(searchFrom)
    return cachedEnemy
end

-- ============================================================
-- AIM LOCK (değişmedi, sadece getClosestEnemy artık daha akıllı)
-- ============================================================
MainTrove:Connect(RunService.RenderStepped, function(dt)
    if not knifeRageEnabled then return end
    if not CameraController then return end
    local enemy = getClosestEnemy()
    if not enemy then return end

    local targetPart = enemy.Char:FindFirstChild("HitboxHead")
        or enemy.Char:FindFirstChild("Head")
        or enemy.Root
    if not targetPart or not targetPart.Parent then return end

    local from
    if state == "ATTACK" and lastGroundPos then
        from = lastGroundPos
    else
        local enemyLook = enemy.Root.CFrame.LookVector
        local lookH = Vector3.new(enemyLook.X, 0, enemyLook.Z)
        if lookH.Magnitude > 0.01 then lookH = lookH.Unit end
        from = enemy.Root.Position - lookH * 3
    end

    local dir = targetPart.Position - from
    if dir.Magnitude < 0.01 then return end
    dir = dir.Unit

    local targetPitch = math.asin(math.clamp(dir.Y, -1, 1))
    local targetYaw   = math.atan2(-dir.X, -dir.Z)

    if CONFIG.AIM_SMOOTHING > 0 then
        local alpha = math.clamp(dt / CONFIG.AIM_SMOOTHING, 0, 1)
        local dYaw = targetYaw - aimYaw
        if dYaw > math.pi then dYaw = dYaw - 2*math.pi
        elseif dYaw < -math.pi then dYaw = dYaw + 2*math.pi end
        aimYaw = aimYaw + dYaw * alpha
        aimPitch = aimPitch + (targetPitch - aimPitch) * alpha
    else
        aimPitch = targetPitch
        aimYaw   = targetYaw
    end

    applyCameraRotation(aimPitch, aimYaw)
end)

-- ============================================================
-- ANA DÖNGÜ (VOID kısmı aynı, ATTACK kısmı güçlendirildi)
-- ============================================================
MainTrove:Connect(RunService.Heartbeat, function()
    if not knifeRageEnabled then return end
    local now    = tick()
    local lpRoot = lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart")
    if not lpRoot then return end

    -- YENİ: Shooting range'de saldırı yok (sadece void spam)
    if isShootingRange() then
        voidSpam(lpRoot, lpRoot.Position)
        return
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lplr then updateEnemyTracker(plr) end
    end

    local f = localFighter()
    if not f then return end

    local item = f.EquippedItem
    if not isMeleeItem(item) then
        if now - lastEquip > 0.6 then
            lastEquip = now
            tryEquipMelee()
        end
        voidSpam(lpRoot, lpRoot.Position)
        return
    end

    local isKnife = tostring(item.Name or "") == "Knife"
    local cooldownReady
    if isKnife then cooldownReady = now >= nextKnifeReadyAt
    else cooldownReady = now >= nextMeleeReadyAt end

    -- ===== VOID (DEĞİŞMEDİ) =====
    if state == "VOID" then
        local enemy = getClosestEnemy()
        local center = lpRoot.Position
        local predState = nil
        if enemy then
            predState = getPredictedState(enemy.Player)
            center = predState.Position
        end

        voidSpam(lpRoot, center)

        if enemy and cooldownReady and predState then
            if canAttackNow(predState) then
                currentEnemy = enemy
                firedThisAtk = false
                state        = "ATTACK"
                stateEndsAt  = now + CONFIG.ATTACK_DURATION
                cycleCount   = cycleCount + 1
                if CONFIG.DEBUG then
                    print(string.format("[#%d] STRIKE -> %s (v=%.1f, conf=%.2f, tPred=%.3f)",
                        cycleCount, enemy.Player.Name,
                        predState.Speed, predState.Confidence, predState.PredictionTime))
                end
            end
        end
        return
    end

    -- ===== ATTACK (GÜÇLENDİRİLDİ) =====
    if state == "ATTACK" then
        -- YENİ: Kapsamlı target validasyonu
        local invalid = currentEnemy == nil
            or currentEnemy.Root.Parent == nil
            or currentEnemy.Player.Character ~= currentEnemy.Char
            or not canAttack(currentEnemy.Player)

        if now >= stateEndsAt or invalid then
            if CONFIG.DEBUG and invalid then
                print(string.format("[#%d] CANCELLED (target invalid)", cycleCount))
            end
            state       = "VOID"
            stateEndsAt = now + CONFIG.VOID_DURATION
            voidSpam(lpRoot, lpRoot.Position)
            return
        end

        if not firedThisAtk then
            -- YENİ: Fire öncesi son doğrulamalar
            local predState = getPredictedState(currentEnemy.Player)

            if not canAttackNow(predState) then
                -- Hedef kaçmış/hızlanmış -> iptal
                if CONFIG.DEBUG then print(string.format("[#%d] CANCEL (speed %.1f)", cycleCount, predState.Speed)) end
                state = "VOID"
                stateEndsAt = now + CONFIG.VOID_DURATION
                return
            end

            if isNearOtherMatch(predState.RealPosition, currentEnemy.Player) then
                if CONFIG.DEBUG then print(string.format("[#%d] CANCEL (other match nearby)", cycleCount)) end
                state = "VOID"
                stateEndsAt = now + CONFIG.VOID_DURATION
                return
            end

            local hum = lpRoot.Parent and lpRoot.Parent:FindFirstChildOfClass("Humanoid")
            if hum then pcall(function() hum:ChangeState(Enum.HumanoidStateType.Physics) end) end

            local shieldFront = isKnife and hasRiotShield(currentEnemy)

            local tpPos = computeTPPosFromState(predState, isKnife, shieldFront)
            fastSetCF(lpRoot, CFrame.lookAt(tpPos, predState.Position))
            lastGroundPos = lpRoot.Position

            local targetPart = currentEnemy.Char:FindFirstChild("HitboxBody")
                or currentEnemy.Char:FindFirstChild("HitboxHead")
                or currentEnemy.Char:FindFirstChild("Head")
                or currentEnemy.Root

            -- YENİ: targetPart geçerlilik kontrolü
            if not targetPart or not targetPart.Parent then
                state = "VOID"
                stateEndsAt = now + CONFIG.VOID_DURATION
                return
            end

            local payload, fireType = buildPayload(predState.CFrame, targetPart, isKnife)
            local oid = itemField(item, "ObjectID")
            if oid then
                local ok = pcall(function() UseItem:FireServer(oid, fireType, payload, nil) end)
                if ok then
                    successCount = successCount + 1
                    if isKnife then nextKnifeReadyAt = now + CONFIG.KNIFE_COOLDOWN
                    else            nextMeleeReadyAt = now + CONFIG.MELEE_COOLDOWN end
                end
                if CONFIG.DEBUG then
                    print(string.format("[#%d] FIRE ok=%s (total=%d, TP=%.1f studs back)",
                        cycleCount, tostring(ok), successCount, CONFIG.TP_BACK))
                end
            end
            firedThisAtk = true
        end
        return
    end
end)
-- ── Knife Rage toggle ────────────────────────────────────────────
KnifeRageGroup:AddToggle('KnifeRageEnabled', {
    Text = 'Enable Knife Rage',
    Default = false,
    Callback = function(v)
        knifeRageEnabled = v
        if v then
            Library:Notify('Knife Rage enabled', 3)
            getgenv().RagebotStatusText = 'Knife Rage'
        else
            Library:Notify('Knife Rage disabled', 2)
            if getgenv().RagebotStatusText == 'Knife Rage' then
                getgenv().RagebotStatusText = 'Idle'
            end
        end
    end
}):AddKeyPicker('KnifeRageKey', {
    Default = 'None',
    Mode = 'Toggle',
    SyncToggleState = true,
    Text = 'Knife Rage'
})


local VoidspamGroup = Tabs.Combat:AddLeftGroupbox('Voidspam')

local voidspamEnabled = false
local voidspamAttackSpeed = 0.15
local voidspamHide = 100
local VOID_DEPTH = 50000000
local voidspamLastTime = 0
local voidspamRestoreData = {}
local originalParts = nil
local lastFlickerTime = 0

local hideLabel = VoidspamGroup:AddLabel('Hide Count: 100')

local function updateHideLabel()
    pcall(function()
        hideLabel:SetText('Hide Count: ' .. tostring(voidspamHide))
    end)
end

local function captureOriginal()
    local char = lplr.Character
    if not char then return end
    originalParts = {}
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("Decal") then
            table.insert(originalParts, { part = part, transparency = part.Transparency })
        end
    end
end

local function restoreOriginal()
    if not originalParts then return end
    for _, data in ipairs(originalParts) do
        if data.part and data.part.Parent then
            data.part.Transparency = data.transparency
        end
    end
    originalParts = nil
end

lplr.CharacterAdded:Connect(function()
    task.wait(0.5)
    if voidspamEnabled then captureOriginal() end
end)

RunService.Heartbeat:Connect(function()
    if not voidspamEnabled then return end
    if voidspamHide <= 0 then
        local char = lplr.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("Decal") then
                    part.Transparency = 0
                end
            end
        end
        return
    end

    local now = tick()
    if now - lastFlickerTime < 0.05 then return end
    lastFlickerTime = now

    local char = lplr.Character
    if not char then return end

    voidspamHide = voidspamHide - 1
    updateHideLabel()

    local shouldHide = (voidspamHide % 2 == 0)
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("Decal") then
            part.Transparency = shouldHide and 1 or 0
        end
    end
end)

RunService:BindToRenderStep("VoidspamRestore", 10, function()
    for _, data in ipairs(voidspamRestoreData) do
        if data.root and data.root.Parent then
            data.root.CFrame = data.oldCF
            data.root.AssemblyLinearVelocity = data.oldVel
            data.root.AssemblyAngularVelocity = data.oldRotVel
        end
    end
    voidspamRestoreData = {}
end)

RunService.Heartbeat:Connect(function()
    if not voidspamEnabled then return end
    if getgenv().Config and getgenv().Config.Enabled then return end

    local now = tick()
    if now - voidspamLastTime < math.max(voidspamAttackSpeed, 0.01) then return end
    voidspamLastTime = now

    local char = lplr.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local oldCF, oldVel, oldRotVel = hrp.CFrame, hrp.AssemblyLinearVelocity, hrp.AssemblyAngularVelocity
    local pos = oldCF.Position
    hrp.CFrame = CFrame.new(pos.X, VOID_DEPTH, pos.Z)
    hrp.AssemblyLinearVelocity, hrp.AssemblyAngularVelocity = oldVel, oldRotVel
    table.insert(voidspamRestoreData, {root=hrp, oldCF=oldCF, oldVel=oldVel, oldRotVel=oldRotVel})
end)

VoidspamGroup:AddToggle('VoidspamEnabled', {
    Text = 'Enable Voidspam',
    Default = false,
    Callback = function(v)
        voidspamEnabled = v
        if v then
            captureOriginal()
            Library:Notify('Voidspam enabled', 3)
        else
            restoreOriginal()
            voidspamRestoreData = {}
            Library:Notify('Voidspam disabled', 2)
        end
    end
})

VoidspamGroup:AddSlider('VoidspamAttackSpeed', {
    Text = 'Attack Speed (seconds)',
    Default = 0.15,
    Min = 0.01,
    Max = 1.0,
    Rounding = 2,
    Callback = function(v) voidspamAttackSpeed = v end
})

VoidspamGroup:AddSlider('VoidspamHide', {
    Text = 'Hide Count',
    Default = 100,
    Min = 0,
    Max = 500,
    Rounding = 0,
    Callback = function(v)
        voidspamHide = v
        updateHideLabel()
    end
})

local ragebotLoaded = false

local RagebotGroup = Tabs.Combat:AddLeftGroupbox('Ragebot')

RagebotGroup:AddToggle('RagebotEnabled', {
    Text = 'Enable Ragebot (V1)',
    Default = false,
}):AddKeyPicker('RagebotKey', {
    Default = 'None',
    Mode = 'Toggle',
    SyncToggleState = true,
    Text = 'Ragebot V1'
})

RagebotGroup:AddDivider()
local StatusLabel = RagebotGroup:AddLabel('Status: Idle')

local WaitMeleeEnabled = true

RagebotGroup:AddToggle('WaitMeleeToggle', {
    Text = 'Anti-hit',
    Default = true,
    Callback = function(v)
        WaitMeleeEnabled = v
    end
})

local function setStatus(text)
    pcall(function() StatusLabel:SetText('Status: ' .. text) end)
    getgenv().RagebotStatusText = text
end

getgenv().RagebotStatus = 'Idle'
getgenv().RagebotStatusText = 'Idle'
getgenv().RagebotImmunePhase = false
getgenv().RagebotImmuneStart = 0
getgenv().RagebotFiring = false
getgenv().Config = getgenv().Config or {
    Enabled = false,
    VoidOnDeath = true,
    ReloadVoidEnabled = true,
    VoidY = 50000000,
    ReloadVoidY = 50000000,
    ReloadTimeout = 3.0,
    FireRate = 1 / 20,  -- max shots/sec; lower number = slower. default: 20/sec
}

getgenv().Config.VoidOnDeath = true
getgenv().Config.ReloadVoidEnabled = true

local releaseV1Glue = function() end

local function loadRagebot()
    if ragebotLoaded then return true end
    local success, err = pcall(function()
        local Environment = getgenv()
        if Environment.Ragebot then
            pcall(function() Environment.Ragebot:Shutdown() end)
        end

        local Services = setmetatable({}, {
            __index = function(_, serviceName)
                local ok, service = pcall(function() return game:GetService(serviceName) end)
                if ok then return cloneref(service) end
                return nil
            end
        })

        local PLRS = Services.Players
        local RUN  = Services.RunService
        local REP  = Services.ReplicatedStorage
        local LOCAL = PLRS.LocalPlayer
        local PS = LOCAL.PlayerScripts

        local GunModule = require(PS.Modules.ItemTypes.Gun)
        local Utility = require(REP.Modules.Utility)
        local FighterController = require(PS.Controllers.FighterController)
        local MechanicsController = require(PS.Controllers.MechanicsController)
        local EnumLibrary = require(REP.Modules.EnumLibrary)
        local UseItemRemote = REP.Remotes.Replication.Fighter.UseItem

        local function resolveEnum(names, fallback)
            for _, name in ipairs(names) do
                local ok, tok = pcall(function() return EnumLibrary:ToEnum(name) end)
                if ok and tok ~= nil then return tok end
            end
            return fallback
        end

        local START_SHOOTING = resolveEnum({ "StartShooting" }, "StartShooting")
        local STOP_SHOOTING  = resolveEnum({ "StopShooting" }, "StopShooting")
        local START_AIMING   = resolveEnum({ "StartAiming", "StartAim", "AimStart" }, "StartAiming")

        local Config = getgenv().Config
        Config.Enabled = false
        Config.VoidOnDeath = true
        Config.ReloadVoidEnabled = true

        local CharacterParts = setmetatable({}, {
            __index = function(_, partName)
                local character = LOCAL.Character
                if not character then return nil end
                if partName == "Root" then return character:FindFirstChild("HumanoidRootPart")
                elseif partName == "Head" then return character:FindFirstChild("Head") end
                return nil
            end
        })

        -- ─── Forcefield check
        local SPAWN_PROTECTION_GRACE = 2.0
        local FF_ATTR_NAMES = {
            "Invincible", "IsInvincible", "God", "GodMode", "Godmode",
            "ForceField", "Forcefield", "ForceFieldActive",
            "Protected", "SpawnProtection", "Immune", "IsProtected",
        }
        local _charSpawnTime = setmetatable({}, { __mode = "k" })

        local function _recordSpawn(character)
            if character then _charSpawnTime[character] = tick() end
        end
        for _, p in ipairs(PLRS:GetPlayers()) do
            if p.Character then
                _charSpawnTime[p.Character] = tick() - 999
            end
            p.CharacterAdded:Connect(_recordSpawn)
        end
        PLRS.PlayerAdded:Connect(function(p)
            if p.Character then _charSpawnTime[p.Character] = tick() - 999 end
            p.CharacterAdded:Connect(_recordSpawn)
        end)

        local function _charAge(character)
            if not character then return 0 end
            local t = _charSpawnTime[character]
            return t and (tick() - t) or 0
        end

        local function _fighterFor(player)
            if not FighterController or not rawget(FighterController, "Objects") then
                return nil
            end
            for _, f in ipairs(FighterController.Objects) do
                if rawget(f, "Player") == player then return f end
            end
            return nil
        end

        local function isTargetProtected(targetPlayer)
            if not targetPlayer then return true end
            local char = targetPlayer.Character
            if not char then return true end

            if char:FindFirstChildOfClass("ForceField") then return true end
            if char:FindFirstChild("InvincibilityParticles", true) then return true end

            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                for _, obj in ipairs(root:GetChildren()) do
                    if obj:IsA("Attachment") and obj.Name == "Attachment" then
                        return true
                    end
                end
            end

            local hum = char:FindFirstChildWhichIsA("Humanoid")
            for _, attr in ipairs(FF_ATTR_NAMES) do
                if targetPlayer:GetAttribute(attr) == true then return true end
                if char:GetAttribute(attr) == true then return true end
                if hum and hum:GetAttribute(attr) == true then return true end
            end

            local fighter = _fighterFor(targetPlayer)
            if fighter then
                local ent  = rawget(fighter, "Entity")
                local data = ent and rawget(ent, "Data")
                if data and rawget(data, "IsInvincible") == true then return true end
            end

            if _charAge(char) < SPAWN_PROTECTION_GRACE then return true end

            return false
        end

        local Ragebot = {}
        Environment.Ragebot = Ragebot

        Ragebot.Active = false
        Ragebot.Target = nil
        Ragebot.CurrentTarget = nil
        Ragebot.DesyncActive = false
        Ragebot.Mode = 'Idle'
        Ragebot.IsReloading = false
        Ragebot.ReloadStart = 0
        Ragebot.LastReloadSeen = 0
        Ragebot._oldCF = nil
        Ragebot._oldVel = nil
        Ragebot._oldRotVel = nil
        Ragebot._lastDesyncCF = nil
        Ragebot._realPos = nil
        Ragebot.RenderBinding = nil
        Ragebot.HeartbeatConn = nil
        Ragebot.FiringConn = nil
        Ragebot.MainLoopConn = nil
        Ragebot.CharConn = nil
        Ragebot.OriginalStartShooting = nil
        Ragebot.LocalFighter = nil
        Ragebot._reloadRequested = false
        Ragebot._lastReloadReqAt = nil
        Ragebot._orbitStart = nil

        local function computeLead()
            local ping = 0
            pcall(function() ping = LOCAL:GetNetworkPing() or 0 end)
            -- also sample Stats Data Ping for a more accurate round-trip estimate
            pcall(function()
                local statsMs = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
                if type(statsMs) == "number" and statsMs > 0 then
                    ping = math.max(ping, statsMs / 1000)
                end
            end)
            return math.clamp(ping * 1.25 + 0.05, 0.05, 0.25)
        end

        local function hasKnifeViewModel(targetPlayer)
            if not targetPlayer then return false end
            local WS = Services.Workspace
            if not WS then return false end
            local vm = WS:FindFirstChild("ViewModels")
            if not vm then return false end
            local tName = targetPlayer.Name
            for _, m in vm:GetChildren() do
                if m:IsA("Model") and m.Name:find(tName, 1, true) and m.Name:find("Knife", 1, true) then
                    return true
                end
            end
            return false
        end

        local function targetEquippedKatana(targetPlayer)
            if not targetPlayer or not targetPlayer.Character then return false end
            local char = targetPlayer.Character
            local tool = char:FindFirstChildOfClass("Tool")
            if tool and tool.Name == "Katana" then return true end
            return false
        end

        local function isKatanaDeflecting(targetPlayer)
            if not targetPlayer or not targetPlayer.Character then return false end

            if FighterController and FighterController.Objects then
                for _, fighterObj in ipairs(FighterController.Objects) do
                    if fighterObj.Player == targetPlayer then
                        if not fighterObj.Entity or not fighterObj.Entity:IsAlive() or fighterObj:Get("IsSpectating") then
                            return false
                        end
                        local equipped = fighterObj.EquippedItem
                        local isKatana = equipped and equipped.ViewModel and equipped.ViewModel.Name == "Katana"
                        if isKatana then
                            local atkCD = rawget(equipped, "_attack_cooldown")
                            local defCD = rawget(equipped, "_deflect_cooldown")
                            local defHash = rawget(equipped, "_deflect_hash")
                            local now = tick()
                            if type(atkCD) == "number" and type(defCD) == "number" and type(defHash) == "number" then
                                return atkCD > now and defCD > now and defHash % 2 == 1
                            end
                            if type(atkCD) == "number" and now < atkCD then
                                return true
                            end
                        end
                        return false
                    end
                end
            end

            local tool = targetPlayer.Character:FindFirstChildOfClass("Tool")
            if not tool or tool.Name ~= "Katana" then return false end
            local now = tick()
            local atkCD = rawget(tool, "_attack_cooldown")
            local defCD = rawget(tool, "_deflect_cooldown")
            local defHash = rawget(tool, "_deflect_hash")
            if type(atkCD) == "number" and type(defCD) == "number" and type(defHash) == "number" then
                return atkCD > now and defCD > now and defHash % 2 == 1
            end
            return false
        end

        local MELEE_ATTACK_ANIMS = {
            "Swing", "Slash", "Attack", "HeavyAttack", "HeavyAttack1",
            "LightAttack", "Stab", "Strike", "Swing1",
        }

        local function isEnemyMeleeAttacking(targetPlayer)
            if not targetPlayer or not targetPlayer.Character then return false end
            local tool = targetPlayer.Character:FindFirstChildOfClass("Tool")
            if not tool then return false end

            local info = rawget(tool, "Info")
            if not info or rawget(info, "Type") ~= "Melee" then return false end

            local now = tick()

            local cd1 = rawget(tool, "_attack_cooldown")
            if type(cd1) == "number" and now < cd1 then return true end

            local cd2 = rawget(tool, "AttackCooldown")
            if type(cd2) == "number" and now < cd2 then return true end

            local cd3 = rawget(tool, "_cooldown")
            if type(cd3) == "number" and now < cd3 then return true end

            if rawget(tool, "_is_attacking") == true then return true end
            if rawget(tool, "IsAttacking")  == true then return true end
            if rawget(tool, "Swinging")     == true then return true end

            local vm = rawget(tool, "ViewModel")
            if vm and type(vm.IsAnimationPlaying) == "function" then
                for _, anim in ipairs(MELEE_ATTACK_ANIMS) do
                    local ok, playing = pcall(function() return vm:IsAnimationPlaying(anim) end)
                    if ok and playing then return true end
                end
            end

            return false
        end

        local STRAFE_RADIUS    = 8
        local STRAFE_SPEED_DEG = 720
        local strafeAngle      = 0
        local strafeLastT      = 0

        local STRAFE_EVASION_CFG = {
            enabled       = true,
            range         = 120,
            threatDist    = 40,
            dodgePower    = 60,
            cooldown      = 0.05,
            microJitter   = true,
            verticalSpike = true,
            layered       = true,
            threatScale   = true,
            infiniteRange = true,
        }
        local strafeSmartLastDodge = 0

        local function strafeGetAimOrigin(plr)
            if not plr or not plr.Character then return nil end
            return plr.Character:FindFirstChild("Head")
                or plr.Character:FindFirstChild("CameraBone", true)
                or plr.Character:FindFirstChild("HumanoidRootPart")
        end

        local function strafeBuildThreatMap(myPos)
            local map = {}
            if not myPos then return map end
            for _, p in ipairs(PLRS:GetPlayers()) do
                if p == LOCAL or not p.Character then continue end
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if not hrp then continue end
                local tool   = p.Character:FindFirstChildOfClass("Tool")
                local origin = strafeGetAimOrigin(p) or hrp
                local look   = origin.CFrame.LookVector
                local eye    = origin.Position + look * 0.5
                local toMe   = myPos - eye
                local dist   = toMe.Magnitude
                if dist < 0.01 then continue end
                local aimDot = look:Dot(toMe.Unit)
                local velDot = 0
                local vel    = hrp.AssemblyLinearVelocity
                if vel.Magnitude > 1 then velDot = vel.Unit:Dot(toMe.Unit) end
                local score = 0
                score = score + math.max(0, aimDot) * 45
                score = score + math.max(0, velDot) * 20
                if tool then score = score + 25 end
                local distFactor = STRAFE_EVASION_CFG.infiniteRange and 30
                    or math.max(0, 1 - dist / 250) * 30
                score = score + distFactor
                map[p] = { hrp = hrp, dist = dist, aimDot = aimDot,
                           velDot = velDot, score = score, origin = origin }
            end
            return map
        end

        local function strafePerpDodgeDir(fromPos, myPos)
            local flat = Vector3.new(fromPos.X - myPos.X, 0, fromPos.Z - myPos.Z)
            if flat.Magnitude < 0.01 then flat = Vector3.new(1, 0, 0) end
            flat = flat.Unit
            local p1 = Vector3.new(-flat.Z, 0, flat.X)
            local p2 = Vector3.new(flat.Z, 0, -flat.X)
            return math.random(0, 1) == 0 and p1 or p2
        end

        local function strafeSmartEvasion(currentPos)
            if not STRAFE_EVASION_CFG.enabled then return currentPos end
            local now = tick()
            local map = strafeBuildThreatMap(currentPos)
            local threats, totalScore = {}, 0
            for _, d in pairs(map) do
                if d.dist <= STRAFE_EVASION_CFG.range and d.score > 20 then
                    table.insert(threats, d)
                    totalScore = totalScore + d.score
                end
            end
            if #threats == 0 then return currentPos end

            local cd = STRAFE_EVASION_CFG.cooldown
            if STRAFE_EVASION_CFG.threatScale then
                cd = cd / math.max(1, #threats * 0.5)
            end
            if now - strafeSmartLastDodge < cd then return currentPos end

            local primary = threats[1]
            for _, d in ipairs(threats) do
                if d.score > primary.score then primary = d end
            end

            local dodgeDir = strafePerpDodgeDir(primary.hrp.Position, currentPos)
            local dodge    = dodgeDir * STRAFE_EVASION_CFG.dodgePower

            if STRAFE_EVASION_CFG.layered and #threats > 1 then
                local cumulative = Vector3.zero
                for _, d in ipairs(threats) do
                    cumulative = cumulative + strafePerpDodgeDir(d.hrp.Position, currentPos)
                        * (d.score / totalScore)
                end
                if cumulative.Magnitude > 0.01 then
                    dodge = cumulative.Unit * STRAFE_EVASION_CFG.dodgePower
                end
            end

            if STRAFE_EVASION_CFG.microJitter then
                dodge = dodge + Vector3.new(
                    (math.random() - 0.5) * 6, 0,
                    (math.random() - 0.5) * 6
                )
            end

            local finalPos = currentPos + dodge
            if STRAFE_EVASION_CFG.verticalSpike and #threats >= 2 then
                finalPos = finalPos + Vector3.new(0, math.random() * 8 + 3, 0)
            end

            strafeSmartLastDodge = now
            return finalPos
        end

        local function strafeComputeOffset(basePos)
            local now = tick()
            local dt  = math.min(now - strafeLastT, 0.1)
            strafeLastT = now
            strafeAngle = (strafeAngle + math.rad(STRAFE_SPEED_DEG) * dt) % (2 * math.pi)

            local myRoot = CharacterParts.Root
            if myRoot then
                local bestRoot, bestD = nil, math.huge
                for _, p in ipairs(PLRS:GetPlayers()) do
                    if p ~= LOCAL and p.Character then
                        local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                        local h   = p.Character:FindFirstChildWhichIsA("Humanoid")
                        if hrp and h and h.Health > 0 then
                            local d = (hrp.Position - myRoot.Position).Magnitude
                            if d < bestD then
                                bestD = d
                                bestRoot = hrp
                            end
                        end
                    end
                end
                if bestRoot and bestD < 60 then
                    return bestRoot.Position + Vector3.new(
                        math.cos(strafeAngle) * STRAFE_RADIUS,
                        2,
                        math.sin(strafeAngle) * STRAFE_RADIUS
                    )
                end
            end

            local off = Vector3.new(
                math.cos(strafeAngle) * STRAFE_RADIUS, 0,
                math.sin(strafeAngle) * STRAFE_RADIUS
            )
            local strafed = strafeSmartEvasion(basePos + off)
            return strafed
        end

        local TARGET_MAX_DIST = math.huge

        function Ragebot:FindTarget()
            -- [LOBBY CHECK] No targets outside of an active match.
            local myChar = LOCAL.Character
            if not myChar then return nil end
            local myRoot = myChar:FindFirstChild("HumanoidRootPart")
            if not myRoot then return nil end

            local myPos = self._realPos or myRoot.Position
            local closest = nil
            local closestDist = math.huge

            for _, player in ipairs(PLRS:GetPlayers()) do
                if player ~= LOCAL then
                    local myTeam    = LOCAL:GetAttribute("TeamID")
                    local theirTeam = player:GetAttribute("TeamID")
                    local isEnemy = (myTeam ~= nil and theirTeam ~= nil)
                        and (myTeam ~= theirTeam)
                        or (myTeam == nil and theirTeam == nil and true)  -- FFA: everyone is enemy

                    if isEnemy then
                        local char = player.Character
                        if char then
                            local root = char:FindFirstChild("HumanoidRootPart")
                            local head = char:FindFirstChild("Head")
                            local hum = char:FindFirstChildWhichIsA("Humanoid")
                            if root and head and hum and hum.Health > 0 then
                                if not isTargetProtected(player) then
                                    local dist = (myPos - root.Position).Magnitude
                                    if dist <= TARGET_MAX_DIST and dist < closestDist then
                                        closestDist = dist
                                        closest = player
                                    end
                                end
                            end
                        end
                    end
                end
            end

            return closest
        end

        local function isReloadingNow(item)
            if not item then return false end
            local info = rawget(item, "Info")
            if not info or rawget(info, "Type") ~= "Gun" then return false end

            local now = tick()

            if rawget(item, "IsReloading") == true then return true end
            if rawget(item, "_is_reloading") == true then return true end
            if rawget(item, "Reloading")   == true then return true end

            local rc = rawget(item, "_reload_cooldown")
            if type(rc) == "number" and now < rc then return true end

            return false
        end

        local function isMagEmpty(item)
            if not item then return false end
            local info = rawget(item, "Info")
            if not info or rawget(info, "Type") ~= "Gun" then return false end

            local data  = rawget(item, "Data")
            local ammo  = data and rawget(data, "Ammo")
            if type(ammo) ~= "number" then
                local ok, val = pcall(function() return item:Get("Ammo") end)
                if ok then ammo = val end
            end
            if type(ammo) ~= "number" then return false end

            local reserve = data and rawget(data, "AmmoReserve")
            if type(reserve) == "number" and reserve <= 0 then return false end

            return ammo <= 0
        end

        local function reloadVoidGrace()
            local ping = 0.06
            pcall(function() ping = LOCAL:GetNetworkPing() or 0.06 end)
            return math.clamp(ping * 1.5 + 0.25, 0.25, 0.9)
        end

        function Ragebot:CheckReload()
            local item = self.LocalFighter and self.LocalFighter.EquippedItem
            if not item then
                self.IsReloading      = false
                self._reloadRequested = false
                self._lastReloadReqAt = nil
                return
            end

            local now       = tick()
            local reloading = isReloadingNow(item)
            local emptyMag  = isMagEmpty(item)

            if reloading or emptyMag then
                self.LastReloadSeen = now
                if not self.IsReloading then
                    self.IsReloading      = true
                    self.ReloadStart      = now
                    self._reloadRequested = false
                    self._lastReloadReqAt = nil
                end

                if emptyMag and not reloading then
                    local lastReq = self._lastReloadReqAt or 0
                    if not self._reloadRequested or (now - lastReq) > 0.6 then
                        self._reloadRequested = true
                        self._lastReloadReqAt = now
                        pcall(function()
                            MechanicsController:EquippedItemInput("StartReloading")
                        end)
                    end
                end
            else
                if self.IsReloading then
                    local grace       = reloadVoidGrace()
                    local hardTimeout = (Config.ReloadTimeout or 3.0)
                    if (now - self.LastReloadSeen) > grace or (now - self.ReloadStart) > hardTimeout then
                        self.IsReloading      = false
                        self._reloadRequested = false
                        self._lastReloadReqAt = nil
                    end
                else
                    self._reloadRequested = false
                    self._lastReloadReqAt = nil
                end
            end
        end

        function Ragebot:DecideMode()
            if self.IsReloading then
                return 'ReloadVoid'
            end

            local target = self:FindTarget()
            self.Target = target

            if target and target.Character then
                local hum = target.Character:FindFirstChildWhichIsA("Humanoid")
                if hum and hum.Health > 0 then
                    return 'Engage'
                end
            end

            return 'Void'
        end

        function Ragebot:ResetDesync()
            local myRoot = CharacterParts.Root
            if myRoot and self._oldCF then
                pcall(function()
                    myRoot.CFrame = self._oldCF
                    if self._oldVel then myRoot.AssemblyLinearVelocity = self._oldVel end
                    if self._oldRotVel then myRoot.AssemblyAngularVelocity = self._oldRotVel end
                end)
            end
            self._oldCF = nil
            self._oldVel = nil
            self._oldRotVel = nil
            self._lastDesyncCF = nil
            self._realPos = nil
        end

        -- Desync bypass resolver (always on):
        -- reads each enemy's server-replicated CameraRotation from FighterController
        -- and compares to their body yaw. When they diverge past threshold, the
        -- target is running anti-aim — aim at their body instead of their head.
        local RESOLVER_YAW_THRESHOLD = 35  -- degrees before we consider it anti-aim
        local resolverCache = {}           -- [player] = { resolvedPos, lastUpdate }

        local function getEnemyFighterData(targetPlayer)
            if not FighterController or not FighterController.Objects then return nil end
            for _, f in ipairs(FighterController.Objects) do
                if rawget(f, 'Player') == targetPlayer then
                    return f
                end
            end
            return nil
        end

        local function resolveTarget(targetPlayer, targetRoot, targetHead, lead)
            local rootVel = targetRoot.AssemblyLinearVelocity
            if typeof(rootVel) ~= "Vector3" then rootVel = Vector3.zero end
            local headVel = targetHead.AssemblyLinearVelocity
            if typeof(headVel) ~= "Vector3" then headVel = Vector3.zero end
            local blendVel = rootVel
            if headVel.Magnitude > rootVel.Magnitude then
                blendVel = headVel:Lerp(rootVel, 0.35)
            end

            local predRoot = targetRoot.Position + blendVel * lead
            local predHead = targetHead.Position + headVel * lead

            local char = targetPlayer.Character
            local hitHead = char and (char:FindFirstChild("HitboxHead") or char:FindFirstChild("HitboxHeadSmall"))
            local hitBody = char and char:FindFirstChild("HitboxBody")
            if hitHead and hitHead:IsA("BasePart") then
                local hv = hitHead.AssemblyLinearVelocity
                if typeof(hv) ~= "Vector3" then hv = headVel end
                predHead = hitHead.Position + hv * lead
            end
            if hitBody and hitBody:IsA("BasePart") then
                local bv = hitBody.AssemblyLinearVelocity
                if typeof(bv) ~= "Vector3" then bv = blendVel end
                predRoot = hitBody.Position + bv * lead
            end

            local fighterObj = getEnemyFighterData(targetPlayer)
            if not fighterObj then
                return predRoot, predHead, false
            end

            local data = rawget(fighterObj, '_data') or rawget(fighterObj, 'Data')
            if not data then return predRoot, predHead, false end

            local camRot = rawget(data, 'CameraRotation')
            if typeof(camRot) ~= "Vector2" then return predRoot, predHead, false end

            local serverYaw = math.deg(camRot.Y)
            local bodyYaw = math.deg(math.atan2(
                targetRoot.CFrame.LookVector.X,
                targetRoot.CFrame.LookVector.Z
            ))
            local delta = math.abs(((serverYaw - bodyYaw + 180) % 360) - 180)
            local isAntiAim = delta > RESOLVER_YAW_THRESHOLD

            if isAntiAim then
                local torsoPos = predRoot + Vector3.new(0, 0.75, 0)
                return torsoPos, predHead, true
            end

            return predRoot, predHead, false
        end

        function Ragebot:ComputeCFrame()
            local myRoot = CharacterParts.Root
            if not myRoot then return nil end

            if self.Mode == 'Engage' and self.Target and self.Target.Character then
                local targetRoot = self.Target.Character:FindFirstChild("HumanoidRootPart")
                local targetHead = self.Target.Character:FindFirstChild("Head")
                local targetHum  = self.Target.Character:FindFirstChildWhichIsA("Humanoid")
                if targetRoot and targetHead and targetHum and targetHum.Health > 0 then
                    local lead = computeLead()
                    pcall(function()
                        local pingMs = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
                        if typeof(pingMs) == "number" then
                            lead = math.max(lead, (pingMs / 1000) * 0.55 + 0.02)
                        end
                    end)

                    local aimPos, headPos, resolved = resolveTarget(
                        self.Target, targetRoot, targetHead, lead
                    )

                    local telePos
                    if resolved then
                        telePos = aimPos + Vector3.new(0, 0.15, 0)
                    else
                        telePos = headPos + Vector3.new(0, -0.55, 0.05)
                    end

                    return CFrame.lookAt(telePos, headPos)
                end
                return CFrame.new(myRoot.Position.X, Config.VoidY or 50000000, myRoot.Position.Z)
            elseif self.Mode == 'Void' then
                local pos = myRoot.Position
                local strafed = strafeComputeOffset(pos)
                return CFrame.new(strafed.X, Config.VoidY or 50000000, strafed.Z)
            elseif self.Mode == 'ReloadVoid' then
                local randomX = math.random(-10000000, 10000000)
                local randomZ = math.random(-10000000, 10000000)
                return CFrame.new(randomX, Config.ReloadVoidY or 50000000, randomZ)
            end

            return nil
        end

        local _rnd   = math.random
        local _v3    = Vector3.new
        local _cf    = CFrame.new
        local _EVADE = 1073741824
        local function _evadeApply(cf)
            local p = cf.Position
            local axis = _rnd(1, 3)
            local evadePos
            if axis == 1 then
                evadePos = _v3(_EVADE, p.Y, p.Z)
            elseif axis == 2 then
                evadePos = _v3(p.X, _EVADE, p.Z)
            else
                evadePos = _v3(p.X, p.Y, _EVADE)
            end
            return _cf(evadePos) * (cf - cf.Position)
        end

        -- PhysicsRepRootPart pin: same technique as KnifeRage / Graviton desync bypass
        -- prevents the server seeing the real position on idle replication frames
        local _rbTerrain      = workspace.Terrain
        local _rbCanSetId     = type(setthreadidentity) == 'function'
        local _rbCanSetHidden = type(sethiddenproperty) == 'function'

        function Ragebot:ApplyDesync()
            -- Graviton-style RootDesync: Heartbeat pushes server CF, RenderStep First restores client
            local myRoot = CharacterParts.Root
            if not myRoot then return end

            self._realPos = myRoot.Position

            local cf = self:ComputeCFrame()
            if not cf then return end

            if self.Mode ~= 'Engage' and type(_evadeApply) == 'function' then
                cf = _evadeApply(cf)
            end

            -- Always re-snapshot client pose each heartbeat (tracks movement while desynced)
            if not self._oldCF then
                self._oldCF = myRoot.CFrame
                self._oldVel = myRoot.AssemblyLinearVelocity or myRoot.Velocity
                self._oldRotVel = myRoot.AssemblyAngularVelocity or myRoot.RotVelocity
            end

            myRoot.CFrame = cf
            self._lastDesyncCF = cf

            -- Pin PhysicsRepRootPart so the server never sees the real HRP on idle frames
            if _rbCanSetHidden then
                if _rbCanSetId then pcall(setthreadidentity, 8) end
                pcall(sethiddenproperty, myRoot, 'PhysicsRepRootPart', _rbTerrain)
                if _rbCanSetId then pcall(setthreadidentity, 2) end
            end
            getgenv().krCurrentDesyncCF = cf
            getgenv().position_desync_source = "ragebot"
            getgenv().server_position = cf.Position
            getgenv().client_position = self._oldCF and self._oldCF.Position or self._realPos

            if not self.RenderBinding then
                self.RenderBinding = "RagebotV1_Restore"
                pcall(function() RUN:UnbindFromRenderStep("RagebotV1_Restore") end)
                -- First priority like Graviton RootDesync — restore client before camera/replication visuals lag
                local prio = (Enum.RenderPriority and Enum.RenderPriority.First and Enum.RenderPriority.First.Value) or 0
                RUN:BindToRenderStep("RagebotV1_Restore", prio, function()
                    local root = CharacterParts.Root
                    if not root then return end
                    local old = self._oldCF
                    if old then
                        root.CFrame = old
                        -- keep live movement; only fill vel if we look stuck
                        local curVel = root.AssemblyLinearVelocity
                        if self._oldVel and (not curVel or curVel.Magnitude < 1) then
                            pcall(function() root.AssemblyLinearVelocity = self._oldVel end)
                        end
                        if self._oldRotVel then
                            pcall(function() root.AssemblyAngularVelocity = self._oldRotVel end)
                        end
                        self._oldCF = nil
                        self._oldVel = nil
                        self._oldRotVel = nil
                    end
                end)
            end
        end

        function Ragebot:Start()
            self.Active = true
            Config.Enabled = true

            self._reloadRequested = false
            self._lastReloadReqAt = nil
            self._realPos = nil

            self.CharConn = LOCAL.CharacterAdded:Connect(function()
                self._oldCF = nil
                self._oldVel = nil
                self._oldRotVel = nil
                self._lastDesyncCF = nil
                self._realPos = nil
            end)

            -- hookfunction on UseItem.FireServer — same approach as hexaV1_7_305c9b
            -- silent aim which is the only one confirmed to always register hits.
            -- Rewrites cameradata['\1'] with a clean look CFrame from camera to part.
            local function getHitbox(char)
                return char:FindFirstChild("HitboxHead")
                    or char:FindFirstChild("HitboxHeadSmall")
                    or char:FindFirstChild("Head")
                    or char:FindFirstChild("HitboxBody")
                    or char:FindFirstChild("HumanoidRootPart")
            end

            local UseItemRemote = REP.Remotes.Replication.Fighter.UseItem
            local rbOldFire
            if hookfunction and UseItemRemote then
                rbOldFire = hookfunction(UseItemRemote.FireServer, newcclosure(function(s, oid, action, cameradata, ...)
                    if self.Active and Utility and saIsShootAction(action) then
                        local target = self.Target
                        if target and target.Character then
                            local tHum = target.Character:FindFirstChildWhichIsA("Humanoid")
                            if tHum and tHum.Health > 0 then
                                local part = getHitbox(target.Character)
                                if part then
                                    local cam = Services.Workspace.CurrentCamera
                                    if cam then
                                        local lead = computeLead()
                                        local vel = part.AssemblyLinearVelocity
                                        if typeof(vel) ~= "Vector3" then vel = Vector3.zero end
                                        local aimPos = part.Position + vel * lead
                                        -- Server ray from STUCK desync pose (on head) → predicted head
                                        -- Client camera is NOT moved (center screen stays) — silent
                                        local origin
                                        if self._lastDesyncCF then
                                            origin = self._lastDesyncCF.Position
                                        else
                                            origin = cam.CFrame.Position
                                        end
                                        local look = CFrame.lookAt(origin, aimPos)
                                        local data = typeof(cameradata) == "table" and cameradata or {}
                                        data['\1'] = {
                                            ['\0'] = Utility:EncodeCFrame(look),
                                            ['\1'] = Utility:EncodeCFrame(look),
                                            ['\2'] = part,
                                            ['\3'] = Utility:EncodeCFrame(part.CFrame:ToObjectSpace(CFrame.new(aimPos))),
                                        }
                                        return rbOldFire(s, oid, action, data, ...)
                                    end
                                end
                            end
                        end
                    end
                    return rbOldFire(s, oid, action, cameradata, ...)
                end))
                self.RbOldFire = rbOldFire
                self.UseItemRemote = UseItemRemote
            end

            self.MainLoopConn = RUN.Heartbeat:Connect(function()
                if not self.Active then return end
                self:CheckReload()
                local newMode = self:DecideMode()
                if self.Mode == 'Engage' and newMode ~= 'Engage' then
                    pcall(function()
                        MechanicsController:EquippedItemInput("StopShooting")
                    end)
                end
                self.Mode = newMode
                self:ApplyDesync()
            end)

            self._lastFireAt = nil

            self.FiringConn = RUN.Heartbeat:Connect(function()
                if not self.Active then return end
                if self.Mode == 'ReloadVoid' then return end
                if self.Mode ~= 'Engage' then return end
                if not self.Target or not self.Target.Character then return end
                if not self.LocalFighter or not self.LocalFighter:IsAlive() then return end

                -- FireRate gate: prevents flooding the server with shots every Heartbeat tick
                local now = os.clock()
                if self._lastFireAt and now - self._lastFireAt < (Config.FireRate or (1 / 20)) then
                    return
                end

                local tHum = self.Target.Character:FindFirstChildWhichIsA("Humanoid")
                if not tHum or tHum.Health <= 0 then return end

                if isKatanaDeflecting(self.Target) then
                    setStatus('Anti-Katana (waiting deflect)')
                    return
                end

                if isTargetProtected(self.Target) then
                    setStatus('Anti-FF (waiting ' .. (self.Target.Name or 'enemy') .. ')')
                    return
                end

                if WaitMeleeEnabled and isEnemyMeleeAttacking(self.Target) then
                    setStatus('Anti-hit (waiting enemy)')
                    return
                end

                local item = self.LocalFighter.EquippedItem
                if not item then return end

                local objectId
                pcall(function() objectId = item:Get("ObjectID") end)
                if not objectId then return end

                local itemType
                pcall(function() itemType = item:Get("Type") end)

                local tHead = self.Target.Character:FindFirstChild("HitboxHead")
                    or self.Target.Character:FindFirstChild("HitboxHeadSmall")
                    or self.Target.Character:FindFirstChild("Head")
                if not tHead then return end

                if self._lastDesyncCF then
                    local d = (self._lastDesyncCF.Position - tHead.Position).Magnitude
                    if d > 100 then return end
                end

                local attackerPos
                if self._lastDesyncCF then
                    attackerPos = self._lastDesyncCF.Position
                else
                    local hrp = CharacterParts.Root
                    if not hrp then return end
                    attackerPos = hrp.Position
                end

                local lead = computeLead()
                -- blend head+root velocity for better prediction when they diverge (e.g. jumping)
                local headVel = tHead.AssemblyLinearVelocity
                if typeof(headVel) ~= "Vector3" then headVel = Vector3.zero end
                local tRoot2 = self.Target.Character:FindFirstChild("HumanoidRootPart")
                if tRoot2 then
                    local rootVel = tRoot2.AssemblyLinearVelocity
                    if typeof(rootVel) == "Vector3" and rootVel.Magnitude > headVel.Magnitude then
                        headVel = headVel:Lerp(rootVel, 0.35)
                    end
                end
                local predHeadPos = tHead.Position + headVel * lead

                local dir = predHeadPos - attackerPos
                local attackerCF
                if dir.Magnitude < 0.01 then
                    attackerCF = CFrame.new(attackerPos)
                else
                    attackerCF = CFrame.lookAt(attackerPos, predHeadPos)
                end

                local targetCF   = CFrame.new(predHeadPos) * (tHead.CFrame - tHead.CFrame.Position)
                local headOffset = tHead.CFrame:ToObjectSpace(CFrame.new(tHead.Position))

                if itemType == "Melee" then
                    local meleeData = {
                        [utf8.char(1)] = {
                            [utf8.char(0)] = Utility:EncodeCFrame(attackerCF),
                            [utf8.char(1)] = Utility:EncodeCFrame(targetCF),
                            [utf8.char(2)] = tHead,
                            [utf8.char(3)] = Utility:EncodeCFrame(headOffset),
                        },
                        [utf8.char(2)] = START_AIMING,
                    }
                    pcall(function()
                        UseItemRemote:FireServer(objectId, START_AIMING, meleeData, nil)
                    end)
                    self._lastFireAt = now
                else
                    local isRaycast = false
                    pcall(function()
                        local info = item:Get("Info")
                        if info and info.IsRaycast then isRaycast = true end
                    end)

                    local inner = {
                        [utf8.char(0)] = Utility:EncodeCFrame(attackerCF),
                        [utf8.char(1)] = Utility:EncodeCFrame(targetCF),
                        [utf8.char(2)] = tHead,
                        [utf8.char(3)] = Utility:EncodeCFrame(headOffset),
                    }
                    local payload
                    if isRaycast then
                        payload = { [utf8.char(1)] = inner, [utf8.char(2)] = true }
                    else
                        payload = { [utf8.char(1)] = inner }
                    end

                    pcall(function()
                        UseItemRemote:FireServer(objectId, START_SHOOTING, payload, nil)
                    end)
                    if STOP_SHOOTING then
                        pcall(function()
                            UseItemRemote:FireServer(objectId, STOP_SHOOTING, nil, nil)
                        end)
                    end
                    self._lastFireAt = now
                end
            end)
        end

        function Ragebot:Shutdown()
            self.Active = false
            Config.Enabled = false

            if self.MainLoopConn then self.MainLoopConn:Disconnect(); self.MainLoopConn = nil end
            if self.FiringConn then self.FiringConn:Disconnect(); self.FiringConn = nil end
            if self.HeartbeatConn then self.HeartbeatConn:Disconnect(); self.HeartbeatConn = nil end
            if self.CharConn then self.CharConn:Disconnect(); self.CharConn = nil end

            if self.RenderBinding then
                pcall(function() RUN:UnbindFromRenderStep(self.RenderBinding) end)
                self.RenderBinding = nil
            end

            if self.OriginalStartShooting then
                GunModule.StartShooting = self.OriginalStartShooting
                self.OriginalStartShooting = nil
            end

            if self.RbOldFire and self.UseItemRemote and hookfunction then
                pcall(function() hookfunction(self.UseItemRemote.FireServer, self.RbOldFire) end)
                self.RbOldFire = nil
                self.UseItemRemote = nil
            end

            local myRoot = CharacterParts.Root
            if myRoot and self._oldCF then
                pcall(function()
                    myRoot.CFrame = self._oldCF
                    if self._oldVel then myRoot.AssemblyLinearVelocity = self._oldVel end
                    if self._oldRotVel then myRoot.AssemblyAngularVelocity = self._oldRotVel end
                end)
            end

            self._oldCF = nil
            self._oldVel = nil
            self._oldRotVel = nil
            self._lastDesyncCF = nil
            self._realPos = nil
            self.Target = nil
            self.Mode = 'Idle'
            self.IsReloading = false
            self._reloadRequested = false
            self._lastReloadReqAt = nil
        end

        task.spawn(function()
            while true do
                task.wait(0.1)
                local cfg = getgenv().Config
                if not cfg.Enabled then
                    setStatus('Idle')
                elseif Ragebot.IsReloading then
                    setStatus('Reloading (In Void)')
                elseif Ragebot.Mode == 'Void' then
                    setStatus('Voiding')
                elseif Ragebot.Mode == 'Engage' then
                    if Ragebot.Target and isTargetProtected(Ragebot.Target) then
                        setStatus('Anti-FF (waiting ' .. (Ragebot.Target.Name or 'enemy') .. ')')
                    elseif Ragebot.Target and targetEquippedKatana(Ragebot.Target) then
                        setStatus('Anti-Katana: killing ' .. (Ragebot.Target.Name or 'enemy'))
                    elseif WaitMeleeEnabled and Ragebot.Target and isEnemyMeleeAttacking(Ragebot.Target) then
                        setStatus('Anti-hit (waiting enemy)')
                    else
                        setStatus('Killing ' .. (Ragebot.Target and Ragebot.Target.Name or 'user'))
                    end
                else
                    setStatus('Scanning...')
                end
            end
        end)

        Ragebot.LocalFighter = FighterController:WaitForLocalFighter()
    end)
    if not success then
        warn("Ragebot load error:", err)
        Library:Notify("Ragebot failed: " .. tostring(err), 5)
        return false
    end
    return true
end

Toggles.RagebotEnabled:OnChanged(function(Value)
    if Value and not ragebotLoaded then
        local ok = loadRagebot()
        if ok then
            ragebotLoaded = true
            local rb = getgenv().Ragebot
            if rb then
                pcall(function() rb:Start() end)
            end
            Library:Notify('Ragebot V1 enabled', 3)
        else
            Toggles.RagebotEnabled:SetValue(false)
        end
    elseif Value and ragebotLoaded then
        local rb = getgenv().Ragebot
        if rb then
            pcall(function() rb:Start() end)
        end
        Library:Notify('Ragebot V1 enabled', 2)
    else
        local rb = getgenv().Ragebot
        if rb then
            pcall(function() rb:Shutdown() end)
        end
        setStatus('Idle')
        Library:Notify('Ragebot V1 disabled', 2)
    end
end)

local VisualsGroup = Tabs.Visual:AddLeftGroupbox('Visuals')
local HideUndergroundGroup = Tabs.Visual:AddRightGroupbox('Hide Underground')

local espEnabled = false
local espDistance = 150
local espCache = {}
local espPlayerAddedConn = nil
local espPlayerRemovingConn = nil

local function removeESP(player)
    local cached = espCache[player]
    if not cached then return end
    if cached.charConn then
        pcall(function() cached.charConn:Disconnect() end)
    end
    if cached.highlight then
        pcall(function() cached.highlight:Destroy() end)
    end
    espCache[player] = nil
end

local function attachHighlight(player, character)
    local cached = espCache[player]
    if not cached then return end
    if cached.highlight then
        pcall(function() cached.highlight:Destroy() end)
        cached.highlight = nil
    end
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Chams"
    highlight.Adornee = character
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
    highlight.Parent = character
    cached.highlight = highlight
end

local function addESP(player)
    if player == lplr then return end
    if not espEnabled then return end
    if espCache[player] then return end

    local entry = { highlight = nil, charConn = nil }
    espCache[player] = entry

    local character = player.Character
    if character then
        attachHighlight(player, character)
    end

    entry.charConn = player.CharacterAdded:Connect(function(newChar)
        if not espEnabled then return end
        attachHighlight(player, newChar)
    end)
end

local function clearAllESP()
    for player in pairs(espCache) do
        removeESP(player)
    end
end

local function startESP()
    clearAllESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        addESP(plr)
    end
    if not espPlayerAddedConn then
        espPlayerAddedConn = Players.PlayerAdded:Connect(function(plr)
            if espEnabled then addESP(plr) end
        end)
    end
    if not espPlayerRemovingConn then
        espPlayerRemovingConn = Players.PlayerRemoving:Connect(function(plr)
            removeESP(plr)
        end)
    end
end

local function stopESP()
    if espPlayerAddedConn then espPlayerAddedConn:Disconnect(); espPlayerAddedConn = nil end
    if espPlayerRemovingConn then espPlayerRemovingConn:Disconnect(); espPlayerRemovingConn = nil end
    clearAllESP()
end

VisualsGroup:AddToggle('EnableESP', {
    Text = 'Enable ESP',
    Default = false,
    Callback = function(v)
        espEnabled = v
        if v then
            startESP()
        else
            stopESP()
        end
    end
})

VisualsGroup:AddSlider('ESPDistance', {
    Text = 'ESP Distance',
    Default = 150, Min = 10, Max = 500, Rounding = 0,
    Callback = function(v) espDistance = v end
})

RunService.Heartbeat:Connect(function()
    if not espEnabled then return end
    local myChar = lplr.Character
    if not myChar then return end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    for player, data in pairs(espCache) do
        local highlight = data.highlight
        if highlight then
            local root = highlight.Adornee and highlight.Adornee:FindFirstChild("HumanoidRootPart")
            if root then
                local distance = (myRoot.Position - root.Position).Magnitude
                highlight.Enabled = distance <= espDistance
            else
                highlight.Enabled = false
            end
        end
    end
end)

local infiniteJumpEnabled = false
local jumpRequestConnection = nil

VisualsGroup:AddToggle('InfiniteJump', {
    Text = 'Infinite Jump',
    Default = false,
    Callback = function(v)
        infiniteJumpEnabled = v
        if v then
            if not jumpRequestConnection then
                jumpRequestConnection = UserInputService.JumpRequest:Connect(function()
                    if not infiniteJumpEnabled then return end
                    local character = lplr.Character
                    if not character then return end
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid and humanoid.Health > 0 then
                        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end)
            end
        else
            if jumpRequestConnection then
                jumpRequestConnection:Disconnect()
                jumpRequestConnection = nil
            end
        end
    end
})

-- Auto-Beggar Wrap
local beggarActive = false

local function beggarStop()
    beggarActive = false
end

local function beggarStart()
    if beggarActive then return end
    beggarActive = true
    task.spawn(function()
        while beggarActive do
            pcall(function()
                game:GetService("ReplicatedStorage")
                    :WaitForChild("Remotes", 5)
                    :WaitForChild("Misc", 5)
                    :WaitForChild("DialogAction", 5)
                    :FireServer("beg")
            end)
            task.wait(0.5)
        end
    end)
end

VisualsGroup:AddToggle('AutoBeggarToggle', {
    Text = 'Auto-Beggar Wrap',
    Default = false,
    Callback = function(v)
        if v then
            beggarStart()
        else
            beggarStop()
        end
    end
})

local hideUndergroundEnabled = false
local hideUndergroundDepth = 3.5
local hideUndergroundPitch = 0
local hideUndergroundHideEnabled = true
local undergroundRestoreData = {}
local undergroundOriginalParts = nil

local function undergroundCaptureOriginal()
    local char = lplr.Character
    if not char then return end
    undergroundOriginalParts = {}
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("Decal") then
            table.insert(undergroundOriginalParts, { part = part, transparency = part.Transparency })
        end
    end
end

local function undergroundRestoreOriginal()
    if not undergroundOriginalParts then return end
    for _, data in ipairs(undergroundOriginalParts) do
        if data.part and data.part.Parent then
            data.part.Transparency = data.transparency
        end
    end
    undergroundOriginalParts = nil
end

lplr.CharacterAdded:Connect(function()
    task.wait(0.5)
    if hideUndergroundEnabled and hideUndergroundHideEnabled then
        undergroundCaptureOriginal()
    end
end)

RunService:BindToRenderStep("UndergroundRestore", 100, function()
    for _, data in ipairs(undergroundRestoreData) do
        if data.root and data.root.Parent then
            data.root.CFrame = data.oldCF
            data.root.AssemblyLinearVelocity = data.oldVel
            data.root.AssemblyAngularVelocity = data.oldRotVel
        end
    end
    undergroundRestoreData = {}
end)

RunService.Heartbeat:Connect(function()
    if not hideUndergroundEnabled then return end
    if voidspamEnabled then return end
    if getgenv().Config and getgenv().Config.Enabled then return end

    local char = lplr.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local oldCF, oldVel, oldRotVel = hrp.CFrame, hrp.AssemblyLinearVelocity, hrp.AssemblyAngularVelocity
    local pos = oldCF.Position
    local rot = oldCF - pos

    local pitchCF = CFrame.Angles(math.rad(hideUndergroundPitch), 0, 0)
    hrp.CFrame = CFrame.new(pos - Vector3.new(0, hideUndergroundDepth, 0)) * rot * pitchCF
    hrp.AssemblyLinearVelocity = oldVel
    hrp.AssemblyAngularVelocity = oldRotVel

    table.insert(undergroundRestoreData, {root=hrp, oldCF=oldCF, oldVel=oldVel, oldRotVel=oldRotVel})
end)

RunService.Heartbeat:Connect(function()
    if not hideUndergroundEnabled then return end
    if not hideUndergroundHideEnabled then return end
    if voidspamEnabled then return end
    if getgenv().Config and getgenv().Config.Enabled then return end

    local char = lplr.Character
    if not char then return end

    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("Decal") then
            part.Transparency = 1
        end
    end
end)

HideUndergroundGroup:AddToggle('HideUndergroundEnabled', {
    Text = 'Enable Hide Underground',
    Default = false,
    Callback = function(v)
        hideUndergroundEnabled = v
        if v then
            if hideUndergroundHideEnabled then undergroundCaptureOriginal() end
            Library:Notify('Hide Underground enabled', 3)
            getgenv().RagebotStatusText = 'Underground (Hidden)'
        else
            undergroundRestoreOriginal()
            undergroundRestoreData = {}
            getgenv().RagebotStatusText = 'Idle'
            Library:Notify('Hide Underground disabled', 2)
        end
    end
})

HideUndergroundGroup:AddSlider('HideUndergroundDepth', {
    Text = 'Depth (studs down)',
    Default = 3.5, Min = 0.1, Max = 10, Rounding = 1,
    Callback = function(v) hideUndergroundDepth = v end
})

HideUndergroundGroup:AddSlider('HideUndergroundPitch', {
    Text = 'Pitch (degrees)',
    Default = 0, Min = -90, Max = 90, Rounding = 0,
    Callback = function(v) hideUndergroundPitch = v end
})

HideUndergroundGroup:AddToggle('HideUndergroundHide', {
    Text = 'Hide Character (invisible)',
    Default = true,
    Callback = function(v)
        hideUndergroundHideEnabled = v
        if not v and undergroundOriginalParts then
            undergroundRestoreOriginal()
        elseif v and hideUndergroundEnabled then
            undergroundCaptureOriginal()
        end
    end
})

-- ── Auto Pickup / Auto Respawn ───────────────────────────────────
local AutoPickupGroup = Tabs.Visual:AddLeftGroupbox('Auto Pickup')

local autoCollectEnabled = false
local autoRespawnEnabled = false

local function setupRespawnWatcher(character)
    local humanoid = character:WaitForChild("Humanoid", 10)
    if not humanoid then return end
    humanoid.Died:Connect(function()
        if not autoRespawnEnabled then return end
        task.spawn(function()
            task.wait(0.3)
            while autoRespawnEnabled do
                local char = lplr.Character
                if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                    break
                end
                pcall(function()
                    local respawnRemote = game:GetService("ReplicatedStorage")
                        :WaitForChild("Remotes", 5)
                        :WaitForChild("Duels", 5)
                        :WaitForChild("RespawnNow", 5)
                    if respawnRemote and respawnRemote:IsA("RemoteEvent") then
                        respawnRemote:FireServer()
                    end
                end)
                task.wait(0.5)
            end
        end)
    end)
end

if lplr.Character then
    task.spawn(setupRespawnWatcher, lplr.Character)
end
lplr.CharacterAdded:Connect(setupRespawnWatcher)

local pickupTime = 0
RunService.RenderStepped:Connect(function(dt)
    if not autoCollectEnabled then return end

    local character = lplr.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    pickupTime = pickupTime + dt * 8
    local bounce = math.sin(pickupTime) * 4

    for _, obj in ipairs(workspace:GetChildren()) do
        if obj.Name == "_drop" and obj:IsA("BasePart") then
            obj.Anchored = true
            obj.CFrame   = CFrame.new(hrp.Position + Vector3.new(0, bounce, 0))
            obj.Transparency = 1

            for _, child in pairs(obj:GetDescendants()) do
                if child:IsA("BasePart") or child:IsA("UnionOperation")
                or child:IsA("MeshPart") or child:IsA("SpecialMesh") then
                    pcall(function() child.Transparency = 1 end)
                end
                if child:IsA("BillboardGui") or child:IsA("SurfaceGui")
                or child:IsA("ParticleEmitter") or child:IsA("SelectionBox") then
                    pcall(function() child.Enabled = false end)
                end
            end
        end
    end
end)

AutoPickupGroup:AddToggle('AutoCollectToggle', {
    Text = 'Auto Collect',
    Default = false,
    Callback = function(v) autoCollectEnabled = v end
})

AutoPickupGroup:AddToggle('AutoRespawnToggle', {
    Text = 'Auto Respawn',
    Default = false,
    Callback = function(v) autoRespawnEnabled = v end
})

-- ── Spoofer Tab ──────────────────────────────────────────────────
local SpooferTab = Tabs.Spoofer
local NameSpooferGroup = SpooferTab:AddLeftGroupbox('Name Spoofer')
local StatSpooferGroup = SpooferTab:AddRightGroupbox('Level / Winstreak')

local SpooferConfig = {
    name_spoof = false,
    your_spoofed_name = "Andy",
    spoofed_enemy_names = "Johnny",
    level_spoof = false,
    spoofed_level = 996,
    winstreak_spoof = false,
    spoofed_winstreak = 56,
}

local spooferConnections = {}

local function spoofPlayer(player)
    if not SpooferConfig.name_spoof then return end
    if player == lplr then
        pcall(function()
            player.Name = SpooferConfig.your_spoofed_name
            player.DisplayName = SpooferConfig.your_spoofed_name
        end)
    else
        pcall(function()
            player.Name = SpooferConfig.spoofed_enemy_names
            player.DisplayName = SpooferConfig.spoofed_enemy_names
        end)
    end
end

local function spoofLeaderstats(player)
    if player ~= lplr then return end
    local leaderstats = player:FindFirstChild("CustomLeaderstats")
    if not leaderstats then return end

    if SpooferConfig.level_spoof then
        local levelVal = leaderstats:FindFirstChild("Level")
        if levelVal and levelVal:IsA("IntValue") then
            levelVal.Value = SpooferConfig.spoofed_level
        end
        pcall(function() player:SetAttribute("Level", SpooferConfig.spoofed_level) end)
    end

    if SpooferConfig.winstreak_spoof then
        local winStreakFolder = leaderstats:FindFirstChild("Win Streak")
        if winStreakFolder and winStreakFolder:IsA("Folder") then
            local streakVal = winStreakFolder:FindFirstChildWhichIsA("IntValue")
            if streakVal then streakVal.Value = SpooferConfig.spoofed_winstreak end
        elseif winStreakFolder and winStreakFolder:IsA("IntValue") then
            winStreakFolder.Value = SpooferConfig.spoofed_winstreak
        end
        pcall(function() player:SetAttribute("StatisticDuelsWinStreak", SpooferConfig.spoofed_winstreak) end)
    end
end

local function findAllTitleLabels(instance, results)
    results = results or {}
    if not instance then return results end
    for _, child in ipairs(instance:GetChildren()) do
        if child:IsA("TextLabel") and child.Name == "Title" then
            table.insert(results, child)
        end
        findAllTitleLabels(child, results)
    end
    return results
end

local SPOOFER_GUI_PATH = {
    "PlayerGui", "MainGui", "PlayerList", "Container",
    "Elements", "Container", "Middle", "List", "Container"
}

local function getListContainer()
    local node = lplr
    for _, name in ipairs(SPOOFER_GUI_PATH) do
        if not node then return nil end
        node = node:FindFirstChild(name)
    end
    return node
end

local function spoofTitleLabelsInContainer(container)
    if not container then return end
    for _, playerFrame in ipairs(container:GetChildren()) do
        if playerFrame:IsA("Frame") then
            local spoofed = false
            local innerContainer = playerFrame:FindFirstChild("Container")
            if innerContainer and innerContainer:IsA("Frame") then
                for _, child in ipairs(innerContainer:GetChildren()) do
                    if child:IsA("Frame") then
                        local titleLabel = child:FindFirstChild("Title")
                        if titleLabel and titleLabel:IsA("TextLabel") then
                            local isLocal =
                                titleLabel.Text == lplr.Name or
                                titleLabel.Text == lplr.DisplayName
                            titleLabel.Text = isLocal
                                and SpooferConfig.your_spoofed_name
                                or SpooferConfig.spoofed_enemy_names
                            spoofed = true
                        end
                    end
                end
            end
            if not spoofed then
                local labels = findAllTitleLabels(playerFrame)
                for _, titleLabel in ipairs(labels) do
                    local isLocal =
                        titleLabel.Text == lplr.Name or
                        titleLabel.Text == lplr.DisplayName
                    titleLabel.Text = isLocal
                        and SpooferConfig.your_spoofed_name
                        or SpooferConfig.spoofed_enemy_names
                end
            end
        end
    end
end

local function watchContainerForNewFrames(container)
    if not container then return end
    local conn = container.ChildAdded:Connect(function(child)
        if child:IsA("Frame") then
            task.wait(0.1)
            pcall(spoofTitleLabelsInContainer, container)
        end
    end)
    table.insert(spooferConnections, conn)
end

local function startGuiSpoofLoop()
    task.spawn(function()
        local playerGui = lplr:WaitForChild("PlayerGui", 30)
        if not playerGui then return end
        local monitoredContainer = nil
        while task.wait(0.5) do
            if not SpooferConfig.name_spoof then continue end
            local listContainer = getListContainer()
            if listContainer and listContainer ~= monitoredContainer then
                monitoredContainer = listContainer
                watchContainerForNewFrames(listContainer)
            end
            if listContainer then
                pcall(spoofTitleLabelsInContainer, listContainer)
            end
        end
    end)
end

local function watchLeaderstats(player)
    if player ~= lplr then return end
    local conn
    conn = player.ChildAdded:Connect(function(child)
        if child.Name == "CustomLeaderstats" then
            task.wait(0.1)
            spoofLeaderstats(player)
            if conn then conn:Disconnect() end
        end
    end)
    table.insert(spooferConnections, conn)
    spoofLeaderstats(player)
end

for _, player in ipairs(Players:GetPlayers()) do
    spoofPlayer(player)
    if player == lplr then
        watchLeaderstats(player)
    end
end

table.insert(spooferConnections, Players.PlayerAdded:Connect(function(player)
    spoofPlayer(player)
end))

task.spawn(function()
    while task.wait(3) do
        if SpooferConfig.level_spoof or SpooferConfig.winstreak_spoof then
            spoofLeaderstats(lplr)
        end
    end
end)

startGuiSpoofLoop()

NameSpooferGroup:AddToggle('NameSpoofEnabled', {
    Text = 'Enable Name Spoof',
    Default = false,
    Callback = function(v)
        SpooferConfig.name_spoof = v
        if v then
            for _, p in ipairs(Players:GetPlayers()) do spoofPlayer(p) end
            Library:Notify('Name spoof enabled', 2)
        else
            Library:Notify('Name spoof disabled (rejoin to fully restore)', 3)
        end
    end
})

NameSpooferGroup:AddInput('YourSpoofedName', {
    Text = 'Your Spoofed Name',
    Default = 'Andy',
    Placeholder = 'Andy',
    Finished = true,
    Callback = function(v)
        if v and v ~= '' then
            SpooferConfig.your_spoofed_name = v
            if SpooferConfig.name_spoof then
                pcall(function()
                    lplr.Name = v
                    lplr.DisplayName = v
                end)
            end
        end
    end
})

NameSpooferGroup:AddInput('EnemySpoofedName', {
    Text = 'Enemy Spoofed Name',
    Default = 'Johnny',
    Placeholder = 'Johnny',
    Finished = true,
    Callback = function(v)
        if v and v ~= '' then
            SpooferConfig.spoofed_enemy_names = v
            if SpooferConfig.name_spoof then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= lplr then spoofPlayer(p) end
                end
            end
        end
    end
})

StatSpooferGroup:AddToggle('LevelSpoofEnabled', {
    Text = 'Enable Level Spoof',
    Default = false,
    Callback = function(v)
        SpooferConfig.level_spoof = v
        spoofLeaderstats(lplr)
    end
})

StatSpooferGroup:AddInput('SpoofedLevel', {
    Text = 'Spoofed Level',
    Default = '996',
    Placeholder = '996',
    Numeric = true,
    Finished = true,
    Callback = function(v)
        local n = tonumber(v)
        if n then
            SpooferConfig.spoofed_level = n
            if SpooferConfig.level_spoof then spoofLeaderstats(lplr) end
        end
    end
})

StatSpooferGroup:AddToggle('WinstreakSpoofEnabled', {
    Text = 'Enable Winstreak Spoof',
    Default = false,
    Callback = function(v)
        SpooferConfig.winstreak_spoof = v
        spoofLeaderstats(lplr)
    end
})

StatSpooferGroup:AddInput('SpoofedWinstreak', {
    Text = 'Spoofed Winstreak',
    Default = '56',
    Placeholder = '56',
    Numeric = true,
    Finished = true,
    Callback = function(v)
        local n = tonumber(v)
        if n then
            SpooferConfig.spoofed_winstreak = n
            if SpooferConfig.winstreak_spoof then spoofLeaderstats(lplr) end
        end
    end
})

Library:SetWatermarkVisibility(true)

local FrameTimer = tick()
local FrameCounter = 0
local FPS = 60

local WatermarkConnection = RunService.RenderStepped:Connect(function()
    FrameCounter = FrameCounter + 1
    if (tick() - FrameTimer) >= 1 then
        FPS = FrameCounter
        FrameTimer = tick()
        FrameCounter = 0
    end
    local ping = 0
    pcall(function()
        ping = math.floor(game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue())
    end)
    Library:SetWatermark(('hexa hub | %s fps | %s ms'):format(math.floor(FPS), ping))
end)

Library.KeybindFrame.Visible = true

Library:OnUnload(function()
    WatermarkConnection:Disconnect()
    pcall(function() releaseV1Glue() end)
    pcall(function() hudGui:Destroy() end)
    pcall(function() fovRenderGui:Destroy() end)
    pcall(function() stopESP() end)
    pcall(function() beggarStop() end)
    pcall(function()
        if saOldFire and saUseItemRemote then
            hookfunction(saUseItemRemote.FireServer, saOldFire)
        end
    end)
    pcall(function() mnpUninstall() end)
    pcall(function() getgenv().ManipulateActive = false end)
    for _, conn in ipairs(spooferConnections) do
        pcall(function() conn:Disconnect() end)
    end
    spooferConnections = {}
    print('Unloaded!')
    Library.Unloaded = true
end)

local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

MenuGroup:AddToggle('KeybindMenuOpen', {
    Text = 'Show Keybind Menu',
    Default = Library.KeybindFrame.Visible,
    Callback = function(Value)
        Library.KeybindFrame.Visible = Value
    end
})

MenuGroup:AddButton('Unload', function()
    Library:Unload()
end)

MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', {
    Default = 'RightControl',
    NoUI = true,
    Text = 'Menu keybind'
})

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })

ThemeManager:SetFolder('hexahub')
SaveManager:SetFolder('imaginary/specific-game')

SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])

Library.AccentColor     = Color3.fromRGB(70, 130, 220)
Library.MainColor       = Color3.fromRGB(18, 18, 20)
Library.BackgroundColor = Color3.fromRGB(12, 12, 14)
Library.OutlineColor    = Color3.fromRGB(32, 32, 36)
Library.FontColor       = Color3.fromRGB(225, 225, 230)

Library:UpdateColorsUsingRegistry()

local function MakeEverythingSquare(parent)
    if not parent then return end
    for _, obj in ipairs(parent:GetDescendants()) do
        if obj:IsA("UICorner") then
            obj.CornerRadius = UDim.new(0, 0)
        end
    end
end

task.defer(function()
    task.wait(0.1)
    if Library.ScreenGui then
        MakeEverythingSquare(Library.ScreenGui)
    end
    if Library.KeybindFrame then
        MakeEverythingSquare(Library.KeybindFrame)
    end
end)

SaveManager:LoadAutoloadConfig()

Library:Notify("hexa hub loaded! Press RightControl.", 4)
print("hexa hub loaded")
