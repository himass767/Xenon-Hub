--[[ 
    XENON HUB v1.2 - UI OVERHAUL & BUG FIXES
    Owners: Himass & Z-Ω
]]

local P = game.Players.LocalPlayer
local S = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local F, N, AL, SailorMode = false, false, true, false

-- Notification
game.StarterGui:SetCore("SendNotification", {
    Title = "XENON HUB v1.2";
    Text = "UI Updated & Bugs Fixed!";
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
    p.ScrollBarImageColor3 = Color3.fromRGB(0,200,255)
    
    -- TỰ ĐỘNG CĂN ĐỀU CÁC NÚT BẤM (Giống Buffalo Hub)
    local layout = Instance.new("UIListLayout", p)
    layout.Padding = UDim.new(0, 8) -- Khoảng cách giữa các nút
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    -- Padding trên cùng để không bị dính viền
    local pad = Instance.new("UIPadding", p)
    pad.PaddingTop = UDim.new(0, 10)
    
    return p
end

local MainPg, GamePg, InfoPg = CreatePage(true), CreatePage(false), CreatePage(false)

local function Switch(page)
    MainPg.Visible = (page == MainPg)
    GamePg.Visible = (page == GamePg)
    InfoPg.Visible = (page == InfoPg)
end

-- Sidebar Buttons
local sideLayout = Instance.new("UIListLayout", Side)
sideLayout.Padding = UDim.new(0, 5)
sideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
local sidePad = Instance.new("UIPadding", Side)
sidePad.PaddingTop = UDim.new(0, 15)

local function TabBtn(name, page)
    local b = Instance.new("TextButton", Side)
    b.Size, b.Text = UDim2.new(0.85,0,0,35), name
    b.BackgroundColor3, b.TextColor3 = Color3.fromRGB(30,30,40), Color3.new(1,1,1)
    b.Font, b.TextSize = Enum.Font.GothamBold, 11
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() Switch(page) end)
end

TabBtn("MAIN", MainPg)
TabBtn("GAMES", GamePg)
TabBtn("INFO", InfoPg)

-- INFO PAGE
local iTxt = Instance.new("TextLabel", InfoPg)
iTxt.Size, iTxt.Text = UDim2.new(1,0,1,0), "XENON HUB v1.2\n\nLEADERS:\nHIMASS & Z-Ω\n\nStatus: Fixed Fly & UI"
iTxt.TextColor3, iTxt.BackgroundTransparency, iTxt.Font = Color3.fromRGB(0,200,255), 1, "GothamBold"
iTxt.TextSize = 14

-- FEATURE BUTTON TEMPLATE
local function CreateFeature(name, parent)
    local b = Instance.new("TextButton", parent)
    b.Size, b.Text = UDim2.new(0.9,0,0,40), name
    b.BackgroundColor3, b.TextColor3 = Color3.fromRGB(35,35,45), Color3.new(1,1,1)
    b.Font, b.TextSize = Enum.Font.GothamBold, 12
    Instance.new("UICorner", b)
    return b
end

-- MAIN PAGE CONTENT
local SpeedInput = Instance.new("TextBox", MainPg)
SpeedInput.Size = UDim2.new(0.9,0,0,35)
SpeedInput.Text, SpeedInput.PlaceholderText = "50", "Fly Speed (Nhập số)"
SpeedInput.BackgroundColor3, SpeedInput.TextColor3 = Color3.fromRGB(25,25,35), Color3.new(1,1,1)
Instance.new("UICorner", SpeedInput)

local FlyBtn = CreateFeature("FLIGHT: OFF", MainPg)
local NocBtn = CreateFeature("NOCLIP: OFF", MainPg)
local LeaveBtn = CreateFeature("AUTO-LEAVE: ON", MainPg)
LeaveBtn.TextColor3 = Color3.fromRGB(0, 255, 150)

-- GAME PAGE CONTENT
local SailorBtn = CreateFeature("SAILOR PIECE: OFF", GamePg)

-- --- LOGIC HỆ THỐNG ---

-- 1. Auto Leave Admin (Đã hồi sinh)
local function CheckAdmins()
    if not AL then return end
    for _, v in pairs(game.Players:GetPlayers()) do
        if v:GetRoleInGroup(game.CreatorId) == "Admin" or v:GetRankInGroup(game.CreatorId) >= 200 then
            P:Kick("\n[XENON HUB]\nĐã tự động thoát vì có Admin: " .. v.Name)
        end
    end
end
game.Players.PlayerAdded:Connect(CheckAdmins)
task.spawn(function() while task.wait(3) do CheckAdmins() end end)

LeaveBtn.MouseButton1Click:Connect(function()
    AL = not AL
    LeaveBtn.Text = AL and "AUTO-LEAVE: ON" or "AUTO-LEAVE: OFF"
    LeaveBtn.TextColor3 = AL and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 100, 100)
end)

-- 2. Fly (Đã fix điều khiển bằng Camera)
FlyBtn.MouseButton1Click:Connect(function()
    F = not F
    FlyBtn.Text = F and "FLIGHT: ON" or "FLIGHT: OFF"
    FlyBtn.BackgroundColor3 = F and Color3.fromRGB(0,120,200) or Color3.fromRGB(35,35,45)
    
    local c = P.Character
    local hrp, hum = c:FindFirstChild("HumanoidRootPart"), c:FindFirstChild("Humanoid")
    if not hrp or not F then return end
    
    local bv = Instance.new("BodyVelocity", hrp)
    local bg = Instance.new("BodyGyro", hrp)
    bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    bg.P = 10000
    
    task.spawn(function()
        while F and task.wait() do
            local cam = workspace.CurrentCamera
            bg.CFrame = cam.CFrame
            
            local moveDir = Vector3.new(0,0,0)
            if hum.MoveDirection.Magnitude > 0 then
                -- Bay theo hướng camera nhìn
                moveDir = cam.CFrame.LookVector * (tonumber(SpeedInput.Text) or 50)
            end
            bv.Velocity = moveDir
        end
        if bv then bv:Destroy() end
        if bg then bg:Destroy() end
    end)
end)

-- 3. Noclip
NocBtn.MouseButton1Click:Connect(function()
    N = not N
    NocBtn.Text = N and "NOCLIP: ON" or "NOCLIP: OFF"
    NocBtn.BackgroundColor3 = N and Color3.fromRGB(150,0,200) or Color3.fromRGB(35,35,45)
end)

RunService.Stepped:Connect(function()
    if N and P.Character then
        for _, part in pairs(P.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

-- 4. Sailor Piece Logic
SailorBtn.MouseButton1Click:Connect(function()
    SailorMode = not SailorMode
    SailorBtn.Text = SailorMode and "SAILOR PIECE: ON" or "SAILOR PIECE: OFF"
    SailorBtn.BackgroundColor3 = SailorMode and Color3.fromRGB(0,200,100) or Color3.fromRGB(35,35,45)
    
    if SailorMode then
        game.StarterGui:SetCore("SendNotification", {Title = "XENON"; Text = "Sailor Mode ON (Infinite Jump enabled)"; Duration = 3})
    end
end)

UIS.JumpRequest:Connect(function()
    if SailorMode and P.Character and P.Character:FindFirstChildOfClass("Humanoid") then
        P.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Đóng/Mở Menu
T.MouseButton1Click:Connect(function() M.Visible = not M.Visible end)
