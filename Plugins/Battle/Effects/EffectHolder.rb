# This assumes that each user of the module has an instance variable called @effects
# You may also define procs called @apply_proc, @expire_proc, and @remain_proc
module EffectHolder
    attr_reader :effects

    def eachEffectWithData(onlyActive=false)
        @effects.each do |effect, value|
			next if onlyActive && !effectActive?(effect)
            effectData = GameData::BattleEffect.get(effect)
			yield effect,value,effectData
		end
    end

    def applyEffect(effect, value = nil)
		effectData = GameData::BattleEffect.get(effect)
		if value.nil?
            if effectData.type == :Boolean
                value = true
            else
                raise _INTL("Value must be provided when applying effect #{effectData.real_name} (it's not a boolean)")
            end
		end
        @effects[effect] = value
        @apply_proc.call(effectData) if @apply_proc
	end

    def incrementEffect(effect,incrementAmount=1)
        effectData = GameData::BattleEffect.get(effect)
        validateInteger(effectData)
        oldValue = @effects[effect]
        newValue = oldValue + incrementAmount
        if newValue >= effectData.maximum
            raise _INTL("Effect incremented above maximum: #{effectData.real_name}")
        end
        @effects[effect] = newValue
        @increment_proc&.call(effectData,incrementAmount)
        return newValue
    end

    def effectAtMax?(effect)
        effectData = GameData::BattleEffect.get(effect)
        validateInteger(effectData)
        return false if effectData.maximum.nil?
        value = @effects[effect]
        raise _INTL("Effect above maximum: #{effectData.real_name}") if value >= effectData.maximum
    end

	def disableEffect(effect)
		effectData = GameData::BattleEffect.get(effect)
        return if !effectData.active_value?(@effects[effect])
		@effects[effect] = effectData.default
        @expire_proc.call(effectData) if @expire_proc
		effectData.eachConnectedEffect do |otherEffect, otherData|
			@effects[otherEffect] = otherData.default
            @expire_proc.call(otherData) if @expire_proc
		end
	end

	def effectActive?(effect)
		effectData = GameData::BattleEffect.get(effect)
		return effectData.active_value?(@effects[effect])
	end

    def effectCount(effect)
        effectData = GameData::BattleEffect.get(effect)
        validateInteger(effectData)
        return @effects[effect]
    end

    def validateInteger(effect)
        effectData = effect
        effectData = GameData::BattleEffect.get(effect) if effect.is_a?(Symbol)
        if effectData.type != :Integer
		    raise _INTL("Invalid operation for non-integer effect: #{effectData.real_name}")
        end
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