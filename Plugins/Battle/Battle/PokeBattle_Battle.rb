class PokeBattle_Battle
	attr_accessor :ballsUsed       # Number of balls thrown without capture
	attr_accessor :messagesBlocked
	attr_accessor :commandPhasesThisRound
	attr_accessor :battleAI
	attr_accessor :bossBattle
	attr_accessor :numBossOnlyTurns
	attr_accessor :autoTesting
	attr_accessor :autoTestingIndex
	attr_accessor :honorAura
	attr_reader	  :curses
  
  def bossBattle?
	return bossBattle
  end
	
  #=============================================================================
  # Creating the battle class
  #=============================================================================
  def initialize(scene,p1,p2,player,opponent)
    if p1.length==0
      raise ArgumentError.new(_INTL("Party 1 has no Pokémon."))
    elsif p2.length==0
      raise ArgumentError.new(_INTL("Party 2 has no Pokémon."))
    end
    @scene             = scene
    @peer              = PokeBattle_BattlePeer.create
    @battleAI          = PokeBattle_AI.new(self)
    @field             = PokeBattle_ActiveField.new    # Whole field (gravity/rooms)
    @sides             = [PokeBattle_ActiveSide.new,   # Player's side
                          PokeBattle_ActiveSide.new]   # Foe's side
    @positions         = []                            # Battler positions
    @battlers          = []
    @sideSizes         = [1,1]   # Single battle, 1v1
    @backdrop          = ""
    @backdropBase      = nil
    @time              = 0
    @environment       = :None   # e.g. Tall grass, cave, still water
    @turnCount         = 0
    @decision          = 0
    @caughtPokemon     = []
    player   = [player] if !player.nil? && !player.is_a?(Array)
    opponent = [opponent] if !opponent.nil? && !opponent.is_a?(Array)
    @player            = player     # Array of Player/NPCTrainer objects, or nil
    @opponent          = opponent   # Array of NPCTrainer objects, or nil
    @items             = nil
    @endSpeeches       = []
    @endSpeechesWin    = []
    @party1            = p1
    @party2            = p2
    @party1order       = Array.new(@party1.length) { |i| i }
    @party2order       = Array.new(@party2.length) { |i| i }
    @party1starts      = [0]
    @party2starts      = [0]
    @internalBattle    = true
    @debug             = false
    @canRun            = true
    @canLose           = false
    @switchStyle       = true
    @showAnims         = true
    @controlPlayer     = false
    @expGain           = true
    @moneyGain         = true
    @rules             = {}
    @priority          = []
    @priorityTrickRoom = false
    @choices           = []
    @megaEvolution     = [
       [-1] * (@player ? @player.length : 1),
       [-1] * (@opponent ? @opponent.length : 1)
    ]
    @initialItems      = [
       Array.new(@party1.length) { |i| (@party1[i]) ? @party1[i].item_id : nil },
       Array.new(@party2.length) { |i| (@party2[i]) ? @party2[i].item_id : nil }
    ]
    @recycleItems      = [Array.new(@party1.length, nil),   Array.new(@party2.length, nil)]
    @belch             = [Array.new(@party1.length, false), Array.new(@party2.length, false)]
    @battleBond        = [Array.new(@party1.length, false), Array.new(@party2.length, false)]
    @usedInBattle      = [Array.new(@party1.length, false), Array.new(@party2.length, false)]
    @successStates     = []
    @lastMoveUsed      = nil
    @lastMoveUser      = -1
    @switching         = false
    @futureSight       = false
    @endOfRound        = false
    @moldBreaker       = false
    @runCommand        = 0
    @nextPickupUse     = 0
	@ballsUsed		   = 0
	@messagesBlocked   = false
	@bossBattle		   = false
	@numBossOnlyTurns  = 0
	@autoTesting	   = false
	@autoTestingIndex  = 1
	@commandPhasesThisRound = 0
	@honorAura		   = false
	@curses			   = []
    if GameData::Move.exists?(:STRUGGLE)
      @struggle = PokeBattle_Move.from_pokemon_move(self, Pokemon::Move.new(:STRUGGLE))
    else
      @struggle = PokeBattle_Struggle.new(self, nil)
    end
  end
  
  #=============================================================================
  # Messages and animations
  #=============================================================================
  def pbDisplay(msg,&block)
    @scene.pbDisplayMessage(msg,&block) if !messagesBlocked
  end

  def pbDisplayBrief(msg)
    @scene.pbDisplayMessage(msg,true) if !messagesBlocked
  end

  def pbDisplayPaused(msg,&block)
    @scene.pbDisplayPausedMessage(msg,&block) if !messagesBlocked
  end

  def pbDisplayConfirm(msg)
    return @scene.pbDisplayConfirmMessage(msg) if !messagesBlocked
  end
  
  def pbDisplayConfirmSerious(msg)
    return @scene.pbDisplayConfirmMessageSerious(msg) if !messagesBlocked
  end

  # Used for causing weather by a move or by an ability.
 def pbStartWeather(user,newWeather,fixedDuration=false,showAnim=true)
    return if @field.weather==newWeather
    @field.weather = newWeather
    duration = (fixedDuration) ? 5 : -1
    if duration>0 && user && user.itemActive?
      duration = BattleHandlers.triggerWeatherExtenderItem(user.item,
         @field.weather,duration,user,self)
    end
    @field.weatherDuration = duration
    weather_data = GameData::BattleWeather.try_get(@field.weather)
    pbCommonAnimation(weather_data.animation) if showAnim && weather_data
	##@scene.pbAreaUI(newWeather)
    pbHideAbilitySplash(user) if user
    case @field.weather
    when :Sun         then pbDisplay(_INTL("The sunlight turned harsh!"))
    when :Rain        then pbDisplay(_INTL("It started to rain!"))
    when :Sandstorm   then pbDisplay(_INTL("A sandstorm brewed!"))
    when :Hail        then pbDisplay(_INTL("It started to hail!"))
    when :HarshSun    then pbDisplay(_INTL("The sunlight turned extremely harsh!"))
    when :HeavyRain   then pbDisplay(_INTL("A heavy rain began to fall!"))
    when :StrongWinds then pbDisplay(_INTL("Mysterious strong winds are protecting Flying-type Pokémon!"))
    when :ShadowSky   then pbDisplay(_INTL("A shadow sky appeared!"))
    end
    # Check for end of primordial weather, and weather-triggered form changes
    eachBattler { |b| b.pbCheckFormOnWeatherChange }
    pbEndPrimordialWeather
  end

  def pbStartTerrain(user,newTerrain,fixedDuration=true)
    return if @field.terrain==newTerrain
	old_terrain = @field.terrain
    @field.terrain = newTerrain
    duration = (fixedDuration) ? 5 : -1
    if duration>0 && user && user.itemActive?
      duration = BattleHandlers.triggerTerrainExtenderItem(user.item,newTerrain,duration,user,self)
    end
    @field.terrainDuration = duration
    terrain_data = GameData::BattleTerrain.try_get(@field.terrain)
    pbCommonAnimation(terrain_data.animation) if terrain_data
    case @field.terrain
    when :Electric
      pbDisplay(_INTL("An electric current runs across the battlefield!"))
    when :Grassy
      pbDisplay(_INTL("Grass grew to cover the battlefield!"))
    when :Misty
      pbDisplay(_INTL("Mist swirled about the battlefield!"))
    when :Psychic
      pbDisplay(_INTL("The battlefield got weird!"))
    end
	pbHideAbilitySplash(user) if user
    # Check for terrain seeds that boost stats in a terrain
    eachBattler { |b| b.pbItemTerrainStatBoostCheck }
	
	# Trigger dialogue for each opponent
	if @opponent
		@opponent.each_with_index do |trainer_speaking,idxTrainer|
			@scene.showTrainerDialogue(idxTrainer) { |policy,dialogue|
				PokeBattle_AI.triggerTerrainChangeDialogue(policy,old_terrain,newTerrain,trainer_speaking,dialogue)
			}
		end
	end
  end 
  
  def pbChangeField(user,fieldEffect,modifier)
	return
	@field.effects[PBEffects:fieldEffect] = modifier
  end
  
  
  
end


