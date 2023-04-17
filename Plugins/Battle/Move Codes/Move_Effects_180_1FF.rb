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
# Consumes berry and raises the user's Defense and Sp. Def by 3 stages. (Stuff Cheeks)
#===============================================================================
class PokeBattle_Move_183 < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        return false if user.hasAnyBerry?
        @battle.pbDisplay(_INTL("But it failed, because #{user.pbThis(true)} has no berries!")) if show_message
        return true
    end

    def pbEffectGeneral(user)
        user.pbRaiseMultipleStatStages([:DEFENSE, 3, :SPECIAL_DEFENSE, 3], user, move: self)
        user.eachItem do |item|
            next unless GameData::Item.get(item).is_berry?
            user.pbHeldItemTriggerCheck(item, false)
            user.consumeItem(item)
        end
    end

    def getEffectScore(user, target)
        score = getMultiStatUpEffectScore([:DEFENSE, 3, :SPECIAL_DEFENSE, 3], user, target)
        user.eachItem do |item|
            next unless GameData::Item.get(item).is_berry?
            score += 40
        end
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
        return target.hasAnyBerry? && !target.semiInvulnerable?
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
        target.eachItem do |item|
            next unless GameData::Item.get(item).is_berry?
            target.pbHeldItemTriggerCheck(item, false)
            target.consumeItem(item)
        end
    end

    def getEffectScore(_user, _target)
        return 60 # I don't understand the utility of this move
    end
end

#===============================================================================
# (Not currently used)
#===============================================================================
class PokeBattle_Move_185 < PokeBattle_Move
end

#===============================================================================
# Decrease 3 stages of speed and weakens target to fire moves. (Tar Shot)
#===============================================================================
class PokeBattle_Move_186 < PokeBattle_Move
    def pbFailsAgainstTarget?(_user, target, show_message)
        if !target.pbCanLowerStatStage?(:SPEED, target, self) && target.effectActive?(:TarShot)
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is already covered in tar and can't have their Speed lowered!")) if show_message
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        target.tryLowerStat(:SPEED, user, move: self, increment: 3)
        target.applyEffect(:TarShot)
    end

    def getEffectScore(user, target)
        score = 0
        score += getMultiStatDownEffectScore([:SPEED, 3], user, target)
        score += 50 unless target.effectActive?(:TarShot)
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
            @battle.pbDisplay(_INTL("But it failed, since none of #{user.pbThis(true)} or its allies can be healed or have their status conditions removed!")) if show_message
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
# (Not currently used)
#===============================================================================
class PokeBattle_Move_18A < PokeBattle_Move
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
# Move has increased Priority in sunshine (Solar Glide)
#===============================================================================
class PokeBattle_Move_18C < PokeBattle_Move
    def priorityModification(_user, _targets)
        return 1 if @battle.sunny?
        return 0
    end

    def shouldHighlight?(_user, _target)
        return @battle.sunny?
    end
end

#===============================================================================
# (Not currently used.)
#===============================================================================
class PokeBattle_Move_18D < PokeBattle_Move
end

#===============================================================================
# Boosts Targets' Attack and Defense by 2 stages each. (Coaching)
#===============================================================================
class PokeBattle_Move_18E < PokeBattle_TargetMultiStatUpMove
    def initialize(battle, move)
        super
        @statUp = [:ATTACK, 2, :DEFENSE, 2]
    end
end

#===============================================================================
# Renders item unusable (Slime Ball)
#===============================================================================
class PokeBattle_Move_18F < PokeBattle_Move
    def pbEffectAgainstTarget(user, target)
        return if damagingMove?
        return unless canknockOffItems?(user, target)
        knockOffItems(user, target) do |_item, itemName|
            @battle.pbDisplay(_INTL("{1}'s {2} became unusuable, so it dropped it!", target.pbThis, itemName))
        end
    end

    def pbEffectWhenDealingDamage(user, target)
        return unless canknockOffItems?(user, target)
        knockOffItems(user, target) do |_item, itemName|
            @battle.pbDisplay(_INTL("{1}'s {2} became unusuable, so it dropped it!", target.pbThis, itemName))
        end
    end

    def getEffectScore(user, target)
        score = 0
        target.eachItem do |item|
            score += 30 if canRemoveItem?(user, target, item, checkingForAI: true)
        end
        return score
    end
end

#===============================================================================
# Power is boosted on Psychic Terrain (Shattered Energy)
#===============================================================================
class PokeBattle_Move_190 < PokeBattle_Move
    def pbBaseDamage(baseDmg, _user, _target)
        baseDmg *= 1.5 if @battle.pbWeather == :Eclipse
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
        user.tryRaiseStat(:SPECIAL_ATTACK, user, move: self, increment: 3)
    end
end

#===============================================================================
# Fails if the Target has no Item (Poltergeist)
#===============================================================================
class PokeBattle_Move_192 < PokeBattle_Move
    def pbFailsAgainstTarget?(_user, target, show_message)
        if target.hasAnyItem?
            if show_message
                @battle.pbDisplay(_INTL("{1} is about to be attacked by its {2}!", target.pbThis, target.itemCountD))
            end
            return false
        end
        @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} doesn't have any items!")) if show_message
        return true
    end
end

#===============================================================================
# (Not currently used.)
#===============================================================================
class PokeBattle_Move_193 < PokeBattle_Move
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
# (Not currently used.)
#===============================================================================
class PokeBattle_Move_196 < PokeBattle_Move

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
