BattleHandlers::AbilityOnSwitchOut.add(:REGENERATOR,
  proc { |ability, battler, endOfBattle, _battle = nil|
      next if endOfBattle
      battler.pbRecoverHP(battler.totalhp / 3.0, false, false, false)
  }
)

BattleHandlers::AbilityOnSwitchOut.add(:NATURALCURE,
  proc { |ability, battler, _endOfBattle|
      battler.pbCureStatus(false)
  }
)

BattleHandlers::AbilityOnSwitchOut.add(:FLYBY,
  proc { |ability, battler, endOfBattle|
      next if endOfBattle
      battler.battle.forceUseMove(battler, :GUST, -1, ability: ability)
  }
)

BattleHandlers::AbilityOnSwitchOut.add(:REFUGE,
  proc { |ability, battler, endOfBattle|
      next if endOfBattle
      battler.position.applyEffect(:Refuge, battler.pokemonIndex)
  }
)

BattleHandlers::AbilityOnSwitchOut.add(:POORCONDUCT,
  proc { |ability, battler, endOfBattle|
      next if endOfBattle
      battler.battle.pbShowAbilitySplash(battler, ability)
      battler.battle.eachOtherSideBattler(battler.index) do |b|
          next unless b.near?(battler)
          b.pbLowerMultipleStatStages([:ATTACK,1,:SPECIAL_ATTACK,1],battler,showFailMsg: true)
      end
      battler.battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchOut.add(:INFINITESOURCE,
  proc { |ability, battler, endOfBattle|
      next if endOfBattle
      battler.position.applyEffect(:InfiniteSource, battler.pokemonIndex)
  }
)

BattleHandlers::AbilityOnSwitchOut.add(:MOTHBURGLAR,
  proc { |ability, battler, endOfBattle|
      next if endOfBattle
      battler.battle.forceUseMove(battler, :THIEF, -1, ability: ability)
  }
)