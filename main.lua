-- [[ DEAD RAIL MASTER ULTIMATE V.FINAL ]]
-- Project Memory: Auto Join, Warp Hitbox, ESP X-Ray, Aimbot Snap, Gold X-Ray

local player = game.Players.LocalPlayer
local pGui = player:WaitForChild("PlayerGui")
local ts = game:GetService("TweenService")
local runS = game:GetService("RunService")
local cam = workspace.CurrentCamera
local rs = game:GetService("ReplicatedStorage")

-- [[ ล้างของเก่าเพื่อป้องกัน Script ซ้อน ]]
if pGui:FindFirstChild("DeadRail_Master_Final") then pGui.DeadRail_Master_Final:Destroy() end

local sg = Instance.new("ScreenGui", pGui)
sg.Name = "DeadRail_Master_Final"
sg.ResetOnSpawn = false

-- === 1. ตัวแปรสถานะ (Project Memory) ===
_G.AutoJoin = false
_G.SelectedMode = "ปกติ"
_G.AimbotEnabled = false
_G.PlayerESP = false
_G.GoldXray = false

local modeMap = {
    ["ปกติ"] = "Normal",
    ["ฝันร้าย"] = "Nightmare",
    ["ฝนตกเป็นน้ำมัน"] = "ScorchedEarth",
    ["คริสต์มาส"] = "ChristmasEvent2025"
}

-- === 2. SYSTEM: AUTO JOIN & WARP (รัวๆ ตามสั่ง) ===
task.spawn(function()
    while task.wait(0.5) do
        if _G.AutoJoin then
            pcall(function()
                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                -- Warp ไปที่บล็อก Hitbox
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") and v.Name == "Hitbox" then
                        if hrp then hrp.CFrame = v.CFrame end
                        break
                    end
                end
                -- ส่ง Remote ตามโหมดที่เลือก
                local remote = rs:WaitForChild("Shared"):WaitForChild("Network"):WaitForChild("RemoteEvent"):WaitForChild("CreateParty")
                remote:FireServer({{
                    isPrivate = true, 
                    maxMembers = 1, 
                    trainId = "default", 
                    gameMode = modeMap[_G.SelectedMode] or "Normal"
                }})
            end)
        end
    end
end)

-- === 3. SYSTEM: PLAYER ESP (X-RAY) ===
runS.RenderStepped:Connect(function()
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= player and v.Character then
            local hl = v.Character:FindFirstChild("PlayerHL")
            if _G.PlayerESP then
                if not hl then
                    hl = Instance.new("Highlight", v.Character)
                    hl.Name = "PlayerHL"
                    hl.FillColor = Color3.fromRGB(255, 0, 0)
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                end
                hl.Enabled = true
            else
                if hl then hl.Enabled = false end
            end
        end
    end
end)

-- === 4. UI CONSTRUCTION (Draggable & สมมาตร) ===
local function makeDraggable(obj)
    local dragging, dragStart, startPos
    obj.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = input.Position; startPos = obj.Position end end)
    game:GetService("UserInputService").InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then local delta = input.Position - dragStart; obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
    obj.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
end

local logo = Instance.new("TextButton", sg)
logo.Size = UDim2.new(0, 140, 0, 50); logo.Position = UDim2.new(0.5, -70, 0.05, 0); logo.BackgroundColor3 = Color3.fromRGB(15, 15, 15); logo.Text = "DEAD RAIL"; logo.TextColor3 = Color3.new(1,1,1); logo.Font = "SourceSansBold"; logo.TextSize = 22; Instance.new("UICorner", logo)
makeDraggable(logo)

local frame = Instance.new("Frame", sg)
frame.Size = UDim2.new(0, 0, 0, 0); frame.Position = UDim2.new(0.5, 0, 0.35, 0); frame.AnchorPoint = Vector2.new(0.5, 0.5); frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10); frame.Visible = false; frame.ClipsDescendants = true; Instance.new("UICorner", frame)
local layout = Instance.new("UIListLayout", frame); layout.FillDirection = "Horizontal"; layout.Padding = UDim.new(0, 10); layout.HorizontalAlignment = "Center"; layout.VerticalAlignment = "Center"
makeDraggable(frame)

-- แถบเลือกโหมด
local mCont = Instance.new("Frame", frame); mCont.Size = UDim2.new(0, 130, 0, 100); mCont.BackgroundTransparency = 1
Instance.new("UIListLayout", mCont).Padding = UDim.new(0, 2)
local modeBtns = {}
for mName, _ in pairs(modeMap) do
    local b = Instance.new("TextButton", mCont)
    b.Size = UDim2.new(1, 0, 0, 23); b.BackgroundColor3 = Color3.fromRGB(30, 30, 30); b.Text = mName; b.TextColor3 = Color3.new(1,1,1); b.Font = "SourceSansBold"; b.TextSize = 11; Instance.new("UICorner", b)
    b.Activated:Connect(function()
        _G.SelectedMode = mName
        for _, btn in pairs(modeBtns) do btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30) end
        b.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    end)
    modeBtns[mName] = b
end
modeBtns["ปกติ"].BackgroundColor3 = Color3.fromRGB(0, 150, 255)

local function createBtn(text, var)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 85, 0, 85); btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25); btn.Text = text.."\nOFF"; btn.TextColor3 = Color3.new(0.9,0.9,0.9); btn.Font = "SourceSansBold"; btn.TextSize = 11; Instance.new("UICorner", btn)
    btn.Activated:Connect(function()
        _G[var] = not _G[var]
        btn.Text = text.."\n"..(_G[var] and "ON" or "OFF")
        btn.BackgroundColor3 = _G[var] and Color3.fromRGB(0, 100, 50) or Color3.fromRGB(25, 25, 25)
    end)
end

createBtn("AUTO\nJOIN", "AutoJoin"); createBtn("PLAYER\nESP", "PlayerESP"); createBtn("GOLD\nXRAY", "GoldXray"); createBtn("AIMBOT", "AimbotEnabled")

logo.Activated:Connect(function()
    local isOp = frame.Size.X.Offset == 0
    ts:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Size = isOp and UDim2.new(0, 540, 0, 120) or UDim2.new(0, 0, 0, 0)}):Play()
    frame.Visible = true
end)

-- === 5. SYSTEM: AIMBOT SNAP ===
runS.RenderStepped:Connect(function()
    if _G.AimbotEnabled then
        local target = nil; local shortest = 500
        for _, v in pairs(workspace:GetChildren()) do
            if v:IsA("Model") and v ~= player.Character and v:FindFirstChild("Head") and v:FindFirstChildOfClass("Humanoid") then
                if v:FindFirstChildOfClass("Humanoid").Health > 0 then
                    local _, onS = cam:WorldToViewportPoint(v.Head.Position)
                    if onS then
                        local dist = (player.Character.HumanoidRootPart.Position - v.Head.Position).Magnitude
                        if dist < shortest then target = v.Head; shortest = dist end
                    end
                end
            end
        end
        if target then cam.CFrame = CFrame.lookAt(cam.CFrame.Position, target.Position) end
    end
end)

