-- // Script made by #tupsutumppu / PASTER | 20.7.2023
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Ui Library (Linoria)
local repo = 'https://raw.githubusercontent.com/wally-rblx/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local Window = Library:CreateWindow({
    Title = "Flag Wars GUI",
    Center = true, 
    AutoShow = true,
})

--Tabs
local Tabs = {
    -- Creates a new tab titled Main
    Main = Window:AddTab("Main"),
    UI = Window:AddTab("UI")
}

--Groupboxes
local silentAim = Tabs.Main:AddLeftGroupbox("Silent Aim")
local gunMods = Tabs.Main:AddLeftGroupbox("Gun Mods")
local playerESP = Tabs.Main:AddRightGroupbox("Player ESP")
local MenuGroupLeft = Tabs.UI:AddRightGroupbox("UI Settings")

--Settings
local FOVCircleSettings = {
    CircleSides = 64,
    CircleColor = Color3.fromRGB(255,255,255),
    CircleTransparency = 0.7,
    CircleRadius = 75,
    CircleFilled = false,
    CircleVisible = false,
}

local ESPSettings = {
    Boxes = false,
    BoxOutline = true,
    BoxOutlineThickness = 2,
    BoxOutlineColor = Color3.fromRGB(0,0,0),
    BoxThickness = 1,
    BoxColor = Color3.fromRGB(0,255,0),
    EnemyBoxColor = Color3.fromRGB(255,0,0)
}

local CombatSettings = {
    SilentAim = false,
    InfAmmo = false,
}
--Functions
local Circle = Drawing.new("Circle")
local function changeCircle()
    Circle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    Circle.NumSides = FOVCircleSettings.CircleSides
    Circle.Color = FOVCircleSettings.CircleColor
    Circle.Transparency = FOVCircleSettings.CircleTransparency
    Circle.Radius = FOVCircleSettings.CircleRadius
    Circle.Filled = FOVCircleSettings.CircleFilled
    Circle.Visible = FOVCircleSettings.CircleVisible
    Circle.Thickness = 0
end
--Silent aim
local function getDirection(arguments)
    if CombatSettings.SilentAim then
        local tableArgs = arguments
        local TipAttachment = tableArgs.tipAttach
        if TipAttachment then
            TipAttachment = TipAttachment.WorldCFrame.Position
            local closest = nil
            local maxDist = math.huge
            local AimPos;
    
            for _,v in pairs(Players:GetPlayers()) do
                if v ~= LocalPlayer and v.Team ~= LocalPlayer.Team and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
                    local HRP = v.Character:FindFirstChild("Head")
                    local HRPV3 = HRP.Position
                    local HRPV2, isVisible = Camera:WorldToScreenPoint(HRPV3)
                    HRPV2 = Vector2.new(HRPV2.X, HRPV2.Y)
    
                    if isVisible then
                        local distance = (HRPV2 - (Camera.ViewportSize / 2)).Magnitude
                        if distance < FOVCircleSettings.CircleRadius then
                            local dist = (LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position - HRP.Position).Magnitude
                            if dist < maxDist then
                                closest = v
                                maxDist = dist
                            end
                        end
                    end
                end
            end
            if closest ~= nil and closest.Character ~= nil then
                AimPos = (closest.Character:FindFirstChild("Head").Position - TipAttachment).Unit
                return AimPos
            end
            return nil
        end
    end
end
for i,v in pairs(getgc()) do
    if type(v) == "function" and getinfo(v).name == "fire" then
        local silentAim; silentAim = hookfunction(v, function(...)
            local args = {...}
            local isPossible = getDirection(args[1])
            if CombatSettings.SilentAim and isPossible ~= nil then
                args[3] = isPossible
                return silentAim(unpack(args))
            else
                return silentAim(...)
            end
        end)
    end
end
local stuff0 = {}
local stuffhuge = {}
local gunHook; gunHook = hookmetamethod(game, "__index", newcclosure(function(key, value)
    if not checkcaller() and value == "Value" then
        if table.find(stuff0, tostring(key)) then
            return 0
        elseif table.find(stuffhuge, tostring(key)) then
            return math.huge
        end
    end
    return gunHook(key, value)
end))
for i,v in pairs(getgc()) do
    if type(v) == "function" and debug.getinfo(v).name == "useAmmo" then
        local hook; hook = hookfunction(v, function(...)
            if CombatSettings.InfAmmo then
                return 1
            else
                return hook(...)
            end
        end)
    end
end
--ESP
local PlayerESP = {}
function CreateESP(player)
    local draw = {
        BoxOutline = Drawing.new("Square"), {
            Thickness = 2,
            Filled = false,
            Transparency = 1,
            Color = Color3.fromRGB(0,0,0),
            Visible = false,
            ZIndex = 1,
            Visible = false
        },
        Box = Drawing.new("Square"), {
            Thickness = 1,
            Filled = false,
            Transparency = 1,
            Color = ESPSettings.BoxColor,
            Visible = false,
            ZIndex = 2,
            Visible = false
        },
    }
    PlayerESP[player] = draw
end
function RemoveESP(model)
    for i, v in pairs(PlayerESP) do
        if i.Name == model.Name then
            if type(v) ~= "table" then
                v:Remove()
            end
            PlayerESP[i] = nil
            return
        end
    end
end
local function UpdatePlayerESP()
    for i,v in pairs(PlayerESP) do
        local Character = i
        local color;
        local playerFound = Players:FindFirstChild(i.Name)
        if Character ~= nil and playerFound then
            if playerFound.Team == LocalPlayer.Team then
                color = ESPSettings.BoxColor
            else
                color = ESPSettings.EnemyBoxColor
            end
            local Position, OnScreen = Camera:WorldToViewportPoint(Character:GetPivot().Position)
            if OnScreen and Character:FindFirstChild("HumanoidRootPart") and Character:FindFirstChild("Head") and Character:FindFirstChild("Humanoid") and Character.Humanoid.Health > 0 then
                local RootPart = Character.HumanoidRootPart
                local Head = Character.Head
                local RootPos = Camera.WorldToViewportPoint(Camera, RootPart.CFrame.Position)
                local HeadPos = Camera.WorldToViewportPoint(Camera, Head.CFrame.Position + Vector3.new(0, 0.5, 0))
                local LegPos = Camera.WorldToViewportPoint(Camera, RootPart.CFrame.Position - Vector3.new(0, 3, 0))
    
                if ESPSettings.Boxes then
                    v.BoxOutline.Size = Vector2.new(2000 / RootPos.Z, HeadPos.Y - LegPos.Y)
                    v.BoxOutline.Position = Vector2.new(RootPos.X - v.BoxOutline.Size.X / 2, RootPos.Y - v.BoxOutline.Size.Y / 2)
                    v.BoxOutline.Color = ESPSettings.BoxOutlineColor
                    v.BoxOutline.Thickness = ESPSettings.BoxOutlineThickness
                    v.BoxOutline.Visible = ESPSettings.BoxOutline
    
                    v.Box.Size = Vector2.new(2000 / RootPos.Z, HeadPos.Y - LegPos.Y)
                    v.Box.Position = Vector2.new(RootPos.X - v.Box.Size.X / 2, RootPos.Y - v.Box.Size.Y / 2)
                    v.Box.Color = color
                    v.Box.Thickness = ESPSettings.BoxThickness
                    v.Box.Visible = ESPSettings.Boxes
                else
                    v.BoxOutline.Visible = false
                    v.Box.Visible = false
                end
            else
                v.BoxOutline.Visible = false
                v.Box.Visible = false
            end
        else
            v.BoxOutline.Visible = false
            v.Box.Visible = false
            RemoveESP(i)
        end
    end
end
RunService.RenderStepped:Connect(UpdatePlayerESP)
for _,v in pairs(Workspace:GetChildren()) do
    if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and Players[v.Name] and v.Name ~= LocalPlayer.Name then
        CreateESP(v)
    end
end
Workspace.ChildAdded:Connect(function(model)
    if model:IsA("Model") and Players[model.Name] and model.Name ~= LocalPlayer.Name and not table.find(PlayerESP, model) then
        CreateESP(model)
    end
end)

--Ui Library Buttons, Toggles & etc
silentAim:AddToggle("SilentAimToggle", {
    Text = "Enabled",
    Default = false, -- Default value (true / false)
    Tooltip = "Enable/Disable Silent Aim", -- Information shown when you hover over the toggle
    Callback = function(Value)
        CombatSettings.SilentAim = Value
        FOVCircleSettings.CircleVisible = Value
        changeCircle()
    end
})
silentAim:AddDivider()
silentAim:AddSlider("FOV Radius", {
    Text = "FOV Circle Radius",
    Default = 100,
    Min = 20,
    Max = 800,
    Rounding = 1,
    Compact = false, -- If set to true, then it will hide the label
    Callback = function(Value)
        FOVCircleSettings.CircleRadius = Value
        changeCircle()
    end
})
silentAim:AddLabel("Color"):AddColorPicker("FOVCircleColor", {
    Default = Color3.new(0, 1, 0), -- Bright green
    Title = 'Some color', -- Optional. Allows you to have a custom color picker title (when you open it)
})
Options.FOVCircleColor:OnChanged(function()
    FOVCircleSettings.CircleColor = Options.FOVCircleColor.Value
    changeCircle()
end)

playerESP:AddToggle("PlayerESPBox", {
    Text = "Box",
    Default = false, -- Default value (true / false)
    Tooltip = "Enable/Disable BOX ESP", -- Information shown when you hover over the toggle
    Callback = function(Value)
        ESPSettings.Boxes = Value
    end
})
playerESP:AddDivider()
playerESP:AddToggle("BoxOutline", {
    Text = "Box Outline",
    Default = true, -- Default value (true / false)
    Tooltip = "Enable/Disable Box Outline", -- Information shown when you hover over the toggle
    Callback = function(Value)
        ESPSettings.BoxOutline = Value
    end
})
playerESP:AddLabel("Enemy Box Color"):AddColorPicker("EnemyBoxColor", {
    Default = Color3.new(1, 0, 0), -- Bright green
    Title = 'Enemy Box Color', -- Optional. Allows you to have a custom color picker title (when you open it)
})
Options.EnemyBoxColor:OnChanged(function()
    ESPSettings.EnemyBoxColor = Options.EnemyBoxColor.Value
end)
playerESP:AddLabel("Team Box Color"):AddColorPicker("TeamBoxColor", {
    Default = Color3.new(0, 1, 0), -- Bright green
    Title = 'Enemy Box Color', -- Optional. Allows you to have a custom color picker title (when you open it)
})
Options.TeamBoxColor:OnChanged(function()
    ESPSettings.BoxColor = Options.TeamBoxColor.Value
end)

gunMods:AddToggle("InfAmmo", {
    Text = "Infinite Ammo",
    Default = false, -- Default value (true / false)
    Tooltip = "Enable/Disable Inf Ammo", -- Information shown when you hover over the toggle
    Callback = function(Value)
        CombatSettings.InfAmmo = Value
    end
})
gunMods:AddToggle("NoRecoil", {
    Text = "No Recoil",
    Default = false, -- Default value (true / false)
    Tooltip = "Enable/Disable No Recoil", -- Information shown when you hover over the toggle
    Callback = function(Value)
        local recoilvalues = {
            "RecoilMin",
            "RecoilMax",
            "RecoilDecay",
            "TotalRecoilMax",
        }
        if Value then
            for _,v in pairs(recoilvalues) do
                table.insert(stuff0, v)
            end
        else
            for _,v in pairs(stuff0) do
                if table.find(recoilvalues, v) then
                    stuff0[v]:Remove()
                end
            end
        end
    end
})
gunMods:AddToggle("NoSpread", {
    Text = "No Spread",
    Default = false, -- Default value (true / false)
    Tooltip = "Enable/Disable No Spread", -- Information shown when you hover over the toggle
    Callback = function(Value)
        local spreadvalues = {
            "MaxSpread",
            "MinSpread",
        }
        if Value then
            for _,v in pairs(spreadvalues) do
                table.insert(stuff0, v)
            end
        else
            for _,v in pairs(stuff0) do
                if table.find(spreadvalues, v) then
                    stuff0[v]:Remove()
                end
            end
        end
    end
})
gunMods:AddToggle("RapidFire", {
    Text = "Rapid Fire",
    Default = false, -- Default value (true / false)
    Tooltip = "Enable/Disable Rapid Fire", -- Information shown when you hover over the toggle
    Callback = function(Value)
        local cooldownvalues = {
            "ShotCooldown",
            "HeadshotCooldown"
        }
        if Value then
            for _,v in pairs(cooldownvalues) do
                table.insert(stuff0, v)
            end
        else
            for _,v in pairs(stuff0) do
                if table.find(cooldownvalues, v) then
                    stuff0[v]:Remove()
                end
            end
        end
    end
})
gunMods:AddToggle("HeadShotDamage", {
    Text = "Headshot Damage",
    Default = false, -- Default value (true / false)
    Tooltip = "Enable/Disable Headshot Damage", -- Information shown when you hover over the toggle
    Callback = function(Value)
        local damagevalues = {
            "HeadshotDamage"
        }
        if Value then
            for _,v in pairs(damagevalues) do
                table.insert(stuffhuge, v)
            end
        else
            for _,v in pairs(stuffhuge) do
                if table.find(damagevalues, v) then
                    stuff0[v]:Remove()
                end
            end
        end
    end
})
gunMods:AddLabel("Reset to apply")
MenuGroupLeft:AddButton("Unload", function() Library:Unload() end) 
MenuGroupLeft:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "K", NoUI = true, Text = "Menu keybind" }) 
Library.ToggleKeybind = Options.MenuKeybind
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder('TridentSurvivalFREE')
ThemeManager:ApplyToTab(Tabs.UI)
