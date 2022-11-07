BattleHandlers::AbilityOnHPDroppedBelowHalf.add(:EMERGENCYEXIT,
    proc { |ability,battler,battle|
      next false if battler.effectActive?(:SkyDrop) || battler.inTwoTurnAttack?("0CE")   # Sky Drop
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
      next battle.triggeredSwitchOut(battler.index)
    }
  )
  
BattleHandlers::AbilityOnHPDroppedBelowHalf.copy(:EMERGENCYEXIT,:WIMPOUT)