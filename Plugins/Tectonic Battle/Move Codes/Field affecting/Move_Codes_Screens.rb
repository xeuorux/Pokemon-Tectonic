#===============================================================================
# For 10 rounds, foes' attacks cannot become critical hits.
#===============================================================================
class PokeBattle_Move_StartPreventCriticalHitsAgainstUserSide10 < PokeBattle_Move
    def initialize(battle, move)
        super
        @luckyChantDuration = 10
    end

    def pbEffectGeneral(user)
        duration = applyEffectDurationModifiers(@luckyChantDuration, user)
        user.pbOwnSide.applyEffect(:LuckyChant, duration)
    end

    def getEffectScore(user, _target)
        duration = applyEffectDurationModifiers(@luckyChantDuration, user)
        return getLuckyChantEffectScore(user, duration)
    end
end

#===============================================================================
# Protects the user's side from critical hits and some damage. (Sanctuary)
#===============================================================================
class PokeBattle_Move_StartPreventCriticalHitsAndReduceDamageAgainstUserSide5 < PokeBattle_Move
    def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
        super
        if damagingMove? && showAnimation && !user.pbOwnSide.effectActive?(:Sanctuary)
            @battle.pbAnimation(:LUCKYCHANT, user, nil, hitNum)
        end
    end

    def pbEffectGeneral(user)
        return if damagingMove?
        user.pbOwnSide.applyEffect(:Sanctuary, user.getScreenDuration)
    end

    def pbAdditionalEffect(user, target)
        user.pbOwnSide.applyEffect(:Sanctuary, user.getScreenDuration)
    end

    def getEffectScore(user, _target)
        return getSanctuaryEffectScore(user, nil, self)
    end
end

#===============================================================================
# For 5 rounds, lowers power of physical attacks against the user's side.
# (Reflect)
#===============================================================================
class PokeBattle_Move_StartWeakenPhysicalDamageAgainstUserSide5 < PokeBattle_Move
    def pbEffectGeneral(user)
        user.pbOwnSide.applyEffect(:Reflect, user.getScreenDuration)
    end

    def getEffectScore(user, _target)
        return getReflectEffectScore(user, nil, self)
    end
end

#===============================================================================
# For 5 rounds, lowers power of special attacks against the user's side. (Light Screen)
#===============================================================================
class PokeBattle_Move_StartWeakenSpecialDamageAgainstUserSide5 < PokeBattle_Move
    def pbEffectGeneral(user)
        user.pbOwnSide.applyEffect(:LightScreen, user.getScreenDuration)
    end

    def getEffectScore(user, _target)
        return getLightScreenEffectScore(user, nil, self)
    end
end

#===============================================================================
# For 5 rounds, lowers power of attacks against the user's side. Fails if
# weather is not hail. (Aurora Veil)
#===============================================================================
class PokeBattle_Move_StartWeakenDamageAgainstUserSideIfInHail5 < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        unless @battle.icy?
            @battle.pbDisplay(_INTL("But it failed, since it's not Hailing!")) if show_message
            return true
        end
        if user.pbOwnSide.effectActive?(:AuroraVeil)
            @battle.pbDisplay(_INTL("But it failed, since Aurora Veil is already active!")) if show_message
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        user.pbOwnSide.applyEffect(:AuroraVeil, user.getScreenDuration)
    end

    def getEffectScore(user, _target)
        return getScreenEffectScore(user, :AuroraVeil, nil, self)
    end
end

#===============================================================================
# For 5 rounds, lowers power of attacks with 100+ BP against the user's side. (Repulsion Field)
#===============================================================================
class PokeBattle_Move_StartWeaken100PowerOrHigherDamageAgainstUserSide5 < PokeBattle_Move
    def pbEffectGeneral(user)
        user.pbOwnSide.applyEffect(:RepulsionField, user.getScreenDuration)
    end

    def getEffectScore(user, _target)
        score = 0
        user.eachOpposing do |b|
            score += 40 if b.hasDamagingAttack?
        end
        score += 15 * user.getScreenDuration(aiCheck: true)
        score = (score * 1.3).ceil if user.fullHealth?
        return score
    end
end