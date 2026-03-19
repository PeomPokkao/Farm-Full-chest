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

function TweenTo(pos)
	local char=player.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	local tween=TweenService:Create(char.HumanoidRootPart,TweenInfo.new((char.HumanoidRootPart.Position-pos).Magnitude/200),{CFrame=CFrame.new(pos)})
	tween:Play()
	tween.Completed:Wait()
end

function GetBoss()
	for _,v in pairs(workspace.Enemies:GetChildren()) do
		if v.Name=="Darkbeard" and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health>0 then
			return v
		end
	end
end

function SummonBoss()
	local altar=workspace:FindFirstChild("DarkbeardAltar",true)
	if altar then
		TweenTo(altar.Position+Vector3.new(0,5,0))
		task.wait(1)
		local tool=player.Backpack:FindFirstChild("First of Darkness")
		if tool then
			player.Character.Humanoid:EquipTool(tool)
			tool:Activate()
		end
	end
end

function IsBossCasting(boss)
	local hum=boss:FindFirstChild("Humanoid")
	local hrp=boss:FindFirstChild("HumanoidRootPart")
	if not hum or not hrp then return false end
	if hrp.Velocity.Magnitude<1 then return true end
	for _,v in pairs(hum:GetPlayingAnimationTracks()) do
		if v.IsPlaying then return true end
	end
	return false
end

-------------------------------------------------
-- LOOPS
-------------------------------------------------
task.spawn(function()
	while task.wait(1) do
		if _G.AutoChest and not HasFOD() then
			for _,v in pairs(workspace:GetDescendants()) do
				if v:IsA("TouchTransmitter") then
					local chest=v.Parent
					if chest and chest:FindFirstChild("TouchInterest") then
						TweenTo(chest.Position+Vector3.new(0,3,0))
						firetouchinterest(player.Character.HumanoidRootPart,chest,0)
						firetouchinterest(player.Character.HumanoidRootPart,chest,1)
					end
				end
			end
		end
	end
end)

task.spawn(function()
	while task.wait(1) do
		if _G.AutoBoss then
			if HasFOD() then
				SummonBoss()
				task.wait(5)
			end
			local boss=GetBoss()
			if boss then
				repeat task.wait()
					if not _G.SmartDodge then
						TweenTo(boss.HumanoidRootPart.Position+Vector3.new(0,10,0))
					end
					local tool=player.Character:FindFirstChildOfClass("Tool")
					if tool then tool:Activate() end
				until not boss or boss.Humanoid.Health<=0
			end
		end
	end
end)

task.spawn(function()
	while task.wait(1) do
		if _G.AutoHaki then
			pcall(function()
				if not player.Character:FindFirstChild("HasBuso") then
					ReplicatedStorage.Remotes.CommF_:InvokeServer("Buso")
				end
			end)
		end
	end
end)

task.spawn(function()
	while task.wait(0.05) do
		if _G.FastAttack then
			local tool=player.Character and player.Character:FindFirstChildOfClass("Tool")
			if tool then tool:Activate() end
		end
	end
end)

task.spawn(function()
	while task.wait(0.2) do
		if _G.BringMob then
			for _,v in pairs(workspace.Enemies:GetChildren()) do
				if v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health>0 then
					v.HumanoidRootPart.CanCollide=false
					v.HumanoidRootPart.Size=Vector3.new(60,60,60)
					v.HumanoidRootPart.CFrame=player.Character.HumanoidRootPart.CFrame*CFrame.new(0,0,-5)
				end
			end
		end
	end
end)

local safeOffsets={Vector3.new(15,15,0),Vector3.new(-15,15,0),Vector3.new(0,15,15),Vector3.new(0,15,-15)}
local attackOffsets={Vector3.new(6,10,6),Vector3.new(-6,10,6),Vector3.new(-6,10,-6),Vector3.new(6,10,-6)}

task.spawn(function()
	local i=1
	while task.wait(0.12) do
		if _G.SmartDodge then
			local boss=GetBoss()
			local char=player.Character
			if boss and char and char:FindFirstChild("HumanoidRootPart") then
				local pos
				if IsBossCasting(boss) then
					pos=boss.HumanoidRootPart.Position+safeOffsets[i]
				else
					pos=boss.HumanoidRootPart.Position+attackOffsets[i]
				end
				char.HumanoidRootPart.CFrame=CFrame.new(pos,boss.HumanoidRootPart.Position)
				i=i+1 if i>4 then i=1 end
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
