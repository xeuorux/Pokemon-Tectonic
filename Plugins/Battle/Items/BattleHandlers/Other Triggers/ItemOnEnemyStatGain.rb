BattleHandlers::ItemOnEnemyStatGain.add(:MIRRORHERB,
  proc { |item, battler, user, battle, benefactor|
    next unless benefactor.hasRaisedStatStages?
    battle.pbDisplay(_INTL("{1} copies {2}'s raised stat stages with its {3}!", battler.pbThis,
        benefactor.pbThis(false), getItemName(battler.baseItem)))
    battler.pbConsumeItem(item, true, false)
    GameData::Stat.each_battle { |s|
      battler.stages[s.id] = 0 if benefactor.stages[s.id] > 0
    }
  }
)

BattleHandlers::ItemOnEnemyStatGain.add(:PARADOXHERB,
  proc { |item, battler, user, battle, benefactor|
    next unless benefactor.hasRaisedStatStages?
    battle.pbDisplay(_INTL("{1} resets {2}'s raised stat stages with its {3}!", battler.pbThis,
        benefactor.pbThis(false), getItemName(battler.baseItem)))
    battler.pbConsumeItem(item, true, false)
    GameData::Stat.each_battle { |s|
      benefactor.stages[s.id] = 0 if benefactor.stages[s.id] > 0
    }
  }
)
