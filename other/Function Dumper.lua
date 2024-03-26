getgenv().function_dump = function(scrName)
    local gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name;
    local folder = (isfolder(gameName) and gameName) or makefolder(gameName);
    local functions = {};
    local dump = `dumped by #tupsutumppu\n\n`;

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
                        upvalueStr ..= `upvalue[{key}] = {value}\t{upvalInfo.name or ""}({upvalInfo.is_vararg ~= 1 and get_args(upvalInfo.numparams)})\n`;
    
                    elseif typeof(value) == "table" then
                        upvalueStr ..= `upvalue[{key}] = {table_to_string(value)}\n`;
    
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
                    protoStr ..= `\n\tproto[{key}] = function {(info.name or "__UNNAMED PROTO_")}({(info.is_vararg ~= 1 and get_args(info.numparams)) or "..."})\t({info.what})`;
                end

                protoStr ..= "\n"
            end

            tempDump ..= protoStr;
        end

        tempDump ..= "\nend\n";
        tempDump ..= "\n-----------------------------------------\n"
        dump ..= tempDump;
    end
    
    writefile(`{folder}/{scrName}.txt`, dump);
end
