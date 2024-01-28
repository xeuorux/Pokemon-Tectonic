
#===============================================================================
# Combos with another Pledge move used by the ally. (Grass Pledge)
# If the move is a combo, power is doubled and causes either a sea of fire or a
# swamp on the opposing side.
#===============================================================================
class PokeBattle_Move_106 < PokeBattle_PledgeMove
    def initialize(battle, move)
        super
        # [Function code to combo with, effect, override type, override animation]
        @combos = [["107", :SeaOfFire, :FIRE, :FIREPLEDGE],
                   ["108", :Swamp,     nil,   nil],]
    end
end

#===============================================================================
# Combos with another Pledge move used by the ally. (Fire Pledge)
# If the move is a combo, power is doubled and causes either a rainbow on the
# user's side or a sea of fire on the opposing side.
#===============================================================================
class PokeBattle_Move_107 < PokeBattle_PledgeMove
    def initialize(battle, move)
        super
        # [Function code to combo with, effect, override type, override animation]
        @combos = [["108", :Rainbow,   :WATER, :WATERPLEDGE],
                   ["106", :SeaOfFire, nil,    nil],]
    end
end

#===============================================================================
# Combos with another Pledge move used by the ally. (Water Pledge)
# If the move is a combo, power is doubled and causes either a swamp on the
# opposing side or a rainbow on the user's side.
#===============================================================================
class PokeBattle_Move_108 < PokeBattle_PledgeMove
    def initialize(battle, move)
        super
        # [Function code to combo with, effect, override type, override animation]
        @combos = [["106", :Swamp,   :GRASS, :GRASSPLEDGE],
                   ["107", :Rainbow, nil,    nil],]
    end
end