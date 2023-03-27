BattleHandlers::AbilityOnHPDroppedBelowHalf.add(:EMERGENCYEXIT,
    proc { |ability, battler, battle|
        next false if battler.effectActive?(:SkyDrop) || battler.inTwoTurnAttack?("0CE")   # Sky Drop
        # In wild battles
        if battle.wildBattle?
            next false if battler.opposes? && battle.pbSideBattlerCount(battler.index) > 1
            next false unless battle.pbCanRun?(battler.index)
            battle.pbShowAbilitySplash(battler, ability, true)
            battle.pbHideAbilitySplash(battler)
            pbSEPlay("Battle flee")
            battle.pbDisplay(_INTL("{1} fled from battle!", battler.pbThis))
            battle.decision = 3 # Escaped
            next true
        end
        # In trainer battles
        next false if battle.pbAllFainted?(battler.idxOpposingSide)
        next battle.triggeredSwitchOut(battler.index, ability: ability)
    }
)

BattleHandlers::AbilityOnHPDroppedBelowHalf.copy(:EMERGENCYEXIT, :WIMPOUT)

BattleHandlers::AbilityOnHPDroppedBelowHalf.add(:BERSERK,
  proc { |ability, battler, _battle|
      battler.pbRaiseMultipleStatStages([:ATTACK, 1, :SPECIAL_ATTACK, 1], battler, ability: ability)
      next false
  }
)

BattleHandlers::AbilityOnHPDroppedBelowHalf.add(:ADRENALINERUSH,
  proc { |ability, battler, _battle|
      battler.tryRaiseStat(:SPEED, battler, increment: 2, ability: ability)
      next false
  }
)

BattleHandlers::AbilityOnHPDroppedBelowHalf.add(:BOULDERNEST,
  proc { |ability, battler, battle|
      battle.pbShowAbilitySplash(battler, ability)
      if battler.pbOpposingSide.effectActive?(:StealthRock)
          battle.pbDisplay(_INTL("But there were already pointed stones floating around {1}!",
   battler.pbOpposingTeam(true)))
      else
          battler.pbOpposingSide.applyEffect(:StealthRock)
      end
      battle.pbHideAbilitySplash(battler)
      next false
  }
)

BattleHandlers::AbilityOnHPDroppedBelowHalf.add(:REAWAKENEDPOWER,
  proc { |ability, battler, _battle|
      battler.pbMaximizeStatStage(:SPECIAL_ATTACK, battler, self, ability: ability)
      next false
  }
)
