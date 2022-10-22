class PokeBattle_ActiveSide
	include EffectHolder

	attr_accessor :effects
	attr_reader :index

	def initialize(battle,index)
		@battle = battle
		@index = index
		@effects = {}
		GameData::BattleEffect.each_side_effect do |effectData|
			@effects[effectData.id] = effectData.default
		end

		@apply_proc = proc do |effectData|
			effectData.apply_side(@battle, self)
		end
		@remain_proc = proc do |effectData|
			effectData.remain_side(@battle, self)
		end
		@expire_proc = proc do |effectData|
			effectData.expire_side(@battle, self)
		end
		@increment_proc = proc do |effectData,increment|
			effectData.increment_side(@battle, self,increment)
		end
	end
end
