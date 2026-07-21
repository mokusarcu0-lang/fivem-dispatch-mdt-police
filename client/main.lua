local ESX = exports['es_extended']:getSharedObject()

-- ============================================
-- CLIENT INITIALIZATION
-- ============================================
local playerJob = nil
local isOnDuty = false
local playerWanted = 0

AddEventHandler('esx:setJob', function(job)
    playerJob = job
end)

-- On player load
AddEventHandler('esx:playerLoaded', function()
    ESX.TriggerServerCallback('esx:getPlayerData', function(data)
        playerJob = data.job
    end)
end)

-- ============================================
-- NOTIFICATIONS
-- ============================================
function NotifyPolice(title, description, type)
    lib.notify({
        title = title,
        description = description,
        type = type or 'inform',
        duration = 5000,
        position = 'top-right'
    })
end

-- ============================================
-- WANTED LEVEL SYNC
-- ============================================
RegisterNetEvent('dispatch:setWantedLevel')
AddEventHandler('dispatch:setWantedLevel', function(level)
    playerWanted = level
    SetPlayerWantedLevel(PlayerId(), level, false)
end)

RegisterNetEvent('dispatch:updatePoliceStatus')
AddEventHandler('dispatch:updatePoliceStatus', function(playerId, onDuty)
    if playerId == GetPlayerServerId(PlayerId()) then
        isOnDuty = onDuty
    end
end)

-- ============================================
-- POLICE JOB CHECK
-- ============================================
function IsPolice()
    return playerJob and playerJob.name == Config.PoliceJob
end

function GetPoliceGrade()
    return playerJob and playerJob.grade or -1
end

-- ============================================
-- PRINT STARTUP INFO
-- ============================================
print('^2[Dispatch-MDT-Police] Client started successfully!^7')
print('^3ESX Legacy: ^71.14.0')
print('^3Police Job: ^7' .. Config.PoliceJob)
