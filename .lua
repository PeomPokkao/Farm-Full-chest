local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()

local Window = Library.CreateLib("Poom Edit", "Synapse")

local Tab1 = Window:NewTab("TabName ")

local Section9 = Tab1:NewSection("Dark Coat")

Section9:NewLabel("Status : N/A")

Section9:NewToggle("Farm Darkcoat", "ToggleInfo", function(state)
    if state then
        print("Toggle On")
    else
        print("Toggle Off")
    end
end)

local Section67 = Tab1:NewSection("Server")

Section67:NewButton("Hop Server", "ButtonInfo", function()
    print("Clicked")
end)

Section67:NewToggle("Hop Low Player", "ToggleInfo", function(state)
    if state then
        print("Toggle On")
    else
        print("Toggle Off")
    end
end)

Section67:NewLabel("Status : N/A")
