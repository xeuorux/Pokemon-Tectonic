BattleHandlers::AbilityOnHPDroppedBelowHalf.add(:EMERGENCYEXIT,
    proc { |ability,battler,battle|
      next false if battler.effects[PBEffects::SkyDrop]>=0 || battler.inTwoTurnAttack?("0CE")   # Sky Drop
      # In wild battles
      if battle.wildBattle?
        next false if battler.opposes? && battle.pbSideBattlerCount(battler.index)>1
        next false if !battle.pbCanRun?(battler.index)
        battle.pbShowAbilitySplash(battler,true)
        battle.pbHideAbilitySplash(battler)
        pbSEPlay("Battle flee")
        battle.pbDisplay(_INTL("{1} fled from battle!",battler.pbThis))
        battle.decision = 3   # Escaped
        next true
      end
      # In trainer battles
      next false if battle.pbAllFainted?(battler.idxOpposingSide)
      next false if !battle.pbCanSwitch?(battler.index)   # Battler can't switch out
      next false if !battle.pbCanChooseNonActive?(battler.index)   # No Pokémon can switch in
      battle.pbShowAbilitySplash(battler,true)
      battle.pbHideAbilitySplash(battler)
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s {2} activated!",battler.pbThis,battler.abilityName))
      end
      battle.pbDisplay(_INTL("{1} went back to {2}!",
         battler.pbThis,battle.pbGetOwnerName(battler.index)))
      if battle.endOfRound   # Just switch out
        battle.scene.pbRecall(battler.index) if !battler.fainted?
        battler.pbAbilitiesOnSwitchOut   # Inc. primordial weather check
        next true
      end
      newPkmn = battle.pbGetReplacementPokemonIndex(battler.index)   # Owner chooses
      next false if newPkmn<0   # Shouldn't ever do this
      battle.pbRecallAndReplace(battler.index,newPkmn)
      battle.pbClearChoice(battler.index)   # Replacement Pokémon does nothing this round
      next true
    }
  )
  
BattleHandlers::AbilityOnHPDroppedBelowHalf.copy(:EMERGENCYEXIT,:WIMPOUT)