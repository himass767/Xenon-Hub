--[[ 
    XENON HUB v1.4.5.3 - EMERGENCY FIX
    Owners: Himass & Z-Ω
]]

-- Đợi game tải
if not game:IsLoaded() then game.Loaded:Wait() end

local P = game.Players.LocalPlayer
local S = (gethui and gethui()) or game:GetService("CoreGui") or P:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")
local _G = { Farm = false, Speed = 60 }

-- Xóa UI cũ để không bị chồng
if S:FindFirstChild("XenonEmergency") then S.XenonEmergency:Destroy() end

local SG = Instance.new("ScreenGui", S)
SG.Name = "XenonEmergency"
SG.ResetOnSpawn = false

-- NÚT MỞ MENU (Cái này quan trọng nhất, phải hiện cái này)
local T = Instance.new("TextButton", SG)
T.Size = UDim2.new(0, 70, 0, 30)
T.Position = UDim2.new(0, 10, 0, 200)
T.Text = "XENON"
T.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
T.TextColor3 = Color3.new(1,1,1)
T.Font = Enum.Font.GothamBold
T.Active = true
T.Draggable = true
Instance.new("UICorner", T)

-- MENU CHÍNH
local M = Instance.new("Frame", SG)
M.Size = UDim2.new(0, 350, 0, 280)
M.Position = UDim2.new(0.5, -175, 0.5, -140)
M.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
M.Visible = true -- Mặc định hiện luôn để check
M.Active = true
M.Draggable = true
Instance.new("UICorner", M)

-- Sidebar (Bên trái)
local Side = Instance.new("Frame", M)
Side.Size = UDim2.new(0, 90, 1, 0)
Side.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Instance.new("UICorner", Side)

local SideLayout = Instance.new("UIListLayout", Side)
SideLayout.Padding = UDim.new(0, 10)
SideLayout.HorizontalAlignment = "Center"
Instance.new("UIPadding", Side).PaddingTop = UDim.new(0, 15)

-- Container chứa các trang
local Pages = Instance.new("Frame", M)
Pages.Size = UDim2.new(0, 250, 1, 0)
Pages.Position = UDim2.new(0, 100, 0, 0)
Pages.BackgroundTransparency = 1

local function CreatePage(visible)
    local p = Instance.new("ScrollingFrame", Pages)
    p.Size = UDim2.new(1, 0, 1, 0)
    p.BackgroundTransparency = 1
    p.Visible = visible
    p.CanvasSize = UDim2.new(0, 0, 2, 0) -- Cho phép cuộn
    p.ScrollBarThickness = 2
    local layout = Instance.new("UIListLayout", p)
    layout.Padding = UDim.new(0, 12)
    layout.HorizontalAlignment = "Center"
    Instance.new("UIPadding", p).PaddingTop = UDim.new(0, 15)
    return p
end

local MainPg = CreatePage(true)
local GamePg = CreatePage(false)

-- Hàm tạo nút (Cách nhau thưa đúng ý mày)
local function AddBtn(txt, parent, callback)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0.9, 0, 0, 40)
    b.Text = txt
    b.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() callback(b) end)
    return b
end

-- --- NỘI DUNG MAIN ---
local SpeedBox = Instance.new("TextBox", MainPg)
SpeedBox.Size = UDim2.new(0.9, 0, 0, 35)
SpeedBox.Text = "60"
SpeedBox.PlaceholderText = "Tốc độ..."
SpeedBox.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
SpeedBox.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", SpeedBox)
SpeedBox:GetPropertyChangedSignal("Text"):Connect(function() _G.Speed = tonumber(SpeedBox.Text) or 60 end)

local flyActive = false
AddBtn("FLY: OFF", MainPg, function(b)
    flyActive = not flyActive
    b.Text = flyActive and "FLY: ON" or "FLY: OFF"
    b.BackgroundColor3 = flyActive and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(35, 35, 45)
    
    task.spawn(function()
        local hrp = P.Character:WaitForChild("HumanoidRootPart")
        local bv = Instance.new("BodyVelocity", hrp)
        bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        while flyActive and task.wait() do
            if P.Character.Humanoid.MoveDirection.Magnitude > 0 then
                bv.Velocity = workspace.CurrentCamera.CFrame.LookVector * _G.Speed
            else
                bv.Velocity = Vector3.new(0,0,0)
            end
        end
        bv:Destroy()
    end)
end)

local SailorFarmFrame = Instance.new("Frame", MainPg)
SailorFarmFrame.Size = UDim2.new(1,0,0,0); SailorFarmFrame.BackgroundTransparency = 1
Instance.new("UIListLayout", SailorFarmFrame).Padding = UDim.new(0, 12)

-- --- NỘI DUNG GAMES ---
AddBtn("SAILOR PIECE", GamePg, function(b)
    b.Text = "KÍCH HOẠT THÀNH CÔNG"; b.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    
    AddBtn("AUTO FARM", SailorFarmFrame, function(fb)
        _G.Farm = not _G.Farm
        fb.Text = _G.Farm and "FARM: ON" or "FARM: OFF"
        fb.BackgroundColor3 = _G.Farm and Color3.fromRGB(255, 100, 0) or Color3.fromRGB(35, 35, 45)
        
        task.spawn(function()
            while _G.Farm do task.wait()
                pcall(function()
                    for _, v in pairs(workspace.Enemies:GetChildren()) do
                        if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                            P.Character.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, 7, 0)
                            game:GetService("ReplicatedStorage").Events.Combat:FireServer()
                        end
                    end
                end)
            end
        end)
    end)
end)

-- Tab Switch
AddBtn("MAIN", Side, function() MainPg.Visible = true; GamePg.Visible = false end)
AddBtn("GAMES", Side, function() MainPg.Visible = false; GamePg.Visible = true end)

T.MouseButton1Click:Connect(function() M.Visible = not M.Visible end)
