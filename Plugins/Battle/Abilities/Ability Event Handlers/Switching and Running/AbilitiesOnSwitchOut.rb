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

BattleHandlers::AbilityOnSwitchOut.add(:POORCONDUCT,
  proc { |_ability, battler, endOfBattle|
      next if endOfBattle
      battle.pbShowAbilitySplash(battler)
      battle.eachOtherSideBattler(battler.index) do |b|
          next unless b.near?(battler)
          b.pbLowerMultipleStatStages([:ATTACK,1,:SPECIAL_ATTACK,1],battler,showFailMsg: true)
      end
      battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchOut.add(:INFINITESOURCE,
  proc { |_ability, battler, endOfBattle|
      next if endOfBattle
      PBDebug.log("[Ability triggered] #{battler.pbThis}'s #{battler.abilityName}")
      battler.position.applyEffect(:InfiniteSource, battler.pokemonIndex)
  }
)