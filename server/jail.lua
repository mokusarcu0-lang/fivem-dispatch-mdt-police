local ESX = exports['es_extended']:getSharedObject()

-- ============================================
-- JAIL SYSTEM
-- ============================================

local jailedPlayers = {}

-- Jail a player
function JailPlayer(playerId, jailTime, reason, officer)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then return false end

    -- Check if jail is available
    MySQL.Async.fetchAll('SELECT COUNT(*) as count FROM player_jail', {}, function(result)
        if result[1].count >= Config.JailCells then
            print('^1[Jail] No available cells!^7')
            return false
        end
    end)

    -- Save to database
    MySQL.Async.execute('INSERT INTO player_jail (citizen_id, jail_time, reason, jailed_by) VALUES (@citizen_id, @jail_time, @reason, @jailed_by) ON DUPLICATE KEY UPDATE jail_time = @jail_time, reason = @reason, jailed_by = @jailed_by', {
        ['@citizen_id'] = xPlayer.citizenid,
        ['@jail_time'] = jailTime,
        ['@reason'] = reason,
        ['@jailed_by'] = officer and ESX.GetPlayerFromId(officer).name or 'System'
    }, function(rowsChanged)
        jailedPlayers[playerId] = {
            citizen_id = xPlayer.citizenid,
            remaining_time = jailTime,
            reason = reason,
            jailed_at = os.time()
        }

        -- Notify player
        TriggerClientEvent('ox_lib:notify', playerId, {
            title = _U('jail_player'),
            description = string.format(_U('jail_player'), jailTime),
            type = 'error',
            duration = 5000
        })

        -- Notify officer
        if officer then
            TriggerClientEvent('ox_lib:notify', officer, {
                title = _U('success'),
                description = string.format(_U('jail_player'), xPlayer.name, jailTime),
                type = 'success'
            })
        end

        -- Move player to jail
        TriggerClientEvent('jail:sendToJail', playerId, Config.JailLocations[1].inCell)

        -- Start jail timer
        StartJailTimer(playerId, jailTime)
    end)

    return true
end

-- Unjail a player
function UnjailPlayer(playerId, officer)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then return false end

    MySQL.Async.execute('DELETE FROM player_jail WHERE citizen_id = @citizen_id', {
        ['@citizen_id'] = xPlayer.citizenid
    }, function(rowsChanged)
        jailedPlayers[playerId] = nil

        TriggerClientEvent('ox_lib:notify', playerId, {
            title = _U('success'),
            description = _U('released_from_jail'),
            type = 'success'
        })

        if officer then
            local officerPlayer = ESX.GetPlayerFromId(officer)
            if officerPlayer then
                TriggerClientEvent('ox_lib:notify', officer, {
                    title = _U('success'),
                    description = string.format(_U('unjail_player'), xPlayer.name),
                    type = 'success'
                })
            end
        end

        -- Release player from jail
        TriggerClientEvent('jail:releaseFromJail', playerId)
    end)

    return true
end

-- Jail timer
function StartJailTimer(playerId, jailTime)
    local remaining = jailTime
    local startTime = os.time()

    local timer = SetInterval(function()
        if not jailedPlayers[playerId] then
            ClearInterval(timer)
            return
        end

        remaining = jailTime - (os.time() - startTime)

        if remaining <= 0 then
            UnjailPlayer(playerId, nil)
            ClearInterval(timer)
        else
            -- Notify player every 60 seconds
            if remaining % 60 == 0 then
                TriggerClientEvent('ox_lib:notify', playerId, {
                    title = _U('jail_remaining'),
                    description = string.format(_U('jail_remaining'), remaining),
                    type = 'inform'
                })
            end
        end
    end, 1000)
end

-- Export functions
function ExportJailPlayer(playerId, jailTime, reason)
    return JailPlayer(playerId, jailTime, reason, nil)
end

function ExportUnjailPlayer(playerId)
    return UnjailPlayer(playerId, nil)
end

exports('jailPlayer', ExportJailPlayer)
exports('unjailPlayer', ExportUnjailPlayer)

-- Handle player disconnect - release from jail
AddEventHandler('esx:playerDropped', function(playerId, reason)
    if jailedPlayers[playerId] then
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer then
            MySQL.Async.execute('DELETE FROM player_jail WHERE citizen_id = @citizen_id', {
                ['@citizen_id'] = xPlayer.citizenid
            })
        end
        jailedPlayers[playerId] = nil
    end
end)

-- Load jail data on player load
AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
    MySQL.Async.fetchAll('SELECT * FROM player_jail WHERE citizen_id = @citizen_id', {
        ['@citizen_id'] = xPlayer.citizenid
    }, function(result)
        if result[1] then
            local jailData = result[1]
            local timeJailed = os.time() - os.date('%s', jailData.created_at)
            local remaining = jailData.jail_time - timeJailed

            if remaining > 0 then
                jailedPlayers[playerId] = {
                    citizen_id = xPlayer.citizenid,
                    remaining_time = remaining,
                    reason = jailData.reason,
                    jailed_at = os.time()
                }

                -- Send to jail
                TriggerClientEvent('jail:sendToJail', playerId, Config.JailLocations[1].inCell)

                -- Start timer
                StartJailTimer(playerId, remaining)
            else
                -- Time already served, release
                UnjailPlayer(playerId, nil)
            end
        end
    end)
end)

print('^2[Jail] Jail system loaded!^7')
