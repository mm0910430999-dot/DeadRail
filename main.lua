-- [[ PROJECT: BLUE PROTOCOL (ULTIMATE HOLOGRAM EDITION) ]]
-- [[ STATUS: MASTER MEMORY | SCANNER ADDED TO BOOT FRAME ]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- // ASSETS & CONFIG
local THEME_COLOR = Color3.fromRGB(0, 240, 255) -- Cyber Cyan
local DEEP_BLUE = Color3.fromRGB(0, 30, 100)
local SCAN_TEXTURE = "rbxassetid://7200216447" -- Grid/Tech Texture
local BOOT_SOUND_ID = "rbxassetid://85695184390474" -- ID ที่คุณกำหนด

_G.Settings = {
    AutoJoin = false,
    Aimbot = false,
    Radar = true,
    Mode = "Normal"
}

-- // [NEW] SOUND FUNCTION
local function PlayConfirmSound()
    local s = Instance.new("Sound", Workspace)
    s.SoundId = BOOT_SOUND_ID
    s.Volume = 1
    s.PlayOnRemove = true
    s:Play()
    s:Destroy()
end

-- // 1. UI INITIALIZATION (THE HOLODECK)
local pGui = LocalPlayer:WaitForChild("PlayerGui")
if pGui:FindFirstChild("BlueProtocol_UI") then pGui.BlueProtocol_UI:Destroy() end

local ScreenGui = Instance.new("ScreenGui", pGui)
ScreenGui.Name = "BlueProtocol_UI"
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 10000

-- // [SECTION: INITIALIZATION LOADING SCREEN]
local function StartBootSequence()
    local BootFrame = Instance.new("Frame", ScreenGui)
    BootFrame.Size = UDim2.new(0, 420, 0, 160)
    BootFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    BootFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    BootFrame.BackgroundColor3 = Color3.fromRGB(5, 10, 20)
    BootFrame.BackgroundTransparency = 0.4
    BootFrame.BorderSizePixel = 0
    BootFrame.ClipsDescendants = true -- สำคัญเพื่อให้ Scanner หายไปเมื่อออกจากขอบ
    
    local BootStroke = Instance.new("UIStroke", BootFrame)
    BootStroke.Color = THEME_COLOR
    BootStroke.Thickness = 1.5
    
    local BootLabel = Instance.new("TextLabel", BootFrame)
    BootLabel.Text = "LOADING HOLOGRAPHIC INTERFACE..."
    BootLabel.Size = UDim2.new(1, 0, 0, 40)
    BootLabel.Position = UDim2.new(0, 0, 0.15, 0)
    BootLabel.TextColor3 = THEME_COLOR
    BootLabel.Font = Enum.Font.Code
    BootLabel.TextSize = 15
    BootLabel.BackgroundTransparency = 1
    
    local BarBack = Instance.new("Frame", BootFrame)
    BarBack.Size = UDim2.new(0.8, 0, 0, 4)
    BarBack.Position = UDim2.new(0.1, 0, 0.65, 0)
    BarBack.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    
    local BarFill = Instance.new("Frame", BarBack)
    BarFill.Size = UDim2.new(0, 0, 1, 0)
    BarFill.BackgroundColor3 = THEME_COLOR
    BarFill.BorderSizePixel = 0

    -- [NEW] Scanner Effect for BootFrame
    local BootScanner = Instance.new("Frame", BootFrame)
    BootScanner.Size = UDim2.new(1, 0, 0, 2) -- ความสูง 2 pixel
    BootScanner.BackgroundColor3 = THEME_COLOR
    BootScanner.BorderSizePixel = 0
    BootScanner.BackgroundTransparency = 0.5
    
    local BootScannerGradient = Instance.new("UIGradient", BootScanner)
    BootScannerGradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(1, 1)
    }

    -- [NEW] Task for BootScanner
    task.spawn(function()
        while BootFrame.Parent == ScreenGui do -- จะรันจนกว่า BootFrame จะถูกทำลาย
            BootScanner.Position = UDim2.new(0, 0, -0.1, 0) -- เริ่มจากด้านบนนอกเฟรม
            TweenService:Create(BootScanner, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 1.1, 0)}):Play()
            task.wait(1.7) -- รอให้ Tween จบและหน่วงเวลานิดหน่อยก่อนรอบถัดไป
        end
    end)


    local function SpawnDispersal()
        local p = Instance.new("Frame", ScreenGui)
        p.Size = UDim2.new(0, math.random(4,8), 0, math.random(4,8))
        p.Position = UDim2.new(0.5, math.random(-30,30), 0.5, math.random(-30,30))
        p.BackgroundColor3 = THEME_COLOR
        p.BackgroundTransparency = 0.3
        local target = p.Position + UDim2.new(0, math.random(-200, 200), 0, math.random(-200, 200))
        TweenService:Create(p, TweenInfo.new(1.2), {Position = target, Rotation = 360, BackgroundTransparency = 1, Size = UDim2.new(0,0,0,0)}):Play()
        game.Debris:AddItem(p, 1.2)
    end

    task.spawn(function()
        for i = 1, 100 do
            BarFill.Size = UDim2.new(i/100, 0, 1, 0)
            BootLabel.Text = "CONNECTING NEURAL LINK... ["..i.."%]"
            if i % 4 == 0 then SpawnDispersal() end
            task.wait(0.02)
        end
        
        PlayConfirmSound() -- เสียงที่คุณให้มาดังที่นี่
        
        BootLabel.Text = "SYSTEM INITIALIZED // ONLINE"
        task.wait(0.5)
        TweenService:Create(BootFrame, TweenInfo.new(0.5), {Size = UDim2.new(0, 500, 0, 0), BackgroundTransparency = 1}):Play()
        TweenService:Create(BootLabel, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        task.wait(0.5)
        BootFrame:Destroy()
    end)
end

-- > BACKGROUND GLOW (รักษาไว้ตามต้นฉบับ)
local AmbientGlow = Instance.new("ImageLabel", ScreenGui)
AmbientGlow.Size = UDim2.new(1, 0, 1, 0)
AmbientGlow.BackgroundTransparency = 1
AmbientGlow.Image = "rbxassetid://132696068"
AmbientGlow.ImageColor3 = THEME_COLOR
AmbientGlow.ImageTransparency = 0.8
AmbientGlow.Visible = false

-- > MAIN HOLOGRAPHIC PANEL (รักษาไว้ตามต้นฉบับ)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 500, 0, 350)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 15, 25)
MainFrame.BackgroundTransparency = 0.2
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.ClipsDescendants = true

-- Tech Grid Overlay (รักษาไว้ตามต้นฉบับ)
local GridOverlay = Instance.new("ImageLabel", MainFrame)
GridOverlay.Size = UDim2.new(2, 0, 2, 0)
GridOverlay.Position = UDim2.new(0,0,0,0)
GridOverlay.BackgroundTransparency = 1
GridOverlay.Image = "rbxassetid://300136367"
GridOverlay.ImageColor3 = THEME_COLOR
GridOverlay.ImageTransparency = 0.85
GridOverlay.TileSize = UDim2.new(0, 50, 0, 50)
GridOverlay.ScaleType = Enum.ScaleType.Tile

task.spawn(function()
    while MainFrame do
        TweenService:Create(GridOverlay, TweenInfo.new(10, Enum.EasingStyle.Linear), {Position = UDim2.new(-0.5, -50, -0.5, -50)}):Play()
        task.wait(10)
        GridOverlay.Position = UDim2.new(0,0,0,0)
    end
end)

local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = THEME_COLOR
UIStroke.Thickness = 2
UIStroke.Transparency = 0.3

-- "Scanning Beam" Effect (รักษาไว้ตามต้นฉบับ)
local Scanner = Instance.new("Frame", MainFrame)
Scanner.Size = UDim2.new(1, 0, 0, 2)
Scanner.BackgroundColor3 = THEME_COLOR
Scanner.BorderSizePixel = 0
Scanner.BackgroundTransparency = 0.5
local ScannerGradient = Instance.new("UIGradient", Scanner)
ScannerGradient.Transparency = NumberSequence.new{
    NumberSequenceKeypoint.new(0, 1),
    NumberSequenceKeypoint.new(0.5, 0),
    NumberSequenceKeypoint.new(1, 1)
}

task.spawn(function()
    while true do
        Scanner.Position = UDim2.new(0, 0, -0.1, 0)
        TweenService:Create(Scanner, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Position = UDim2.new(0, 0, 1.1, 0)}):Play()
        task.wait(2.5)
    end
end)

-- > HEADER SYSTEM
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(0, 50, 80)
Header.BackgroundTransparency = 0.5

local Title = Instance.new("TextLabel", Header)
Title.Text = "SYSTEM // ONLINE"
Title.Font = Enum.Font.Code
Title.TextSize = 18
Title.TextColor3 = THEME_COLOR
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

-- > CONTENT LAYOUT
local Content = Instance.new("Frame", MainFrame)
Content.Position = UDim2.new(0, 0, 0, 50)
Content.Size = UDim2.new(0.6, 0, 1, -50)
Content.BackgroundTransparency = 1

local List = Instance.new("UIListLayout", Content)
List.Padding = UDim.new(0, 8)
List.HorizontalAlignment = Enum.HorizontalAlignment.Center
List.SortOrder = Enum.SortOrder.LayoutOrder

-- // 2. THE SPECIAL FUNCTION: HOLOGRAPHIC RADAR (รักษาไว้ตามต้นฉบับ)
local RadarFrame = Instance.new("Frame", MainFrame)
RadarFrame.Size = UDim2.new(0.35, 0, 0.35, 0)
RadarFrame.SizeConstraint = Enum.SizeConstraint.RelativeXX
RadarFrame.Position = UDim2.new(0.62, 0, 0.2, 0)
RadarFrame.BackgroundColor3 = Color3.fromRGB(0, 20, 40)
RadarFrame.BackgroundTransparency = 0.5
RadarFrame.BorderSizePixel = 0
Instance.new("UICorner", RadarFrame).CornerRadius = UDim.new(1, 0)
local RadarStroke = Instance.new("UIStroke", RadarFrame)
RadarStroke.Color = THEME_COLOR
RadarStroke.Thickness = 2

local lineH = Instance.new("Frame", RadarFrame)
lineH.Size = UDim2.new(1,0,0,1); lineH.Position = UDim2.new(0,0,0.5,0); lineH.BackgroundColor3 = THEME_COLOR; lineH.BackgroundTransparency=0.5
local lineV = Instance.new("Frame", RadarFrame)
lineV.Size = UDim2.new(0,1,1,0); lineV.Position = UDim2.new(0.5,0,0,0); lineV.BackgroundColor3 = THEME_COLOR; lineV.BackgroundTransparency=0.5

local PlayerDot = Instance.new("Frame", RadarFrame)
PlayerDot.Size = UDim2.new(0, 4, 0, 4)
PlayerDot.Position = UDim2.new(0.5, -2, 0.5, -2)
PlayerDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", PlayerDot).CornerRadius = UDim.new(1, 0)

local BlipContainer = Instance.new("Frame", RadarFrame)
BlipContainer.Size = UDim2.new(1, 0, 1, 0)
BlipContainer.BackgroundTransparency = 1

local RADAR_RANGE = 300

RunService.RenderStepped:Connect(function()
    if not MainFrame.Visible then return end
    BlipContainer:ClearAllChildren()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local myPos = hrp.Position
    local forward = hrp.CFrame.LookVector
    local right = hrp.CFrame.RightVector
    for _, v in pairs(Workspace:GetChildren()) do
        if v:IsA("Model") and v ~= char and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") then
            local eHrp = v.HumanoidRootPart
            local dist = (eHrp.Position - myPos).Magnitude
            if dist < RADAR_RANGE and v.Humanoid.Health > 0 then
                local dx = eHrp.Position.X - myPos.X
                local dz = eHrp.Position.Z - myPos.Z
                local relX = right:Dot(Vector3.new(dx, 0, dz))
                local relY = forward:Dot(Vector3.new(dx, 0, dz))
                local scale = 0.5
                local finalX = (relX / RADAR_RANGE) * scale
                local finalY = -(relY / RADAR_RANGE) * scale
                local blip = Instance.new("Frame", BlipContainer)
                blip.Size = UDim2.new(0, 6, 0, 6)
                blip.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
                blip.Position = UDim2.new(0.5 + finalX, -3, 0.5 + finalY, -3)
                Instance.new("UICorner", blip).CornerRadius = UDim.new(1,0)
                local g = Instance.new("UIStroke", blip)
                g.Color = Color3.fromRGB(255, 0, 0); g.Thickness = 1
            end
        end
    end
end)

local RadarLabel = Instance.new("TextLabel", RadarFrame)
RadarLabel.Text = "HOLO-RADAR V.1"
RadarLabel.Size = UDim2.new(1,0,0,15); RadarLabel.Position = UDim2.new(0,0,1.05,0)
RadarLabel.BackgroundTransparency = 1; RadarLabel.TextColor3 = THEME_COLOR; RadarLabel.Font = Enum.Font.Code; RadarLabel.TextSize = 10

-- // 3. BUTTON CREATION (รักษาไว้ตามต้นฉบับ)
local function CreateHoloBtn(text, settingKey)
    local Btn = Instance.new("TextButton", Content)
    Btn.Size = UDim2.new(0.9, 0, 0, 45)
    Btn.BackgroundColor3 = Color3.fromRGB(0, 30, 60)
    Btn.BackgroundTransparency = 0.6
    Btn.Text = ""; Btn.AutoButtonColor = false
    local Stroke = Instance.new("UIStroke", Btn)
    Stroke.Color = THEME_COLOR; Stroke.Transparency = 0.7; Stroke.Thickness = 1
    local Label = Instance.new("TextLabel", Btn)
    Label.Text = text; Label.TextColor3 = Color3.fromRGB(200, 255, 255); Label.Font = Enum.Font.GothamBold; Label.TextSize = 14
    Label.Size = UDim2.new(1, -20, 1, 0); Label.Position = UDim2.new(0, 10, 0, 0); Label.BackgroundTransparency = 1; Label.TextXAlignment = Enum.TextXAlignment.Left
    local Light = Instance.new("Frame", Btn)
    Light.Size = UDim2.new(0, 4, 1, 0); Light.BackgroundColor3 = Color3.fromRGB(50, 50, 50); Light.BorderSizePixel = 0
    Btn.MouseEnter:Connect(function() TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.3}):Play(); TweenService:Create(Stroke, TweenInfo.new(0.2), {Transparency = 0}):Play() end)
    Btn.MouseLeave:Connect(function() TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.6}):Play(); TweenService:Create(Stroke, TweenInfo.new(0.2), {Transparency = 0.7}):Play() end)
    Btn.MouseButton1Click:Connect(function()
        _G.Settings[settingKey] = not _G.Settings[settingKey]
        local state = _G.Settings[settingKey]
        local Flash = Instance.new("Frame", Btn); Flash.Size = UDim2.new(1,0,1,0); Flash.BackgroundColor3 = THEME_COLOR; Flash.BackgroundTransparency = 0.5
        TweenService:Create(Flash, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play(); game.Debris:AddItem(Flash, 0.3)
        TweenService:Create(Light, TweenInfo.new(0.3), {BackgroundColor3 = state and THEME_COLOR or Color3.fromRGB(50,50,50)}):Play()
        Label.TextColor3 = state and THEME_COLOR or Color3.fromRGB(200, 255, 255)
        local originText = text; Label.Text = "// PROCESSING..."; task.wait(0.1); Label.Text = originText
    end)
end

CreateHoloBtn("[01] AUTO JOIN SEQUENCE", "AutoJoin")
CreateHoloBtn("[02] TARGET LOCK (AIMBOT)", "Aimbot")
CreateHoloBtn("[03] X-RAY SENSORS", "Radar")

-- // 4. TOGGLE BUTTON (HOLO ORB - รักษาไว้ตามต้นฉบับ)
local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 60, 0, 60); ToggleBtn.Position = UDim2.new(0.5, -30, 0.1, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0); ToggleBtn.BackgroundTransparency = 0.5; ToggleBtn.Text = ""
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
local ToggleStroke = Instance.new("UIStroke", ToggleBtn); ToggleStroke.Color = THEME_COLOR; ToggleStroke.Thickness = 2
local Ring = Instance.new("ImageLabel", ToggleBtn); Ring.Size = UDim2.new(0.8, 0, 0.8, 0); Ring.Position = UDim2.new(0.1, 0, 0.1, 0); Ring.BackgroundTransparency = 1; Ring.Image = "rbxassetid://403932782"; Ring.ImageColor3 = THEME_COLOR
task.spawn(function() while ToggleBtn do Ring.Rotation = Ring.Rotation + 2 task.wait(0.02) end end)

ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible; AmbientGlow.Visible = MainFrame.Visible
    if MainFrame.Visible then MainFrame.Size = UDim2.new(0, 0, 0, 350); TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Size = UDim2.new(0, 500, 0, 350)}):Play() end
end)

-- // 5. GAME LOGIC & DRAG (รักษาไว้ตามต้นฉบับ)
RunService.RenderStepped:Connect(function()
    if _G.Settings.Aimbot then
        local target = nil; local dist = 500; local c = LocalPlayer.Character
        if c then
            for _,v in pairs(Workspace:GetChildren()) do
                if v:IsA("Model") and v ~= c and v:FindFirstChild("Head") and v:FindFirstChild("Humanoid") then
                    if v.Humanoid.Health > 0.1 then local d = (c.HumanoidRootPart.Position - v.Head.Position).Magnitude
                    if d < dist then dist = d; target = v.Head end end
                end
            end
            if target then Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, target.Position) end
        end
    end
end)

local function Drag(obj)
    local g, s, sp; obj.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then g=true; s=i.Position; sp=obj.Position end end)
    UserInputService.InputChanged:Connect(function(i) if g and i.UserInputType == Enum.UserInputType.MouseMovement then local d=i.Position-s; obj.Position = UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y) end end)
    obj.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then g=false end end)
end
Drag(ToggleBtn); Drag(MainFrame)

-- START BOOT
StartBootSequence()


