local player = game.Players.LocalPlayer
local pGui = player:WaitForChild("PlayerGui")
local ts = game:GetService("TweenService")
local runS = game:GetService("RunService")
local cam = workspace.CurrentCamera

-- ล้างของเก่า
if pGui:FindFirstChild("DeadRail_Supreme_V8") then pGui.DeadRail_Supreme_V8:Destroy() end

local sg = Instance.new("ScreenGui", pGui)
sg.Name = "DeadRail_Supreme_V8"
sg.ResetOnSpawn = false
sg.DisplayOrder = 999

-- === 1. ตัวแปรสถานะ ===
_G.AutoJoin = false
_G.ESPActive = false
_G.PlayerESP = false
_G.AimbotEnabled = false

local fovRadius = 200
local maxAimDist = 400

-- === 2. UI FOV (วงกลมการเล็ง) ===
local fovCircle = Instance.new("Frame", sg)
fovCircle.Name = "FOVCircle"
fovCircle.Size = UDim2.new(0, fovRadius*2, 0, fovRadius*2)
fovCircle.Position = UDim2.new(0.5, -fovRadius, 0.5, -fovRadius)
fovCircle.BackgroundTransparency = 1
fovCircle.Visible = false
local fStroke = Instance.new("UIStroke", fovCircle)
fStroke.Thickness = 2
fStroke.Color = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0)

-- === 3. PLAYER ESP LOGIC (ระบุชื่อและระยะ) ===
task.spawn(function()
    while true do
        if _G.PlayerESP then
            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local char = p.Character
                    local hrp = char.HumanoidRootPart
                    
                    -- สร้าง Highlight (ตัวส่องสว่าง)
                    local hl = char:FindFirstChild("PlayerHighlight") or Instance.new("Highlight", char)
                    hl.Name = "PlayerHighlight"
                    hl.FillColor = Color3.fromRGB(255, 0, 0)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.Enabled = true
                    
                    -- สร้าง BillboardGui (ป้ายชื่อบนหัว)
                    local bg = hrp:FindFirstChild("PlayerInfo") or Instance.new("BillboardGui", hrp)
                    bg.Name = "PlayerInfo"
                    bg.AlwaysOnTop = true
                    bg.Size = UDim2.new(0, 100, 0, 50)
                    bg.ExtentsOffset = Vector3.new(0, 3, 0)
                    
                    local tl = bg:FindFirstChild("InfoLabel") or Instance.new("TextLabel", bg)
                    tl.Name = "InfoLabel"
                    tl.Size = UDim2.new(1, 0, 1, 0)
                    tl.BackgroundTransparency = 1
                    tl.TextColor3 = Color3.fromRGB(255, 255, 255)
                    tl.TextStrokeTransparency = 0
                    tl.Font = Enum.Font.SourceSansBold
                    tl.TextSize = 16
                    local dist = math.floor((player.Character.HumanoidRootPart.Position - hrp.Position).Magnitude)
                    tl.Text = p.Name .. "\n[" .. dist .. "m]"
                end
            end
        else
            -- ลบ ESP เมื่อปิด
            for _, p in pairs(game.Players:GetPlayers()) do
                if p.Character then
                    if p.Character:FindFirstChild("PlayerHighlight") then p.Character.PlayerHighlight:Destroy() end
                    if p.Character:FindFirstChild("HumanoidRootPart") and p.Character.HumanoidRootPart:FindFirstChild("PlayerInfo") then
                        p.Character.HumanoidRootPart.PlayerInfo:Destroy()
                    end
                end
            end
        end
        task.wait(0.5)
    end
end)

-- === 4. AIMBOT LOGIC (INSTANT LOCK) ===
runS.RenderStepped:Connect(function()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if _G.AimbotEnabled then
        fovCircle.Visible = true
        local target = nil
        local minMouse = fovRadius
        
        for _, v in pairs(workspace:GetChildren()) do
            if v:IsA("Model") and v ~= char then
                local head = v:FindFirstChild("Head")
                local hum = v:FindFirstChildOfClass("Humanoid")
                
                if head and hum and hum.Health > 0.1 and head.Position.Y > (v:GetPivot().Position.Y - 1) then
                    local sPos, onS = cam:WorldToViewportPoint(head.Position)
                    if onS then
                        local mDist = (Vector2.new(sPos.X, sPos.Y) - Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)).Magnitude
                        if mDist < minMouse then
                            minMouse = mDist
                            target = head
                        end
                    end
                end
            end
        end

        if target then
            cam.CFrame = CFrame.lookAt(cam.CFrame.Position, target.Position)
            hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(target.Position.X, hrp.Position.Y, target.Position.Z))
        end
    else
        fovCircle.Visible = false
    end
end)

-- === 5. UI เมนู (เพิ่มปุ่ม PLAYER ESP) ===
local logo = Instance.new("TextButton", sg)
logo.Size = UDim2.new(0, 120, 0, 45); logo.Position = UDim2.new(0.5, -60, 0.05, 0); logo.BackgroundColor3 = Color3.fromRGB(15, 15, 15); logo.Text = "DEAD RAIL"; logo.TextColor3 = Color3.new(1,1,1); logo.Font = "SourceSansBold"; logo.TextSize = 20; Instance.new("UICorner", logo)

local frame = Instance.new("Frame", sg)
frame.Size = UDim2.new(0, 0, 0, 0); frame.Position = UDim2.new(0.5, 0, 0.2, 0); frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10); frame.Visible = false; frame.ClipsDescendants = true; Instance.new("UICorner", frame)
local layout = Instance.new("UIListLayout", frame); layout.FillDirection = "Horizontal"; layout.Padding = UDim.new(0, 10); layout.HorizontalAlignment = "Center"; layout.VerticalAlignment = "Center"

local function makeBtn(text, varName)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 90, 0, 70); btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25); btn.Text = text.."\nOFF"; btn.TextColor3 = Color3.fromRGB(200, 200, 200); btn.Font = "SourceSansBold"; btn.TextSize = 12; Instance.new("UICorner", btn)
    btn.Activated:Connect(function()
        _G[varName] = not _G[varName]
        btn.Text = text.."\n"..(_G[varName] and "ON" or "OFF")
        btn.BackgroundColor3 = _G[varName] and Color3.fromRGB(0, 100, 50) or Color3.fromRGB(25, 25, 25)
    end)
end

makeBtn("AUTO\nJOIN", "AutoJoin")
makeBtn("GOLD\nX-RAY", "ESPActive")
makeBtn("PLAYER\nESP", "PlayerESP")
makeBtn("AIMBOT", "AimbotEnabled")

logo.Activated:Connect(function()
    local isOpen = (frame.Size.X.Offset > 0)
    local tSize = isOpen and UDim2.new(0, 0, 0, 0) or UDim2.new(0, 420, 0, 110)
    frame.Visible = true
    ts:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Size = tSize, Position = UDim2.new(0.5, -210, 0.2, 0)}):Play()
end)

-- ลากเมนูได้
local function makeDraggable(obj)
    local dragging, dragStart, startPos
    obj.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = input.Position; startPos = obj.Position end end)
    game:GetService("UserInputService").InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then local delta = input.Position - dragStart; obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
    obj.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
end
makeDraggable(logo); makeDraggable(frame)

