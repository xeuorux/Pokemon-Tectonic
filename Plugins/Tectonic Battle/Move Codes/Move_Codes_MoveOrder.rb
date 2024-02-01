#===============================================================================
# Target moves immediately after the user, ignoring priority/speed. (After You)
#===============================================================================
class PokeBattle_Move_TargetActsNext < PokeBattle_Move
    def ignoresSubstitute?(_user); return true; end

    def pbFailsAgainstTarget?(_user, target, show_message)
        # Target has already moved this round
        return true if pbMoveFailedTargetAlreadyMoved?(target, show_message)
        # Target was going to move next anyway (somehow)
        if target.effectActive?(:MoveNext)
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is already being forced to move next!")) if show_message
            return true
        end
        # Target didn't choose to use a move this round
        oppMove = @battle.choices[target.index][2]
        unless oppMove
            @battle.pbDisplay(_INTL("But it failed. since #{target.pbThis(true)} isn't using a move this turn!")) if show_message
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(_user, target)
        target.applyEffect(:MoveNext)
        @battle.pbDisplay(_INTL("{1} took the kind offer!", target.pbThis))
    end

    def pbFailsAgainstTargetAI?(_user, _target); return false; end

    def getEffectScore(user, target)
        return 0 if user.opposes?(target)
        userSpeed = user.pbSpeed(true, move: self)
        targetSpeed = target.pbSpeed(true)
        return 0 if targetSpeed > userSpeed
        return 60
    end
end

#===============================================================================
# Target moves last this round, ignoring priority/speed. (Quash)
#===============================================================================
class PokeBattle_Move_TargetActsLast < PokeBattle_Move
    def pbFailsAgainstTarget?(_user, target, show_message)
        return true if pbMoveFailedTargetAlreadyMoved?(target, show_message)
        # Target isn't going to use a move
        oppMove = @battle.choices[target.index][2]
        unless oppMove
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} isn't using a move this turn!")) if show_message
            return true
        end
        # Target is already maximally Quashed and will move last anyway
        highestQuash = 0
        @battle.eachBattler do |b|
            next if b.effects[:Quash] <= highestQuash
            highestQuash = b.effects[:Quash]
        end
        if highestQuash > 0 && target.effects[:Quash] == highestQuash
            @battle.pbDisplay(_INTL("But it failed!")) if show_message
            return true
        end
        # Target was already going to move last
        if highestQuash == 0 && @battle.pbPriority.last.index == target.index
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} was already forced to move last!")) if show_message
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(_user, target)
        highestQuash = 0
        @battle.eachBattler do |b|
            next if b.effects[:Quash] <= highestQuash
            highestQuash = b.effects[:Quash]
        end
        target.applyEffect(:Quash, highestQuash + 1)
        @battle.pbDisplay(_INTL("{1}'s move was postponed!", target.pbThis))
    end

    def pbFailsAgainstTargetAI?(_user, _target); return false; end

    def getTargetAffectingEffectScore(user, target)
        return 0 unless user.opposes?(target)
        return 0 unless user.hasAlly?
        userSpeed = user.pbSpeed(true, move: self)
        targetSpeed = target.pbSpeed(true)
        return 0 if targetSpeed > userSpeed
        return 50
    end
end

#===============================================================================
# Spurs all allies to move immediately after. (Vainglory Flames)
#===============================================================================
class PokeBattle_Move_AlliesActNext < PokeBattle_Move
    def pbEffectGeneral(user)
        user.eachAlly do |b|
            b.applyEffect(:MoveNext)
            @battle.pbDisplay(_INTL("{1} is fired up!", b.pbThis))
        end
    end
end

#===============================================================================
# Target moves immediately after the user, ignoring priority/speed. (Kickstart)
#===============================================================================
class PokeBattle_Move_TargetActsNextDamagingMove < PokeBattle_Move
    def pbEffectAgainstTarget(_user, target)
        return if target.fainted?
        return if pbMoveFailedTargetAlreadyMoved?(target) # Target has already moved this round
        return if target.effectActive?(:MoveNext) # Target was going to move next anyway (somehow)
        return if @battle.choices[target.index][2].nil? # Target didn't choose to use a move this round
        target.applyEffect(:MoveNext)
        @battle.pbDisplay(_INTL("{1} was kickstarted into action!", target.pbThis))
    end

    def getEffectScore(_user, _target)
        echoln("The AI will never use Kickstart.")
        return -1000
    end
end

#===============================================================================
# Target moves immediately after the user and deals 50% more damage. (Amp Up)
#===============================================================================
class PokeBattle_Move_TargetActsNextBoostsTheirDamage < PokeBattle_Move_PowerUpAllyMove
    def pbEffectAgainstTarget(_user, target)
        super
        target.applyEffect(:MoveNext)
        @battle.pbDisplay(_INTL("{1} is amped up!", target.pbThis))
    end

    def pbFailsAgainstTargetAI?(_user, _target); return false; end

    def getEffectScore(user, target)
        score = super
        score += 50 if @battle.battleAI.userMovesFirst?(self, user, target)
        return score
    end
end