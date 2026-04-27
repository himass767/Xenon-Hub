--[[
    DarkForge-X | SHADOW-CORE MODE
    Script: Ultimate Troll - Chạm Bay + Ôm Bay
    Tính năng:
    - Chế độ 1: Chạm Là Bay (người khác văng đi)
    - Chế độ 2: Ôm Người Chơi (giữ họ, bay cùng bạn)
    - Chế độ 3: Ôm + Ném (giữ rồi quăng đi xa)
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ==================== CẤU HÌNH ====================
local MODE = 1  -- 1: Chạm Bay | 2: Ôm Bay | 3: Ôm + Ném
local ENABLED = false
local RANGE = 12
local GRABBED_PLAYER = nil  -- Người đang bị ôm
local FLY_SPEED = 100       -- Tốc độ bay khi ôm

-- ==================== UI ====================
pcall(function() PlayerGui:FindFirstChild("UltimateTroll_UI"):Destroy() end)

local gui = Instance.new("ScreenGui")
gui.Name = "UltimateTroll_UI"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

-- Nút chính
local mainBtn = Instance.new("TextButton")
mainBtn.Size = UDim2.new(0, 65, 0, 65)
mainBtn.Position = UDim2.new(0.85, 0, 0.55, 0)
mainBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
mainBtn.Text = "TẮT"
mainBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
mainBtn.Font = Enum.Font.GothamBold
mainBtn.TextSize = 12
mainBtn.BorderSizePixel = 0
mainBtn.Draggable = true
mainBtn.Parent = gui
Instance.new("UICorner", mainBtn).CornerRadius = UDim.new(0, 33)

-- Nút đổi chế độ
local modeBtn = Instance.new("TextButton")
modeBtn.Size = UDim2.new(0, 50, 0, 50)
modeBtn.Position = UDim2.new(0.85, 0, 0.7, 0)
modeBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
modeBtn.Text = "BAY"
modeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
modeBtn.Font = Enum.Font.GothamBold
modeBtn.TextSize = 11
modeBtn.BorderSizePixel = 0
modeBtn.Draggable = true
modeBtn.Parent = gui
Instance.new("UICorner", modeBtn).CornerRadius = UDim.new(0, 25)

-- Nhãn trạng thái
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0, 200, 0, 25)
statusLabel.Position = UDim2.new(0.5, -100, 0.05, 0)
statusLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
statusLabel.BackgroundTransparency = 0.5
statusLabel.Text = "CHẾ ĐỘ: CHẠM BAY"
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 13
statusLabel.Parent = gui
Instance.new("UICorner", statusLabel).CornerRadius = UDim.new(0, 8)

-- Nhãn ôm
local grabLabel = Instance.new("TextLabel")
grabLabel.Size = UDim2.new(0, 200, 0, 25)
grabLabel.Position = UDim2.new(0.5, -100, 0.1, 0)
grabLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
grabLabel.BackgroundTransparency = 0.5
grabLabel.Text = "ĐANG ÔM: KHÔNG"
grabLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
grabLabel.Font = Enum.Font.GothamBold
grabLabel.TextSize = 13
grabLabel.Parent = gui
Instance.new("UICorner", grabLabel).CornerRadius = UDim.new(0, 8)

-- ==================== XỬ LÝ UI ====================
mainBtn.MouseButton1Click:Connect(function()
    ENABLED = not ENABLED
    if not ENABLED then
        GRABBED_PLAYER = nil  -- Thả người đang ôm
    end
    mainBtn.BackgroundColor3 = ENABLED and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    mainBtn.Text = ENABLED and "BẬT" or "TẮT"
end)

modeBtn.MouseButton1Click:Connect(function()
    MODE = MODE + 1
    if MODE > 3 then MODE = 1 end
    GRABBED_PLAYER = nil  -- Thả người đang ôm
    
    if MODE == 1 then
        modeBtn.Text = "BAY"
        modeBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        statusLabel.Text = "CHẾ ĐỘ: CHẠM BAY"
    elseif MODE == 2 then
        modeBtn.Text = "ÔM"
        modeBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        statusLabel.Text = "CHẾ ĐỘ: ÔM BAY"
    elseif MODE == 3 then
        modeBtn.Text = "NÉM"
        modeBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 150)
        statusLabel.Text = "CHẾ ĐỘ: ÔM + NÉM"
    end
end)

-- ==================== HÀM CHÍNH ====================

-- Hàm tìm người chơi gần nhất
local function getNearestPlayer()
    local char = LocalPlayer.Character
    if not char then return nil end
    local myRoot = char:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    
    local nearest = nil
    local minDist = RANGE
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local targetChar = player.Character
            if targetChar then
                local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                if targetRoot then
                    local dist = (myRoot.Position - targetRoot.Position).Magnitude
                    if dist < minDist then
                        minDist = dist
                        nearest = player
                    end
                end
            end
        end
    end
    return nearest
end

-- Hàm đẩy người chơi bay đi (CHẾ ĐỘ 1)
local function pushPlayerAway(targetPlayer)
    local targetChar = targetPlayer.Character
    if not targetChar then return end
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end
    
    -- Tắt anchor để có thể đẩy
    pcall(function()
        targetRoot.Anchored = false
        targetRoot.CanCollide = false
    end)
    
    -- Đẩy bằng nhiều cách một lúc
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    
    if myRoot then
        local direction = (targetRoot.Position - myRoot.Position).Unit
        targetRoot.Velocity = direction * Vector3.new(300, 300, 300)
        targetRoot.AssemblyLinearVelocity = direction * 500 + Vector3.new(0, 800, 0)
    else
        targetRoot.Velocity = Vector3.new(math.random(-300,300), 800, math.random(-300,300))
    end
    
    -- CFrame push
    pcall(function()
        targetRoot.CFrame = targetRoot.CFrame + Vector3.new(0, 15, 0)
    end)
end

-- Hàm ôm người chơi (CHẾ ĐỘ 2 & 3)
local function grabPlayer(targetPlayer)
    if GRABBED_PLAYER then return end  -- Đang ôm người khác rồi
    
    local targetChar = targetPlayer.Character
    if not targetChar then return end
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end
    
    -- Tắt anchor để kéo đi được
    pcall(function()
        targetRoot.Anchored = false
        targetRoot.CanCollide = false
        local hum = targetChar:FindFirstChild("Humanoid")
        if hum then hum.PlatformStand = true end
    end)
    
    GRABBED_PLAYER = targetPlayer
    grabLabel.Text = "ĐANG ÔM: " .. targetPlayer.Name
    grabLabel.TextColor3 = Color3.fromRGB(255, 100, 0)
end

-- Hàm thả người đang ôm
local function releasePlayer(throw)
    if not GRABBED_PLAYER then return end
    
    local targetChar = GRABBED_PLAYER.Character
    if targetChar then
        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
        if targetRoot then
            pcall(function()
                targetRoot.Anchored = false
                targetRoot.CanCollide = true
                local hum = targetChar:FindFirstChild("Humanoid")
                if hum then hum.PlatformStand = false end
                
                if throw then
                    -- Ném đi xa
                    targetRoot.Velocity = Vector3.new(math.random(-500,500), 1000, math.random(-500,500))
                    targetRoot.AssemblyLinearVelocity = Vector3.new(math.random(-300,300), 1200, math.random(-300,300))
                end
            end)
        end
    end
    
    GRABBED_PLAYER = nil
    grabLabel.Text = "ĐANG ÔM: KHÔNG"
    grabLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
end

-- Hàm kéo người bị ôm theo mình
local function updateGrab()
    if not GRABBED_PLAYER then return end
    
    local myChar = LocalPlayer.Character
    if not myChar then return end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    
    local targetChar = GRABBED_PLAYER.Character
    if not targetChar then
        GRABBED_PLAYER = nil
        return
    end
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not targetRoot then
        GRABBED_PLAYER = nil
        return
    end
    
    -- Kéo người đó theo sau lưng
    local behindPos = myRoot.Position - (myRoot.CFrame.LookVector * 5) + Vector3.new(0, 2, 0)
    targetRoot.CFrame = CFrame.new(behindPos)
    targetRoot.Velocity = Vector3.new(0, 0, 0)
    targetRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
end

-- Hàm bay khi đang ôm người (điều khiển bay)
local function flyWithGrab()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end
    
    -- Cho phép bay
    hum.PlatformStand = true
    
    local moveDirection = Vector3.new(0, 0, 0)
    
    -- Điều khiển bằng phím WASD
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        moveDirection = moveDirection + root.CFrame.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        moveDirection = moveDirection - root.CFrame.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        moveDirection = moveDirection - root.CFrame.RightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        moveDirection = moveDirection + root.CFrame.RightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        moveDirection = moveDirection + Vector3.new(0, 1, 0)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        moveDirection = moveDirection - Vector3.new(0, 1, 0)
    end
    
    if moveDirection.Magnitude > 0 then
        root.Velocity = moveDirection.Unit * FLY_SPEED
    else
        root.Velocity = Vector3.new(0, 0, 0)
    end
end

-- ==================== VÒNG LẶP CHÍNH ====================
task.spawn(function()
    while task.wait(0.05) do
        if not ENABLED then continue end
        
        local nearestPlayer = getNearestPlayer()
        
        -- CHẾ ĐỘ 1: CHẠM BAY
        if MODE == 1 then
            if nearestPlayer then
                pushPlayerAway(nearestPlayer)
            end
            
        -- CHẾ ĐỘ 2: ÔM BAY
        elseif MODE == 2 then
            if GRABBED_PLAYER then
                -- Bay cùng người bị ôm
                flyWithGrab()
                updateGrab()
            else
                -- Tìm người để ôm
                if nearestPlayer then
                    grabPlayer(nearestPlayer)
                end
            end
            
        -- CHẾ ĐỘ 3: ÔM + NÉM
        elseif MODE == 3 then
            if GRABBED_PLAYER then
                flyWithGrab()
                updateGrab()
                -- Ném khi nhấn phím R
                if UserInputService:IsKeyDown(Enum.KeyCode.R) then
                    releasePlayer(true)
                end
            else
                if nearestPlayer then
                    grabPlayer(nearestPlayer)
                end
            end
        end
    end
end)

-- ==================== PHÍM TẮT ====================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Phím T: Thả người đang ôm (không ném)
    if input.KeyCode == Enum.KeyCode.T then
        releasePlayer(false)
    end
    
    -- Phím R: Ném người đang ôm
    if input.KeyCode == Enum.KeyCode.R then
        releasePlayer(true)
    end
    
    -- Phím Y: Bật/tắt nhanh
    if input.KeyCode == Enum.KeyCode.Y then
        ENABLED = not ENABLED
        if not ENABLED then releasePlayer(false) end
        mainBtn.BackgroundColor3 = ENABLED and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        mainBtn.Text = ENABLED and "BẬT" or "TẮT"
    end
end)

-- ==================== KHÔI PHỤC ====================
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    pcall(function()
        PlayerGui:FindFirstChild("UltimateTroll_UI"):Destroy()
        gui.Parent = PlayerGui
    end)
end)

print("=":rep(40))
print("[DarkForge-X] Ultimate Troll - Đã sẵn sàng!")
print("[DarkForge-X] Các chế độ:")
print("[DarkForge-X]   BAY: Chạm là người khác bay")
print("[DarkForge-X]   ÔM: Ấn vào người để ôm, WASD bay")
print("[DarkForge-X]   NÉM: Ôm + phím R để ném đi")
print("[DarkForge-X] Phím tắt:")
print("[DarkForge-X]   Y: Bật/tắt | T: Thả | R: Ném")
print("[DarkForge-X]   SPACE: Bay lên | SHIFT: Bay xuống")
print("=":rep(40))
