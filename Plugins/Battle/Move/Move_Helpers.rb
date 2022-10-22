class PokeBattle_Move
  def applyRainDebuff?(user,checkingForAI=false)
      return RAIN_DEBUFF_ACTIVE && !immuneToRainDebuff?() && [:Rain, :HeavyRain].include?(@battle.field.weather) && user.debuffedByRain?(checkingForAI)
  end

  def applySunDebuff?(user,checkingForAI=false)
      return SUN_DEBUFF_ACTIVE && !immuneToSunDebuff?() && [:Sun, :HarshSun].include?(@battle.field.weather) && user.debuffedBySun?(checkingForAI)
  end

  def inherentImmunitiesPierced?(user,target)
    return (user.boss? || target.boss?) && damagingMove?
  end

  def canRemoveItem?(user,target,checkingForAI=false)
      return false if @battle.wildBattle? && user.opposes? && !user.boss   # Wild Pokémon can't knock off, but bosses can
      return false if user.fainted?
      if checkingForAI
          return false if target.effectActive?(:Substitute)
      else
          return false if target.damageState.unaffected || target.damageState.substitute
      end
      return false if !target.item || target.unlosableItem?(target.item)
      return false if target.shouldAbilityApply?(:STICKYHOLD,checkingForAI) && !@battle.moldBreaker
      return true
  end

  def canStealItem?(user,target,checkingForAI=false)
      return false if !canRemoveItem?(user,target)
      return false if user.item && @battle.trainerBattle?
      return false if user.unlosableItem?(target.item)
      return true
  end

  def healStatus(pokemonOrBattler)
    if pokemonOrBattler.is_a?(PokeBattle_Battler)
      pokemonOrBattler.pbCureStatus
    elsif pokemonOrBattler.status != :NONE
      oldStatus = pokemonOrBattler.status
      pokemonOrBattler.status      = :NONE
      pokemonOrBattler.statusCount = 0
      PokeBattle_Battler.showStatusCureMessage(oldStatus,pokemonOrBattler,@battle)
    end
  end

  def selectPartyMemberForEffect(idxBattler,selectableProc=nil)
      # Get player's party
      party    = @battle.pbParty(idxBattler)
      partyPos = @battle.pbPartyOrder(idxBattler)
      partyStart, _partyEnd = @battle.pbTeamIndexRangeFromBattlerIndex(idxBattler)
      modParty = @battle.pbPlayerDisplayParty(idxBattler)
      # Start party screen
      pkmnScene = PokemonParty_Scene.new
      pkmnScreen = PokemonPartyScreen.new(pkmnScene,modParty)
      #pkmnScreen.pbStartScene(_INTL("Use move on which Pokémon?"),@battle.pbNumPositions(0,0))
      idxParty = -1
      # Loop while in party screen
      loop do
        # Select a Pokémon
        idxParty = pkmnScreen.pbChooseAblePokemon(selectableProc)
        next if idxParty < 0
        idxPartyRet = -1
        partyPos.each_with_index do |pos,i|
          next if pos!=idxParty+partyStart
          idxPartyRet = i
          break
        end
        next if idxPartyRet < 0
        pkmn = party[idxPartyRet]
        next if !pkmn || pkmn.egg?
        yield pkmn
        break
      end
      pkmnScene.pbEndScene
  end

  def removeProtections(target)	
    GameData::BattleEffect.each do |effectData|
      next if !effectData.protection_effect
      case effectData.location
      when :Battler
        target.disableEffect(effectData.id)
      when :Side
        target.pbOwnSide.disableEffect(effectData.id)
      end
    end
  end 
end