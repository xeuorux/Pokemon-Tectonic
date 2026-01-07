#===============================================================================
# Target switches out, to be replaced at random.
# For status moves. (Roar, Whirlwind)
#===============================================================================
class PokeBattle_Move_SwitchOutTargetStatusMove < PokeBattle_Move
    def forceSwitchMove?; return true; end

    def ignoresSubstitute?(_user); return true; end

    def pbFailsAgainstTarget?(user, target, show_message)
        if target.effectActive?(:Ingrain) || target.effectActive?(:EvilRoots)
            @battle.pbDisplay(_INTL("{1} anchored itself with its roots!", target.pbThis)) if show_message
            return true
        end
        if @battle.wildBattle? && !@battle.canRun
            @battle.pbDisplay(_INTL("But it failed, since the battle can't be run from!")) if show_message
            return true
        end
        if @battle.wildBattle? && (target.level > user.level)
            @battle.pbDisplay(_INTL("But it failed, since {1}'s level is greater than {2}'s!", target.pbThis(true), user.pbThis(true))) if show_message
            return true
        end
        if @battle.wildBattle? && target.boss
            @battle.pbDisplay(_INTL("But it failed, since {1} is an Avatar!", target.pbThis(true))) if show_message
            return true
        end
        if @battle.trainerBattle? && !@battle.pbCanChooseNonActive?(target.index)
            @battle.pbDisplay(_INTL("But it failed, since {1} cannot be replaced!", target.pbThis(true))) if show_message
            return true
        end
        return false
    end

    def pbSwitchOutTargetsEffect(user, targets, numHits, switchedBattlers)
        return if numHits == 0
        forceOutTargets(user, targets, switchedBattlers, substituteBlocks: false)
    end

    def getTargetAffectingEffectScore(user, target)
        return getForceOutEffectScore(user, target)
    end
end

# Empowered Whirlwind
class PokeBattle_Move_EmpoweredWhirlwind < PokeBattle_Move_SwitchOutTargetStatusMove
    include EmpoweredMove

    def pbEffectGeneral(user)
        transformType(user, :FLYING)
    end
end

#===============================================================================
# Target switches out, to be replaced at random.
# For damaging moves. (Discourage, Dragon Tail)
#===============================================================================
class PokeBattle_Move_SwitchOutTargetDamagingMove < PokeBattle_Move
    def forceSwitchMove?; return true; end

    def pbSwitchOutTargetsEffect(user, targets, numHits, switchedBattlers)
        return if numHits == 0
        forceOutTargets(user, targets, switchedBattlers, substituteBlocks: true)
    end

    def getTargetAffectingEffectScore(user, target)
        return getForceOutEffectScore(user, target)
    end
end

#===============================================================================
# If the move misses, all targets are forced to switch out. (Rolling Boulder)
#===============================================================================
class PokeBattle_Move_SwitchOutTargetIfMisses < PokeBattle_Move
    def forceSwitchMove?; return true; end

    # This method is called if a move fails to hit all of its targets
    def pbAllMissed(user, targets)
        forceOutTargets(user,targets,[],substituteBlocks: true, invertMissCheck: true)
    end

    def getEffectScore(user, target)
        return getForceOutEffectScore(user, target) * 0.5
    end
end

#===============================================================================
# Target switches out, to be replaced manually. (Thorn Rattle)
#===============================================================================
class PokeBattle_Move_SwitchOutTargetDamagingMoveNonRandom < PokeBattle_Move
    def forceSwitchMove?; return true; end

    def pbSwitchOutTargetsEffect(user, targets, numHits, switchedBattlers)
        return if numHits == 0
        forceOutTargets(user, targets, switchedBattlers, substituteBlocks: false)
    end

    def getTargetAffectingEffectScore(user, target)
        return getForceOutEffectScore(user, target, false)
    end
end