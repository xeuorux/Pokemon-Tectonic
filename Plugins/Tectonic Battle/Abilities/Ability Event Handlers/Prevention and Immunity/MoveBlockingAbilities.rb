BattleHandlers::MoveBlockingAbility.add(:DAZZLING,
  proc { |ability, bearer, user, targets, move, battle|
        priority = battle.choices[user.index][4] || move.priority || nil
        next false unless priority && priority > 0
        next false unless bearer.opposes?(user)
        ret = false
        targets.each do |b|
            next unless b.opposes?(user)
            ret = true
        end
        next ret
  }
)

BattleHandlers::MoveBlockingAbility.copy(:DAZZLING, :QUEENLYMAJESTY, :ROYALMAJESTY)

BattleHandlers::MoveBlockingAbility.add(:KILLJOY,
    proc { |ability, _bearer, _user, _targets, move, _battle|
        next move.danceMove?
    }
)

BattleHandlers::MoveBlockingAbility.add(:BADINFLUENCE,
    proc { |ability, _bearer, _user, _targets, move, _battle|
        next move.healingMove?
    }
)

BattleHandlers::MoveBlockingAbility.add(:DESICCATE,
    proc { |ability, _bearer, _user, _targets, move, battle|
        next [:GRASS,:WATER].include?(move.calcType) && battle.sandy?
    }
)

BattleHandlers::MoveBlockingAbility.add(:LUNARCLEANSING,
    proc { |ability, _bearer, _user, _targets, move, battle|
        next [:BUG,:POISON].include?(move.calcType) && battle.moonGlowing?
    }
)