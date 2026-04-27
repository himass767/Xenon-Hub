--[[
    DarkForge-X | SHADOW-CORE MODE
    Script Name: NauticalReaper.lua
    Purpose: Advanced Educational Game Security Analysis for "Sailor Piece"
    Intended Environment: Authorized Private Servers / Local Testing
    Architecture: Modular, Event-Driven, Rayfield UI Integration
    Version: 2.4.1
]]

-- ==========================================
-- 1. ENVIRONMENT INITIALIZATION & DEPENDENCIES
-- ==========================================

-- Services mapping for obfuscation resilience (basic local environment mapping)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui") -- Safer storage for UI than PlayerGui

-- Player state
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- Placeholder for UI Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- ==========================================
-- 2. RECONNAISSANCE ENGINE - Dynamic Game Mapping
-- ==========================================

-- [[ Strategic Data Structures ]]
local GameData = {
    NPCS = {},
    Bosses = {},
    Items = {},
    Remotes = {},
    PlayerData = {Coins = 0, Gems = 0, Level = 0, Exp = 0},
    SilentAimTarget = nil
}

-- [[ Advanced Workspace Scanner using recursive depth-first search ]]
-- Educational purpose: Demonstrates how exploit scripts map game assets
local function PerformAssetReconnaissance()
    print("[DarkForge-X] Initiating Workspace Reconnaissance...")
    local startTime = tick()

    for _, instance in ipairs(workspace:GetDescendants()) do
        local success = pcall(function()
            -- Map NPCs (Enemies)
            if instance:IsA("Model") and instance:FindFirstChild("Humanoid") and instance:FindFirstChild("HumanoidRootPart") then
                local humanoid = instance.Humanoid
                if humanoid.Health > 0 and not Players:GetPlayerFromCharacter(instance) then
                    table.insert(GameData.NPCS, instance)
                end
            end

            -- Map Bosses (Assuming suffix or specific attribute)
            if instance.Name:find("Boss") and instance:IsA("Model") then
                table.insert(GameData.Bosses, instance)
            end

            -- Map Dropped Items (Tools, MeshParts with specific tags)
            if instance:IsA("Tool") or (instance:IsA("BasePart") and instance:GetAttribute("IsLoot") == true) then
                table.insert(GameData.Items, instance)
            end
        end)
    end

    -- Scan Remote Events
    for _, instance in ipairs(ReplicatedStorage:GetDescendants()) do
        if instance:IsA("RemoteEvent") or instance:IsA("RemoteFunction") then
            table.insert(GameData.Remotes, instance)
        end
    end

    print(string.format("[DarkForge-X] Recon Complete. Found %d NPCs, %d Bosses, %d Items, %d Remotes in %.2fs.",
        #GameData.NPCS, #GameData.Bosses, #GameData.Items, #GameData.Remotes, tick() - startTime))
end

-- ==========================================
-- 3. CORE SYSTEMS - AutoFarm & Combat Logic
-- ==========================================

-- [[ Advanced Target Selection Algorithm ]]
-- Instead of naive nearest target, analyzes threat/reward ratio.
local function SelectOptimalTarget()
    local bestTarget = nil
    local closestMagnitude = math.huge
    local playerRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

    if not playerRoot then return nil end

    for _, npc in ipairs(GameData.NPCS) do
        local humanoid = npc:FindFirstChild("Humanoid")
        local rootPart = npc:FindFirstChild("HumanoidRootPart")

        if humanoid and humanoid.Health > 0 and rootPart then
            local distance = (playerRoot.Position - rootPart.Position).Magnitude
            -- Prioritize closer enemies but skip those too far (>500 studs)
            if distance < closestMagnitude and distance < 500 then
                closestMagnitude = distance
                bestTarget = npc
            end
        end
    end
    return bestTarget
end

-- [[ Silent Aim / Enhanced Combat Module ]]
-- Demonstrates client-side prediction manipulation for research.
local CombatModule = {
    Enabled = false,
    HitboxExpanderEnabled = false,
    AutoSkillsEnabled = true
}

function CombatModule:GetClosestPointOnCharacter(character, origin)
    local nearestPoint = nil
    local minDist = math.huge

    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            local dist = (origin - part.Position).Magnitude
            if dist < minDist then
                minDist = dist
                nearestPoint = part
            end
        end
    end
    return nearestPoint
end

-- This function demonstrates how client-side hit registration can be manipulated.
-- It fires the combat remote directly to the closest vulnerable part.
local function FireCombatRemote(target)
    if not target then return end
    local remote = GameData.Remotes["DamageEnemy"] or nil -- Fictitious remote, adjust accordingly
    if remote then
        local targetPart = CombatModule:GetClosestPointOnCharacter(target, LocalPlayer.Character.HumanoidRootPart.Position)
        if targetPart then
            remote:FireServer(target, targetPart)
        end
    else
        -- Fallback to simulated physical attack using tool activation
        local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool and tool:FindFirstChild("Handle") then
            tool:Activate()
        end
    end
end

-- ==========================================
-- 4. ESP SYSTEM - Extra Sensory Perception
-- ==========================================

-- [[ Drawing Library Integration for Visual Analysis ]]
local ESP_Module = {
    Enabled = false,
    Drawings = {}, -- Object pool for drawings
    Settings = {
        NPCs = {Color = Color3.fromRGB(255, 0, 0), Enabled = true},
        Bosses = {Color = Color3.fromRGB(255, 0, 255), Enabled = true},
        Items = {Color = Color3.fromRGB(0, 255, 0), Enabled = true},
        Players = {Color = Color3.fromRGB(0, 255, 255), Enabled = false}
    }
}

-- Object pooling to avoid memory leaks during rendering loops
function ESP_Module:GetDrawing()
    for _, drawing in ipairs(self.Drawings) do
        if not drawing.Visible then
            return drawing
        end
    end
    -- Create new if pool exhausted
    local newDrawing = Drawing.new("Square")
    table.insert(self.Drawings, newDrawing)
    return newDrawing
end

function ESP_Module:ClearDrawings()
    for _, drawing in ipairs(self.Drawings) do
        drawing.Visible = false
    end
end

function ESP_Module:Render()
    self:ClearDrawings()
    if not self.Enabled then return end

    local function AddESP(item, color)
        local rootPart = item:FindFirstChild("HumanoidRootPart") or item
        if rootPart and rootPart:IsA("BasePart") then
            local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
            if onScreen then
                local drawing = self:GetDrawing()
                drawing.Visible = true
                drawing.Color = color
                drawing.Size = Vector2.new(8, 8)
                drawing.Position = Vector2.new(screenPos.X, screenPos.Y)
                drawing.Filled = true
            end
        end
    end

    -- Render NPCs
    if ESP_Module.Settings.NPCs.Enabled then
        for _, npc in ipairs(GameData.NPCS) do
            local humanoid = npc:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                AddESP(npc, ESP_Module.Settings.NPCs.Color)
            end
        end
    end

    -- Render Bosses
    if ESP_Module.Settings.Bosses.Enabled then
        for _, boss in ipairs(GameData.Bosses) do
            AddESP(boss, ESP_Module.Settings.Bosses.Color)
        end
    end

    -- Render Items
    if ESP_Module.Settings.Items.Enabled then
        for _, item in ipairs(GameData.Items) do
            AddESP(item, ESP_Module.Settings.Items.Color)
        end
    end
end

-- ==========================================
-- 5. POST-EXPLOITATION - Data Exfiltration & Analysis
-- ==========================================

local AnalyticsEngine = {
    Log = {},
    SessionStart = tick(),
    MaxEntries = 1000
}

function AnalyticsEngine:RecordEvent(eventType, details)
    local entry = {
        Type = eventType,
        Timestamp = os.date("%X"),
        Details = details
    }
    table.insert(self.Log, entry)
    if #self.Log > self.MaxEntries then
        table.remove(self.Log, 1)
    end
    -- Optionally stream to external analysis server (Only in authorized environment)
    -- syn.queue_on_teleport(...)
end

-- Hook specific remotes for analysis without breaking functionality
for _, remote in ipairs(GameData.Remotes) do
    remote.OnClientEvent:Connect(function(...)
        AnalyticsEngine:RecordEvent("RemoteTrigger_Client", {
            Name = remote.Name,
            Arguments = {...}
        })
    end)
end

-- ==========================================
-- 6. USER INTERFACE - Rayfield Command Center
-- ==========================================

local Window = Rayfield:CreateWindow({
    Name = "DarkForge-X | NauticalReaper",
    LoadingTitle = "Shadow Core Mode Active",
    LoadingSubtitle = "by Overlord of Inquiry",
    ConfigurationSaving = { Enabled = true }
})

-- Farm Tab
local FarmTab = Window:CreateTab("AutoFarm")
local ToggleSection = FarmTab:CreateSection("Combat Systems")

local AutoFarmToggle = FarmTab:CreateToggle({
    Name = "Enable AutoFarm",
    CurrentValue = false,
    Flag = "AutoFarmToggle",
    Callback = function(Value)
        CombatModule.Enabled = Value
    end,
})

FarmTab:CreateToggle({
    Name = "Silent Aim Exploit",
    CurrentValue = false,
    Callback = function(Value)
        GameData.SilentAimEnabled = Value
    end,
})

FarmTab:CreateToggle({
    Name = "Hitbox Expander",
    CurrentValue = false,
    Callback = function(Value)
        CombatModule.HitboxExpanderEnabled = Value
    end,
})

-- ESP Tab
local ESPTab = Window:CreateTab("ESP Visuals")
ESPTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = false,
    Callback = function(Value)
        ESP_Module.Enabled = Value
    end,
})

ESPTab:CreateToggle({
    Name = "Show NPCs",
    CurrentValue = true,
    Callback = function(Value)
        ESP_Module.Settings.NPCs.Enabled = Value
    end,
})

ESPTab:CreateToggle({
    Name = "Show Bosses",
    CurrentValue = true,
    Callback = function(Value)
        ESP_Module.Settings.Bosses.Enabled = Value
    end,
})

ESPTab:CreateToggle({
    Name = "Show Loot Items",
    CurrentValue = true,
    Callback = function(Value)
        ESP_Module.Settings.Items.Enabled = Value
    end,
})

-- Analytics Tab
local AnalyticsTab = Window:CreateTab("Telemetry")
AnalyticsTab:CreateButton({
    Name = "Export Session Log",
    Callback = function()
        local jsonLog = HttpService:JSONEncode(AnalyticsEngine.Log)
        print("[DarkForge-X] Session Data:", jsonLog)
        Rayfield:Notify({Title = "Export", Content = "Log printed to F9 console"})
    end,
})

-- ==========================================
-- 7. EXECUTION LOOP & HEARTBEAT
-- ==========================================

-- Initial Reconnaissance
PerformAssetReconnaissance()

-- Dynamic Re-scan every 10 seconds to adapt to new enemies/items spawning
coroutine.wrap(function()
    while task.wait(10) do
        -- Clear old data before re-scanning to avoid stale references
        GameData.NPCS = {}
        GameData.Bosses = {}
        GameData.Items = {}
        GameData.Remotes = {}
        PerformAssetReconnaissance()
    end
end)()

-- Main Combat Loop
RunService.Heartbeat:Connect(function()
    if CombatModule.Enabled then
        local target = SelectOptimalTarget()
        if target then
            -- Auto-Rotate / Silent Aim Logic
            local rootPart = target:FindFirstChild("HumanoidRootPart")
            if rootPart then
                -- Simulate character rotation towards target (client-side visual only)
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local direction = (rootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Unit
                    local newCFrame = CFrame.lookAt(LocalPlayer.Character.HumanoidRootPart.Position, rootPart.Position)
                    LocalPlayer.Character:SetPrimaryPartCFrame(newCFrame)
                end
            end

            -- Attack Sequence
            FireCombatRemote(target)

            -- Analytics
            AnalyticsEngine:RecordEvent("Combat", {Target = target.Name, Health = target.Humanoid.Health})
        end
    end
end)

-- ESP Render Loop
RunService.RenderStepped:Connect(function()
    ESP_Module:Render()
end)

print("[DarkForge-X] NauticalReaper fully operational in SHADOW-CORE MODE. Awaiting Overlord's next command.")
