--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local TeleportService = game:GetService("TeleportService")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

_G.AutoFarm = false
getgenv().bringmob = false
getgenv().UesFast = false

--------------------------------------------------
-- UI
--------------------------------------------------
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "KaitunMiniUI"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 260, 0, 120)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.BackgroundColor3 = Color3.fromRGB(25,25,25)
Main.BorderSizePixel = 0

local MainCorner = Instance.new("UICorner", Main)
MainCorner.CornerRadius = UDim.new(0, 12)

local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Color3.fromRGB(60,60,60)
Stroke.Thickness = 1

--------------------------------------------------
-- DRAG
--------------------------------------------------
local dragging = false
local dragStart, startPos

Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 
    or input.UserInputType == Enum.UserInputType.Touch then

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

UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement 
    or input.UserInputType == Enum.UserInputType.Touch) then

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
-- BUTTON
--------------------------------------------------
local function CreateButton(text, posY)
    local Btn = Instance.new("TextButton", Main)
    Btn.Size = UDim2.new(0, 180, 0, 25)
    Btn.Position = UDim2.new(0.5, -90, 0, posY)
    Btn.BackgroundColor3 = Color3.fromRGB(35,35,35)
    Btn.TextColor3 = Color3.fromRGB(255,255,255)
    Btn.TextSize = 12
    Btn.Font = Enum.Font.GothamBold
    Btn.Text = text

    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", Btn).Color = Color3.fromRGB(70,70,70)

    return Btn
end

local StartBtn = CreateButton("Start : OFF", 30)
local HopBtn = CreateButton("Hop Server", 60)

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
-- QUEST
--------------------------------------------------
local function HRP()
    return (player.Character or player.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
end

local QuestTable = {
    {1,10,"Bandit","BanditQuest1",1,CFrame.new(1060,16,1547),CFrame.new(1150,17,1630)},
    {11,30,"Monkey","JungleQuest",1,CFrame.new(-1600,36,153),CFrame.new(-1440,67,11)},
    {31,60,"Gorilla","JungleQuest",2,CFrame.new(-1600,36,153),CFrame.new(-1100,40,-500)},
    {61,100,"Pirate","BuggyQuest1",1,CFrame.new(-1140,4,3830),CFrame.new(-1200,5,4000)},
    {101,150,"Brute","BuggyQuest1",2,CFrame.new(-1140,4,3830),CFrame.new(-1000,5,4300)},
    {151,225,"Desert Bandit","DesertQuest",1,CFrame.new(894,5,4392),CFrame.new(1000,10,4500)},
    {226,300,"Desert Officer","DesertQuest",2,CFrame.new(894,5,4392),CFrame.new(1600,10,4300)},
    {301,375,"Snow Bandit","SnowQuest",1,CFrame.new(1389,87,-1298),CFrame.new(1200,120,-1400)},
    {376,450,"Snowman","SnowQuest",2,CFrame.new(1389,87,-1298),CFrame.new(1200,150,-1600)},
    {451,525,"Chief Petty Officer","MarineQuest2",1,CFrame.new(-5035,29,4324),CFrame.new(-4900,60,4100)},
    {526,625,"Sky Bandit","SkyQuest",1,CFrame.new(-4842,717,-2623),CFrame.new(-4700,750,-2600)},
    {626,700,"Dark Master","SkyQuest",2,CFrame.new(-4842,717,-2623),CFrame.new(-5200,800,-2300)},
}

local function getQuest()
    local Lv = player.Data.Level.Value
    for _,v in pairs(QuestTable) do
        if Lv >= v[1] and Lv <= v[2] then
            return v
        end
    end
end

--------------------------------------------------
-- AUTO FARM LOOP
--------------------------------------------------
task.spawn(function()
    while true do
        task.wait(0.2)

        if not _G.AutoFarm then
            Status.Text = "Status : Idle"
            continue
        end

        getgenv().bringmob = true
        getgenv().UesFast = true

        local q = getQuest()
        if not q then continue end

        Status.Text = "Status : "..q[3]

        HRP().CFrame = q[6]
        task.wait(1)

        pcall(function()
            RS.Remotes.CommF_:InvokeServer("StartQuest", q[4], q[5])
        end)

        local mob = workspace.Enemies:FindFirstChild(q[3])

        if mob and mob:FindFirstChild("HumanoidRootPart") then
            repeat
                task.wait()
                Posmon = mob.HumanoidRootPart.CFrame
                HRP().CFrame = Posmon * CFrame.new(0,25,0)
            until not _G.AutoFarm or mob.Humanoid.Health <= 0
        else
            HRP().CFrame = q[7]
        end
    end
end)

--------------------------------------------------
-- BUTTON ACTION
--------------------------------------------------
StartBtn.MouseButton1Click:Connect(function()
    _G.AutoFarm = not _G.AutoFarm

    if _G.AutoFarm then
        StartBtn.Text = "Start : ON"
        StartBtn.BackgroundColor3 = Color3.fromRGB(0,170,0)
    else
        StartBtn.Text = "Start : OFF"
        StartBtn.BackgroundColor3 = Color3.fromRGB(35,35,35)
    end
end)

HopBtn.MouseButton1Click:Connect(function()
    Status.Text = "Status : Hopping..."
    task.wait(0.5)
    TeleportService:Teleport(game.PlaceId, player)
end)

--------------------------------------------------
-- FPS / PING
--------------------------------------------------
local fps = 0

RunService.RenderStepped:Connect(function()
    fps = math.floor(1 / RunService.RenderStepped:Wait())
end)

task.spawn(function()
    while task.wait(1) do
        local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        Title.Text = "Kaitun PoomEdit | Ping : "..ping.." | FPS : "..fps
    end
end)
