BattleHandlers::ItemOnEnemyStatGain.add(:MIRRORHERB,
  proc { |item, battler, user, battle, benefactor|
    next unless benefactor.hasRaisedStatSteps?
    battle.pbDisplay(_INTL("{1} copies {2}'s raised stat steps with its {3}!", battler.pbThis,
        benefactor.pbThis(false), getItemName(item)))
    battler.consumeItem(item)
    GameData::Stat.each_battle { |s|
      battler.steps[s.id] = 0 if benefactor.steps[s.id] > 0
    }
  }
)

BattleHandlers::ItemOnEnemyStatGain.add(:PARADOXHERB,
  proc { |item, battler, user, battle, benefactor|
    next unless benefactor.hasRaisedStatSteps?
    battle.pbDisplay(_INTL("{1} resets {2}'s raised stat steps with its {3}!", battler.pbThis,
        benefactor.pbThis(false), getItemName(item)))
    battler.consumeItem(item)
    GameData::Stat.each_battle { |s|
      benefactor.steps[s.id] = 0 if benefactor.steps[s.id] > 0
    }
  }
)
