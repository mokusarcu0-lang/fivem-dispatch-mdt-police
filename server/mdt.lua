local ESX = exports['es_extended']:getSharedObject()

-- ============================================
-- MDT SYSTEM
-- ============================================

-- Get vehicle information
RegisterServerEvent('mdt:getVehicleInfo')
AddEventHandler('mdt:getVehicleInfo', function(plate)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer or xPlayer.job.name ~= Config.PoliceJob then return end

    MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE plate = @plate LIMIT 1', {
        ['@plate'] = plate
    }, function(result)
        if result[1] then
            local vehicleData = result[1]
            
            -- Get owner information
            MySQL.Async.fetchAll('SELECT identifier, firstname, lastname FROM users WHERE identifier = @identifier LIMIT 1', {
                ['@identifier'] = vehicleData.owner
            }, function(userResult)
                if userResult[1] then
                    vehicleData.owner_name = userResult[1].firstname .. ' ' .. userResult[1].lastname
                    vehicleData.owner_id = userResult[1].identifier
                end
                
                TriggerClientEvent('mdt:vehicleInfoResponse', source, vehicleData)
            end)
        else
            TriggerClientEvent('mdt:vehicleInfoResponse', source, nil)
        end
    end)
end)

-- Get player/citizen information
RegisterServerEvent('mdt:getPlayerInfo')
AddEventHandler('mdt:getPlayerInfo', function(identifier)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer or xPlayer.job.name ~= Config.PoliceJob then return end

    MySQL.Async.fetchAll('SELECT * FROM users WHERE identifier = @identifier LIMIT 1', {
        ['@identifier'] = identifier
    }, function(result)
        if result[1] then
            local userData = result[1]
            
            -- Get wanted level
            MySQL.Async.fetchAll('SELECT wanted_level, reason FROM player_wanted WHERE citizen_id = @citizen_id LIMIT 1', {
                ['@citizen_id'] = identifier
            }, function(wantedResult)
                if wantedResult[1] then
                    userData.wanted_level = wantedResult[1].wanted_level
                    userData.wanted_reason = wantedResult[1].reason
                else
                    userData.wanted_level = 0
                    userData.wanted_reason = ''
                end
                
                -- Get jail status
                MySQL.Async.fetchAll('SELECT jail_time, reason FROM player_jail WHERE citizen_id = @citizen_id LIMIT 1', {
                    ['@citizen_id'] = identifier
                }, function(jailResult)
                    if jailResult[1] then
                        userData.jail_time = jailResult[1].jail_time
                        userData.jail_reason = jailResult[1].reason
                    else
                        userData.jail_time = 0
                        userData.jail_reason = ''
                    end
                    
                    TriggerClientEvent('mdt:playerInfoResponse', source, userData)
                end)
            end)
        else
            TriggerClientEvent('mdt:playerInfoResponse', source, nil)
        end
    end)
end)

-- Get all dispatch calls for MDT
RegisterServerEvent('mdt:getDispatchCalls')
AddEventHandler('mdt:getDispatchCalls', function()
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer or xPlayer.job.name ~= Config.PoliceJob then return end

    MySQL.Async.fetchAll('SELECT * FROM dispatch_calls WHERE status != "closed" ORDER BY created_at DESC LIMIT 50', {}, function(result)
        TriggerClientEvent('mdt:dispatchCallsResponse', source, result or {})
    end)
end)

-- Search player by name
RegisterServerEvent('mdt:searchPlayer')
AddEventHandler('mdt:searchPlayer', function(searchName)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer or xPlayer.job.name ~= Config.PoliceJob then return end

    MySQL.Async.fetchAll('SELECT identifier, firstname, lastname FROM users WHERE firstname LIKE @search OR lastname LIKE @search LIMIT 20', {
        ['@search'] = '%' .. searchName .. '%'
    }, function(result)
        TriggerClientEvent('mdt:searchResultsResponse', source, result or {})
    end)
end)

-- Add MDT note
RegisterServerEvent('mdt:addNote')
AddEventHandler('mdt:addNote', function(citizenId, note)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer or xPlayer.job.name ~= Config.PoliceJob then return end

    MySQL.Async.execute('INSERT INTO player_notes (citizen_id, note, created_by, created_at) VALUES (@citizen_id, @note, @created_by, NOW())', {
        ['@citizen_id'] = citizenId,
        ['@note'] = note,
        ['@created_by'] = xPlayer.name
    }, function(rowsChanged)
        TriggerClientEvent('ox_lib:notify', source, {
            title = _U('success'),
            description = 'Megjegyzés hozzáadva',
            type = 'success'
        })
    end)
end)

-- Get player notes
RegisterServerEvent('mdt:getNotes')
AddEventHandler('mdt:getNotes', function(citizenId)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer or xPlayer.job.name ~= Config.PoliceJob then return end

    MySQL.Async.execute('CREATE TABLE IF NOT EXISTS `player_notes` (
        `id` int(11) NOT NULL AUTO_INCREMENT,
        `citizen_id` varchar(50) NOT NULL,
        `note` text NOT NULL,
        `created_by` varchar(50),
        `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (`id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;', {})

    MySQL.Async.fetchAll('SELECT * FROM player_notes WHERE citizen_id = @citizen_id ORDER BY created_at DESC LIMIT 50', {
        ['@citizen_id'] = citizenId
    }, function(result)
        TriggerClientEvent('mdt:notesResponse', source, result or {})
    end)
end)

print('^2[MDT] MDT system loaded!^7')
