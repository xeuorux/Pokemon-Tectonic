# This assumes that each user of the module has an instance variable called @effects
# You may also define procs called @apply_proc, @expire_proc, and @remain_proc
module EffectHolder
    attr_reader :effects

    def eachEffectWithData()
        @effects.each do |effect, value|
			effectData = GameData::BattleEffect.get(effect)
			yield effect,value,effectData
		end
    end

    def applyEffect(effect, value = nil)
		return if fainted?
		effectData = GameData::BattleEffect.get(effect)
		value = effectData.default if value.nil?
		@effects[effect] = value
		@apply_proc.call(effectData) if @apply_proc
	end

	def disableEffect(effect)
		return if fainted?
		effectData = GameData::BattleEffect.get(effect)
		@effects[effect] = effectData.default
		effectData.eachConnectedEffect do |otherEffect, otherData|
			@effects[otherEffect] = otherData.default
		end
	end

	def effectActive?(effect)
		return if fainted?
		effectData = GameData::BattleEffect.get(effect)
		return effectData.active_value?(@effects[effect])
	end

    def processEffectsEOR()
        changedEffects = {}
        @effects.each do |effect, value|
            effectData = GameData::BattleEffect.get(effect)
            # Tick down active effects that tick down
            if effectData.ticks_down && effectData.active_value?(value)
                newValue = value - effectData.tick_amount
                newValue = 0 if newValue < 0 && !effectData.ticks_past_zero
                if effectData.active_value?(newValue)
                    @remain_proc.call(effectData) if @remain_proc
                else
                    effectData.eachConnectedEffect do |otherEffect, otherData|
                        changedEffects[otherEffect] = otherData.default
                    end
                    @expire_proc.call(effectData) if @expire_proc
                end
                changedEffects[effect] = newValue
            end
            changedEffects[effect] = effectData.default if effectData.resets_eor && value != effectData.default
        end
        @effects.update(changedEffects)
    end
end