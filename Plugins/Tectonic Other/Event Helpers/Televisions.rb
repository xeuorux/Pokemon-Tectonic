def displayTVProgram()
    # TODO: Add other sorts of TV programs here
    displayNewsProgram()
end

def displayNewsProgram(map_id = -1)
    if map_id != -1
        displayWeatherReport(map_id)
    else
        displayInterestingWeatherReport()
    end
end

WEATHER_REPORT_MAPS = {
    56 => _INTL("Novo Town"),
    217 => _INTL("Sweetrock Harbor"),
    32 => _INTL("Prizca"),
    187 => _INTL("Prizca"),
    126 => _INTL("Casaba Villa"),
    301 => _INTL("County Park"),
    37 => _INTL("Svait"),
    258 => _INTL("Whitebloom Town"),
    186 => _INTL("Frostflow Farms"),
    6 => _INTL("LuxTech Campus"),
    130 => _INTL("Canal Desert"),
    59 => _INTL("Feebas' Fin"),
    53 => _INTL("The Shelf"),
}

def displayInterestingWeatherReport()
    interestingReports = {} # Name, report
    boringReports = {} # Same

    WEATHER_REPORT_MAPS.each do |id, name|
        weatherReport = getWeatherOverNextDay(id)
        if weatherReport[0][0] == :None && weatherReport[1][0] == :None && weatherReport[2][0] == :None
            boringReports[name] = weatherReport
        else
            interestingReports[name] = weatherReport
        end
    end
    
    mapName = nil
    report = nil
    echoln("There are #{interestingReports.length} maps experiencing interesting weather tomorrow.")
    if (!interestingReports.empty? && rand(2) == 0) || boringReports.empty?
        mapName = interestingReports.keys.sample
        report = interestingReports[mapName]
    else
        mapName = boringReports.keys.sample
        report = boringReports[mapName]
    end

    displayWeatherReport(report,mapName) if report
end

def displayWeatherReport(weatherReport,mapName)
    morningWeather, morningStrength = weatherReport[0]
    morningDescriptor = getWeatherDescriptor(morningWeather, morningStrength)

    afternoonWeather, afternoonStrength = weatherReport[1]
    afternoonDescriptor = getWeatherDescriptor(afternoonWeather, afternoonStrength)

    eveningWeather, eveningStrength = weatherReport[2]
    eveningDescriptor = getWeatherDescriptor(eveningWeather, eveningStrength)

    pbMessage(_INTL("Tomorrow's weather forecast for #{mapName}!"))
    if (morningWeather == :None) &&  (afternoonWeather == :None) && (eveningWeather == :None)
        pbMessage(_INTL("The area will experience normal conditions all day."))
        pbMessage(_INTL("This means cloud cover at around 50 percent, with a very low chance for precipitation."))
        return
    end
    
    pbMessage(_INTL("The morning will see #{morningDescriptor}."))
    showWeatherWarnings(morningWeather, morningStrength)
    if afternoonDescriptor == morningDescriptor
        pbMessage(_INTL("That weather will continue into the afternoon."))

        if eveningDescriptor == afternoonDescriptor
            pbMessage(_INTL("That evening: even more of the same."))
        else
            pbMessage(_INTL("However, things will shake up in the evening with #{eveningDescriptor}."))
            showWeatherWarnings(eveningWeather, eveningStrength)
        end
    else
        pbMessage(_INTL("In the afternoon, that will make way for #{afternoonDescriptor}."))
        showWeatherWarnings(afternoonWeather, afternoonStrength)
        if eveningDescriptor == afternoonDescriptor
            pbMessage(_INTL("The day will close out with the same conditions."))
        else
            if eveningDescriptor == morningDescriptor
                pbMessage(_INTL("More #{eveningDescriptor} will return in the evening."))
                showWeatherWarnings(eveningWeather, eveningStrength)
            else
                pbMessage(_INTL("Finally, in the evening we'll get #{eveningDescriptor}."))
                showWeatherWarnings(eveningWeather, eveningStrength)
            end
        end
    end
end

def showWeatherWarnings(weatherSymbol, strength)
    return if !isWeatherDangerous?(weatherSymbol, strength)
    warningMessage = [_INTL("Please take caution!"),_INTL("We warn the viewer to be careful."),_INTL("We recommend citizens stay indoors.")].sample
    pbMessage(warningMessage)
end

def isWeatherDangerous?(weatherSymbol, strength)
    return true if [:Sandstorm,:Blizzard,:Storm].include?(weatherSymbol)
    return true if weatherSymbol == :Sun && strength >= 4
    return false
end

def getWeatherDescriptor(weatherSymbol, strength)
    case weatherSymbol
    when :Rain
        return _INTL("cloudy skies with light rain showers")
    when :Snow
        return _INTL("cloudy skies with light snowfall")
    when :Dusty
        return _INTL("sunny skies with dry, dusty air")
    when :Sun
        return _INTL("sunny skies and hot tempuratures")
    when :Overcast
        return _INTL("overcast skies with high ambient humidity")
    when :Storm,:HeavyRain
        return _INTL("total cloud cover and heavy rain with thunder")
    when :Blizzard
        return _INTL("blizzard conditions with high winds and heavy snowfall")
    when :Sandstorm
        return _INTL("hot and dry sandstorm conditions")
    when :Fog
        return _INTL("cold and wet fog wtih reduced visibility")
    when :ToxicFog
        return _INTL("smoggy and dangerous conditions")
    end

    return _INTL("lightly cloudy skies with no precipitation")
end