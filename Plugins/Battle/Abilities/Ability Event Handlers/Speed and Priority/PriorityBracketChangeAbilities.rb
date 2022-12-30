BattleHandlers::PriorityBracketChangeAbility.add(:STALL,
  proc { |_ability, _battler, subPri, _battle|
      next -1 if subPri == 0
  }
)

BattleHandlers::PriorityBracketChangeAbility.add(:QUICKDRAW,
    proc { |_ability, _battler, subPri, battle|
        next 1 if subPri < 1 && battle.pbRandom(10) < 3
    }
)
