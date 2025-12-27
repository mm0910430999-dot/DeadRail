-- [[ DEAD RAIL MASTER ULTIMATE - RE-FIXED UI ]]
local player = game.Players.LocalPlayer
local pGui = player:WaitForChild("PlayerGui")
local ts = game:GetService("TweenService")
local runS = game:GetService("RunService")
local cam = workspace.CurrentCamera
local rs = game:GetService("ReplicatedStorage")

-- ล้างของเก่าให้เกลี้ยงก่อนรันใหม่
if pGui:FindFirstChild("DeadRail_Master_Stable") then pGui.DeadRail_Master_Stable:Destroy() end

local sg = Instance.new("ScreenGui", pGui)
sg.Name = "DeadRail_Master_Stable"
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.DisplayOrder = 9999 -- บังคับให้อยู่หน้าสุด

-- === 1. ตัวแปรสถานะ ===
_G.AutoJoin = false
_G.ESPActive = false
_G.PlayerESP = false
_G.AimbotEnabled = false
_G.SelectedMode = "Normal"

local fovRadius = 250
local maxAimDist = 500
local modeMap = {
    ["ปกติ"] = "Normal",
    ["ฝันร้าย"] = "Nightmare",
    ["ฝนตก"] = "ScorchedEarth",
    ["กิจกรรม"] = "ChristmasEvent2025"
}

-- === 2. TURBO AUTO JOIN ===
task.spawn(function()
    while true do
        task.wait(0.05)
        if _G.AutoJoin then
            pcall(function()
                rs.Shared.Network.RemoteEvent.CreateParty:FireServer({{
                    isPrivate = true, maxMembers = 1, trainId = "default", gameMode = _G.SelectedMode
                }})
                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                for _, v in pairs(workspace:GetDescendants()) do
                    if v.Name == "Hitbox" and v:IsA("BasePart") then hrp.CFrame = v.CFrame break end
                end
            end)
        end
    end
end)

-- === 3. AIMBOT LOGIC (ไม่เล็งศพ) ===
runS.RenderStepped:Connect(function()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if _G.AimbotEnabled and hrp then
        local target = nil
        local shortestDist = maxAimDist
        for _, v in pairs(workspace:GetChildren()) do
            if v:IsA("Model") and v ~= char then
                local head = v:FindFirstChild("Head")
                local hum = v:FindFirstChildOfClass("Humanoid")
                if head and hum and hum.Health > 0.1 and head.Position.Y > (v:GetPivot().Position.Y - 1) then
                    local sPos, onS = cam:WorldToViewportPoint(head.Position)
                    if onS and (Vector2.new(sPos.X, sPos.Y) - Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)).Magnitude < fovRadius then
                        shortestDist = (hrp.Position - head.Position).Magnitude
                        target = head
                    end
                end
            end
        end
        if target then cam.CFrame = CFrame.lookAt(cam.CFrame.Position, target.Position) end
    end
end)

-- === 4. UI CONSTRUCTION (แก้ไขปุ่มกด) ===
local logo = Instance.new("TextButton", sg)
logo.Size = UDim2.new(0, 100, 0, 40); logo.Position = UDim2.new(0.5, -50, 0.05, 0); logo.BackgroundColor3 = Color3.fromRGB(40, 40, 40); logo.Text = "SCRIPT"; logo.TextColor3 = Color3.new(1,1,1); logo.Font = "SourceSansBold"; logo.TextSize = 18; logo.ZIndex = 10; Instance.new("UICorner", logo)

local mainFrame = Instance.new("Frame", sg)
mainFrame.Size = UDim2.new(0, 460, 0, 200); mainFrame.Position = UDim2.new(0.5, -230, 0.2, 0); mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20); mainFrame.Visible = false; mainFrame.ZIndex = 5; Instance.new("UICorner", mainFrame)
local hLayout = Instance.new("UIListLayout", mainFrame); hLayout.FillDirection = "Horizontal"; hLayout.Padding = UDim.new(0, 15); hLayout.HorizontalAlignment = "Center"; hLayout.VerticalAlignment = "Center"

local function createSection(name)
    local f = Instance.new("Frame", mainFrame); f.Size = UDim2.new(0, 200, 0, 160); f.BackgroundTransparency = 1
    local l = Instance.new("UIListLayout", f); l.Padding = UDim.new(0, 8); l.HorizontalAlignment = "Center"
    local t = Instance.new("TextLabel", f); t.Size = UDim2.new(1, 0, 0, 30); t.Text = name; t.TextColor3 = Color3.fromRGB(0, 170, 255); t.Font = "SourceSansBold"; t.TextSize = 16; t.BackgroundTransparency = 1
    return f
end

local function createBtn(txt, var, parent)
    local b = Instance.new("TextButton", parent); b.Size = UDim2.new(0, 140, 0, 35); b.BackgroundColor3 = Color3.fromRGB(40, 40, 40); b.Text = txt.." [OFF]"; b.TextColor3 = Color3.white; b.Font = "SourceSansBold"; b.TextSize = 12; Instance.new("UICorner", b)
    b.Activated:Connect(function()
        _G[var] = not _G[var]
        b.Text = txt..(_G[var] and " [ON]" or " [OFF]")
        b.BackgroundColor3 = _G[var] and Color3.fromRGB(0, 150, 80) or Color3.fromRGB(40, 40, 40)
    end)
end

-- Section 1
local sec1 = createSection("Dead Rail")
createBtn("AUTO JOIN", "AutoJoin", sec1)
createBtn("GOLD X-RAY", "ESPActive", sec1)

-- Section 2
local sec2 = createSection("Lockเป้ายิงปืน")
createBtn("ล็อคหัว", "AimbotEnabled", sec2)

-- ระบบเปิด/ปิด (บังคับให้ทำงาน)
logo.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
    -- ใส่สีเปลี่ยนตอนกดเพื่อให้รู้ว่าปุ่มทำงาน
    logo.BackgroundColor3 = mainFrame.Visible and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(40, 40, 40)
end)

-- ลากได้
local function drag(o)
    local g, s, sp
    o.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then g = true; s = i.Position; sp = o.Position end end)
    game:GetService("UserInputService").InputChanged:Connect(function(i) if g and i.UserInputType == Enum.UserInputType.MouseMovement then local d = i.Position - s; o.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y) end end)
    o.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then g = false end end)
end
drag(logo); drag(mainFrame)

