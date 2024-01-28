#===============================================================================
# The user raises the target's Attack and Sp. Atk by 5 steps by decorating
# the target. (Decorate)
#===============================================================================
class PokeBattle_Move_17B < PokeBattle_TargetMultiStatUpMove
    def initialize(battle, move)
        super
        @statUp = [:ATTACK, 5, :SPECIAL_ATTACK, 5]
    end
end

#===============================================================================
# Boosts Targets' Attack and Defense by 2 steps each. (Coaching)
#===============================================================================
class PokeBattle_Move_18E < PokeBattle_TargetMultiStatUpMove
    def initialize(battle, move)
        super
        @statUp = [:ATTACK, 2, :DEFENSE, 2]
    end
end

#===============================================================================
# Boosts Targets' Sp. Atk and Sp. Def by 2 steps. (Tutelage)
#===============================================================================
class PokeBattle_Move_5CE < PokeBattle_TargetMultiStatUpMove
    def initialize(battle, move)
        super
        @statUp = [:SPECIAL_ATTACK, 2, :SPECIAL_DEFENSE, 2]
    end
end

#===============================================================================
# Increases target's Defense and Special Defense by 3 steps. (Aromatic Mist)
#===============================================================================
class PokeBattle_Move_138 < PokeBattle_TargetMultiStatUpMove
    def ignoresSubstitute?(_user); return true; end

    def initialize(battle, move)
        super
        @statUp = [:DEFENSE, 3, :SPECIAL_DEFENSE, 3]
    end
end

#===============================================================================
# Doubles an allies Attack and Speed. The user cannot swap out of battle.
# If the user faints, so too does that ally. (Dragon Ride)
#===============================================================================
class PokeBattle_Move_575 < PokeBattle_Move
    def pbFailsAgainstTarget?(user, target, show_message)
        if target.effectActive?(:OnDragonRide)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is already on a dragon ride!"))
            end
            return true
        end
        if user.effectActive?(:GivingDragonRideTo)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis} is already giving a dragon ride!"))
            end
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        target.applyEffect(:OnDragonRide)
        user.applyEffect(:GivingDragonRideTo, target.index)
        @battle.pbDisplay(_INTL("{1} gives {2} a ride on its back!", user.pbThis, target.pbThis(true)))
    end

    def getEffectScore(user, target)
        return 0 if user.effects[:PerishSong] > 0
        return 0 if user.belowHalfHealth?
        return 0 unless target.hasPhysicalAttack?
        return 150
    end
end

#===============================================================================
# Damages target if target is a foe, or buff's the target's Speed
# by four steps if it's an ally. (Lightning Spear)
#===============================================================================
class PokeBattle_Move_5C8 < PokeBattle_Move
    def pbOnStartUse(user, targets)
        @buffing = false
        @buffing = !user.opposes?(targets[0]) if targets.length > 0
    end

    def pbFailsAgainstTarget?(user, target, show_message)
        return false unless @buffing
        return !target.pbCanRaiseStatStep?(:SPEED, user, self, true)
    end

    def damagingMove?(aiCheck = false)
        if aiCheck
            return super
        else
            return false if @buffing
            return super
        end
    end

    def pbEffectAgainstTarget(user, target)
        return unless @buffing
        target.pbRaiseMultipleStatSteps([:SPEED, 4], user, move: self)
    end

    def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
        if @buffing
            @battle.pbAnimation(:CHARGE, user, targets, hitNum) if showAnimation
        else
            super
        end
    end
end