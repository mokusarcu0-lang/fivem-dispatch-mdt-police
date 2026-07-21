local ESX = exports['es_extended']:getSharedObject()

-- ============================================
-- POLICE JOB SYSTEM
-- ============================================

-- Get police count
function GetOnDutyPolice()
    local count = 0
    for _, xPlayer in ipairs(ESX.GetPlayers()) do
        local player = ESX.GetPlayerFromId(xPlayer)
        if player and player.job.name == Config.PoliceJob then
            count = count + 1
        end
    end
    return count
end

-- Arrest command
RegisterCommand(Config.Commands.jail, function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer or xPlayer.job.name ~= Config.PoliceJob then
        TriggerClientEvent('ox_lib:notify', source, {
            title = _U('error'),
            description = _U('not_police'),
            type = 'error'
        })
        return
    end

    if #args < 2 then
        TriggerClientEvent('ox_lib:notify', source, {
            title = _U('error'),
            description = _U('cmd_jail_help'),
            type = 'error'
        })
        return
    end

    local targetId = tonumber(args[1])
    local jailTime = tonumber(args[2])
    local reason = args[3] or 'No reason provided'

    if not targetId or not jailTime then
        TriggerClientEvent('ox_lib:notify', source, {
            title = _U('error'),
            description = 'Invalid ID or time',
            type = 'error'
        })
        return
    end

    local targetPlayer = ESX.GetPlayerFromId(targetId)
    if not targetPlayer then
        TriggerClientEvent('ox_lib:notify', source, {
            title = _U('error'),
            description = 'Player not found',
            type = 'error'
        })
        return
    end

    -- Jail the player
    TriggerEvent('police:jailPlayer', targetId, jailTime, reason, source)
end, false)

-- Unjail command
RegisterCommand(Config.Commands.unjail, function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer or xPlayer.job.name ~= Config.PoliceJob or xPlayer.job.grade < 2 then
        TriggerClientEvent('ox_lib:notify', source, {
            title = _U('error'),
            description = _U('not_police'),
            type = 'error'
        })
        return
    end

    if #args < 1 then
        TriggerClientEvent('ox_lib:notify', source, {
            title = _U('error'),
            description = _U('cmd_unjail_help'),
            type = 'error'
        })
        return
    end

    local targetId = tonumber(args[1])
    if not targetId then
        TriggerClientEvent('ox_lib:notify', source, {
            title = _U('error'),
            description = 'Invalid ID',
            type = 'error'
        })
        return
    end

    local targetPlayer = ESX.GetPlayerFromId(targetId)
    if not targetPlayer then
        TriggerClientEvent('ox_lib:notify', source, {
            title = _U('error'),
            description = 'Player not found',
            type = 'error'
        })
        return
    end

    -- Unjail the player
    TriggerEvent('police:unjailPlayer', targetId, source)
end, false)

-- Set wanted level command
RegisterCommand(Config.Commands.wanted, function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer or xPlayer.job.name ~= Config.PoliceJob then
        TriggerClientEvent('ox_lib:notify', source, {
            title = _U('error'),
            description = _U('not_police'),
            type = 'error'
        })
        return
    end

    if #args < 2 then
        TriggerClientEvent('ox_lib:notify', source, {
            title = _U('error'),
            description = _U('cmd_wanted_help'),
            type = 'error'
        })
        return
    end

    local targetId = tonumber(args[1])
    local wantedLevel = tonumber(args[2])
    local reason = args[3] or 'No reason'

    if not targetId or not wantedLevel or wantedLevel < 0 or wantedLevel > 5 then
        TriggerClientEvent('ox_lib:notify', source, {
            title = _U('error'),
            description = 'Invalid ID or wanted level (0-5)',
            type = 'error'
        })
        return
    end

    local targetPlayer = ESX.GetPlayerFromId(targetId)
    if not targetPlayer then
        TriggerClientEvent('ox_lib:notify', source, {
            title = _U('error'),
            description = 'Player not found',
            type = 'error'
        })
        return
    end

    -- Set wanted
    exports['dispatch-mdt-police']:setPlayerWanted(targetId, wantedLevel, reason)

    TriggerClientEvent('ox_lib:notify', source, {
        title = _U('success'),
        description = string.format(_U('set_wanted'), targetPlayer.name, wantedLevel),
        type = 'success'
    })
end, false)

-- Police activity log
function LogPoliceAction(playerId, action, details)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then return end

    MySQL.Async.execute('INSERT INTO police_logs (player_name, player_id, action, details, created_at) VALUES (@name, @id, @action, @details, NOW())', {
        ['@name'] = xPlayer.name,
        ['@id'] = xPlayer.citizenid,
        ['@action'] = action,
        ['@details'] = details
    }, function() end)
end

-- Create police logs table
MySQL.Async.execute('CREATE TABLE IF NOT EXISTS `police_logs` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `player_name` varchar(50),
    `player_id` varchar(50),
    `action` varchar(100),
    `details` text,
    `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;', {})

print('^2[Police] Police job system loaded!^7')
