Config = {}

-- ============================================
-- GENERAL SETTINGS
-- ============================================
Config.Locale = 'hu' -- 'hu' = Hungarian, 'en' = English
Config.Debug = false

-- ============================================
-- POLICE JOB SETTINGS
-- ============================================
Config.PoliceJob = 'police'
Config.PoliceGrade = {
    recruit = 0,
    officer = 1,
    sergeant = 2,
    lieutenant = 3,
    captain = 4,
    chief = 5
}

-- Police Uniforms (model names)
Config.PoliceUniforms = {
    recruit = {
        male = 'a_m_m_business_1',
        female = 'a_f_m_business_1'
    },
    officer = {
        male = 'a_m_m_business_1',
        female = 'a_f_m_business_1'
    }
}

-- ============================================
-- DISPATCH SETTINGS
-- ============================================
Config.DispatchTypes = {
    {name = 'assault', label = 'Támadás', color = {255, 0, 0}},
    {name = 'robbery', label = 'Rablás', color = {255, 100, 0}},
    {name = 'traffic', label = 'Forgalom', color = {255, 255, 0}},
    {name = 'accident', label = 'Baleset', color = {0, 255, 0}},
    {name = 'welfare', label = 'Segítségkérés', color = {0, 0, 255}},
    {name = 'suspicious', label = 'Gyanús tevékenység', color = {128, 0, 128}}
}

-- Dispatch Blip Settings
Config.DispatchBlip = {
    sprite = 227,
    display = 4,
    scale = 0.8,
    route = false
}

-- ============================================
-- MDT SETTINGS
-- ============================================
Config.MDTAccess = {
    'police'
}

Config.MDTCommands = {
    open = 'mdt',
    close = 'mdtclose'
}

-- ============================================
-- JAIL SETTINGS
-- ============================================
Config.JailLocations = {
    {
        name = 'Police Station Jail',
        coords = vector3(461.45, -987.54, 29.44),
        heading = 0.0,
        inCell = vector3(462.45, -992.54, 24.44)
    }
}

Config.MaxJailTime = 3600 -- seconds (1 hour)
Config.JailCells = 10
Config.JailReleaseTime = 300 -- Release notification after (seconds)

-- ============================================
-- WANTED SYSTEM
-- ============================================
Config.WantedLevels = {
    {stars = 1, label = '1 csillag', bounty = 100},
    {stars = 2, label = '2 csillag', bounty = 250},
    {stars = 3, label = '3 csillag', bounty = 500},
    {stars = 4, label = '4 csillag', bounty = 1000},
    {stars = 5, label = '5 csillag', bounty = 2000}
}

-- ============================================
-- POLICE COMMANDS
-- ============================================
Config.Commands = {
    wanted = 'wanted',
    jail = 'jail',
    unjail = 'unjail',
    dispatch = 'dispatch',
    mdt = 'mdt',
    duty = 'duty'
}

-- ============================================
-- DATABASE TABLES (auto-created)
-- ============================================
Config.Database = {
    dispatchTable = 'dispatch_calls',
    wantedTable = 'player_wanted',
    jailTable = 'player_jail'
}

-- ============================================
-- NOTIFICATION SETTINGS
-- ============================================
Config.Notifications = {
    duration = 5000,
    position = 'top-right'
}
