class PokeBattle_Battle
	attr_accessor :ballsUsed       # Number of balls thrown without capture
	attr_accessor :messagesBlocked
	attr_accessor :commandPhasesThisRound
	attr_accessor :battleAI
	attr_accessor :bossBattle
	attr_accessor :autoTesting
	attr_accessor :autoTestingIndex
	attr_accessor :honorAura
	attr_accessor :expStored
	attr_reader	  :curses
	attr_accessor :expCapped
  attr_accessor :turnsToSurvive
  
  def bossBattle?
	  return bossBattle
  end
  
  def roomActive?
    @field.effects.each do |effect,value|
      effectData = GameData::BattleEffect.get(effect)
      return true if effectData.is_room?
    end
    return false
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
    @field             = PokeBattle_ActiveField.new(self)    # Whole field (gravity/rooms)
    @sides             = [PokeBattle_ActiveSide.new(self,0),   # Player's side
                          PokeBattle_ActiveSide.new(self,1)]   # Foe's side
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
    @autoTesting	   = false
    @autoTestingIndex  = 1
    @commandPhasesThisRound = 0
    @honorAura		   = false
    @curses			   = []
    @expStored		   = 0
    @expCapped		   = false
    @turnsToSurvive  = -1
    if GameData::Move.exists?(:STRUGGLE)
      @struggle = PokeBattle_Move.from_pokemon_move(self, Pokemon::Move.new(:STRUGGLE))
    else
      @struggle = PokeBattle_Struggle.new(self, nil)
    end
  end

  def curseActive?(curseID)
    return @curses.include?(curseID)
  end

  def pbCheckAlliedAbility(abil,idxBattler=0,nearOnly=false)
    eachSameSideBattler(idxBattler) do |b|
      next if nearOnly && !b.near?(idxBattler)
      return b if b.hasActiveAbility?(abil)
    end
    return nil
  end

    # moveIDOrIndex is either the index of the move on the user's move list (Integer)
  # or it's the ID of the move to be used (Symbol)
  def forceUseMove(forcedMoveUser,moveIDOrIndex,target=-1,specialUsage=true,usageMessage=nil,moveUsageEffect=nil,showAbilitySplash=false)
    oldLastRoundMoved = forcedMoveUser.lastRoundMoved
    if specialUsage
      # NOTE: Petal Dance being used shouldn't lock the
      #       battler into using that move, and shouldn't contribute to its
      #       turn counter if it's already locked into Petal Dance.
      oldCurrentMove = forcedMoveUser.currentMove
      oldOutrage = forcedMoveUser.effects[PBEffects::Outrage]
      forcedMoveUser.effects[PBEffects::Outrage] += 1 if forcedMoveUser.effects[PBEffects::Outrage]>0
    end
    if showAbilitySplash
      pbShowAbilitySplash(forcedMoveUser,true)
    end
    pbDisplay(usageMessage) if !usageMessage.nil?
    if showAbilitySplash
      pbHideAbilitySplash(forcedMoveUser)
    end
    moveID = moveIDOrIndex.is_a?(Symbol) ? moveIDOrIndex : nil
    moveIndex = moveIDOrIndex.is_a?(Integer) ? moveIDOrIndex : -1
    PBDebug.logonerr{
      forcedMoveUser.effects[moveUsageEffect] = true if !moveUsageEffect.nil?
      forcedMoveUser.pbUseMoveSimple(moveID,target,moveIndex,specialUsage)
      forcedMoveUser.effects[moveUsageEffect] = false if !moveUsageEffect.nil?
    }
    forcedMoveUser.lastRoundMoved = oldLastRoundMoved
    if specialUsage
      forcedMoveUser.effects[PBEffects::Outrage] = oldOutrage
      forcedMoveUser.currentMove = oldCurrentMove
    end
    pbJudge()
    return if @decision>0
end

def getBattleMoveInstanceFromID(move_id)
  return PokeBattle_Move.from_pokemon_move(self, Pokemon::Move.new(move_id))
end
  
  #=============================================================================
  # Messages and animations
  #=============================================================================
  def pbDisplay(msg,&block)
    @scene.pbDisplayMessage(msg,&block) if !@messagesBlocked
  end

  def pbDisplayBrief(msg)
    @scene.pbDisplayMessage(msg,true) if !@messagesBlocked
  end

  def pbDisplayPaused(msg,&block)
    @scene.pbDisplayPausedMessage(msg,&block) if !@messagesBlocked
  end

  def pbDisplayConfirm(msg)
    return @scene.pbDisplayConfirmMessage(msg) if !@messagesBlocked
  end
  
  def pbDisplayConfirmSerious(msg)
    return @scene.pbDisplayConfirmMessageSerious(msg) if !@messagesBlocked
  end

  def pbShowAbilitySplash(battler,delay=false,logTrigger=true)
    return if @messagesBlocked
    PBDebug.log("[Ability triggered] #{battler.pbThis}'s #{battler.abilityName}") if logTrigger
    return if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
    @scene.pbShowAbilitySplash(battler)
    if delay
      frames = Graphics.frame_rate # Default 1 second
      frames /= 2 if $PokemonSystem.battlescene > 0
      frames.times { @scene.pbUpdate }   
    end
  end

  def pbAnimation(move,user,targets,hitNum=0)
    if @messagesBlocked
      echoln("Skipping animation during AI calculations.")
      return
    end
    @scene.pbAnimation(move,user,targets,hitNum) if @showAnims
  end

  def pbCommonAnimation(name,user=nil,targets=nil)
    if @messagesBlocked
      echoln("Skipping animation during AI calculations.")
      return
    end
    return if @messagesBlocked
    @scene.pbCommonAnimation(name,user,targets) if @showAnims
  end

  def pbHideAbilitySplash(battler)
    return if @messagesBlocked
    return if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
    @scene.pbHideAbilitySplash(battler)
  end

  def pbReplaceAbilitySplash(battler)
    return if @messagesBlocked
    return if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
    @scene.pbReplaceAbilitySplash(battler)
  end
end


