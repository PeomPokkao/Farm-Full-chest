local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Poom Edit", "Synapse")
local Tab1 = Window:NewTab("DarkCoat")

local Section9 = Tab1:NewSection("Dark Coat")

-- Label Status
local StatusLabel = Section9:NewLabel("Status : N/A")

-- Toggle Auto Farm
_G.AutoDarkcoat = false
Section9:NewToggle("Farm Darkcoat", "ToggleInfo", function(state)
    _G.AutoDarkcoat = state
    if state then
        StatusLabel:UpdateLabel("Status : Running")
    else
        StatusLabel:UpdateLabel("Status : Stopped")
    end
end)

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- Function: Check if player has Fist of Darkness
local function HasFOD()
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

-- Function: Get nearest chest
local function GetNearestChest()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    local nearest, dist = nil, math.huge

    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name:lower():find("chest") then
            local d = (v.Position - hrp.Position).Magnitude
            if d < dist then
                nearest = v
                dist = d
            end
        end
    end
    return nearest
end

-- Function: Summon Boss at CFrame (มึงบอกตำแหน่ง)
local BossCFrame = CFrame.new(0,10,0) -- ใส่ตำแหน่ง summon จริงที่มึงอยากได้
local function SummonBoss()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    StatusLabel:UpdateLabel("Status : Summoning Boss")
    TweenService:Create(char.HumanoidRootPart, TweenInfo.new(1), {CFrame = BossCFrame}):Play()
    task.wait(1)
    -- Equip tool
    local tool = player.Backpack:FindFirstChild("Fist of Darkness")
    if tool then
        char.Humanoid:EquipTool(tool)
        tool:Activate()
    end
end

-- AUTO FARM LOOP
task.spawn(function()
    while task.wait(0.5) do
        if _G.AutoDarkcoat then
            local char = player.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
            local hrp = char.HumanoidRootPart

            if not HasFOD() then
                -- Farm Chest
                StatusLabel:UpdateLabel("Status : Farming Chest")
                local chest = GetNearestChest()
                if chest then
                    TweenService:Create(hrp, TweenInfo.new(1), {CFrame = chest.CFrame + Vector3.new(0,3,0)}):Play()
                    task.wait(1)
                    firetouchinterest(hrp, chest, 0)
                    firetouchinterest(hrp, chest, 1)
                end
            else
                -- Summon Boss
                SummonBoss()
                task.wait(5)
            end
        else
            StatusLabel:UpdateLabel("Status : Idle")
        end
    end
end)
