--// SERVICES
local Players = game:GetService("Players")
local player = Players.LocalPlayer

--// GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "MyAwesomeUI"

-- MAIN FRAME
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 600, 0, 350)
Main.Position = UDim2.new(0.5, -300, 0.5, -175)
Main.BackgroundColor3 = Color3.fromRGB(10,10,10)
Main.BorderSizePixel = 0

-- CORNER
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

-- HEADER
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1,0,0,40)
Header.BackgroundColor3 = Color3.fromRGB(0,0,0)
Header.BorderSizePixel = 0
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 12)

-- TITLE
local Title = Instance.new("TextLabel", Header)
Title.Text = "My Awesome GUI"
Title.Size = UDim2.new(0,200,1,0)
Title.Position = UDim2.new(0,10,0,0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(0,200,255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left

-- CLOSE BUTTON
local Close = Instance.new("TextButton", Header)
Close.Size = UDim2.new(0,30,0,30)
Close.Position = UDim2.new(1,-40,0.5,-15)
Close.Text = "X"
Close.BackgroundColor3 = Color3.fromRGB(255,80,80)
Close.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", Close)

Close.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- MINIMIZE BUTTON
local Min = Instance.new("TextButton", Header)
Min.Size = UDim2.new(0,30,0,30)
Min.Position = UDim2.new(1,-80,0.5,-15)
Min.Text = "-"
Min.BackgroundColor3 = Color3.fromRGB(255,200,80)
Min.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", Min)

local minimized = false
Min.MouseButton1Click:Connect(function()
    minimized = not minimized
    Main.Size = minimized and UDim2.new(0,600,0,40) or UDim2.new(0,600,0,350)
end)

-- SIDEBAR
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0,150,1,-40)
Sidebar.Position = UDim2.new(0,0,0,40)
Sidebar.BackgroundColor3 = Color3.fromRGB(15,15,15)
Sidebar.BorderSizePixel = 0

-- BUTTON FUNCTION
local function CreateTab(name, y)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(1,-20,0,40)
    btn.Position = UDim2.new(0,10,0,y)
    btn.Text = name
    btn.BackgroundColor3 = name == "Main" and Color3.fromRGB(0,170,200) or Color3.fromRGB(25,25,25)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    Instance.new("UICorner", btn)
    return btn
end

local MainTab = CreateTab("Main",10)
local SettingsTab = CreateTab("Settings",60)
local CreditsTab = CreateTab("Credits",110)

-- CONTENT
local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1,-160,1,-50)
Content.Position = UDim2.new(0,160,0,45)
Content.BackgroundTransparency = 1

-- PRINT BUTTON
local PrintBtn = Instance.new("TextButton", Content)
PrintBtn.Size = UDim2.new(1,0,0,40)
PrintBtn.Position = UDim2.new(0,0,0,0)
PrintBtn.Text = "Print Message"
PrintBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
PrintBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", PrintBtn)

PrintBtn.MouseButton1Click:Connect(function()
    print("Hello from UI!")
end)

-- TOGGLE
local ToggleFrame = Instance.new("Frame", Content)
ToggleFrame.Size = UDim2.new(1,0,0,40)
ToggleFrame.Position = UDim2.new(0,0,0,60)
ToggleFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
Instance.new("UICorner", ToggleFrame)

local ToggleText = Instance.new("TextLabel", ToggleFrame)
ToggleText.Text = "Toggle Something"
ToggleText.Size = UDim2.new(0.7,0,1,0)
ToggleText.BackgroundTransparency = 1
ToggleText.TextColor3 = Color3.new(1,1,1)
ToggleText.Font = Enum.Font.Gotham
ToggleText.TextSize = 14

local ToggleBtn = Instance.new("TextButton", ToggleFrame)
ToggleBtn.Size = UDim2.new(0,50,0,25)
ToggleBtn.Position = UDim2.new(1,-60,0.5,-12)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(80,80,80)
ToggleBtn.Text = ""
Instance.new("UICorner", ToggleBtn)

local ToggleCircle = Instance.new("Frame", ToggleBtn)
ToggleCircle.Size = UDim2.new(0,20,0,20)
ToggleCircle.Position = UDim2.new(0,2,0.5,-10)
ToggleCircle.BackgroundColor3 = Color3.new(1,1,1)
Instance.new("UICorner", ToggleCircle)

local toggled = false

ToggleBtn.MouseButton1Click:Connect(function()
    toggled = not toggled
    
    if toggled then
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0,170,200)
        ToggleCircle.Position = UDim2.new(1,-22,0.5,-10)
    else
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(80,80,80)
        ToggleCircle.Position = UDim2.new(0,2,0.5,-10)
    end
end)
