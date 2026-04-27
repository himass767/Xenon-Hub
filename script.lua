--[[
    DarkForge-X | SHADOW-CORE MODE
    Script cực nhẹ cho Delta X - Sailor Piece
    Chỉ 1 nút toggle + AutoFarm
]]

-- ==================== KHỞI TẠO ====================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ==================== BIẾN TOÀN CỤC ====================
local Farming = false
local LastAttack = 0
local AttackDelay = 0.3
local FarmRange = 200
local NPCS = {}
local LastScan = 0

-- ==================== TẠO NÚT BẬT/TẮT ĐƠN GIẢN ====================
local function CreateToggleButton()
    -- Xóa UI cũ nếu có
    if PlayerGui:FindFirstChild("DarkForgeX_Toggle") then
        PlayerGui.DarkForgeX_Toggle:Destroy()
    end
    
    -- Tạo ScreenGui
    local gui = Instance.new("ScreenGui")
    gui.Name = "DarkForgeX_Toggle"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = PlayerGui
    
    -- Nút chính
    local button = Instance.new("TextButton")
    button.Name = "ToggleButton"
    button.Size = UDim2.new(0, 80, 0, 80)
    button.Position = UDim2.new(0.85, 0, 0.7, 0)
    button.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    button.Text = "FARM\nTẮT"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 16
    button.BorderSizePixel = 0
    button.Active = true
    button.Draggable = true
    button.ZIndex = 10
    button.Parent = gui
    
    -- Bo góc
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 40)
    corner.Parent = button
    
    -- Stroke viền
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 3
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Parent = button
    
    -- Nhãn trạng thái
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(0, 150, 0, 20)
    statusLabel.Position = UDim2.new(0.5, -75, 1, 10)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Ấn để bật AutoFarm"
    statusLabel.TextColor3 = Color3.fromRGB(0, 255, 200)
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.TextSize = 12
    statusLabel.ZIndex = 10
    statusLabel.Parent = button
    
    -- Xử lý click
    button.MouseButton1Click:Connect(function()
        Farming = not Farming
        
        if Farming then
            button.BackgroundColor3 = Color3.fromRGB(0, 200, 50)
            button.Text = "FARM\nBẬT"
            statusLabel.Text = "Đang AutoFarm..."
        else
            button.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            button.Text = "FARM\nTẮT"
            statusLabel.Text = "Đã dừng AutoFarm"
        end
    end)
    
    -- Thông báo
    local notif = Instance.new("TextLabel")
    notif.Name = "Notification"
    notif.Size = UDim2.new(0, 300, 0, 30)
    notif.Position = UDim2.new(0.5, -150, 0, 10)
    notif.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    notif.BackgroundTransparency = 0.3
    notif.Text = "DarkForge-X | Ấn nút đỏ để bắt đầu"
    notif.TextColor3 = Color3.fromRGB(0, 255, 200)
    notif.Font = Enum.Font.GothamBold
    notif.TextSize = 14
    notif.ZIndex = 10
    notif.Parent = gui
    
    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0, 8)
    notifCorner.Parent = notif
    
    -- Tự ẩn thông báo sau 5 giây
    task.spawn(function()
        task.wait(5)
        notif:Destroy()
    end)
    
    return gui
end

-- Tạo nút
local ToggleUI = CreateToggleButton()

-- ==================== QUÉT NPC ====================
local function ScanNPCs()
    local now = tick()
    if now - LastScan < 2 then return end
    LastScan = now
    
    local npcs = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("Model") then
                local hum = obj:FindFirstChild("Humanoid")
                local hrp = obj:FindFirstChild("HumanoidRootPart")
                if hum and hrp and hum.Health > 0 and not Players:GetPlayerFromCharacter(obj) then
                    table.insert(npcs, {
                        Model = obj,
                        Humanoid = hum,
                        RootPart = hrp
                    })
                end
            end
        end)
    end
    NPCS = npcs
end

-- ==================== TÌM NPC GẦN NHẤT ====================
local function GetNearestNPC()
    local char = LocalPlayer.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    
    local nearest = nil
    local minDist = FarmRange
    
    for _, npc in ipairs(NPCS) do
        if npc.Humanoid.Health > 0 and npc.RootPart then
            local dist = (root.Position - npc.RootPart.Position).Magnitude
            if dist < minDist then
                minDist = dist
                nearest = npc
            end
        end
    end
    return nearest
end

-- ==================== TẤN CÔNG ====================
local function AttackTarget(target)
    if not target then return end
    local char = LocalPlayer.Character
    if not char then return end
    
    -- Thử dùng tool
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        tool:Activate()
        task.wait(0.15)
        tool:Deactivate()
        return
    end
    
    -- Fallback: VirtualInput
    pcall(function()
        local vim = game:GetService("VirtualInputManager")
        vim:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.1)
        vim:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end)
end

-- ==================== AUTO FARM LOOP ====================
RunService.Heartbeat:Connect(function()
    if not Farming then return end
    
    local now = tick()
    if now - LastAttack < AttackDelay then return end
    
    ScanNPCs()
    local target = GetNearestNPC()
    
    if target then
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local dist = (hrp.Position - target.RootPart.Position).Magnitude
                
                -- Di chuyển nếu xa
                if dist > 15 then
                    local hum = char:FindFirstChild("Humanoid")
                    if hum then
                        hum:MoveTo(target.RootPart.Position)
                    end
                end
                
                -- Tấn công
                AttackTarget(target)
                LastAttack = now
            end
        end
    end
end)

-- ==================== CHỐNG AFK ====================
task.spawn(function()
    while task.wait(30) do
        if Farming then
            pcall(function()
                local vim = game:GetService("VirtualInputManager")
                vim:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                task.wait(0.05)
                vim:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            end)
        end
    end
end)

-- ==================== KHÔI PHỤC UI KHI CHẾT ====================
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if PlayerGui:FindFirstChild("DarkForgeX_Toggle") then
        PlayerGui.DarkForgeX_Toggle:Destroy()
    end
    ToggleUI = CreateToggleButton()
end)

-- ==================== THÔNG BÁO ====================
print("=":rep(40))
print("[DarkForge-X] Script đã chạy!")
print("[DarkForge-X] Tìm nút TRÒN ĐỎ trên màn hình")
print("[DarkForge-X] Ấn vào để BẬT/TẮT AutoFarm")
print("[DarkForge-X] Có thể KÉO nút đi chỗ khác")
print("=":rep(40))
