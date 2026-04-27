--[[
    DarkForge-X | SHADOW-CORE MODE
    Script: NauticalReaper v5.0 - BUILT-IN UI
    Game: Sailor Piece (Mảnh Thủy Thủ)
    Đặc điểm: KHÔNG CẦN THƯ VIỆN NGOÀI - UI tự tạo 100%
]]

-- ============================================================
-- SECTION 1: KHỞI TẠO MÔI TRƯỜNG
-- ============================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ============================================================
-- SECTION 2: TẠO UI TỪ ĐẦU (BUILT-IN UI LIBRARY)
-- ============================================================
local UI = {}

-- Tạo ScreenGui an toàn
local function CreateSafeGui()
    local gui = nil
    
    -- Thử CoreGui trước
    pcall(function()
        gui = Instance.new("ScreenGui")
        gui.Parent = CoreGui
        gui.Name = "DarkForgeX_UI"
        gui.ResetOnSpawn = false
    end)
    
    -- Nếu CoreGui fail, dùng PlayerGui
    if not gui or not gui.Parent then
        pcall(function()
            gui = Instance.new("ScreenGui")
            gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
            gui.Name = "DarkForgeX_UI"
            gui.ResetOnSpawn = false
        end)
    end
    
    return gui
end

local ScreenGui = CreateSafeGui()
if not ScreenGui then
    warn("[DarkForge-X] KHÔNG THỂ TẠO UI! Executor của bạn có thể bị hạn chế.")
    return
end

print("[DarkForge-X] UI Container created successfully in", ScreenGui.Parent.Name)

-- ============================================================
-- SECTION 3: UI COMPONENTS (Tự code các thành phần UI)
-- ============================================================

-- [[ MAIN WINDOW ]]
local MainWindow = Instance.new("Frame")
MainWindow.Name = "MainWindow"
MainWindow.Size = UDim2.new(0, 350, 0, 450)
MainWindow.Position = UDim2.new(0.5, -175, 0.5, -225)
MainWindow.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainWindow.BorderSizePixel = 0
MainWindow.Active = true
MainWindow.Draggable = true
MainWindow.Visible = true
MainWindow.Parent = ScreenGui

-- Bo góc
local UICorner_Main = Instance.new("UICorner")
UICorner_Main.CornerRadius = UDim.new(0, 10)
UICorner_Main.Parent = MainWindow

-- [[ TITLE BAR ]]
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainWindow

local UICorner_Title = Instance.new("UICorner")
UICorner_Title.CornerRadius = UDim.new(0, 10)
UICorner_Title.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -80, 1, 0)
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "DarkForge-X | NauticalReaper v5.0"
TitleText.TextColor3 = Color3.fromRGB(0, 255, 200)
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 14
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

-- [[ CLOSE BUTTON ]]
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 16
CloseButton.BorderSizePixel = 0
CloseButton.Parent = TitleBar

local UICorner_Close = Instance.new("UICorner")
UICorner_Close.CornerRadius = UDim.new(0, 15)
UICorner_Close.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
    MainWindow.Visible = not MainWindow.Visible
end)

-- [[ MINIMIZE BUTTON ]]
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -70, 0, 5)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.fromRGB(0, 0, 0)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.TextSize = 18
MinimizeButton.BorderSizePixel = 0
MinimizeButton.Parent = TitleBar

local UICorner_Min = Instance.new("UICorner")
UICorner_Min.CornerRadius = UDim.new(0, 15)
UICorner_Min.Parent = MinimizeButton

MinimizeButton.MouseButton1Click:Connect(function()
    -- Toggle content visibility
    for _, child in ipairs(MainWindow:GetChildren()) do
        if child.Name ~= "TitleBar" then
            child.Visible = not child.Visible
        end
    end
end)

-- [[ CONTENT AREA ]]
local ContentArea = Instance.new("Frame")
ContentArea.Name = "Content"
ContentArea.Size = UDim2.new(1, -20, 1, -60)
ContentArea.Position = UDim2.new(0, 10, 0, 50)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainWindow

-- [[ TAB SYSTEM ]]
local Tabs = {}
local TabButtons = {}
local CurrentTab = nil

local TabButtonHolder = Instance.new("Frame")
TabButtonHolder.Name = "TabButtons"
TabButtonHolder.Size = UDim2.new(1, 0, 0, 35)
TabButtonHolder.BackgroundTransparency = 1
TabButtonHolder.Parent = ContentArea

local TabContentHolder = Instance.new("Frame")
TabContentHolder.Name = "TabContent"
TabContentHolder.Size = UDim2.new(1, 0, 1, -40)
TabContentHolder.Position = UDim2.new(0, 0, 0, 40)
TabContentHolder.BackgroundTransparency = 1
TabContentHolder.Parent = ContentArea

-- [[ SCROLLING FRAME ]]
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.ScrollBarThickness = 4
ScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 200)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.Parent = TabContentHolder

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ScrollingFrame

local UIPadding = Instance.new("UIPadding")
UIPadding.PaddingRight = UDim.new(0, 5)
UIPadding.Parent = ScrollingFrame

-- ============================================================
-- SECTION 4: UI HELPER FUNCTIONS
-- ============================================================

function UI:CreateTab(name)
    local tabContent = Instance.new("Frame")
    tabContent.Name = name .. "_Content"
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.BackgroundTransparency = 1
    tabContent.Visible = false
    tabContent.Parent = ScrollingFrame
    
    local tabButton = Instance.new("TextButton")
    tabButton.Name = name .. "_Btn"
    tabButton.Size = UDim2.new(0, 100, 0, 30)
    tabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    tabButton.Text = name
    tabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    tabButton.Font = Enum.Font.GothamSemibold
    tabButton.TextSize = 12
    tabButton.BorderSizePixel = 0
    tabButton.Parent = TabButtonHolder
    
    local UICorner_Btn = Instance.new("UICorner")
    UICorner_Btn.CornerRadius = UDim.new(0, 6)
    UICorner_Btn.Parent = tabButton
    
    tabButton.MouseButton1Click:Connect(function()
        -- Ẩn tất cả tab
        for _, tab in ipairs(Tabs) do
            tab.Visible = false
        end
        for _, btn in ipairs(TabButtons) do
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        -- Hiện tab được chọn
        tabContent.Visible = true
        tabButton.BackgroundColor3 = Color3.fromRGB(0, 200, 150)
        tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        CurrentTab = tabContent
    end)
    
    table.insert(Tabs, tabContent)
    table.insert(TabButtons, tabButton)
    
    -- Sắp xếp tab buttons
    local xOffset = 0
    for i, btn in ipairs(TabButtons) do
        btn.Position = UDim2.new(0, xOffset, 0, 0)
        xOffset = xOffset + 105
    end
    
    -- Tạo layout cho tab content
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Parent = tabContent
    
    return tabContent
end

function UI:CreateToggle(tab, name, default, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, 0, 0, 40)
    toggleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    toggleFrame.BorderSizePixel = 0
    toggleFrame.Parent = tab
    
    local UICorner_Toggle = Instance.new("UICorner")
    UICorner_Toggle.CornerRadius = UDim.new(0, 6)
    UICorner_Toggle.Parent = toggleFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 50, 0, 24)
    button.Position = UDim2.new(1, -60, 0.5, -12)
    button.BackgroundColor3 = default and Color3.fromRGB(0, 200, 150) or Color3.fromRGB(80, 80, 85)
    button.Text = default and "BẬT" or "TẮT"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 11
    button.BorderSizePixel = 0
    button.Parent = toggleFrame
    
    local UICorner_Btn = Instance.new("UICorner")
    UICorner_Btn.CornerRadius = UDim.new(0, 12)
    UICorner_Btn.Parent = button
    
    local toggled = default
    
    button.MouseButton1Click:Connect(function()
        toggled = not toggled
        button.BackgroundColor3 = toggled and Color3.fromRGB(0, 200, 150) or Color3.fromRGB(80, 80, 85)
        button.Text = toggled and "BẬT" or "TẮT"
        if callback then callback(toggled) end
    end)
    
    -- Trả về table để có thể set value từ code
    return {
        SetValue = function(val)
            toggled = val
            button.BackgroundColor3 = toggled and Color3.fromRGB(0, 200, 150) or Color3.fromRGB(80, 80, 85)
            button.Text = toggled and "BẬT" or "TẮT"
        end,
        GetValue = function() return toggled end
    }
end

function UI:CreateSlider(tab, name, min, max, default, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, 0, 0, 60)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    sliderFrame.BorderSizePixel = 0
    sliderFrame.Parent = tab
    
    local UICorner_Slider = Instance.new("UICorner")
    UICorner_Slider.CornerRadius = UDim.new(0, 6)
    UICorner_Slider.Parent = sliderFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. default
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = sliderFrame
    
    -- Slider background
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -40, 0, 6)
    sliderBg.Position = UDim2.new(0, 20, 0, 35)
    sliderBg.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = sliderFrame
    
    local UICorner_Bg = Instance.new("UICorner")
    UICorner_Bg.CornerRadius = UDim.new(0, 3)
    UICorner_Bg.Parent = sliderBg
    
    -- Slider fill
    local fill = Instance.new("Frame")
    local percent = (default - min) / (max - min)
    fill.Size = UDim2.new(percent, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 200, 150)
    fill.BorderSizePixel = 0
    fill.Parent = sliderBg
    
    local UICorner_Fill = Instance.new("UICorner")
    UICorner_Fill.CornerRadius = UDim.new(0, 3)
    UICorner_Fill.Parent = fill
    
    -- Slider button
    local sliderBtn = Instance.new("TextButton")
    sliderBtn.Size = UDim2.new(0, 18, 0, 18)
    sliderBtn.Position = UDim2.new(percent, -9, 0.5, -9)
    sliderBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderBtn.Text = ""
    sliderBtn.BorderSizePixel = 0
    sliderBtn.Parent = sliderBg
    
    local UICorner_SliderBtn = Instance.new("UICorner")
    UICorner_SliderBtn.CornerRadius = UDim.new(0, 9)
    UICorner_SliderBtn.Parent = sliderBtn
    
    -- Slider functionality
    local dragging = false
    local currentValue = default
    
    local function UpdateSlider(input)
        local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        currentValue = math.floor(min + (max - min) * pos)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        sliderBtn.Position = UDim2.new(pos, -9, 0.5, -9)
        label.Text = name .. ": " .. currentValue
    end
    
    sliderBtn.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if dragging then
                dragging = false
                if callback then callback(currentValue) end
            end
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            UpdateSlider(input)
        end
    end)
    
    sliderBtn.TouchTap:Connect(function()
        -- Mobile support
    end)
    
    return {
        SetValue = function(val)
            currentValue = val
            local pos = (val - min) / (max - min)
            fill.Size = UDim2.new(pos, 0, 1, 0)
            sliderBtn.Position = UDim2.new(pos, -9, 0.5, -9)
            label.Text = name .. ": " .. val
        end,
        GetValue = function() return currentValue end
    }
end

function UI:CreateLabel(tab, text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 25)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(150, 150, 155)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = tab
    
    return {
        SetText = function(newText) label.Text = newText end
    }
end

function UI:CreateSection(tab, title)
    local sectionFrame = Instance.new("Frame")
    sectionFrame.Size = UDim2.new(1, 0, 0, 30)
    sectionFrame.BackgroundTransparency = 1
    sectionFrame.BorderSizePixel = 0
    sectionFrame.Parent = tab
    
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 0.5, 0)
    line.BackgroundColor3 = Color3.fromRGB(0, 200, 150)
    line.BorderSizePixel = 0
    line.Parent = sectionFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 0, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    label.Text = "  " .. title .. "  "
    label.TextColor3 = Color3.fromRGB(0, 255, 200)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.AutomaticSize = Enum.AutomaticSize.X
    label.Parent = sectionFrame
    label.ZIndex = 2
    
    return sectionFrame
end

-- ============================================================
-- SECTION 5: TOGGLE KEY (Phím tắt UI)
-- ============================================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        MainWindow.Visible = not MainWindow.Visible
    end
end)

print("[DarkForge-X] Built-in UI initialized. Press RightCtrl to toggle.")

-- ============================================================
-- SECTION 6: GAME CONFIGURATION
-- ============================================================
local CONFIG = {
    Farm = {
        Enabled = false,
        Range = 150,
        AttackDelay = 0.3,
        MoveSpeed = 80,
    },
    Boss = {
        Enabled = false,
        Range = 300,
        UseSkill = true,
    },
    Collect = {
        Enabled = true,
        Range = 30,
    },
    Safety = {
        AntiAFK = true,
        AntiVoid = true,
        SafeMove = true,
    }
}

-- ============================================================
-- SECTION 7: GAME LOGIC (ĐƠN GIẢN HÓA, CHẮC CHẮN HOẠT ĐỘNG)
-- ============================================================
local NPCS = {}
local LastAttack = 0
local LastScan = 0

local function QuickScan()
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
                    table.insert(npcs, {Model = obj, Humanoid = hum, RootPart = hrp})
                end
            end
        end)
    end
    NPCS = npcs
end

local function GetNearestNPC(range)
    local char = LocalPlayer.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    
    local nearest = nil
    local minDist = range or 150
    
    for _, npc in ipairs(NPCS) do
        if npc.Humanoid.Health > 0 then
            local dist = (root.Position - npc.RootPart.Position).Magnitude
            if dist < minDist then
                minDist = dist
                nearest = npc
            end
        end
    end
    return nearest
end

local function AttackNPC(target)
    if not target then return end
    local char = LocalPlayer.Character
    if not char then return end
    
    -- Cách 1: Dùng tool
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        tool:Activate()
        task.wait(0.15)
        tool:Deactivate()
        return
    end
    
    -- Cách 2: Click chuột (mobile/pc)
    pcall(function()
        keypress(0x01)
        task.wait(0.1)
        keyrelease(0x01)
    end)
end

-- Main farm loop
task.spawn(function()
    while task.wait() do
        if not CONFIG.Farm.Enabled then continue end
        
        QuickScan()
        local target = GetNearestNPC(CONFIG.Farm.Range)
        if target then
            local char = LocalPlayer.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    -- Di chuyển đến target
                    local dist = (hrp.Position - target.RootPart.Position).Magnitude
                    if dist > 12 then
                        local humanoid = char:FindFirstChild("Humanoid")
                        if humanoid then
                            humanoid:MoveTo(target.RootPart.Position)
                        end
                    end
                    
                    -- Tấn công
                    if tick() - LastAttack >= CONFIG.Farm.AttackDelay then
                        AttackNPC(target)
                        LastAttack = tick()
                    end
                end
            end
        end
        
        task.wait(CONFIG.Farm.AttackDelay)
    end
end)

-- Anti AFK
task.spawn(function()
    while task.wait(30) do
        if CONFIG.Safety.AntiAFK and CONFIG.Farm.Enabled then
            pcall(function()
                keypress(0x20)
    
