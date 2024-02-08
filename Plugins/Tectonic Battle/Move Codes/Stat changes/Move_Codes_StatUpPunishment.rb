#===============================================================================
# Poisons opposing Pokemon that have increased their stats. (Stinging Jealousy)
#===============================================================================
class PokeBattle_Move_PoisonTargetIfTargetHasRaisedStats < PokeBattle_JealousyMove
    def initialize(battle, move)
        @statusToApply = :POISON
        super
    end
end

#===============================================================================
# Burns opposing Pokemon that have increased their stats. (Burning Jealousy)
#===============================================================================
class PokeBattle_Move_BurnTargetIfTargetHasRaisedStats < PokeBattle_JealousyMove
    def initialize(battle, move)
        @statusToApply = :BURN
        super
    end
end

#===============================================================================
# Frostbites opposing Pokemon that have increased their stats. (Freezing Jealousy)
#===============================================================================
class PokeBattle_Move_FrostbiteTargetIfTargetHasRaisedStats < PokeBattle_JealousyMove
    def initialize(battle, move)
        @statusToApply = :FROSTBITE
        super
    end
end