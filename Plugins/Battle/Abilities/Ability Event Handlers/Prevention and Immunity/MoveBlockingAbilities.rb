BattleHandlers::MoveBlockingAbility.add(:DAZZLING,
  proc { |_ability, bearer, user, targets, _move, battle|
      next false if battle.choices[user.index][4] <= 0
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
    proc { |_ability, _bearer, _user, _targets, move, _battle|
        next move.danceMove?
    }
)

BattleHandlers::MoveBlockingAbility.add(:BADINFLUENCE,
    proc { |_ability, _bearer, _user, _targets, move, _battle|
        next move.healingMove?
    }
)
