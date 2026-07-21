local ESX = exports['es_extended']:getSharedObject()

-- ============================================
-- POLICE COMMANDS CLIENT
-- ============================================

-- Arrest animation
function ArrestAnimation(targetPlayerId)
    local ped = GetPlayerPed(targetPlayerId)
    if not ped then return end

    -- Hands up animation
    RequestAnimDict('combat@damage@rb_writhe')
    while not HasAnimDictLoaded('combat@damage@rb_writhe') do
        Wait(0)
    end

    TaskPlayAnim(ped, 'combat@damage@rb_writhe', 'rb_writhe_loop', 8.0, -8.0, -1, 1, 0, false, false, false)
end

-- Police menu
RegisterCommand(Config.Commands.police, function(source, args, rawCommand)
    if not IsPolice() then
        NotifyPolice(_U('error'), _U('not_police'), 'error')
        return
    end

    OpenPoliceMenu()
end, false)

function OpenPoliceMenu()
    local options = {
        {
            title = _U('dispatch_list'),
            description = 'Aktív hívások megtekintése',
            icon = 'fas fa-radio',
            onSelect = function()
                GetActiveCalls()
            end
        },
        {
            title = _U('mdt_title'),
            description = 'Mobil Adatopó megnyitása',
            icon = 'fas fa-laptop',
            onSelect = function()
                OpenMDT()
            end
        },
        {
            title = 'Körözés Beállítása',
            description = 'Játékos körözésének beállítása',
            icon = 'fas fa-user-slash',
            onSelect = function()
                lib.registerContext({
                    id = 'set_wanted',
                    title = 'Körözés Beállítása',
                    options = {
                        {
                            title = 'Játékos ID',
                            input = true,
                            inputType = 'number',
                            inputPlaceholder = 'Enter Player ID'
                        },
                        {
                            title = 'Körözési Szint',
                            input = true,
                            inputType = 'number',
                            inputPlaceholder = '1-5'
                        }
                    }
                })
                lib.showContext('set_wanted')
            end
        }
    }

    lib.registerContext({
        id = 'police_menu',
        title = 'Rendőrség Menü',
        options = options
    })

    lib.showContext('police_menu')
end

-- ============================================
-- WANTED LEVEL INDICATOR
-- ============================================
local wantedStars = 0

Citizen.CreateThread(function()
    while true do
        Wait(100)

        if IsPolice() then
            -- Draw wanted level for nearby players
            local players = GetActivePlayers()
            for _, playerId in ipairs(players) do
                if playerId ~= PlayerId() then
                    local ped = GetPlayerPed(playerId)
                    if ped and GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), GetEntityCoords(ped), true) < 50.0 then
                        local wantedLevel = GetPlayerWantedLevel(playerId)
                        if wantedLevel > 0 then
                            local pedCoords = GetEntityCoords(ped)
                            local onScreen, x, y = GetScreenCoordFromWorldCoord(pedCoords.x, pedCoords.y, pedCoords.z + 2.0)
                            if onScreen then
                                DrawText(x, y, '⚠ ' .. wantedLevel .. ' csillag')
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- ============================================
-- PLAYER TARGETING (for police actions)
-- ============================================
function TargetNearestPlayer()
    local closestPlayer = nil
    local closestDistance = 50.0

    local players = GetActivePlayers()
    for _, playerId in ipairs(players) do
        if playerId ~= PlayerId() then
            local targetPed = GetPlayerPed(playerId)
            if targetPed then
                local distance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), GetEntityCoords(targetPed), true)
                if distance < closestDistance then
                    closestDistance = distance
                    closestPlayer = playerId
                end
            end
        end
    end

    return closestPlayer, closestDistance
end

-- ============================================
-- FRISK PLAYER
-- ============================================
RegisterCommand('frisk', function(source, args, rawCommand)
    if not IsPolice() then
        NotifyPolice(_U('error'), _U('not_police'), 'error')
        return
    end

    local nearestPlayer, distance = TargetNearestPlayer()
    if not nearestPlayer or distance > 2.0 then
        NotifyPolice('Hiba', 'Nincs a közelben játékos', 'error')
        return
    end

    local targetPed = GetPlayerPed(nearestPlayer)
    RequestAnimDict('weapons@pistol@2h@aim')
    while not HasAnimDictLoaded('weapons@pistol@2h@aim') do
        Wait(0)
    end

    -- Start frisk animation
    TaskPlayAnim(PlayerPedId(), 'weapons@pistol@2h@aim', 'aim', 8.0, -8.0, 3000, 1, 0, false, false, false)

    NotifyPolice('Info', 'Rá vagy szálláson az őrizeten tartásra...', 'inform')
end, false)

-- ============================================
-- LICENSE CHECK
-- ============================================
RegisterCommand('checklic', function(source, args, rawCommand)
    if not IsPolice() then
        NotifyPolice(_U('error'), _U('not_police'), 'error')
        return
    end

    local nearestPlayer, distance = TargetNearestPlayer()
    if not nearestPlayer or distance > 2.0 then
        NotifyPolice('Hiba', 'Nincs a közelben játékos', 'error')
        return
    end

    OpenMDT()
    NotifyPolice('MDT', 'Jogosítványa ellenőrzéshez nyisd meg az MDT-t', 'inform')
end, false)

print('^2[Police] Police client loaded!^7')
