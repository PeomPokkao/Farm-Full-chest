--// SERVICES
local Players = game:GetService("Players")
local player = Players.LocalPlayer

--// DATA
local FightingStyles = {
    "Combat","Dark Step","Electric","Water Kung Fu","Dragon Breath",
    "Superhuman","Death Step","Sharkman Karate","Electric Claw",
    "Dragon Talon","Godhuman","Sanguine Art"
}

local Swords = {
    "Katana","Cutlass","Dual Katana","Triple Katana",
    "Shisui","Wando","Saddi","Yama","Tushita",
    "Cursed Dual Katana","Saber","Pole",
    "Midnight Blade","Rengoku","Dark Blade"
}

--// GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "ItemCheckerUI"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 350, 0, 400)
Main.Position = UDim2.new(0.5, -175, 0.5, -200)
Main.BackgroundColor3 = Color3.fromRGB(25,25,25)

-- Title
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1,0,0,40)
Title.Position = UDim2.new(0,0,0,0)
Title.Text = "Item Checker"
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundTransparency = 1
Title.TextScaled = true

-- Scroll
local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1,0,1,-80)
Scroll.Position = UDim2.new(0,0,0,40)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0,0,0,0)

-- Layout ใน Scroll
local List = Instance.new("UIListLayout", Scroll)

-- Refresh Button
local Refresh = Instance.new("TextButton", Main)
Refresh.Size = UDim2.new(1,0,0,40)
Refresh.Position = UDim2.new(0,0,1,-40)
Refresh.Text = "🔄 Refresh"
Refresh.BackgroundColor3 = Color3.fromRGB(40,40,40)
Refresh.TextColor3 = Color3.new(1,1,1)

--// FUNCTION เช็คของ
local function HasItem(name)
    local backpack = player:WaitForChild("Backpack")
    local character = player.Character or player.CharacterAdded:Wait()
    return backpack:FindFirstChild(name) or character:FindFirstChild(name)
end

--// CREATE ROW
local function CreateRow(text, has)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1,0,0,25)
    Label.BackgroundTransparency = 1
    Label.TextScaled = true

    if has then
        Label.Text = "✔ " .. text
        Label.TextColor3 = Color3.fromRGB(0,255,0)
    else
        Label.Text = "❌ " .. text
        Label.TextColor3 = Color3.fromRGB(255,0,0)
    end

    Label.Parent = Scroll
end

--// LOAD LIST
local function LoadItems()
    Scroll:ClearAllChildren()

    local List = Instance.new("UIListLayout")
    List.Parent = Scroll

    CreateRow("=== Fighting Styles ===", true)
    for _,v in pairs(FightingStyles) do
        CreateRow(v, HasItem(v))
    end

    CreateRow("=== Swords ===", true)
    for _,v in pairs(Swords) do
        CreateRow(v, HasItem(v))
    end

    task.wait()
    Scroll.CanvasSize = UDim2.new(0,0,0,List.AbsoluteContentSize.Y)
end

-- ปุ่ม Refresh
Refresh.MouseButton1Click:Connect(function()
    LoadItems()
end)

-- โหลดครั้งแรก
LoadItems()
