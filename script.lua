--[[ 
    XENON HUB v1.4 - ULTIMATE FOCUS
    Owners: Himass & Z-Ω
    Update: Real Sailor Piece Script, Fixed Fly, Pro UI Layout
]]

local P = game.Players.LocalPlayer
local S = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local F, N, AL, SailorActivated = false, false, true, false

-- Khởi tạo thông báo
game.StarterGui:SetCore("SendNotification", {
    Title = "XENON HUB v1.4";
    Text = "Focus Mode: Active! Enjoy your farm.";
    Duration = 5;
})

-- UI Setup
local SG = Instance.new("ScreenGui", S)
local T = Instance.new("TextButton", SG)
T.Size, T.Position, T.Text = UDim2.new(0,80,0,35), UDim2.new(0,10,0,150), "XENON"
T.BackgroundColor3, T.TextColor3 = Color3.fromRGB(15,15,20), Color3.fromRGB(0,200,255)
T.Font, T.Draggable, T.Active = Enum.Font.GothamBold, true, true
Instance.new("UICorner", T)

local M = Instance.new("Frame", SG)
M.Size, M.Position, M.BackgroundColor3 = UDim2.new(0,350,0,280), UDim2.new(0.5,-175,0.5,-140), Color3.fromRGB(10,10,15)
M.Visible, M.Draggable, M.Active = true, true, true
Instance.new("UICorner", M)

local Side = Instance.new("Frame", M)
Side.Size, Side.BackgroundColor3 = UDim2.new(0,90,1,0), Color3.fromRGB(18,18,25)
Instance.new("UICorner", Side)

local Pages = Instance.new("Frame", M)
Pages.Size, Pages.Position = UDim2.new(0,250,1,0), UDim2.new(0,100,0,0)
Pages.BackgroundTransparency = 1

local function CreatePage(visible)
    local p = Instance.new("ScrollingFrame", Pages)
    p.Size, p.BackgroundTransparency, p.Visible = UDim2.new(1,0,1,0), 1, visible
    p.ScrollBarThickness = 2
    p.ScrollBarImageColor3 = Color3.fromRGB(0,200,255)
    
    local layout = Instance.new("UIListLayout", p)
    layout.Padding = UDim.new(0, 10) -- KHOẢNG CÁCH NÚT BẤM CHUẨN
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Instance.new("UIPadding", p).PaddingTop = UDim.new(0, 10)
    
    return p
end

local MainPg, GamePg, InfoPg = CreatePage(true), CreatePage(false), CreatePage(false)

local function TabBtn(name, page)
    local b = Instance.new("TextButton", Side)
    b.Size, b.Text = UDim2.new(0.85,0,0,35), name
    b.BackgroundColor3, b.TextColor3 = Color3.fromRGB(30,30,40), Color3.new(1,1,1)
    b.Font, b.TextSize = Enum.Font.GothamBold, 11
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        MainPg.Visible, GamePg.Visible, InfoPg.Visible = (page == MainPg), (page == GamePg), (page == InfoPg)
    end)
end

TabBtn("MAIN", MainPg)
TabBtn("GAMES", GamePg)
TabBtn("INFO", InfoPg)

local function FeatureBtn(name, parent)
    local b = Instance.new("TextButton", parent)
    b.Size, b.Text = UDim2.new(0.9,0,0,40), name
    b.BackgroundColor3, b.TextColor3 = Color3.fromRGB(35,35,45), Color3.new(1,1,1)
    b.Font, b.TextSize = Enum.Font.GothamBold, 12
    Instance.new("UICorner", b)
    return b
end

-- MAIN PAGE CONTENT
local SpeedInput = Instance.new("TextBox", MainPg)
SpeedInput.Size, SpeedInput.Text = UDim2.new(0.9,0,0,35), "50"
SpeedInput.PlaceholderText = "Fly Speed"
SpeedInput.BackgroundColor3, SpeedInput.TextColor3 = Color3.fromRGB(25,25,35), Color3.new(1,1,1)
Instance.new("UICorner", SpeedInput)

local FlyBtn = FeatureBtn("FLIGHT: OFF", MainPg)
local NocBtn = FeatureBtn("NOCLIP: OFF", MainPg)
local LeaveBtn = FeatureBtn("AUTO-LEAVE: ON", MainPg)

-- GAME PAGE CONTENT
local SailorBtn = FeatureBtn("ACTIVATE SAILOR PIECE", GamePg)
SailorBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)

-- --- HỆ THỐNG LOGIC ---

-- 1. Auto Leave Admin (Fix dứt điểm)
local function CheckAdmin()
    if not AL then return end
    for _, player in pairs(game.Players:GetPlayers()) do
        if player:GetRankInGroup(game.CreatorId) >= 200 or player:GetRoleInGroup(game.CreatorId) == "Admin" then
            P:Kick("\n[XENON HUB SAFETY]\nPhát hiện Admin: " .. player.Name)
        end
    end
end
game.Players.PlayerAdded:Connect(CheckAdmin)
task.spawn(function() while task.wait(3) do CheckAdmin() end end)

LeaveBtn.MouseButton1Click:Connect(function()
    AL = not AL
    LeaveBtn.Text = AL and "AUTO-LEAVE: ON" or "AUTO-LEAVE: OFF"
    LeaveBtn.TextColor3 = AL and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 100, 100)
end)

-- 2. Fly Điều Khiển Theo Camera
FlyBtn.MouseButton1Click:Connect(function()
    F = not F
    FlyBtn.Text = F and "FLIGHT: ON" or "FLIGHT: OFF"
    FlyBtn.BackgroundColor3 = F and Color3.fromRGB(0,120,200) or Color3.fromRGB(35,35,45)
    
    local hrp = P.Character:FindFirstChild("HumanoidRootPart")
    if not hrp or not F then return end
    
    local bv = Instance.new("BodyVelocity", hrp)
    bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    
    task.spawn(function()
        while F and task.wait() do
            local cam = workspace.CurrentCamera
            if P.Character.Humanoid.MoveDirection.Magnitude > 0 then
                -- Bay theo đúng hướng camera nhìn (Lên/Xuống/Trái/Phải)
                bv.Velocity = cam.CFrame.LookVector * (tonumber(SpeedInput.Text) or 50)
            else
                bv.Velocity = Vector3.new(0, 0, 0)
            end
        end
        bv:Destroy()
    end)
end)

-- 3. Sailor Piece Script (Khi nhấn sẽ hiện ra tính năng cày cuốc)
SailorBtn.MouseButton1Click:Connect(function()
    if SailorActivated then return end
    SailorActivated = true
    SailorBtn.Text = "SAILOR MODE ENABLED!"
    SailorBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    
    -- Xóa các nút Main cũ để nhường chỗ cho Farm
    FlyBtn:Destroy()
    NocBtn:Destroy()
    SpeedInput:Destroy()
    
    -- Thêm các nút Farm xịn xò của Sailor Piece
    local FarmBtn = FeatureBtn("AUTO FARM LEVEL: OFF", MainPg)
    local AuraBtn = FeatureBtn("KILL AURA: OFF", MainPg)
    local StatBtn = FeatureBtn("AUTO STATS: OFF", MainPg)
    local JumpBtn = FeatureBtn("INFINITE JUMP: ON", MainPg)
    
    -- Logic Kill Aura (Dành cho Sailor Piece)
    AuraBtn.MouseButton1Click:Connect(function()
        _G.KillAura = not _G.KillAura
        AuraBtn.Text = _G.KillAura and "KILL AURA: ON" or "KILL AURA: OFF"
        task.spawn(function()
            while _G.KillAura do
                pcall(function()
                    for _, v in pairs(workspace.Enemies:GetChildren()) do
                        if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                            if (P.Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude < 25 then
                                -- Tự động gây sát thương (Ví dụ bằng remote hoặc damage trực tiếp)
                                v.Humanoid.Health = 0 
                            end
                        end
                    end
                end)
                task.wait(0.5)
            end
        end)
    end)
    
    -- Logic Infinite Jump (Geppo)
    UIS.JumpRequest:Connect(function()
        if SailorActivated then P.Character.Humanoid:ChangeState("Jumping") end
    end)
end)

-- 4. Noclip
NocBtn.MouseButton1Click:Connect(function()
    N = not N
    NocBtn.Text = N and "NOCLIP: ON" or "NOCLIP: OFF"
end)

RunService.Stepped:Connect(function()
    if N and P.Character then
        for _, part in pairs(P.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

T.MouseButton1Click:Connect(function() M.Visible = not M.Visible end)
