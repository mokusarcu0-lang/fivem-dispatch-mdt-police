local ESX = exports['es_extended']:getSharedObject()

-- ============================================
-- DISPATCH BLIPS
-- ============================================
local dispatchBlips = {}
local activeCalls = {}

-- New dispatch call received
RegisterNetEvent('dispatch:newCall')
AddEventHandler('dispatch:newCall', function(callData)
    if not IsPolice() then return end

    activeCalls[callData.id] = callData

    -- Create blip
    local blip = AddBlipForCoord(callData.coords.x, callData.coords.y, callData.coords.z)
    SetBlipAsNoLongerNeeded(blip)
    SetBlipRoute(blip, true)
    SetBlipColour(blip, callData.color[1])
    
    SetBlipSprite(blip, Config.DispatchBlip.sprite)
    SetBlipDisplay(blip, Config.DispatchBlip.display)
    SetBlipScale(blip, Config.DispatchBlip.scale)
    
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentString(callData.description)
    EndTextCommandDisplayHelp(0)

    dispatchBlips[callData.id] = blip
end)

-- Update dispatch call
RegisterNetEvent('dispatch:updateCall')
AddEventHandler('dispatch:updateCall', function(callId, callData)
    activeCalls[callId] = callData
end)

-- Call closed
RegisterNetEvent('dispatch:callClosed')
AddEventHandler('dispatch:callClosed', function(callId)
    if dispatchBlips[callId] then
        RemoveBlip(dispatchBlips[callId])
        dispatchBlips[callId] = nil
    end
    activeCalls[callId] = nil
end)

-- Set GPS to dispatch location
RegisterNetEvent('dispatch:setGPS')
AddEventHandler('dispatch:setGPS', function(coords)
    if not IsPolice() then return end
    
    SetNewWaypoint(coords.x, coords.y)
    NotifyPolice('GPS', _U('dispatch_gps'), 'success')
end)

-- ============================================
-- DISPATCH UI (ox_lib)
-- ============================================
RegisterNetEvent('dispatch:openUI')
AddEventHandler('dispatch:openUI', function()
    if not IsPolice() then return end

    local dispatchTypes = {}
    for _, dispatchType in ipairs(Config.DispatchTypes) do
        table.insert(dispatchTypes, {
            label = dispatchType.label,
            value = dispatchType.name
        })
    end

    local input = lib.inputDialog('Új Hívás Létrehozása', {
        {type = 'select', label = 'Hívás Típusa', options = dispatchTypes, required = true},
        {type = 'input', label = 'Leírás', placeholder = 'Add meg a hívás leírását...', required = true}
    })

    if input then
        TriggerServerEvent('dispatch:createFromUI', input[1], input[2])
    end
end)

-- Accept call context menu
exports['ox_lib']:registerContextMenu({
    id = 'dispatch_accept',
    title = 'Hívás Elfogadása',
    options = {
        {
            label = 'Elfogadom',
            icon = 'fas fa-check',
            onSelect = function()
                local callId = nil
                -- Get nearest unclaimed call
                for id, call in pairs(activeCalls) do
                    if not call.assigned_to then
                        callId = id
                        break
                    end
                end

                if callId then
                    TriggerServerEvent('dispatch:acceptCall', callId)
                else
                    NotifyPolice('Hiba', 'Nincs elérhető hívás', 'error')
                end
            end
        }
    }
})

-- Close call context menu
exports['ox_lib']:registerContextMenu({
    id = 'dispatch_close',
    title = 'Hívás Lezárása',
    options = {
        {
            label = 'Lezárom',
            icon = 'fas fa-times',
            onSelect = function()
                local callId = nil
                -- Get current assigned call
                for id, call in pairs(activeCalls) do
                    if call.assigned_to == ESX.GetPlayerName() then
                        callId = id
                        break
                    end
                end

                if callId then
                    TriggerServerEvent('dispatch:closeCall', callId)
                    NotifyPolice('Siker', _U('dispatch_closed'), 'success')
                else
                    NotifyPolice('Hiba', 'Nincs aktív hívásod', 'error')
                end
            end
        }
    }
})

-- ============================================
-- GET ACTIVE CALLS
-- ============================================
function GetActiveCalls()
    TriggerServerEvent('dispatch:getActiveCalls')
end

RegisterNetEvent('dispatch:receiveActiveCalls')
AddEventHandler('dispatch:receiveActiveCalls', function(calls)
    activeCalls = {}
    for _, call in ipairs(calls) do
        activeCalls[call.id] = call
    end
end)

-- ============================================
-- DISPATCH COMMANDS
-- ============================================
RegisterCommand(Config.Commands.dispatch, function(source, args, rawCommand)
    if not IsPolice() then
        NotifyPolice(_U('error'), _U('not_police'), 'error')
        return
    end

    TriggerEvent('dispatch:openUI')
end, false)

print('^2[Dispatch] Dispatch client loaded!^7')
