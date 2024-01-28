#===============================================================================
# Decreases the user's Attack and Defense by 2 steps each. (Superpower)
#===============================================================================
class PokeBattle_Move_03B < PokeBattle_StatDownMove
    def initialize(battle, move)
        super
        @statDown = [:ATTACK, 2, :DEFENSE, 2]
    end
end

#===============================================================================
# Decreases the user's Sp. Atk and Sp. Def by 2 steps each. (Geyser, Phantom Gate)
#===============================================================================
class PokeBattle_Move_53E < PokeBattle_StatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPECIAL_ATTACK, 2, :SPECIAL_DEFENSE, 2]
    end
end

#===============================================================================
# Decreases the user's Defense and Special Defense by 2 steps each.
# (Close Combat, Dragon Ascent)
#===============================================================================
class PokeBattle_Move_03C < PokeBattle_StatDownMove
    def initialize(battle, move)
        super
        @statDown = DEFENDING_STATS_2
    end
end

#===============================================================================
# Decreases the user's Defense, Special Defense and Speed by 2 steps each.
# (V-create)
#===============================================================================
class PokeBattle_Move_03D < PokeBattle_StatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPEED, 2, :DEFENSE, 2, :SPECIAL_DEFENSE, 2]
    end
end

#===============================================================================
# Decreases the user's Speed by 2 steps. (Hammer Arm, Ice Hammer)
#===============================================================================
class PokeBattle_Move_03E < PokeBattle_StatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPEED, 2]
    end
end

#===============================================================================
# Decreases the user's Speed by 3 steps. (Razor Plunge)
#===============================================================================
class PokeBattle_Move_5A3 < PokeBattle_StatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPEED, 3]
    end
end

#===============================================================================
# Decreases the user's Attack by 4 steps. (Infinite Force)
#===============================================================================
class PokeBattle_Move_50F < PokeBattle_StatDownMove
    def initialize(battle, move)
        super
        @statDown = [:ATTACK, 4]
    end
end

#===============================================================================
# Decreases the user's Special Attack by 4 steps.
#===============================================================================
class PokeBattle_Move_03F < PokeBattle_StatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPECIAL_ATTACK, 4]
    end
end

#===============================================================================
# Decreases the user's Defense by 3 steps. (Clanging Scales)
#===============================================================================
class PokeBattle_Move_15F < PokeBattle_StatDownMove
    def initialize(battle, move)
        super
        @statDown = [:DEFENSE, 3]
    end
end

#===============================================================================
# Decreases the user's Speed and Defense by 1 step each. Can't miss. (Omniscient Blow)
#===============================================================================
class PokeBattle_Move_519 < PokeBattle_StatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPEED, 1, :DEFENSE, 1]
    end

    def pbAccuracyCheck(_user, _target); return true; end
end