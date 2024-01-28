#===============================================================================
# Removes all Rooms. Fails if there is no Room. (Razing Vines)
#===============================================================================
class PokeBattle_Move_131 < PokeBattle_Move
    def pbMoveFailed?(_user, _targets, show_message)
        anyRoom = false
        @battle.field.eachEffect(true) do |effect, _value, effectData|
            next unless effectData.is_room?
            anyRoom = true
            break
        end

        unless anyRoom
            @battle.pbDisplay(_INTL("But it failed, since there is no active room!")) if show_message
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        @battle.field.eachEffect(true) do |effect, _value, effectData|
            next unless effectData.is_room?
            @battle.field.disableEffect(effect)
        end
    end

    def getEffectScore(user, _target)
        return 80
    end
end

#===============================================================================
# Removes all Weather. Fails if there is no Weather (Sky Fall)
#===============================================================================
class PokeBattle_Move_5B5 < PokeBattle_Move
    def pbMoveFailed?(_user, _targets, show_message)
        if @battle.pbWeather == :None
            @battle.pbDisplay(_INTL("But it failed, since there is no active weather!")) if show_message
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
       @battle.endWeather
    end

    def getEffectScore(user, _target)
        return getWeatherResetEffectScore(user)
    end
end