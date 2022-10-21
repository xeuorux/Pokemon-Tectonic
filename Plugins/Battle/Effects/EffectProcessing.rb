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

        remain_proc = Proc.new { |effectData|
            effectData.remain_battler(@battle,self)
        }
        expire_proc = Proc.new { |effectData|
            effectData.expire_battler(@battle,self)
        }
        effectsEndOfRound(@effects,remain_proc,expire_proc)
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