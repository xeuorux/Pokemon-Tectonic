class PokeBattle_ActiveSide
	include EffectHolder

	attr_accessor :effects
	attr_reader :index

	def initialize(battle,index)
		@battle = battle
		@index = index

		@effects = {}
		
		@location = :Side
		@apply_proc = proc do |effectData|
			effectData.apply_side(@battle, self)
		end
		@disable_proc = proc do |effectData|
			effectData.disable_side(@battle, self)
		end
		@eor_proc = proc do |effectData|
			effectData.eor_side(@battle, self)
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

		resetEffects()
	end

	def resetEffects()
		@effects.clear
		GameData::BattleEffect.each_side_effect do |effectData|
			@effects[effectData.id] = effectData.default
		end
	end

	def applyEffect(effect, value = nil)
		super(effect,value)
		echoln("[SIDE EFFECT] Effect #{getName(effect)} applied to side #{index}")
	end
end
