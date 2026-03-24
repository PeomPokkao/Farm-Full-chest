_G.AutoFarm = true

local player = game.Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")

--------------------------------------------------
-- CHARACTER
--------------------------------------------------
local function GetChar()
    return player.Character or player.CharacterAdded:Wait()
end

local function HRP()
    return GetChar():WaitForChild("HumanoidRootPart")
end

--------------------------------------------------
-- 📊 QUEST TABLE (1-2800 ใช้ได้จริง)
--------------------------------------------------
local QuestTable = {

    -- SEA 1
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

    -- SEA 2
    {700,775,"Raider","Area1Quest",1,CFrame.new(-429,72,1836),CFrame.new(-300,80,1700)},
    {776,875,"Mercenary","Area1Quest",2,CFrame.new(-429,72,1836),CFrame.new(-100,80,1500)},
    {876,950,"Swan Pirate","Area2Quest",1,CFrame.new(638,71,918),CFrame.new(700,80,1000)},
    {951,1050,"Factory Staff","Area2Quest",2,CFrame.new(638,71,918),CFrame.new(500,80,700)},
    {1051,1200,"Marine Lieutenant","MarineQuest3",1,CFrame.new(-2440,73,-3210),CFrame.new(-2300,80,-3000)},
    {1201,1350,"Marine Captain","MarineQuest3",2,CFrame.new(-2440,73,-3210),CFrame.new(-2000,80,-3000)},
    {1351,1500,"Zombie","ZombieQuest",1,CFrame.new(-5497,48,-794),CFrame.new(-5600,60,-900)},

    -- SEA 3
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
-- 🔍 หาเควส
--------------------------------------------------
local function GetQuest()
    local Lv = player.Data.Level.Value
    for _,v in pairs(QuestTable) do
        if Lv >= v[1] and Lv <= v[2] then
            return v
        end
    end
end

--------------------------------------------------
-- 🚀 TWEEN
--------------------------------------------------
local function TweenTo(cf)
    local dist = (HRP().Position - cf.Position).Magnitude
    local speed = 300
    local t = dist / speed

    local tween = TweenService:Create(HRP(), TweenInfo.new(t), {CFrame = cf})
    tween:Play()
    tween.Completed:Wait()
end

--------------------------------------------------
-- ⚔️ ATTACK
--------------------------------------------------
local function Attack()
    VirtualUser:Button1Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end

--------------------------------------------------
-- 🔁 AUTO FARM
--------------------------------------------------
task.spawn(function()
    while _G.AutoFarm do
        task.wait(0.3)

        local q = GetQuest()
        if not q then continue end

        local Mob = q[3]
        local QuestName = q[4]
        local QuestLv = q[5]
        local CFrameQuest = q[6]
        local CFrameMob = q[7]

        -- รับเควส
        pcall(function()
            RS.Remotes.CommF_:InvokeServer("StartQuest", QuestName, QuestLv)
        end)

        -- หา mob
        local mob = workspace.Enemies:FindFirstChild(Mob)

        if mob and mob:FindFirstChild("HumanoidRootPart") then
            repeat
                task.wait()

                HRP().CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0,20,0)
                Attack()

            until not mob or mob.Humanoid.Health <= 0 or not _G.AutoFarm
        else
            TweenTo(CFrameMob)
        end
    end
end)
