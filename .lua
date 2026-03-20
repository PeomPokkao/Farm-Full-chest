-- SERVICES
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui") -- รอ PlayerGui

-- SAVE SYSTEM
local FileName = "PoomDarkcoat.json"
local Config = {AutoFarmDarkcoat = false}
if isfile and isfile(FileName) then
    local data = HttpService:JSONDecode(readfile(FileName))
    for k,v in pairs(data) do Config[k] = v end
end
function SaveConfig()
    if writefile then
        writefile(FileName, HttpService:JSONEncode(Config))
    end
end

_G.AutoFarmDarkcoat = Config.AutoFarmDarkcoat
_G.DarkcoatStatus = "Idle"
_G.ServerStatus = "Idle"
_G.HopLow = false

-- FUNCTIONS
local BlacklistModels = {"Door","Dofamingo","Swan's Room"}
local function IsBlacklisted(part)
    local obj = part
    while obj and obj ~= workspace do
        for _,name in pairs(BlacklistModels) do
            if obj.Name:lower():find(name:lower()) then return true end
        end
        obj = obj.Parent
    end
    return false
end

function HasFOD()
    local char = player.Character
    if not char then return false end
    for _,v in pairs(player.Backpack:GetChildren()) do
        if v.Name == "Fist of Darkness" then return true end
    end
    for _,v in pairs(char:GetChildren()) do
        if v.Name == "Fist of Darkness" then return true end
    end
    return false
end

function TweenTo(pos)
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    local dist = (hrp.Position - pos).Magnitude
    local tween = TweenService:Create(hrp, TweenInfo.new(dist/250, Enum.EasingStyle.Linear), {CFrame = CFrame.new(pos)})
    tween:Play()
    tween.Completed:Wait()
end

function GetNearestChest()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    local nearest, dist = nil, math.huge
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name:lower():find("chest") and not IsBlacklisted(v) then
            local d = (v.Position - hrp.Position).Magnitude
            if d < dist then
                dist = d
                nearest = v
            end
        end
    end
    return nearest
end

function GetBoss()
    for _,v in pairs(workspace:GetDescendants()) do
        if v.Name == "Darkbeard" and v:FindFirstChild("Humanoid") then
            if v.Humanoid.Health > 0 then return v end
        end
    end
end

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

function HopLowServer()
    _G.ServerStatus = "Scanning..."
    local cursor, bestServer, lowest = "", nil, math.huge
    repeat
        local url = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?limit=100&sortOrder=Asc"
        if cursor ~= "" then url = url.."&cursor="..cursor end
        local res = HttpService:JSONDecode(game:HttpGet(url))
        for _,v in pairs(res.data) do
            if v.playing < v.maxPlayers and v.playing < lowest then
                lowest = v.playing
                bestServer = v.id
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

-- AUTO FARM LOOP
task.spawn(function()
    while task.wait(0.3) do
        local char = player.Character
        if _G.AutoFarmDarkcoat and char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            if not HasFOD() then
                _G.DarkcoatStatus = "Farming Chest"
                local chest = GetNearestChest()
                if chest then
                    TweenTo(chest.Position + Vector3.new(0,3,0))
                    firetouchinterest(hrp, chest, 0)
                    firetouchinterest(hrp, chest, 1)
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
        else
            _G.DarkcoatStatus = "N/A"
        end
    end
end)

-- ===== FLUENT UI =====
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Parent = playerGui,
    Title = "Poom Edit",
    SubTitle = "Darkcoat + AutoFarm",
    Size = UDim2.fromOffset(500,400),
    Acrylic = true,
    Theme = "Dark"
})

local Tabs = {
    Main = Window:AddTab({Title = "Main"}),
    Settings = Window:AddTab({Title = "Settings"})
}

local Options = Fluent.Options

-- Auto Darkcoat Toggle
local AutoToggle = Tabs.Main:AddToggle("AutoDarkcoat", {Title="Auto Darkcoat", Default=Config.AutoFarmDarkcoat})
AutoToggle:OnChanged(function()
    Config.AutoFarmDarkcoat = AutoToggle.Value
    _G.AutoFarmDarkcoat = AutoToggle.Value
    SaveConfig()
end)
AutoToggle:SetValue(Config.AutoFarmDarkcoat)

-- Status
local Status = Tabs.Main:AddParagraph({Title="Status", Content="Idle"})
task.spawn(function()
    while task.wait(0.3) do
        Status:SetContent(_G.DarkcoatStatus)
    end
end)

-- Server Hop Button
Tabs.Main:AddButton({Title="Hop Server", Description="Teleport to new server", Callback=function()
    _G.ServerStatus = "Hopping..."
    TeleportService:Teleport(game.PlaceId)
end})

-- Toggle Hop Low
local HopLowToggle = Tabs.Main:AddToggle("HopLow", {Title="Hop Low Server", Default=false})
HopLowToggle:OnChanged(function()
    _G.HopLow = HopLowToggle.Value
    if _G.HopLow then
        task.spawn(function()
            while _G.HopLow do
                HopLowServer()
                task.wait(10)
            end
        end)
    end
end)

-- Save Manager
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:SetFolder("PoomEdit")
InterfaceManager:SetFolder("PoomEdit")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
SaveManager:LoadAutoloadConfig()

Fluent:Notify({Title="Poom Edit", Content="Script Loaded", Duration=5})
