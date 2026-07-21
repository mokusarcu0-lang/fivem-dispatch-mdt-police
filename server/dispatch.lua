local ESX = exports['es_extended']:getSharedObject()

-- ============================================
-- DISPATCH CALLS MANAGEMENT
-- ============================================
local activeCalls = {}
local callId = 0

-- Create a new dispatch call
function CreateDispatchCall(type, description, coords, playerId)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then return false end

    callId = callId + 1
    
    local callData = {
        id = callId,
        type = type,
        description = description,
        coords = coords,
        created_by = xPlayer.name,
        created_by_id = playerId,
        assigned_to = nil,
        status = 'pending',
        created_at = os.time()
    }

    -- Save to database
    MySQL.Async.execute('INSERT INTO dispatch_calls (call_type, coords, description, created_by, status) VALUES (@type, @coords, @description, @created_by, @status)', {
        ['@type'] = type,
        ['@coords'] = json.encode(coords),
        ['@description'] = description,
        ['@created_by'] = xPlayer.name,
        ['@status'] = 'pending'
    }, function(rowsChanged)
        activeCalls[callId] = callData
    end)

    -- Notify all police
    for _, xP in ipairs(ESX.GetPlayers()) do
        local player = ESX.GetPlayerFromId(xP)
        if player and player.job.name == Config.PoliceJob then
            TriggerClientEvent('dispatch:newCall', xP, callData)
            TriggerClientEvent('ox_lib:notify', xP, {
                title = _U('dispatch_created'),
                description = description,
                type = 'inform',
                duration = 5000
            })
        end
    end

    return callId
end

-- Accept dispatch call
RegisterServerEvent('dispatch:acceptCall')
AddEventHandler('dispatch:acceptCall', function(callId)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer or xPlayer.job.name ~= Config.PoliceJob then return end

    if activeCalls[callId] then
        activeCalls[callId].assigned_to = xPlayer.name
        activeCalls[callId].status = 'assigned'

        -- Update database
        MySQL.Async.execute('UPDATE dispatch_calls SET assigned_to = @assigned_to, status = @status WHERE id = @id', {
            ['@assigned_to'] = xPlayer.name,
            ['@status'] = 'assigned',
            ['@id'] = callId
        })

        -- Notify all police
        for _, xP in ipairs(ESX.GetPlayers()) do
            local player = ESX.GetPlayerFromId(xP)
            if player and player.job.name == Config.PoliceJob then
                TriggerClientEvent('dispatch:updateCall', xP, callId, activeCalls[callId])
            end
        end

        -- Set GPS for player
        TriggerClientEvent('dispatch:setGPS', source, activeCalls[callId].coords)
    end
end)

-- Close dispatch call
RegisterServerEvent('dispatch:closeCall')
AddEventHandler('dispatch:closeCall', function(callId)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer or xPlayer.job.name ~= Config.PoliceJob then return end

    if activeCalls[callId] then
        activeCalls[callId].status = 'closed'

        -- Update database
        MySQL.Async.execute('UPDATE dispatch_calls SET status = @status, closed_at = NOW() WHERE id = @id', {
            ['@status'] = 'closed',
            ['@id'] = callId
        })

        -- Notify all police
        for _, xP in ipairs(ESX.GetPlayers()) do
            local player = ESX.GetPlayerFromId(xP)
            if player and player.job.name == Config.PoliceJob then
                TriggerClientEvent('dispatch:callClosed', xP, callId)
            end
        end

        -- Remove from active calls after delay
        SetTimeout(5000, function()
            activeCalls[callId] = nil
        end)
    end
end)

-- Get all active calls
RegisterServerEvent('dispatch:getActiveCalls')
AddEventHandler('dispatch:getActiveCalls', function()
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer or xPlayer.job.name ~= Config.PoliceJob then return end

    local calls = {}
    for id, call in pairs(activeCalls) do
        if call.status ~= 'closed' then
            table.insert(calls, call)
        end
    end

    TriggerClientEvent('dispatch:receiveActiveCalls', source, calls)
end)

-- ============================================
-- DISPATCH COMMAND
-- ============================================
RegisterCommand(Config.Commands.dispatch, function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not xPlayer or xPlayer.job.name ~= Config.PoliceJob then
        TriggerClientEvent('ox_lib:notify', source, {
            title = _U('error'),
            description = _U('not_police'),
            type = 'error'
        })
        return
    end

    -- Open dispatch UI
    TriggerClientEvent('dispatch:openUI', source)
end, false)

-- Create dispatch from UI
RegisterServerEvent('dispatch:createFromUI')
AddEventHandler('dispatch:createFromUI', function(type, description)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer or xPlayer.job.name ~= Config.PoliceJob then return end

    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)

    CreateDispatchCall(type, description, coords, source)

    TriggerClientEvent('ox_lib:notify', source, {
        title = _U('success'),
        description = _U('dispatch_created'),
        type = 'success'
    })
end)

print('^2[Dispatch] Dispatch system loaded!^7')
