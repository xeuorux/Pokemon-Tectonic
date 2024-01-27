#===============================================================================
# Increases the user's Attack and Defense by 1 step each. (Bulk Up)
#===============================================================================
class PokeBattle_Move_024 < PokeBattle_MultiStatUpMove
    def initialize(battle, move)
        super
        @statUp = [:ATTACK, 2, :DEFENSE, 2]
    end
end

#===============================================================================
# Increases the user's Attack, Defense and accuracy by 2 steps each. (Coil)
#===============================================================================
class PokeBattle_Move_025 < PokeBattle_MultiStatUpMove
    def initialize(battle, move)
        super
        @statUp = [:ATTACK, 2, :DEFENSE, 2, :ACCURACY, 2]
    end
end

#===============================================================================
# Increases the user's Attack and Sp. Def by 2 step each. (Flow State)
#===============================================================================
class PokeBattle_Move_512 < PokeBattle_MultiStatUpMove
    def initialize(battle, move)
        super
        @statUp = [:ATTACK, 2, :SPECIAL_DEFENSE, 2]
    end
end

#===============================================================================
# Increases the user's Attack by 2 steps, and Speed by 1. (Dragon Dance)
#===============================================================================
class PokeBattle_Move_026 < PokeBattle_MultiStatUpMove
    def initialize(battle, move)
        super
        @statUp = [:ATTACK, 2, :SPEED, 1]
    end
end

#===============================================================================
# Increases the user's Attack and Speed by 2 steps each. (Shift Gear)
#===============================================================================
class PokeBattle_Move_036 < PokeBattle_MultiStatUpMove
    def aiAutoKnows?(pokemon); return true; end

    def initialize(battle, move)
        super
        @statUp = [:SPEED, 2, :ATTACK, 2]
    end
end

#===============================================================================
# Increases the user's Attack and Defense by 2 steps each, and Speed by 1.
# (Shiver Dance)
#===============================================================================
class PokeBattle_Move_525 < PokeBattle_MultiStatUpMove
    def aiAutoKnows?(pokemon); return true; end

    def initialize(battle, move)
        super
        @statUp = [:ATTACK, 2, :DEFENSE, 2, :SPEED, 1]
    end
end

#===============================================================================
# Increases the user's Attack and Special Attack by 1 steps each.
#===============================================================================
class PokeBattle_Move_048 < PokeBattle_MultiStatUpMove
    def initialize(battle, move)
        super
        @statUp = ATTACKING_STATS_1
    end
end

#===============================================================================
# Increases the user's Attack and Special Attack by 2 steps each. (Work Up)
#===============================================================================
class PokeBattle_Move_027 < PokeBattle_MultiStatUpMove
    def initialize(battle, move)
        super
        @statUp = ATTACKING_STATS_2
    end
end

#===============================================================================
# Increases the user's Attack and Sp. Attack by 2 step eachs.
# In sunny weather, increases are 4 steps each instead. (Growth)
#===============================================================================
class PokeBattle_Move_028 < PokeBattle_MultiStatUpMove
    def initialize(battle, move)
        super
        @statUp = ATTACKING_STATS_2
    end

    def pbOnStartUse(_user, _targets)
        if @battle.sunny?
            @statUp = [:ATTACK, 4, :SPECIAL_ATTACK, 4]
        else
            @statUp = ATTACKING_STATS_2
        end
    end

    def shouldHighlight?(_user, _target)
        return @battle.sunny?
    end
end

#===============================================================================
# Increases the user's Attack and accuracy by 3 steps each. (Hone Claws)
#===============================================================================
class PokeBattle_Move_029 < PokeBattle_MultiStatUpMove
    def initialize(battle, move)
        super
        @statUp = [:ATTACK, 3, :ACCURACY, 3]
    end
end

#===============================================================================
# Increases the user's Defense and Special Defense by 2 steps each.
# (Cosmic Power, Defend Order)
#===============================================================================
class PokeBattle_Move_02A < PokeBattle_MultiStatUpMove
    def aiAutoKnows?(pokemon); return true; end
    
    def initialize(battle, move)
        super
        @statUp = DEFENDING_STATS_2
    end
end

#===============================================================================
# Increases the user's Defense and Sp. Def by 2 steps. User curls up. (Curl Up)
#===============================================================================
class PokeBattle_Move_01E < PokeBattle_MultiStatUpMove
    def aiAutoKnows?(pokemon); return true; end

    def initialize(battle, move)
        super
        @statUp = DEFENDING_STATS_2
    end

    def pbEffectGeneral(user)
        user.applyEffect(:DefenseCurl)
        super
    end
end

#===============================================================================
# Increases the user's defensive stats by 2 steps and gives them the (Shellter)
# Shell Armor ability.
#===============================================================================
class PokeBattle_Move_5E2 < PokeBattle_MultiStatUpMove
    def aiAutoKnows?(pokemon); return true; end
    
    def initialize(battle, move)
        super
        @statUp = DEFENDING_STATS_2
    end

    def pbEffectGeneral(user)
        super
        user.addAbility(:SHELLARMOR,true)
    end
end

#===============================================================================
# Increases the user's defensive stats by 2 steps each.
# Charges up user's next attack if it is Electric-type. (Charge)
#===============================================================================
class PokeBattle_Move_021 < PokeBattle_MultiStatUpMove
    def initialize(battle, move)
        super
        @statUp = DEFENDING_STATS_2
    end

    def pbEffectGeneral(user)
        user.applyEffect(:Charge)
        super
    end

    def getEffectScore(user, target)
        foundMove = false
        user.eachMove do |m|
            next if m.type != :ELECTRIC || !m.damagingMove?
            foundMove = true
            break
        end
        score = super
        if foundMove
            score += 20
        else
            score -= 20
        end
        return score
    end
end

#===============================================================================
# Increases the user's Sp. Atk by 2 steps, and Speed by 1 step. (Lightning Dance)
#===============================================================================
class PokeBattle_Move_503 < PokeBattle_MultiStatUpMove
    def initialize(battle, move)
        super
        @statUp = [:SPECIAL_ATTACK, 2, :SPEED, 1]
    end
end

#===============================================================================
# Increases the user's Speed and Sp. Atk by 2 steps. (Frolic)
#===============================================================================
class PokeBattle_Move_5E3 < PokeBattle_MultiStatUpMove
    def aiAutoKnows?(pokemon); return true; end

    def initialize(battle, move)
        super
        @statUp = [:SPEED, 2, :SPECIAL_ATTACK, 2]
    end
end

#===============================================================================
# Raises the user's Sp. Attack and Sp. Defense by 2 steps each, and Speed by 1.
# (Quiver Dance)
#===============================================================================
class PokeBattle_Move_02B < PokeBattle_MultiStatUpMove
    def aiAutoKnows?(pokemon); return true; end

    def initialize(battle, move)
        super
        @statUp = [:SPECIAL_ATTACK, 2, :SPECIAL_DEFENSE, 2, :SPEED, 1]
    end
end

#===============================================================================
# Raises the user's Sp. Attack and Sp. Defense by 2 step eachs. (Calm Mind)
#===============================================================================
class PokeBattle_Move_02C < PokeBattle_MultiStatUpMove
    def initialize(battle, move)
        super
        @statUp = [:SPECIAL_ATTACK, 2, :SPECIAL_DEFENSE, 2]
    end
end

#===============================================================================
# Increases the user's Sp. Atk, Sp. Def and accuracy by 2 steps each. (Store Fuel)
#===============================================================================
class PokeBattle_Move_54E < PokeBattle_MultiStatUpMove
    def initialize(battle, move)
        super
        @statUp = [:SPECIAL_ATTACK, 2, :SPECIAL_DEFENSE, 2, :ACCURACY, 2]
    end
end

#===============================================================================
# Increases the user's Sp. Atk and Sp. Def by 2 steps each. (Vanguard)
#===============================================================================
class PokeBattle_Move_513 < PokeBattle_MultiStatUpMove
    def initialize(battle, move)
        super
        @statUp = [:SPECIAL_ATTACK, 2, :DEFENSE, 2]
    end
end

#===============================================================================
# Raises the user's Attack, Defense, Speed, Special Attack and Special Defense
# by 1 step each. (Ancient Power, Ominous Wind, Silver Wind)
#===============================================================================
class PokeBattle_Move_02D < PokeBattle_MultiStatUpMove
    def initialize(battle, move)
        super
        @statUp = ALL_STATS_1
    end
end