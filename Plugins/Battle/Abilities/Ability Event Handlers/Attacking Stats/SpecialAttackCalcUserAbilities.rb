BattleHandlers::SpecialAttackCalcUserAbility.add(:FLAREBOOST,
    proc { |_ability, user, _battle, spAtkMult|
        spAtkMult *= 1.5 if user.burned?
        next spAtkMult
    }
)

BattleHandlers::SpecialAttackCalcUserAbility.add(:MINUS,
  proc { |_ability, user, _battle, spAtkMult|
      user.eachAlly do |b|
          next unless b.hasActiveAbility?(%i[MINUS PLUS])
          spAtkMult *= 1.5
          break
      end
      next spAtkMult
  }
)

BattleHandlers::SpecialAttackCalcUserAbility.copy(:MINUS, :PLUS)

BattleHandlers::SpecialAttackCalcUserAbility.add(:SOLARPOWER,
  proc { |_ability, _user, battle, spAtkMult|
      spAtkMult *= 1.5 if battle.sunny?
      next spAtkMult
  }
)

BattleHandlers::SpecialAttackCalcUserAbility.add(:AUDACITY,
  proc { |_ability, user, _battle, spAtkMult|
      spAtkMult *= 1.33 if user.pbHasAnyStatus?
      next spAtkMult
  }
)

BattleHandlers::SpecialAttackCalcUserAbility.add(:HEADACHE,
  proc { |_ability, _user, _battle, spAtkMult|
      spAtkMult *= 2.0
      next spAtkMult
  }
)

BattleHandlers::SpecialAttackCalcUserAbility.add(:ENERGYUP,
  proc { |_ability, _user, _battle, spAtkMult|
      spAtkMult *= 1.5
      next spAtkMult
  }
)

BattleHandlers::SpecialAttackCalcUserAbility.add(:ARCANEFINALE,
  proc { |_ability, user, _battle, spAtkMult|
      spAtkMult *= 2 if user.isLastAlive?
      next spAtkMult
  }
)

BattleHandlers::SpecialAttackCalcUserAbility.add(:TIDALFORCE,
  proc { |_ability, _user, battle, spAtkMult|
      spAtkMult *= 1.3 if battle.rainy?
      next spAtkMult
  }
)

BattleHandlers::SpecialAttackCalcUserAbility.add(:SOLARCELL,
  proc { |_ability, _user, battle, spAtkMult|
      spAtkMult *= 1.25 if battle.sunny?
      next spAtkMult
  }
)

BattleHandlers::SpecialAttackCalcUserAbility.add(:RADIATE,
  proc { |_ability, _user, _battle, spAtkMult|
      spAtkMult *= 1.3
      next spAtkMult
  }
)

BattleHandlers::SpecialAttackCalcUserAbility.copy(:RADIATE, :ARCANE)

BattleHandlers::SpecialAttackCalcUserAbility.add(:BALANCEOFPOWER,
  proc { |_ability, user, _battle, spAtkMult|
      spAtkMult *= 1.5 if user.lastRoundMoveCategory == 0
      next spAtkMult
  }
)
