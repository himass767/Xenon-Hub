--[[
    DarkForge-X | SHADOW-CORE MODE
    Script: NauticalReaper VNG Edition
    Dành riêng cho: Roblox VNG + Delta X Android
    Game: Sailor Piece (Mảnh Thủy Thủ)
]]

-- Khởi tạo services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Biến toàn cục
local Farming = false
local LastAttack = 0
local AttackDelay = 0.3
local NPCS = {}
local LastScan = 0

-- Xóa UI cũ nếu có
if PlayerGui:FindFirstChild("DFX_VNG") then
    PlayerGui.DFX_VNG:Destroy()
end

-- Tạo UI đơn giản
local gui = Instance.new("ScreenGui")
gui.Name = "DFX_VNG"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

-- Nút bật/tắt
local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0, 70, 0, 70)
btn.Position = UDim2.new(0.8, 0, 0.6, 0)
btn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
btn.Text = "TẮT"
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.Font = Enum.Font.GothamBold
btn.TextSize = 14
btn.BorderSizePixel = 0
btn.Draggable = true
btn.Parent = gui

Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 35)

-- Xử lý bật/tắt
btn.MouseButton1Click:Connect(function()
    Farming = not Farming
    if Farming then
        btn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        btn.Text = "BẬT"
    else
        btn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        btn.Text = "TẮT"
    end
end)

-- Quét NPC
local function scan()
    if tick() - LastScan < 2 then return end
    LastScan = tick()
    local npcs = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("Model") then
                local hum = obj:FindFirstChild("Humanoid")
                local hrp = obj:FindFirstChild("HumanoidRootPart")
                if hum and hrp and hum.Health > 0 and not Players:GetPlayerFromCharacter(obj) then
                    table.insert(npcs, {Humanoid = hum, RootPart = hrp})
                end
            end
        end)
    end
    NPCS = npcs
end

-- Tìm NPC gần nhất
local function getNearest()
    local char = LocalPlayer.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local nearest, minDist = nil, 200
    for _, npc in ipairs(NPCS) do
        if npc.Humanoid.Health > 0 then
            local dist = (root.Position - npc.RootPart.Position).Magnitude
            if dist < minDist then minDist = dist; nearest = npc end
        end
    end
    return nearest
end

-- Tấn công
local function atk(target)
    if not target then return end
    local char = LocalPlayer.Character
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        tool:Activate()
        task.wait(0.1)
        tool:Deactivate()
    end
end

-- Loop chính
RunService.Heartbeat:Connect(function()
    if not Farming then return end
    if tick() - LastAttack < AttackDelay then return end
    scan()
    local target = getNearest()
    if target then
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local dist = (hrp.Position - target.RootPart.Position).Magnitude
                if dist > 12 then
                    local hum = char:FindFirstChild("Humanoid")
                    if hum then hum:MoveTo(target.RootPart.Position) end
                end
                atk(target)
                LastAttack = tick()
            end
        end
    end
end)

-- Chống AFK
task.spawn(function()
    while task.wait(30) do
        if Farming then
            pcall(function()
                game:GetService("VirtualInputManager"):SendMouseButtonEvent(0, 0, 0, true, game, 0)
                task.wait(0.05)
                game:GetService("VirtualInputManager"):SendMouseButtonEvent(0, 0, 0, false, game, 0)
            end)
        end
    end
end)

-- Phục hồi UI khi chết
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if PlayerGui:FindFirstChild("DFX_VNG") then
        PlayerGui.DFX_VNG:Destroy()
    end
    gui = Instance.new("ScreenGui")
    gui.Name = "DFX_VNG"
    gui.ResetOnSpawn = false
    gui.Parent = PlayerGui
    btn.Parent = gui
end)

print("[DarkForge-X] VNG Edition - Sẵn sàng!")
