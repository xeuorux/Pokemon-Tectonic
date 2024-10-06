class PokeBattle_Battler
    include EffectHolder

    def resetEffects
        @effects.clear

        GameData::BattleEffect.each_battler_effect do |effectData|
            @effects[effectData.id] = effectData.default
        end

        # Reset values, accounting for baton pass
        GameData::BattleEffect.each_battler_effect do |effectData|
            effectID = effectData.id
            # Reset the value to its default
            # Unless its a baton passable value and we are baton passing
            if batonPass && effectData.baton_passed
                currentValue = @effects[effectID]
                newValue = effectData.baton_pass_value(self, currentValue)
                @effects[effectID] = newValue
            else
                @effects[effectID] = effectData.default
            end
            effectData.initialize_battler(@battle, self)
        end
    end

    def applyEffect(effect, value = nil, ignoreFainted = false)
        return if fainted? && !ignoreFainted
        super(effect, value)
        # echoln("[BATTLER EFFECT] Effect #{effect} applied to battler #{pbThis(true)}") if !effectActive?(effect)
        if getData(effect).is_mental?
            pbItemStatusCureCheck
            pbAbilityStatusCureCheck
        end

        if getData(effect).trapping?
            eachActiveAbility do |ability|
                BattleHandlers.triggerCertainSwitchingUserAbility(ability, self, @battle, true)
            end
            refreshDataBox
        end
    end

    def disableEffect(effect, ignoreFainted = false)
        return if fainted? && !ignoreFainted
        # echoln("[BATTLER EFFECT] Effect #{effect} disabled on battler #{pbThis(true)}") if effectActive?(effect)
        super(effect)

        refreshDataBox if getData(effect).trapping?
    end

    def effectActive?(effect, ignoreFainted = false)
        return false if fainted? && !ignoreFainted
        super(effect)
    end

    def countEffect(effect, ignoreFainted = false)
        return 0 if fainted? && !ignoreFainted
        super(effect)
    end

    def processEffectsEOR
        return if fainted?
        super
    end

    def eachEffectAlsoPosition(onlyActive = false, alsoPosition, &block)
        super(onlyActive).each(&block)
        @battle.positions[@index].eachEffect(onlyActive, &block) if alsoPosition
    end

    def getReleventEffectHolders
        holders = [self, @battle.positions[@index], pbOwnSide, @battle.field]
    end

    def eachEffectAllLocations(onlyActive = false, &block)
        getReleventEffectHolders.each do |effectHolder|
            effectHolder.eachEffect(onlyActive, &block)
        end
    end

    def modifyTrackersEOR
        @lastHPLost = 0
        @lastHPLostFromFoe                    = 0
        @tookDamage                           = false
        @tookPhysicalHitLastRound             = @tookPhysicalHit
        @tookPhysicalHit                      = false
        @tookSpecialHitLastRound              = @tookSpecialHit
        @tookSpecialHit                       = false
        @lastRoundMoveFailed                  = @lastMoveFailed
        @lastAttacker.clear
        @lastFoeAttacker.clear
        @indicesTargetedRoundBeforeLast = @indicesTargetedLastRound.clone
        @indicesTargetedLastRound = @indicesTargetedThisRound.clone
        @indicesTargetedThisRound.clear
        @empoweredTimer += 1 if boss?

        @lastRoundMove 			= @lastMoveUsed
        @lastRoundMoveType	    = @lastMoveUsedType
        @lastRoundMoveCategory	= @lastMoveUsedCategory
    end
end
