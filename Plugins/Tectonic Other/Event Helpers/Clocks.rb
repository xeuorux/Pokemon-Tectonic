def clockInteraction
    stateCurrentTime
end

def stateCurrentTime
    realMinutes = PBDayNight.pbGetDayNightMinutes
    hour   = (realMinutes / 60).to_s
    minute = realMinutes % 60
    if minute < 10
        minute = "0" + minute.to_s
    else
        minute = minute.to_s
    end

    pbMessage(_INTL("It's {1}:{2} right now.", hour, minute))
end