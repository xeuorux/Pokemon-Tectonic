#===============================================================================
# Raises Attack of user and allies by 2 steps. (Howl)
#===============================================================================
class PokeBattle_Move_RaiseUserAndAlliesAtk2 < PokeBattle_TeamStatBuffMove
    def initialize(battle, move)
        super
        @statUp = [:ATTACK, 2]
    end
end

# Empowered Howl
class PokeBattle_Move_EmpoweredHowl < PokeBattle_Move_RaiseUserAndAlliesAtk2
    include EmpoweredMove

    def pbEffectGeneral(user)
        summonAvatar(user, :POOCHYENA, _INTL("#{user.pbThis} calls out to the pack!"))
        super
        transformType(user, :DARK)
    end
end

#===============================================================================
# Summons Moonglow for 8 turns. Raises the Attack of itself and all allies by 2 steps. (Midnight Hunt)
#===============================================================================
class PokeBattle_Move_RaiseUserAndAlliesAtk2StartMoonglow8 < PokeBattle_Move_RaiseUserAndAlliesAtk2
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
# Raises Defense of user and allies by 3 steps. (Stand Together)
#===============================================================================
class PokeBattle_Move_RaiseUserAndAlliesDef3 < PokeBattle_TeamStatBuffMove
    def initialize(battle, move)
        super
        @statUp = [:DEFENSE, 3]
    end
end

# Empowered Stand Together
class PokeBattle_Move_EmpoweredStandTogether < PokeBattle_Move_RaiseUserAndAlliesDef3
    include EmpoweredMove

    def pbEffectGeneral(user)
        summonAvatar(user, :TYROGUE, _INTL("#{user.pbThis} joins with an ally!"))
        super
        transformType(user, :FIGHTING)
    end
end

#===============================================================================
# Raises Sp. Atk of user and allies by 2 steps. (Mind Link)
#===============================================================================
class PokeBattle_Move_RaiseUserAndAlliesSpAtk2 < PokeBattle_TeamStatBuffMove
    def initialize(battle, move)
        super
        @statUp = [:SPECIAL_ATTACK, 2]
    end
end

# Empowered Mind Link
class PokeBattle_Move_EmpoweredMindLink < PokeBattle_Move_RaiseUserAndAlliesSpAtk2
    include EmpoweredMove

    def pbEffectGeneral(user)
        summonAvatar(user, :ABRA, _INTL("#{user.pbThis} gathers an new mind!"))
        super
        transformType(user, :PSYCHIC)
    end
end

#===============================================================================
# Raises Sp. Def of user and allies by 3 steps. (Symbiosis)
#===============================================================================
class PokeBattle_Move_RaiseUserAndAlliesSpDef3 < PokeBattle_TeamStatBuffMove
    def initialize(battle, move)
        super
        @statUp = [:SPECIAL_DEFENSE, 3]
    end
end

# Empowered Symbiosis
class PokeBattle_Move_EmpoweredSymbiosis < PokeBattle_Move_RaiseUserAndAlliesSpDef3
    include EmpoweredMove

    def pbEffectGeneral(user)
        summonAvatar(user, :GOSSIFLEUR, _INTL("#{user.pbThis} connects with their friend!"))
        super
        transformType(user, :GRASS)
    end
end