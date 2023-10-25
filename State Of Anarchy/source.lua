-- // Script made by #tupsutumppu / PASTER | 13.8.2023
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Camera = Workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Mouse = LocalPlayer:GetMouse()

--UI Library (Linoria OF COURSE) --Theme is made by this dude (https://v3rmillion.net/member.php?action=profile&uid=2974593)
local repo = 'https://raw.githubusercontent.com/wally-rblx/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet('https://raw.githubusercontent.com/Kiriko-Protection/Utilities/main/Neverlose.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({
   Title = "State Of Anarchy GUI",
   Center = true,
   AutoShow = true,
})

local Tabs = {
   Main = Window:AddTab('Main'),
   ['UI Settings'] = Window:AddTab('UI Settings'),
}

local SilentAimLeft = Tabs.Main:AddLeftGroupbox("Silent Aim")
local ESPRight = Tabs.Main:AddRightGroupbox("ESP")

local CombatSettings = {
    SilentAim = false,
}
local FOVCircleSettings = {
    CircleSides = 64,
    CircleColor = Color3.fromRGB(255,255,255),
    CircleTransparency = 1,
    CircleRadius = 75,
    CircleFilled = false,
    CircleVisible = false,
}

--ESP
local ESPSettings = {
    --Box ESP
    Boxes = false,
    BoxesOutline = false,
    BoxesThickness = 2,
    BoxesOutlineThickness = 3,
    BoxesTransparency = 1,
    BoxesFilled = false,
    --Trace ESP
    Tracers = false,
    TracersFrom = 1, -- 1 = Bottom, 2 = Middle
    TracersOutline = false,
    TracersThickness = 2,
    TracersOutlineThickness = 3,
    TracersTransparency = 1,
    --Name ESP
    Names = false,
    NamesFont = 1,
    NamesSize = 13,
    NamesCenter = true,
    NamesOutline = true,
    --Distance ESP
    Distances = false,
    DistancesFont = 1,
    DistancesSize = 13,
    DistancesCenter = true,
    DistancesOutline = true,
}
local ColorSettings = {
    Team = {
        Boxes = Color3.fromRGB(255, 255, 255),
        Tracers = Color3.fromRGB(255, 255, 255),
        Names = Color3.fromRGB(255, 255, 255),
        Distance = Color3.fromRGB(255, 255, 255),
        --Outlines
        BoxesOutline = Color3.fromRGB(0, 0, 0),
        TracersOutline = Color3.fromRGB(0, 0, 0),
        NamesOutline = Color3.fromRGB(0, 0, 0),
        DistancesOutline = Color3.fromRGB(0, 0, 0),
    },
    Enemy = {
        Boxes = Color3.fromRGB(255, 255, 255),
        Tracers = Color3.fromRGB(255, 255, 255),
        Names = Color3.fromRGB(255, 255, 255),
        Distance = Color3.fromRGB(255, 255, 255),
        --Outlines
        BoxesOutline = Color3.fromRGB(0, 0, 0),
        TracersOutline = Color3.fromRGB(0, 0, 0),
        NamesOutline = Color3.fromRGB(0, 0, 0),
        DistancesOutline = Color3.fromRGB(0, 0, 0),
    }
}
local drawings = {}
local GetName = function(model)
    return model.Name
end
-- Why pcall? (There was some weird ass error message from this function when you execute the script.)
local CreateESP = function(model) pcall(function()
        local draw = {
            BoxOutline = Drawing.new("Quad"), {
                Thickness = ESPSettings.BoxesOutlineThickness,
                Filled = false,
                Transparency = ESPSettings.BoxesOutlineTransparency,
                Color = Color3.fromRGB(0, 0, 0),
                Visible = false,
                ZIndex = 1
            },
            Box = Drawing.new("Quad"), {
                Thickness = ESPSettings.BoxesThickness,
                Filled = ESPSettings.BoxesFilled,
                Transparency = ESPSettings.BoxesTransparency,
                Color = Color3.fromRGB(0, 0, 0),
                Visible = false,
                ZIndex = 2
            },
            TraceOutline = Drawing.new("Line"), {
                Thickness = ESPSettings.TracersOutlineThickness,
                Color = Color3.fromRGB(0, 0, 0),
                Transparency = ESPSettings.TracersOutlineTransparency,
                Visible = false,
                ZIndex = 1
            },
            Trace = Drawing.new("Line"), {
                Thickness = ESPSettings.TracersThickness,
                Color = Color3.fromRGB(0, 0, 0),
                Transparency = ESPSettings.TracersTransparency,
                Visible = false,
                ZIndex = 2
            },
            Name = Drawing.new("Text"), {
                Text = "nil",
                Color = Color3.fromRGB(0, 0, 0),
                Font = ESPSettings.NamesFont,
                Size = ESPSettings.NamesSize,
                Center = ESPSettings.NamesCenter,
                Outline = ESPSettings.NamesOutline,
                OutlineColor = Color3.fromRGB(0, 0, 0)
            },
            Distance = Drawing.new("Text"), {
                Text = "nil",
                Color = Color3.fromRGB(0, 0, 0),
                Font = ESPSettings.DistancesFont,
                Size = ESPSettings.DistancesSize,
                Center = ESPSettings.DistancesCenter,
                Outline = ESPSettings.DistancesOutline,
                OutlineColor = Color3.fromRGB(0, 0, 0)
            },
        }
        drawings[model] = draw
    end)
end
local RemoveESP = function(model)
    table.foreach(drawings, function(i,v)
        if i == model then
            v.BoxOutline:Remove()
            v.Box:Remove()
            v.Trace:Remove()
            v.TraceOutline:Remove()
            v.Name:Remove()
            v.Distance:Remove()
            drawings[i] = nil
            return
        end
    end)
end
local UpdateESP = function()
    table.foreach(drawings, function(i,v)
        local Character = i
        if Character and Character:FindFirstChild("HumanoidRootPart") and Players:FindFirstChild(Character.Name) then
            local TeamSettings
            if Players[Character.Name].Team == LocalPlayer.Team then
                TeamSettings = ColorSettings.Team
            else
                TeamSettings = ColorSettings.Enemy
            end
            local ForceTeamColor = ESPSettings.UseTeamColors
            local HumanoidRootPart = Character.HumanoidRootPart

            local TL = Camera:WorldToViewportPoint(HumanoidRootPart.CFrame * CFrame.new(-3,3,0).p)
            local TR = Camera:WorldToViewportPoint(HumanoidRootPart.CFrame * CFrame.new(3,3,0).p)
            local BL = Camera:WorldToViewportPoint(HumanoidRootPart.CFrame * CFrame.new(-3,-3,0).p)
            local BR = Camera:WorldToViewportPoint(HumanoidRootPart.CFrame * CFrame.new(3,-3,0).p)

            local TracerPosX, TracerPosY = (BL.X + BR.X) / 2, (BL.Y + BR.Y) / 2
            local NamePosX, NamePosY = (TL.X + TR.X) / 2, (TL.Y + TR.Y) / 2

            local Pos, OnScreen = Camera:WorldToViewportPoint(HumanoidRootPart.CFrame.Position)
            if OnScreen and Character ~= nil then
                --Boxes
                if ESPSettings.Boxes then
                    --Outline
                    v.BoxOutline.PointA = Vector2.new(TR.X, TR.Y)
                    v.BoxOutline.PointB = Vector2.new(TL.X, TL.Y)
                    v.BoxOutline.PointC = Vector2.new(BL.X, BL.Y)
                    v.BoxOutline.PointD = Vector2.new(BR.X, BR.Y)
                    v.BoxOutline.Color = TeamSettings.BoxesOutline
                    v.BoxOutline.Thickness = ESPSettings.BoxesThickness + 1.5
                    v.BoxOutline.Transparency = ESPSettings.BoxesTransparency
                    v.BoxOutline.Visible = ESPSettings.BoxesOutline
                    --Box
                    v.Box.PointA = v.BoxOutline.PointA
                    v.Box.PointB = v.BoxOutline.PointB
                    v.Box.PointC = v.BoxOutline.PointC
                    v.Box.PointD = v.BoxOutline.PointD
                    v.Box.Color = TeamSettings.Boxes
                    v.Box.Thickness = ESPSettings.BoxesThickness
                    v.Box.Transparency = ESPSettings.BoxesTransparency
                    v.Box.Filled = ESPSettings.BoxesFilled
                    v.Box.Visible = true
                else
                    v.BoxOutline.Visible = false
                    v.Box.Visible = false
                end
                --Tracers
                if ESPSettings.Tracers then
                    v.TraceOutline.Thickness = ESPSettings.TracersThickness + 1.5
                    v.TraceOutline.Color = TeamSettings.TracersOutline
                    v.TraceOutline.Transparency = ESPSettings.TracersTransparency
                    v.TraceOutline.Visible = ESPSettings.TracersOutline
                    v.TraceOutline.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / ESPSettings.TracersFrom)
                    v.TraceOutline.To = Vector2.new(TracerPosX, TracerPosY)

                    v.Trace.Thickness = ESPSettings.TracersThickness
                    v.Trace.Color = TeamSettings.Tracers
                    v.Trace.Transparency = ESPSettings.TracersTransparency
                    v.Trace.Visible = true
                    v.Trace.From = v.TraceOutline.From
                    v.Trace.To = v.TraceOutline.To
                else
                    v.Trace.Visible = false
                    v.TraceOutline.Visible = false
                end
                --Names
                if ESPSettings.Names then
                    v.Name.Text = Character.Name
                    v.Name.Color = TeamSettings.Names
                    v.Name.Font = ESPSettings.NamesFont
                    v.Name.Size = ESPSettings.NamesSize
                    v.Name.Center = ESPSettings.NamesCenter
                    v.Name.Outline = ESPSettings.NamesOutline
                    v.Name.OutlineColor = TeamSettings.NamesOutline
                    v.Name.Position = Vector2.new(NamePosX, NamePosY - 27)
                    v.Name.Visible = true
                else
                    v.Name.Visible = false
                    v.Name.Outline = false
                end
                --Distance
                if ESPSettings.Distances then
                    v.Distance.Text = tostring(math.floor((LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame.Position - HumanoidRootPart.CFrame.Position).Magnitude)) .. " studs"
                    v.Distance.Color = TeamSettings.Distance
                    v.Distance.Font = ESPSettings.DistancesFont
                    v.Distance.Size = ESPSettings.DistancesSize
                    v.Distance.Center = ESPSettings.DistancesCenter
                    v.Distance.Outline = ESPSettings.DistancesOutline
                    v.Distance.OutlineColor = TeamSettings.DistancesOutline
                    v.Distance.Position = Vector2.new(NamePosX, NamePosY - 15)
                    v.Distance.Visible = true
                else
                    v.Distance.Visible = false
                    v.Distance.Outline = false
                end
            else
                v.BoxOutline.Visible = false
                v.Box.Visible = false
                v.Trace.Visible = false
                v.TraceOutline.Visible = false
                v.Name.Visible = false
                v.Name.Outline = false
                v.Distance.Visible = false
                v.Distance.Outline = false
            end
        end
    end)
end
table.foreach(Workspace.Players:GetChildren(), function(_,v)
    if v.Name ~= LocalPlayer.Name and v:IsA("Model") and not table.find(drawings, v) then
        CreateESP(v)
    end
end)

--Silent Aim
local Circle = Drawing.new("Circle")
Circle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

RunService.RenderStepped:Connect(function()
    UpdateESP()
    Circle.NumSides = FOVCircleSettings.CircleSides
    Circle.Color = FOVCircleSettings.CircleColor
    Circle.Transparency = FOVCircleSettings.CircleTransparency
    Circle.Radius = FOVCircleSettings.CircleRadius
    Circle.Filled = FOVCircleSettings.CircleFilled
    Circle.Visible = FOVCircleSettings.CircleVisible
    Circle.Thickness = 0
end)
local getclosest = function()
    local closest = nil
    local maxDist = math.huge
    table.foreach(Workspace.Players:GetChildren(), function(_,v)
        if v.Name ~= LocalPlayer.Name and v:FindFirstChild("HumanoidRootPart") then
            local HRP = v.HumanoidRootPart
            local HRPV3 = HRP.Position
            local HRPV2, isVisible = Camera:WorldToScreenPoint(HRPV3)
            HRPV2 = Vector2.new(HRPV2.X, HRPV2.Y)
            if isVisible then
                local distance = (HRPV2 - (Camera.ViewportSize / 2)).Magnitude
                if distance < FOVCircleSettings.CircleRadius then
                    local dist = (Workspace.Players[LocalPlayer.Name]:FindFirstChild("HumanoidRootPart").Position - HRP.Position).Magnitude
                    if dist < maxDist then
                        closest = v
                        maxDist = dist
                    end
                end
            end
        end
    end)
    if closest ~= nil then
        return closest
    end
end
local hookbullet = function()
    warn("Hooked new function... if you dont see this message after dying please note that silent aim might not work.")
    table.foreach(getgc(), function(i, v)
        if type(v) == "function" and getinfo(v).name == "new" and tostring(getfenv(v).script) == "BulletModule" then
            local old
            old = hookfunction(v, function(...)
                local args = {...}
                if CombatSettings.SilentAim then
                    local entity = getclosest()
                    local head = entity and entity:FindFirstChild("Head")
                    local tpos = head and head.Position or args[1]
                    args[1] = tpos
                    return old(unpack(args))
                end
                return old(...)
            end)
        end
    end)
end
Workspace.Players.ChildAdded:Connect(function(child)
    if child.Name ~= LocalPlayer.Name and child:IsA("Model") then
        CreateESP(child)
    elseif child:IsA("Model") and child.Name == LocalPlayer.Name then
        task.wait(2)
        hookbullet()
    end
end)
Players.PlayerRemoving:Connect(function(child)
    table.foreach(drawings, function(i,v)
        if i.Name == child.Name then
            RemoveESP(i)
        end
    end)
end)
Players.PlayerAdded:Connect(function(child)
    local secs = 0
    repeat
        task.wait(1)
        secs = secs + 1
    until Workspace.Players:FindFirstChild(child.Name) or secs == 20
    if Workspace.Players:FindFirstChild(child.Name) then CreateESP(Workspace.Players:FindFirstChild(child.Name)) end
end)

table.foreach(getgc(), function(i,v)
    if type(v) == "function" and tostring(getfenv(v).script) == "ChatHandler" and getinfo(v).name == "createMessage" then
        local chatold; chatold = hookfunction(v, function(...)
            local whatareyoulookingfor = {...}
            chatold(...)
            --Hi stranger :)
            --Again some weird ass error message "Argument 1 missing or nil".
            pcall(function()
                if whatareyoulookingfor[1] ~= nil then
                    local msg = whatareyoulookingfor[2]
                    local shooter = tostring(msg):split(" ")[1]
                    local died = tostring(msg):split(" ")[3]
                    if shooter ~= nil and died ~= nil and tostring(msg):lower():find("shot") then
                        table.foreach(drawings, function(i,_)
                            if tostring(i.Name) == died then
                                RemoveESP(i)
                            end
                        end)
                    end
                end
            end)
        end)
    end
end)
--UI Library Stuff

SilentAimLeft:AddToggle("SilentAimToggle", {
    Text = "Enabled",
    Default = false,
    Tooltip = "Enable/Disable Silent Aim",
    Callback = function(Value)
        CombatSettings.SilentAim = Value
    end
})
SilentAimLeft:AddDivider()
SilentAimLeft:AddToggle("FOVCIRCLETOGGLE", {
    Text = "Show FOV Circle",
    Default = false,
    Tooltip = "Show/Hide FOV CIRCLE",
    Callback = function(Value)
        print(Value)
        FOVCircleSettings.CircleVisible = Value
    end
})
SilentAimLeft:AddSlider("FOV Radius", {
    Text = "Radius",
    Default = 100,
    Min = 20,
    Max = 800,
    Rounding = 1,
    Compact = false,
    Callback = function(Value)
        FOVCircleSettings.CircleRadius = Value
    end
})
SilentAimLeft:AddSlider("FOV Transparency", {
    Text = "Transparency",
    Default = 1,
    Min = 0,
    Max = 1,
    Rounding = 1,
    Compact = false,
    Callback = function(Value)
        FOVCircleSettings.CircleTransparency = Value
    end
})
SilentAimLeft:AddLabel("Color"):AddColorPicker("FOVCircleColor", {
    Default = Color3.new(1, 1, 1),
    Title = 'Some color',
})
Options.FOVCircleColor:OnChanged(function(a)
    FOVCircleSettings.CircleColor = a
end)

ESPRight:AddToggle("BoxESP", {
    Text = "Box",
    Default = false,
    Tooltip = "Enable/Disable Box ESP",
    Callback = function(Value)
        ESPSettings.Boxes = Value
    end
})
ESPRight:AddToggle("BoxESPOutline", {
    Text = "Box Outline",
    Default = false,
    Tooltip = "Enable/Disable Box Outline",
    Callback = function(Value)
        ESPSettings.BoxesOutline = Value
    end
})
ESPRight:AddToggle("BoxESPFilled", {
    Text = "Box Filled",
    Default = false,
    Tooltip = "Enable/Disable Box Fill",
    Callback = function(Value)
        ESPSettings.BoxesFilled = Value
    end
})
ESPRight:AddSlider("BoxThickness", {
    Text = "Box Thickness",
    Default = 2,
    Min = 0,
    Max = 3,
    Rounding = 1,
    Compact = false,
    Callback = function(Value)
        ESPSettings.BoxesThickness = Value
    end
})
ESPRight:AddSlider("BoxTransparency", {
    Text = "Box Transparency",
    Default = 1,
    Min = 0,
    Max = 1,
    Rounding = 1,
    Compact = false,
    Callback = function(Value)
        ESPSettings.BoxesTransparency = Value
    end
})
ESPRight:AddLabel("Box Color"):AddColorPicker("BOXCOLOR", {
    Default = Color3.new(1, 1, 1),
    Title = 'Some color',
})
Options.BOXCOLOR:OnChanged(function(a)
    ColorSettings.Team.Boxes = a
    ColorSettings.Enemy.Boxes = a
end)
ESPRight:AddDivider()
ESPRight:AddToggle("TraceESP", {
    Text = "Trace",
    Default = false,
    Tooltip = "Enable/Disable Trace ESP",
    Callback = function(Value)
        ESPSettings.Tracers = Value
    end
})
ESPRight:AddToggle("TraceESPOutline", {
    Text = "Trace Outline",
    Default = false,
    Tooltip = "Enable/Disable Trace Outline",
    Callback = function(Value)
        ESPSettings.TracersOutline = Value
    end
})
ESPRight:AddSlider("TraceThickness", {
    Text = "Trace Thickness",
    Default = 2,
    Min = 0,
    Max = 3,
    Rounding = 1,
    Compact = false,
    Callback = function(Value)
        ESPSettings.TracersThickness = Value
    end
})
ESPRight:AddSlider("TraceTransparency", {
    Text = "Trace Transparency",
    Default = 1,
    Min = 0,
    Max = 1,
    Rounding = 1,
    Compact = false,
    Callback = function(Value)
        ESPSettings.TracersTransparency = Value
    end
})
ESPRight:AddLabel("Trace Color"):AddColorPicker("TRACECOLOR", {
    Default = Color3.new(1, 1, 1),
    Title = 'Some color',
})
Options.TRACECOLOR:OnChanged(function(a)
    ColorSettings.Team.Tracers = a
    ColorSettings.Enemy.Tracers = a
end)
ESPRight:AddDivider()
ESPRight:AddToggle("NameESP", {
    Text = "Name",
    Default = false,
    Tooltip = "Enable/Disable Name ESP",
    Callback = function(Value)
        ESPSettings.Names = Value
    end
})
ESPRight:AddToggle("NameOutline", {
    Text = "Name Outline",
    Default = false,
    Tooltip = "Enable/Disable Name Outline",
    Callback = function(Value)
        ESPSettings.NamesOutline = Value
    end
})
ESPRight:AddSlider("NameSize", {
    Text = "Name Size",
    Default = 13,
    Min = 4,
    Max = 15,
    Rounding = 1,
    Compact = false,
    Callback = function(Value)
        ESPSettings.NamesSize = Value
    end
})
ESPRight:AddLabel("Name Color"):AddColorPicker("NAMECOLOR", {
    Default = Color3.new(1, 1, 1),
    Title = 'Some color',
})
Options.NAMECOLOR:OnChanged(function(a)
    ColorSettings.Team.Names = a
    ColorSettings.Enemy.Names = a
end)
ESPRight:AddDivider()
ESPRight:AddToggle("DistanceESP", {
    Text = "Distance",
    Default = false,
    Tooltip = "Enable/Disable Distance ESP",
    Callback = function(Value)
        ESPSettings.Distances = Value
    end
})
ESPRight:AddToggle("DistanceOutline", {
    Text = "Distance Outline",
    Default = false,
    Tooltip = "Enable/Disable Distance Outline",
    Callback = function(Value)
        ESPSettings.DistancesOutline = Value
    end
})
ESPRight:AddSlider("DistanceSize", {
    Text = "Distance Size",
    Default = 13,
    Min = 4,
    Max = 15,
    Rounding = 1,
    Compact = false,
    Callback = function(Value)
        ESPSettings.DistancesSize = Value
    end
})
ESPRight:AddLabel("Distance Color"):AddColorPicker("DISTANCECOLOR", {
    Default = Color3.new(1, 1, 1),
    Title = 'Some color',
})
Options.DISTANCECOLOR:OnChanged(function(a)
    ColorSettings.Team.Distance = a
    ColorSettings.Enemy.Distance = a
end)
hookbullet()

-- UI Settings
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')
MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' })
Library.ToggleKeybind = Options.MenuKeybind
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })
ThemeManager:SetFolder('MyScriptHub')
SaveManager:SetFolder('MyScriptHub/specific-game')
SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])
