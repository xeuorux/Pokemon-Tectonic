def avatarBearticDefeated?
    return pbGetSelfSwitch(29,'A',40) # In Gigalith's Guts
end

def avatarCrobatDefeated?
    return pbGetSelfSwitch(8,'A',260) # In Underpeak Tunnels B1
end

def avatarMonkeysDefeated?
    return pbGetSelfSwitch(15,'A',53) # In The Shelf
end

def avatarWhiscashDefeated?
    return pbGetSelfSwitch(14,'A',216) # In Highland Lake
end

def allDigitSlipsCollected?
    return pbQuantity(:DIGITSLIP) >= 8
end