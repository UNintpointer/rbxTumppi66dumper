-- // Services
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local virtualUser = game:GetService("VirtualUser")

-- // Other variables
local camera = workspace.CurrentCamera
local localPlayer = players.LocalPlayer
local espCache = {}
local closestDir = nil
local specateFrame = localPlayer.PlayerGui.MainGui.Spectate

-- // In game functions
local new_projectile = require(replicatedStorage:WaitForChild("GunSystem").GunSharedAssets.Projectile).New
local fire = require(replicatedStorage:WaitForChild("GunSystem").GunClientAssets.Modules.Gun).Fire

-- // UI Library Init (Linoria)
local repo = "https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local Window = Library:CreateWindow({
    Title = tostring(game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name) .. " |" .. " by #tupsutumppu / PASTER",
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})
local Tabs = {
    combat = Window:AddTab("Combat"),
    visuals = Window:AddTab("Visuals"),
    ["UI Settings"] = Window:AddTab("UI Settings")
}
local silentAim = Tabs.combat:AddLeftGroupbox("Silent Aim")
local triggerBot = Tabs.combat:AddRightGroupbox("Triggerbot")
local gunMods = Tabs.combat:AddRightGroupbox("Gun Mods")
local playerBox = Tabs.visuals:AddLeftGroupbox("box")
local playerTracer = Tabs.visuals:AddLeftGroupbox("Tracer")
local playerName = Tabs.visuals:AddRightGroupbox("Name")
local playerWeapon = Tabs.visuals:AddRightGroupbox("Weapon")

-- // Settings
local settings = {
    combat = {
        silentAim = false,
        hitPart = "Head",
        useFov = false,
        triggerBot = false,
        infiniteAmmo = false,
        noRecoil = false,
        rapidFire = false,
        fastReload = false,
        fovCircle = {
            enabled = false,
            sides = 64,
            color = Color3.fromRGB(255, 255, 255),
            transparency = 1,
            radius = 75,
            filled = false,
        }
    },
    esp = {
        box = {enabled = false, outline = false, thickness = 2, transparency = 1, filled = false, color = Color3.fromRGB(45, 255, 0), outlineColor = Color3.fromRGB(0, 0, 0)},
        tracer = {enabled = false, outline = false, thickness = 2, transparency = 1, color = Color3.fromRGB(0, 180, 255), outlineColor = Color3.fromRGB(0, 0, 0)},
        name = {enabled = false, font = 2, size = 13, center = true, outline = true, color = Color3.fromRGB(45, 255, 0), outlineColor = Color3.fromRGB(0, 0, 0)},
        weapon = {enabled = false , font = 2, size = 13, center = true, outline = true, color = Color3.fromRGB(0, 180, 255), outlineColor = Color3.fromRGB(0, 0, 0)}
    }
}

-- // Cheat functions
local function isNotSpectating()
    if specateFrame.Visible then
        return false
    end
    return true
end
local function getClosest()
    local closest = nil
    local maxDist = math.huge

    for _, player in pairs(workspace:GetChildren()) do
        if player:IsA("Model") and player.Name ~= localPlayer.Name and player:FindFirstChild(settings.combat.hitPart) then
            local pos = player[settings.combat.hitPart].CFrame.p
            local posv2, onScreen = camera:WorldToScreenPoint(pos)

            if onScreen then
                local distance = (Vector2.new(posv2.X, posv2.Y) - (camera.ViewportSize / 2)).Magnitude
                
                if distance < settings.combat.fovCircle.radius then
                    distance = (camera.CFrame.p - pos).Magnitude

                    if distance < maxDist then
                        closest = player
                        maxDist = distance
                    end
                end
            end
        end
    end

    if closest ~= nil then
        return closest
    end
end
runService.Heartbeat:Connect(function()
    if isNotSpectating() then
        local closest = getClosest()
        local localChar = localPlayer.Character
        local localHitBox = workspace.Hitboxes:FindFirstChild(localPlayer.Name)
        local hitPart = closest and closest:FindFirstChild(settings.combat.hitPart)
    
        if closest and localChar and localHitBox and hitPart then
            local screenPos = camera:WorldToScreenPoint(hitPart.CFrame.p)
            local rayDir = camera:ScreenPointToRay(screenPos.X, screenPos.Y).Direction
    
            local origin = camera.CFrame.p
            local destination = hitPart.CFrame.p
            local direction = destination - origin
            local params = RaycastParams.new()
            params.FilterDescendantsInstances = {camera, localChar, workspace.Hitboxes:FindFirstChild(localPlayer.Name)}
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.IgnoreWater = true
            result = workspace:Raycast(origin, direction, params)
    
            if result and result.Instance and (result.Instance:IsDescendantOf(workspace.Hitboxes:FindFirstChild(closest.Name)) or result.Instance:IsDescendantOf(closest)) then
                closestDir = rayDir
    
                if settings.combat.triggerBot and not closest:FindFirstChild("RoundForceField") then
                    virtualUser:Button1Down(Vector2.new(1000, 1000), camera.CFrame)
                    task.wait(0.05)
                    virtualUser:Button1Up(Vector2.new(1000, 1000), camera.CFrame)
    
                end
            else
                closestDir = nil
            end
        end
    end
end)

-- // ESP functions
local function newDrawing(player_model)
    local draw = {
        boxOutline = Drawing.new("Quad"), {
            Thickness = settings.esp.box.thickness + 1.5,
            Filled = settings.esp.box.filled,
            Transparency = settings.esp.box.transparency,
            Color = settings.esp.box.outlineColor,
            Visible = settings.esp.box.outline,
            ZIndex = 1
        },
        box = Drawing.new("Quad"), {
            Thickness = settings.esp.box.thickness,
            Filled = false,
            Transparency = settings.esp.box.transparency,
            Color = settings.esp.box.color,
            Visible = settings.esp.box.enabled,
            ZIndex = 2
        },
        traceOutline = Drawing.new("Line"), {
            Thickness = settings.esp.tracer.thickness + 1.5,
            Color = settings.esp.tracer.outlineColor,
            Transparency = settings.esp.tracer.transparency,
            Visible = false,
            ZIndex = 1
        },
        trace = Drawing.new("Line"), {
            Thickness = settings.esp.tracer.thickness,
            Color = settings.esp.tracer.color,
            Transparency = settings.esp.tracer.transparency,
            Visible = false,
            ZIndex = 2
        },
        name = Drawing.new("Text"), {
            Text = "nil",
            Color = settings.esp.name.color,
            Font = settings.esp.name.font,
            Size = settings.esp.name.size,
            Center = settings.esp.name.center,
            Outline = settings.esp.name.outline,
            OutlineColor = settings.esp.name.outlineColor
        },
        weapon = Drawing.new("Text"), {
            Text = "nil",
            Color = settings.esp.weapon.color,
            Font = settings.esp.weapon.font,
            Size = settings.esp.weapon.size,
            Center = settings.esp.weapon.center,
            Outline = settings.esp.weapon.outline,
            OutlineColor = settings.esp.weapon.outlineColor
        },
    }
    espCache[player_model] = draw
end
local function getWeapon(player_model)
    local weapon = player_model:FindFirstChildWhichIsA("Model")

    if weapon then
        return weapon.Name
    end
    return "No Weapon"
end
local function updateEsp()
    for i,v in pairs(espCache) do
        local character = i
        if character and character:FindFirstChild("HumanoidRootPart") and players:FindFirstChild(character.Name) then
            local humanoidRootPart = character.HumanoidRootPart
            local tL = camera:WorldToViewportPoint(humanoidRootPart.CFrame * CFrame.new(-3,3,0).p)
            local tR = camera:WorldToViewportPoint(humanoidRootPart.CFrame * CFrame.new(3,3,0).p)
            local bL = camera:WorldToViewportPoint(humanoidRootPart.CFrame * CFrame.new(-3,-3,0).p)
            local bR = camera:WorldToViewportPoint(humanoidRootPart.CFrame * CFrame.new(3,-3,0).p)
            local tracerPosX, tracerPosY = (bL.X + bR.X) / 2, (bL.Y + bR.Y) / 2
            local topPosX, topPosY = (tL.X + tR.X) / 2, (tL.Y + tR.Y) / 2
            local pos, onScreen = camera:WorldToViewportPoint(humanoidRootPart.CFrame.Position)

            if onScreen and character ~= nil then
                -- Boxes
                if settings.esp.box.enabled then
                    -- Outline
                    v.boxOutline.PointA = Vector2.new(tR.X, tR.Y)
                    v.boxOutline.PointB = Vector2.new(tL.X, tL.Y)
                    v.boxOutline.PointC = Vector2.new(bL.X, bL.Y)
                    v.boxOutline.PointD = Vector2.new(bR.X, bR.Y)
                    v.boxOutline.Color = settings.esp.box.outlineColor
                    v.boxOutline.Thickness = settings.esp.box.thickness + 1.5
                    v.boxOutline.Transparency = settings.esp.box.transparency
                    v.boxOutline.Visible = settings.esp.box.outline
                    -- box
                    v.box.PointA = v.boxOutline.PointA
                    v.box.PointB = v.boxOutline.PointB
                    v.box.PointC = v.boxOutline.PointC
                    v.box.PointD = v.boxOutline.PointD
                    v.box.Color = settings.esp.box.color
                    v.box.Thickness = settings.esp.box.thickness
                    v.box.Transparency = settings.esp.box.transparency
                    v.box.Filled = settings.esp.box.filled
                    v.box.Visible = true
                else
                    v.boxOutline.Visible = false
                    v.box.Visible = false
                end
                -- Tracers
                if settings.esp.tracer.enabled then
                    v.traceOutline.Thickness = settings.esp.tracer.thickness + 1.5
                    v.traceOutline.Color = settings.esp.tracer.outlineColor
                    v.traceOutline.Transparency = settings.esp.tracer.transparency
                    v.traceOutline.Visible = settings.esp.tracer.outline
                    v.traceOutline.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 1)
                    v.traceOutline.To = Vector2.new(tracerPosX, tracerPosY)

                    v.trace.Thickness = settings.esp.tracer.thickness
                    v.trace.Color = settings.esp.tracer.color
                    v.trace.Transparency = settings.esp.tracer.transparency
                    v.trace.Visible = true
                    v.trace.From = v.traceOutline.From
                    v.trace.To = v.traceOutline.To
                else
                    v.trace.Visible = false
                    v.traceOutline.Visible = false
                end
                -- Names
                if settings.esp.name.enabled then
                    v.name.Text = character.Name
                    v.name.Color = settings.esp.name.color
                    v.name.Font = settings.esp.name.font
                    v.name.Size = settings.esp.name.size
                    v.name.Center = settings.esp.name.center
                    v.name.Outline = settings.esp.name.outline
                    v.name.OutlineColor = settings.esp.name.outlineColor
                    v.name.Position = Vector2.new(topPosX, topPosY - 27)
                    v.name.Visible = true
                else
                    v.name.Visible = false
                    v.name.Outline = false
                end
                -- Distance
                if settings.esp.weapon.enabled then
                    v.weapon.Text = getWeapon(character)
                    v.weapon.Color = settings.esp.weapon.color
                    v.weapon.Font = settings.esp.weapon.font
                    v.weapon.Size = settings.esp.weapon.size
                    v.weapon.Center = settings.esp.weapon.center
                    v.weapon.Outline = settings.esp.weapon.outline
                    v.weapon.OutlineColor = settings.esp.weapon.outlineColor
                    v.weapon.Position = Vector2.new(topPosX, topPosY - 15)
                    v.weapon.Visible = true
                else
                    v.weapon.Visible = false
                    v.weapon.Outline = false
                end
            else
                v.boxOutline.Visible = false
                v.box.Visible = false
                v.trace.Visible = false
                v.traceOutline.Visible = false
                v.name.Visible = false
                v.weapon.Visible = false
            end
        end
    end
end

-- // Function hooks
local silentHook
local fireHook
local recoilHook

silentHook = hookfunction(new_projectile, function(...)
    local args = {...}
    args[6] = (settings.combat.silentAim and closestDir) or args[6]
    return silentHook(unpack(args))
end)
fireHook = hookfunction(fire, function(...)
    local args = {...}
    if settings.combat.infiniteAmmo then
        local ammoVal = args[1].Ammo
        args[1].Ammo = ammoVal + 1
    end
    if settings.combat.noRecoil then
        args[1].RecoilMult = 0
    end
    if settings.combat.rapidFire then
        args[1].FireRate = args[1].FireRate / 2
    end
    if settings.combat.fastReload then
        args[1].ReloadTime = 0
    end
    return fireHook(unpack(args))
end)

-- // Player & FOV Circle handling
local function removePlayer(player_model)
    for i,v in pairs(espCache) do
        if i == player_model then
            v.boxOutline:Remove()
            v.box:Remove()
            v.trace:Remove()
            v.traceOutline:Remove()
            v.name:Remove()
            v.weapon:Remove()
            espCache[i] = nil
        end
    end
end
for _, child in pairs(workspace:GetChildren()) do
    if child:IsA("Model") and players:FindFirstChild(child.Name) and child.Name ~= localPlayer.Name then
        newDrawing(child)
    end
end
workspace.ChildAdded:Connect(function(child)
    if child:IsA("Model") and players:FindFirstChild(child.Name) and child.Name ~= localPlayer.Name then
        newDrawing(child)
    end
end)
workspace.ChildRemoved:Connect(function(child)
    if child:IsA("Model") and child.Name ~= localPlayer.Name then
        removePlayer(child)
    end
end)
local Circle = Drawing.new("Circle")
runService.RenderStepped:Connect(function()
    updateEsp()
    Circle.NumSides = settings.combat.fovCircle.sides
    Circle.Color = settings.combat.fovCircle.color
    Circle.Transparency = settings.combat.fovCircle.transparency
    Circle.Radius = settings.combat.fovCircle.radius
    Circle.Filled = settings.combat.fovCircle.filled
    Circle.Visible = settings.combat.fovCircle.enabled
    Circle.Thickness = settings.combat.fovCircle.thickness
    Circle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
end)

-- // UI Library interactables
silentAim:AddToggle("silentAim", {
    Text = "Enabled",
    Default = false,
    Tooltip = "",

    Callback = function(Value)
        settings.combat.silentAim = Value
    end
})
silentAim:AddDivider()
silentAim:AddToggle("silentAimFOV", {
    Text = "Show FOV Circle",
    Default = false,
    Tooltip = "",

    Callback = function(Value)
        settings.combat.fovCircle.enabled = Value
    end
})
silentAim:AddSlider("FOV Radius", {
    Text = "Radius",
    Default = 75,
    Min = 20,
    Max = 800,
    Rounding = 1,
    Compact = false,
    Callback = function(Value)
        settings.combat.fovCircle.radius = Value
    end
})
silentAim:AddSlider("FOV Transparency", {
    Text = "Transparency",
    Default = 1,
    Min = 0,
    Max = 1,
    Rounding = 1,
    Compact = false,
    Callback = function(Value)
        settings.combat.fovCircle.transparency = Value
    end
})
silentAim:AddLabel("Color"):AddColorPicker("FOVCircleColor", {
    Default = Color3.fromRGB(255, 255, 255),
    Title = "FOV Color",
    Callback = function(Value)
        settings.combat.fovCircle.color = Value
    end
})
triggerBot:AddToggle("triggerBot", {
    Text = "Enabled",
    Default = false,
    Tooltip = "",

    Callback = function(Value)
        settings.combat.triggerBot = Value
    end
})
gunMods:AddToggle("Infinite Ammo", {
    Text = "Infinite Ammo",
    Default = false,
    Tooltip = "",

    Callback = function(Value)
        settings.combat.infiniteAmmo = Value
    end
})
gunMods:AddToggle("No Recoil", {
    Text = "No Recoil",
    Default = false,
    Tooltip = "",

    Callback = function(Value)
        settings.combat.noRecoil = Value
    end
})
gunMods:AddToggle("Rapid Fire", {
    Text = "Faster Firerate",
    Default = false,
    Tooltip = "",

    Callback = function(Value)
        settings.combat.rapidFire = Value
    end
})
gunMods:AddToggle("Fast Reload", {
    Text = "Fast Reload",
    Default = false,
    Tooltip = "! DOES NOT REMOVE RELOAD ANIMATION !",

    Callback = function(Value)
        settings.combat.fastReload = Value
    end
})
gunMods:AddLabel("Fast Reload does not work on\nall weapons.")
playerBox:AddToggle("BoxESP", {
    Text = "Enabled",
    Default = false,
    Tooltip = "Enable/Disable Box ESP",
    Callback = function(Value)
        settings.esp.box.enabled = Value
    end
})
playerBox:AddToggle("BoxESPOutline", {
    Text = "Outline",
    Default = false,
    Tooltip = "Enable/Disable Box Outline",
    Callback = function(Value)
        settings.esp.box.outline = Value
    end
})
playerBox:AddSlider("BoxThickness", {
    Text = "Thickness",
    Default = 2,
    Min = 0,
    Max = 3,
    Rounding = 1,
    Compact = false,
    Callback = function(Value)
        settings.esp.box.thickness = Value
    end
})
playerBox:AddSlider("BoxTransparency", {
    Text = "Transparency",
    Default = 1,
    Min = 0,
    Max = 1,
    Rounding = 1,
    Compact = false,
    Callback = function(Value)
        settings.esp.box.transparency = Value
    end
})
playerBox:AddLabel("Box Color"):AddColorPicker("BOXCOLOR", {
    Default = settings.esp.box.color,
    Title = "box color",

    Callback = function(Value)
        settings.esp.box.color = Value
    end
})

playerTracer:AddToggle("TracerESP", {
    Text = "Enabled",
    Default = false,
    Tooltip = "Enable/Disable Tracer ESP",
    Callback = function(Value)
        settings.esp.tracer.enabled = Value
    end
})
playerTracer:AddToggle("TracerESPOutline", {
    Text = "Outline",
    Default = false,
    Tooltip = "Enable/Disable Box Outline",
    Callback = function(Value)
        settings.esp.tracer.outline = Value
    end
})
playerTracer:AddSlider("TracerThickness", {
    Text = "Thickness",
    Default = 2,
    Min = 0,
    Max = 3,
    Rounding = 1,
    Compact = false,
    Callback = function(Value)
        settings.esp.tracer.thickness = Value
    end
})
playerTracer:AddSlider("TracerTransparency", {
    Text = "Transparency",
    Default = 1,
    Min = 0,
    Max = 1,
    Rounding = 1,
    Compact = false,
    Callback = function(Value)
        settings.esp.tracer.transparency = Value
    end
})
playerTracer:AddLabel("Trace Color"):AddColorPicker("TRACECOLOR", {
    Default = settings.esp.tracer.color,
    Title = "tracer color",

    Callback = function(Value)
        settings.esp.tracer.color = Value
    end
})
playerName:AddToggle("NameESP", {
    Text = "Enabled",
    Default = false,
    Tooltip = "Enable/Disable Name ESP",
    Callback = function(Value)
        settings.esp.name.enabled = Value
    end
})
playerName:AddToggle("NameOutline", {
    Text = "Outline",
    Default = true,
    Tooltip = "Enable/Disable Name Outline",
    Callback = function(Value)
        settings.esp.name.outline = Value
    end
})
playerName:AddSlider("NameSize", {
    Text = "Size",
    Default = 13,
    Min = 4,
    Max = 15,
    Rounding = 1,
    Compact = false,
    Callback = function(Value)
        settings.esp.name.size = Value
    end
})
playerName:AddLabel("Text Color"):AddColorPicker("NAMECOLOR", {
    Default = settings.esp.name.color,
    Title = "name color",

    Callback = function(Value)
        settings.esp.name.color = Value
    end
})
playerWeapon:AddToggle("WeaponESP", {
    Text = "Enabled",
    Default = false,
    Tooltip = "Enable/Disable Weapon (TEXT) ESP",
    Callback = function(Value)
        settings.esp.weapon.enabled = Value
    end
})
playerWeapon:AddToggle("WeaponOutline", {
    Text = "Outline",
    Default = true,
    Tooltip = "Enable/Disable Weapon (TEXT) Outline",
    Callback = function(Value)
        settings.esp.weapon.outline = Value
    end
})
playerWeapon:AddSlider("WeaponSize", {
    Text = "Size",
    Default = 13,
    Min = 4,
    Max = 15,
    Rounding = 1,
    Compact = false,
    Callback = function(Value)
        settings.esp.weapon.size = Value
    end
})
playerWeapon:AddLabel("Text Color"):AddColorPicker("WEAPONCOLOR", {
    Default = settings.esp.weapon.color,
    Title = "weapon color",

    Callback = function(Value)
        settings.esp.weapon.color = Value
    end
})

local MenuGroup = Tabs["UI Settings"]:AddRightGroupbox('Menu')
MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' })
Library.ToggleKeybind = Options.MenuKeybind
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder('MyScriptHub')
ThemeManager:ApplyToTab(Tabs['UI Settings'])
