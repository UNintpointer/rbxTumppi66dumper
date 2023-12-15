-- [[ "Cheat Functions" Library for developing (cheat) scripts for Roblox. | Updated 15.12.2023 | Discord: #tupsu, V3rmillion: Alpenglow ]] --

-- // Just to make it clear this is nowhere near finished because i have no way to test this as i have no executor rn.

local cfun = {}
cfun.__index = cfun

type pInfo = {
    Speed: number,
    Gravity: number
}

-- // Standard math libray doesnt have "math.average / math.avg".
function cfun.avg(...: number): number?
    local args = {...}
    local total = #args

    if total >= 2 then
        local val = 0

        for _, v in ipairs(args) do
            val += v
        end
        return val / total
    end
    return nil
end

function cfun.rstring(length: number): string
    local characterSets = {{97, 122}, {65, 90}, {48, 57}}
    local randomString = ""

    for i = 1, length do
        math.randomseed(tick() ^ 5)
        local set = characterSets[math.random(1, #characterSets)]
        randomString = randomString .. string.char(math.random(set[1], set[2]))
    end
    return randomString
end

-- // This function will return a hit position for bullet.
function cfun.predictP(pData: pInfo, hitPart: Instance, pFrom: Vector3?): Vector3
    local distance = (hitPart.CFrame.p - (pFrom or workspace.CurrentCamera.CFrame.p)).Magnitude
    local timeToHit = distance / pData.Speed
    local velocity = hitPart.Velocity + Vector3.new(0, pData.Gravity * (timeToHit / 2), 0)
    local hitPos = hitPart.CFrame.p + (velocity * timeToHit)

    return hitPos
end

-- // This function will return a direction where the bullet needs to fly.
function cfun.predictU(pData: pInfo, hitPart: Instance, pFrom: Vector3): Vector3
    local distance = (hitPart.CFrame.p - workspace.CurrentCamera.CFrame.p).Magnitude
    local timeToHit = distance / pData.Speed
    local velocity = hitPart.Velocity + Vector3.new(0, pData.Gravity * (timeToHit / 2), 0)
    local hitPos = ((hitPart.CFrame.p + (velocity * timeToHit)) - pFrom).Unit

    return hitPos
end

function cfun.calc2dbox(char: Model): Vector2?
    return
end

return cfun
