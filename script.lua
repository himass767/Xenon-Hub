--[[
    DarkForge-X | SHADOW-CORE MODE
    Script: TouchFly Instant - Chạm Bay Tức Thì
    Sửa lỗi: Bạn ko tự bay, người khác bay ngay khi chạm
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local ENABLED = true
local RANGE = 12

-- UI
pcall(function() PlayerGui:FindFirstChild("TouchFlyX"):Destroy() end)

local gui = Instance.new("ScreenGui")
gui.Name = "TouchFlyX"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0, 60, 0, 60)
btn.Position = UDim2.new(0.8, 0, 0.5, 0)
btn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
btn.Text = "BAY"
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.Font = Enum.Font.GothamBold
btn.TextSize = 14
btn.BorderSizePixel = 0
btn.Draggable = true
btn.Parent = gui
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 30)

btn.MouseButton1Click:Connect(function()
    ENABLED = not ENABLED
    btn.BackgroundColor3 = ENABLED and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
end)

-- Hàm đẩy đa dạng (thử từng cách đến khi thành công)
local function pushPlayer(targetChar)
    local root = targetChar:FindFirstChild("HumanoidRootPart")
    local hum = targetChar:FindFirstChild("Humanoid")
    if not root then return end
    
    -- Cách 1: Set velocity trực tiếp (nhanh nhất)
    root.Velocity = Vector3.new(0, 500, 0)
    
    -- Cách 2: Dùng CFrame nếu Velocity bị chặn
    task.wait(0.02)
    pcall(function()
        root.CFrame = root.CFrame + Vector3.new(0, 20, 0)
    end)
    
    -- Cách 3: Đẩy Humanoid nếu có
    if hum then
        pcall(function()
            hum.Sit = true
            task.wait(0.05)
            hum.Sit = false
            hum:Move(Vector3.new(0, 1000, 0), true)
        end)
    end
    
    -- Cách 4: Xóa HumanoidRootPart tạm thời (cực mạnh)
    pcall(function()
        root.Anchored = false
        root.CanCollide = false
        root.AssemblyLinearVelocity = Vector3.new(0, 1000, 0)
    end)
end

-- Vòng lặp NHANH (mỗi 0.05 giây kiểm tra)
task.spawn(function()
    while task.wait(0.05) do
        if not ENABLED then continue end
        
        local char = LocalPlayer.Character
        if not char then continue end
        local myRoot = char:FindFirstChild("HumanoidRootPart")
        if not myRoot then continue end
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            local targetChar = player.Character
            if targetChar then
                local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                if targetRoot then
                    local dist = (myRoot.Position - targetRoot.Position).Magnitude
                    if dist <= RANGE then
                        pushPlayer(targetChar)
                    end
                end
            end
        end
    end
end)

-- Khôi phục UI khi chết
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    pcall(function()
        PlayerGui:FindFirstChild("TouchFlyX"):Destroy()
        gui.Parent = PlayerGui
    end)
end)

print("[DarkForge-X] TouchFly Instant - Sẵn sàng!")
print("[DarkForge-X] Đến gần người khác -> Bay NGAY LẬP TỨC!")
