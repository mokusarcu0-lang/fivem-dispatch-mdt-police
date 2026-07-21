local ESX = exports['es_extended']:getSharedObject()

-- ============================================
-- MDT UI STATE
-- ============================================
local mdtOpen = false
local currentVehicleInfo = nil
local currentPlayerInfo = nil

-- ============================================
-- MDT OPEN/CLOSE
-- ============================================
RegisterCommand(Config.Commands.mdt, function(source, args, rawCommand)
    if not IsPolice() then
        NotifyPolice(_U('error'), _U('not_police'), 'error')
        return
    end

    if mdtOpen then
        CloseMDT()
    else
        OpenMDT()
    end
end, false)

function OpenMDT()
    if not IsPolice() then return end

    mdtOpen = true
    SetNuiFocus(true, true)
    SendReactMessage('openMDT', {
        locale = Config.Locale
    })
end

function CloseMDT()
    mdtOpen = false
    SetNuiFocus(false, false)
    SendReactMessage('closeMDT', {})
end

-- ============================================
-- MDT VEHICLE SEARCH
-- ============================================
RegisterNetEvent('mdt:getVehicleData')
AddEventHandler('mdt:getVehicleData', function(plate)
    if not IsPolice() then return end

    TriggerServerEvent('mdt:getVehicleInfo', plate)
end)

RegisterNetEvent('mdt:vehicleInfoResponse')
AddEventHandler('mdt:vehicleInfoResponse', function(vehicleData)
    if vehicleData then
        currentVehicleInfo = vehicleData
        SendReactMessage('vehicleInfoResponse', vehicleData)
    else
        NotifyPolice(_U('error'), 'Jármű nem található', 'error')
        SendReactMessage('vehicleInfoResponse', nil)
    end
end)

-- ============================================
-- MDT PLAYER SEARCH
-- ============================================
RegisterNetEvent('mdt:getPlayerData')
AddEventHandler('mdt:getPlayerData', function(identifier)
    if not IsPolice() then return end

    TriggerServerEvent('mdt:getPlayerInfo', identifier)
end)

RegisterNetEvent('mdt:playerInfoResponse')
AddEventHandler('mdt:playerInfoResponse', function(playerData)
    if playerData then
        currentPlayerInfo = playerData
        SendReactMessage('playerInfoResponse', playerData)
    else
        NotifyPolice(_U('error'), 'Játékos nem található', 'error')
        SendReactMessage('playerInfoResponse', nil)
    end
end)

-- ============================================
-- MDT SEARCH BY NAME
-- ============================================
RegisterNetEvent('mdt:searchPlayers')
AddEventHandler('mdt:searchPlayers', function(searchName)
    if not IsPolice() then return end

    TriggerServerEvent('mdt:searchPlayer', searchName)
end)

RegisterNetEvent('mdt:searchResultsResponse')
AddEventHandler('mdt:searchResultsResponse', function(results)
    SendReactMessage('searchResultsResponse', results)
end)

-- ============================================
-- MDT DISPATCH CALLS
-- ============================================
RegisterNetEvent('mdt:loadDispatchCalls')
AddEventHandler('mdt:loadDispatchCalls', function()
    if not IsPolice() then return end

    TriggerServerEvent('mdt:getDispatchCalls')
end)

RegisterNetEvent('mdt:dispatchCallsResponse')
AddEventHandler('mdt:dispatchCallsResponse', function(calls)
    SendReactMessage('dispatchCallsResponse', calls)
end)

-- ============================================
-- MDT NOTES
-- ============================================
RegisterNetEvent('mdt:addPlayerNote')
AddEventHandler('mdt:addPlayerNote', function(citizenId, note)
    if not IsPolice() then return end

    TriggerServerEvent('mdt:addNote', citizenId, note)
end)

RegisterNetEvent('mdt:loadPlayerNotes')
AddEventHandler('mdt:loadPlayerNotes', function(citizenId)
    if not IsPolice() then return end

    TriggerServerEvent('mdt:getNotes', citizenId)
end)

RegisterNetEvent('mdt:notesResponse')
AddEventHandler('mdt:notesResponse', function(notes)
    SendReactMessage('notesResponse', notes)
end)

-- ============================================
-- NUI CALLBACKS
-- ============================================
RegisterNUICallback('closeMDT', function(data, cb)
    CloseMDT()
    cb('ok')
end)

RegisterNUICallback('searchVehicle', function(data, cb)
    TriggerServerEvent('mdt:getVehicleInfo', data.plate)
    cb('ok')
end)

RegisterNUICallback('searchPlayer', function(data, cb)
    TriggerServerEvent('mdt:getPlayerInfo', data.identifier)
    cb('ok')
end)

RegisterNUICallback('searchPlayers', function(data, cb)
    TriggerServerEvent('mdt:searchPlayer', data.name)
    cb('ok')
end)

RegisterNUICallback('getDispatchCalls', function(data, cb)
    TriggerServerEvent('mdt:getDispatchCalls')
    cb('ok')
end)

RegisterNUICallback('addNote', function(data, cb)
    TriggerServerEvent('mdt:addNote', data.citizenId, data.note)
    cb('ok')
end)

RegisterNUICallback('getNotes', function(data, cb)
    TriggerServerEvent('mdt:getNotes', data.citizenId)
    cb('ok')
end)

-- ============================================
-- SEND MESSAGE TO REACT
-- ============================================
function SendReactMessage(event, data)
    SendNUIMessage({
        action = event,
        data = data
    })
end

print('^2[MDT] MDT client loaded!^7')
