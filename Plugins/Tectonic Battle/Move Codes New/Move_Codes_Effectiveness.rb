#===============================================================================
# Effectiveness against Dragon-type is 2x. (Slay)
#===============================================================================
class PokeBattle_Move_54F < PokeBattle_TypeSuperMove
    def initialize(battle, move)
        super
        @typeHated = :DRAGON
    end
end

#===============================================================================
# Effectiveness against Electric-type is 2x. (Blackout)
#===============================================================================
class PokeBattle_Move_562 < PokeBattle_TypeSuperMove
    def initialize(battle, move)
        super
        @typeHated = :ELECTRIC
    end
end

#===============================================================================
# Effectiveness against Ghost-type is 2x. (Holly Charm)
#===============================================================================
class PokeBattle_Move_563 < PokeBattle_TypeSuperMove
    def initialize(battle, move)
        super
        @typeHated = :GHOST
    end
end

#===============================================================================
# Effectiveness against Fighting-type is 2x. (Honorless Sting)
#===============================================================================
class PokeBattle_Move_586 < PokeBattle_TypeSuperMove
    def initialize(battle, move)
        super
        @typeHated = :FIGHTING
    end
end

#===============================================================================
# Type effectiveness is multiplied by the Flying-type's effectiveness against
# the target. (Flying Press)
#===============================================================================
class PokeBattle_Move_144 < PokeBattle_Move
    def pbCalcTypeModSingle(moveType, defType, user, target)
        ret = super
        if GameData::Type.exists?(:FLYING)
            flyingEff = Effectiveness.calculate_one(:FLYING, defType)
            ret *= flyingEff.to_f / Effectiveness::NORMAL_EFFECTIVE_ONE
        end
        return ret
    end
end

#===============================================================================
# Type effectiveness is multiplied by the Psychic-type's effectiveness against
# the target. (Leyline Burst)
#===============================================================================
class PokeBattle_Move_573 < PokeBattle_Move
    def pbCalcTypeModSingle(moveType, defType, user, target)
        ret = super
        if GameData::Type.exists?(:PSYCHIC)
            psychicEffectiveness = Effectiveness.calculate_one(:PSYCHIC, defType)
            ret *= psychicEffectiveness.to_f / Effectiveness::NORMAL_EFFECTIVE_ONE
        end
        return ret
    end
end