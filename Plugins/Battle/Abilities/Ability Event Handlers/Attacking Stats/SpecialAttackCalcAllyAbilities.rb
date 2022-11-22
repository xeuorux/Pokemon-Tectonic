BattleHandlers::SpecialAttackCalcAllyAbility.add(:BATTERY,
    proc { |ability,user,battle,spAtkMult|
        spAtkMult *= 1.3
        next spAtkMult
    }
  )