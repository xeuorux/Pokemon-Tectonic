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

		@remain_proc = proc do |effectData|
			effectData.remain_position(@battle, @index)
		end
		@expire_proc = proc do |effectData|
			effectData.expire_position(@battle, @index)
		end
	end
end
