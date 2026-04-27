--[[ 
    XENON HUB v1.3 - SAILOR BEAST MODE
    Owners: Himass & Z-Ω
    Update: Auto-Switch GUI for Sailor Piece, Auto Farm, Kill Aura
]]

local P = game.Players.LocalPlayer
local S = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local F, N, AL, SailorActive = false, false, true, false
local _G = _G or {}

-- Notification
game.StarterGui:SetCore("SendNotification", {
    Title = "XENON HUB v1.3";
    Text = "Sailor Piece Mode Ready!";
    Duration = 5;
})

-- UI Setup
local SG = Instance.new("ScreenGui", S)
local T = Instance.new("TextButton", SG)
T.Size, T.Position, T.Text = UDim2.new(0,80,0,35), UDim2.new(0,10,0,150), "XENON"
T.Draggable, T.Active, T.BackgroundColor3, T.TextColor3 = true, true, Color3.fromRGB(15,15,20), Color3.fromRGB(0,200,255)
T.Font = Enum.Font.GothamBold
Instance.new("UICorner", T)

local M = Instance.new("Frame", SG)
M.Size, M.Position, M.BackgroundColor3 = UDim2.new(0,350,0,280), UDim2.new(0.5,-175,0.5,-140), Color3.fromRGB(15,15,20)
M.Visible, M.Draggable, M.Active = true, true, true
Instance.new("UICorner", M)
Instance.new("UICorner", M)

local Side = Instance.new("Frame", M)
Side.Size, Side.BackgroundColor3 = UDim2.new(0,90,1,0), Color3.fromRGB(20,20,25)
Instance.new("UICorner", Side)

local Pages = Instance.new("Frame", M)
Pages.Size, Pages.Position = UDim2.new(0,250,1,0), UDim2.new(0,100,0,0)
Pages.BackgroundTransparency = 1

local function CreatePage(visible)
    local p = Instance.new("ScrollingFrame", Pages)
    p.Size, p.BackgroundTransparency, p.Visible = UDim2.new(1,0,1,0), 1, visible
    p.ScrollBarThickness = 2
    local layout = Instance.new("UIListLayout", p)
    layout.Padding = UDim.new(0, 8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Instance.new("UIPadding", p).PaddingTop = UDim.new(0, 10)
    return p
end

local MainPg, GamePg, InfoPg = CreatePage(true), CreatePage(false), CreatePage(false)

local function TabBtn(name, page)
    local b = Instance.new("TextButton", Side)
    b.Size = UDim2.new(0.85,0,0,35)
    b.Text = name
    b.BackgroundColor3, b.TextColor3 = Color3.fromRGB(30,30,40), Color3.new(1,1,1)
    b.Font, b.TextSize = Enum.Font.GothamBold, 11
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        MainPg.Visible, GamePg.Visible, InfoPg.Visible = (page == MainPg), (page == GamePg), (page == InfoPg)
    end)
    return b
end

local MainTab = TabBtn("MAIN", MainPg)
TabBtn("GAMES", GamePg)
TabBtn("INFO", InfoPg)

local function CreateBtn(name, parent)
    local b = Instance.new("TextButton", parent)
    b.Size, b.Text = UDim2.new(0.9,0,0,40), name
    b.BackgroundColor3, b.TextColor3 = Color3.fromRGB(35,35,45), Color3.new(1,1,1)
    b.Font, b.TextSize = Enum.Font.GothamBold, 12
    Instance.new("UICorner", b)
    return b
end

-- MAIN PAGE (Mặc định)
local SpeedInput = Instance.new("TextBox", MainPg)
SpeedInput.Size, SpeedInput.Text = UDim2.new(0.9,0,0,35), "50"
SpeedInput.PlaceholderText = "Speed"
SpeedInput.BackgroundColor3, SpeedInput.TextColor3 = Color3.fromRGB(25,25,35), Color3.new(1,1,1)
Instance.new("UICorner", SpeedInput)

local FlyBtn = CreateBtn("FLIGHT: OFF", MainPg)
local NocBtn = CreateBtn("NOCLIP: OFF", MainPg)
local LeaveBtn = CreateBtn("AUTO-LEAVE: ON", MainPg)

-- GAME PAGE
local SailorActBtn = CreateBtn("ACTIVATE SAILOR PIECE", GamePg)
SailorActBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)

-- --- LOGIC CHUYỂN ĐỔI SCRIPT (SAILOR PIECE) ---
SailorActBtn.MouseButton1Click:Connect(function()
    SailorActive = true
    SailorActBtn.Text = "SAILOR MODE ACTIVE!"
    SailorActBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
    
    -- Xóa các nút cũ ở phần Main
    FlyBtn:Destroy()
    NocBtn:Destroy()
    SpeedInput:Destroy()
    
    -- Thêm các tính năng Farm thực thụ của Sailor Piece
    local FarmBtn = CreateBtn("AUTO FARM LEVEL: OFF", MainPg)
    local KillBtn = CreateBtn("KILL AURA: OFF", MainPg)
    local StatBtn = CreateBtn("AUTO STATS: OFF", MainPg)
    local JumpBtn = CreateBtn("INFINITE JUMP: ON", MainPg)
    
    MainTab.Text = "SAILOR HUB"
    game.StarterGui:SetCore("SendNotification", {Title = "XENON"; Text = "Main Tab updated to Sailor Piece features!"; Duration = 3})

    -- 1. Auto Farm Level (Logic giả lập - cần liên kết với Quest của game)
    FarmBtn.MouseButton1Click:Connect(function()
        _G.AutoFarm = not _G.AutoFarm
        FarmBtn.Text = _G.AutoFarm and "AUTO FARM: ON" or "AUTO FARM: OFF"
        FarmBtn.BackgroundColor3 = _G.AutoFarm and Color3.fromRGB(0,200,100) or Color3.fromRGB(35,35,45)
    end)

    -- 2. Kill Aura (Tự đánh quái xung quanh)
    KillBtn.MouseButton1Click:Connect(function()
        _G.KillAura = not _G.KillAura
        KillBtn.Text = _G.KillAura and "KILL AURA: ON" or "KILL AURA: OFF"
        KillBtn.BackgroundColor3 = _G.KillAura and Color3.fromRGB(255,100,0) or Color3.fromRGB(35,35,45)
        task.spawn(function()
            while _G.KillAura do
                for _, v in pairs(workspace.Enemies:GetChildren()) do -- Tên folder quái tùy map
                    if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                        if (P.Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude < 20 then
                            v.Humanoid:TakeDamage(100) -- Hoặc dùng RemoteEvent đánh quái
                        end
                    end
                end
                task.wait(0.5)
            end
        end)
    end)
end)

-- --- LOGIC GỐC (FLY & ADMIN) ---
FlyBtn.MouseButton1Click:Connect(function()
    F = not F
    FlyBtn.Text = F and "FLIGHT: ON" or "FLIGHT: OFF"
    local c = P.Character
    local hrp, hum = c:FindFirstChild("HumanoidRootPart"), c:FindFirstChild("Humanoid")
    if not hrp or not F then return end
    local bv = Instance.new("BodyVelocity", hrp)
    bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    task.spawn(function()
        while F and task.wait() do
            bv.Velocity = workspace.CurrentCamera.CFrame.LookVector * (tonumber(SpeedInput.Text) or 50)
            if hum.MoveDirection.Magnitude == 0 then bv.Velocity = Vector3.new(0,0,0) end
        end
        bv:Destroy()
    end)
end)

local function CheckAdmins()
    if not AL then return end
    for _, v in pairs(game.Players:GetPlayers()) do
        if v:GetRoleInGroup(game.CreatorId) == "Admin" or v:GetRankInGroup(game.CreatorId) >= 200 then
            P:Kick("\n[XENON HUB]\nPhát hiện Admin: " .. v.Name)
        end
    end
end
task.spawn(function() while task.wait(3) do CheckAdmins() end end)

T.MouseButton1Click:Connect(function() M.Visible = not M.Visible end)
