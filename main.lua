-- [[ PROJECT: BLUE PROTOCOL (ULTIMATE GLITCH EDITION) ]]
-- [[ STATUS: MASTER MEMORY | GLITCH & FLICKER EFFECTS ADDED ]]

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
local GLITCH_COLOR = Color3.fromRGB(255, 0, 100) -- Red/Pink for Glitch
local DEEP_BLUE = Color3.fromRGB(0, 30, 100)
local BOOT_SOUND_ID = "rbxassetid://85695184390474"

_G.Settings = {
    AutoJoin = false,
    Aimbot = false,
    Radar = true,
    Mode = "Normal"
}

-- // [SYSTEM] UTILITY FUNCTIONS
local function PlayConfirmSound()
    local s = Instance.new("Sound", Workspace)
    s.SoundId = BOOT_SOUND_ID
    s.Volume = 1
    s.PlayOnRemove = true
    s:Play()
    s:Destroy()
end

local function RandomChar()
    local chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ@#$%&"
    local r = math.random(1, #chars)
    return string.sub(chars, r, r)
end

local function GlitchText(label, finalDelay)
    local originalText = label.Text
    local len = string.len(originalText)
    
    task.spawn(function()
        for i = 1, 15 do -- Glitch loop count
            local newText = ""
            for j = 1, len do
                if math.random() > 0.5 then
                    newText = newText .. string.sub(originalText, j, j)
                else
                    newText = newText .. RandomChar()
                end
            end
            label.Text = newText
            label.TextColor3 = (i % 2 == 0) and GLITCH_COLOR or THEME_COLOR
            task.wait(0.03)
        end
        label.Text = originalText
        label.TextColor3 = THEME_COLOR
    end)
end

local function ShakeEffect(obj, intensity)
    local origin = obj.Position
    task.spawn(function()
        for i = 1, 6 do
            local offX = math.random(-intensity, intensity)
            local offY = math.random(-intensity, intensity)
            obj.Position = origin + UDim2.new(0, offX, 0, offY)
            task.wait(0.02)
        end
        obj.Position = origin
    end)
end

-- // 1. UI INITIALIZATION
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
    BootFrame.ClipsDescendants = true
    
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

    -- Scanner Effect
    local BootScanner = Instance.new("Frame", BootFrame)
    BootScanner.Size = UDim2.new(1, 0, 0, 2)
    BootScanner.BackgroundColor3 = THEME_COLOR
    BootScanner.BorderSizePixel = 0
    BootScanner.BackgroundTransparency = 0.5
    
    local BootScannerGradient = Instance.new("UIGradient", BootScanner)
    BootScannerGradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(1, 1)
    }

    task.spawn(function()
        while BootFrame.Parent == ScreenGui do
            BootScanner.Position = UDim2.new(0, 0, -0.1, 0)
            TweenService:Create(BootScanner, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 1.1, 0)}):Play()
            task.wait(1.7)
        end
    end)

    local function SpawnDispersal()
        local p = Instance.new("Frame", ScreenGui)
        p.Size = UDim2.new(0, math
