module GameData
  class TrainerType
    attr_reader :policies

    DATA = {}
    DATA_FILENAME = "trainer_types.dat"

    def initialize(hash)
      @id          = hash[:id]
      @id_number   = hash[:id_number]   || -1
      @real_name   = hash[:name]        || "Unnamed"
      @base_money  = hash[:base_money]  || 30
      @battle_BGM  = hash[:battle_BGM]
      @victory_ME  = hash[:victory_ME]
      @victory_ME  = hash[:victory_ME]
      @intro_ME    = hash[:intro_ME]
      @gender      = hash[:gender]      || 2
      @skill_level = hash[:skill_level] || @base_money
      @skill_code  = hash[:skill_code]
      @policies	   = hash[:policies]	|| []
    end

    def wild?; return @gender == 3; end
  end
end
