class PokeBattle_Battle
	def pbRandom(x); return rand(x); end

  #=============================================================================
  # Information about the type and size of the battle
  #=============================================================================
  def wildBattle?;    return @opponent.nil?;  end
  def trainerBattle?; return !@opponent.nil?; end

  # Sets the number of battler slots on each side of the field independently.
  # For "1v2" names, the first number is for the player's side and the second
  # number is for the opposing side.
  def setBattleMode(mode)
    @sideSizes =
      case mode
      when "triple", "3v3" then [3, 3]
      when "3v2"           then [3, 2]
      when "3v1"           then [3, 1]
      when "2v3"           then [2, 3]
      when "double", "2v2" then [2, 2]
      when "2v1"           then [2, 1]
      when "1v3"           then [1, 3]
      when "1v2"           then [1, 2]
      else                      [1, 1]   # Single, 1v1 (default)
      end
  end

  def singleBattle?
    return pbSideSize(0)==1 && pbSideSize(1)==1
  end

  def pbSideSize(index)
    return @sideSizes[index%2]
  end

  def maxBattlerIndex
    return (pbSideSize(0)>pbSideSize(1)) ? (pbSideSize(0)-1)*2 : pbSideSize(1)*2-1
  end
  
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

  def curseActive?(curseID)
    return @curses.include?(curseID)
  end

  def pbCheckNeutralizingGas(battler=nil)
    # Battler = the battler to switch out. 
	  # Should be specified when called from pbAttackPhaseSwitch
	  # Should be nil when called from pbEndOfRoundPhase
    return if !@field.effectActive?(:NeutralizingGas)
    return if battler && (battler.ability != :NEUTRALIZINGGAS || battler.effects[:GastroAcid])
    gasActive = false
    eachBattler {|b|
      next if !b || b.fainted?
      next if battler && b.index == battler.index
      # if specified, the battler will switch out, so don't consider it.
      # neutralizing gas can be blocked with gastro acid, ending the effect.
      if b.hasActiveNeutralizingGas?
        gasActive = true
        break
      end
    }
    if !gasActive
      @field.disableEffect(:NeutralizingGas)
      pbPriority(true).each { |b| 
	      next if battler && b.index == battler.index
	      b.pbEffectsOnSwitchIn
	    }
    end
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
      oldOutrageTurns = forcedMoveUser.effects[:Outrage]
      forcedMoveUser.effects[:Outrage] += 1 if forcedMoveUser.effectActive?(:Outrage)
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
      forcedMoveUser.effects[:Outrage] = oldOutrageTurns
      forcedMoveUser.currentMove = oldCurrentMove
    end
    pbJudge()
    return if @decision>0
  end

  def getBattleMoveInstanceFromID(move_id)
    return PokeBattle_Move.from_pokemon_move(self, Pokemon::Move.new(move_id))
  end

  def allEffectHolders()
    yield @field
    @sides.each do |side|
      yield side
    end
    @positions.each_with_index do |position,index|
      yield position
    end
    eachBattler do |b|
      yield b
    end
  end
end