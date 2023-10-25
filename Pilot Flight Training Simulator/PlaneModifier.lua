-- // Script made by #tupsutumppu / PASTER | Updated: 27.9.2023 | Created: 16.6.2023
local DiscordLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/discord%20lib.txt"))()
local win = DiscordLib:Window("PTFS Plane Speed Modifier")
local serv = win:Server("super op script", "")
local maxSpeedChannel = serv:Channel("Max Speed")
local accelerationChannel = serv:Channel("Acceleration")

local function mod(target, value)
    local senv = getsenv(game:GetService("Players").LocalPlayer.Character.Control)
    local fenv = senv.SetupData

    if (senv and fenv) then
        local upvals = debug.getupvalues(fenv)
        debug.setupvalue(fenv, target, value)
    end
end

maxSpeedChannel:Textbox("MaxSpeed", "Type here!", true, function(text)
    if tonumber(text) then
        mod(4, tonumber(text))
    end
end)

accelerationChannel:Textbox("Acceleration", "Type here!", true, function(text)
    if tonumber(text) then
        mod(35, tonumber(text))
    end
end)
