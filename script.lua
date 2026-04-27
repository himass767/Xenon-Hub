--[[ 
    XENON HUB v1.4.5.1 - AUTO FARM FLY FIX
    Owners: Himass & Z-Ω
]]

local P = game.Players.LocalPlayer
local S = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local _G = { Farm = false, Aura = false, Speed = 60 }

-- Xóa UI cũ
if S:FindFirstChild("XenonV1451") then S.XenonV1451:Destroy() end
local SG = Instance.new("ScreenGui", S); SG.Name = "XenonV1451"

-- [Các phần UI cũ giữ nguyên để mày dễ dùng]
local T = Instance.new("TextButton", SG)
T.Size, T.Position, T.Text = UDim2.new(0,80,0,35), UDim2.new(0,10,0,150), "XENON"
T.BackgroundColor3, T.TextColor3 = Color3.fromRGB(20,20,25), Color3.fromRGB(0,200,255)
T.Font, T.Draggable, T.Active = Enum.Font.GothamBold, true, true
Instance.new("UICorner", T)

local M = Instance.new("Frame", SG)
M.Size, M.Position, M.BackgroundColor3 = UDim2.new(0,380,0,320), UDim2.new(0.5,-190,0.5,-160), Color3.fromRGB(12,12,17)
M.Visible = true; Instance.new("UICorner", M)

local Side = Instance.new("Frame", M); Side.Size, Side.BackgroundColor3 = UDim2.new(0,100,1,0), Color3.fromRGB(18,18,24)
Instance.new("UICorner", Side)
local Pages = Instance.new("Frame", M); Pages.Size, Pages.Position = UDim2.new(0,260,1,0), UDim2.new(0,110,0,0); Pages.BackgroundTransparency = 1

local function CreatePage(visible)
    local p = Instance.new("ScrollingFrame", Pages)
    p.Size, p.BackgroundTransparency, p.Visible = UDim2.new(1,0,1,0), 1, visible
    p.ScrollBarThickness, p.AutomaticCanvasSize = 2, "Y"
    local layout = Instance.new("UIListLayout", p); layout.Padding, layout.HorizontalAlignment = UDim.new(0, 15), "Center"
    Instance.new("UIPadding", p).PaddingTop = UDim.new(0, 15)
    return p
end

local MainPg, GamePg = CreatePage(true), CreatePage(false)

local function AddBtn(txt, parent, callback)
    local b = Instance.new("TextButton", parent)
    b.Size, b.Text = UDim2.new(0.95,0,0,45), txt
    b.BackgroundColor3, b.TextColor3 = Color3.fromRGB(35,35,45), Color3.new(1,1,1)
    b.Font, b.TextSize = Enum.Font.GothamBold, 12
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() callback(b) end)
    return b
end

-- --- LOGIC FLY VÀ SPEED ---
local SpeedBox = Instance.new("TextBox", MainPg)
SpeedBox.Size, SpeedBox.Text = UDim2.new(0.95,0,0,40), "60"
SpeedBox.BackgroundColor3, SpeedBox.TextColor3 = Color3.fromRGB(25,25,30), Color3.new(1,1,1)
Instance.new("UICorner", SpeedBox)
SpeedBox:GetPropertyChangedSignal("Text"):Connect(function() _G.Speed = tonumber(SpeedBox.Text) or 60 end)

-- --- TÍNH NĂNG SAILOR PIECE ---
local SailorSection = Instance.new("Frame", MainPg)
SailorSection.Size, SailorSection.BackgroundTransparency = UDim2.new(1,0,0,0), 1
Instance.new("UIListLayout", SailorSection).Padding = UDim.new(0,15)

AddBtn("ACTIVATE SAILOR PIECE", GamePg, function(b)
    b.Text = "ACTIVE!"; b.BackgroundColor3 = Color3.fromRGB(0,200,100)
    
    -- NÚT FARM ĐƯỢC FIX LẠI ĐỂ TỰ BAY
    AddBtn("AUTO FARM LEVEL", SailorSection, function(fb)
        _G.Farm = not _G.Farm
        fb.Text = _G.Farm and "AUTO FARM: ON" or "AUTO FARM: OFF"
        
        task.spawn(function()
            while _G.Farm do task.wait()
                pcall(function()
                    local target = nil
                    -- Tìm quái còn sống
                    for _, v in pairs(workspace.Enemies:GetChildren()) do
                        if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                            target = v
                            break
                        end
                    end
                    
                    if target and
                                        
