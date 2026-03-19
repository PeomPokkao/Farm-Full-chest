-------------------------------------------------
-- SAVE SYSTEM
-------------------------------------------------
local HttpService = game:GetService("HttpService")
local FileName = "PoomHub_Config.json"

local Config = {
	AutoChest = false,
	AutoBoss = false,
	BringMob = false,
	FastAttack = false,
	AutoHaki = false,
	SmartDodge = false
}

if isfile and isfile(FileName) then
	local data = readfile(FileName)
	local decoded = HttpService:JSONDecode(data)
	for k,v in pairs(decoded) do
		Config[k] = v
	end
end

function SaveConfig()
	if writefile then
		writefile(FileName, HttpService:JSONEncode(Config))
	end
end

-------------------------------------------------
-- UI
-------------------------------------------------
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0,220,0,260)
MainFrame.Position = UDim2.new(0,20,0.3,0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)

local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1,0,0,30)
TopBar.BackgroundColor3 = Color3.fromRGB(20,20,20)

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(0.7,0,1,0)
Title.BackgroundTransparency = 1
Title.Text = "Poom Hub"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true

local MinBtn = Instance.new("TextButton", TopBar)
MinBtn.Size = UDim2.new(0.3,0,1,0)
MinBtn.Position = UDim2.new(0.7,0,0,0)
MinBtn.Text = "-"
MinBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
MinBtn.TextColor3 = Color3.new(1,1,1)
MinBtn.TextScaled = true

local Container = Instance.new("Frame", MainFrame)
Container.Size = UDim2.new(1,0,1,-30)
Container.Position = UDim2.new(0,0,0,30)
Container.BackgroundTransparency = 1

local UIList = Instance.new("UIListLayout", Container)
UIList.Padding = UDim.new(0,5)

-------------------------------------------------
-- DRAG
-------------------------------------------------
local UIS = game:GetService("UserInputService")
local dragging, startPos, startFramePos

TopBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		startPos = input.Position
		startFramePos = MainFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end
end)

UIS.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - startPos
		MainFrame.Position = UDim2.new(
			startFramePos.X.Scale,
			startFramePos.X.Offset + delta.X,
			startFramePos.Y.Scale,
			startFramePos.Y.Offset + delta.Y
		)
	end
end)

-------------------------------------------------
-- MINIMIZE
-------------------------------------------------
local minimized=false
MinBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	if minimized then
		Container.Visible=false
		MainFrame:TweenSize(UDim2.new(0,220,0,30),"Out","Quad",0.25,true)
		MinBtn.Text="+"
	else
		Container.Visible=true
		MainFrame:TweenSize(UDim2.new(0,220,0,260),"Out","Quad",0.25,true)
		MinBtn.Text="-"
	end
end)

-------------------------------------------------
-- TOGGLE
-------------------------------------------------
function CreateToggle(name,key,callback)
	local btn = Instance.new("TextButton", Container)
	btn.Size = UDim2.new(1,-10,0,35)
	btn.TextColor3 = Color3.new(1,1,1)
	
	local state = Config[key]
	btn.Text = name.." : "..(state and "ON" or "OFF")
	btn.BackgroundColor3 = state and Color3.fromRGB(0,170,0) or Color3.fromRGB(40,40,40)
	
	callback(state)
	
	btn.MouseButton1Click:Connect(function()
		state = not state
		btn.Text = name.." : "..(state and "ON" or "OFF")
		btn.BackgroundColor3 = state and Color3.fromRGB(0,170,0) or Color3.fromRGB(40,40,40)
		
		Config[key] = state
		SaveConfig()
		
		callback(state)
	end)
end

-------------------------------------------------
-- GLOBAL
-------------------------------------------------
_G.AutoChest = Config.AutoChest
_G.AutoBoss = Config.AutoBoss
_G.BringMob = Config.BringMob
_G.FastAttack = Config.FastAttack
_G.AutoHaki = Config.AutoHaki
_G.SmartDodge = Config.SmartDodge

-------------------------------------------------
-- SERVICES
-------------------------------------------------
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-------------------------------------------------
-- FIX TWEEN (นิ่ง)
-------------------------------------------------
function TweenTo(pos)
	local char = player.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	
	local hrp = char.HumanoidRootPart
	local hum = char:FindFirstChild("Humanoid")
	
	if hrp:FindFirstChild("Tweening") then return end
	local flag = Instance.new("BoolValue", hrp)
	flag.Name = "Tweening"
	
	pos = Vector3.new(pos.X, hrp.Position.Y, pos.Z)
	
	if hum then
		hum:ChangeState(Enum.HumanoidStateType.Physics)
		for _,v in pairs(hum:GetPlayingAnimationTracks()) do
			v:Stop()
		end
	end
	
	local distance = (hrp.Position - pos).Magnitude
	
	local tween = TweenService:Create(
		hrp,
		TweenInfo.new(distance/260, Enum.EasingStyle.Linear),
		{CFrame = CFrame.new(pos)}
	)
	
	tween:Play()
	tween.Completed:Wait()
	
	if hum then
		hum:ChangeState(Enum.HumanoidStateType.Running)
	end
	
	flag:Destroy()
end

-------------------------------------------------
-- FUNCTIONS
-------------------------------------------------
function HasFOD()
	for _,v in pairs(player.Backpack:GetChildren()) do
		if v.Name=="First of Darkness" then return true end
	end
	for _,v in pairs(player.Character:GetChildren()) do
		if v.Name=="First of Darkness" then return true end
	end
	return false
end

-------------------------------------------------
-- FIX AUTO CHEST
-------------------------------------------------
function GetChests()
	local list = {}
	for _,v in pairs(workspace:GetDescendants()) do
		if v:IsA("TouchTransmitter") then
			local chest = v.Parent
			if chest and chest:IsA("BasePart") then
				table.insert(list, chest)
			end
		end
	end
	return list
end

function GetNearestChest()
	local char = player.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	
	local hrp = char.HumanoidRootPart
	local chests = GetChests()
	
	table.sort(chests, function(a,b)
		return (a.Position - hrp.Position).Magnitude < (b.Position - hrp.Position).Magnitude
	end)
	
	return chests[1]
end

task.spawn(function()
	while task.wait(0.4) do
		if _G.AutoChest and not HasFOD() then
			local chest = GetNearestChest()
			if chest then
				TweenTo(chest.Position + Vector3.new(0,3,0))
				firetouchinterest(player.Character.HumanoidRootPart, chest, 0)
				firetouchinterest(player.Character.HumanoidRootPart, chest, 1)
			end
		end
	end
end)

-------------------------------------------------
-- TOGGLES
-------------------------------------------------
CreateToggle("Auto Chest","AutoChest", function(v) _G.AutoChest=v end)
CreateToggle("Auto Boss","AutoBoss", function(v) _G.AutoBoss=v end)
CreateToggle("Bring Mob","BringMob", function(v) _G.BringMob=v end)
CreateToggle("Fast Attack","FastAttack", function(v) _G.FastAttack=v end)
CreateToggle("Auto Haki","AutoHaki", function(v) _G.AutoHaki=v end)
CreateToggle("Smart Dodge","SmartDodge", function(v) _G.SmartDodge=v end)
