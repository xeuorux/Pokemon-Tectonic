#===============================================================================
# User's Defense is used instead of user's Attack for this move's calculations.
# (Body Press)
#===============================================================================
class PokeBattle_Move_AttacksWithDefense < PokeBattle_Move
    def aiAutoKnows?(pokemon); return true; end
	
    def pbAttackingStat(user, _target)
        return user, :DEFENSE
    end
end

#===============================================================================
# User's Special Defense is used instead of user's Special Attack for this move's calculations.
# (Ward Press)
#===============================================================================
class PokeBattle_Move_AttacksWithSpDef < PokeBattle_Move
    def aiAutoKnows?(pokemon); return true; end
	
    def pbAttackingStat(user, _target)
        return user, :SPECIAL_DEFENSE
    end
end

#===============================================================================
# Target's attacking stats are used instead of user's Attack for this move's calculations.
# (Foul Play, Short Circuit)
#===============================================================================
class PokeBattle_Move_AttacksWithTargetsStats < PokeBattle_Move
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
class PokeBattle_Move_DoesPhysicalDamage < PokeBattle_Move
    def pbDefendingStat(_user, target)
        return target, :DEFENSE
    end
end

#===============================================================================
# Target's Special Defense is used instead of its Defense for this move's
# calculations. (Vim Ripper)
#===============================================================================
class PokeBattle_Move_DoesSpecialDamage < PokeBattle_Move
    def pbDefendingStat(_user, target)
        return target, :SPECIAL_DEFENSE
    end
end

#===============================================================================
# Target's Attack is used instead of its Defense for this move's
# calculations. (Butting Heads)
#===============================================================================
class PokeBattle_Move_TargetsAttackDefends < PokeBattle_Move
    def pbDefendingStat(_user, target)
        return target, :ATTACK
    end
end

#===============================================================================
# Target's Sp. Atk is used instead of its Sp. Def for this move's
# calculations. (Beam Struggle)
#===============================================================================
class PokeBattle_Move_TargetsSpAtkDefends < PokeBattle_Move
    def pbDefendingStat(_user, target)
        return target, :SPECIAL_ATTACK
    end
end