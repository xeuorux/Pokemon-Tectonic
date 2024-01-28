#===============================================================================
# Decreases the target's Attack and Defense by 2 steps each. (Tickle)
#===============================================================================
class PokeBattle_Move_04A < PokeBattle_TargetMultiStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:ATTACK, 2, :DEFENSE, 2]
    end
end

#===============================================================================
# Decreases the target's Sp. Atk and Sp. Def by 2 steps each. (Prank)
#===============================================================================
class PokeBattle_Move_560 < PokeBattle_TargetMultiStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPECIAL_ATTACK, 2, :SPECIAL_DEFENSE, 2]
    end
end

#===============================================================================
# Lowers the target's Attack, Defense, Speed, Special Attack and Special Defense
# by 1 step each. (Ruin)
#===============================================================================
class PokeBattle_Move_047 < PokeBattle_TargetMultiStatDownMove
    def initialize(battle, move)
        super
        @statDown = ALL_STATS_1
    end
end