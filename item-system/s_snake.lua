addEvent('snakecam:toggleSnakeCam', true)

local snakecams = {}

--// Ripped from interior-system and edited // 18-3-2013
function snakecam_isPlayerNearInterior(thePlayer)
    local posX, posY, posZ = getElementPosition(thePlayer)
    local dimension = getElementDimension(thePlayer)
    local count = 0
    local possibleInteriors = getElementsByType("interior")
    for _, interior in ipairs(possibleInteriors) do
        local interiorEntrance = getElementData(interior, "entrance")
        local interiorExit = getElementData(interior, "exit")

        for _, point in ipairs( { interiorEntrance, interiorExit } ) do
            if (point[5] == dimension) then
                local distance = getDistanceBetweenPoints3D(posX, posY, posZ, point[1], point[2], point[3])
                if (distance <= 2) then
                    local dbid = getElementData(interior, "dbid")
                    local interiorName = getElementData(interior, "name")
                    count = count + 1
                    if dimension == 0 then
                        return true, { interiorExit[1], interiorExit[2], interiorExit[3], interiorExit[5], interiorExit[4], interiorEntrance[1], interiorEntrance[2], interiorEntrance[3], dimension, getElementInterior(thePlayer) }
                    else
                        return true, { interiorEntrance[1], interiorEntrance[2], interiorEntrance[3], interiorEntrance[5], interiorEntrance[4], interiorExit[1], interiorExit[2], interiorExit[3], dimension, getElementInterior(thePlayer) }
                    end
                end
            end
        end
    end

    if (count==0) then
        return false, 'NOH!'
    end
end

function snakecam_toggleSnakeCam(p)
    local theTeam = getPlayerTeam(p)
    local teamID = getElementData(theTeam, "id")
    if exports.integration:isPlayerAdmin(p) or teamID == 1 or teamID == 59 and (getElementData(p, "duty") > 0) then
        if not snakecams[p] then
            local nearInterior, pos = snakecam_isPlayerNearInterior(p)
            if nearInterior then
                local x, y, z = getElementPosition(p)
                local rx, ry, rz = getElementRotation(p)
                local int, dim = getElementInterior(p), getElementDimension(p)
                snakecams[p] = createPed(getElementModel(p), x, y, z)
                setElementRotation(snakecams[p], rx, ry, rz)
                setElementInterior(snakecams[p], int)
                setElementDimension(snakecams[p], dim)
                triggerClientEvent(p, 'snakecam:toggleClientSnakeCam', p, pos, true)
                exports.global:sendLocalMeAction(p, "slips a snake cam under the door.")
            else
                outputChatBox('You are not near an interior!', p, 255, 0, 0, false)
            end
        else
            triggerClientEvent(p, 'snakecam:toggleClientSnakeCam', p, pos, false)
            exports.global:sendLocalMeAction(p, "slips a snake cam out from under the door.")
            destroyElement(snakecams[p])
            snakecams[p] = nil
        end
    end
end
addEventHandler('snakecam:toggleSnakeCam', root, snakecam_toggleSnakeCam)
addCommandHandler('snakecam', snakecam_toggleSnakeCam)

addEventHandler('onPlayerQuit', root,
function()
    if snakecams[source] then
        destroyElement(snakecams[source])
        snakecams[source] = nil
    end
end)

addEventHandler('onPlayerWasted', root,
function()
    if snakecams[source] then
        destroyElement(snakecams[source])
        snakecams[source] = nil
        setCameraTarget(source, source)
        triggerClientEvent(source, 'snakecam:toggleClientSnakeCam', source, { 0, 0, 3, 0, 0, 0, 0, 3, 0, 0 }, false)
    end
end)
