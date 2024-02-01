#===============================================================================
# Frostbite's the target.
#===============================================================================
class PokeBattle_Move_Frostbite < PokeBattle_FrostbiteMove
end

# Empowered Ice Beam
class PokeBattle_Move_637 < PokeBattle_Move_Frostbite
    include EmpoweredMove
end

#===============================================================================
# Frostbites the target. Accuracy perfect in hail. (Blizzard)
#===============================================================================
class PokeBattle_Move_FrostbiteTargetAlwaysHitsInHail < PokeBattle_FrostbiteMove
    def pbBaseAccuracy(user, target)
        return 0 if @battle.icy?
        return super
    end
end

#===============================================================================
# Frostbites the target. May cause the target to flinch. (Ice Fang)
#===============================================================================
class PokeBattle_Move_FrostbiteFlinchTarget < PokeBattle_Move
    def flinchingMove?; return true; end

    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        chance = pbAdditionalEffectChance(user, target, @calcType, 10)
        return if chance == 0
        if @battle.pbRandom(100) < chance && target.canFrostbite?(user, false, self) && canApplyRandomAddedEffects?(user,target,true)
            target.applyFrostbite(user)
        end 
        if @battle.pbRandom(100) < chance && canApplyRandomAddedEffects?(user,target,true)
            target.pbFlinch
        end
    end

    def getTargetAffectingEffectScore(user, target)
        score = 0
        score += 0.1 * getFrostbiteEffectScore(user, target)
        score += 0.1 * getFlinchingEffectScore(60, user, target, self)
        return score
    end
end

#===============================================================================
# If a Pokémon attacks the user with a special move before it uses this move, the
# attacker is frostbitten. (Condensate)
#===============================================================================
class PokeBattle_Move_FrostbiteAttackerBeforeUserActs < PokeBattle_Move
    def pbDisplayChargeMessage(user)
        user.applyEffect(:Condensate)
    end

    def getTargetAffectingEffectScore(user, target)
        if target.hasSpecialAttack?
            return getFrostbiteEffectScore(user, target) / 2
        else
            return 0
        end
    end
end

#===============================================================================
# Target is frostbitten if in moonglow. (Night Chill)
#===============================================================================
class PokeBattle_Move_FrostbitesTargetIfInMoonglow < PokeBattle_FrostbiteMove
    def pbAdditionalEffect(user, target)
        return unless @battle.moonGlowing?
        super
    end

    def getTargetAffectingEffectScore(user, target)
        return 0 unless @battle.moonGlowing?
        super
    end
end

# Empowered Chill
class PokeBattle_Move_EmpoweredChill < PokeBattle_Move
    include EmpoweredMove

    def pbEffectGeneral(user)
        super
        @battle.eachOtherSideBattler(user) do |b|
            b.applyFrostbite(user) if b.canFrostbite?(user, true, self)
        end
        transformType(user, :ICE)
    end
end