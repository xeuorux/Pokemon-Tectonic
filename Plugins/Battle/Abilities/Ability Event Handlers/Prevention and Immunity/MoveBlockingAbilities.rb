BattleHandlers::MoveBlockingAbility.add(:KILLJOY,
    proc { |ability,bearer,user,targets,move,battle|
      next move.danceMove?
    }
  )
  
BattleHandlers::MoveBlockingAbility.copy(:DAZZLING,:ROYALMAJESTY)

BattleHandlers::MoveBlockingAbility.add(:BADINFLUENCE,
    proc { |ability,bearer,user,targets,move,battle|
        next move.healingMove?
    }
)