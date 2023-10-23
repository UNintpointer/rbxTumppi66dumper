while not (game or game.HttpGet) do
    task.wait()
end

local oldHttpGet
oldHttpGet = hookfunction(game.HttpGet, newcclosure(function(...)
    local args = {...}

    if args[2] and string.find(tostring(args[2]), "/v2/tokens/exists/") then
        return game:GetService("HttpService"):JSONEncode({success = true})
    end
    return oldHttpGet(...)
end))
