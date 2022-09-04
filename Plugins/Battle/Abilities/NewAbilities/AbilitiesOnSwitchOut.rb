BattleHandlers::AbilityOnSwitchOut.add(:FLYBY,
  proc { |ability,battler,endOfBattle|
    battler.battle.forceUseMove(battler,:GUST,-1,true,nil,nil,true)
  }
)