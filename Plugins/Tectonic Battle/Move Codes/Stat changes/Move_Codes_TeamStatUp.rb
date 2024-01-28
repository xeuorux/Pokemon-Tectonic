#===============================================================================
# Raises Attack of user and allies by 2 steps. (Howl)
#===============================================================================
class PokeBattle_Move_530 < PokeBattle_TeamStatBuffMove
    def initialize(battle, move)
        super
        @statUp = [:ATTACK, 2]
    end
end

# Empowered Howl
class PokeBattle_Move_627 < PokeBattle_Move_530
    include EmpoweredMove

    def pbEffectGeneral(user)
        summonAvatar(user, :POOCHYENA, _INTL("#{user.pbThis} calls out to the pack!"))
        super
        transformType(user, :DARK)
    end
end

#===============================================================================
# Raises Defense of user and allies by 3 steps. (Stand Together)
#===============================================================================
class PokeBattle_Move_554 < PokeBattle_TeamStatBuffMove
    def initialize(battle, move)
        super
        @statUp = [:DEFENSE, 3]
    end
end

# Empowered Stand Together
class PokeBattle_Move_635 < PokeBattle_Move_554
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
class PokeBattle_Move_549 < PokeBattle_TeamStatBuffMove
    def initialize(battle, move)
        super
        @statUp = [:SPECIAL_ATTACK, 2]
    end
end

# Empowered Mind Link
class PokeBattle_Move_628 < PokeBattle_Move_549
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
class PokeBattle_Move_555 < PokeBattle_TeamStatBuffMove
    def initialize(battle, move)
        super
        @statUp = [:SPECIAL_DEFENSE, 3]
    end
end

# Empowered Symbiosis
class PokeBattle_Move_634 < PokeBattle_Move_555
    include EmpoweredMove

    def pbEffectGeneral(user)
        summonAvatar(user, :GOSSIFLEUR, _INTL("#{user.pbThis} connects with their friend!"))
        super
        transformType(user, :GRASS)
    end
end