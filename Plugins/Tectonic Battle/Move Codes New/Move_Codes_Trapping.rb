#===============================================================================
# Trapping move. Traps for 3 or 6 rounds. Trapped Pokémon lose 1/16 of max HP
# at end of each round.
#===============================================================================
class PokeBattle_Move_0CF < PokeBattle_Move
    def pbEffectAgainstTarget(user, target)
        return if target.fainted? || target.damageState.substitute
        return if target.effectActive?(:Trapping)
        # Set trapping effect duration and info
        trappingDuration = 3
        trappingDuration *= 2 if user.hasActiveItem?(:GRIPCLAW)
        target.applyEffect(:Trapping, trappingDuration)
        target.applyEffect(:TrappingMove, @id)
        target.pointAt(:TrappingUser, user)
        # Message
        msg = _INTL("{1} was trapped!", target.pbThis)
        case @id
        when :BIND, :VINEBIND, :BEARHUG
            msg = _INTL("{1} was squeezed by {2}!", target.pbThis, user.pbThis(true))
        when :CLAMP, :SLAMSHUT
            msg = _INTL("{1} clamped {2}!", user.pbThis, target.pbThis(true))
        when :FIRESPIN, :CRIMSONSTORM
            msg = _INTL("{1} was trapped in the fiery vortex!", target.pbThis)
        when :INFESTATION,:TERRORSWARM
            msg = _INTL("{1} has been afflicted with an infestation by {2}!", target.pbThis, user.pbThis(true))
        when :MAGMASTORM
            msg = _INTL("{1} became trapped by Magma Storm!", target.pbThis)
        when :SANDTOMB, :SANDVORTEX
            msg = _INTL("{1} became trapped by sand!", target.pbThis)
        when :WHIRLPOOL, :MAELSTROM
            msg = _INTL("{1} became trapped in the vortex!", target.pbThis)
        when :WRAP
            msg = _INTL("{1} was wrapped by {2}!", target.pbThis, user.pbThis(true))
        when :SHATTERVISE
            msg = _INTL("{1} was caught in {2}'s vises!", target.pbThis, user.pbThis(true))
        when :DRAGBENEATH
            msg = _INTL("{1} was dragged beneath the waves!", target.pbThis)
        end
        @battle.pbDisplay(msg)
    end

    def getEffectScore(_user, target)
        return 0 if target.effectActive?(:Trapping) || target.substituted?
        return 40
    end
end

#===============================================================================
# Target can no longer switch out or flee, as long as the user remains active.
# (Anchor Shot, Block, Mean Look, Spider Web, Spirit Shackle, Thousand Waves)
#===============================================================================
class PokeBattle_Move_0EF < PokeBattle_Move
    def pbFailsAgainstTarget?(_user, target, show_message)
        return false if damagingMove?
        if target.effectActive?(:MeanLook)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} already can't escape!"))
            end
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        return if damagingMove?
        target.pointAt(:MeanLook, user) unless target.effectActive?(:MeanLook)
    end

    def pbAdditionalEffect(user, target)
        return if target.fainted? || target.damageState.substitute
        return if target.effectActive?(:MeanLook)
        target.pointAt(:MeanLook, user) unless target.effectActive?(:MeanLook)
    end

    def getTargetAffectingEffectScore(_user, target)
        return 0 if target.effectActive?(:MeanLook)
        return 50
    end
end