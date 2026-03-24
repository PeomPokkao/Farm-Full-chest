_G.AutoRedeem = true

local RS = game:GetService("ReplicatedStorage")

local Codes = {
"ADMINFIGHT",
"GIFTING_HOURS",
"EARN_FRUITS",
"FIGHT4FRUIT",
"NOEXPLOITER",
"ADMINHACKED",
"NOOB2ADMIN",
"CODESLIDE",
"ADMINDARES",
"fruitconcepts",
"krazydares",
"TRIPLEABUSE",
"SEATROLLING",
"24NOADMIN",
"REWARDFUN",
"NEWTROLL",
"SECRET_ADMIN",
"ADMIN_TROLL",
"youtuber_shipbattle",
"STAFFBATTLE",
"ADMIN_STRENGTH",
"JULYUPDATE_RESET",
"DRAGONABUSE",
"NOOB2PRO",
"CINCODEMAYO_BOOST",
"Noob_Refund",
"CODE_SERVICIO",
"DEVSCOOKING",
"TY_FOR_WATCHING",
"GAMERROBOT_YT",
"GAMER_ROBOT_1M",
"EXP_5B",
"RESET_5B",
"1MLIKES_RESET",
"THIRDSEA",
"1BILLION",
"2BILLION",
"3BVISITS",
"Update10",
"Update11",
"UPD14",
"UPD15",
"UPD16",
"ShutDownFix2",
"XmasExp",
"XmasReset",
"PointsReset",
"Control",
"NOMOREHACK",
"BANEXPLOIT"
}

task.spawn(function()
    for _,code in pairs(Codes) do
        if not _G.AutoRedeem then break end

        pcall(function()
            print("กำลังใช้โค้ด:", code)

            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Redeem", code)

            task.wait(0.5)
        end)
    end

    print("✅ ใช้โค้ดครบแล้ว")
end)
