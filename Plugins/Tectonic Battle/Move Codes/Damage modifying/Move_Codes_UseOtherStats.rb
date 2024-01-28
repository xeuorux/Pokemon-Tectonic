#===============================================================================
# This move is physical if user's Attack is higher than its Special Attack (Long Shot)
# (after applying stat steps)
#===============================================================================
class PokeBattle_Move_57C < PokeBattle_Move
    def initialize(battle, move)
        super
        @calculated_category = 1
    end

    def calculateCategory(user, _targets)
        return selectBestCategory(user)
    end
end

#===============================================================================
# User's Defense is used instead of user's Attack for this move's calculations.
# (Body Press)
#===============================================================================
class PokeBattle_Move_177 < PokeBattle_Move
    def aiAutoKnows?(pokemon); return true; end
	
    def pbAttackingStat(user, _target)
        return user, :DEFENSE
    end
end

#===============================================================================
# User's Special Defense is used instead of user's Special Attack for this move's calculations.
# (Ward Press)
#===============================================================================
class PokeBattle_Move_540 < PokeBattle_Move
    def aiAutoKnows?(pokemon); return true; end
	
    def pbAttackingStat(user, _target)
        return user, :SPECIAL_DEFENSE
    end
end

#===============================================================================
# Target's attacking stats are used instead of user's Attack for this move's calculations.
# (Foul Play, Tricky Toxins)
#===============================================================================
class PokeBattle_Move_121 < PokeBattle_Move
    def aiAutoKnows?(pokemon); return true; end
	
    def pbAttackingStat(_user, target)
        return target, :SPECIAL_ATTACK if specialMove?
        return target, :ATTACK
    end
end

#===============================================================================
# Target's Defense is used instead of its Special Defense for this move's
# calculations. (Guttural Roar, Secret Sword)
#===============================================================================
class PokeBattle_Move_122 < PokeBattle_Move
    def pbDefendingStat(_user, target)
        return target, :DEFENSE
    end
end

#===============================================================================
# Target's Special Defense is used instead of its Defense for this move's
# calculations. (Vim Ripper)
#===============================================================================
class PokeBattle_Move_506 < PokeBattle_Move
    def pbDefendingStat(_user, target)
        return target, :SPECIAL_DEFENSE
    end
end

#===============================================================================
# Target's Attack is used instead of its Defense for this move's
# calculations. (Butt Heads)
#===============================================================================
class PokeBattle_Move_54C < PokeBattle_Move
    def pbDefendingStat(_user, target)
        return target, :ATTACK
    end
end

#===============================================================================
# Target's Sp. Atk is used instead of its Sp. Def for this move's
# calculations.
#===============================================================================
class PokeBattle_Move_54D < PokeBattle_Move
    def pbDefendingStat(_user, target)
        return target, :SPECIAL_ATTACK
    end
end