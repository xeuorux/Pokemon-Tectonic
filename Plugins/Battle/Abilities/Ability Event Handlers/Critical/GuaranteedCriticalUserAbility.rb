BattleHandlers::GuaranteedCriticalUserAbility.add(:MERCILESS,
    proc { |ability,user,target,battle|
      next true if target.poisoned?
    }
)
  
BattleHandlers::GuaranteedCriticalUserAbility.add(:HARSH,
    proc { |ability,user,target,battle|
      next true if target.burned?
    }
)
  
BattleHandlers::GuaranteedCriticalUserAbility.add(:BITTER,
    proc { |ability,user,target,battle|
      next true if target.frostbitten?
    }
)
  
BattleHandlers::GuaranteedCriticalUserAbility.add(:WALLNINJA,
    proc { |ability,user,target,battle|
      next true if user.battle.roomActive?
    }
)
  
BattleHandlers::GuaranteedCriticalUserAbility.add(:AQUASNEAK,
    proc { |ability,user,target,battle|
      next true if user.turnCount <= 1
    }
)
  
BattleHandlers::GuaranteedCriticalUserAbility.add(:LURING,
    proc { |ability,user,target,battle|
      next true if target.dizzy?
    }
)