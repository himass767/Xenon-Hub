--[[ 
    XENON HUB v1.4.4 - SAILOR BEAST UPDATE
    Owners: Himass & Z-Ω
]]

local P = game.Players.LocalPlayer
local S = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local F, N, AL = false, false, true
local _G = { Farm = false, Aura = false, Stats = false, Geppo = true }

-- Xóa UI cũ để tránh chồng chéo
if S:FindFirstChild("XenonFinal") then S.XenonFinal:Destroy() end

local SG = Instance.new("ScreenGui", S)
SG.Name = "XenonFinal"

-- Nút mở Menu
local T = Instance.new("TextButton", SG)
T.Size, T.Position, T.Text = UDim2.new(0,80,0,35), UDim2.new(0,10,0,150), "XENON"
T.BackgroundColor3, T.TextColor3 = Color3.fromRGB(20,20,25), Color3.fromRGB(0,200,255)
T.Font, T.Draggable, T.Active = Enum.Font.GothamBold, true, true
Instance.new("UICorner", T)

-- Khung chính
local M = Instance.new("Frame", SG)
M.Size, M.Position, M.BackgroundColor3 = UDim2.new(0,380,0,320), UDim2.new(0.5,-190,0.5,-160), Color3.fromRGB(10,10,15)
M.Visible = true
Instance.new("UICorner", M)

-- Sidebar
local Side = Instance.new("Frame", M)
Side.Size, Side.BackgroundColor3 = UDim2.new(0,100,1,0), Color3.fromRGB(15,15,22)
Instance.new("UICorner", Side)

local SideLayout = Instance.new("UIListLayout", Side)
SideLayout.Padding, SideLayout.HorizontalAlignment = UDim.new(0, 10), "Center"
Instance.new("UIPadding", Side).PaddingTop = UDim.new(0, 20)

-- Trang nội dung
local Pages = Instance.new("Frame", M)
Pages.Size, Pages.Position = UDim2.new(0,260,1,0), UDim2.new(0,110,0,0)
Pages.BackgroundTransparency = 1

local function CreatePage(visible)
    local p = Instance.new("ScrollingFrame", Pages)
    p.Size, p.BackgroundTransparency, p.Visible = UDim2.new(1,0,1,0), 1, visible
    p.ScrollBarThickness, p.AutomaticCanvasSize = 2, "Y"
    local layout = Instance.new("UIListLayout", p)
    layout.Padding, layout.HorizontalAlignment = UDim.new(0, 15), "Center"
    Instance.new("UIPadding", p).PaddingTop = UDim.new(0, 15)
    return p
end

local MainPg = CreatePage(true)
local GamePg = CreatePage(false)
local InfoPg = CreatePage(false)

-- Hàm tạo nút tính năng (Kiểu Buffalo Hub - Cách nhau rộng)
local function AddButton(txt, parent, callback)
    local b = Instance.new("TextButton", parent)
    b.Size, b.Text = UDim2.new(0.95,0,0,45), txt
    b.BackgroundColor3, b.TextColor3 = Color3.fromRGB(30,30,40), Color3.new(1,1,1)
    b.Font, b.TextSize = Enum.Font.GothamBold, 12
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() callback(b) end)
    return b
end

-- --- TAB INFO (Đã thêm nội dung) ---
local function AddInfo(txt)
    local l = Instance.new("TextLabel", InfoPg)
    l.Size, l.Text = UDim2.new(1,0,0,30), txt
    l.TextColor3, l.BackgroundTransparency, l.Font = Color3.new(0.7,0.7,0.7), 1, "Gotham"
end
AddInfo("XENON HUB v1.4.4")
AddInfo("Owner: Himass & Z-Ω")
AddInfo("Special: Sailor Piece Script")

-- --- TAB MAIN (Mặc định) ---
local function LoadMainDefault()
    MainPg:ClearAllChildren()
    Instance.new("UIListLayout", MainPg).Padding = UDim.new(0,15)
    
    AddButton("FLY: OFF", MainPg, function(b)
        F = not F
        b.Text = F and "FLY: ON" or "FLY: OFF"
        b.BackgroundColor3 = F and Color3.fromRGB(0,150,255) or Color3.fromRGB(30,30,40)
        
        local hrp = P.Character:FindFirstChild("HumanoidRootPart")
        if not hrp or not F then return end
        local bv = Instance.new("BodyVelocity", hrp)
        bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        task.spawn(function()
            while F and task.wait() do
                if P.Character.Humanoid.MoveDirection.Magnitude > 0 then
                    bv.Velocity = workspace.CurrentCamera.CFrame.LookVector * 60
                else
                    bv.Velocity = Vector3.new(0,0,0)
                end
            end
            bv:Destroy()
        end)
    end)
    
    AddButton("NOCLIP: OFF", MainPg, function(b)
        N = not N
        b.Text = N and "NOCLIP: ON" or "NOCLIP: OFF"
    end)
end
LoadMainDefault()

-- --- TAB GAMES (Kích hoạt Sailor) ---
AddButton("ACTIVATE SAILOR PIECE", GamePg, function(btn)
    btn.Text = "SAILOR ACTIVE!"
    btn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    
    -- LÀM MỚI TAB MAIN VỚI TÍNH NĂNG FARM
    MainPg:ClearAllChildren()
    local l = Instance.new("UIListLayout", MainPg)
    l.Padding, l.HorizontalAlignment = UDim.new(0,15), "Center"
    
    AddButton("AUTO FARM LEVEL: OFF", MainPg, function(b)
        _G.Farm = not _G.Farm
        b.Text = _G.Farm and "AUTO FARM: ON" or "AUTO FARM: OFF"
        -- Logic: Teleport to Quest NPC & Mobs (Phải có tên NPC cụ thể)
    end)
    
    AddButton("KILL AURA: OFF", MainPg, function(b)
        _G.Aura = not _G.Aura
        b.Text = _G.Aura and "KILL AURA: ON" or "KILL AURA: OFF"
        task.spawn(function()
            while _G.Aura do
                pcall(function()
                    for _, v in pairs(workspace.Enemies:GetChildren()) do
                        if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                            if (P.Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude < 30 then
                                v.Humanoid.Health = 0 -- Ví dụ vả quái
                            end
                        end
                    end
                end)
                task.wait(0.3)
            end
        end)
    end)
    
    AddButton("INFINITE GEPPO: ON", MainPg, function() end)
    
    -- Jump Logic cho Sailor
    UIS.JumpRequest:Connect(function()
        if _G.Geppo then P.Character.Humanoid:ChangeState("Jumping") end
    end)
end)

-- Chuyển Tab
local function TabSwitch(name, pg)
    local b = Instance.new("TextButton", Side)
    b.Size, b.Text = UDim2.new(0.9,0,0,40), name
    b.BackgroundColor3, b.TextColor3 = Color3.fromRGB(25,25,35), Color3.new(1,1,1)
    b.Font = "GothamBold"
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        MainPg.Visible, GamePg.Visible, InfoPg.Visible = (pg == MainPg), (pg == GamePg), (pg == InfoPg)
    end)
end
TabSwitch("MAIN", MainPg)
TabSwitch("GAMES", GamePg)
TabSwitch("INFO", InfoPg)

-- Noclip RunService
RunService.Stepped:Connect(function()
    if N and P.Character then
        for _, v in pairs(P.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
    end
end)

T.MouseButton1Click:Connect(function() M.Visible = not M.Visible end)
