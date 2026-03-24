_G.AutoPirate = true

local player = game.Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")

task.spawn(function()
    repeat task.wait() until player:FindFirstChild("PlayerGui")

    while _G.AutoPirate do
        task.wait(1)

        -- ถ้ายังไม่มีทีม (ยังไม่เลือก)
        if player.Team == nil then
            pcall(function()
                RS.Remotes.CommF_:InvokeServer("SetTeam", "Pirates")
            end)
        end
    end
end)

wait(1)

local player = game.Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local function HRP()
    return (player.Character or player.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
end

--------------------------------------------------
-- 📊 QUEST TABLE
--------------------------------------------------
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

    {700,775,"Raider","Area1Quest",1,CFrame.new(-429,72,1836),CFrame.new(-300,80,1700)},
    {776,875,"Mercenary","Area1Quest",2,CFrame.new(-429,72,1836),CFrame.new(-100,80,1500)},
    {876,950,"Swan Pirate","Area2Quest",1,CFrame.new(638,71,918),CFrame.new(700,80,1000)},
    {951,1050,"Factory Staff","Area2Quest",2,CFrame.new(638,71,918),CFrame.new(500,80,700)},
    {1051,1200,"Marine Lieutenant","MarineQuest3",1,CFrame.new(-2440,73,-3210),CFrame.new(-2300,80,-3000)},
    {1201,1350,"Marine Captain","MarineQuest3",2,CFrame.new(-2440,73,-3210),CFrame.new(-2000,80,-3000)},
    {1351,1500,"Zombie","ZombieQuest",1,CFrame.new(-5497,48,-794),CFrame.new(-5600,60,-900)},

    {1500,1575,"Pirate Millionaire","PiratePortQuest",1,CFrame.new(-290,42,5580),CFrame.new(-200,50,5700)},
    {1576,1675,"Pistol Billionaire","PiratePortQuest",2,CFrame.new(-290,42,5580),CFrame.new(-400,50,5900)},
    {1676,1800,"Dragon Crew Warrior","AmazonQuest",1,CFrame.new(5830,52,-1100),CFrame.new(5900,60,-900)},
    {1801,2000,"Dragon Crew Archer","AmazonQuest",2,CFrame.new(5830,52,-1100),CFrame.new(6100,60,-800)},
    {2001,2200,"Peanut Scout","NutsQuest",1,CFrame.new(-2100,38,-10100),CFrame.new(-2000,50,-10000)},
    {2201,2400,"Peanut President","NutsQuest",2,CFrame.new(-2100,38,-10100),CFrame.new(-2200,50,-10300)},
    {2401,2600,"Ice Cream Chef","IceCreamQuest",1,CFrame.new(-820,65,-10950),CFrame.new(-900,70,-11000)},
    {2601,2800,"Ice Cream Commander","IceCreamQuest",2,CFrame.new(-820,65,-10950),CFrame.new(-700,70,-10800)},
}

--------------------------------------------------
-- หาเควส
--------------------------------------------------
function getQuest()
    local Lv = player.Data.Level.Value
    for _,v in pairs(QuestTable) do
        if Lv >= v[1] and Lv <= v[2] then
            return {
                Mob = v[3],
                QuestName = v[4],
                QuestLv = v[5],
                QuestPos = v[6],
                MobPos = v[7],
                MobsL = v[3]
            }
        end
    end
end

--------------------------------------------------
-- AUTO FARM LOOP
--------------------------------------------------
task.spawn(function()
    while _G.AutoFarm do
        task.wait(0.2)

        local q = getQuest()
        if not q then continue end

        local mob = workspace.Enemies:FindFirstChild(q.Mob)

        -- รับเควส
        pcall(function()
            RS.Remotes.CommF_:InvokeServer("StartQuest", q.QuestName, q.QuestLv)
        end)

        if mob and mob:FindFirstChild("HumanoidRootPart") then
            repeat
                task.wait()

                -- จุดรวมมอน
                Posmon = mob.HumanoidRootPart.CFrame

                -- ยืนลอย
                HRP().CFrame = Posmon * CFrame.new(0,25,0)

            until mob.Humanoid.Health <= 0 or not _G.AutoFarm
        else
            HRP().CFrame = q.MobPos
        end
    end
end)

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()

local Window = Library.CreateLib("Kaitun Poom Edit", "Sentinel")

local Tab = Window:NewTab("Kaitun")

local Section = Tab:NewSection("Kaitun")

Section:NewLabel("Kaitun")

Section:NewButton("RedeemCode", "redeemcode", function()
    print("Clicked")
end)

Section:NewToggle("start", "start Kaitun function", function(state)

_G.AutoFarm = state
getgenv().bringmob = state
getgenv().UesFast = state

end)
