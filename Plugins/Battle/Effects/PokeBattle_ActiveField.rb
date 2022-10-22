class PokeBattle_ActiveField
	include EffectHolder

	attr_accessor :effects, :defaultWeather, :weather, :weatherDuration, :defaultTerrain, :terrain, :terrainDuration

	def initialize(battle)
		@effects = {}
		GameData::BattleEffect.each_field_effect do |effectData|
			@effects[effectData.id] = effectData.default
		end
		@defaultWeather  = :None
		@weather         = :None
		@weatherDuration = 0
		@defaultTerrain  = :None
		@terrain         = :None
		@terrainDuration = 0
		@battle = battle

		@remain_proc = proc do |effectData|
			effectData.remain_both_sides(@battle)
		end
		@expire_proc = proc do |effectData|
			effectData.expire_both_sides(@battle)
		end
	end
end
