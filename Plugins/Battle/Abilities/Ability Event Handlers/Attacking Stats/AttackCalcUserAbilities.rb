BattleHandlers::AttackCalcUserAbility.add(:FLOWERGIFT,
    proc { |_ability, user, _battle, attackMult|
        attackMult *= 1.5 if user.battle.sunny?
        next attackMult
    }
)

BattleHandlers::AttackCalcUserAbility.add(:SLOWSTART,
    proc { |_ability, user, _battle, attackMult|
        attackMult /= 2 if user.effectActive?(:SlowStart)
        next attackMult
    }
)

BattleHandlers::AttackCalcUserAbility.add(:PRIMEVALSLOWSTART,
  proc { |_ability, _user, _battle, attackMult|
      attackMult /= 2
      next attackMult
  }
)

BattleHandlers::AttackCalcUserAbility.add(:GORILLATACTICS,
    proc { |_ability, _user, _battle, attackMult|
        attackMult *= 1.5
        next attackMult
    }
)

BattleHandlers::AttackCalcUserAbility.add(:GUTS,
  proc { |_ability, user, _battle, attackMult|
      attackMult *= 1.33 if user.pbHasAnyStatus?
      next attackMult
  }
)

BattleHandlers::AttackCalcUserAbility.add(:TOUGHCLAWS,
  proc { |_ability, _user, _battle, attackMult|
      attackMult *= 1.3
      next attackMult
  }
)

BattleHandlers::AttackCalcUserAbility.add(:TOXICBOOST,
  proc { |_ability, user, _battle, attackMult|
      attackMult *= 1.5 if user.poisoned?
      next attackMult
  }
)

BattleHandlers::AttackCalcUserAbility.add(:HUGEPOWER,
  proc { |_ability, _user, _battle, attackMult|
      attackMult *= 1.5
      next attackMult
  }
)

BattleHandlers::AttackCalcUserAbility.copy(:HUGEPOWER, :PUREPOWER)

BattleHandlers::AttackCalcUserAbility.add(:FLUSTERFLOCK,
  proc { |_ability, _user, _battle, attackMult|
      attackMult *= 2.0
      next attackMult
  }
)

BattleHandlers::AttackCalcUserAbility.add(:POWERUP,
  proc { |_ability, _user, _battle, attackMult|
      attackMult *= 1.5
      next attackMult
  }
)

BattleHandlers::AttackCalcUserAbility.add(:DEEPSTING,
  proc { |_ability, _user, _battle, attackMult|
      attackMult *= 1.5
      next attackMult
  }
)

BattleHandlers::AttackCalcUserAbility.add(:BIGTHORNS,
  proc { |_ability, _user, battle, attackMult|
      attackMult *= 1.3 if battle.field.terrain == :Grassy
      next attackMult
  }
)

BattleHandlers::AttackCalcUserAbility.add(:SUNCHASER,
  proc { |_ability, _user, battle, attackMult|
      attackMult *= 1.3 if battle.sunny?
      next attackMult
  }
)

BattleHandlers::AttackCalcUserAbility.add(:BLIZZBOXER,
  proc { |_ability, _user, battle, attackMult|
      attackMult *= 1.3 if battle.pbWeather == :Hail
      next attackMult
  }
)

BattleHandlers::AttackCalcUserAbility.add(:STRANGESTRENGTH,
  proc { |_ability, _user, battle, attackMult|
      attackMult *= 2.0 if battle.field.terrain == :Fairy
      next attackMult
  }
)

BattleHandlers::AttackCalcUserAbility.add(:HARSHHUNTER,
  proc { |_ability, _user, battle, attackMult|
      attackMult *= 1.3 if battle.pbWeather == :Sandstorm
      next attackMult
  }
)

BattleHandlers::AttackCalcUserAbility.add(:RAMMINGSPEED,
  proc { |_ability, user, _battle, attackMult|
      attackMult *= 1.3 if user.pbOwnSide.effectActive?(:Tailwind)
      next attackMult
  }
)

BattleHandlers::AttackCalcUserAbility.add(:ROBUST,
  proc { |_ability, _user, _battle, attackMult|
      attackMult *= 1.2
      next attackMult
  }
)

BattleHandlers::AttackCalcUserAbility.add(:BALANCEOFPOWER,
  proc { |_ability, user, _battle, attackMult|
      attackMult *= 1.5 if user.lastRoundMoveCategory == 1
      next attackMult
  }
)
