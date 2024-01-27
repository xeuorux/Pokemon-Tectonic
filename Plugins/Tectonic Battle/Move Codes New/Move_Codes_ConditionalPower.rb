#===============================================================================
# Power is doubled if the target is using Dive. Hits some semi-invulnerable
# targets. (Surf)
#===============================================================================
class PokeBattle_Move_075 < PokeBattle_Move
    def hitsDivingTargets?; return true; end

    def pbBaseDamage(baseDmg, _user, target)
        baseDmg *= 2 if target.inTwoTurnAttack?("0CB") # Dive
        return baseDmg
    end

    def pbEffectAfterAllHits(user, target)
        if !target.damageState.unaffected && !target.damageState.protected && !target.damageState.missed && user.canGulpMissile?
            user.form = 2
            user.form = 1 if user.aboveHalfHealth?
            @battle.scene.pbChangePokemon(user, user.pokemon)
        end
    end

    def getEffectScore(user, _target)
        return 50 if user.canGulpMissile?
        return 0
    end
end

#===============================================================================
# Power is doubled if the target is using Dig. Hits digging targets. (Earthquake)
#===============================================================================
class PokeBattle_Move_076 < PokeBattle_Move
    def hitsDiggingTargets?; return true; end

    def pbBaseDamage(baseDmg, _user, target)
        baseDmg *= 2 if target.inTwoTurnAttack?("OCA") # Dig
        return baseDmg
    end
end

#===============================================================================
# Deals double damage on the first turn out. (Play Bite)
#===============================================================================
class PokeBattle_Move_013 < PokeBattle_Move
    def pbBaseDamage(baseDmg, user, target)
        baseDmg *= 2 if user.firstTurn?
        return baseDmg
    end
end

#===============================================================================
# Power is doubled if Fusion Flare has already been used this round. (Fusion Bolt)
#===============================================================================
class PokeBattle_Move_079 < PokeBattle_Move
    def pbChangeUsageCounters(user, specialUsage)
        @doublePower = @battle.field.effectActive?(:FusionFlare)
        super
    end

    def pbBaseDamage(baseDamage, _user, _target)
        baseDamage *= 2 if @doublePower
        return baseDamage
    end

    def pbBaseDamageAI(baseDmg, _user, _target)
        return baseDmg
    end

    def pbEffectGeneral(_user)
        @battle.field.applyEffect(:FusionBolt)
    end

    def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
        hitNum = 1 if (targets.length > 0 && targets[0].damageState.critical) || @doublePower # Charged anim
        super
    end
end

#===============================================================================
# Power is doubled if Fusion Bolt has already been used this round. (Fusion Flare)
#===============================================================================
class PokeBattle_Move_07A < PokeBattle_Move
    def pbChangeUsageCounters(user, specialUsage)
        @doublePower = @battle.field.effectActive?(:FusionBolt)
        super
    end

    def pbBaseDamage(baseDamage, _user, _target)
        baseDamage *= 2 if @doublePower
        return baseDamage
    end

    def pbBaseDamageAI(baseDmg, _user, _target)
        return baseDmg
    end

    def pbEffectGeneral(_user)
        @battle.field.applyEffect(:FusionFlare)
    end

    def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
        hitNum = 1 if (targets.length > 0 && targets[0].damageState.critical) || @doublePower # Charged anim
        super
    end
end

#===============================================================================
# Power is doubled if the target is burned. (Flare Up)
#===============================================================================
class PokeBattle_Move_50E < PokeBattle_Move
    def pbBaseDamage(baseDmg, _user, target)
        baseDmg *= 2 if target.burned?
        return baseDmg
    end
end

#===============================================================================
# Power is doubled if the target is frostbitten. (Ice Impact)
#===============================================================================
class PokeBattle_Move_50C < PokeBattle_Move
    def pbBaseDamage(baseDmg, _user, target)
        baseDmg *= 2 if target.frostbitten?
        return baseDmg
    end
end

#===============================================================================
# Power is doubled if the target is poisoned. (Venoshock)
#===============================================================================
class PokeBattle_Move_07B < PokeBattle_Move
    def pbBaseDamage(baseDmg, _user, target)
        baseDmg *= 2 if target.poisoned?
        return baseDmg
    end
end

#===============================================================================
# Power is doubled if the target is paralyzed. Cures the target of numb.
# (Smelling Salts)
#===============================================================================
class PokeBattle_Move_07C < PokeBattle_Move
    def pbBaseDamage(baseDmg, _user, target)
        baseDmg *= 2 if target.numbed?
        return baseDmg
    end

    def pbEffectAfterAllHits(_user, target)
        return if target.fainted?
        return if target.damageState.unaffected || target.damageState.substitute
        target.pbCureStatus(true, :NUMB)
    end

    def getTargetAffectingEffectScore(_user, target)
        return -30 if target.numbed?
        return 0
    end
end

#===============================================================================
# Power is doubled if the target is asleep. Wakes the target up. (Wake-Up Slap)
#===============================================================================
class PokeBattle_Move_07D < PokeBattle_Move
    def pbBaseDamage(baseDmg, _user, target)
        baseDmg *= 2 if target.asleep?
        return baseDmg
    end

    def pbEffectAfterAllHits(_user, target)
        return if target.fainted?
        return if target.damageState.unaffected || target.damageState.substitute
        target.pbCureStatus(true, :SLEEP)
    end

    def getTargetAffectingEffectScore(_user, target)
        return -60 if target.asleep?
        return 0
    end
end

#===============================================================================
# Power is doubled if the user is statused. (Facade, Hard Feelings)
# Burn/Frostbite's reduction of damage is negated.
#===============================================================================
class PokeBattle_Move_07E < PokeBattle_Move
    def damageReducedByBurn?; return false; end

    def pbBaseDamage(baseDmg, user, _target)
        baseDmg *= 2 if user.pbHasAnyStatus?
        return baseDmg
    end
end

#===============================================================================
# Power is doubled if the target has a status problem. (Hex, Cruelty)
#===============================================================================
class PokeBattle_Move_07F < PokeBattle_Move
    def pbBaseDamage(baseDmg, _user, target)
        baseDmg *= 2 if target.pbHasAnyStatus?
        return baseDmg
    end
end

#===============================================================================
# Power is doubled if the target's HP is down to 1/2 or less. (Brine, Dead End)
#===============================================================================
class PokeBattle_Move_080 < PokeBattle_Move
    def pbBaseDamage(baseDmg, _user, target)
        baseDmg *= 2 if target.belowHalfHealth?
        return baseDmg
    end
end

#===============================================================================
# Power is doubled if the user has lost HP due to the target's move this round.
# (Avalanche, Revenge)
#===============================================================================
class PokeBattle_Move_081 < PokeBattle_Move
    def pbBaseDamage(baseDmg, user, target)
        baseDmg *= 2 if user.lastAttacker.include?(target.index)
        return baseDmg
    end

    def pbBaseDamageAI(baseDmg, user, target)
        baseDmg *= 2 if user.pbSpeed(true, move: self) < target.pbSpeed
        return baseDmg
    end
end

#===============================================================================
# Power is doubled if the target has already lost HP this round. (Assurance)
#===============================================================================
class PokeBattle_Move_082 < PokeBattle_Move
    def pbBaseDamage(baseDmg, _user, target)
        baseDmg *= 2 if target.tookDamage
        return baseDmg
    end

    def pbBaseDamageAI(baseDmg, user, target)
        fastAllyAttacker = false
        user.eachAlly do |b|
            next unless b.hasDamagingAttack?
            fastAllyAttacker = true if b.pbSpeed(true) > user.pbSpeed(true, move: self)
        end
        baseDmg *= 2 if fastAllyAttacker
        return baseDmg
    end
end

#===============================================================================
# Power is doubled if a user's ally has already used this move this round. (Round)
# If an ally is about to use the same move, make it go next, ignoring priority.
#===============================================================================
class PokeBattle_Move_083 < PokeBattle_Move
    def pbBaseDamage(baseDmg, user, _target)
        baseDmg *= 2 if user.pbOwnSide.effectActive?(:Round)
        return baseDmg
    end

    def pbEffectGeneral(user)
        user.pbOwnSide.applyEffect(:Round)
        user.eachAlly do |b|
            next if @battle.choices[b.index][0] != :UseMove || b.movedThisRound?
            next if @battle.choices[b.index][2].function != @function
            b.applyEffect(:MoveNext)
            break
        end
    end

    def getEffectScore(user, _target)
        score = 0
        user.eachAlly do |b|
            next unless b.pbHasMove?(@id)
            score += 50
        end
        return score
    end
end

#===============================================================================
# Power is doubled if the target has already moved this round. (Payback)
#===============================================================================
class PokeBattle_Move_084 < PokeBattle_Move
    def pbBaseDamage(baseDmg, _user, target)
        baseDmg *= 2 if target.movedThisRound?
        return baseDmg
    end

    def pbBaseDamageAI(baseDmg, user, target)
        baseDmg *= 2 if user.pbSpeed(true, move: self) < target.pbSpeed
        return baseDmg
    end
end

#===============================================================================
# Power is doubled if a user's teammate fainted last round. (Retaliate)
#===============================================================================
class PokeBattle_Move_085 < PokeBattle_Move
    def pbBaseDamage(baseDmg, user, _target)
        baseDmg *= 2 if user.pbOwnSide.faintLastRound?
        return baseDmg
    end
end

#===============================================================================
# Power is doubled if the user has no held item. (Acrobatics, Detachment)
#===============================================================================
class PokeBattle_Move_086 < PokeBattle_Move
    def pbBaseDamage(baseDmg, user, _target)
        baseDmg *= 2 unless user.hasAnyItem?
        return baseDmg
    end
end