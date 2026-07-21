local ESX = exports['es_extended']:getSharedObject()

-- ============================================
-- JAIL SYSTEM CLIENT
-- ============================================

local inJail = false
local jailTime = 0

-- Send player to jail
RegisterNetEvent('jail:sendToJail')
AddEventHandler('jail:sendToJail', function(jailCoords)
    inJail = true

    -- Teleport player
    SetEntityCoords(PlayerPedId(), jailCoords.x, jailCoords.y, jailCoords.z, false, false, false, false)
    SetEntityHeading(PlayerPedId(), 0.0)

    -- Freeze player
    FreezeEntityPosition(PlayerPedId(), true)

    NotifyPolice('Börtön', _U('released_from_jail'), 'error')
end)

-- Release player from jail
RegisterNetEvent('jail:releaseFromJail')
AddEventHandler('jail:releaseFromJail', function()
    inJail = false

    -- Unfreeze player
    FreezeEntityPosition(PlayerPedId(), false)

    NotifyPolice('Kibocsátás', _U('released_from_jail'), 'success')

    -- Teleport to exit
    local exitCoord = vector3(425.4, -979.5, 29.4)
    SetEntityCoords(PlayerPedId(), exitCoord.x, exitCoord.y, exitCoord.z, false, false, false, false)
end)

-- ============================================
-- JAIL ESCAPE PREVENTION
-- ============================================
Citizen.CreateThread(function()
    while true do
        Wait(1000)

        if inJail then
            local playerCoords = GetEntityCoords(PlayerPedId())
            local jailCoords = Config.JailLocations[1].inCell

            -- Check if player moved too far from jail
            local distance = GetDistanceBetweenCoords(playerCoords, jailCoords, true)
            if distance > 50.0 then
                -- Teleport back
                SetEntityCoords(PlayerPedId(), jailCoords.x, jailCoords.y, jailCoords.z, false, false, false, false)
                NotifyPolice('Börtön', 'Nem hagyhatsz el a börtönből!', 'error')
            end
        end
    end
end)

-- ============================================
-- JAIL CELL DOOR
-- ============================================
local jailDoorHash = GetHashKey('v_ilev_cor_door2')
local doorCoord = Config.JailLocations[1].coords

Citizen.CreateThread(function()
    while true do
        Wait(100)

        -- Check if any door is nearby
        local nearbyObjects = GetGamePool('CObject')
        for _, obj in ipairs(nearbyObjects) do
            if GetEntityModel(obj) == jailDoorHash then
                local objCoords = GetEntityCoords(obj)
                local distance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), objCoords, true)

                if distance < 5.0 and inJail then
                    FreezeEntityPosition(obj, true)
                    SetEntityNoCollisionEntity(PlayerPedId(), obj, false)
                end
            end
        end
    end
end)

-- ============================================
-- JAIL COMMANDS (for police)
-- ============================================
RegisterCommand('jailinfo', function(source, args, rawCommand)
    if not IsPolice() then
        NotifyPolice(_U('error'), _U('not_police'), 'error')
        return
    end

    NotifyPolice('Börtön Info', 'Max cella: ' .. Config.JailCells, 'inform')
end, false)

-- ============================================
-- JAIL TELEPORT (admin only)
-- ============================================
RegisterCommand('gotojail', function(source, args, rawCommand)
    if not IsPolice() then return end

    local jailCoords = Config.JailLocations[1].coords
    SetEntityCoords(PlayerPedId(), jailCoords.x, jailCoords.y, jailCoords.z, false, false, false, false)
    
    NotifyPolice('Teleport', 'Börtönbe teleportálva', 'success')
end, false)

print('^2[Jail] Jail client loaded!^7')
