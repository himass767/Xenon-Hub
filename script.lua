--[[ 
    XENON HUB v2.0 - TWISTED (STORM CHASER)
    Tính năng: Định vị lốc, Chạy nhanh, Auto Farm Thiết bị
]]

local Player = game.Players.LocalPlayer
local Core = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local _G = { Speed = 100, AutoFarm = false, Esp = true }

if Core:FindFirstChild("XenonTwisted") then Core.XenonTwisted:Destroy() end
local SG = Instance.new("ScreenGui", Core); SG.Name = "XenonTwisted"

-- Nút mở Menu
local T = Instance.new("TextButton", SG)
T.Size, T.Position, T.Text = UDim2.new(0,80,0,35), UDim2.new(0,10,0,150), "XENON"
T.BackgroundColor3, T.TextColor3 = Color3.fromRGB(200, 0, 0), Color3.new(1,1,1)
Instance.new("UICorner", T)

-- Menu Chính
local M = Instance.new("Frame", SG)
M.Size, M.Position, M.BackgroundColor3 = UDim2.new(0,250,0,300), UDim2.new(0.5,-125,0.5,-150), Color3.fromRGB(20,20,20)
M.Visible = true; Instance.new("UICorner", M)

local List = Instance.new("ScrollingFrame", M)
List.Size, List.Position, List.BackgroundTransparency = UDim2.new(1,-20,1,-20), UDim2.new(0,10,0,10), 1
List.CanvasSize = UDim2.new(0,0,2,0)
local Layout = Instance.new("UIListLayout", List); Layout.Padding = UDim.new(0,10)

local function AddBtn(txt, callback)
    local b = Instance.new("TextButton", List)
    b.Size, b.Text = UDim2.new(1,0,0,40), txt
    b.BackgroundColor3, b.TextColor3 = Color3.fromRGB(40,40,45), Color3.new(1,1,1)
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() callback(b) end)
end

-- 1. CHẠY NHANH (WalkSpeed)
AddBtn("SIÊU TỐC ĐỘ: OFF", function(self)
    _G.SpeedHack = not _G.SpeedHack
    self.Text = _G.SpeedHack and "SIÊU TỐC: ON" or "SIÊU TỐC: OFF"
    task.spawn(function()
        while _G.SpeedHack do
            if Player.Character and Player.Character:FindFirstChild("Humanoid") then
                Player.Character.Humanoid.WalkSpeed = _G.Speed
            end
            task.wait()
        end
        Player.Character.Humanoid.WalkSpeed = 16
    end)
end)

-- 2. ĐỊNH VỊ LỐC XOÁY (ESP)
AddBtn("ĐỊNH VỊ LỐC: ON", function(self)
    _G.Esp = not _G.Esp
    self.Text = _G.Esp and "ĐỊNH VỊ LỐC: ON" or "ĐỊNH VỊ LỐC: OFF"
end)

-- 3. AUTO FARM (ĐẶT & LẤY THIẾT BỊ)
AddBtn("AUTO FARM SENSOR: OFF", function(self)
    _G.AutoFarm = not _G.AutoFarm
    self.Text = _G.AutoFarm and "AUTO FARM: ON" or "AUTO FARM: OFF"
    
    task.spawn(function()
        while _G.AutoFarm do
            task.wait(1)
            pcall(function()
                -- Tìm lốc xoáy (Storm)
                local storm = workspace:FindFirstChild("Storms") and workspace.Storms:GetChildren()[1]
                if storm then
                    local dist = (Player.Character.HumanoidRootPart.Position - storm.Position).Magnitude
                    
                    -- Nếu lốc gần (đang đến), tự đặt thiết bị
                    if dist < 500 and dist > 100 then
                        -- Lệnh đặt thiết bị (Remote tùy thuộc vào game Twisted)
                        game:GetService("ReplicatedStorage").Remotes.PlaceSensor:FireServer()
                    end
                    
                    -- Nếu lốc đã đi xa, tự lấy lại thiết bị
                    if dist > 600 then
                        game:GetService("ReplicatedStorage").Remotes.PickupSensor:FireServer()
                    end
                end
            end)
        end
    end)
end)

-- Vẽ ESP Lốc Xoáy
RunService.RenderStepped:Connect(function()
    if _G.Esp then
        pcall(function()
            for _, s in pairs(workspace.Storms:GetChildren()) do
                if not s:FindFirstChild("XenonEsp") then
                    local bill = Instance.new("BillboardGui", s); bill.Name = "XenonEsp"
                    bill.AlwaysOnTop, bill.Size = true, UDim2.new(0,100,0,50)
                    local txt = Instance.new("TextLabel", bill)
                    txt.Size, txt.BackgroundTransparency, txt.TextColor3 = UDim2.new(1,0,1,0), 1, Color3.new(1,0,0)
                    txt.Text = "⚠️ LỐC XOÁY ⚠️"
                end
            end
        end)
    end
end)

T.MouseButton1Click:Connect(function() M.Visible = not M.Visible end)
