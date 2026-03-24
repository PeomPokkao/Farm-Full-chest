--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local TeleportService = game:GetService("TeleportService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer

_G.AutoFarm = false

--------------------------------------------------
-- UI
--------------------------------------------------
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "KaitunMiniUI"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 260, 0, 120)
Main.Position = UDim2.new(0, 20, 0, 100)
Main.BackgroundColor3 = Color3.fromRGB(25,25,25)
Main.BorderSizePixel = 0

-- โค้ง
local MainCorner = Instance.new("UICorner", Main)
MainCorner.CornerRadius = UDim.new(0, 12)

-- เงา
local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Color3.fromRGB(60,60,60)
Stroke.Thickness = 1

--------------------------------------------------
-- DRAG
--------------------------------------------------
local dragging, dragInput, dragStart, startPos

Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Main.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

--------------------------------------------------
-- TITLE
--------------------------------------------------
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1,0,0,20)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.TextSize = 12
Title.Font = Enum.Font.GothamBold
Title.Text = "Kaitun PoomEdit | Ping : ... | FPS : ..."

--------------------------------------------------
-- BUTTON STYLE FUNCTION
--------------------------------------------------
local function CreateButton(parent, text, posY)
    local Btn = Instance.new("TextButton", parent)
    Btn.Size = UDim2.new(0, 180, 0, 25)
    Btn.Position = UDim2.new(0.5, -90, 0, posY)
    Btn.BackgroundColor3 = Color3.fromRGB(35,35,35)
    Btn.TextColor3 = Color3.fromRGB(255,255,255)
    Btn.TextSize = 12
    Btn.Font = Enum.Font.GothamBold
    Btn.Text = text

    local corner = Instance.new("UICorner", Btn)
    corner.CornerRadius = UDim.new(0, 8)

    local stroke = Instance.new("UIStroke", Btn)
    stroke.Color = Color3.fromRGB(70,70,70)

    return Btn
end

--------------------------------------------------
-- BUTTONS
--------------------------------------------------
local StartBtn = CreateButton(Main, "Start : OFF", 30)
local HopBtn = CreateButton(Main, "Hop Server", 60)

--------------------------------------------------
-- STATUS
--------------------------------------------------
local Status = Instance.new("TextLabel", Main)
Status.Size = UDim2.new(1,0,0,20)
Status.Position = UDim2.new(0,0,0,90)
Status.BackgroundTransparency = 1
Status.TextColor3 = Color3.fromRGB(180,180,180)
Status.TextSize = 12
Status.Font = Enum.Font.Gotham
Status.Text = "Status : Idle"

--------------------------------------------------
-- START TOGGLE
--------------------------------------------------
StartBtn.MouseButton1Click:Connect(function()
    _G.AutoFarm = not _G.AutoFarm

    if _G.AutoFarm then
        StartBtn.Text = "Start : ON"
        StartBtn.BackgroundColor3 = Color3.fromRGB(0,170,0)
        Status.Text = "Status : Farming..."
    else
        StartBtn.Text = "Start : OFF"
        StartBtn.BackgroundColor3 = Color3.fromRGB(35,35,35)
        Status.Text = "Status : Idle"
    end
end)

--------------------------------------------------
-- HOP SERVER
--------------------------------------------------
HopBtn.MouseButton1Click:Connect(function()
    Status.Text = "Status : Hopping..."
    task.wait(0.5)

    TeleportService:Teleport(game.PlaceId, player)
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
