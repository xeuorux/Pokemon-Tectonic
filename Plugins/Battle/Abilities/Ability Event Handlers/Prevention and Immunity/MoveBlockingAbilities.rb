BattleHandlers::MoveBlockingAbility.add(:DAZZLING,
  proc { |ability,bearer,user,targets,move,battle|
    next false if battle.choices[user.index][4]<=0
    next false if !bearer.opposes?(user)
    ret = false
    targets.each do |b|
      next if !b.opposes?(user)
      ret = true
    end
    next ret
  }
)

BattleHandlers::MoveBlockingAbility.copy(:DAZZLING,:QUEENLYMAJESTY,:ROYALMAJESTY)

BattleHandlers::MoveBlockingAbility.add(:KILLJOY,
    proc { |ability,bearer,user,targets,move,battle|
      next move.danceMove?
    }
  )

BattleHandlers::MoveBlockingAbility.add(:BADINFLUENCE,
    proc { |ability,bearer,user,targets,move,battle|
        next move.healingMove?
    }
)