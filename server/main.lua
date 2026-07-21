local ESX = exports['es_extended']:getSharedObject()

-- ============================================
-- DATABASE INITIALIZATION
-- ============================================
function InitializeDatabase()
    MySQL.Async.execute('CREATE TABLE IF NOT EXISTS `dispatch_calls` (
        `id` int(11) NOT NULL AUTO_INCREMENT,
        `call_type` varchar(50) NOT NULL,
        `coords` varchar(50) NOT NULL,
        `description` varchar(255),
        `created_by` varchar(50),
        `assigned_to` varchar(50),
        `status` varchar(20) DEFAULT "pending",
        `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
        `closed_at` timestamp NULL,
        PRIMARY KEY (`id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;', {}, function(rowsChanged)
        print('^2[Dispatch] Dispatch table initialized^7')
    end)

    MySQL.Async.execute('CREATE TABLE IF NOT EXISTS `player_wanted` (
        `id` int(11) NOT NULL AUTO_INCREMENT,
        `citizen_id` varchar(50) NOT NULL UNIQUE,
        `wanted_level` int(11) DEFAULT 0,
        `reason` varchar(255),
        `set_by` varchar(50),
        `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (`id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;', {}, function(rowsChanged)
        print('^2[Police] Wanted table initialized^7')
    end)

    MySQL.Async.execute('CREATE TABLE IF NOT EXISTS `player_jail` (
        `id` int(11) NOT NULL AUTO_INCREMENT,
        `citizen_id` varchar(50) NOT NULL UNIQUE,
        `jail_time` int(11) NOT NULL,
        `reason` varchar(255),
        `jailed_by` varchar(50),
        `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (`id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;', {}, function(rowsChanged)
        print('^2[Jail] Jail table initialized^7')
    end)
end

-- Wait for MySQL to be ready
if GetResourceState('mysql-async') == 'started' then
    InitializeDatabase()
else
    AddEventHandler('onServerResourceStart', function(resourceName)
        if resourceName == 'mysql-async' then
            InitializeDatabase()
        end
    end)
end

-- ============================================
-- POLICE ONLINE COUNT
-- ============================================
function GetPoliceCount()
    local count = 0
    for _, xPlayer in ipairs(ESX.GetPlayers()) do
        local player = ESX.GetPlayerFromId(xPlayer)
        if player and player.job.name == Config.PoliceJob then
            count = count + 1
        end
    end
    return count
end

exports('getPoliceCount', GetPoliceCount)

-- ============================================
-- PLAYER EVENTS
-- ============================================
AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
    -- Load wanted level on login
    MySQL.Async.fetchAll('SELECT * FROM player_wanted WHERE citizen_id = @citizen_id', {
        ['@citizen_id'] = xPlayer.citizenid
    }, function(result)
        if result[1] then
            TriggerClientEvent('dispatch:setWantedLevel', playerId, result[1].wanted_level)
        end
    end)
end)

-- ============================================
-- POLICE DUTY SYSTEM
-- ============================================
local onDuty = {}

RegisterCommand(Config.Commands.duty, function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not xPlayer or xPlayer.job.name ~= Config.PoliceJob then
        TriggerClientEvent('ox_lib:notify', source, {
            title = _U('error'),
            description = _U('not_police'),
            type = 'error'
        })
        return
    end

    if onDuty[source] then
        onDuty[source] = false
        TriggerClientEvent('ox_lib:notify', source, {
            title = _U('success'),
            description = _U('police_duty_off'),
            type = 'success'
        })
    else
        onDuty[source] = true
        TriggerClientEvent('ox_lib:notify', source, {
            title = _U('success'),
            description = _U('police_duty_on'),
            type = 'success'
        })
    end

    -- Notify all police of duty change
    for _, xP in ipairs(ESX.GetPlayers()) do
        local player = ESX.GetPlayerFromId(xP)
        if player and player.job.name == Config.PoliceJob then
            TriggerClientEvent('dispatch:updatePoliceStatus', xP, source, onDuty[source])
        end
    end
end, false)

-- ============================================
-- EXPORT: SET WANTED
-- ============================================
function SetPlayerWanted(playerId, wantedLevel, reason)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then return false end

    if wantedLevel < 0 or wantedLevel > 5 then
        return false
    end

    MySQL.Async.execute('INSERT INTO player_wanted (citizen_id, wanted_level, reason) VALUES (@citizen_id, @wanted_level, @reason) ON DUPLICATE KEY UPDATE wanted_level = @wanted_level, reason = @reason', {
        ['@citizen_id'] = xPlayer.citizenid,
        ['@wanted_level'] = wantedLevel,
        ['@reason'] = reason or 'No reason provided'
    }, function(rowsChanged)
        TriggerClientEvent('dispatch:setWantedLevel', playerId, wantedLevel)
        
        -- Notify all police
        for _, xP in ipairs(ESX.GetPlayers()) do
            local player = ESX.GetPlayerFromId(xP)
            if player and player.job.name == Config.PoliceJob then
                TriggerClientEvent('ox_lib:notify', xP, {
                    title = _U('set_wanted'),
                    description = string.format(_U('set_wanted'), xPlayer.name, wantedLevel),
                    type = 'inform'
                })
            end
        end
    end)

    return true
end

exports('setPlayerWanted', SetPlayerWanted)

-- ============================================
-- EXPORT: GET WANTED
-- ============================================
function GetPlayerWanted(citizenId)
    local promise = promise.new()
    
    MySQL.Async.fetchAll('SELECT wanted_level FROM player_wanted WHERE citizen_id = @citizen_id', {
        ['@citizen_id'] = citizenId
    }, function(result)
        if result[1] then
            promise:resolve(result[1].wanted_level)
        else
            promise:resolve(0)
        end
    end)

    return Citizen.Await(promise)
end

exports('getPlayerWanted', GetPlayerWanted)

-- ============================================
-- PRINT STARTUP INFO
-- ============================================
print('^2[Dispatch-MDT-Police] Server started successfully!^7')
print('^3Police Job: ^7' .. Config.PoliceJob)
print('^3Database: ^7MariaDB (ESX Legacy 1.14.0)')
