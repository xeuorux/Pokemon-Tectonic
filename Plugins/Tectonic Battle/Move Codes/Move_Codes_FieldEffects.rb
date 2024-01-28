#===============================================================================
# For 4 rounds, doubles the Speed of all battlers on the user's side. (Tailwind)
#===============================================================================
class PokeBattle_Move_05B < PokeBattle_Move
    def initialize(battle, move)
        super
        @tailwindDuration = 4
    end

    def pbEffectGeneral(user)
        user.pbOwnSide.applyEffect(:Tailwind, @tailwindDuration)
    end

    def getEffectScore(user, _target)
        return getTailwindEffectScore(user, @tailwindDuration, self)
    end
end

#===============================================================================
# For 5 rounds, increases gravity on the field. Pokémon cannot become airborne.
# (Gravity)
#===============================================================================
class PokeBattle_Move_118 < PokeBattle_Move
    def initialize(battle, move)
        super
        @gravityDuration = 5
    end

    def pbEffectGeneral(_user)
        @battle.field.applyEffect(:Gravity, @gravityDuration)
    end

    def getEffectScore(user, _target)
        return getGravityEffectScore(user, @gravityDuration)
    end
end

#===============================================================================
# Heals every active battler by 1/8th of their HP for the next 5 turns. (Floral Gramarye)
#===============================================================================
class PokeBattle_Move_137 < PokeBattle_Move
    def pbEffectGeneral(_user)
        @battle.field.applyEffect(:FloralGramarye, 5) unless @battle.field.effectActive?(:FloralGramarye)
    end

    def pbMoveFailed?(_user, _targets, show_message)
        return false if damagingMove?
        if @battle.field.effectActive?(:FloralGramarye)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since the field is already covered in flowers!"))
            end
            return true
        end
        return false
    end

    def getEffectScore(user, _target)
        return 100
    end
end