class PokeBattle_Battle
  #=============================================================================
  # Start a battle
  #=============================================================================
  def pbStartBattle
    PBDebug.log("")
    PBDebug.log("******************************************")
    logMsg = "[Started battle] "
    if @sideSizes[0]==1 && @sideSizes[1]==1
      logMsg += "Single "
    elsif @sideSizes[0]==2 && @sideSizes[1]==2
      logMsg += "Double "
    elsif @sideSizes[0]==3 && @sideSizes[1]==3
      logMsg += "Triple "
    else
      logMsg += "#{@sideSizes[0]}v#{@sideSizes[1]} "
    end
    logMsg += "wild " if wildBattle?
    logMsg += "trainer " if trainerBattle?
    logMsg += "battle (#{@player.length} trainer(s) vs. "
    logMsg += "#{pbParty(1).length} wild Pokémon)" if wildBattle?
    logMsg += "#{@opponent.length} trainer(s))" if trainerBattle?
    PBDebug.log(logMsg)
	$game_switches[94] = false
    faintedBefore = $Trainer.able_pokemon_count # Record the number of fainted
    pbEnsureParticipants
    begin
      pbStartBattleCore
    rescue BattleAbortedException
      @decision = 0
      @scene.pbEndBattle(@decision)
    end
	$game_switches[94] = true if $Trainer.able_pokemon_count == faintedBefore # Record if the fight was perfected
    return @decision
  end
end

