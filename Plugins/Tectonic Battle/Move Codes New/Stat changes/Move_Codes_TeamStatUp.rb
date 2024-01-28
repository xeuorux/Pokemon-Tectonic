#===============================================================================
# Raises Attack of user and allies by 2 steps. (Howl)
#===============================================================================
class PokeBattle_Move_530 < PokeBattle_TeamStatBuffMove
    def initialize(battle, move)
        super
        @statUp = [:ATTACK, 2]
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

#===============================================================================
# Raises Sp. Atk of user and allies by 2 steps. (Mind Link)
#===============================================================================
class PokeBattle_Move_549 < PokeBattle_TeamStatBuffMove
    def initialize(battle, move)
        super
        @statUp = [:SPECIAL_ATTACK, 2]
    end
end

#===============================================================================
# Raises Sp. Def of user and allies by 3 steps. (Camaraderie)
#===============================================================================
class PokeBattle_Move_555 < PokeBattle_TeamStatBuffMove
    def initialize(battle, move)
        super
        @statUp = [:SPECIAL_DEFENSE, 3]
    end
end