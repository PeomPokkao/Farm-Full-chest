_G.AutoFarmLevel = true

local player = game.Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")

--------------------------------------------------
-- HRP
--------------------------------------------------
local function HRP()
    return (player.Character or player.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
end

--------------------------------------------------
-- QUEST
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
-- 🔥 AUTO FARM
--------------------------------------------------
task.spawn(function()
    while task.wait(0.2) do
        if not _G.AutoFarmLevel then continue end

        local q = getQuest()
        if not q then continue end

        -- รับเควส
        pcall(function()
            RS.Remotes.CommF_:InvokeServer("StartQuest", q.QuestName, q.QuestLv)
        end)

        local mob = workspace.Enemies:FindFirstChild(q.Mob)

        if mob and mob:FindFirstChild("HumanoidRootPart") then
            repeat
                task.wait()

                Posmon = mob.HumanoidRootPart.CFrame
                HRP().CFrame = Posmon * CFrame.new(0,25,0)

            until not _G.AutoFarmLevel or mob.Humanoid.Health <= 0
        else
            HRP().CFrame = q.MobPos
        end
    end
end)

--------------------------------------------------
-- 🧲 BRING MOB (ผูกกับ AutoFarm)
--------------------------------------------------
task.spawn(function()
    while task.wait() do
        if not _G.AutoFarmLevel then continue end

        pcall(function()
            local q = getQuest()
            if not q then return end

            for _,v in pairs(workspace.Enemies:GetChildren()) do
                if v.Name == q.MobsL 
                and v:FindFirstChild("HumanoidRootPart") 
                and v:FindFirstChild("Humanoid") then

                    if (v.HumanoidRootPart.Position - HRP().Position).Magnitude <= 400 then
                        v.HumanoidRootPart.CFrame = Posmon
                        v.Humanoid.WalkSpeed = 0
                        v.Humanoid.JumpPower = 0
                        v.HumanoidRootPart.CanCollide = false
                        v.HumanoidRootPart.Transparency = 1
                        v.Humanoid:ChangeState(11)
                    end
                end
            end
        end)
    end
end)

--------------------------------------------------
-- ⚔️ FAST ATTACK (ผูกกับ AutoFarm)
--------------------------------------------------
local plr = player
local CbFw = debug.getupvalues(require(plr.PlayerScripts.CombatFramework))
local CbFw2 = CbFw[2]

function GetCurrentBlade() 
    local p13 = CbFw2.activeController
    local ret = p13.blades[1]
    if not ret then return end
    while ret.Parent ~= plr.Character do 
        ret = ret.Parent 
    end
    return ret
end

function AttackNoCD() 
    local AC = CbFw2.activeController

    local bladehit = require(game.ReplicatedStorage.CombatFramework.RigLib).getBladeHits(
        plr.Character,
        {plr.Character.HumanoidRootPart},
        60
    )

    if #bladehit > 0 then
        pcall(function()
            for _, anim in pairs(AC.animator.anims.basic) do
                anim:Play()
            end
        end)

        game:GetService("ReplicatedStorage").RigControllerEvent:FireServer(
            "hit", bladehit, 1, ""
        )
    end
end

task.spawn(function()
    while task.wait() do
        if _G.AutoFarmLevel then
            pcall(function()
                AttackNoCD()
            end)
        end
    end
end)
