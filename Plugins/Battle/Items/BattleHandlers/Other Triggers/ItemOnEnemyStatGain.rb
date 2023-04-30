BattleHandlers::ItemOnEnemyStatGain.add(:MIRRORHERB,
  proc { |item, battler, stat, increment, user, battle, benefactor|
    battle.pbDisplay(_INTL("{1} copies {2}'s {3} with its {4}!", battler.pbThis,
        benefactor.pbThis(false), GameData::Stat.get(stat).real_name, getItemName(item)))
    battler.consumeItem(item)
    GameData::Stat.each_battle { |s|
      battler.steps[s.id] = benefactor.steps[s.id] if benefactor.steps[s.id] > 0
    }
    battler.steps[stat] = benefactor.steps[stat]
  }
)

BattleHandlers::ItemOnEnemyStatGain.add(:PARADOXHERB,
  proc { |item, battler, stat, increment, user, battle, benefactor|
    battle.pbDisplay(_INTL("{1} resets {2}'s {3} with its {4}!", battler.pbThis,
        benefactor.pbThis(false), GameData::Stat.get(stat).real_name, getItemName(item)))
    battler.consumeItem(item)
    benefactor.steps[stat] = 0
  }
)