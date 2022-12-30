BattleHandlers::SpecialAttackCalcUserItem.add(:DEEPSEATOOTH,
    proc { |_item, user, _battle, spAtkMult|
        spAtkMult *= 2 if user.isSpecies?(:CLAMPERL)
        next spAtkMult
    }
)

BattleHandlers::SpecialAttackCalcUserItem.add(:WISEGLASSES,
  proc { |_item, _user, _battle, spAtkMult|
      spAtkMult *= 1.1
      next spAtkMult
  }
)

BattleHandlers::SpecialAttackCalcUserItem.add(:CHOICESPECS,
  proc { |_item, _user, _battle, spAtkMult|
      spAtkMult *= 1.33
      next spAtkMult
  }
)
