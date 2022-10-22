class PokeBattle_ActiveSide
    attr_accessor :effects
    attr_reader :index

    def initialize(index)
      @effects = {}
      @index = index
      GameData::BattleEffect.each_side_effect do |effectData|
        @effects[effectData.id] = effectData.default
      end
    end

    def processEffectsEOR(battle)  
      remain_proc = Proc.new { |effectData|
          effectData.remain_side(battle,self)
      }
      expire_proc = Proc.new { |effectData|
          effectData.expire_side(battle,self)
      }
      effectsEndOfRound(@effects,remain_proc,expire_proc)
    end
end