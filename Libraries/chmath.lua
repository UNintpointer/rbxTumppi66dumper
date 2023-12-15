-- [[ "Cheat Math" Library for developing (cheat) scripts for Roblox. | Updated 15.12.2023 | Discord: #tupsu, V3rmillion: Alpenglow ]] --

-- // Just to make it clear this is nowhere near finished because i have no way to test this as i have no executor rn. I will be updating this whenever i get some lovely executor.

local chmath = {}
chmath.__index = chmath

type pInfo = {
    Speed: number,
    Gravity: number
}

function chmath.avg(...: number): number?
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

function chmath.predictP(pData: pInfo, hitPart: Instance, pFrom: Vector3?): Vector3
    local distance = (hitPart.CFrame.p - (pFrom or workspace.CurrentCamera.CFrame.p)).Magnitude
    local timeToHit = distance / pData.Speed
    local velocity = hitPart.Velocity + Vector3.new(0, pData.Gravity * (timeToHit / 2), 0)
    local hitPos = hitPart.CFrame.p + (velocity * timeToHit)

    return hitPos
end

function chmath.predictU(pData: pInfo, hitPart: Instance, pFrom: Vector3): Vector3
    local distance = (hitPart.CFrame.p - workspace.CurrentCamera.CFrame.p).Magnitude
    local timeToHit = distance / pData.Speed
    local velocity = hitPart.Velocity + Vector3.new(0, pData.Gravity * (timeToHit / 2), 0)
    local hitPos = ((hitPart.CFrame.p + (velocity * timeToHit)) - pFrom).Unit

    return hitPos
end

function chmath.calc2dbox(char: Model): Vector2?
    return
end

return chmath
