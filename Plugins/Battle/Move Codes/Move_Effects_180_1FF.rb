#===============================================================================
# User is protected against damaging moves this round. Decreases the Defense of
# the user of a stopped physical move by 2 stages. (Obstruct)
#===============================================================================
class PokeBattle_Move_180 < PokeBattle_ProtectMove
    def initialize(battle, move)
        super
        @effect = :Obstruct
    end
end

#===============================================================================
# Lowers target's Defense and Special Defense by 1 stage at the end of each
# turn. Prevents target from retreating. (Octolock)
#===============================================================================
class PokeBattle_Move_181 < PokeBattle_Move
    def pbFailsAgainstTarget?(_user, target, show_message)
        if target.effectActive?(:Octolock)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is already octolocked!"))
            end
            return true
        end
        if target.pbHasType?(:GHOST)
            if show_message
                @battle.pbDisplay(_INTL("But {1} isn't affected because it's a Ghost...",
target.pbThis(true)))
            end
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        target.applyEffect(:Octolock)
        target.pointAt(:OctolockUser, user)
    end

    def getEffectScore(_user, target)
        score = 60
        score += 60 if target.aboveHalfHealth?
        return score
    end
end

#===============================================================================
# Ignores move redirection from abilities and moves. (Snipe Shot)
#===============================================================================
class PokeBattle_Move_182 < PokeBattle_Move
    def cannotRedirect?; return true; end
end

#===============================================================================
# Consumes berry and raises the user's Defense by 2 stages. (Stuff Cheeks)
#===============================================================================
class PokeBattle_Move_183 < PokeBattle_Move
    def pbEffectGeneral(user)
        if !user.item || !user.item.is_berry?
            @battle.pbDisplay("But it failed!")
            return -1
        end
        user.tryRaiseStat(:DEFENSE, user, increment: 2, move: self)
        user.pbHeldItemTriggerCheck(user.item, false)
        user.pbConsumeItem(true, true, false) if user.item
    end

    def getEffectScore(user, target)
        score = getMultiStatUpEffectScore([:DEFENSE, 2], user, target)
        score += 40 if user.item&.is_berry?
        return score
    end
end

#===============================================================================
# Forces all active Pokémon to consume their held berries. This move bypasses
# Substitutes. (Tea Time)
#===============================================================================
class PokeBattle_Move_184 < PokeBattle_Move
    def ignoresSubstitute?(_user); return true; end

    def isValidTarget?(target)
        return target.item && target.item.is_berry? && !target.semiInvulnerable?
    end

    def pbMoveFailed?(_user, _targets, show_message)
        @battle.eachBattler do |b|
            return false if isValidTarget?(b)
        end
        @battle.pbDisplay(_INTL("But it failed, because no one has any berries!")) if show_message
        return true
    end

    def pbEffectGeneral(_user)
        @battle.pbDisplay(_INTL("It's tea time! Everyone dug in to their Berries!"))
    end

    def pbFailsAgainstTarget?(_user, target, _show_message)
        return !isValidTarget?(target)
    end

    def pbEffectAgainstTarget(_user, target)
        target.pbHeldItemTriggerCheck(target.item, false)
        target.pbConsumeItem(true, true, false) if target.item.is_berry?
    end

    def getEffectScore(_user, _target)
        return 60 # I don't understand the utility of this move
    end
end

#===============================================================================
# Decreases Opponent's Defense by 1 stage. Does Double Damage under gravity
# (Grav Apple)
#===============================================================================
class PokeBattle_Move_185 < PokeBattle_TargetStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:DEFENSE, 1]
    end

    def pbBaseDamage(baseDmg, _user, _target)
        baseDmg *= 1.5 if @battle.field.effectActive?(:Gravity)
        return baseDmg
    end
end

#===============================================================================
# Decrease 1 stage of speed and weakens target to fire moves. (Tar Shot)
#===============================================================================
class PokeBattle_Move_186 < PokeBattle_Move
    def pbFailsAgainstTarget?(_user, target, show_message)
        if !target.pbCanLowerStatStage?(:SPEED, target, self) && target.effectActive?(:TarShot)
            @battle.pbDisplay(_INTL("But it failed!")) if show_message
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        target.tryLowerStat(:SPEED, user, move: self)
        target.applyEffect(:TarShot)
    end

    def getEffectScore(user, target)
        score = 0
        score += getMultiStatDownEffectScore([:SPEED, 1], user, target)
        score += 60 unless target.effectActive?(:TarShot)
        return score
    end
end

#===============================================================================
# Changes Category based on Opponent's Def and SpDef. Has 20% Chance to Poison
# (Shell Side Arm)
#===============================================================================
class PokeBattle_Move_187 < PokeBattle_Move_005
    def initialize(battle, move)
        super
        @calculated_category = 1
    end

    def calculateCategory(user, targets)
        return selectBestCategory(user, targets[0])
    end
end

#===============================================================================
# Hits 3 times and always critical. (Surging Strikes)
#===============================================================================
class PokeBattle_Move_188 < PokeBattle_Move_0A0
    def multiHitMove?; return true; end
    def pbNumHits(_user, _targets, _checkingForAI = false); return 3; end
end

#===============================================================================
# Restore HP and heals any status conditions of itself and its allies
# (Jungle Healing)
#===============================================================================
class PokeBattle_Move_189 < PokeBattle_Move
    def healingMove?; return true; end

    def pbMoveFailed?(_user, targets, show_message)
        jglheal = 0
        for i in 0...targets.length
            jglheal += 1 if (targets[i].hp == targets[i].totalhp || !targets[i].canHeal?) && targets[i].status == :NONE
        end
        if jglheal == targets.length
            @battle.pbDisplay(_INTL("But it failed!")) if show_message
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        target.pbCureStatus
        if target.hp != target.totalhp && target.canHeal?
            hpGain = (target.totalhp / 4.0).round
            target.pbRecoverHP(hpGain)
        end
        super
    end
end

#===============================================================================
# Changes type and base power based on Battle Terrain (Terrain Pulse)
#===============================================================================
class PokeBattle_Move_18A < PokeBattle_Move
    def pbBaseDamage(baseDmg, user, _target)
        baseDmg *= 2 if @battle.field.terrain != :None && !user.airborne?
        return baseDmg
    end

    def pbBaseType(user)
        ret = :NORMAL
        unless user.airborne?
            case @battle.field.terrain
            when :Electric
                ret = :ELECTRIC || ret
            when :Grassy
                ret = :GRASS || ret
            when :Fairy
                ret = :FAIRY || ret
            when :Psychic
                ret = :PSYCHIC || ret
            end
        end
        return ret
    end

    def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
        t = pbBaseType(user)
        hitNum = 1 if t == :ELECTRIC
        hitNum = 2 if t == :GRASS
        hitNum = 3 if t == :FAIRY
        hitNum = 4 if t == :PSYCHIC
        super
    end
end

#===============================================================================
# Burns opposing Pokemon that have increased their stats. (Burning Jealousy)
#===============================================================================
class PokeBattle_Move_18B < PokeBattle_JealousyMove
    def initialize(battle, move)
        @statusToApply = :BURN
        super
    end
end

#===============================================================================
# Move has increased Priority in Grassy Terrain (Grassy Glide)
#===============================================================================
class PokeBattle_Move_18C < PokeBattle_Move
    def priorityModification(_user, _targets)
        return 1 if @battle.field.terrain == :Grassy
        return 0
    end

    def getEffectScore(_user, _target)
        return 50 if @battle.field.terrain == :Grassy
        return 0
    end

    def shouldHighlight?(_user, _target)
        return @battle.field.terrain == :Grassy
    end
end

#===============================================================================
# Power Doubles onn Electric Terrain (Rising Voltage)
#===============================================================================
class PokeBattle_Move_18D < PokeBattle_Move
    def pbBaseDamage(baseDmg, _user, target)
        baseDmg *= 2 if @battle.field.terrain == :Electric && !target.airborne?
        return baseDmg
    end
end

#===============================================================================
# Boosts Targets' Attack and Defense (Coaching)
#===============================================================================
class PokeBattle_Move_18E < PokeBattle_TargetMultiStatUpMove
    def initialize(battle, move)
        super
        @statUp = [:ATTACK, 1, :DEFENSE, 1]
    end
end

#===============================================================================
# Renders item unusable (Corrosive Gas)
#===============================================================================
class PokeBattle_Move_18F < PokeBattle_Move
    def removalMessageForTarget(target)
        itemName = target.itemName
        return _INTL("{1}'s {2} became unusuable, so it dropped it!", target.pbThis, itemName)
    end

    def pbEffectAgainstTarget(user, target)
        return if damagingMove?
        return unless canRemoveItem?(user, target)
        removeItem(user, target, false, removalMessageForTarget(target))
    end

    def pbEffectWhenDealingDamage(user, target)
        return unless canRemoveItem?(user, target)
        removeItem(user, target, false, removalMessageForTarget(target))
    end

    def getEffectScore(user, target)
        return 30 if canRemoveItem?(user, target)
        return 0
    end
end

#===============================================================================
# Power is boosted on Psychic Terrain (Expanding Force)
#===============================================================================
class PokeBattle_Move_190 < PokeBattle_Move
    def pbBaseDamage(baseDmg, _user, _target)
        baseDmg *= 1.5 if @battle.field.terrain == :Psychic
        return baseDmg
    end
end

#===============================================================================
# Boosts Sp Atk on 1st Turn and Attacks on 2nd (Meteor Beam)
#===============================================================================
class PokeBattle_Move_191 < PokeBattle_TwoTurnMove
    def pbChargingTurnMessage(user, _targets)
        @battle.pbDisplay(_INTL("{1} is overflowing with space power!", user.pbThis))
    end

    def pbChargingTurnEffect(user, _target)
        user.tryRaiseStat(:SPECIAL_ATTACK, user, move: self)
    end
end

#===============================================================================
# Fails if the Target has no Item (Poltergeist)
#===============================================================================
class PokeBattle_Move_192 < PokeBattle_Move
    def pbFailsAgainstTarget?(_user, target, show_message)
        if target.item
            if show_message
                @battle.pbDisplay(_INTL("{1} is about to be attacked by its {2}!", target.pbThis,
    target.itemName))
            end
            return false
        end
        @battle.pbDisplay(_INTL("But it failed!")) if show_message
        return true
    end
end

#===============================================================================
# Reduces Defense and Raises Speed after all hits (Scale Shot)
#===============================================================================
class PokeBattle_Move_193 < PokeBattle_Move_0C0
    def pbEffectAfterAllHits(user, _target)
        user.tryLowerStat(:DEFENSE, user, move: self)
        user.tryRaiseStat(:SPEED, user, move: self)
    end

    def getEffectScore(user, target)
        score = super
        score += getMultiStatUpEffectScore([:SPEED, 1], user, target)
        score -= getMultiStatDownEffectScore([:DEFENSE, 1], user, target)
        return score
    end
end

#===============================================================================
# Double damage if stats were lowered that turn. (Lash Out)
#===============================================================================
class PokeBattle_Move_194 < PokeBattle_Move
    def pbBaseDamage(baseDmg, user, _target)
        baseDmg *= 2 if user.effectActive?(:StatsDropped)
        return baseDmg
    end
end

#===============================================================================
# Removes all Terrain. Fails if there is no Terrain (Steel Roller)
#===============================================================================
class PokeBattle_Move_195 < PokeBattle_Move
    def pbMoveFailed?(_user, _targets, show_message)
        if @battle.field.terrain == :None
            @battle.pbDisplay(_INTL("But it failed, since there is no active terrain!")) if show_message
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        case @battle.field.terrain
        when :Electric
            @battle.pbDisplay(_INTL("The electric current disappeared from the battlefield!"))
        when :Grassy
            @battle.pbDisplay(_INTL("The grass disappeared from the battlefield!"))
        when :Fairy
            @battle.pbDisplay(_INTL("The fae mist disappeared from the battlefield!"))
        when :Psychic
            @battle.pbDisplay(_INTL("The weirdness disappeared from the battlefield!"))
        end
        @battle.pbStartTerrain(user, :None, false)
    end

    def getEffectScore(_user, _target)
        return 20
    end
end

#===============================================================================
# User loses half their max health. Boosted Damage when on Misty Terrain (Misty Explosion)
#===============================================================================
class PokeBattle_Move_196 < PokeBattle_Move_0E0
    def pbBaseDamage(baseDmg, user, _target)
        baseDmg = (baseDmg * 1.5).round if @battle.field.terrain == :Fairy && !user.airborne?
        return baseDmg
    end

    def getEffectScore(user, _target)
        return getHPLossEffectScore(user, 0.5)
    end

    def pbSelfKO(user)
        return if user.fainted?
        user.applyFractionalDamage(1.0 / 2.0, false)
    end
end

#===============================================================================
# Target becomes Psychic type. (Magic Powder)
#===============================================================================
class PokeBattle_Move_197 < PokeBattle_Move
    def pbFailsAgainstTarget?(_user, target, show_message)
        unless target.canChangeType?
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)}'s type can't be changed!"))
            end
            return true
        end
        if target.pbHasOtherType?(:PSYCHIC)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is already Psychic-type!"))
            end
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(_user, target)
        newType = :PSYCHIC
        target.pbChangeTypes(newType)
        typeName = newType.name
        @battle.pbDisplay(_INTL("{1} transformed into the {2} type!", target.pbThis, typeName))
    end

    def getEffectScore(_user, _target)
        return 50
    end
end

#===============================================================================
# Target's last move used loses 3 PP. (Eerie Spell)
#===============================================================================
class PokeBattle_Move_198 < PokeBattle_Move
    def pbEffectAgainstTarget(_user, target)
        target.eachMove do |m|
            next if m.id != target.lastRegularMoveUsed
            reduction = [3, m.pp].min
            target.pbSetPP(m, m.pp - reduction)
            @battle.pbDisplay(_INTL("It reduced the PP of {1}'s {2} by {3}!",
               target.pbThis(true), m.name, reduction))
            break
        end
    end
end

#===============================================================================
# Deals double damage to Dynamax POkémons. Dynamax is not implemented though.
# (Behemoth Blade, Behemoth Bash, Dynamax Cannon)
#===============================================================================
class PokeBattle_Move_199 < PokeBattle_Move
    # DYNAMAX IS NOT IMPLEMENTED.
end
