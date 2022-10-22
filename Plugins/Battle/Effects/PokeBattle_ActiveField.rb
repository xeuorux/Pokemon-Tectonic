class PokeBattle_ActiveField
    attr_accessor :effects
    attr_accessor :defaultWeather
    attr_accessor :weather
    attr_accessor :weatherDuration
    attr_accessor :defaultTerrain
    attr_accessor :terrain
    attr_accessor :terrainDuration

    def initialize
      @effects = {}
      GameData::BattleEffect.each_both_sides_effect do |effectData|
        @effects[effectData.id] = effectData.default
      end
      @defaultWeather  = :None
      @weather         = :None
      @weatherDuration = 0
      @defaultTerrain  = :None
      @terrain         = :None
      @terrainDuration = 0
    end

    def processEffectsEOR(battle)  
      remain_proc = Proc.new { |effectData|
          effectData.remain_both_sides(battle,self)
      }
      expire_proc = Proc.new { |effectData|
          effectData.expire_both_sides(battle,self)
      }
      effectsEndOfRound(@effects,remain_proc,expire_proc)
    end
end