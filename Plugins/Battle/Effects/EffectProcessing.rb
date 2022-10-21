class PokeBattle_Battler
    def applyEffect(effect,value=nil)
        return if fainted?
        effectData = GameData::BattleEffect.get(effect)
        return if effectData.nil?
        value = effectData.default if value.nil?
        @effects[effect] = value
        effectData.apply_battler(@battle,self)
    end

    def disableEffect(effect)
        return if fainted?
        effectData = GameData::BattleEffect.get(effect)
        return if effectData.nil?
        @effects[effect] = effectData.default
        effectData.eachConnectedEffect do |otherEffect, otherData|
            @effects[otherEffect] = otherData.default
        end
    end

    def effectActive?(effect)
        return if fainted?
        effectData = GameData::BattleEffect.get(effect)
        return if effectData.nil?
        return effectData.active_value?(@effects[effect])
    end

    def processEffectsEOR
        return if fainted?
        @effects.each do |effect,value|
            next if !effectActive?(effect)
            effectData.eor_battler(@battle,self)
        end

        changedEffects = {}

        @effects.each do |effect, value|
            effectData = GameData::BattleEffect.get(effect)
            next if effectData.nil?
            # Tick down active effects that tick down
            if effectData.ticks_down && effectData.active_value?(value)
                newValue = value - effectData.tick_amount
                newValue = 0 if newValue < 0 && !effectData.ticks_past_zero
                if effectData.active_value?(newValue)
                    effectData.remain_battler(@battle,self)
                else
                    effectData.eachConnectedEffect do |otherEffect, otherData|
                        changedEffects[otherEffect] = otherData.default
                    end
                    effectData.expire_battler(@battle,self)
                end
                changedEffects[effect] = newValue
            end
            if effectData.resets_eor && value != effectData.default
                changedEffects[effect] = effectData.default
            end
        end

        @effects.update(changedEffects)
    end

    def modifyTrackersEOR()
        @lastHPLost                           = 0
        @lastHPLostFromFoe                    = 0
        @tookDamage                           = false
        @tookPhysicalHit                      = false
        @lastRoundMoveFailed                  = @lastMoveFailed
        @lastAttacker.clear
        @lastFoeAttacker.clear
        @indexesTargetedThisTurn.clear
        @primevalTimer += 1 if boss?
    end
end