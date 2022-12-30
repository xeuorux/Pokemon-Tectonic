BattleHandlers::AbilityOnSwitchOut.add(:REGENERATOR,
  proc { |_ability, battler, endOfBattle, _battle = nil|
      next if endOfBattle
      PBDebug.log("[Ability triggered] #{battler.pbThis}'s #{battler.abilityName}")
      battler.pbRecoverHP(battler.totalhp / 3.0, false, false, false)
  }
)

BattleHandlers::AbilityOnSwitchOut.add(:NATURALCURE,
  proc { |_ability, battler, _endOfBattle|
      PBDebug.log("[Ability triggered] #{battler.pbThis}'s #{battler.abilityName}")
      battler.pbCureStatus(false)
  }
)

BattleHandlers::AbilityOnSwitchOut.add(:FLYBY,
  proc { |_ability, battler, endOfBattle|
      next if endOfBattle
      battler.battle.forceUseMove(battler, :GUST, -1, true, nil, nil, true)
  }
)

BattleHandlers::AbilityOnSwitchOut.add(:REFUGE,
  proc { |_ability, battler, endOfBattle|
      next if endOfBattle
      PBDebug.log("[Ability triggered] #{battler.pbThis}'s #{battler.abilityName}")
      battler.position.applyEffect(:Refuge, battler.pokemonIndex)
  }
)
