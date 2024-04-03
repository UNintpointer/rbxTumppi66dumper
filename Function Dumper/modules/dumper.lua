local dumper = {};
local repr1_2 = loadstring([[
    -- Modified Version of repr
    -- https://github.com/Ozzypig/repr/tree/master

    local defaultSettings = {
        pretty = false,
        robloxFullName = false,
        robloxProperFullName = true,
        robloxClassName = true,
        tabs = false,
        semicolons = false,
        spaces = 3,
        sortKeys = true
    };

    local function get_args(numparams)
        local argStr = "";

        for arg = 1, numparams do
            argStr ..= (arg ~= numparams and `a_{arg}, `) or `a_{arg}`;
        end

        return argStr;
    end;

    local keywords = {
        ["and"] = true,
        ["break"] = true,
        ["do"] = true,
        ["else"] = true,
        ["elseif"] = true,
        ["end"] = true,
        ["false"] = true,
        ["for"] = true,
        ["function"] = true,
        ["if"] = true,
        ["in"] = true,
        ["local"] = true,
        ["nil"] = true,
        ["not"] = true,
        ["or"] = true,
        ["repeat"] = true,
        ["return"] = true,
        ["then"] = true,
        ["true"] = true,
        ["until"] = true,
        ["while"] = true
    };
    local function isLuaIdentifier(str)
        if (type(str) ~= "string") then
            return false;
        end
        if (str:len() == 0) then
            return false;
        end
        if str:find("[^%d%a_]") then
            return false;
        end
        if tonumber(str:sub(1, 1)) then
            return false;
        end
        if keywords[str] then
            return false;
        end
        return true;
    end
    local function properFullName(object, usePeriod)
        if ((object == nil) or (object == game)) then
            return "";
        end
        local s = object.Name;
        local usePeriod = true;
        if not isLuaIdentifier(s) then
            s = ("[%q]"):format(s);
            usePeriod = false;
        end
        if (not object.Parent or (object.Parent == game)) then
            return s;
        else
            return properFullName(object.Parent) .. ((usePeriod and ".") or "") .. s;
        end
    end
    local depth = 0;
    local shown;
    local INDENT;
    local reprSettings;
    local function repr(value, reprSettings)
        reprSettings = reprSettings or defaultSettings;
        INDENT = (" "):rep(reprSettings.spaces or defaultSettings.spaces);
        if reprSettings.tabs then
            INDENT = "\t";
        end
        local v = value;
        local tabs = INDENT:rep(depth);
        if (depth == 0) then
            shown = {};
        end
        if (type(v) == "string") then
            return ("%q"):format(v);
        elseif (type(v) == "number") then
            if (v == math.huge) then
                return "math.huge";
            end
            if (v == - math.huge) then
                return "-math.huge";
            end
            return tonumber(v);
        elseif (type(v) == "boolean") then
            return tostring(v);
        elseif (type(v) == "nil") then
            return "nil";
        elseif ((type(v) == "table") and (type(v.__tostring) == "function")) then
            return tostring(v.__tostring(v));
        elseif ((type(v) == "table") and getmetatable(v) and (type(getmetatable(v).__tostring) == "function")) then
            return tostring(getmetatable(v).__tostring(v));
        elseif (type(v) == "table") then
            if shown[v] then
                return "{CYCLIC}";
            end
            shown[v] = true;
            local str = "{" .. ((reprSettings.pretty and ("\n" .. INDENT .. tabs)) or "");
            local isArray = true;
            for k, v in pairs(v) do
                if (type(k) ~= "number") then
                    isArray = false;
                    break;
                end
            end
            if isArray then
                for i = 1, # v do
                    if (i ~= 1) then
                        str = str .. ((reprSettings.semicolons and ";") or ",") .. ((reprSettings.pretty and ("\n" .. INDENT .. tabs)) or " ");
                    end
                    depth = depth + 1;
                    str = str .. repr(v[i], reprSettings);
                    depth = depth - 1;
                end
            else
                local keyOrder = {};
                local keyValueStrings = {};
                for k, v in pairs(v) do
                    depth = depth + 1;
                    local kStr = (isLuaIdentifier(k) and k) or ("[" .. repr(k, reprSettings) .. "]");
                    local vStr = repr(v, reprSettings);
                    table.insert(keyOrder, kStr);
                    keyValueStrings[kStr] = vStr;
                    depth = depth - 1;
                end
                if reprSettings.sortKeys then
                    table.sort(keyOrder);
                end
                local first = true;
                for _, kStr in pairs(keyOrder) do
                    if not first then
                        str = str .. ((reprSettings.semicolons and ";") or ",") .. ((reprSettings.pretty and ("\n" .. INDENT .. tabs)) or " ");
                    end
                    str = str .. ("%s = %s"):format(kStr, keyValueStrings[kStr]);
                    first = false;
                end
            end
            shown[v] = false;
            if reprSettings.pretty then
                str = str .. "\n" .. tabs;
            end
            str = str .. "}";
            return str;
        elseif typeof then
            if (typeof(v) == "Instance") then
                return ((reprSettings.robloxFullName and ((reprSettings.robloxProperFullName and properFullName(v)) or v:GetFullName())) or v.Name) .. ((reprSettings.robloxClassName and ((" (%s)"):format(v.ClassName))) or "");
            elseif (typeof(v) == "Axes") then
                local s = {};
                if v.X then
                    table.insert(s, repr(Enum.Axis.X, reprSettings));
                end
                if v.Y then
                    table.insert(s, repr(Enum.Axis.Y, reprSettings));
                end
                if v.Z then
                    table.insert(s, repr(Enum.Axis.Z, reprSettings));
                end
                return ("Axes.new(%s)"):format(table.concat(s, ", "));
            elseif (typeof(v) == "BrickColor") then
                return ("BrickColor.new(%q)"):format(v.Name);
            elseif (typeof(v) == "CFrame") then
                return ("CFrame.new(%s)"):format(table.concat({
                    v:GetComponents()
                }, ", "));
            elseif (typeof(v) == "Color3") then
                return ("Color3.new(%d, %d, %d)"):format(v.r, v.g, v.b);
            elseif (typeof(v) == "ColorSequence") then
                if (# v.Keypoints > 2) then
                    return ("ColorSequence.new(%s)"):format(repr(v.Keypoints, reprSettings));
                elseif (v.Keypoints[1].Value == v.Keypoints[2].Value) then
                    return ("ColorSequence.new(%s)"):format(repr(v.Keypoints[1].Value, reprSettings));
                else
                    return ("ColorSequence.new(%s, %s)"):format(repr(v.Keypoints[1].Value, reprSettings), repr(v.Keypoints[2].Value, reprSettings));
                end
            elseif (typeof(v) == "ColorSequenceKeypoint") then
                return ("ColorSequenceKeypoint.new(%d, %s)"):format(v.Time, repr(v.Value, reprSettings));
            elseif (typeof(v) == "DockWidgetPluginGuiInfo") then
                return ("DockWidgetPluginGuiInfo.new(%s, %s, %s, %s, %s, %s, %s)"):format(repr(v.InitialDockState, reprSettings), repr(v.InitialEnabled, reprSettings), repr(v.InitialEnabledShouldOverrideRestore, reprSettings), repr(v.FloatingXSize, reprSettings), repr(v.FloatingYSize, reprSettings), repr(v.MinWidth, reprSettings), repr(v.MinHeight, reprSettings));
            elseif (typeof(v) == "Enums") then
                return "Enums";
            elseif (typeof(v) == "Enum") then
                return ("Enum.%s"):format(tostring(v));
            elseif (typeof(v) == "EnumItem") then
                return ("Enum.%s.%s"):format(tostring(v.EnumType), v.Name);
            elseif (typeof(v) == "Faces") then
                local s = {};
                for _, enumItem in pairs(Enum.NormalId:GetEnumItems()) do
                    if v[enumItem.Name] then
                        table.insert(s, repr(enumItem, reprSettings));
                    end
                end
                return ("Faces.new(%s)"):format(table.concat(s, ", "));
            elseif (typeof(v) == "NumberRange") then
                if (v.Min == v.Max) then
                    return ("NumberRange.new(%d)"):format(v.Min);
                else
                    return ("NumberRange.new(%d, %d)"):format(v.Min, v.Max);
                end
            elseif (typeof(v) == "NumberSequence") then
                if (# v.Keypoints > 2) then
                    return ("NumberSequence.new(%s)"):format(repr(v.Keypoints, reprSettings));
                elseif (v.Keypoints[1].Value == v.Keypoints[2].Value) then
                    return ("NumberSequence.new(%d)"):format(v.Keypoints[1].Value);
                else
                    return ("NumberSequence.new(%d, %d)"):format(v.Keypoints[1].Value, v.Keypoints[2].Value);
                end
            elseif (typeof(v) == "NumberSequenceKeypoint") then
                if (v.Envelope ~= 0) then
                    return ("NumberSequenceKeypoint.new(%d, %d, %d)"):format(v.Time, v.Value, v.Envelope);
                else
                    return ("NumberSequenceKeypoint.new(%d, %d)"):format(v.Time, v.Value);
                end
            elseif (typeof(v) == "PathWaypoint") then
                return ("PathWaypoint.new(%s, %s)"):format(repr(v.Position, reprSettings), repr(v.Action, reprSettings));
            elseif (typeof(v) == "PhysicalProperties") then
                return ("PhysicalProperties.new(%d, %d, %d, %d, %d)"):format(v.Density, v.Friction, v.Elasticity, v.FrictionWeight, v.ElasticityWeight);
            elseif (typeof(v) == "Random") then
                return "<Random>";
            elseif (typeof(v) == "Ray") then
                return ("Ray.new(%s, %s)"):format(repr(v.Origin, reprSettings), repr(v.Direction, reprSettings));
            elseif (typeof(v) == "RBXScriptConnection") then
                return "<RBXScriptConnection>";
            elseif (typeof(v) == "RBXScriptSignal") then
                return "<RBXScriptSignal>";
            elseif (typeof(v) == "Rect") then
                return ("Rect.new(%d, %d, %d, %d)"):format(v.Min.X, v.Min.Y, v.Max.X, v.Max.Y);
            elseif (typeof(v) == "Region3") then
                local min = v.CFrame.p + (v.Size * - 0.5);
                local max = v.CFrame.p + (v.Size * 0.5);
                return ("Region3.new(%s, %s)"):format(repr(min, reprSettings), repr(max, reprSettings));
            elseif (typeof(v) == "Region3int16") then
                return ("Region3int16.new(%s, %s)"):format(repr(v.Min, reprSettings), repr(v.Max, reprSettings));
            elseif (typeof(v) == "TweenInfo") then
                return ("TweenInfo.new(%d, %s, %s, %d, %s, %d)"):format(v.Time, repr(v.EasingStyle, reprSettings), repr(v.EasingDirection, reprSettings), v.RepeatCount, repr(v.Reverses, reprSettings), v.DelayTime);
            elseif (typeof(v) == "UDim") then
                return ("UDim.new(%d, %d)"):format(v.Scale, v.Offset);
            elseif (typeof(v) == "UDim2") then
                return ("UDim2.new(%d, %d, %d, %d)"):format(v.X.Scale, v.X.Offset, v.Y.Scale, v.Y.Offset);
            elseif (typeof(v) == "Vector2") then
                return ("Vector2.new(%d, %d)"):format(v.X, v.Y);
            elseif (typeof(v) == "Vector2int16") then
                return ("Vector2int16.new(%d, %d)"):format(v.X, v.Y);
            elseif (typeof(v) == "Vector3") then
                return ("Vector3.new(%d, %d, %d)"):format(v.X, v.Y, v.Z);
            elseif (typeof(v) == "Vector3int16") then
                return ("Vector3int16.new(%d, %d, %d)"):format(v.X, v.Y, v.Z);
            elseif (typeof(v) == "DateTime") then
                return ("DateTime.fromIsoDate(%q)"):format(v:ToIsoDate());
            else
                return "<" .. typeof(v) .. ">";
            end
        else
            if type(v) == "function" then
                local info = debug.getinfo(v);
                return `<{value}\t{upvalInfo.name or ""}({(func.info.is_vararg ~= 1 and get_args(func.info.numparams)) or "..."})>`;
            else
                return "<" .. type(v) .. ">";
            end
        end
    end
    return repr;
]])();

local reprSettings = {
    pretty = true;
	robloxFullName = false;
	robloxProperFullName = false;
	robloxClassName = false;
	tabs = true;
	semicolons = false;
	spaces = 4;
	sortKeys = false;
}

function dumper.save_to_file(parts, name)
    local gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name;
    local folder = (isfolder(gameName) and gameName) or makefolder(gameName);
    local fileName = `{folder}/{name}_{math.floor(math.random(1, 999))}.txt`; -- boohoo

    for _, part in pairs(parts) do
        appendfile(fileName, part .. "\n-----------------------------------------\n");
    end
end

function dumper.function_dump(scrName)
    local functions = {};
    local dump = {};

    local function get_args(numparams)
        local argStr = "";

        for arg = 1, numparams do
            argStr ..= (arg ~= numparams and `a_{arg}, `) or `a_{arg}`;
        end

        return argStr;
    end

    local function table_to_string(tbl)
        local str = "{\n";

        for key, value in pairs(tbl) do
            str ..= `\t{key} = {value}\n`;
        end

        str ..= "}";
        return str;
    end

    for _, value in pairs(getgc()) do
        if typeof(value) == "function" and islclosure(value) then
            local info = debug.getinfo(value);
            local scriptName = string.match(info.short_src, "%.([%w_]+)$");

            if scriptName == scrName then

                functions[value] = {
                    info = info;
                    upvalues = debug.getupvalues(value);
                    constants = debug.getconstants(value);
                    protos = debug.getprotos(value, true);
                }

            end
        end
    end

    for _, func in pairs(functions) do
        local tempDump = "";

        do
            local upvalueStr = "";

            if #func.upvalues > 0 then

                for key, value in pairs(func.upvalues) do
                    if typeof(value) == "function" then
                        local upvalInfo = debug.getinfo(value);
                        upvalueStr ..= `upvalue[{key}] = <{value}\t{upvalInfo.name or ""}({upvalInfo.is_vararg ~= 1 and get_args(upvalInfo.numparams)})>\n`;
    
                    elseif typeof(value) == "table" then
                        upvalueStr ..= `upvalue[{key}] = {repr1_2(value, reprSettings)}\n`;
    
                    else
                        upvalueStr ..= `upvalue[{key}] = {value}\n`;
                    end
                end
            end

            tempDump ..= upvalueStr;
        end

        tempDump ..= `\nfunction {(func.info.name or "__UNNAMED__")}({(func.info.is_vararg ~= 1 and get_args(func.info.numparams)) or "..."})\n\n`;

        do

            local constantStr = "";

            if #func.constants > 0 then

                for key, value in pairs(func.constants) do
                    constantStr ..= `\tconstant[{key}] = {value}\n`;
                end

            end

            tempDump ..= constantStr;
        end

        do
            local protoStr = "\t";

            if #func.protos > 0 then

                for key, value in pairs(func.protos) do
                    local info = debug.getinfo(value);
                    protoStr ..= `\n\tproto[{key}] = function {(info.name or "__UNNAMED PROTO_")}({(info.is_vararg ~= 1 and get_args(info.numparams)) or "..."})`;
                    protoStr ..= `\n\t\twhat = {info.what}`;
                    protoStr ..= "\n\tend";
                end
            end

            tempDump ..= protoStr;
        end

        tempDump ..= "\nend\n";
        table.insert(dump, tempDump);
    end

    return dump;
end

return dumper;
