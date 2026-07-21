Locales = {}

Locales.hu = {
    -- General
    ['no_permission'] = 'Nincs jogod ehhez!',
    ['error'] = 'Hiba',
    ['success'] = 'Siker',
    ['loading'] = 'Betöltés...',
    
    -- Dispatch
    ['dispatch_created'] = 'Hívás létrehozva',
    ['dispatch_description'] = 'Hívás típusa: %s',
    ['dispatch_gps'] = 'GPS beállítva',
    ['dispatch_taken'] = '%s felvette a hívást',
    ['dispatch_closed'] = 'Hívás lezárva',
    ['dispatch_list'] = 'Aktív hívások',
    ['no_dispatch'] = 'Nincsenek aktív hívások',
    
    -- Police
    ['police_duty_on'] = 'Szolgálatba állás',
    ['police_duty_off'] = 'Szolgálatból kiállás',
    ['already_on_duty'] = 'Már szolgálatban vagy!',
    ['already_off_duty'] = 'Nem vagy szolgálatban!',
    ['not_police'] = 'Nem vagy rendőr!',
    
    -- Wanted
    ['set_wanted'] = 'Körözés beállítva: %s (csillag: %d)',
    ['remove_wanted'] = 'Körözés eltávolítva: %s',
    ['wanted_level'] = 'Körözési szint: %d csillag',
    
    -- Jail
    ['jail_player'] = '%s börtönbe került (%d mp)',
    ['unjail_player'] = '%s szabadult',
    ['jail_not_available'] = 'Nincs szabad cella!',
    ['jail_remaining'] = 'Hátralevő idő: %d másodperc',
    ['released_from_jail'] = 'Szabadulás börtönből',
    
    -- MDT
    ['mdt_title'] = 'Mobil Adatopó',
    ['mdt_vehicle_info'] = 'Jármű információ',
    ['mdt_driver_info'] = 'Sofőr információ',
    ['mdt_warrants'] = 'Elfogatási parancsok',
    ['mdt_licenses'] = 'Jogosítványok',
    ['mdt_notes'] = 'Megjegyzések',
    ['mdt_dispatch'] = 'Hívások',
    
    -- Commands
    ['cmd_dispatch'] = 'Hívás létrehozása',
    ['cmd_dispatch_help'] = '/dispatch [típus] [leírás]',
    ['cmd_jail'] = 'Játékos börtönbe zárása',
    ['cmd_jail_help'] = '/jail [id] [idő(mp)]',
    ['cmd_unjail'] = 'Játékos szabadítása',
    ['cmd_unjail_help'] = '/unjail [id]',
    ['cmd_wanted'] = 'Körözés beállítása',
    ['cmd_wanted_help'] = '/wanted [id] [csillag(1-5)]',
    ['cmd_mdt'] = 'MDT megnyitása',
    ['cmd_duty'] = 'Szolgálat ki/be',
}

Locales.en = {
    -- General
    ['no_permission'] = 'You don\'t have permission!',
    ['error'] = 'Error',
    ['success'] = 'Success',
    ['loading'] = 'Loading...',
    
    -- Dispatch
    ['dispatch_created'] = 'Call created',
    ['dispatch_description'] = 'Call type: %s',
    ['dispatch_gps'] = 'GPS set',
    ['dispatch_taken'] = '%s took the call',
    ['dispatch_closed'] = 'Call closed',
    ['dispatch_list'] = 'Active calls',
    ['no_dispatch'] = 'No active calls',
    
    -- Police
    ['police_duty_on'] = 'On duty',
    ['police_duty_off'] = 'Off duty',
    ['already_on_duty'] = 'Already on duty!',
    ['already_off_duty'] = 'Not on duty!',
    ['not_police'] = 'You are not a police officer!',
    
    -- Wanted
    ['set_wanted'] = 'Wanted set: %s (stars: %d)',
    ['remove_wanted'] = 'Wanted removed: %s',
    ['wanted_level'] = 'Wanted level: %d stars',
    
    -- Jail
    ['jail_player'] = '%s jailed (%d sec)',
    ['unjail_player'] = '%s released',
    ['jail_not_available'] = 'No available cells!',
    ['jail_remaining'] = 'Time remaining: %d seconds',
    ['released_from_jail'] = 'Released from jail',
    
    -- MDT
    ['mdt_title'] = 'Mobile Data Terminal',
    ['mdt_vehicle_info'] = 'Vehicle Info',
    ['mdt_driver_info'] = 'Driver Info',
    ['mdt_warrants'] = 'Warrants',
    ['mdt_licenses'] = 'Licenses',
    ['mdt_notes'] = 'Notes',
    ['mdt_dispatch'] = 'Calls',
    
    -- Commands
    ['cmd_dispatch'] = 'Create a dispatch call',
    ['cmd_dispatch_help'] = '/dispatch [type] [description]',
    ['cmd_jail'] = 'Jail a player',
    ['cmd_jail_help'] = '/jail [id] [time(sec)]',
    ['cmd_unjail'] = 'Release a player',
    ['cmd_unjail_help'] = '/unjail [id]',
    ['cmd_wanted'] = 'Set wanted level',
    ['cmd_wanted_help'] = '/wanted [id] [stars(1-5)]',
    ['cmd_mdt'] = 'Open MDT',
    ['cmd_duty'] = 'Toggle duty',
}

function GetLocale(key)
    local locale = Locales[Config.Locale] or Locales.en
    return locale[key] or 'Unknown translation: ' .. key
end

function _U(key, ...)
    local str = GetLocale(key)
    return string.format(str, ...)
end
