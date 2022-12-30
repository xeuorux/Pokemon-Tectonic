BattleHandlers::DamageCalcTargetItem.add(:BABIRIBERRY,
    proc { |_item, _user, target, _move, mults, _baseDmg, type|
        pbBattleTypeWeakingBerry(:STEEL, type, target, mults)
    }
)

BattleHandlers::DamageCalcTargetItem.add(:CHARTIBERRY,
  proc { |_item, _user, target, _move, mults, _baseDmg, type|
      pbBattleTypeWeakingBerry(:ROCK, type, target, mults)
  }
)

BattleHandlers::DamageCalcTargetItem.add(:CHILANBERRY,
  proc { |_item, _user, target, _move, mults, _baseDmg, type|
      pbBattleTypeWeakingBerry(:NORMAL, type, target, mults)
  }
)

BattleHandlers::DamageCalcTargetItem.add(:CHOPLEBERRY,
  proc { |_item, _user, target, _move, mults, _baseDmg, type|
      pbBattleTypeWeakingBerry(:FIGHTING, type, target, mults)
  }
)

BattleHandlers::DamageCalcTargetItem.add(:COBABERRY,
  proc { |_item, _user, target, _move, mults, _baseDmg, type|
      pbBattleTypeWeakingBerry(:FLYING, type, target, mults)
  }
)

BattleHandlers::DamageCalcTargetItem.add(:COLBURBERRY,
  proc { |_item, _user, target, _move, mults, _baseDmg, type|
      pbBattleTypeWeakingBerry(:DARK, type, target, mults)
  }
)

BattleHandlers::DamageCalcTargetItem.add(:DEEPSEASCALE,
  proc { |_item, _user, target, move, mults, _baseDmg, _type|
      mults[:defense_multiplier] *= 2 if target.isSpecies?(:CLAMPERL) && move.specialMove?
  }
)

BattleHandlers::DamageCalcTargetItem.add(:EVIOLITE,
  proc { |_item, _user, target, _move, mults, _baseDmg, _type|
      # NOTE: Eviolite cares about whether the Pokémon itself can evolve, which
      #       means it also cares about the Pokémon's form. Some forms cannot
      #       evolve even if the species generally can, and such forms are not
      #       affected by Eviolite.
      mults[:defense_multiplier] *= 1.5 if target.pokemon.species_data.get_evolutions(true).length > 0
  }
)

BattleHandlers::DamageCalcTargetItem.add(:HABANBERRY,
  proc { |_item, _user, target, _move, mults, _baseDmg, type|
      pbBattleTypeWeakingBerry(:DRAGON, type, target, mults)
  }
)

BattleHandlers::DamageCalcTargetItem.add(:KASIBBERRY,
  proc { |_item, _user, target, _move, mults, _baseDmg, type|
      pbBattleTypeWeakingBerry(:GHOST, type, target, mults)
  }
)

BattleHandlers::DamageCalcTargetItem.add(:KEBIABERRY,
  proc { |_item, _user, target, _move, mults, _baseDmg, type|
      pbBattleTypeWeakingBerry(:POISON, type, target, mults)
  }
)

BattleHandlers::DamageCalcTargetItem.add(:METALPOWDER,
  proc { |_item, _user, target, _move, mults, _baseDmg, _type|
      mults[:defense_multiplier] *= 1.5 if target.isSpecies?(:DITTO) && !target.transformed?
  }
)

BattleHandlers::DamageCalcTargetItem.add(:OCCABERRY,
  proc { |_item, _user, target, _move, mults, _baseDmg, type|
      pbBattleTypeWeakingBerry(:FIRE, type, target, mults)
  }
)

BattleHandlers::DamageCalcTargetItem.add(:PASSHOBERRY,
  proc { |_item, _user, target, _move, mults, _baseDmg, type|
      pbBattleTypeWeakingBerry(:WATER, type, target, mults)
  }
)

BattleHandlers::DamageCalcTargetItem.add(:PAYAPABERRY,
  proc { |_item, _user, target, _move, mults, _baseDmg, type|
      pbBattleTypeWeakingBerry(:PSYCHIC, type, target, mults)
  }
)

BattleHandlers::DamageCalcTargetItem.add(:RINDOBERRY,
  proc { |_item, _user, target, _move, mults, _baseDmg, type|
      pbBattleTypeWeakingBerry(:GRASS, type, target, mults)
  }
)

BattleHandlers::DamageCalcTargetItem.add(:ROSELIBERRY,
  proc { |_item, _user, target, _move, mults, _baseDmg, type|
      pbBattleTypeWeakingBerry(:FAIRY, type, target, mults)
  }
)

BattleHandlers::DamageCalcTargetItem.add(:SHUCABERRY,
  proc { |_item, _user, target, _move, mults, _baseDmg, type|
      pbBattleTypeWeakingBerry(:GROUND, type, target, mults)
  }
)

BattleHandlers::DamageCalcTargetItem.add(:SOULDEW,
  proc { |_item, user, target, move, mults, _baseDmg, _type|
      next if Settings::SOUL_DEW_POWERS_UP_TYPES
      next if !target.isSpecies?(:LATIAS) && !target.isSpecies?(:LATIOS)
      mults[:defense_multiplier] *= 1.5 if move.specialMove? && !user.battle.rules["souldewclause"]
  }
)

BattleHandlers::DamageCalcTargetItem.add(:TANGABERRY,
  proc { |_item, _user, target, _move, mults, _baseDmg, type|
      pbBattleTypeWeakingBerry(:BUG, type, target, mults)
  }
)

BattleHandlers::DamageCalcTargetItem.add(:WACANBERRY,
  proc { |_item, _user, target, _move, mults, _baseDmg, type|
      pbBattleTypeWeakingBerry(:ELECTRIC, type, target, mults)
  }
)

BattleHandlers::DamageCalcTargetItem.add(:YACHEBERRY,
  proc { |_item, _user, target, _move, mults, _baseDmg, type|
      pbBattleTypeWeakingBerry(:ICE, type, target, mults)
  }
)
