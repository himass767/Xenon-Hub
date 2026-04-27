--[[ 
    XENON HUB v1.4 - FULL OPTION
    Owners: Himass & Z-Ω
    Features: Fly, Noclip, Admin Auto-Leave, Tab System
]]

local P = game.Players.LocalPlayer
local S = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local F, N, AL = false, false, true -- AL is Auto-Leave (On by default)

-- UI Setup
local SG = Instance.new("ScreenGui", S)
local T = Instance.new("TextButton", SG)
T.Size, T.Position, T.Text = UDim2.new(0,80,0,35), UDim2.new(0,10,0,150), "XENON"
T.Draggable, T.Active, T.BackgroundColor3, T.TextColor3 = true, true, Color3.fromRGB(15,15,20), Color3.fromRGB(0,200,255)
T.Font = Enum.Font.GothamBold
Instance.new("UICorner", T)

-- Main Frame
local M = Instance.new("Frame", SG)
M.Size, M.Position, M.BackgroundColor3 = UDim2.new(0,350,0,280), UDim2.new(0.5,-175,0.5,-140), Color3.fromRGB(10,10,15)
M.Visible, M.Draggable, M.Active = true, true, true
Instance.new("UICorner", M)

-- Sidebar
local Side = Instance.new("Frame", M)
Side.Size, Side.BackgroundColor3 = UDim2.new(0,80,1,0), Color3.fromRGB(18,18,25)
Instance.new("UICorner", Side)

-- Pages Container
local Pages = Instance.new("Frame", M)
Pages.Size, Pages.Position = UDim2.new(0,260,1,0), UDim2.new(0,90,0,0)
Pages.BackgroundTransparency = 1

local function CreatePage(visible)
    local p = Instance.new("ScrollingFrame", Pages)
    p.Size, p.BackgroundTransparency, p.Visible = UDim2.new(1,0,1,0), 1, visible
    p.ScrollBarThickness = 0
    return p
end

local MainPg = CreatePage(true)
local GamePg = CreatePage(false)
local InfoPg = CreatePage(false)

-- Tab Switch Logic
local function Switch(page)
    MainPg.Visible = (page == MainPg)
    GamePg.Visible = (page == GamePg)
    InfoPg.Visible = (page == InfoPg)
end

local function TabBtn(name, pos, page)
    local b = Instance.new("TextButton", Side)
    b.Size, b.Position, b.Text = UDim2.new(0.9,0,0,35), pos, name
    b.BackgroundColor3, b.TextColor3 = Color3.fromRGB(30,30,40), Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 11
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() Switch(page) end)
end

TabBtn("MAIN", UDim2.new(0.05,0,0.15,0), MainPg)
TabBtn("GAMES", UDim2.new(0.05,0,0.3,0), GamePg)
TabBtn("INFO", UDim2.new(0.05,0,0.45,0), InfoPg)

-- INFO PAGE (Himass & Z-Ω)
local iTxt = Instance.new("TextLabel", InfoPg)
iTxt.Size, iTxt.Text = UDim2.new(1,0,1,0), "XENON PROJECT\n\nLEADERS:\n\nHIMASS\n&\nZ-Ω"
iTxt.TextColor3, iTxt.BackgroundTransparency, iTxt.Font = Color3.fromRGB(0,200,255), 1, "GothamBold"
iTxt.TextSize = 16

-- MAIN PAGE CONTENT
local SpeedInput = Instance.new("TextBox", MainPg)
SpeedInput.Size, SpeedInput.Position = UDim2.new(0.9,0,0,35), UDim2.new(0.05,0,0.05,0)
SpeedInput.Text, SpeedInput.PlaceholderText = "50", "Fly Speed"
SpeedInput.BackgroundColor3, SpeedInput.TextColor3 = Color3.fromRGB(25,25,35), Color3.new(1,1,1)
Instance.new("UICorner", SpeedInput)

local function FeatureBtn(name, pos, parent)
    local b = Instance.new("TextButton", parent)
    b.Size, b.Position, b.Text = UDim2.new(0.9,0,0,40), pos, name
    b.BackgroundColor3, b.TextColor3 = Color3.fromRGB(35,35,45), Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    Instance.new("UICorner", b)
    return b
end

local FlyBtn = FeatureBtn("FLIGHT: OFF", UDim2.new(0.05,0,0.22,0), MainPg)
local NocBtn = FeatureBtn("NOCLIP: OFF", UDim2.new(0.05,0,0.4,0), MainPg)
local LeaveBtn = FeatureBtn("AUTO-LEAVE: ON", UDim2.new(0.05,0,0.58,0), MainPg)
LeaveBtn.TextColor3 = Color3.fromRGB(0, 255, 150)

-- GAME PAGE (Placeholder)
local gTxt = Instance.new("TextLabel", GamePg)
gTxt.Size, gTxt.Text = UDim2.new(1,0,0,100), "Select a game to load scripts..."
gTxt.TextColor3, gTxt.BackgroundTransparency = Color3.fromRGB(100,100,100), 1

-- --- SYSTEMS LOGIC ---

-- 1. Auto-Leave (Safety)
local function CheckAdmins()
    if not AL then return end
    for _, v in pairs(game.Players:GetPlayers()) do
        if v:GetRoleInGroup(game.CreatorId) == "Admin" or v:GetRankInGroup(game.CreatorId) >= 200 then
            P:Kick("\n[XENON HUB]\nSafety Kick: Admin '" .. v.Name .. "' detected.")
        end
    end
end
game.Players.PlayerAdded:Connect(CheckAdmins)
task.spawn(function() while task.wait(5) do CheckAdmins() end end) -- Check every 5s

LeaveBtn.MouseButton1Click:Connect(function()
    AL = not AL
    LeaveBtn.Text = AL and "AUTO-LEAVE: ON" or "AUTO-LEAVE: OFF"
    LeaveBtn.TextColor3 = AL and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 100, 100)
end)

-- 2. Flight
FlyBtn.MouseButton1Click:Connect(function()
    F = not F
    FlyBtn.Text = F and "FLIGHT: ON" or "FLIGHT: OFF"
    FlyBtn.BackgroundColor3 = F and Color3.fromRGB(0,120,200) or Color3.fromRGB(35,35,45)
    local c = P.Character
    local hrp, hum = c:FindFirstChild("HumanoidRootPart"), c:FindFirstChild("Humanoid")
    if not hrp or not F then return end
    local bv, bg = Instance.new("BodyVelocity", hrp), Instance.new("BodyGyro", hrp)
    bv.MaxForce, bg.MaxTorque = Vector3.new(1e6,1e6,1e6), Vector3.new(1e6,1e6,1e6)
    task.spawn(function()
        while F and task.wait() do
            bg.CFrame = workspace.CurrentCamera.CFrame
            bv.Velocity = hum.MoveDirection.Magnitude > 0 and workspace.CurrentCamera.CFrame.LookVector * (tonumber(SpeedInput.Text) or 50) or Vector3.new(0,0.05,0)
        end
        if bv then bv:Destroy() end if bg then bg:Destroy() end
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

T.MouseButton1Click:Connect(function() M.Visible = not M.Visible end)
