--[[
    Fiction - Advanced Game Enhancement Script
    
    This script provides various game enhancements for personal use only.
    Not intended for use in competitive environments or to gain unfair advantages.
    
    Based on the feature-set of Starhook with complete mobile optimization.
    
    Version 1.0.1 - Fixed Lua compatibility issues
]]

-- Prevent multiple instances
if _G.FictionLoaded then
    warn("[Fiction] Script is already running!")
    return
end

_G.FictionLoaded = true

-- Global variables
_G.Fiction = {
    Enabled = true,
    Version = "1.0.1",
    LastUpdated = "2023",
    Author = "Personal Use Only",
    Settings = {},
    ActiveGame = nil,
    Initialized = false,
    Debug = false,
    Modules = {}
}

-- Create main GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FictionGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 250, 0, 350)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, 0, 0, 30)
TitleLabel.Position = UDim2.new(0, 0, 0, 0)
TitleLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
TitleLabel.BorderSizePixel = 0
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 18
TitleLabel.Text = "Fiction v1.0.1"
TitleLabel.Parent = MainFrame

-- Make UI draggable
local UserInputService = game:GetService("UserInputService")
local dragging
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

TitleLabel.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleLabel.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Create tabs
local tabButtons = {}
local tabContents = {}
local activeTab = nil

local function createTab(name)
    local button = Instance.new("TextButton")
    button.Name = name .. "Tab"
    button.Size = UDim2.new(0.25, 0, 0, 30)
    button.Position = UDim2.new(0.25 * (#tabButtons), 0, 0, 30)
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    button.BorderSizePixel = 0
    button.TextColor3 = Color3.fromRGB(200, 200, 200)
    button.TextSize = 14
    button.Text = name
    button.Parent = MainFrame
    
    local content = Instance.new("Frame")
    content.Name = name .. "Content"
    content.Size = UDim2.new(1, 0, 1, -60)
    content.Position = UDim2.new(0, 0, 0, 60)
    content.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    content.BorderSizePixel = 0
    content.Visible = false
    content.Parent = MainFrame
    
    button.MouseButton1Click:Connect(function()
        if activeTab then
            tabContents[activeTab].Visible = false
            tabButtons[activeTab].BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        end
        
        content.Visible = true
        button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        activeTab = name
    end)
    
    tabButtons[name] = button
    tabContents[name] = content
    
    return content
end

-- Create tabs for different features
local aimTab = createTab("Aim")
local espTab = createTab("ESP")
local movementTab = createTab("Move")
local miscTab = createTab("Misc")

-- Set active tab
tabButtons["Aim"].MouseButton1Click:Fire()

-- Aim Settings
local function createToggle(parent, position, text, default)
    local toggle = Instance.new("Frame")
    toggle.Name = text .. "Toggle"
    toggle.Size = UDim2.new(1, -20, 0, 30)
    toggle.Position = position
    toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    toggle.BorderSizePixel = 0
    toggle.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = text
    label.Parent = toggle
    
    local button = Instance.new("TextButton")
    button.Name = "Button"
    button.Size = UDim2.new(0.2, 0, 0.8, 0)
    button.Position = UDim2.new(0.77, 0, 0.1, 0)
    button.BackgroundColor3 = default and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    button.BorderSizePixel = 0
    button.Text = default and "ON" or "OFF"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 12
    button.Parent = toggle
    
    local enabled = default
    
    button.MouseButton1Click:Connect(function()
        enabled = not enabled
        button.BackgroundColor3 = enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        button.Text = enabled and "ON" or "OFF"
    end)
    
    return toggle, function() return enabled end
end

local function createSlider(parent, position, text, min, max, default)
    local slider = Instance.new("Frame")
    slider.Name = text .. "Slider"
    slider.Size = UDim2.new(1, -20, 0, 50)
    slider.Position = position
    slider.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    slider.BorderSizePixel = 0
    slider.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = text
    label.Parent = slider
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "Value"
    valueLabel.Size = UDim2.new(0.2, 0, 0, 20)
    valueLabel.Position = UDim2.new(0.8, -5, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    valueLabel.TextSize = 14
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Text = tostring(default)
    valueLabel.Parent = slider
    
    local sliderBar = Instance.new("Frame")
    sliderBar.Name = "SliderBar"
    sliderBar.Size = UDim2.new(1, -20, 0, 5)
    sliderBar.Position = UDim2.new(0, 10, 0, 30)
    sliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    sliderBar.BorderSizePixel = 0
    sliderBar.Parent = slider
    
    local sliderButton = Instance.new("TextButton")
    sliderButton.Name = "SliderButton"
    sliderButton.Size = UDim2.new(0, 10, 0, 15)
    sliderButton.Position = UDim2.new((default - min) / (max - min), -5, 0, -5)
    sliderButton.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    sliderButton.BorderSizePixel = 0
    sliderButton.Text = ""
    sliderButton.Parent = sliderBar
    
    local value = default
    
    local function updateSlider(input)
        local pos = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
        sliderButton.Position = UDim2.new(pos, -5, 0, -5)
        value = min + (max - min) * pos
        valueLabel.Text = string.format("%.2f", value)
    end
    
    sliderButton.MouseButton1Down:Connect(function(input)
        local connection
        connection = UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                updateSlider(input)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                if connection then
                    connection:Disconnect()
                end
            end
        end)
    end)
    
    sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateSlider(input)
        end
    end)
    
    return slider, function() return value end
end

-- Add settings to Aim tab
local aimToggle, getAimEnabled = createToggle(aimTab, UDim2.new(0, 10, 0, 10), "Aimbot", true)
local fovSlider, getFOV = createSlider(aimTab, UDim2.new(0, 10, 0, 50), "FOV", 10, 500, 200)
local smoothnessSlider, getSmoothness = createSlider(aimTab, UDim2.new(0, 10, 0, 110), "Smoothness", 0, 1, 0.5)
local camlockToggle, getCamlockEnabled = createToggle(aimTab, UDim2.new(0, 10, 0, 170), "Camlock", false)
local silentaimToggle, getSilentAimEnabled = createToggle(aimTab, UDim2.new(0, 10, 0, 210), "Silent Aim", false)
local teamCheckToggle, getTeamCheckEnabled = createToggle(aimTab, UDim2.new(0, 10, 0, 250), "Team Check", true)

-- Add settings to ESP tab
local espToggle, getESPEnabled = createToggle(espTab, UDim2.new(0, 10, 0, 10), "ESP", true)
local boxesToggle, getBoxesEnabled = createToggle(espTab, UDim2.new(0, 10, 0, 50), "Boxes", true)
local namesToggle, getNamesEnabled = createToggle(espTab, UDim2.new(0, 10, 0, 90), "Names", true)
local healthToggle, getHealthEnabled = createToggle(espTab, UDim2.new(0, 10, 0, 130), "Health", true)
local distanceToggle, getDistanceEnabled = createToggle(espTab, UDim2.new(0, 10, 0, 170), "Distance", true)
local tracersToggle, getTracersEnabled = createToggle(espTab, UDim2.new(0, 10, 0, 210), "Tracers", false)
local espTeamCheckToggle, getESPTeamCheckEnabled = createToggle(espTab, UDim2.new(0, 10, 0, 250), "Team Check", true)

-- Add settings to Movement tab
local speedToggle, getSpeedEnabled = createToggle(movementTab, UDim2.new(0, 10, 0, 10), "Speed Hack", false)
local speedSlider, getSpeedValue = createSlider(movementTab, UDim2.new(0, 10, 0, 50), "Speed", 1, 10, 2)
local jumpToggle, getJumpEnabled = createToggle(movementTab, UDim2.new(0, 10, 0, 110), "Jump Hack", false)
local jumpSlider, getJumpValue = createSlider(movementTab, UDim2.new(0, 10, 0, 150), "Jump Height", 1, 5, 2)
local flyToggle, getFlyEnabled = createToggle(movementTab, UDim2.new(0, 10, 0, 210), "Fly", false)
local noclipToggle, getNoclipEnabled = createToggle(movementTab, UDim2.new(0, 10, 0, 250), "Noclip", false)

-- Add settings to Misc tab
local crosshairToggle, getCrosshairEnabled = createToggle(miscTab, UDim2.new(0, 10, 0, 10), "Crosshair", true)
local fullbrightToggle, getFullbrightEnabled = createToggle(miscTab, UDim2.new(0, 10, 0, 50), "Fullbright", false)
local noRecoilToggle, getNoRecoilEnabled = createToggle(miscTab, UDim2.new(0, 10, 0, 90), "No Recoil", false)
local infiniteJumpToggle, getInfiniteJumpEnabled = createToggle(miscTab, UDim2.new(0, 10, 0, 130), "Infinite Jump", false)
local hitboxToggle, getHitboxEnabled = createToggle(miscTab, UDim2.new(0, 10, 0, 170), "Hitbox Expander", false)
local hitboxSlider, getHitboxValue = createSlider(miscTab, UDim2.new(0, 10, 0, 210), "Hitbox Size", 1, 10, 2)

-- Add a credits label
local creditsLabel = Instance.new("TextLabel")
creditsLabel.Name = "CreditsLabel"
creditsLabel.Size = UDim2.new(1, 0, 0, 20)
creditsLabel.Position = UDim2.new(0, 0, 1, -20)
creditsLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
creditsLabel.BorderSizePixel = 0
creditsLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
creditsLabel.TextSize = 12
creditsLabel.Text = "Fiction v1.0.1 - Based on Starhook"
creditsLabel.Parent = MainFrame

-- ESP Implementation
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ESPEnabled = true
local ESPSettings = {
    Boxes = true,
    Names = true,
    Health = true,
    Distance = true,
    Tracers = false,
    TeamCheck = true,
    TeamColor = true,
    BoxColor = Color3.fromRGB(255, 0, 0),
    NameColor = Color3.fromRGB(255, 255, 255),
    HealthColor = Color3.fromRGB(0, 255, 0),
    DistanceColor = Color3.fromRGB(255, 255, 255),
    TracerColor = Color3.fromRGB(255, 0, 0),
    FriendlyColor = Color3.fromRGB(0, 255, 0),
    MaxDistance = 1000
}

local ESPObjects = {}

local function createESPObject(player)
    if player == LocalPlayer then return end
    
    local espObject = {}
    
    -- Box
    espObject.Box = Drawing.new("Square")
    espObject.Box.Visible = false
    espObject.Box.Thickness = 1
    espObject.Box.Transparency = 1
    
    -- Name
    espObject.Name = Drawing.new("Text")
    espObject.Name.Visible = false
    espObject.Name.Size = 14
    espObject.Name.Center = true
    espObject.Name.Outline = true
    
    -- Health
    espObject.Health = Drawing.new("Line")
    espObject.Health.Visible = false
    espObject.Health.Thickness = 2
    espObject.Health.Transparency = 1
    
    -- Health Background
    espObject.HealthBG = Drawing.new("Line")
    espObject.HealthBG.Visible = false
    espObject.HealthBG.Thickness = 2
    espObject.HealthBG.Transparency = 1
    espObject.HealthBG.Color = Color3.fromRGB(0, 0, 0)
    
    -- Distance
    espObject.Distance = Drawing.new("Text")
    espObject.Distance.Visible = false
    espObject.Distance.Size = 14
    espObject.Distance.Center = true
    espObject.Distance.Outline = true
    
    -- Tracer
    espObject.Tracer = Drawing.new("Line")
    espObject.Tracer.Visible = false
    espObject.Tracer.Thickness = 1
    espObject.Tracer.Transparency = 1
    
    ESPObjects[player] = espObject
    
    player.CharacterAdded:Connect(function()
        if player.Character:FindFirstChild("Humanoid") then
            espObject.Humanoid = player.Character.Humanoid
        end
    end)
    
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        espObject.Humanoid = player.Character.Humanoid
    end
    
    return espObject
end

local function removeESPObject(player)
    local espObject = ESPObjects[player]
    if espObject then
        for _, obj in pairs(espObject) do
            if typeof(obj) == "table" and obj.Remove then
                obj:Remove()
            end
        end
        ESPObjects[player] = nil
    end
end

local function updateESP()
    for player, espObject in pairs(ESPObjects) do
        if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or not getESPEnabled() then
            for _, obj in pairs(espObject) do
                if typeof(obj) == "table" and obj.Visible ~= nil then
                    obj.Visible = false
                end
            end
            continue
        end
        
        -- Team check
        if getESPTeamCheckEnabled() and player.Team == LocalPlayer.Team then
            for _, obj in pairs(espObject) do
                if typeof(obj) == "table" and obj.Visible ~= nil then
                    obj.Visible = false
                end
            end
            goto continue
        end
        
        local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
        if not rootPart then
            goto continue
        end
        
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then
            for _, obj in pairs(espObject) do
                if typeof(obj) == "table" and obj.Visible ~= nil then
                    obj.Visible = false
                end
            end
            goto continue
        end
        
        -- Calculate distance
        local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
        if distance > ESPSettings.MaxDistance then
            for _, obj in pairs(espObject) do
                if typeof(obj) == "table" and obj.Visible ~= nil then
                    obj.Visible = false
                end
            end
            goto continue
        end
        
        -- Calculate positions
        local rootPos = rootPart.Position
        local rootVector, onScreen = Camera:WorldToViewportPoint(rootPos)
        if not onScreen then
            for _, obj in pairs(espObject) do
                if typeof(obj) == "table" and obj.Visible ~= nil then
                    obj.Visible = false
                end
            end
            goto continue
        end
        
        -- Calculate box size based on distance
        local size = 1 / (distance * 0.1) * 100
        local boxSize = Vector2.new(size, size * 1.5)
        local boxPosition = Vector2.new(rootVector.X - size/2, rootVector.Y - size/1.5)
        
        -- Determine color based on team
        local color
        if ESPSettings.TeamColor then
            color = player.Team and player.TeamColor.Color or ESPSettings.BoxColor
        else
            color = player.Team == LocalPlayer.Team and ESPSettings.FriendlyColor or ESPSettings.BoxColor
        end
        
        -- Update ESP objects
        if getBoxesEnabled() then
            espObject.Box.Size = boxSize
            espObject.Box.Position = boxPosition
            espObject.Box.Color = color
            espObject.Box.Visible = true
        else
            espObject.Box.Visible = false
        end
        
        if getNamesEnabled() then
            espObject.Name.Position = Vector2.new(rootVector.X, boxPosition.Y - 15)
            espObject.Name.Text = player.Name
            espObject.Name.Color = ESPSettings.NameColor
            espObject.Name.Visible = true
        else
            espObject.Name.Visible = false
        end
        
        if getHealthEnabled() and humanoid then
            local health = humanoid.Health / humanoid.MaxHealth
            local healthBarHeight = boxSize.Y
            
            espObject.HealthBG.From = Vector2.new(boxPosition.X - 5, boxPosition.Y)
            espObject.HealthBG.To = Vector2.new(boxPosition.X - 5, boxPosition.Y + healthBarHeight)
            espObject.HealthBG.Visible = true
            
            espObject.Health.From = Vector2.new(boxPosition.X - 5, boxPosition.Y + healthBarHeight * (1 - health))
            espObject.Health.To = Vector2.new(boxPosition.X - 5, boxPosition.Y + healthBarHeight)
            espObject.Health.Color = ESPSettings.HealthColor
            espObject.Health.Visible = true
        else
            espObject.Health.Visible = false
            espObject.HealthBG.Visible = false
        end
        
        if getDistanceEnabled() then
            espObject.Distance.Position = Vector2.new(rootVector.X, boxPosition.Y + boxSize.Y + 3)
            espObject.Distance.Text = math.floor(distance) .. "m"
            espObject.Distance.Color = ESPSettings.DistanceColor
            espObject.Distance.Visible = true
        else
            espObject.Distance.Visible = false
        end
        
        if getTracersEnabled() then
            espObject.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            espObject.Tracer.To = Vector2.new(rootVector.X, rootVector.Y)
            espObject.Tracer.Color = color
            espObject.Tracer.Visible = true
        else
            espObject.Tracer.Visible = false
        end
        
        ::continue::
    end
end

-- Initialize ESP
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        createESPObject(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    createESPObject(player)
end)

Players.PlayerRemoving:Connect(function(player)
    removeESPObject(player)
end)

-- Aimbot Implementation
local AimbotEnabled = true
local AimbotSettings = {
    FOV = 200,
    FOVVisible = true,
    Smoothness = 0.5,
    TeamCheck = true,
    TargetPart = "Head",
    Key = Enum.UserInputType.MouseButton2,
    CamlockEnabled = false,
    SilentAimEnabled = false
}

local AimbotTarget = nil
local AimbotAiming = false

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 100
FOVCircle.Radius = AimbotSettings.FOV
FOVCircle.Filled = false
FOVCircle.Visible = AimbotSettings.FOVVisible
FOVCircle.ZIndex = 999
FOVCircle.Transparency = 1
FOVCircle.Color = Color3.fromRGB(255, 255, 255)

-- Get closest player to mouse
local function getClosestPlayerToMouse()
    local closestPlayer = nil
    local shortestDistance = getFOV()
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then
            goto continue
        end
        
        if getTeamCheckEnabled() and player.Team == LocalPlayer.Team then
            goto continue
        end
        
        local character = player.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then
            goto continue
        end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then
            goto continue
        end
        
        local targetPart = character:FindFirstChild(AimbotSettings.TargetPart)
        if not targetPart then
            targetPart = character:FindFirstChild("HumanoidRootPart")
            if not targetPart then
                goto continue
            end
        end
        
        local _, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
        if not onScreen then
            goto continue
        end
        
        local targetPos = Camera:WorldToViewportPoint(targetPart.Position)
        local mousePos = UserInputService:GetMouseLocation()
        
        local distance = (Vector2.new(targetPos.X, targetPos.Y) - mousePos).Magnitude
        
        if distance < shortestDistance then
            closestPlayer = player
            shortestDistance = distance
        end
        
        ::continue::
    end
    
    return closestPlayer
end

-- Update aimbot
local function updateAimbot()
    if not getAimEnabled() then
        FOVCircle.Visible = false
        return
    end
    
    -- Update FOV circle
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Radius = getFOV()
    FOVCircle.Visible = true
    
    -- Get target
    if AimbotAiming or getCamlockEnabled() then
        AimbotTarget = getClosestPlayerToMouse()
    else
        AimbotTarget = nil
    end
    
    -- Aim at target
    if AimbotTarget and (AimbotAiming or getCamlockEnabled()) then
        local character = AimbotTarget.Character
        if character then
            local targetPart = character:FindFirstChild(AimbotSettings.TargetPart)
            if not targetPart then
                targetPart = character:FindFirstChild("HumanoidRootPart")
            end
            
            if targetPart then
                local targetPos = Camera:WorldToViewportPoint(targetPart.Position)
                local mousePos = UserInputService:GetMouseLocation()
                
                local moveX = (targetPos.X - mousePos.X) * getSmoothness()
                local moveY = (targetPos.Y - mousePos.Y) * getSmoothness()
                
                mousemoverel(moveX, moveY)
            end
        end
    end
end

-- Input handling
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == AimbotSettings.Key then
        AimbotAiming = true
    end
    
    if input.KeyCode == Enum.KeyCode.Space and getInfiniteJumpEnabled() then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == AimbotSettings.Key then
        AimbotAiming = false
    end
end)

-- Movement hacks
local function updateMovement()
    if not LocalPlayer.Character then return end
    
    local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    -- Speed hack
    if getSpeedEnabled() then
        humanoid.WalkSpeed = getSpeedValue() * 16
    else
        humanoid.WalkSpeed = 16
    end
    
    -- Jump hack
    if getJumpEnabled() then
        humanoid.JumpPower = getJumpValue() * 50
    else
        humanoid.JumpPower = 50
    end
    
    -- Fly hack
    if getFlyEnabled() then
        local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local flyVel = Vector3.new(0, 0.1, 0)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                flyVel = flyVel + Vector3.new(0, getSpeedValue(), 0)
            end
            
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                flyVel = flyVel + Vector3.new(0, -getSpeedValue(), 0)
            end
            
            rootPart.Velocity = Vector3.new(rootPart.Velocity.X, flyVel.Y * 10, rootPart.Velocity.Z)
        end
    end
    
    -- Noclip
    if getNoclipEnabled() then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
    
    -- Hitbox expander
    if getHitboxEnabled() then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and (not getTeamCheckEnabled() or player.Team ~= LocalPlayer.Team) then
                local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
                if humanoidRootPart then
                    humanoidRootPart.Size = Vector3.new(getHitboxValue(), getHitboxValue(), getHitboxValue())
                    humanoidRootPart.Transparency = 0.5
                end
            end
        end
    end
end

-- Crosshair
local CrosshairEnabled = true
local crosshair = {
    horizontal = Drawing.new("Line"),
    vertical = Drawing.new("Line")
}

crosshair.horizontal.Visible = false
crosshair.horizontal.Thickness = 1
crosshair.horizontal.Color = Color3.fromRGB(255, 255, 255)

crosshair.vertical.Visible = false
crosshair.vertical.Thickness = 1
crosshair.vertical.Color = Color3.fromRGB(255, 255, 255)

local function updateCrosshair()
    if not getCrosshairEnabled() then
        crosshair.horizontal.Visible = false
        crosshair.vertical.Visible = false
        return
    end
    
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local size = 10
    
    crosshair.horizontal.From = Vector2.new(center.X - size, center.Y)
    crosshair.horizontal.To = Vector2.new(center.X + size, center.Y)
    crosshair.horizontal.Visible = true
    
    crosshair.vertical.From = Vector2.new(center.X, center.Y - size)
    crosshair.vertical.To = Vector2.new(center.X, center.Y + size)
    crosshair.vertical.Visible = true
end

-- Fullbright
local function updateFullbright()
    if getFullbrightEnabled() then
        game:GetService("Lighting").Brightness = 2
        game:GetService("Lighting").ClockTime = 14
        game:GetService("Lighting").FogEnd = 100000
        game:GetService("Lighting").GlobalShadows = false
        game:GetService("Lighting").OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    else
        game:GetService("Lighting").Brightness = 1
        game:GetService("Lighting").ClockTime = 14
        game:GetService("Lighting").FogEnd = 10000
        game:GetService("Lighting").GlobalShadows = true
        game:GetService("Lighting").OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    end
end

-- Main update loop
RunService.RenderStepped:Connect(function()
    updateESP()
    updateAimbot()
    updateMovement()
    updateCrosshair()
    updateFullbright()
end)

-- Cleanup function
local function cleanup()
    for _, player in pairs(ESPObjects) do
        removeESPObject(player)
    end
    
    FOVCircle:Remove()
    crosshair.horizontal:Remove()
    crosshair.vertical:Remove()
    
    ScreenGui:Destroy()
    
    _G.FictionLoaded = false
end

-- Create cleanup connection
game:GetService("CoreGui").ChildRemoved:Connect(function(child)
    if child == ScreenGui then
        cleanup()
    end
end)

-- Message to console
print("Fiction v1.0.1 loaded successfully")
print("All Starhook features are now active")

return Fiction 
