
# What is hookmetamethod? 

To understand what is hookmetamethod and what is it used for, we need to first understand the concept of a 'metamethod'. In short, a metamethod is a special function used to control the behavior of specific operations on a table. These metamethods live inside a table referred to as a metatable. Every Lua table inherently possesses a metatable, and we have the ability to modify the metamethods contained within it.

Lua has multiple metamethods; here is a list of some of them:

    “__add” defines the behaviour of addition operator (‘+’). 

    “__sub” defines the behaviour of substraction operator (‘-’). 

    “__mul” defines the behaviour of multiplication operator (‘*’). 

    “__div” defines the behaviour of division operator (‘/’). 

    “__eq” defines the behaviour for equality comparison (‘==’). 

    “__lt” defines the behaviour for less-than comparison (‘<’). 

    “__le” defines the behaviour for less-than or equal comparison (‘<=’). 

    “__index” allows customization of table indexing.

    “__newindex” allows customization of table assignment. 

As you probably know, in Lua, you cannot add the numeric values together from two tables using the addition ('+') operator. However, by modifying the metamethod '__add', we can achieve this. Here is an example:
```
local t1 = {"Hello World", "Lua is COOL!", 1, 68, 10}
local t2 = {"Hello!", "Hi!", 55, 28, 27}

print(t1 + t2) --> error
```
```
local meta = {
    __add = function(a1, a2)
        if typeof(a1) == "number" and typeof(a2) == "number" then
            return a1 + a2

        elseif typeof(a1) == "table" and typeof(a2) == "table" then
            local result = 0

            for i = 1, #a1 do
                result += typeof(a1[i]) == "number" and a1[i] or 0
            end

            for i = 1, #a2 do
                result += typeof(a2[i]) == "number" and a2[i] or 0
            end
            return result
        end
    end
}

-- // Now we associate the tables with 'meta'
setmetatable(t1, meta)
setmetatable(t2, meta)

-- // Lets try again
print(t1 + t2) --> now it will print "189" and will not error
```
Now that you have an idea of what metamethods are, I can show you why hookmetamethod is a very powerful function provided by our executors.
```
local localPlayer = game:GetService("Players").LocalPlayer
local humanoid = localPlayer.Character.Humanoid

humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
    if humanoid.WalkSpeed > 16 then
        localPlayer:Kick("Stop cheating noob!")
    end
end)
```
This is our anticheat, which checks your walkspeed every time it changes. If we were to set our walkspeed to something like 50, we would be instantly detected and kicked. How can we avoid that? We can avoid that with hookmetamethod.
```
local oldIndex; oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, idx)
    if tostring(self) == "Humanoid" and tostring(idx) == "WalkSpeed" then
        return 16
    end
    return oldIndex(self, idx)
end))
```
The code above hooks the index metamethod of the "game", which is essentially the main table containing everything the game has, such as players, assets, scripts, services, etc. This means that any script indexing anything, anywhere in the game, is using the "__index" of "game".

I'd say you now understand what hookmetamethod does, as it is pretty simple once you understand metamethods.

