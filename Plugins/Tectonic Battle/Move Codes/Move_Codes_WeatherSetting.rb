#===============================================================================
# Starts sunny weather. (Sunshine)
#===============================================================================
class PokeBattle_Move_0FF < PokeBattle_WeatherMove
    def initialize(battle, move)
        super
        @weatherType = :Sun
    end
end

#===============================================================================
# Starts rainy weather. (Rain)
#===============================================================================
class PokeBattle_Move_100 < PokeBattle_WeatherMove
    def initialize(battle, move)
        super
        @weatherType = :Rain
    end
end

#===============================================================================
# Starts sandstorm weather. (Sandstorm)
#===============================================================================
class PokeBattle_Move_101 < PokeBattle_WeatherMove
    def initialize(battle, move)
        super
        @weatherType = :Sandstorm
    end
end

#===============================================================================
# Starts hail weather. (Hail)
#===============================================================================
class PokeBattle_Move_102 < PokeBattle_WeatherMove
    def initialize(battle, move)
        super
        @weatherType = :Hail
    end
end

#===============================================================================
# Starts eclipse weather. (Eclipse)
#===============================================================================
class PokeBattle_Move_09D < PokeBattle_WeatherMove
    def initialize(battle, move)
        super
        @weatherType = :Eclipse
    end
end

#===============================================================================
# Starts moonlight weather. (Moonglow)
#===============================================================================
class PokeBattle_Move_09E < PokeBattle_WeatherMove
    def initialize(battle, move)
        super
        @weatherType = :Moonglow
    end
end

#===============================================================================
# Burns the target and sets Sun
#===============================================================================
class PokeBattle_Move_59A < PokeBattle_InviteMove
    def initialize(battle, move)
        super
        @weatherType = :Sun
        @durationSet = 4
        @statusToApply = :BURN
    end
end

#===============================================================================
# Numbs the target and sets Rain
#===============================================================================
class PokeBattle_Move_59B < PokeBattle_InviteMove
    def initialize(battle, move)
        super
        @weatherType = :Rain
        @durationSet = 4
        @statusToApply = :NUMB
    end
end

#===============================================================================
# Frostbites the target and sets Hail
#===============================================================================
class PokeBattle_Move_59C < PokeBattle_InviteMove
    def initialize(battle, move)
        super
        @weatherType = :Hail
        @durationSet = 4
        @statusToApply = :FROSTBITE
    end
end

#===============================================================================
# Dizzies the target and sets Sandstorm
#===============================================================================
class PokeBattle_Move_59D < PokeBattle_InviteMove
    def initialize(battle, move)
        super
        @weatherType = :Sandstorm
        @durationSet = 4
        @statusToApply = :DIZZY
    end
end

#===============================================================================
# Summons Eclipse for 8 turns and lowers the Attack of all enemies by 2 steps. (Wingspan Eclipse)
#===============================================================================
class PokeBattle_Move_52F < PokeBattle_Move_042
    def pbEffectGeneral(user)
        @battle.pbStartWeather(user, :Eclipse, 8, false) unless @battle.primevalWeatherPresent?
    end

    def getEffectScore(user, target)
        return getWeatherSettingEffectScore(:Eclipse, user, @battle, 8)
    end
end

#===============================================================================
# Target becomes trapped. Summons Eclipse for 8 turns.
# (Captivating Sight)
#===============================================================================
class PokeBattle_Move_5AF < PokeBattle_Move_0EF
    def pbFailsAgainstTarget?(_user, target, show_message)
        return false unless @battle.primevalWeatherPresent?(false)
        super
    end

    def pbEffectGeneral(user)
        @battle.pbStartWeather(user, :Eclipse, 8, false) unless @battle.primevalWeatherPresent?
    end

    def getEffectScore(user, _target)
        score = super
        score += getWeatherSettingEffectScore(:Eclipse, user, @battle, 8)
        return score
    end
end

#===============================================================================
# Summons Moonglow for 8 turns. Raises the Attack of itself and all allies by 2 steps. (Midnight Hunt)
#===============================================================================
class PokeBattle_Move_5B0 < PokeBattle_Move_530
    def pbMoveFailed?(user, _targets, show_message)
        return false unless @battle.primevalWeatherPresent?(false)
        super
    end

    def pbEffectGeneral(user)
        @battle.pbStartWeather(user, :Moonglow, 8, false) unless @battle.primevalWeatherPresent?
        super
    end

    def getEffectScore(user, _target)
        score = super
        score += getWeatherSettingEffectScore(:Moonglow, user, @battle, 8)
        return score
    end
end

#===============================================================================
# Sets stealth rock and sandstorm for 5 turns. (Stone Signal)
#===============================================================================
class PokeBattle_Move_5BD < PokeBattle_Move_105
    def pbMoveFailed?(user, _targets, show_message)
        return false
    end

    def pbEffectGeneral(user)
        super
        @battle.pbStartWeather(user, :Sandstorm, 5, false) unless @battle.primevalWeatherPresent?
    end
end

# Empowered Sunshine
class PokeBattle_Move_601 < PokeBattle_Move_0FF
    include EmpoweredMove

    def pbEffectGeneral(user)
        super
        user.pbRaiseMultipleStatSteps(ATTACKING_STATS_1, user, move: self)
        transformType(user, :FIRE)
    end
end

# Empowered Rain
class PokeBattle_Move_602 < PokeBattle_Move_100
    include EmpoweredMove

    def pbEffectGeneral(user)
        super
        @battle.pbAnimation(:AQUARING, user, [user])
        user.applyEffect(:AquaRing)
        transformType(user, :WATER)
    end
end

# Empowered Hail
class PokeBattle_Move_605 < PokeBattle_Move_102
    include EmpoweredMove

    def pbEffectGeneral(user)
        super
        @battle.eachOtherSideBattler(user) do |b|
            b.tryLowerStat(:SPEED, user, increment: 2, move: self)
        end
        transformType(user, :ICE)
    end
end

# Empowered Sandstorm
class PokeBattle_Move_60B < PokeBattle_Move_101
    include EmpoweredMove

    def pbEffectGeneral(user)
        super
        user.pbRaiseMultipleStatSteps(DEFENDING_STATS_1, user, move: self)
        transformType(user, :ROCK)
    end
end

# Empowered Eclipse
class PokeBattle_Move_617 < PokeBattle_Move_09D
    include EmpoweredMove

    def pbEffectGeneral(user)
        super
        user.pbRaiseMultipleStatSteps([:ATTACK, 1, :SPECIAL_ATTACK, 1], user, move: self)
        transformType(user, :PSYCHIC)
    end
end

# Empowered Moonglow
class PokeBattle_Move_618 < PokeBattle_Move_09E
    include EmpoweredMove

    def pbEffectGeneral(user)
        super

        @battle.eachSameSideBattler(user) do |b|
            b.pbRaiseMultipleStatSteps(DEFENDING_STATS_1, user, move: self)
        end

        transformType(user, :FAIRY)
    end
end