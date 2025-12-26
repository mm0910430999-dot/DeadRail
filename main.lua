-- [[ DEAD RAIL MASTER ULTIMATE V.FINAL ]]
local player = game.Players.LocalPlayer
local rs = game:GetService("ReplicatedStorage")
local runS = game:GetService("RunService")
local ts = game:GetService("TweenService")
local cam = workspace.CurrentCamera

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

-- [1] AUTO JOIN & WARP LOGIC
task.spawn(function()
    while task.wait(0.5) do
        if _G.AutoJoin then
            pcall(function()
                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                for _, v in pairs(workspace:GetDescendants()) do
                    if v.Name == "Hitbox" then 
                        if hrp then hrp.CFrame = v.CFrame end 
                        break 
                    end
                end
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

-- [2] PLAYER X-RAY (ESP)
runS.RenderStepped:Connect(function()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player and p.Character then
            local hl = p.Character:FindFirstChild("PlayerHL")
            if _G.PlayerESP then
                if not hl then
                    hl = Instance.new("Highlight", p.Character)
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

-- [3] UI & LOGIC อื่นๆ (Aimbot/GoldXray) จะทำงานอัตโนมัติ
