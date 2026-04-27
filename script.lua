--[[ 
    XENON HUB v1.4.5.2 - ULTIMATE FIX
    Owners: Himass & Z-Ω
]]

repeat task.wait() until game:IsLoaded()

local P = game.Players.LocalPlayer
local S = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local _G = { Farm = false, Aura = false, Speed = 60 }

-- Xóa UI cũ nếu có
if S:FindFirstChild("XenonUltra") then S.XenonUltra:Destroy() end

local SG = Instance.new("ScreenGui", S)
SG.Name = "XenonUltra"
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Nút mở/đóng (Toggle Button)
local T = Instance.new("TextButton", SG)
T.Size, T.Position, T.Text = UDim2.new(0,80,0,35), UDim2.new(0,10,0,150), "XENON"
T.BackgroundColor3, T.TextColor3 = Color3.fromRGB(30,30,35), Color3.fromRGB(0,200,255)
T.Font, T.Draggable, T.Active = Enum.Font.GothamBold, true, true
Instance.new("UICorner", T)

-- Menu Chính
local M = Instance.new("Frame", SG)
M.Size, M.Position, M.BackgroundColor3 = UDim2.new(0,380,0,320), UDim2.new(0.5,-190,0.5,-160), Color3.fromRGB(15,15,20)
M.Visible = true
Instance.new("UICorner", M)

-- Sidebar & Pages Container
local Side = Instance.new("Frame", M); Side.Size, Side.BackgroundColor3 = UDim2.new(0,100,1,0), Color3.fromRGB(20,20,28)
Instance.new("UICorner", Side)
local Pages = Instance.new("Frame", M); Pages.Size, Pages.Position = UDim2.new(0,260,1,0), UDim2.new(0,110,0,0); Pages.BackgroundTransparency = 1

local function CreatePage(visible)
    local p = Instance.new("ScrollingFrame", Pages)
    p.Size, p.BackgroundTransparency, p.Visible = UDim2.new(1,0,1,0), 1, visible
    p.ScrollBarThickness, p.AutomaticCanvasSize = 0, "Y"
    local layout = Instance.new("UIListLayout", p); layout.Padding, layout.HorizontalAlignment = UDim.new(0, 12), "Center"
    Instance.new("UIPadding", p).PaddingTop = UDim.new(0, 10)
    return p
end

local MainPg, GamePg = CreatePage(true), CreatePage(false)

local function AddBtn(txt, parent, callback)
    local b = Instance.new("TextButton", parent)
    b.Size, b.Text = UDim2.new(0.9,0,0,40), txt
    b.BackgroundColor3, b.TextColor3 = Color3.fromRGB(40,40,50), Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() callback(b) end)
    return b
end

-- --- TAB MAIN ---
local SpeedBox = Instance.new("TextBox", MainPg)
SpeedBox.Size, SpeedBox.Text = UDim2.new(0.9,0,0,35), "60"
SpeedBox.PlaceholderText = "Tốc độ Fly..."
SpeedBox.BackgroundColor3, SpeedBox.TextColor3 = Color3.fromRGB(30,30,40), Color3.new(1,1,1)
Instance.new("UICorner", SpeedBox)
SpeedBox:GetPropertyChangedSignal("Text"):Connect(function() _G.Speed = tonumber(SpeedBox.Text) or 60 end)

local F = false
AddBtn("FLY: OFF", MainPg, function(b)
    F = not F; b.Text = F and "FLY: ON" or "FLY: OFF"
    b.BackgroundColor3 = F and Color3.fromRGB(0,120,255) or Color3.fromRGB(40,40,50)
    task.spawn(function()
        local hrp = P.Character:WaitForChild("HumanoidRootPart")
        local bv = Instance.new("BodyVelocity", hrp); bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        while F and task.wait() do
            bv.Velocity = (P.Character.Humanoid.MoveDirection.Magnitude > 0) and (workspace.CurrentCamera.CFrame.LookVector * _G.Speed) or Vector3.new(0,0,0)
        end
        bv:Destroy()
    end)
end)

-- --- TAB GAMES (SAILOR) ---
local SailorSection = Instance.new("Frame", MainPg)
SailorSection.Size, SailorSection.BackgroundTransparency = UDim2.new(1,0,0,0), 1
Instance.new("UIListLayout", SailorSection).Padding = UDim.new(0,12)

AddBtn("ACTIVATE SAILOR PIECE", GamePg, function(b)
    b.Text = "ACTIVATED!"; b.BackgroundColor3 = Color3.fromRGB(0,200,100)
    
    AddBtn("AUTO FARM LEVEL", SailorSection, function(fb)
        _G.Farm = not _G.Farm
        fb.Text = _G.Farm and "FARMING..." or "AUTO FARM"
        fb.BackgroundColor3 = _G.Farm and Color3.fromRGB(200,80,0) or Color3.fromRGB(40,40,50)
        
        task.spawn(function()
            while _G.Farm do task.wait()
                pcall(function()
                    for _, v in pairs(workspace.Enemies:GetChildren()) do
                        if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                            P.Character.HumanoidRootPart.CFrame
                                            
