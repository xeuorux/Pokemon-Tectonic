class PokeBattle_Battle
  def pbCanMegaEvolve?(idxBattler)
    return false if $game_switches[Settings::NO_MEGA_EVOLUTION]
    battler = @battlers[idxBattler]
    return false if !battler.hasMega?
    return false if wildBattle? && opposes?(idxBattler) && !battler.boss
    return true if $DEBUG && Input.press?(Input::CTRL)
    return false if battler.effectActive?(:SkyDrop)
    return false if !pbHasMegaRing?(idxBattler) && !battler.boss
    side  = battler.idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    return @megaEvolution[side][owner] == -1
  end

  #=============================================================================
  # Mega Evolving a battler
  #=============================================================================
  def pbMegaEvolve(idxBattler)
    battler = @battlers[idxBattler]
    return if !battler || !battler.pokemon
    return if !battler.hasMega? || battler.mega?
    # Break Illusion
    if battler.hasActiveAbility?(:ILLUSION)
      BattleHandlers.triggerTargetAbilityOnHit(battler.ability,nil,battler,nil,self)
    end
    # Mega Evolve
    if !battler.boss
      trainerName = pbGetOwnerName(idxBattler)
      case battler.pokemon.megaMessage
      when 1   # Rayquaza
        pbDisplay(_INTL("{1}'s fervent wish has reached {2}!",trainerName,battler.pbThis))
      else
        pbDisplay(_INTL("{1}'s {2} is reacting to {3}'s {4}!",
        battler.pbThis,battler.itemName,trainerName,pbGetMegaRingName(idxBattler)))
      end
    else
      case battler.pokemon.megaMessage
      when 1   # Rayquaza
        pbDisplay(_INTL("{1}'s is inspired by the echo of an ancient wish!",battler.pbThis))
      else
        pbDisplay(_INTL("{1}'s reacts to an unknown power!",battler.pbThis))
      end
    end
    pbCommonAnimation("MegaEvolution",battler)
    battler.pokemon.makeMega
    battler.form = battler.pokemon.form
    battler.pbUpdate(true)
    @scene.pbChangePokemon(battler,battler.pokemon)
    @scene.pbRefreshOne(idxBattler)
    pbCommonAnimation("MegaEvolution2",battler)
    megaName = battler.pokemon.megaName
    if !megaName || megaName==""
      megaName = _INTL("Mega {1}", battler.pokemon.speciesName)
    end
    pbDisplay(_INTL("{1} has Mega Evolved into {2}!",battler.pbThis,megaName))
    side  = battler.idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    @megaEvolution[side][owner] = -2
    if battler.isSpecies?(:GENGAR) && battler.mega?
      battler.disableEffect(:Telekinesis)
    end
    pbCalculatePriority(false,[idxBattler]) if Settings::RECALCULATE_TURN_ORDER_AFTER_MEGA_EVOLUTION
    # Trigger ability
    battler.pbEffectsOnSwitchIn
  end
end