--[[
    DarkForge-X | SHADOW-CORE MODE
    Script: NauticalReaper_Mobile.lua
    Target: Sailor Piece (Mobile Executor)
    Requires: Rayfield UI Library
]]

-- ==================== INIT ====================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Load UI Library
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- ==================== DATA ====================
local FarmConfig = {
    Enabled = false,
    Range = 100,        -- Khoảng cách farm tối đa (studs)
    Delay = 0.5,        -- Delay giữa các đòn đánh
    Method = "Tool",    -- "Tool" hoặc "Remote" (tự detect)
    TargetBosses = true,
    TargetNPCs = true,
    CollectItems = true,
    AutoEquip = true    -- Tự động trang bị vũ khí tốt nhất
}

local EspConfig = {
    Enabled = false,
    ShowNPCs = true,
    ShowItems = true,
    NPColor = Color3.fromRGB(255, 0, 0),
    ItemColor = Color3.fromRGB(0, 255, 0)
}

local GameCache = {
    NPCs = {},
    Items = {},
    Remotes = {},
    LastAttack = 0,
    CurrentTarget = nil
}

-- ==================== RECONNAISSANCE ====================
local function ScanWorkspace()
    local npcs = {}
    local items = {}
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        pcall(function()
            -- Scan NPCs / Enemies
            if obj:IsA("Model") then
                local humanoid = obj:FindFirstChild("Humanoid")
                local hrp = obj:FindFirstChild("HumanoidRootPart")
                if humanoid and hrp and humanoid.Health > 0 then
                    -- Không target player khác
                    if not Players:GetPlayerFromCharacter(obj) then
                        table.insert(npcs, obj)
                    end
                end
            end
            
            -- Scan Items / Loot
            if obj:IsA("Tool") and obj.Parent == workspace then
                table.insert(items, obj)
            end
            -- Kiểm tra thêm mesh loot rơi (tùy game)
            if obj:IsA("MeshPart") and obj:GetAttribute("Loot") then
                table.insert(items, obj)
            end
        end)
    end
    
    -- Scan Remotes để dùng sau nếu cần
    local remotes = {}
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            table.insert(remotes, obj)
        end
    end
    
    GameCache.NPCs = npcs
    GameCache.Items = items
    GameCache.Remotes = remotes
end

-- ==================== UTILS ====================
local function GetNearestNPC()
    local character = LocalPlayer.Character
    if not character then return nil end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    
    local nearest = nil
    local minDist = FarmConfig.Range
    
    for _, npc in ipairs(GameCache.NPCs) do
        local hrp = npc:FindFirstChild("HumanoidRootPart")
        if hrp then
            local dist = (root.Position - hrp.Position).Magnitude
            if dist < minDist then
                minDist = dist
                nearest = npc
            end
        end
    end
    
    return nearest
end

local function GetBestWeapon()
    local character = LocalPlayer.Character
    if not character then return nil end
    local backpack = LocalPlayer.Backpack
    
    local bestTool = nil
    local bestDamage = 0
    
    -- Kiểm tra tool đang cầm
    for _, tool in ipairs(character:GetChildren()) do
        if tool:IsA("Tool") then
            -- Kiểm tra damage attribute nếu có
            local dmg = tool:GetAttribute("Damage") or 10
            if dmg > bestDamage then
                bestDamage = dmg
                bestTool = tool
            end
        end
    end
    
    -- Kiểm tra backpack
    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local dmg = tool:GetAttribute("Damage") or 10
            if dmg > bestDamage then
                bestDamage = dmg
                bestTool = tool
            end
        end
    end
    
    return bestTool
end

local function EquipTool(tool)
    if not tool then return end
    local character = LocalPlayer.Character
    if not character then return end
    
    -- Nếu tool đang ở backpack, equip nó
    if tool.Parent == LocalPlayer.Backpack then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid:EquipTool(tool)
        end
    end
end

local function TeleportTo(targetPos)
    local character = LocalPlayer.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- Dùng Tween để di chuyển mượt, tránh lag
    local distance = (hrp.Position - targetPos).Magnitude
    local speed = 50 -- studs/giây
    local tweenTime = distance / speed
    
    local goal = {CFrame = CFrame.new(targetPos)}
    local tween = TweenService:Create(hrp, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), goal)
    tween:Play()
    tween.Completed:Wait()
end

-- ==================== ATTACK LOGIC ====================
local function AttackTarget(target)
    if not target then return end
    local character = LocalPlayer.Character
    if not character then return end
    
    -- Cách 1: VirtualInput (tap màn hình) - Mobile
    local targetHrp = target:FindFirstChild("HumanoidRootPart")
    if targetHrp then
        -- Di chuyển đến gần (optional)
        local dist = (character.HumanoidRootPart.Position - targetHrp.Position).Magnitude
        if dist > 15 then
            TeleportTo(targetHrp.Position + Vector3.new(0, 0, 5)) -- Đứng cách 5 studs
        end
        
        -- Xoay người về phía target
        local lookAt = CFrame.lookAt(character.HumanoidRootPart.Position, targetHrp.Position)
        character:SetPrimaryPartCFrame(lookAt)
        
        -- Kích hoạt tool
        local tool = character:FindFirstChildOfClass("Tool")
        if tool then
            tool:Activate()
            task.wait(0.1)
            tool:Deactivate()
        else
            -- Fallback: tap màn hình (VirtualInput)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait(0.05)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end
    end
end

-- ==================== ESP ====================
local EspDrawings = {}

local function CreateEspDrawing()
    local drawing = Drawing.new("Square")
    drawing.Visible = false
    drawing.Filled = true
    drawing.Size = Vector2.new(10, 10)
    table.insert(EspDrawings, drawing)
    return drawing
end

local function UpdateEsp()
    -- Xóa tất cả drawing cũ
    for _, d in ipairs(EspDrawings) do
        d.Visible = false
    end
    
    if not EspConfig.Enabled then return end
    
    local drawingIndex = 1
    local function GetDrawing()
        if drawingIndex > #EspDrawings then
            CreateEspDrawing()
        end
        local d = EspDrawings[drawingIndex]
        drawingIndex = drawingIndex + 1
        return d
    end
    
    -- Vẽ NPCs
    if EspConfig.ShowNPCs then
        for _, npc in ipairs(GameCache.NPCs) do
            local hrp = npc:FindFirstChild("HumanoidRootPart")
            if hrp then
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local d = GetDrawing()
                    d.Visible = true
                    d.Position = Vector2.new(pos.X, pos.Y)
                    d.Color = EspConfig.NPColor
                end
            end
        end
    end
    
    -- Vẽ Items
    if EspConfig.ShowItems then
        for _, item in ipairs(GameCache.Items) do
            if item.Parent then
                local pos, onScreen = Camera:WorldToViewportPoint(item.Position)
                if onScreen then
                    local d = GetDrawing()
                    d.Visible = true
                    d.Position = Vector2.new(pos.X, pos.Y)
                    d.Color = EspConfig.ItemColor
                end
            end
        end
    end
end

-- ==================== MAIN LOOP ====================
local function FarmLoop()
    if not FarmConfig.Enabled then return end
    
    -- Auto Equip best weapon
    if FarmConfig.AutoEquip then
        local best = GetBestWeapon()
        if best then
            EquipTool(best)
        end
    end
    
    -- Collect Items
    if FarmConfig.CollectItems then
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            for _, item in ipairs(GameCache.Items) do
                if item.Parent then
                    local dist = (character.HumanoidRootPart.Position - item.Position).Magnitude
                    if dist < 20 then
                        TeleportTo(item.Position)
                        task.wait(0.2)
                    end
                end
            end
        end
    end
    
    -- Attack NPC/Boss
    if FarmConfig.TargetNPCs or FarmConfig.TargetBosses then
        local target = GetNearestNPC()
        if target then
            AttackTarget(target)
        end
    end
end

-- ==================== UI ====================
local Window = Rayfield:CreateWindow({
    Name = "DarkForge-X | NauticalReaper",
    LoadingTitle = "SHADOW-CORE MODE",
    LoadingSubtitle = "Sailor Piece AutoFarm",
    ConfigurationSaving = {Enabled = false}
})

local FarmTab = Window:CreateTab("⚔️ AutoFarm")

FarmTab:CreateToggle({
    Name = "Bật/Tắt AutoFarm",
    CurrentValue = false,
    Callback = function(val) FarmConfig.Enabled = val end
})

FarmTab:CreateSlider({
    Name = "Phạm vi Farm",
    Range = {20, 500},
    Increment = 10,
    CurrentValue = 100,
    Callback = function(val) FarmConfig.Range = val end
})

FarmTab:CreateToggle({
    Name = "Tự động nhặt đồ",
    CurrentValue = true,
    Callback = function(val) FarmConfig.CollectItems = val end
})

FarmTab:CreateToggle({
    Name = "Tự động đổi vũ khí mạnh nhất",
    CurrentValue = true,
    Callback = function(val) FarmConfig.AutoEquip = val end
})

local EspTab = Window:CreateTab("👁️ ESP")
EspTab:CreateToggle({
    Name = "Bật/Tắt ESP",
    CurrentValue = false,
    Callback = function(val) EspConfig.Enabled = val end
})

-- ==================== EXECUTION ====================
-- Scan ban đầu
ScanWorkspace()

-- Rescan mỗi 3 giây (tối ưu mobile, không quá nặng)
task.spawn(function()
    while task.wait(3) do
        ScanWorkspace()
    end
end)

-- Farm loop (heartbeat-based)
RunService.Heartbeat:Connect(function()
    FarmLoop()
end)

-- ESP render loop
RunService.RenderStepped:Connect(function()
    UpdateEsp()
end)

print("[DarkForge-X] NauticalReaper Mobile v3.0 đã sẵn sàng.")
print("[DarkForge-X] Tính năng: AutoFarm, AutoCollect, ESP")
print("[DarkForge-X] Mở UI để bắt đầu!")
