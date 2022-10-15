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
    battler.battle.positions[battler.index].effects[PBEffects::Refuge] = true
    battler.battle.positions[battler.index].effects[PBEffects::RefugeMaker] = battler.pokemonIndex
  }
)