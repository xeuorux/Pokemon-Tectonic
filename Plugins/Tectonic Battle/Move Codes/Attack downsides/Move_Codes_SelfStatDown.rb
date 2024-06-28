#===============================================================================
# Decreases the user's Attack by 1 step.
#===============================================================================
class PokeBattle_Move_LowerUserAtk1 < PokeBattle_StatDownMove
    def initialize(battle, move)
        super
        @statDown = [:ATTACK, 1]
    end
end

#===============================================================================
# Decreases the user's Attack by 2 steps.
#===============================================================================
class PokeBattle_Move_LowerUserAtk2 < PokeBattle_StatDownMove
    def initialize(battle, move)
        super
        @statDown = [:ATTACK, 2]
    end
end

#===============================================================================
# Decreases the user's Attack by 3 steps.
#===============================================================================
class PokeBattle_Move_LowerUserAtk3 < PokeBattle_StatDownMove
    def initialize(battle, move)
        super
        @statDown = [:ATTACK, 3]
    end
end

#===============================================================================
# Decreases the user's Attack by 4 steps.
#===============================================================================
class PokeBattle_Move_LowerUserAtk4 < PokeBattle_StatDownMove
    def initialize(battle, move)
        super
        @statDown = [:ATTACK, 4]
    end
end

#===============================================================================
# Decreases the user's Attack by 5 steps.
#===============================================================================
class PokeBattle_Move_LowerUserAtk5 < PokeBattle_StatDownMove
    def initialize(battle, move)
        super
        @statDown = [:ATTACK, 5]
    end
end

#===============================================================================
# Decreases the user's Special Attack by 1 step.
#===============================================================================
class PokeBattle_Move_LowerUserSpAtk1 < PokeBattle_StatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPECIAL_ATTACK, 1]
    end
end

#===============================================================================
# Decreases the user's Special Attack by 2 steps.
#===============================================================================
class PokeBattle_Move_LowerUserSpAtk2 < PokeBattle_StatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPECIAL_ATTACK, 2]
    end
end

#===============================================================================
# Decreases the user's Special Attack by 3 steps.
#===============================================================================
class PokeBattle_Move_LowerUserSpAtk3 < PokeBattle_StatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPECIAL_ATTACK, 3]
    end
end

#===============================================================================
# Decreases the user's Special Attack by 4 steps.
#===============================================================================
class PokeBattle_Move_LowerUserSpAtk4 < PokeBattle_StatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPECIAL_ATTACK, 4]
    end
end

#===============================================================================
# Decreases the user's Special Attack by 5 steps.
#===============================================================================
class PokeBattle_Move_LowerUserSpAtk5 < PokeBattle_StatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPECIAL_ATTACK, 5]
    end
end

#===============================================================================
# Decreases the user's Defense by 1 step.
#===============================================================================
class PokeBattle_Move_LowerUserDef1 < PokeBattle_StatDownMove
    def initialize(battle, move)
        super
        @statDown = [:DEFENSE, 1]
    end
end

#===============================================================================
# Decreases the user's Defense by 2 steps.
#===============================================================================
class PokeBattle_Move_LowerUserDef2 < PokeBattle_StatDownMove
    def initialize(battle, move)
        super
        @statDown = [:DEFENSE, 2]
    end
end

#===============================================================================
# Decreases the user's Defense by 3 steps.
#===============================================================================
class PokeBattle_Move_LowerUserDef3 < PokeBattle_StatDownMove
    def initialize(battle, move)
        super
        @statDown = [:DEFENSE, 3]
    end
end

#===============================================================================
# Decreases the user's Defense by 4 steps.
#===============================================================================
class PokeBattle_Move_LowerUserDef4 < PokeBattle_StatDownMove
    def initialize(battle, move)
        super
        @statDown = [:DEFENSE, 4]
    end
end

#===============================================================================
# Decreases the user's Defense by 5 steps.
#===============================================================================
class PokeBattle_Move_LowerUserDef5 < PokeBattle_StatDownMove
    def initialize(battle, move)
        super
        @statDown = [:DEFENSE, 5]
    end
end

#===============================================================================
# Decreases the user's Sp. SpDef by 1 step.
#===============================================================================
class PokeBattle_Move_LowerUserSpDef1 < PokeBattle_StatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPECIAL_DEFENSE, 1]
    end
end

#===============================================================================
# Decreases the user's Sp. SpDef by 2 steps.
#===============================================================================
class PokeBattle_Move_LowerUserSpDef2 < PokeBattle_StatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPECIAL_DEFENSE, 2]
    end
end

#===============================================================================
# Decreases the user's Sp. SpDef by 3 steps.
#===============================================================================
class PokeBattle_Move_LowerUserSpDef3 < PokeBattle_StatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPECIAL_DEFENSE, 3]
    end
end

#===============================================================================
# Decreases the user's Sp. SpDef by 4 steps.
#===============================================================================
class PokeBattle_Move_LowerUserSpDef4 < PokeBattle_StatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPECIAL_DEFENSE, 4]
    end
end

#===============================================================================
# Decreases the user's Sp. SpDef by 5 steps.
#===============================================================================
class PokeBattle_Move_LowerUserSpDef5 < PokeBattle_StatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPECIAL_DEFENSE, 5]
    end
end

#===============================================================================
# Decreases the user's Speed by 1 step.
#===============================================================================
class PokeBattle_Move_LowerUserSpd1 < PokeBattle_StatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPEED, 1]
    end
end

#===============================================================================
# Decreases the user's Speed by 2 steps.
#===============================================================================
class PokeBattle_Move_LowerUserSpd2 < PokeBattle_StatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPEED, 2]
    end
end

#===============================================================================
# Decreases the user's Speed by 3 steps.
#===============================================================================
class PokeBattle_Move_LowerUserSpd3 < PokeBattle_StatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPEED, 3]
    end
end

#===============================================================================
# Decreases the user's Speed by 4 steps.
#===============================================================================
class PokeBattle_Move_LowerUserSpd4 < PokeBattle_StatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPEED, 4]
    end
end

#===============================================================================
# Decreases the user's Speed by 5 steps.
#===============================================================================
class PokeBattle_Move_LowerUserSpd5 < PokeBattle_StatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPEED, 5]
    end
end


################################################################################
# COMBINATIONS
################################################################################

#===============================================================================
# Decreases the user's Attack and Defense by 2 steps each.
#===============================================================================
class PokeBattle_Move_LowerUserAtkDef2 < PokeBattle_StatDownMove
    def initialize(battle, move)
        super
        @statDown = [:ATTACK, 2, :DEFENSE, 2]
    end
end

#===============================================================================
# Decreases the user's Sp. Atk and Sp. Def by 2 steps each.
#===============================================================================
class PokeBattle_Move_LowerUserSpAtkSpDef2 < PokeBattle_StatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPECIAL_ATTACK, 2, :SPECIAL_DEFENSE, 2]
    end
end

#===============================================================================
# Decreases the user's Defense and Special Defense by 2 steps each.
# (Close Combat, Dragon Ascent)
#===============================================================================
class PokeBattle_Move_LowerUserDefSpDef2 < PokeBattle_StatDownMove
    def initialize(battle, move)
        super
        @statDown = DEFENDING_STATS_2
    end
end

#===============================================================================
# Decreases the user's Defense, Special Defense and Speed by 2 steps each.
# (V-create)
#===============================================================================
class PokeBattle_Move_LowerUserSpdDefSpDef2 < PokeBattle_StatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPEED, 2, :DEFENSE, 2, :SPECIAL_DEFENSE, 2]
    end
end

#===============================================================================
# Guaranteed to crit, but lowers the user's speed. (Incision)
#===============================================================================
class PokeBattle_Move_AlwaysCritialLowerUserSpeed1 < PokeBattle_Move_LowerUserSpd2
    def pbCriticalOverride(_user, _target); return 1; end
end

#===============================================================================
# Decreases the user's Speed and Defense by 1 step each. Can't miss. (Omniscient Blow)
#===============================================================================
class PokeBattle_Move_CantMissLowerUserSpeedDef1 < PokeBattle_StatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPEED, 1, :DEFENSE, 1]
    end

    def pbAccuracyCheck(_user, _target); return true; end
end