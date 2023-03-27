BattleHandlers::SpecialAttackCalcUserAbility.add(:FLAREBOOST,
    proc { |ability, user, _battle, spAtkMult|
        spAtkMult *= 1.5 if user.burned?
        next spAtkMult
    }
)

BattleHandlers::SpecialAttackCalcUserAbility.add(:MINUS,
  proc { |ability, user, _battle, spAtkMult|
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
  proc { |ability, _user, battle, spAtkMult|
      spAtkMult *= 1.5 if battle.sunny?
      next spAtkMult
  }
)

BattleHandlers::SpecialAttackCalcUserAbility.add(:AUDACITY,
  proc { |ability, user, _battle, spAtkMult|
      spAtkMult *= 1.33 if user.pbHasAnyStatus?
      next spAtkMult
  }
)

BattleHandlers::SpecialAttackCalcUserAbility.add(:HEADACHE,
  proc { |ability, _user, _battle, spAtkMult|
      spAtkMult *= 2.0
      next spAtkMult
  }
)

BattleHandlers::SpecialAttackCalcUserAbility.add(:ENERGYUP,
  proc { |ability, _user, _battle, spAtkMult|
      spAtkMult *= 1.5
      next spAtkMult
  }
)

BattleHandlers::SpecialAttackCalcUserAbility.add(:ARCANEFINALE,
  proc { |ability, user, _battle, spAtkMult|
      spAtkMult *= 2 if user.isLastAlive?
      next spAtkMult
  }
)

BattleHandlers::SpecialAttackCalcUserAbility.add(:AQUAPROPULSION,
  proc { |ability, _user, battle, spAtkMult|
      spAtkMult *= 1.2 if battle.rainy?
      next spAtkMult
  }
)

BattleHandlers::SpecialAttackCalcUserAbility.add(:SOLARCELL,
  proc { |ability, _user, battle, spAtkMult|
      spAtkMult *= 1.25 if battle.sunny?
      next spAtkMult
  }
)

BattleHandlers::SpecialAttackCalcUserAbility.add(:RADIATE,
  proc { |ability, _user, _battle, spAtkMult|
      spAtkMult *= 1.3
      next spAtkMult
  }
)

BattleHandlers::SpecialAttackCalcUserAbility.copy(:RADIATE, :ARCANE)

BattleHandlers::SpecialAttackCalcUserAbility.add(:BALANCEOFPOWER,
  proc { |ability, user, _battle, spAtkMult|
      spAtkMult *= 1.5 if user.lastRoundMoveCategory == 0
      next spAtkMult
  }
)

BattleHandlers::SpecialAttackCalcUserAbility.add(:SHATTERING,
  proc { |ability, _user, battle, spAtkMult|
      spAtkMult *= 1.3 if battle.pbWeather == :Eclipse
      next spAtkMult
  }
)

BattleHandlers::SpecialAttackCalcUserAbility.add(:NIGHTLIGHT,
  proc { |ability, _user, battle, spAtkMult|
      spAtkMult *= 1.3 if battle.pbWeather == :Moonglow
      next spAtkMult
  }
)

BattleHandlers::SpecialAttackCalcUserAbility.add(:SANDPOWER,
  proc { |ability, _user, battle, spAtkMult|
      spAtkMult *= 1.3 if battle.pbWeather == :Sandstorm
      next spAtkMult
  }
)

BattleHandlers::SpecialAttackCalcUserAbility.add(:OVERWHELM,
  proc { |ability, _user, battle, spAtkMult|
      spAtkMult *= 1.3 if battle.rainy?
      next spAtkMult
  }
)

BattleHandlers::SpecialAttackCalcUserAbility.add(:WINTERWISDOM,
  proc { |ability, _user, battle, spAtkMult|
      spAtkMult *= 1.3 if battle.pbWeather == :Hail
      next spAtkMult
  }
)

BattleHandlers::SpecialAttackCalcUserAbility.add(:COLDCALCULATION,
  proc { |ability, _user, _battle, spAtkMult|
      spAtkMult *= 1.75
      next spAtkMult
  }
)

BattleHandlers::SpecialAttackCalcUserAbility.add(:EXTREMEENERGY,
  proc { |ability, _user, _battle, spAtkMult|
      spAtkMult *= 1.5
      next spAtkMult
  }
)
