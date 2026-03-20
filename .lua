-- SERVICES
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- SAVE SYSTEM
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

-- FLUENT UI
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ScreenGui.ResetOnSpawn = false

local Window = Fluent:CreateWindow({
    Parent = ScreenGui,
    Title = "Poom Edit",
    SubTitle = "Darkcoat + AutoFarm",
    Size = UDim2.fromOffset(500,400),
    Acrylic = true,
    Theme = "Dark"
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main" }),
    Settings = Window:AddTab({ Title = "Settings" })
}

local Options = Fluent.Options

-- FUNCTION: Check Fist of Darkness
function HasFOD()
    local char = player.Character
    if not char then return false end
    for _,v in pairs(player.Backpack:GetChildren()) do if v.Name == "Fist of Darkness" then return true end end
    for _,v in pairs(char:GetChildren()) do if v.Name == "Fist of Darkness" then return true end end
    return false
end

-- FUNCTION: Tween to Position
function TweenTo(pos)
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    local dist = (hrp.Position - pos).Magnitude
    local tween = TweenService:Create(hrp, TweenInfo.new(dist/250, Enum.EasingStyle.Linear), {CFrame = CFrame.new(pos)})
    tween:Play()
    tween.Completed:Wait()
end

-- FUNCTION: Chest Blacklist
local BlacklistModels = {"Door","Dofamingo","Swan's Room"}
function IsBlacklisted(part)
    if not part or not part.Parent then return false end
    local parentName = part.Parent.Name:lower()
    for _,name in pairs(BlacklistModels) do
        if parentName:find(name:lower()) then return true end
    end
    return false
end

-- FUNCTION: Get Nearest Chest
function GetNearestChest()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    local nearest, dist = nil, math.huge
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("TouchTransmitter") then
            local chest = v.Parent
            if chest and chest:IsA("BasePart") and chest.Name:lower():find("chest") and not IsBlacklisted(chest) then
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

-- FUNCTION: Get Boss
function GetBoss()
    for _,v in pairs(workspace:GetDescendants()) do
        if v.Name == "Darkbeard" and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            return v
        end
    end
end

-- FUNCTION: Summon Boss
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

-- HOP LOW SERVER
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
            _G.DarkcoatStatus = "Idle"
        end
    end
end)

-- FLUENT UI ELEMENTS
local AutoToggle = Tabs.Main:AddToggle("AutoDarkcoat", {
    Title = "Auto Darkcoat",
    Default = Config.AutoFarmDarkcoat
})
AutoToggle:OnChanged(function(state)
    _G.AutoFarmDarkcoat = state
    Config.AutoFarmDarkcoat = state
    SaveConfig()
end)

local ServerToggle = Tabs.Main:AddToggle("HopLow", {
    Title = "Hop Low Server",
    Default = false
})
ServerToggle:OnChanged(function(state)
    _G.HopLow = state
    if state then
        task.spawn(function()
            while _G.HopLow do
                HopLowServer()
                task.wait(10)
            end
        end)
    end
end)

Tabs.Main:AddParagraph({
    Title = "Status",
    Content = "Darkcoat: Idle\nServer: Idle"
})

-- UPDATE STATUS
task.spawn(function()
    while task.wait(0.5) do
        Tabs.Main:SetParagraphContent(1,"Darkcoat: ".._G.DarkcoatStatus.."\nServer: ".._G.ServerStatus)
    end
end)

-- SaveManager & InterfaceManager
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:SetFolder("PoomEdit")
InterfaceManager:SetFolder("PoomEdit")
SaveManager:LoadAutoloadConfig()

Fluent:Notify({Title="PoomEdit", Content="Script Loaded", Duration=5})
