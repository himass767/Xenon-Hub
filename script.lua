--[[ 
    XENON HUB v1.4.7 - RE-CODE EVERYTHING
    Sửa lỗi: Nhấn nút không hoạt động & Đứng im
]]

local Player = game.Players.LocalPlayer
local Core = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local _G = { FarmLevel = false, FlySpeed = 60 }

-- Xóa UI cũ
if Core:FindFirstChild("XenonV7") then Core.XenonV7:Destroy() end

local ScreenGui = Instance.new("ScreenGui", Core); ScreenGui.Name = "XenonV7"

-- NÚT MỞ MENU
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 80, 0, 35)
OpenBtn.Position = UDim2.new(0, 10, 0, 150)
OpenBtn.Text = "XENON"
OpenBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
OpenBtn.Draggable = true
Instance.new("UICorner", OpenBtn)

-- KHUNG MENU
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 300, 0, 350)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Visible = true
Instance.new("UICorner", MainFrame)

local List = Instance.new("ScrollingFrame", MainFrame)
List.Size = UDim2.new(1, -20, 1, -20)
List.Position = UDim2.new(0, 10, 0, 10)
List.BackgroundTransparency = 1
List.CanvasSize = UDim2.new(0, 0, 2, 0)
local Layout = Instance.new("UIListLayout", List)
Layout.Padding = UDim.new(0, 15)
Layout.HorizontalAlignment = "Center"

-- HÀM TẠO NÚT CƠ BẢN (Không lỗi)
local function MakeButton(txt, callback)
    local btn = Instance.new("TextButton", List)
    btn.Size = UDim2.new(0.9, 0, 0, 45)
    btn.Text = txt
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = "GothamBold"
    Instance.new("UICorner", btn)
    
    btn.MouseButton1Click:Connect(function()
        pcall(callback, btn)
    end)
end

-- 1. CHỈNH TỐC ĐỘ
local SBox = Instance.new("TextBox", List)
SBox.Size = UDim2.new(0.9, 0, 0, 40)
SBox.Text = "60"
SBox.PlaceholderText = "Nhập Speed..."
SBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SBox.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", SBox)
SBox:GetPropertyChangedSignal("Text"):Connect(function()
    _G.FlySpeed = tonumber(SBox.Text) or 60
end)

-- 2. BAY (FLY)
local flying = false
MakeButton("FLY: OFF", function(self)
    flying = not flying
    self.Text = flying and "FLY: ON" or "FLY: OFF"
    self.BackgroundColor3 = flying and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(40, 40, 45)
    
    task.spawn(function()
        local hrp = Player.Character:WaitForChild("HumanoidRootPart")
        local bv = Instance.new("BodyVelocity", hrp)
        bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        while flying do
            task.wait()
            if Player.Character.Humanoid.MoveDirection.Magnitude > 0 then
                bv.Velocity = workspace.CurrentCamera.CFrame.LookVector * _G.FlySpeed
            else
                bv.Velocity = Vector3.new(0, 0, 0)
            end
        end
        bv:Destroy()
    end)
end)

-- 3. AUTO FARM (SAILOR PIECE)
MakeButton("AUTO FARM LEVEL", function(self)
    _G.FarmLevel = not _G.FarmLevel
    self.Text = _G.FarmLevel and "FARMING..." or "AUTO FARM LEVEL"
    self.BackgroundColor3 = _G.FarmLevel and Color3.fromRGB(255, 100, 0) or Color3.fromRGB(40, 40, 45)
    
    task.spawn(function()
        while _G.FarmLevel do
            task.wait()
            pcall(function()
                -- Tìm quái
                for _, mob in pairs(workspace.Enemies:GetChildren()) do
                    if mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                        -- Bay thẳng lên đầu quái
                        Player.Character.HumanoidRootPart.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0, 7, 0)
                        -- Vả
                        game:GetService("ReplicatedStorage").Events.Combat:FireServer()
                    end
                end
            end)
        end
    end)
end)

-- Đóng mở Menu
OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)
