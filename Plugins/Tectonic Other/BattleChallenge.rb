=begin class BattleChallenge
  attr_reader :currentChallenge

  BattleTowerID   = 0
  BattlePalaceID  = 1
  BattleArenaID   = 2
  BattleFactoryID = 3
  BattleAvatarID = 4

  def initialize
    @bc = BattleChallengeData.new
    @currentChallenge = -1
    @types = {}
  end

  def set(id, numrounds, rules)
    @id = id
    @numRounds = numrounds
    @rules = rules
    register(id, id[/double/], 3,
       id[/^factory/] ? BattleFactoryID : BattleTowerID,
       id[/open$/] ? 1 : 0)
    pbWriteCup(id, rules)
  end

  def register(id, doublebattle, numPokemon, battletype, mode = 1)
    ensureType(id)
    if battletype == BattleFactoryID
      @bc.setExtraData(BattleFactoryData.new(@bc))
      numPokemon = 3
      battletype = BattleTowerID
    end
    @rules = modeToRules(doublebattle, numPokemon, battletype, mode) if !@rules
  end
  
  
  
def modeToRules(doublebattle, numPokemon, battletype, mode)
    rules = PokemonChallengeRules.new
    # Set the battle type
    case battletype
    when BattlePalaceID
      rules.setBattleType(BattlePalace.new)
    when BattleArenaID
      rules.setBattleType(BattleArena.new)
      doublebattle = false
    else   # Factory works the same as Tower
      rules.setBattleType(BattleTower.new)
    end
    # Set standard rules and maximum level
    case mode
    when 1      # Open Level
      rules.setRuleset(StandardRules.new(numPokemon, GameData::GrowthRate.max_level))
      rules.setLevelAdjustment(OpenLevelAdjustment.new(30))
    when 2   # Battle Tent
      rules.setRuleset(StandardRules.new(numPokemon, GameData::GrowthRate.max_level))
      rules.setLevelAdjustment(OpenLevelAdjustment.new(60))
	when 4 # Avatar Tower
		rules.setRuleset(StandardRules.new(numPokemon, GameData::GrowthRate.max_level))
		rules.setLevelAdjustment(OpenLevelAdjustment.new(70))
    else
      rules.setRuleset(StandardRules.new(numPokemon, 50))
      rules.setLevelAdjustment(OpenLevelAdjustment.new(50))
    end
    # Set whether battles are single or double
    if doublebattle
      rules.addBattleRule(DoubleBattle.new)
    else
      rules.addBattleRule(SingleBattle.new)
    end
    return rules
  end
end
=end
