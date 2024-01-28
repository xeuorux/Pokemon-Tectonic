#===============================================================================
# For 5 rounds, causes SE damage to be 25% higher, and NVE damage to be 25% lower.
# (Polarized Room)
#===============================================================================
class PokeBattle_Move_124 < PokeBattle_RoomMove
    def initialize(battle, move)
        super
        @roomEffect = :PolarizedRoom
    end
end

#===============================================================================
# For 5 rounds, Pokemon's Attack and Sp. Atk are swapped. (Puzzle Room)
#===============================================================================
class PokeBattle_Move_51A < PokeBattle_RoomMove
    def initialize(battle, move)
        super
        @roomEffect = :PuzzleRoom
    end
end

# Empowered Puzzle Room
class PokeBattle_Move_610 < PokeBattle_Move_51A
    include EmpoweredMove

    def pbEffectGeneral(user)
        super
        user.pbRaiseMultipleStatSteps(ATTACKING_STATS_1, user, move: self)
        transformType(user, :FAIRY)
    end
end

#===============================================================================
# For 5 rounds, swaps all battlers' offensive and defensive stats (Sp. Def <-> Sp. Atk and Def <-> Atk).
# (Odd Room)
#===============================================================================
class PokeBattle_Move_582 < PokeBattle_RoomMove
    def initialize(battle, move)
        super
        @roomEffect = :OddRoom
    end
end