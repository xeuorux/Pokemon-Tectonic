class PokeBattle_Battler
    #=============================================================================
    # Confusion
    #=============================================================================
    def confused?
        return effectActive?(:Confusion)
    end

    def canConfuse?(user = nil, showMessages = true, move = nil, selfInflicted = false)
        return false if fainted?
        if confused?
            @battle.pbDisplay(_INTL("{1} is already confused.", pbThis)) if showMessages
            return false
        end
        if substituted? && !(move && move.ignoresSubstitute?(user)) &&
           !selfInflicted
            @battle.pbDisplay(_INTL("But it failed!")) if showMessages
            return false
        end
        if (selfInflicted || !@battle.moldBreaker) && hasActiveAbility?(:OWNTEMPO)
            if showMessages
                @battle.pbShowAbilitySplash(self)
                @battle.pbDisplay(_INTL("{1} doesn't become confused!", pbThis))
                @battle.pbHideAbilitySplash(self)
            end
            return false
        end
        if pbOwnSide.effectActive?(:Safeguard) && !selfInflicted && !(user && user.hasActiveAbility?(:INFILTRATOR))
            @battle.pbDisplay(_INTL("{1}'s team is protected by Safeguard!", pbThis)) if showMessages
            return false
        end
        return true
    end

    def pbCanConfuseSelf?(showMessages)
        return canConfuse?(nil, showMessages, nil, true)
    end

    def pbConfuse(_msg = nil)
        applyEffect(:Confusion, pbConfusionDuration)
        applyEffect(:ConfusionChance, 0)
    end

    def pbConfusionDuration(duration = -1)
        duration = 3 if duration <= 0
        return duration
    end

    #=============================================================================
    # Charm
    #=============================================================================
    def charmed?
        return effectActive?(:Charm)
    end

    def canCharm?(user = nil, showMessages = true, move = nil, selfInflicted = false)
        return false if fainted?
        if charmed?
            @battle.pbDisplay(_INTL("{1} is already charmed.", pbThis)) if showMessages
            return false
        end
        if substituted? && !(move && move.ignoresSubstitute?(user)) &&
           !selfInflicted
            @battle.pbDisplay(_INTL("But it failed!")) if showMessages
            return false
        end
        if (selfInflicted || !@battle.moldBreaker) && hasActiveAbility?(:OWNTEMPO)
            if showMessages
                @battle.pbShowAbilitySplash(self)
                @battle.pbDisplay(_INTL("{1} doesn't become charmed!", pbThis))
                @battle.pbHideAbilitySplash(self)
            end
            return false
        end
        if pbOwnSide.effectActive?(:Safeguard) && !selfInflicted && !(user && user.hasActiveAbility?(:INFILTRATOR))
            @battle.pbDisplay(_INTL("{1}'s team is protected by Safeguard!", pbThis)) if showMessages
            return false
        end
        return true
    end

    def pbCanCharmSelf?(showMessages)
        return canConfuse?(nil, showMessages, nil, true)
    end

    def pbCharm(_msg = nil)
        applyEffect(:Charm, pbCharmDuration)
        applyEffect(:CharmChance, 0)
    end

    def pbCharmDuration(duration = -1)
        duration = 3 if duration <= 0
        return duration
    end
end
