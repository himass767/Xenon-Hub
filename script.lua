--[[
    ██████╗  █████╗ ██████╗ ██╗  ██╗███████╗ ██████╗ ██████╗  ██████╗ ███████╗   ██╗  ██╗
    ██╔══██╗██╔══██╗██╔══██╗██║ ██╔╝██╔════╝██╔═══██╗██╔══██╗██╔════╝ ██╔════╝   ╚██╗██╔╝
    ██║  ██║███████║██████╔╝█████╔╝ █████╗  ██║   ██║██████╔╝██║  ███╗█████╗      ╚███╔╝ 
    ██║  ██║██╔══██║██╔══██╗██╔═██╗ ██╔══╝  ██║   ██║██╔══██╗██║   ██║██╔══╝      ██╔██╗ 
    ██████╔╝██║  ██║██║  ██║██║  ██╗██║     ╚██████╔╝██║  ██║╚██████╔╝███████╗   ██╔╝ ██╗
    ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝      ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝   ╚═╝  ╚═╝
    
    DarkForge-X | SHADOW-CORE MODE
    Script: NauticalReaper v4.0 FINAL
    Game: Sailor Piece [Mảnh Thủy Thủ] - Shadowrise Devs
    Target: AutoFarm + AutoBoss + AutoCollect + Anti-Ban + NoClip
    Compatibility: Delta X / CodeX / Arceus X / Solara / Wave / Synapse Z
    Status: PRODUCTION READY
]]

-- ============================================================
-- SECTION 1: ENVIRONMENT & SERVICES (Tối ưu cho Mobile & PC)
-- ============================================================
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- UI Library Load
local Rayfield = nil
local UI_LOADED = false

task.spawn(function()
    pcall(function()
        Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
        UI_LOADED = true
    end)
end)

-- ============================================================
-- SECTION 2: CONFIGURATION (Dễ dàng tùy chỉnh)
-- ============================================================
local CONFIG = {
    -- AutoFarm Settings
    FarmEnabled = false,
    FarmRange = 150,            -- Phạm vi tìm quái (studs)
    AttackDelay = 0.3,          -- Delay giữa các đòn đánh (giây)
    UseSkillOnBoss = true,      -- Dùng skill khi gặp boss
    SkillKey = "Z",             -- Phím skill chính
    
    -- Boss Settings
    BossFarmEnabled = false,
    BossNames = {"Boss", "MiniBoss", "WorldBoss"}, -- Tên boss trong game
    BossRange = 300,
    
    -- Movement Settings
    MoveSpeed = 80,             -- Tốc độ di chuyển (studs/giây)
    SafeTeleport = true,        -- Dùng MoveTo thay vì CFrame (an toàn)
    AntiFall = true,            -- Giữ Y không đổi
    MinY = 0,                   -- Tọa độ Y tối thiểu (tự động detect)
    
    -- Collect Settings
    AutoCollect = true,         -- Tự nhặt đồ
    CollectRange = 30,          -- Phạm vi nhặt đồ
    CollectFilter = {"Gem", "Coin", "Fragment", "Fruit"}, -- Lọc đồ cần nhặt
    
    -- Anti-Ban / Safety
    AntiAFK = true,             -- Chống AFK kick
    AntiVoid = true,            -- Chống rơi void (teleport về spawn)
    RandomDelay = true,         -- Delay ngẫu nhiên để tránh detect
    MaxRandomDelay = 0.5,       -- Delay random tối đa
    
    -- Performance
    ScanInterval = 3,           -- Thời gian quét lại workspace (giây)
    MaxNPCs = 50,               -- Số NPC tối đa cache
    CleanupInterval = 30,       -- Dọn dẹp cache (giây)
}

-- ============================================================
-- SECTION 3: GAME DATA CACHE (Map chính xác game Sailor Piece)
-- ============================================================
local GameData = {
    NPCs = {},                  -- Cache quái thường
    Bosses = {},                -- Cache boss
    Items = {},                 -- Cache đồ rơi
    Players = {},               -- Cache người chơi khác
    Remotes = {},               -- Cache remote events
    PlayerSpawn = nil,          -- Vị trí spawn (để teleport về)
    MapGround = 0,              -- Tọa độ Y mặt đất
    LastScan = 0,
    LastAttack = 0,
    CurrentTarget = nil,
    Stats = {
        Kills = 0,
        BossKills = 0,
        ItemsCollected = 0,
        ExpGained = 0,
    }
}

-- ============================================================
-- SECTION 4: SMART SCANNER (Quét workspace thông minh)
-- ============================================================
local function SmartScan()
    local now = tick()
    if now - GameData.LastScan < CONFIG.ScanInterval then return end
    GameData.LastScan = now
    
    local npcs = {}
    local bosses = {}
    local items = {}
    
    -- Phát hiện mặt đất (lấy Y trung bình của terrain hoặc baseplate)
    pcall(function()
        local terrain = workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            -- Lấy Y của terrain gần player
            local playerPos = LocalPlayer.Character and LocalPlayer.Character:GetPivot().Position or Vector3.new(0, 0, 0)
            -- Fallback: tìm baseplate
            for _, part in ipairs(workspace:GetChildren()) do
                if part:IsA("BasePart") and part.Name:lower():find("base") or part.Name:lower():find("ground") then
                    GameData.MapGround = part.Position.Y + (part.Size.Y / 2)
                    break
                end
            end
        end
    end)
    
    -- Fallback: lấy Y của HumanoidRootPart player
    if GameData.MapGround == 0 and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            GameData.MapGround = hrp.Position.Y
        end
    end
    
    -- Quét tất cả descendants (tối ưu: chỉ quét Models)
    for _, obj in ipairs(workspace:GetDescendants()) do
        local success = pcall(function()
            -- === QUÉT QUÁI / NPC ===
            if obj:IsA("Model") then
                local humanoid = obj:FindFirstChild("Humanoid")
                local hrp = obj:FindFirstChild("HumanoidRootPart")
                local head = obj:FindFirstChild("Head")
                
                if humanoid and hrp and humanoid.Health > 0 then
                    -- Không target player
                    if not Players:GetPlayerFromCharacter(obj) then
                        local npcData = {
                            Model = obj,
                            Humanoid = humanoid,
                            RootPart = hrp,
                            Head = head,
                            Name = obj.Name,
                            MaxHealth = humanoid.MaxHealth,
                            Health = humanoid.Health,
                            IsBoss = false
                        }
                        
                        -- Check nếu là boss
                        local nameLower = obj.Name:lower()
                        for _, bossTag in ipairs(CONFIG.BossNames) do
                            if nameLower:find(bossTag:lower()) then
                                npcData.IsBoss = true
                                break
                            end
                        end
                        -- Boss có health cao hơn 2x NPC thường
                        if humanoid.MaxHealth > 5000 then
                            npcData.IsBoss = true
                        end
                        
                        if npcData.IsBoss then
                            table.insert(bosses, npcData)
                        else
                            table.insert(npcs, npcData)
                        end
                    end
                end
            end
            
            -- === QUÉT ĐỒ RƠI ===
            if obj:IsA("Tool") and obj.Parent == workspace then
                local itemName = obj.Name:lower()
                local shouldCollect = false
                
                if #CONFIG.CollectFilter == 0 then
                    shouldCollect = true
                else
                    for _, filter in ipairs(CONFIG.CollectFilter) do
                        if itemName:find(filter:lower()) then
                            shouldCollect = true
                            break
                        end
                    end
                end
                
                if shouldCollect then
                    table.insert(items, {
                        Object = obj,
                        Name = obj.Name,
                        Position = obj:GetPivot().Position,
                        Handle = obj:FindFirstChild("Handle")
                    })
                end
            end
            
            -- Quét meshparts/parts có tag loot
            if obj:IsA("BasePart") and obj:GetAttribute("Loot") then
                table.insert(items, {
                    Object = obj,
                    Name = obj.Name,
                    Position = obj.Position,
                    Handle = obj
                })
            end
        end)
        
        if not success then
            -- Bỏ qua object lỗi
        end
    end
    
    -- Giới hạn cache để tránh lag
    if #npcs > CONFIG.MaxNPCs then
        -- Sắp xếp theo khoảng cách và chỉ giữ MaxNPCs gần nhất
        local playerPos = LocalPlayer.Character and LocalPlayer.Character:GetPivot().Position or Vector3.new(0, 0, 0)
        table.sort(npcs, function(a, b)
            return (a.RootPart.Position - playerPos).Magnitude < (b.RootPart.Position - playerPos).Magnitude
        end)
        for i = CONFIG.MaxNPCs + 1, #npcs do
            npcs[i] = nil
        end
    end
    
    GameData.NPCs = npcs
    GameData.Bosses = bosses
    GameData.Items = items
    
    -- Lưu vị trí spawn
    if LocalPlayer.Character and not GameData.PlayerSpawn then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            GameData.PlayerSpawn = hrp.Position
        end
    end
end

-- ============================================================
-- SECTION 5: MOVEMENT SYSTEM (Anti-Fall, Anti-Void, Safe TP)
-- ============================================================
local Movement = {}

function Movement:GetSafeY(targetY)
    -- Đảm bảo Y không thấp hơn mặt đất
    local safeY = math.max(targetY, GameData.MapGround + 3) -- +3 studs buffer
    return safeY
end

function Movement:MoveTo(targetPos, speed)
    local character = LocalPlayer.Character
    if not character then return false end
    
    local humanoid = character:FindFirstChild("Humanoid")
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not hrp then return false end
    
    -- Anti-Fall: Giữ Y an toàn
    local safeTarget = Vector3.new(
        targetPos.X,
        Movement:GetSafeY(targetPos.Y),
        targetPos.Z
    )
    
    -- Anti-Void: Nếu đang dưới map, teleport về spawn
    if CONFIG.AntiVoid and hrp.Position.Y < GameData.MapGround - 50 then
        if GameData.PlayerSpawn then
            hrp.CFrame = CFrame.new(GameData.PlayerSpawn)
        end
        return false
    end
    
    if CONFIG.SafeTeleport then
        -- Dùng Humanoid:MoveTo() (an toàn, tự động pathfinding)
        humanoid:MoveTo(safeTarget)
        
        -- Chờ đến nơi (có timeout)
        local timeout = 5
        local start = tick()
        while (hrp.Position - safeTarget).Magnitude > 5 do
            if tick() - start > timeout then break end
            humanoid:MoveTo(safeTarget)
            task.wait(0.1)
        end
    else
        -- Dùng Tween (nhanh hơn nhưng rủi ro hơn)
        local distance = (hrp.Position - safeTarget).Magnitude
        local tweenTime = distance / (speed or CONFIG.MoveSpeed)
        tweenTime = math.clamp(tweenTime, 0.1, 3)
        
        local tween = TweenService:Create(
            hrp,
            TweenInfo.new(tweenTime, Enum.EasingStyle.Linear),
            {CFrame = CFrame.new(safeTarget)}
        )
        tween:Play()
        tween.Completed:Wait()
    end
    
    return true
end

function Movement:TeleportTo(targetPos)
    local character = LocalPlayer.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local safeTarget = Vector3.new(
        targetPos.X,
        Movement:GetSafeY(targetPos.Y),
        targetPos.Z
    )
    
    hrp.CFrame = CFrame.new(safeTarget)
end

-- ============================================================
-- SECTION 6: COMBAT SYSTEM (Tự detect cơ chế đánh của game)
-- ============================================================
local Combat = {}
Combat.AttackMethod = nil -- "Tool", "Remote", "Click"

function Combat:DetectAttackMethod()
    if self.AttackMethod then return self.AttackMethod end
    
    -- Thử detect remote combat
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local nameLower = obj.Name:lower()
            if nameLower:find("attack") or nameLower:find("damage") or nameLower:find("hit") or nameLower:find("combat") then
                self.AttackMethod = "Remote"
                self.CombatRemote = obj
                return "Remote"
            end
        end
    end
    
    -- Thử detect tool-based combat
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if tool then
        self.AttackMethod = "Tool"
        return "Tool"
    end
    
    -- Fallback: Click
    self.AttackMethod = "Click"
    return "Click"
end

function Combat:Attack(target)
    local method = self:DetectAttackMethod()
    local char = LocalPlayer.Character
    if not char then return end
    
    if method == "Remote" and self.CombatRemote then
        -- Fire remote combat (tùy game, cần argument phù hợp)
        pcall(function()
            self.CombatRemote:FireServer(target.Model)
        end)
        
    elseif method == "Tool" then
        local tool = char:FindFirstChildOfClass("Tool")
        if not tool then
            -- Tự equip tool từ backpack
            local bpTool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
            if bpTool then
                local humanoid = char:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid:EquipTool(bpTool)
                    task.wait(0.2)
                    tool = bpTool
                end
            end
        end
        
        if tool then
            tool:Activate()
            task.wait(0.2) -- Giữ tool active để đánh
            tool:Deactivate()
        end
        
    elseif method == "Click" then
        -- Mobile: Tap màn hình
        if UserInputService.TouchEnabled then
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait(0.1)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        else
            -- PC: Click chuột
            mouse1press()
            task.wait(0.1)
            mouse1release()
        end
    end
    
    -- Dùng skill nếu gặp boss
    if CONFIG.UseSkillOnBoss and target and target.IsBoss then
        if CONFIG.SkillKey then
            keypress(Enum.KeyCode[CONFIG.SkillKey])
            task.wait(0.1)
            keyrelease(Enum.KeyCode[CONFIG.SkillKey])
        end
    end
end

-- ============================================================
-- SECTION 7: TARGET SELECTION (Chọn mục tiêu thông minh)
-- ============================================================
local function SelectBestTarget()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    -- Ưu tiên Boss nếu bật BossFarm
    if CONFIG.BossFarmEnabled and #GameData.Bosses > 0 then
        for _, boss in ipairs(GameData.Bosses) do
            local dist = (hrp.Position - boss.RootPart.Position).Magnitude
            if dist <= CONFIG.BossRange and boss.Humanoid.Health > 0 then
                return boss
            end
        end
    end
    
    -- Tìm NPC gần nhất
    local closest = nil
    local minDist = CONFIG.FarmRange
    
    for _, npc in ipairs(GameData.NPCs) do
        if npc.Humanoid.Health > 0 then
            local dist = (hrp.Position - npc.RootPart.Position).Magnitude
            if dist < minDist then
                minDist = dist
                closest = npc
            end
        end
    end
    
    return closest
end

-- ============================================================
-- SECTION 8: AUTO COLLECT (Nhặt đồ thông minh)
-- ============================================================
local function AutoCollectItems()
    if not CONFIG.AutoCollect then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    for _, item in ipairs(GameData.Items) do
        if item.Object.Parent then -- Vẫn tồn tại trong workspace
            local dist = (hrp.Position - item.Position).Magnitude
            if dist <= CONFIG.CollectRange then
                -- Di chuyển đến đồ
                Movement:MoveTo(item.Position, CONFIG.MoveSpeed * 1.5)
                task.wait(0.1)
                
                -- Nhặt đồ (touch interest)
                pcall(function()
                    if item.Object:IsA("Tool") then
                        LocalPlayer.Backpack:FindFirstChild(item.Object.Name) -- check
                        firetouchinterest(LocalPlayer.Character.HumanoidRootPart, item.Handle or item.Object, 0)
                        firetouchinterest(LocalPlayer.Character.HumanoidRootPart, item.Handle or item.Object, 1)
                    end
                end)
                
                GameData.Stats.ItemsCollected = GameData.Stats.ItemsCollected + 1
                break -- Chỉ nhặt 1 món mỗi lần
            end
        end
    end
end

-- ============================================================
-- SECTION 9: ANTI-AFK & SAFETY
-- ============================================================
local function AntiAFK()
    if not CONFIG.AntiAFK then return end
    
    task.spawn(function()
        while CONFIG.AntiAFK do
            task.wait(60) -- Mỗi 60 giây
            
            -- Giả lập input nhẹ để không bị kick
            pcall(function()
                if UserInputService.TouchEnabled then
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                    task.wait(0.05)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                else
                    -- Gửi key không quan trọng
                    keypress(0x20) -- Space
                    task.wait(0.05)
                    keyrelease(0x20)
                end
            end)
        end
    end)
end

local function AntiVoidCheck()
    if not CONFIG.AntiVoid then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- Nếu rơi xuống dưới map
    if hrp.Position.Y < GameData.MapGround - 100 then
        print("[DarkForge-X] PHÁT HIỆN RƠI VOID! Đang teleport về spawn...")
        
        -- Teleport về spawn an toàn
        local safePos = GameData.PlayerSpawn or Vector3.new(0, GameData.MapGround + 10, 0)
        Movement:TeleportTo(safePos)
        
        task.wait(1)
    end
end

-- ============================================================
-- SECTION 10: MAIN FARM LOOP
-- ============================================================
local function FarmLoop()
    if not CONFIG.FarmEnabled and not CONFIG.BossFarmEnabled then return end
    
    local now = tick()
    
    -- Chống void
    AntiVoidCheck()
    
    -- Nhặt đồ trước
    AutoCollectItems()
    
    -- Chọn mục tiêu
    local target = SelectBestTarget()
    GameData.CurrentTarget = target
    
    if target then
        local hrp = LocalPlayer.Character and 
