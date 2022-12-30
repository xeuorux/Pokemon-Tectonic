#===============================================================================
# PokeBattle_Move additions
#===============================================================================
class PokeBattle_Move
    attr_accessor :name, :flags
    attr_accessor :zmove_sel        # Used when the player triggers a Z-Move.
    attr_reader   :short_name       # Used for shortening names of Z-Moves/Max Moves.
    attr_reader   :specialUseZMove  # Used for Z-Move display messages in battle.

    alias _ZUD_initialize initialize
    def initialize(battle, move)
        _ZUD_initialize(battle, move)
        @short_name       = @name
        @zmove_sel        = false
        @specialUseZMove  = false
    end
end

#-------------------------------------------------------------------------------
# Checks a PokeBattle_Move to determine if it's a Z Move.
#-------------------------------------------------------------------------------
class PokeBattle_Move
    def zMove?; return @flags[/z/]; end
end

#-------------------------------------------------------------------------------
# Checks a Pokemon::Move to determine if it's a Z Move.
#-------------------------------------------------------------------------------
class Pokemon
    class Move
        def zMove?;     return GameData::Move.get(@id).zMove?; end
    end
end

#-------------------------------------------------------------------------------
# Checks a GameData::Move to determine if it's a Z Move.
#-------------------------------------------------------------------------------
module GameData
    class Move
        def zMove?;     return flags[/z/]; end
    end
end
