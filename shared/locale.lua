Locales = {}

Locales['hu'] = {
    -- Police Job
    not_police = 'Nem vagy rendőr!',
    police_duty_on = 'Munkába álltál',
    police_duty_off = 'Felszabadultál',
    
    -- Dispatch
    dispatch_created = 'Új hívás létrehozva!',
    dispatch_closed = 'Hívás lezárva!',
    dispatch_gps = 'GPS beállítva a célpontra',
    dispatch_list = 'Aktív Hívások',
    
    -- Wanted
    set_wanted = '%s játékos körözve: %d csillag',
    
    -- Jail
    jail_player = '%s játékost %d másodpercre börtönbe helyezted',
    released_from_jail = 'Kibocsátva a börtönből!',
    jail_remaining = 'Börtön időd: %d másodperc',
    unjail_player = '%s játékost felszabadítottad',
    
    -- MDT
    mdt_title = 'Mobil Adatopó',
    
    -- General
    error = 'Hiba',
    success = 'Siker',
    
    -- Commands
    cmd_jail_help = 'Használat: /jail [PlayerID] [Idő másodpercben]',
    cmd_unjail_help = 'Használat: /unjail [PlayerID]',
    cmd_wanted_help = 'Használat: /wanted [PlayerID] [1-5 csillag]'
}

Locales['en'] = {
    -- Police Job
    not_police = 'You are not a police officer!',
    police_duty_on = 'You are now on duty',
    police_duty_off = 'You are now off duty',
    
    -- Dispatch
    dispatch_created = 'New dispatch call created!',
    dispatch_closed = 'Dispatch call closed!',
    dispatch_gps = 'GPS set to location',
    dispatch_list = 'Active Calls',
    
    -- Wanted
    set_wanted = '%s player wanted: %d stars',
    
    -- Jail
    jail_player = 'Player %s jailed for %d seconds',
    released_from_jail = 'Released from jail!',
    jail_remaining = 'Jail time remaining: %d seconds',
    unjail_player = 'Player %s has been released',
    
    -- MDT
    mdt_title = 'Mobile Data Terminal',
    
    -- General
    error = 'Error',
    success = 'Success',
    
    -- Commands
    cmd_jail_help = 'Usage: /jail [PlayerID] [Time in seconds]',
    cmd_unjail_help = 'Usage: /unjail [PlayerID]',
    cmd_wanted_help = 'Usage: /wanted [PlayerID] [1-5 stars]'
}

function _U(str)
    return Locales[Config.Locale][str]
end
