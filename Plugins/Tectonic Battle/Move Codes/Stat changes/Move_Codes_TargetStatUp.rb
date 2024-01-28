#===============================================================================
# The user raises the target's Attack and Sp. Atk by 5 steps by decorating
# the target. (Decorate)
#===============================================================================
class PokeBattle_Move_17B < PokeBattle_TargetMultiStatUpMove
    def initialize(battle, move)
        super
        @statUp = [:ATTACK, 5, :SPECIAL_ATTACK, 5]
    end
end

#===============================================================================
# Boosts Targets' Attack and Defense by 2 steps each. (Coaching)
#===============================================================================
class PokeBattle_Move_18E < PokeBattle_TargetMultiStatUpMove
    def initialize(battle, move)
        super
        @statUp = [:ATTACK, 2, :DEFENSE, 2]
    end
end

#===============================================================================
# Boosts Targets' Sp. Atk and Sp. Def by 2 steps. (Tutelage)
#===============================================================================
class PokeBattle_Move_5CE < PokeBattle_TargetMultiStatUpMove
    def initialize(battle, move)
        super
        @statUp = [:SPECIAL_ATTACK, 2, :SPECIAL_DEFENSE, 2]
    end
end

#===============================================================================
# Increases target's Defense and Special Defense by 3 steps. (Aromatic Mist)
#===============================================================================
class PokeBattle_Move_138 < PokeBattle_TargetMultiStatUpMove
    def ignoresSubstitute?(_user); return true; end

    def initialize(battle, move)
        super
        @statUp = [:DEFENSE, 3, :SPECIAL_DEFENSE, 3]
    end
end