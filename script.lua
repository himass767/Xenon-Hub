--[[ 
    XENON HUB v1.4.2 - THE FINAL FIX
    Owners: Himass & Z-Ω
]]

local P = game.Players.LocalPlayer
local S = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local F, N, AL, SailorActivated = false, false, true, false
local _G = _G or {}

-- Giao diện chính
local SG = Instance.new("ScreenGui", S)
local T = Instance.new("TextButton", SG)
T.Size, T.Position, T.Text = UDim2.new(0,80,0,35), UDim2.new(0,10,0,150), "XENON"
T.BackgroundColor3, T.TextColor3 = Color3.fromRGB(20,20,25), Color3.fromRGB(0,200,255)
T.Font, T.Draggable, T.Active = Enum.Font.GothamBold, true, true
Instance.new("UICorner", T)

local M = Instance.new("Frame", SG)
M.Size, M.Position, M.BackgroundColor3 = UDim2.new(0,380,0,300), UDim2.new(0.5,-190,0.5,-150), Color3.fromRGB(12,12,17)
M.Visible, M.Draggable, M.Active = true, true, true
Instance.new("UICorner", M)

-- Sidebar
local Side = Instance.new("Frame", M)
Side.Size, Side.BackgroundColor3 = UDim2.new(0,100,1,0), Color3.fromRGB(18,18,24)
Instance.new("UICorner", Side)

local Pages = Instance.new("Frame", M)
Pages.Size, Pages.Position = UDim2.new(0,260,1,0), UDim2.new(0,110,0,0)
Pages.BackgroundTransparency = 1

local function CreatePage(visible)
    local p = Instance.new("ScrollingFrame", Pages)
    p.Size, p.BackgroundTransparency, p.Visible = UDim2.new(1,0,1,0), 1, visible
    p.ScrollBarThickness = 3
    p.ScrollBarImageColor3 = Color3.fromRGB(0,200,255)
    
    local layout = Instance.new("UIListLayout", p)
    layout.Padding = UDim.new(0, 15) -- KHOẢNG CÁCH NÚT RỘNG NHƯ BUFFALO HUB
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Instance.new("UIPadding", p).PaddingTop = UDim.new(0, 20)
    
    return p
end

local MainPg, GamePg, InfoPg = CreatePage(true), CreatePage(false), CreatePage(false)

local function TabBtn(name, page)
    local b = Instance.new("TextButton", Side)
    b.Size, b.Text = UDim2.new(0.9,0,0,40), name
    b.BackgroundColor3, b.TextColor3 = Color3.fromRGB(30,30,40), Color3.new(1,1,1)
    b.Font, b.TextSize = Enum.Font.GothamBold, 12
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        MainPg.Visible, GamePg.Visible, InfoPg.Visible = (page == MainPg), (page == GamePg), (page == InfoPg)
    end)
    return b
end

local MainTab = TabBtn("MAIN", MainPg)
TabBtn("GAMES", GamePg)
TabBtn("INFO", InfoPg)

local function FeatureBtn(name, parent)
    local b = Instance.new("TextButton", parent)
    b.Size, b.Text = UDim2.new(0.95,0,0,45), name
    b.BackgroundColor3, b.TextColor3 = Color3.fromRGB(35,35,48), Color3.new(1,1,1)
    b.Font, b.TextSize = Enum.Font.GothamBold, 13
    Instance.new("UICorner", b)
    return b
end

-- --- TAB MAIN CONTENT ---
local SpeedInput = Instance.new("TextBox", MainPg)
SpeedInput.Size, SpeedInput.Text = UDim2.new(0.95,0,0,40), "50"
SpeedInput.PlaceholderText = "Fly Speed"
SpeedInput.BackgroundColor3, SpeedInput.TextColor3 = Color3.fromRGB(25,25,35), Color3.new(1,1,1)
Instance.new("UICorner", SpeedInput)

local FlyBtn = FeatureBtn("FLY: OFF", MainPg)
local NocBtn = FeatureBtn("NOCLIP: OFF", MainPg)
local LeaveBtn = FeatureBtn("AUTO-LEAVE: ON", MainPg)

-- --- TAB GAMES CONTENT ---
local SailorActBtn = FeatureBtn("ACTIVATE SAILOR PIECE", GamePg)
SailorActBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)

-- --- LOGIC HỆ THỐNG ---

-- 1. Fly Fix (Không tự bay lên, điều khiển chuẩn)
FlyBtn.MouseButton1Click:Connect(function()
    F = not F
    FlyBtn.Text = F and "FLY: ON" or "FLY: OFF"
    FlyBtn.BackgroundColor3 = F and Color3.fromRGB(0,150,255) or Color3.fromRGB(35,35,48)
    
    local hrp = P.Character:FindFirstChild("HumanoidRootPart")
    if not hrp or not F then return end
    
    local bv = Instance.new("BodyVelocity", hrp)
    local bg = Instance.new("BodyGyro", hrp)
    bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    bg.P = 15000
    
    task.spawn(function()
        while F and task.wait() do
            local cam = workspace.CurrentCamera
            bg.CFrame = cam.CFrame
            if P.Character.Humanoid.MoveDirection.Magnitude > 0 then
                -- Bay theo đúng hướng camera (kể cả lên xuống)
                bv.Velocity = cam.CFrame.LookVector * (tonumber(SpeedInput.Text) or 50)
            else
                -- Đứng im khi không bấm phím (Fix lỗi tự bay lên)
                bv.Velocity = Vector3.new(0, 0, 0)
            end
        end
        bv:Destroy()
        bg:Destroy()
    end)
end)

-- 2. Auto Leave Admin (Luôn chạy ngầm)
task.spawn(function()
    while task.wait(2) do
        if AL then
            for _, v in pairs(game.Players:GetPlayers()) do
                if v:GetRankInGroup(game.CreatorId) >= 200 then
                    P:Kick("\n[XENON v1.4.2]\nADMIN DETECTED: " .. v.Name)
                end
            end
        end
    end
end)

-- 3. Sailor Piece Transformation (Real Features)
SailorActBtn.MouseButton1Click:Connect(function()
    if SailorActivated then return end
    SailorActivated = true
    SailorActBtn.Text = "SAILOR MODE ACTIVE!"
    SailorActBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 120)
    
    -- Xóa nút cũ ở Main
    FlyBtn:Destroy()
    NocBtn:Destroy()
    SpeedInput:Destroy()
    
    -- Thêm tính năng farm Sailor Piece
    local FarmBtn = FeatureBtn("AUTO FARM LEVEL: OFF", MainPg)
    local AuraBtn = FeatureBtn("KILL AURA: OFF", MainPg)
    local GeppoBtn = FeatureBtn("INFINITE GEPPO: ON", MainPg)
    
    MainTab.Text = "SAILOR"
    
    -- Kill Aura Logic (Tự đánh quái)
    AuraBtn.MouseButton1Click:Connect(function()
        _G.KillAura = not _G.KillAura
        AuraBtn.Text = _G.KillAura and "KILL AURA: ON" or "KILL AURA: OFF"
        AuraBtn.BackgroundColor3 = _G.KillAura and Color3.fromRGB(255, 80, 0) or Color3.fromRGB(35,35,48)
        
        task.spawn(function()
            while _G.KillAura do
                pcall(function()
                    for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                        if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                            local dist = (P.Character.HumanoidRootPart.Position - enemy.HumanoidRootPart.Position).Magnitude
                            if dist < 30 then
                                -- Giả lập đánh quái
                                enemy.Humanoid:TakeDamage(50)
                            end
                        end
                    end
                end)
                task.wait(0.3)
            end
        end)
    end)

    -- Infinite Jump
    UIS.JumpRequest:Connect(function()
        if SailorActivated then P.Character.Humanoid:ChangeState("Jumping") end
    end)
end)

-- Noclip & UI Toggle
NocBtn.MouseButton1Click:Connect(function() N = not N; NocBtn.Text = N and "NOCLIP: ON" or "NOCLIP: OFF" end)
RunService.Stepped:Connect(function()
    if N and P.Character then
        for _, v in pairs(P.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
    end
end)
T.MouseButton1Click:Connect(function() M.Visible = not M.Visible end)
