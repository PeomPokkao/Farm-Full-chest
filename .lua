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
-- SAVE SYSTEM
-------------------------------------------------
local FileName = "PoomDarkcoat.json"

local Config = {
	AutoFarmDarkcoat = false
}

if isfile and isfile(FileName) then
	local data = HttpService:JSONDecode(readfile(FileName))
	for k,v in pairs(data) do
		Config[k] = v
	end
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

-------------------------------------------------
-- FUNCTIONS
-------------------------------------------------
function HasFOD()
	local char = player.Character
	if not char then return false end
	
	for _,v in pairs(player.Backpack:GetChildren()) do
		if v.Name == "First of Darkness" then return true end
	end
	
	for _,v in pairs(char:GetChildren()) do
		if v.Name == "First of Darkness" then return true end
	end
	
	return false
end

function TweenTo(pos)
	local char = player.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	
	local hrp = char.HumanoidRootPart
	local dist = (hrp.Position - pos).Magnitude
	
	local tween = TweenService:Create(
		hrp,
		TweenInfo.new(dist/250, Enum.EasingStyle.Linear),
		{CFrame = CFrame.new(pos)}
	)
	tween:Play()
	tween.Completed:Wait()
end

function GetNearestChest()
	local char = player.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	
	local hrp = char.HumanoidRootPart
	local nearest, dist = nil, math.huge
	
	for _,v in pairs(workspace:GetDescendants()) do
		if v:IsA("TouchTransmitter") then
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

function GetBoss()
	for _,v in pairs(workspace:GetDescendants()) do
		if v.Name == "Darkbeard" and v:FindFirstChild("Humanoid") then
			if v.Humanoid.Health > 0 then
				return v
			end
		end
	end
end

function SummonBoss()
	for _,v in pairs(workspace:GetDescendants()) do
		if v.Name:lower():find("altar") then
			_G.DarkcoatStatus = "Summoning Boss"
			TweenTo(v.Position + Vector3.new(0,5,0))
			task.wait(1)
			
			local tool = player.Backpack:FindFirstChild("First of Darkness")
			if tool then
				player.Character.Humanoid:EquipTool(tool)
				tool:Activate()
			end
			break
		end
	end
end

-------------------------------------------------
-- HOP LOW SERVER
-------------------------------------------------
function HopLowServer()
	_G.ServerStatus = "Scanning..."
	local cursor = ""
	local bestServer = nil
	local lowest = math.huge

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
-- GUI SETUP
-------------------------------------------------
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0,0,0,0)
Main.Position = UDim2.new(0.5,-175,0.5,-125)
Main.BackgroundColor3 = Color3.fromRGB(18,18,18)
Instance.new("UICorner", Main)
Main:TweenSize(UDim2.new(0,350,0,320),"Out","Back",0.4,true)

local Top = Instance.new("Frame", Main)
Top.Size = UDim2.new(1,0,0,35)
Top.BackgroundColor3 = Color3.fromRGB(25,25,25)

local Title = Instance.new("TextLabel", Top)
Title.Size = UDim2.new(1,0,1,0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14

-------------------------------------------------
-- FPS / PING
-------------------------------------------------
local fps, currentFPS, last = 0,0,tick()
RunService.RenderStepped:Connect(function()
	fps+=1
	if tick()-last>=1 then
		currentFPS=fps
		fps=0
		last=tick()
	end
end)

task.spawn(function()
	while task.wait(1) do
		local timeNow=os.date("%H:%M:%S")
		local ping=math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
		Title.Text="Poom Edit | "..timeNow.." | "..ping.." ms | "..currentFPS.." FPS"
	end
end)

-------------------------------------------------
-- DARKCOAT SECTION
-------------------------------------------------
local Section = Instance.new("Frame", Main)
Section.Size = UDim2.new(1,-10,0,120)
Section.Position = UDim2.new(0,5,0,45)
Section.BackgroundColor3 = Color3.fromRGB(28,28,28)

local StatusLabel = Instance.new("TextLabel", Section)
StatusLabel.Size = UDim2.new(1,-10,0,25)
StatusLabel.Position = UDim2.new(0,5,0,70)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.new(1,1,1)

task.spawn(function()
	while task.wait(0.2) do
		StatusLabel.Text = "Status: ".._G.DarkcoatStatus
	end
end)

-------------------------------------------------
-- TOGGLE
-------------------------------------------------
local function CreateToggle(parent, text, key)
	local Frame = Instance.new("Frame", parent)
	Frame.Size = UDim2.new(1,-10,0,35)
	Frame.Position = UDim2.new(0,5,0,35)

	local Label = Instance.new("TextLabel", Frame)
	Label.Size = UDim2.new(0.6,0,1,0)
	Label.BackgroundTransparency = 1
	Label.Text = text
	Label.TextColor3 = Color3.new(1,1,1)

	local Toggle = Instance.new("Frame", Frame)
	Toggle.Size = UDim2.new(0,45,0,22)
	Toggle.Position = UDim2.new(1,-50,0.5,-11)
	Toggle.BackgroundColor3 = Color3.fromRGB(50,50,50)

	local Circle = Instance.new("Frame", Toggle)
	Circle.Size = UDim2.new(0,18,0,18)
	Circle.Position = UDim2.new(0,2,0.5,-9)
	Circle.BackgroundColor3 = Color3.new(1,1,1)

	local state = Config[key]

	local function Update()
		if state then
			Toggle.BackgroundColor3 = Color3.fromRGB(0,170,255)
			Circle:TweenPosition(UDim2.new(1,-20,0.5,-9),"Out","Sine",0.2,true)
		else
			Toggle.BackgroundColor3 = Color3.fromRGB(50,50,50)
			Circle:TweenPosition(UDim2.new(0,2,0.5,-9),"Out","Sine",0.2,true)
		end
		_G[key] = state
	end

	Update()

	Toggle.InputBegan:Connect(function(input)
		if input.UserInputType.Name:find("Mouse") then
			state = not state
			Config[key] = state
			SaveConfig()
			Update()
		end
	end)
end

CreateToggle(Section,"Auto Darkcoat","AutoFarmDarkcoat")

-------------------------------------------------
-- SERVER SECTION
-------------------------------------------------
local ServerSection = Instance.new("Frame", Main)
ServerSection.Size = UDim2.new(1,-10,0,120)
ServerSection.Position = UDim2.new(0,5,0,180)
ServerSection.BackgroundColor3 = Color3.fromRGB(28,28,28)

local ServerLabel = Instance.new("TextLabel", ServerSection)
ServerLabel.Size = UDim2.new(1,-10,0,25)
ServerLabel.Position = UDim2.new(0,5,0,80)
ServerLabel.BackgroundTransparency = 1
ServerLabel.TextColor3 = Color3.new(1,1,1)

task.spawn(function()
	while task.wait(0.2) do
		ServerLabel.Text = "Status: ".._G.ServerStatus
	end
end)

-- Hop Button
local HopBtn = Instance.new("TextButton", ServerSection)
HopBtn.Size = UDim2.new(1,-10,0,35)
HopBtn.Position = UDim2.new(0,5,0,40)
HopBtn.Text = "Hop Server"
HopBtn.BackgroundColor3 = Color3.fromRGB(0,170,255)

HopBtn.MouseButton1Click:Connect(function()
	_G.ServerStatus = "Hopping..."
	TeleportService:Teleport(game.PlaceId)
end)

-- Toggle Hop Low
local function CreateServerToggle(parent)
	local Frame = Instance.new("Frame", parent)
	Frame.Size = UDim2.new(1,-10,0,35)
	Frame.Position = UDim2.new(0,5,0,0)

	local Toggle = Instance.new("Frame", Frame)
	Toggle.Size = UDim2.new(0,45,0,22)
	Toggle.Position = UDim2.new(1,-50,0.5,-11)
	Toggle.BackgroundColor3 = Color3.fromRGB(50,50,50)

	local Circle = Instance.new("Frame", Toggle)
	Circle.Size = UDim2.new(0,18,0,18)
	Circle.Position = UDim2.new(0,2,0.5,-9)
	Circle.BackgroundColor3 = Color3.new(1,1,1)

	local state = false

	Toggle.InputBegan:Connect(function(input)
		if input.UserInputType.Name:find("Mouse") then
			state = not state

			if state then
				_G.HopLow = true
				Toggle.BackgroundColor3 = Color3.fromRGB(0,170,255)
				Circle:TweenPosition(UDim2.new(1,-20,0.5,-9),"Out","Sine",0.2,true)

				task.spawn(function()
					while _G.HopLow do
						HopLowServer()
						task.wait(10)
					end
				end)
			else
				_G.HopLow = false
				_G.ServerStatus = "Stopped"
				Toggle.BackgroundColor3 = Color3.fromRGB(50,50,50)
				Circle:TweenPosition(UDim2.new(0,2,0.5,-9),"Out","Sine",0.2,true)
			end
		end
	end)
end

CreateServerToggle(ServerSection)

-------------------------------------------------
-- MINIMIZE + FLOAT BUTTON
-------------------------------------------------
local MinBtn = Instance.new("TextButton", Top)
MinBtn.Size = UDim2.new(0,30,1,0)
MinBtn.Position = UDim2.new(1,-30,0,0)
MinBtn.Text = "-"
MinBtn.BackgroundTransparency = 1
MinBtn.TextColor3 = Color3.new(1,1,1)
MinBtn.Font = Enum.Font.GothamBold

local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0,120,0,35)
OpenBtn.Position = UDim2.new(0,20,0.5,0)
OpenBtn.Text = "OPEN UI"
OpenBtn.Visible = false
OpenBtn.BackgroundColor3 = Color3.fromRGB(0,170,255)
OpenBtn.TextColor3 = Color3.new(1,1,1)
OpenBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", OpenBtn)

local minimized = false

MinBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	Main.Visible = not minimized
	OpenBtn.Visible = minimized
end)

OpenBtn.MouseButton1Click:Connect(function()
	Main.Visible = true
	OpenBtn.Visible = false
	minimized = false
end)

-------------------------------------------------
-- DRAG FIX (MAIN + BUTTON)
-------------------------------------------------
local draggingMain, dragStartMain, startPosMain
Top.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingMain = true
		dragStartMain = input.Position
		startPosMain = Main.Position
	end
end)
UIS.InputChanged:Connect(function(input)
	if draggingMain and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStartMain
		Main.Position = UDim2.new(
			startPosMain.X.Scale,
			startPosMain.X.Offset + delta.X,
			startPosMain.Y.Scale,
			startPosMain.Y.Offset + delta.Y
		)
	end
end)
UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingMain = false end
end)

local draggingBtn, dragStartBtn, startPosBtn
OpenBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingBtn = true
		dragStartBtn = input.Position
		startPosBtn = OpenBtn.Position
	end
end)
UIS.InputChanged:Connect(function(input)
	if draggingBtn and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStartBtn
		OpenBtn.Position = UDim2.new(
			startPosBtn.X.Scale,
			startPosBtn.X.Offset + delta.X,
			startPosBtn.Y.Scale,
			startPosBtn.Y.Offset + delta.Y
		)
	end
end)
UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingBtn = false end
end)
