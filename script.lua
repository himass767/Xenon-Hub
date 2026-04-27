--[[ 
    XENON HUB v1.1 - SAILOR UPDATE
    Owners: Himass & Z-Ω
]]

local P = game.Players.LocalPlayer
local S = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local F, N, AL = false, false, true

-- Thông báo cập nhật v1.1
game.StarterGui:SetCore("SendNotification", {
    Title = "XENON HUB v1.1";
    Text = "Sailor Piece features added!";
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
M.Size, M.Position, M.BackgroundColor3 = UDim2.new(0,350,0,280), UDim2.new(0.5,-175,0.5,-140), Color3.fromRGB(10,10,15)
M.Visible, M.Draggable, M.Active = true, true, true
Instance.new("UICorner", M)

local Side = Instance.new("Frame", M)
Side.Size, Side.BackgroundColor3 = UDim2.new(0,80,1,0), Color3.fromRGB(18,18,25)
Instance.new("UICorner", Side)

local Pages = Instance.new("Frame", M)
Pages.Size, Pages.Position = UDim2.new(0,260,1,0), UDim2.new(0,90,0,0)
Pages.BackgroundTransparency = 1

local function CreatePage(visible)
    local p = Instance.new("ScrollingFrame", Pages)
    p.Size, p.BackgroundTransparency, p.Visible = UDim2.new(1,0,1,0), 1, visible
    p.ScrollBarThickness = 0
    return p
end

local MainPg, GamePg, InfoPg = CreatePage(true), CreatePage(false), CreatePage(false)

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

-- INFO PAGE
local iTxt = Instance.new("TextLabel", InfoPg)
iTxt.Size, iTxt.Text = UDim2.new(1,0,1,0), "XENON HUB v1.1\n\nLEADERS:\nHIMASS & Z-Ω\n\nLatest: Sailor Piece Support"
iTxt.TextColor3, iTxt.BackgroundTransparency, iTxt.Font = Color3.fromRGB(0,200,255), 1, "GothamBold"
iTxt.TextSize = 14

-- MAIN PAGE
local SpeedInput = Instance.new("TextBox", MainPg)
SpeedInput.Size, SpeedInput.Position = UDim2.new(0.9,0,0,35), UDim2.new(0.05,0,0.05,0)
SpeedInput.Text, SpeedInput.PlaceholderText = "50", "Speed/Fly Value"
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

-- GAME PAGE (SAILOR PIECE)
local SailorBtn = FeatureBtn("ACTIVATE SAILOR PIECE", UDim2.new(0.05,0,0.05,0), GamePg)
SailorBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)

SailorBtn.MouseButton1Click:Connect(function()
    game.StarterGui:SetCore("SendNotification", {Title = "XENON"; Text = "Sailor Piece Mode Activated!"; Duration = 3})
    -- Auto Clicker
    _G.AutoClick = true
    task.spawn(function()
        while _G.AutoClick do
            local virtualUser = game:GetService("VirtualUser")
            virtualUser:CaptureController()
            virtualUser:Button1Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(0.1)
        end
    end)
    -- Infinite Geppo (Jump)
    game:GetService("UserInputService").JumpRequest:Connect(function()
        P.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end)
end)

-- LOGIC (Fly & Noclip như cũ nhưng tối ưu)
FlyBtn.MouseButton1Click:Connect(function()
    F = not F
    FlyBtn.Text = F and "FLIGHT: ON" or "FLIGHT: OFF"
    local c = P.Character
    local hrp, hum = c:FindFirstChild("HumanoidRootPart"), c:FindFirstChild("Humanoid")
    if not hrp or not F then return end
    local bv = Instance.new("BodyVelocity", hrp)
    bv.MaxForce = Vector3.new(1e6,1e6,1e6)
    task.spawn(function()
        while F and task.wait() do
            bv.Velocity = hum.MoveDirection * (tonumber(SpeedInput.Text) or 50) + Vector3.new(0,2,0)
        end
        bv:Destroy()
    end)
end)

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
