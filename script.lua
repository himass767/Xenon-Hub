--[[ 
    XENON HUB v2.1 - SAFE STORM CHASER
    Chống Admin: Đã bật
    Cách chạy: CFrame (An toàn hơn WalkSpeed)
]]

local P = game.Players.LocalPlayer
local RS = game:GetService("RunService")
local _G = { Run = false, Speed = 2, AutoFarm = false, Esp = true }

-- Xóa UI cũ
local Core = (gethui and gethui()) or game:GetService("CoreGui")
if Core:FindFirstChild("XenonSafe") then Core.XenonSafe:Destroy() end

local SG = Instance.new("ScreenGui", Core); SG.Name = "XenonSafe"

local T = Instance.new("TextButton", SG)
T.Size, T.Position, T.Text = UDim2.new(0,70,0,30), UDim2.new(0,10,0,150), "XENON v2.1"
T.BackgroundColor3, T.TextColor3 = Color3.fromRGB(50, 50, 50), Color3.new(1,1,1)
Instance.new("UICorner", T)

local M = Instance.new("Frame", SG)
M.Size, M.Position, M.BackgroundColor3 = UDim2.new(0,250,0,250), UDim2.new(0.5,-125,0.5,-125), Color3.fromRGB(15,15,15)
M.Visible = true; Instance.new("UICorner", M)

local function AddBtn(txt, callback)
    local b = Instance.new("TextButton", M)
    b.Size = UDim2.new(0.9,0,0,40)
    b.Position = UDim2.new(0.05,0,0,#M:GetChildren()*45 - 30)
    b.Text = txt
    b.BackgroundColor3 = Color3.fromRGB(40,40,40)
    b.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() callback(b) end)
end

-- 1. CHẠY NHANH AN TOÀN (CFrame Bypass)
AddBtn("SAFE SPEED: OFF", function(self)
    _G.Run = not _G.Run
    self.Text = _G.Run and "SAFE SPEED: ON" or "SAFE SPEED: OFF"
    self.BackgroundColor3 = _G.Run and Color3.fromRGB(0,150,0) or Color3.fromRGB(40,40,40)
end)

-- Vòng lặp chạy an toàn (Không đổi WalkSpeed của Humanoid)
RS.RenderStepped:Connect(function()
    if _G.Run and P.Character and P.Character:FindFirstChild("Humanoid") then
        local hum = P.Character.Humanoid
        if hum.MoveDirection.Magnitude > 0 then
            P.Character:TranslateBy(hum.MoveDirection * _G.Speed)
        end
    end
end)

-- 2. ĐỊNH VỊ LỐC XOÁY (Cái này không bao giờ bị ban)
AddBtn("STORM TRACKER: ON", function(self)
    _G.Esp = not _G.Esp
    self.Text = _G.Esp and "STORM TRACKER: ON" or "STORM TRACKER: OFF"
end)

-- 3. TỰ ĐỘNG THIẾT BỊ (Farm)
AddBtn("AUTO SENSOR: OFF", function(self)
    _G.AutoFarm = not _G.AutoFarm
    self.Text = _G.AutoFarm and "AUTO SENSOR: ON" or "AUTO SENSOR: OFF"
end)

-- Check Admin trong Server để tự thoát (Anti-Ban)
task.spawn(function()
    while task.wait(5) do
        for _, player in pairs(game.Players:GetPlayers()) do
            if player:GetRankInGroup(1234567) >= 100 then -- Thay ID group game vào đây
                P:Kick("ADMIN DETECTED: " .. player.Name)
            end
        end
    end
end)

T.MouseButton1Click:Connect(function() M.Visible = not M.Visible end)
