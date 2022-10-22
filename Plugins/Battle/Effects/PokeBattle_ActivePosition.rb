class PokeBattle_ActivePosition
    attr_accessor :effects
  
    def initialize
      @effects = {}
      GameData::BattleEffect.each_position_effect do |effectData|
        @effects[effectData.id] = effectData.default
      end
    end

    def processEffectsEOR(battle,index)
      remain_proc = Proc.new { |effectData|
          effectData.remain_position(battle,index)
      }
      expire_proc = Proc.new { |effectData|
          effectData.expire_position(battle,index)
      }
      effectsEndOfRound(@effects,remain_proc,expire_proc)
    end
end