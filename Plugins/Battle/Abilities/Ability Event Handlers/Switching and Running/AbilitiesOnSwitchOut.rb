BattleHandlers::AbilityOnSwitchOut.add(:REGENERATOR,
  proc { |ability,battler,endOfBattle,battle=nil|
    next if endOfBattle
    PBDebug.log("[Ability triggered] #{battler.pbThis}'s #{battler.abilityName}")
    battler.pbRecoverHP(battler.totalhp/3.0,false,false,false)
  }
)

BattleHandlers::AbilityOnSwitchOut.add(:NATURALCURE,
  proc { |ability,battler,endOfBattle|
    PBDebug.log("[Ability triggered] #{battler.pbThis}'s #{battler.abilityName}")
    battler.pbCureStatus(false)
  }
)

BattleHandlers::AbilityOnSwitchOut.add(:FLYBY,
  proc { |ability,battler,endOfBattle|
    next if endOfBattle
    battler.battle.forceUseMove(battler,:GUST,-1,true,nil,nil,true)
  }
)

BattleHandlers::AbilityOnSwitchOut.add(:REFUGE,
  proc { |ability,battler,endOfBattle|
    next if endOfBattle
    PBDebug.log("[Ability triggered] #{battler.pbThis}'s #{battler.abilityName}")
    battler.battle.positions[battler.index].applyEffect(:Refuge,battler.pokemonIndex)
  }
)