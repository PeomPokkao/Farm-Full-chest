--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

local player = Players.LocalPlayer

_G.AutoFarm = false

--------------------------------------------------
-- UI
--------------------------------------------------
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "KaitunMiniUI"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 260, 0, 90)
Main.Position = UDim2.new(0, 20, 0, 100)
Main.BackgroundColor3 = Color3.fromRGB(20,20,20)
Main.BorderSizePixel = 0

-- TITLE
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1,0,0,20)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.TextSize = 12
Title.Font = Enum.Font.SourceSansBold
Title.Text = "Kaitun PoomEdit | Ping : ... | FPS : ..."

-- START BUTTON
local Toggle = Instance.new("TextButton", Main)
Toggle.Size = UDim2.new(0, 180, 0, 25)
Toggle.Position = UDim2.new(0.5, -90, 0, 30)
Toggle.BackgroundColor3 = Color3.fromRGB(40,40,40)
Toggle.TextColor3 = Color3.fromRGB(255,255,255)
Toggle.TextSize = 12
Toggle.Font = Enum.Font.SourceSansBold
Toggle.Text = "Start : OFF"

-- STATUS
local Status = Instance.new("TextLabel", Main)
Status.Size = UDim2.new(1,0,0,20)
Status.Position = UDim2.new(0,0,0,60)
Status.BackgroundTransparency = 1
Status.TextColor3 = Color3.fromRGB(200,200,200)
Status.TextSize = 12
Status.Font = Enum.Font.SourceSans
Status.Text = "Status : Idle"

--------------------------------------------------
-- TOGGLE
--------------------------------------------------
Toggle.MouseButton1Click:Connect(function()
    _G.AutoFarm = not _G.AutoFarm

    if _G.AutoFarm then
        Toggle.Text = "Start : ON"
        Toggle.BackgroundColor3 = Color3.fromRGB(0,170,0)
        Status.Text = "Status : Farming..."
    else
        Toggle.Text = "Start : OFF"
        Toggle.BackgroundColor3 = Color3.fromRGB(40,40,40)
        Status.Text = "Status : Idle"
    end
end)

--------------------------------------------------
-- FPS + PING
--------------------------------------------------
local fps = 0

RunService.RenderStepped:Connect(function()
    fps = math.floor(1 / RunService.RenderStepped:Wait())
end)

task.spawn(function()
    while task.wait(1) do
        local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())

        Title.Text = "Kaitun PoomEdit | Ping : "..ping.." ms | FPS : "..fps.." FPS"
    end
end)
