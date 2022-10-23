BattleHandlers::AbilityOnBattlerFainting.add(:SOULHEART,
    proc { |ability,battler,fainted,battle|
      battler.pbRaiseStatStageByAbility(:SPECIAL_ATTACK,1,battler)
    }
)

BattleHandlers::AbilityOnBattlerFainting.add(:ARCANEFINALE,
    proc { |ability,battler,fainted,battle|
      next if battler.opposes?(fainted)
      next if !battler.isLastAlive?
      battle.pbShowAbilitySplash(battler)
      battle.pbDisplay(_INTL("{1} is the team's finale!",battler.pbThis))
      battle.pbHideAbilitySplash(battler)
    }
)

BattleHandlers::AbilityOnBattlerFainting.add(:HEROICFINALE,
    proc { |ability,battler,fainted,battle|
        next if battler.opposes?(fainted)
        next if !battler.isLastAlive?
        battle.pbShowAbilitySplash(battler)
        battle.pbDisplay(_INTL("{1} is the team's finale!",battler.pbThis))
        battle.pbHideAbilitySplash(battler)
    }
)