# This assumes that each user of the module has an instance variable called @effects
# and a reference to the battle called @battle
# You may also define procs called @apply_proc, @disable_proc, @expire_proc, @remain_proc, and @increment_proc
module EffectHolder
    def eachEffect(onlyActive=false)
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
        elsif !effectData.valid_value?(value)
            raise _INTL("Value #{value} provided to apply for effect #{effectData.real_name} is invalid")
        elsif value == effectData.default
            raise _INTL("Value #{value} provided to apply for effect #{effectData.real_name} is its default value")
		end
        if @effects[effect] == value
            echo(_INTL("[EFFECT] Effect #{effectData.real_name} applied at existing value #{@effects[effect]}"))
        else
            @effects[effect] = value
            @apply_proc.call(effectData,value) if @apply_proc
        end
	end

    def pointAt(effect,battler)
        validatePosition(effect)
        applyEffect(effect,battler.index)
    end

    def incrementEffect(effect,incrementAmount=1)
        effectData = GameData::BattleEffect.get(effect)
        validateInteger(effectData)
        oldValue = @effects[effect]
        newValue = oldValue + incrementAmount
        if newValue > effectData.maximum
            echo(_INTL("[EFFECT] Effect incremented while already at maximum: #{effectData.real_name}"))
            return oldValue
        else
            @effects[effect] = newValue
            @increment_proc&.call(effectData,incrementAmount)
            return newValue
        end
    end

    def getName(effect)
        return getData(effect).real_name
    end

    def effectAtMax?(effect)
        effectData = GameData::BattleEffect.get(effect)
        validateInteger(effectData)
        return false if effectData.maximum.nil?
        value = @effects[effect]
        raise _INTL("Effect above maximum: #{effectData.real_name}") if value >= effectData.maximum
    end

    # Returns true if the value did not expire, false if it did
    def tickDownAndProc(effect)
        if effectActive?(effect)
            if tickDown(effect)
                disableEffect(effect)
                return false
            else
                @remain_proc&.call(GameData::BattleEffect.get(effect))
                return true
            end
        end
    end

    # Returns true if the value is either already at the goal or is at the goal after ticking down
    # otherwise false
    def tickDown(effect,goal=nil)
        effectData = GameData::BattleEffect.get(effect)
        validateInteger(effectData)
        value = @effects[effect]
        goal = effectData.default if goal.nil?
        return true if value <= goal
        @effects[effect] -= 1
        @effects[effect] = goal if @effects[effect] < goal
        return value <= goal
    end

	def disableEffect(effect)
		effectData = GameData::BattleEffect.get(effect)
        return if !effectData.active_value?(@effects[effect])
		@effects[effect] = effectData.default
        @expire_proc.call(effectData) if @expire_proc
		effectData.each_sub_effect do |otherEffect, otherData|
			@effects[otherEffect] = otherData.default
            @expire_proc.call(otherData) if @expire_proc
		end
	end

	def effectActive?(effect)
		effectData = GameData::BattleEffect.get(effect)

        mainEffectActive = effectData.active_value?(@effects[effect])

        effectData.each_sub_effect do |sub_effect|
            sub_active = effectActive?(sub_effect)
            if sub_active != mainEffectActive
                raise _INTL("Sub-Effect #{getData(sub_effect).real_name} of effect #{@real_name} has mismatched activity status")
            end
        end

		return mainEffectActive
	end

    def countEffect(effect)
        effectData = GameData::BattleEffect.get(effect)
        validateInteger(effectData)
        return @effects[effect]
    end

    def pointsAt?(effect,battler)
        validatePosition(effect)
        return false if !effectActive?(effect)
        return @effects[effect] == battler.index
    end

    def eachEffectPointsAt(onlyActive=false.battler)
        eachEffect(true) do |effect,value,data|
            yield effect,value,data if pointsAt?(effect,battler)
        end
    end

    def getBattler(effect)
        validatePosition(effect)
        return nil if effectActive?(effect)
        return @battle.battlers[@effects[effect]]
    end

    def processEffectsEOR()
        changedEffects = {}
        eachEffect(true) do |effect, value, data|
            # Active end of round effects
            @eor_proc.call(data)
            # Tick down active effects that tick down
            tickDownAndProc(effect) if data.ticks_down
            # Disable effects that reset end of round
            disableEffect(effect) if data.resets_eor
        end
    end

    def getMoveData(effect)
        validateMove(effect)
        return GameData::Move.get(@effects[effect])
    end

    #################################################
    # Validate data types
    #################################################
    def getData(dataOrEffect)
        return dataOrEffect if dataOrEffect.is_a?(GameData::BattleEffect)
        return GameData::BattleEffect.get(dataOrEffect)
    end

    def validateInteger(effect)
        effectData = getData(effect)
        if effectData.type != :Integer
		    raise _INTL("Invalid operation for non-integer effect: #{effectData.real_name}")
        end
    end

    def validatePosition(effect)
        effectData = getData(effect)
        if effectData.type != :Position
		    raise _INTL("Invalid operation for non-position effect: #{effectData.real_name}")
        end
    end

    def validateMove(effect)
        effectData = getData(effect)
        if effectData.type != :Move
		    raise _INTL("Invalid operation for non-move effect: #{effectData.real_name}")
        end
    end
end