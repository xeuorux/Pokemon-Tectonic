class PokeBattle_ActivePosition
	include EffectHolder

	attr_accessor :effects

	def initialize(battle,index)
		@battle = battle
		@index = index

		@effects = {}
		GameData::BattleEffect.each_position_effect do |effectData|
			@effects[effectData.id] = effectData.default
		end

		@apply_proc = proc do |effectData|
			effectData.apply_position(@battle, @index)
		end
		@disable_proc = proc do |effectData|
			effectData.disable_position(@battle, @index)
		end
		@eor_proc = proc do |effectData|
			effectData.eor_position(@battle, @index)
		end
		@remain_proc = proc do |effectData|
			effectData.remain_position(@battle, @index)
		end
		@expire_proc = proc do |effectData|
			effectData.expire_position(@battle, @index)
		end
		@increment_proc = proc do |effectData,increment|
			effectData.increment_position(@battle, @index,increment)
		end
	end

	def applyEffect(effect, value = ni)
		super(effect,value)
		echoln("[POSITION EFFECT] Effect #{getName(effect)} applied to position #{@index}, which houses #{battle.battlers[@index].pbThis(true)}")
	end
end
