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
		if v:IsA("TouchTransmitter") and v.Parent:IsA("BasePart") then
			local chest = v.Parent
			local d = (chest.Position - hrp.Position).Magnitude
			-- ข้ามประตู / Dojo / Flamingo
			if d < dist and not chest:FindFirstChild("Door") then
				dist = d
				nearest = chest
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
			
			local tool = player.Backpack:FindFirstChild("Fist of Darkness")
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
			_G.DarkcoatStatus = "Idle"
		end
	end
end)

-------------------------------------------------
-- FLUENT UI
-------------------------------------------------
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Darkcoat Farm",
    SubTitle = "by Poom",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
	Main = Window:AddTab({ Title = "Main" }),
	Settings = Window:AddTab({ Title = "Settings" })
}

local Options = Fluent.Options

-- Status Labels
local StatusLabel = Tabs.Main:AddParagraph({Title = "Darkcoat Status", Content = _G.DarkcoatStatus})
local ServerLabel = Tabs.Main:AddParagraph({Title = "Server Status", Content = _G.ServerStatus})

task.spawn(function()
	while true do
		StatusLabel:SetContent(_G.DarkcoatStatus)
		ServerLabel:SetContent(_G.ServerStatus)
		if Fluent.Unloaded then break end
		task.wait(0.3)
	end
end)

-- Toggle Auto Darkcoat
local AutoDarkcoatToggle = Tabs.Main:AddToggle("AutoDarkcoat", {Title="Auto Darkcoat", Default = Config.AutoFarmDarkcoat})
AutoDarkcoatToggle:OnChanged(function(state)
	_G.AutoFarmDarkcoat = state
	Config.AutoFarmDarkcoat = state
	SaveConfig()
end)
AutoDarkcoatToggle:SetValue(Config.AutoFarmDarkcoat)

-- Hop Low Server Toggle
local HopLowToggle = Tabs.Main:AddToggle("HopLow", {Title="Hop Low Server", Default=false})
HopLowToggle:OnChanged(function(state)
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

-- Fluent SaveManager / InterfaceManager
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetFolder("DarkcoatFarm")
InterfaceManager:SetFolder("DarkcoatFarm")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
SaveManager:LoadAutoloadConfig()

Fluent:Notify({Title="Loaded", Content="Darkcoat Farm Script is ready!", Duration=6})
