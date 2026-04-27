--[[
    DarkForge-X | SHADOW-CORE MODE
    Script: TouchFly Universal - Chạm Là Bay
    Dùng được cho TẤT CẢ game Roblox (VNG & Quốc tế)
    Cách dùng: Đến gần người chơi, họ tự động bay đi xa
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- CẤU HÌNH (có thể chỉnh)
local ENABLED = true
local TOUCH_RANGE = 10      -- Khoảng cách kích hoạt (studs)
local FLY_POWER = 10000     -- Lực đẩy
local FLY_UP = 5000         -- Lực bay lên

-- Xóa UI cũ
pcall(function()
    PlayerGui:FindFirstChild("TouchFly_UI"):Destroy()
end)

-- Tạo UI
local gui = Instance.new("ScreenGui")
gui.Name = "TouchFly_UI"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0, 60, 0, 60)
btn.Position = UDim2.new(0.8, 0, 0.5, 0)
btn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
btn.Text = "BAY\nBẬT"
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.Font = Enum.Font.GothamBold
btn.TextSize = 11
btn.BorderSizePixel = 0
btn.Draggable = true
btn.ZIndex = 10
btn.Parent = gui

Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 30)
Instance.new("UIStroke", btn).Thickness = 2

btn.MouseButton1Click:Connect(function()
    ENABLED = not ENABLED
    if ENABLED then
        btn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        btn.Text = "BAY\nBẬT"
    else
        btn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        btn.Text = "BAY\nTẮT"
    end
end)

-- Vòng lặp chính: kiểm tra người chơi gần và đẩy họ
RunService.Heartbeat:Connect(function()
    if not ENABLED then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    local myRoot = char:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local targetChar = player.Character
            if targetChar then
                local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                if targetRoot then
                    local dist = (myRoot.Position - targetRoot.Position).Magnitude
                    
                    -- Nếu trong phạm vi, đẩy bay
                    if dist <= TOUCH_RANGE then
                        local direction = (targetRoot.Position - myRoot.Position).Unit
                        local force = direction * FLY_POWER + Vector3.new(0, FLY_UP, 0)
                        targetRoot.Velocity = force
                        
                        -- Cách 2: set trực tiếp CFrame nếu Velocity không hoạt động
                        -- targetRoot.CFrame = targetRoot.CFrame + Vector3.new(0, 50, 0)
                    end
                end
            end
        end
    end
end)

print("[DarkForge-X] TouchFly Universal đã sẵn sàng!")
print("[DarkForge-X] Nút xanh BAY BẬT -> Đến gần người chơi -> Họ bay!")
