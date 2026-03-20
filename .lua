-------------------------------------------------
-- SERVICES
-------------------------------------------------
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer

-------------------------------------------------
-- SAVE / CONFIG
-------------------------------------------------
local FileName = "PoomDarkcoat.json"
local Config = { AutoFarmDarkcoat = false }

if isfile and isfile(FileName) then
    local data = HttpService:JSONDecode(readfile(FileName))
    for k,v in pairs(data) do Config[k] = v end
end

function SaveConfig()
    if writefile then writefile(FileName, HttpService:JSONEncode(Config)) end
end

_G.AutoFarmDarkcoat = Config.AutoFarmDarkcoat
_G.DarkcoatStatus = "Idle"
_G.ServerStatus = "Idle"
_G.HopLow = false

-------------------------------------------------
-- FUNCTIONS
-------------------------------------------------
-- ตรวจสอบว่า Player มี Fist of Darkness หรือไม่
function HasFOD()
    local char = player.Character
    if not char then return false end
    for _,v in pairs(player.Backpack:GetChildren()) do if v.Name == "Fist of Darkness" then return true end end
    for _,v in pairs(char:GetChildren()) do if v.Name == "Fist of Darkness" then return true end end
    return false
end

-- Tween ไปตำแหน่ง
function TweenTo(pos)
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    local dist = (hrp.Position - pos).Magnitude
    if dist < 1 then return end -- ป้องกันไปตำแหน่งเดิมติดประตู
    local tween = TweenService:Create(hrp, TweenInfo.new(dist/250, Enum.EasingStyle.Linear), {CFrame = CFrame.new(pos)})
    tween:Play()
    tween.Completed:Wait()
end

-- Blacklist ของพื้นที่ไม่ควรเข้า
local BlacklistTags = {"Door","Dofamingo"}

function IsBlacklisted(part)
    if not part or not part.Name then return false end
    for _,tag in pairs(BlacklistTags) do
        if part.Name:lower():find(tag:lower()) then return true end
    end
    return false
end

-- หา Chest ที่ใกล้ที่สุด (ไม่เอา Blacklist)
function GetNearestChest()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    local nearest, dist = nil, math.huge
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("TouchTransmitter") and not IsBlacklisted(v.Parent) then
            local chest = v.Parent
            if chest and chest:IsA("BasePart") then
                local d = (chest.Position - hrp.Position).Magnitude
                if d < dist then
                    dist = d
                    nearest = chest
                end
            end
        end
    end
    return nearest
end

-- หา Boss
function GetBoss()
    for _,v in pairs(workspace:GetDescendants()) do
        if v.Name == "Darkbeard" and v:FindFirstChild("Humanoid") then
            if v.Humanoid.Health > 0 then return v end
        end
    end
end

-- Summon Boss
function SummonBoss()
    for _,v in pairs(workspace:GetDescendants()) do
        if v.Name:lower():find("altar") then
            _G.DarkcoatStatus = "Summoning Boss"
            TweenTo(v.Position + Vector3.new(0,5,0))
            task.wait(1)
            local tool = player.Backpack:FindFirstChild("Fist of Darkness")
            if tool then
                player.Character.Humanoid:EquipTool(tool)
                tool:Activate()
            end
            break
        end
    end
end

-- Hop Low Server
function HopLowServer()
    _G.ServerStatus = "Scanning..."
    local cursor = ""
    local bestServer, lowest = nil, math.huge
    repeat
        local url = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?limit=100&sortOrder=Asc"
        if cursor ~= "" then url = url.."&cursor="..cursor end
        local res = HttpService:JSONDecode(game:HttpGet(url))
        for _,v in pairs(res.data) do
            if v.playing < v.maxPlayers then
                if v.playing < lowest then
                    lowest = v.playing
                    bestServer = v.id
                end
            end
        end
        cursor = res.nextPageCursor or ""
        task.wait(0.1)
    until cursor == ""
    if bestServer then
        _G.ServerStatus = "Found ("..lowest.." players)"
        task.wait(1)
        _G.ServerStatus = "Hopping..."
        TeleportService:TeleportToPlaceInstance(game.PlaceId, bestServer)
    else
        _G.ServerStatus = "No Server Found"
    end
end

-------------------------------------------------
-- AUTO FARM LOOP
-------------------------------------------------
task.spawn(function()
    while task.wait(0.3) do
        if _G.AutoFarmDarkcoat then
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local hrp = char.HumanoidRootPart
                if not HasFOD() then
                    _G.DarkcoatStatus = "Farming Chest"
                    local chest = GetNearestChest()
                    if chest then
                        TweenTo(chest.Position + Vector3.new(0,3,0))
                        firetouchinterest(hrp, chest, 0)
                        firetouchinterest(hrp, chest, 1)
                        task.wait(0.2)
                    end
                else
                    local boss = GetBoss()
                    if not boss then
                        SummonBoss()
                        task.wait(5)
                    else
                        _G.DarkcoatStatus = "Killing Boss"
                        repeat task.wait()
                            if boss:FindFirstChild("HumanoidRootPart") then
                                hrp.CFrame = boss.HumanoidRootPart.CFrame * CFrame.new(0,10,0)
                            end
                            local tool = char:FindFirstChildOfClass("Tool")
                            if tool then tool:Activate() end
                        until not boss or boss.Humanoid.Health <= 0
                    end
                end
            end
        else
            _G.DarkcoatStatus = "N/A"
        end
    end
end)

-------------------------------------------------
-- FLUENT UI
-------------------------------------------------
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local Window = Fluent:CreateWindow({
    Title = "Darkcoat Hub",
    SubTitle = "by Poom",
    Size = UDim2.fromOffset(520,380),
    Theme = "Dark",
    Acrylic = true,
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({Title="Main"}),
    Settings = Window:AddTab({Title="Settings"})
}

-- Status Labels
local StatusLabel = Tabs.Main:AddParagraph({Title="Status", Content="Status will appear here."})
local ServerLabel = Tabs.Main:AddParagraph({Title="Server Status", Content="Server status here."})

-- Auto Darkcoat Toggle
local ToggleDarkcoat = Tabs.Main:AddToggle("AutoDarkcoat", {Title="Auto Darkcoat", Default=Config.AutoFarmDarkcoat})
ToggleDarkcoat:OnChanged(function(value)
    _G.AutoFarmDarkcoat = value
    Config.AutoFarmDarkcoat = value
    SaveConfig()
end)

-- Hop Low Server Toggle
local ToggleHopLow = Tabs.Main:AddToggle("HopLowServer", {Title="Hop Low Server", Default=false})
ToggleHopLow:OnChanged(function(value)
    _G.HopLow = value
    if value then
        task.spawn(function()
            while _G.HopLow do
                HopLowServer()
                task.wait(10)
            end
        end)
    end
end)

-- Minimize / Open UI ปุ่มลอย
local OpenBtn = Instance.new("TextButton", game.CoreGui)
OpenBtn.Size = UDim2.fromOffset(100,30)
OpenBtn.Position = UDim2.new(0,20,0.5,0)
OpenBtn.Text = "Open UI"
OpenBtn.Visible = false
OpenBtn.BackgroundColor3 = Color3.fromRGB(0,170,255)
OpenBtn.TextColor3 = Color3.new(1,1,1)
OpenBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", OpenBtn)

Window:OnMinimize(function()
    OpenBtn.Visible = true
end)
OpenBtn.MouseButton1Click:Connect(function()
    Window:Show()
    OpenBtn.Visible = false
end)

-- Update Status ทุกวินาที
task.spawn(function()
    while task.wait(1) do
        StatusLabel:UpdateContent("Status: ".._G.DarkcoatStatus)
        ServerLabel:UpdateContent("Server: ".._G.ServerStatus)
    end
end)
