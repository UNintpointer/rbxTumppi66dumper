-- Fresh outta ChatGPT "PASTED AND DETECTED"

-- https://miro.medium.com/v2/resize:fit:500/1*8dWrGbNZr_A3H-WAseqGlw.jpeg

local id, espChannel = create_comm_channel();
local actors = getactors();
local drawings = {};

espChannel.Event:Connect(function(method, id, playerId, index, value)
    if method == "remove" then
        pcall(function()
        
            if drawings[playerId] and drawings[playerId][id] then
                drawings[playerId][id]:Remove();
                drawings[playerId] = nil;
            end
        
        end);

    elseif method == "new" then
        pcall(function()

            if not drawings[playerId] then
                drawings[playerId] = {};
            end
            drawings[playerId][id] = Drawing.new(index);
        
        end);

    else
        local drawing = drawings[playerId] and drawings[playerId][id];

        if drawing then
            pcall(function()

                drawing[index] = value;

            end)
        end
    end
end);

run_on_actor(actors[1], [[
    local RUN_SERVICE = cloneref(game:GetService("RunService"));
    local LIGHTING = cloneref(game:GetService("Lighting"));

    local camera = workspace.CurrentCamera;
    local exec_env = getgenv();

    local player_list;
    local projectileSpeed, projectileDrop = nil, nil;
    local espChannel = ...;
    espChannel = get_comm_channel(espChannel);

    local cheat_settings = {
        combat = {
            noRecoil = false;
            noSway = false;
            silentAim = {
                enabled = false;
                hitPart = "Head";
                hitChance = 80;
                fovCircle = {
                    enabled = false;
                    sides = 128;
                    color = Color3.fromRGB(255, 255, 255);
                    transparency = 1;
                    radius = 75;
                    thickness = 2;
                    filled = false
                };
                hitBoxExtender = {
                    enabled = false;
                    sizeX = 3;
                    sizeY = 3;
                    sizeZ = 3
                }
            }
        };
        world = {
            fullBright = {
                enabled = false;
                brightness = 1.2;
            }
        };
    }

    local esp = {
        settings = {
            ignoreSleeping = true;
            box = {enabled = false; outline = false; thickness = 2; transparency = 1; filled = false; color = Color3.fromRGB(255, 255, 255); outlineColor = Color3.fromRGB(0, 0, 0)};
            tracer = {enabled = false; outline = false; thickness = 2; transparency = 1; color = Color3.fromRGB(255, 255, 255); outlineColor = Color3.fromRGB(0, 0, 0)};
            distance = {enabled = false; font = 2; size = 13; center = true; outline = true; color = Color3.fromRGB(255, 255, 255); outlineColor = Color3.fromRGB(0, 0, 0)};
            armor = {enabled = false; font = 2; size = 13; center = true; outline = true; color = Color3.fromRGB(255, 255, 255); outlineColor = Color3.fromRGB(0, 0, 0)};
            weapon = {enabled = false; font = 2; size = 13; center = true; outline = true; color = Color3.fromRGB(255, 255, 255); outlineColor = Color3.fromRGB(0, 0, 0)}
        }
    };
    esp.cache = {
        __index = esp;
    }

    local modules = {
        ["PlayerClient"] = {};
        ["BowClient"] = {};
        ["Camera"] = {};
        ["RangedWeaponClient"] = {}
    }
    
    for _, value in pairs(getgc(true)) do
        if typeof(value) == "function" and islclosure(value) then
            local info = debug.getinfo(value);
            local scriptName = string.match(info.short_src, "%.([%w_]+)$");
    
            if scriptName and modules[scriptName] and info.name ~= nil then
                modules[scriptName][info.name] = info.func;
            end

        elseif typeof(value) == "table" and rawget(value, "ProjectileSpeed") then
            setmetatable(value, {
                __index = function(tbl, key)
                    local info = debug.getinfo(2);

                    if not info.name and info.nups == 1 and debug.validlevel(9) then
                        local projInfo = debug.getstack(2, 4);

                        if rawget(projInfo, "ProjectileSpeed") then
                            projectileSpeed = rawget(projInfo, "ProjectileSpeed");
                            projectileDrop = rawget(projInfo, "ProjectileDrop");
                        end
                    end

                    return rawget(tbl, key);
                end
            });
        end
    end

    player_list = debug.getupvalue(modules.PlayerClient.updatePlayers, 1);

    exec_env.Drawing = {
        new = function(shape, playerId)
            local properties = {};
            local pId = playerId;
            local id = math.random();
            espChannel:Fire("new", id, playerId, shape);
            
            return setmetatable({
                Remove = function()
                    return espChannel:Fire("remove", id, playerId);
                end
            }, 
            {
                __newindex = function(self, index, value)
                    properties[index] = value;
                    return espChannel:Fire("update", id, pId, index, value);
                end;
                
                __index = function(self, index)
                    return properties[index];
                end
            });
        end
    }

    local function get_closest()
        local closest = nil;
        local maxDist = math.huge;
    
        for key, value in pairs(player_list) do
            if value.model and not value.sleeping and value.model:FindFirstChild(cheat_settings.combat.silentAim.hitPart) then
                local pos = value.model[cheat_settings.combat.silentAim.hitPart].CFrame.Position;
                local posv2, onScreen = camera:WorldToScreenPoint(pos);
    
                if onScreen then
                    local distance = (Vector2.new(posv2.X, posv2.Y) - (camera.ViewportSize / 2)).Magnitude;
    
                    if distance < cheat_settings.combat.silentAim.fovCircle.radius then
                        distance = (camera.CFrame.Position - pos).Magnitude;
    
                        if distance < maxDist then
                            closest = key;
                            maxDist = distance;
                        end
                    end
                end
            end
        end
    
        if closest then
            if player_list[closest] and player_list[closest].model[cheat_settings.combat.silentAim.hitPart] then
                return closest;
            end
        end
    
        return nil;
    end

    local function predict(playerId)
        local prediction = Vector3.new(0, 0, 0);
        local drop = Vector3.new(0, 0, 0);
        local pSpeed, pDrop = projectileSpeed, projectileDrop;
        local hitPart = player_list[playerId] and player_list[playerId].model:FindFirstChild(cheat_settings.combat.silentAim.hitPart);

        if hitPart and pSpeed and pDrop then
            local velocityVector = player_list[playerId].velocityVector;
            local distance = (camera.CFrame.Position - hitPart.CFrame.Position).Magnitude;
            
            -- #PASTED AND DETECTED
            local flightTime = distance / pSpeed;
            local pSpeed2 = pSpeed - 13 * pSpeed ^ 2 * flightTime ^ 2;
            flightTime += (distance / pSpeed2);

            if velocityVector and flightTime then
                prediction = (velocityVector * (flightTime * 10)) * .5;
            end
        end
        return prediction, drop;
    end

    function esp:get_distance()
        return tostring(math.floor((camera.CFrame.Position - self.model:GetPivot().Position).Magnitude)) .. " studs";
    end

    function esp:get_armor_status()
        local isArmored = (#self.armorTable > 0 and true) or false;

        if isArmored then
            return "Armored"
        end
        return "No armor"
    end

    function esp:get_weapon()
        local weapon = player_list[self.playerId] and player_list[self.playerId].handModel;

        if weapon then
            return tostring(weapon);
        end
        return "No weapon";
    end

    function esp:update()
        local data = player_list[self.playerId] or nil;
        local rootPart = self.model:FindFirstChild("HumanoidRootPart");
        local settings = esp.settings;
        local drawings = self.drawings;

        if data and self.model and rootPart and not (data.sleeping and settings.ignoreSleeping) then
            local topLeft = camera:WorldToViewportPoint(rootPart.CFrame * CFrame.new(-3, 3, 0).Position);
            local topRight = camera:WorldToViewportPoint(rootPart.CFrame * CFrame.new(3, 3, 0).Position);
            local bottomLeft = camera:WorldToViewportPoint(rootPart.CFrame * CFrame.new(-3, -3, 0).Position);
            local bottomRight = camera:WorldToViewportPoint(rootPart.CFrame * CFrame.new(3, -3, 0).Position);

            local tracerPos = Vector2.new((bottomLeft.X + bottomRight.X) / 2, (bottomLeft.Y + bottomRight.Y) / 2);
            local topPos = Vector2.new((topLeft.X + topRight.X) / 2, (topLeft.Y + topRight.Y) / 2);

            local pos, onScreen = camera:WorldToViewportPoint(rootPart.CFrame.Position);

            if onScreen then
                if settings.box.enabled then
                    drawings.boxOutline.PointA = Vector2.new(topRight.X, topRight.Y);
                    drawings.boxOutline.PointB = Vector2.new(topLeft.X, topLeft.Y);
                    drawings.boxOutline.PointC = Vector2.new(bottomLeft.X, bottomLeft.Y);
                    drawings.boxOutline.PointD = Vector2.new(bottomRight.X, bottomRight.Y);
                    drawings.boxOutline.Color = settings.box.outlineColor;
                    drawings.boxOutline.Thickness = settings.box.thickness + 1.5;
                    drawings.boxOutline.Transparency = settings.box.transparency;
                    drawings.boxOutline.Visible = settings.box.outline;
    
                    drawings.box.PointA = drawings.boxOutline.PointA;
                    drawings.box.PointB = drawings.boxOutline.PointB;
                    drawings.box.PointC = drawings.boxOutline.PointC;
                    drawings.box.PointD = drawings.boxOutline.PointD;
                    drawings.box.Color = settings.box.color;
                    drawings.box.Thickness = settings.box.thickness;
                    drawings.box.Transparency = settings.box.transparency;
                    drawings.box.Filled = settings.box.filled;
                    drawings.box.Visible = true;
                else
                    drawings.boxOutline.Visible = false;
                    drawings.box.Visible = false;
                end

                if settings.tracer.enabled then
                    drawings.traceOutline.Thickness = settings.tracer.thickness + 1.5;
                    drawings.traceOutline.Color = settings.tracer.outlineColor;
                    drawings.traceOutline.Transparency = settings.tracer.transparency;
                    drawings.traceOutline.Visible = settings.tracer.outline;
                    drawings.traceOutline.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y);
                    drawings.traceOutline.To = tracerPos;

                    drawings.trace.Thickness = settings.tracer.thickness;
                    drawings.trace.Color = settings.tracer.color;
                    drawings.trace.Transparency = settings.tracer.transparency;
                    drawings.trace.Visible = true;
                    drawings.trace.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y);
                    drawings.trace.To = drawings.traceOutline.To;
                else
                    drawings.trace.Visible = false;
                    drawings.traceOutline.Visible = false;
                end

                if settings.weapon.enabled then
                    drawings.weapon.Text = self:get_weapon();
                    drawings.weapon.Color = settings.weapon.color;
                    drawings.weapon.Font = settings.weapon.font;
                    drawings.weapon.Size = settings.weapon.size;
                    drawings.weapon.Center = settings.weapon.center;
                    drawings.weapon.Outline = settings.weapon.outline;
                    drawings.weapon.OutlineColor = settings.weapon.outlineColor;
                    drawings.weapon.Position = Vector2.new(tracerPos.X, (topPos.Y - 17));
                    topPos = Vector2.new(topPos.X, (topPos.Y - 10));
                    drawings.weapon.Visible = true;
                else
                    drawings.weapon.Visible = false;
                end

                if settings.armor.enabled then
                    drawings.armor.Text = self:get_armor_status();
                    drawings.armor.Color = settings.armor.color;
                    drawings.armor.Font = settings.armor.font;
                    drawings.armor.Size = settings.armor.size;
                    drawings.armor.Center = settings.armor.center;
                    drawings.armor.Outline = settings.armor.outline;
                    drawings.armor.OutlineColor = settings.armor.outlineColor;
                    drawings.armor.Position = Vector2.new(tracerPos.X, (topPos.Y - 17));
                    topPos = Vector2.new(topPos.X, (topPos.Y - 10));
                    drawings.armor.Visible = true;
                else
                    drawings.armor.Visible = false;
                end

                if settings.distance.enabled then
                    drawings.distance.Text = self:get_distance();
                    drawings.distance.Color = settings.distance.color;
                    drawings.distance.Font = settings.distance.font;
                    drawings.distance.Size = settings.distance.size;
                    drawings.distance.Center = settings.distance.center;
                    drawings.distance.Outline = settings.distance.outline;
                    drawings.distance.OutlineColor = settings.distance.outlineColor;
                    drawings.distance.Position = Vector2.new(tracerPos.X, (tracerPos.Y + 5));
                    drawings.distance.Visible = true;
                else
                    drawings.distance.Visible = false;
                end
            else
                drawings.boxOutline.Visible = false;
                drawings.box.Visible = false;
                drawings.traceOutline.Visible = false;
                drawings.trace.Visible = false;
                drawings.weapon.Visible = false;
                drawings.armor.Visible = false;
                drawings.distance.Visible = false;
            end
        else
            drawings.boxOutline.Visible = false;
            drawings.box.Visible = false;
            drawings.traceOutline.Visible = false;
            drawings.trace.Visible = false;
            drawings.weapon.Visible = false;
            drawings.armor.Visible = false;
            drawings.distance.Visible = false;
        end
    end

    function esp.new_object(model, playerId)
        local self = setmetatable({}, esp.cache);
        self.model = model;
        self.playerId = playerId;
        self.armorTable = player_list[playerId].armor;
        self.headSize = self.model.Head.Size;
        self.drawings = {
            boxOutline = Drawing.new("Quad", playerId);
            box = Drawing.new("Quad", playerId);
            traceOutline = Drawing.new("Line", playerId);
            trace = Drawing.new("Line", playerId);
            distance = Drawing.new("Text", playerId);
            armor = Drawing.new("Text", playerId);
            weapon = Drawing.new("Text", playerId)
        };
        self.connection = RUN_SERVICE.RenderStepped:Connect(function()
            self:update();
        end);

        esp.cache[playerId] = self;
        return self;
    end

    function esp.remove_object(playerId)
        local object = esp.cache[playerId];

        if object then
            object.connection:Disconnect();

            for _, drawing in pairs(object.drawings) do
                drawing:Remove();
            end

            table.clear(object);
            esp.cache[playerId] = nil;
        end
    end

    for key, value in pairs(player_list) do
        esp.new_object(value.model, key)
    end

    local old_OnCreate;
    local old_OnDestroy;
    local old_createProjectile;
    local old_bow_createProjectile;
    local old_Recoil;
    local old_SetSwaySpeed;
    
    old_OnCreate = hookfunction(modules.PlayerClient.OnCreate, function(...)
        local args = {...};

        task.delay(.5, function()
            for key, value in pairs(player_list) do
                if value.model == args[1].model then
                    esp.new_object(value.model, key);
                end
            end
        end);

        return old_OnCreate(...);
    end);

    old_OnDestroy = hookfunction(modules.PlayerClient.OnDestroy, function(...)
        local args = {...};

        task.delay(.5, function()
            for key, value in pairs(esp.cache) do
                if value.model == args[1].model then
                    esp.remove_object(key);
                end
            end
        end);

        return old_OnDestroy(...);
    end);

    old_createProjectile = hookfunction(modules.RangedWeaponClient.createProjectile, function(...)
        local args = {...};

        if cheat_settings.combat.silentAim.enabled and args[3] == true and projectileSpeed and projectileDrop and math.random(1, 100) <= cheat_settings.combat.silentAim.hitChance then
            local oldCFrame = args[1];
            local closest = get_closest();

            if oldCFrame and closest then
                local newPos = CFrame.lookAt(oldCFrame.Position, player_list[closest].model[cheat_settings.combat.silentAim.hitPart].CFrame.Position + predict(closest));
                args[1] = newPos;

                if newPos then
                    args[1] = newPos;

                    return old_bow_createProjectile(table.unpack(args));
                end
            end
        end
        
        return old_createProjectile(...);
    end);

    old_bow_createProjectile = hookfunction(modules.BowClient.createProjectile, function(...)
        local args = {...};

        if cheat_settings.combat.silentAim.enabled and args[3] == true and projectileSpeed and projectileDrop and math.random(1, 100) <= cheat_settings.combat.silentAim.hitChance then
            local oldCFrame = args[1];
            local closest = get_closest();

            if oldCFrame and closest then
                local newPos = CFrame.lookAt(oldCFrame.Position, player_list[closest].model[cheat_settings.combat.silentAim.hitPart].CFrame.Position + predict(closest));

                if newPos then
                    args[1] = newPos;

                    return old_bow_createProjectile(table.unpack(args));
                end
            end
        end
        
        return old_bow_createProjectile(...);
    end);

    old_Recoil = hookfunction(modules.Camera.Recoil, function(...)

        if cheat_settings.combat.noRecoil then
            return;
        end

        return old_Recoil(...);
    end);

    old_SetSwaySpeed = hookfunction(modules.Camera.SetSwaySpeed, function(...)

        if cheat_settings.combat.noSway then
            return;
        end

        return old_SetSwaySpeed(...);
    end);

    -- Fullbright connection
    LIGHTING.Changed:Connect(function()
        if cheat_settings.world.fullBright.enabled then
            local brightness = cheat_settings.world.fullBright.brightness;
            sethiddenproperty(LIGHTING, "Ambient", Color3.new(brightness, brightness, brightness));
        end
    end);

    local circle = Drawing.new("Circle", 0);
    circle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2);
    RUN_SERVICE.Heartbeat:Connect(function()
        circle.NumSides = cheat_settings.combat.silentAim.fovCircle.sides;
        circle.Color = cheat_settings.combat.silentAim.fovCircle.color;
        circle.Transparency = cheat_settings.combat.silentAim.fovCircle.transparency;
        circle.Radius = cheat_settings.combat.silentAim.fovCircle.radius;
        circle.Filled = cheat_settings.combat.silentAim.fovCircle.filled;
        circle.Visible = cheat_settings.combat.silentAim.fovCircle.enabled;
        circle.Thickness = cheat_settings.combat.silentAim.fovCircle.thickness;
    end)

    -- UI Libr (Puppyware)
    local libary = loadstring(game:HttpGet("https://raw.githubusercontent.com/imagoodpersond/puppyware/main/lib"))()

    local Window = libary:new({name = "Trident Survival V3 | #tupsutumppu", accent = Color3.fromRGB(244, 95, 115), textsize = 13});
    local combatTab = Window:page({name = "Combat"});
    local espTab = Window:page({name = "ESP"});
    local worldVisualTab = Window:page({name = "World"});

    local UI_silentAim = combatTab:section({name = "Silent Aim", side = "left", size = 220});
    local UI_gunMods = combatTab:section({name = "Gun Mods", side = "right", size = 65});

    local UI_playerGen = espTab:section({name = "General", side = "left", size = 45});
    local UI_playerBox = espTab:section({name = "Box", side = "left", size = 170});
    local UI_playerTracer = espTab:section({name = "Tracer", side = "left", size = 170});
    local UI_playerDistance = espTab:section({name = "Distance", side = "right", size = 120});
    local UI_playerWeapon = espTab:section({name = "Weapon", side = "right", size = 120});
    local UI_playerArmor = espTab:section({name = "Armor", side = "right", size = 120});

    local UI_worldVisual = worldVisualTab:section({name = "Visual", side = "left", size = 80});
    local UI_worldVegetation = worldVisualTab:section({name = "Vegetation", side = "right", size = 45});

    UI_silentAim:toggle({name = "Enabled", def = false, callback = function(Boolean)
        cheat_settings.combat.silentAim.enabled = Boolean;
    end});
    UI_silentAim:dropdown({name = "Hit Part", def = "Head", max = 2, options = {"Head", "Torso"}, callback = function(part)
        cheat_settings.combat.silentAim.hitPart = part;
    end});
    UI_silentAim:slider({name = "Hit Chance", def = cheat_settings.combat.silentAim.hitChance, max = 100, min = 10, rounding = true, callback = function(Number)
        cheat_settings.combat.silentAim.hitChance = Number;
    end});
    UI_silentAim:toggle({name = "FOV Circle", def = false, callback = function(Boolean)
        cheat_settings.combat.silentAim.fovCircle.enabled = Boolean;
    end});
    UI_silentAim:slider({name = "FOV Radius", def = cheat_settings.combat.silentAim.fovCircle.radius, max = 800, min = 10, rounding = true, callback = function(Number)
        cheat_settings.combat.silentAim.fovCircle.radius = Number;
    end});
    UI_silentAim:slider({name = "FOV Thickness", def = cheat_settings.combat.silentAim.fovCircle.thickness, max = 3, min = 1, rounding = false, callback = function(Number)
        cheat_settings.combat.silentAim.fovCircle.thickness = Number;
    end});
    UI_silentAim:colorpicker({name = "FOV Color", cpname = "", def = cheat_settings.combat.silentAim.fovCircle.color, callback = function(color)
        cheat_settings.combat.silentAim.fovCircle.color = color;
    end});

    UI_gunMods:toggle({name = "No Recoil", def = false, callback = function(Boolean)
        cheat_settings.combat.noRecoil = Boolean;
    end});
    UI_gunMods:toggle({name = "No Sway", def = false, callback = function(Boolean)
        cheat_settings.combat.noSway = Boolean;
    end});

    UI_playerGen:toggle({name = "Show Sleeping", def = false, callback = function(Boolean)
        esp.settings.ignoreSleeping = not Boolean;
    end});

    UI_playerBox:toggle({name = "Enabled", def = false, callback = function(Boolean)
        esp.settings.box.enabled = Boolean;
    end});
    UI_playerBox:toggle({name = "Outline", def = false, callback = function(Boolean)
        esp.settings.box.outline = Boolean;
    end});
    UI_playerBox:slider({name = "Thickness", def = esp.settings.box.thickness, max = 3, min = 1, rounding = false, callback = function(Number)
        esp.settings.box.thickness = Number;
    end});
    UI_playerBox:slider({name = "Transparency", def = esp.settings.box.transparency, max = 1, min = 0, rounding = false, callback = function(Number)
        esp.settings.box.transparency = Number;
    end});
    UI_playerBox:colorpicker({name = "Color", cpname = "", def = esp.settings.box.color, callback = function(color)
        esp.settings.box.color = color;
    end});
    UI_playerBox:colorpicker({name = "Outline Color", cpname = "", def = esp.settings.box.outlineColor, callback = function(color)
        esp.settings.box.outlineColor = color;
    end});

    UI_playerTracer:toggle({name = "Enabled", def = false, callback = function(Boolean)
        esp.settings.tracer.enabled = Boolean;
    end});
    UI_playerTracer:toggle({name = "Outline", def = false, callback = function(Boolean)
        esp.settings.tracer.outline = Boolean;
    end});
    UI_playerTracer:slider({name = "Thickness", def = esp.settings.tracer.thickness, max = 3, min = 1, rounding = false, callback = function(Number)
        esp.settings.tracer.thickness = Number;
    end});
    UI_playerTracer:slider({name = "Transparency", def = esp.settings.tracer.transparency, max = 1, min = 0, rounding = false, callback = function(Number)
        esp.settings.tracer.transparency = Number;
    end});
    UI_playerTracer:colorpicker({name = "Color", cpname = "", def = esp.settings.tracer.color, callback = function(color)
        esp.settings.tracer.color = color;
    end});
    UI_playerTracer:colorpicker({name = "Outline Color", cpname = "", def = esp.settings.tracer.outlineColor, callback = function(color)
        esp.settings.tracer.outlineColor = color;
    end});

    UI_playerDistance:toggle({name = "Enabled", def = false, callback = function(Boolean)
        esp.settings.distance.enabled = Boolean;
    end});
    UI_playerDistance:toggle({name = "Outline", def = false, callback = function(Boolean)
        esp.settings.distance.outline = Boolean;
    end});
    UI_playerDistance:slider({name = "Size", def = esp.settings.distance.size, max = 25, min = 10, rounding = true, callback = function(Number)
        esp.settings.distance.size = Number;
    end});
    UI_playerDistance:colorpicker({name = "Color", cpname = "", def = esp.settings.distance.color, callback = function(color)
        esp.settings.distance.color = color;
    end});

    UI_playerWeapon:toggle({name = "Enabled", def = false, callback = function(Boolean)
        esp.settings.weapon.enabled = Boolean;
    end});
    UI_playerWeapon:toggle({name = "Outline", def = false, callback = function(Boolean)
        esp.settings.weapon.outline = Boolean;
    end});
    UI_playerWeapon:slider({name = "Size", def = esp.settings.weapon.size, max = 25, min = 10, rounding = true, callback = function(Number)
        esp.settings.weapon.size = Number;
    end});
    UI_playerWeapon:colorpicker({name = "Color", cpname = "", def = esp.settings.weapon.color, callback = function(color)
        esp.settings.weapon.color = color;
    end});

    UI_playerArmor:toggle({name = "Enabled", def = false, callback = function(Boolean)
        esp.settings.armor.enabled = Boolean;
    end});
    UI_playerArmor:toggle({name = "Outline", def = false, callback = function(Boolean)
        esp.settings.armor.outline = Boolean;
    end});
    UI_playerArmor:slider({name = "Size", def = esp.settings.armor.size, max = 25, min = 10, rounding = true, callback = function(Number)
        esp.settings.armor.size = Number;
    end});
    UI_playerArmor:colorpicker({name = "Color", cpname = "", def = esp.settings.armor.color, callback = function(color)
        esp.settings.armor.color = color;
    end});

    UI_worldVisual:toggle({name = "Fullbright", def = false, callback = function(Boolean)
        cheat_settings.world.fullBright.enabled = Boolean;
    end});
    UI_worldVisual:slider({name = "Brightness", def = 1.2, max = 5, min = 0, rounding = false, callback = function(Number)
        cheat_settings.world.fullBright.brightness = Number;
    end});

    UI_worldVegetation:toggle({name = "Disable Grass", def = false, callback = function(Boolean)
        sethiddenproperty(workspace.Terrain, "Decoration", not Boolean);
    end});
]]);
