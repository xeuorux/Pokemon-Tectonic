BattleHandlers::DamageCalcTargetItem.add(:BABIRIBERRY,
    proc { |item, _user, target, _move, mults, _baseDmg, type, aiCheck|
        pbBattleTypeWeakingBerry(item, :STEEL, type, target, mults, false, aiCheck)
    }
)

BattleHandlers::DamageCalcTargetItem.add(:CHARTIBERRY,
  proc { |item, _user, target, _move, mults, _baseDmg, type, aiCheck|
      pbBattleTypeWeakingBerry(item, :ROCK, type, target, mults, false, aiCheck)
  }
)

BattleHandlers::DamageCalcTargetItem.add(:CHILANBERRY,
  proc { |item, _user, target, _move, mults, _baseDmg, type, aiCheck|
      pbBattleTypeWeakingBerry(item, :NORMAL, type, target, mults, false, aiCheck)
  }
)

BattleHandlers::DamageCalcTargetItem.add(:CHOPLEBERRY,
  proc { |item, _user, target, _move, mults, _baseDmg, type, aiCheck|
      pbBattleTypeWeakingBerry(item, :FIGHTING, type, target, mults, false, aiCheck)
  }
)

BattleHandlers::DamageCalcTargetItem.add(:COBABERRY,
  proc { |item, _user, target, _move, mults, _baseDmg, type, aiCheck|
      pbBattleTypeWeakingBerry(item, :FLYING, type, target, mults, false, aiCheck)
  }
)

BattleHandlers::DamageCalcTargetItem.add(:COLBURBERRY,
  proc { |item, _user, target, _move, mults, _baseDmg, type, aiCheck|
      pbBattleTypeWeakingBerry(item, :DARK, type, target, mults, false, aiCheck)
  }
)

BattleHandlers::DamageCalcTargetItem.add(:HABANBERRY,
  proc { |item, _user, target, _move, mults, _baseDmg, type, aiCheck|
      pbBattleTypeWeakingBerry(item, :DRAGON, type, target, mults, false, aiCheck)
  }
)

BattleHandlers::DamageCalcTargetItem.add(:KASIBBERRY,
  proc { |item, _user, target, _move, mults, _baseDmg, type, aiCheck|
      pbBattleTypeWeakingBerry(item, :GHOST, type, target, mults, false, aiCheck)
  }
)

BattleHandlers::DamageCalcTargetItem.add(:KEBIABERRY,
  proc { |item, _user, target, _move, mults, _baseDmg, type, aiCheck|
      pbBattleTypeWeakingBerry(item, :POISON, type, target, mults, false, aiCheck)
  }
)

BattleHandlers::DamageCalcTargetItem.add(:OCCABERRY,
  proc { |item, _user, target, _move, mults, _baseDmg, type, aiCheck|
      pbBattleTypeWeakingBerry(item, :FIRE, type, target, mults, false, aiCheck)
  }
)

BattleHandlers::DamageCalcTargetItem.add(:PASSHOBERRY,
  proc { |item, _user, target, _move, mults, _baseDmg, type, aiCheck|
      pbBattleTypeWeakingBerry(item, :WATER, type, target, mults, false, aiCheck)
  }
)

BattleHandlers::DamageCalcTargetItem.add(:PAYAPABERRY,
  proc { |item, _user, target, _move, mults, _baseDmg, type, aiCheck|
      pbBattleTypeWeakingBerry(item, :PSYCHIC, type, target, mults, false, aiCheck)
  }
)

BattleHandlers::DamageCalcTargetItem.add(:RINDOBERRY,
  proc { |item, _user, target, _move, mults, _baseDmg, type, aiCheck|
      pbBattleTypeWeakingBerry(item, :GRASS, type, target, mults, false, aiCheck)
  }
)

BattleHandlers::DamageCalcTargetItem.add(:ROSELIBERRY,
  proc { |item, _user, target, _move, mults, _baseDmg, type, aiCheck|
      pbBattleTypeWeakingBerry(item, :FAIRY, type, target, mults, false, aiCheck)
  }
)

BattleHandlers::DamageCalcTargetItem.add(:SHUCABERRY,
  proc { |item, _user, target, _move, mults, _baseDmg, type, aiCheck|
      pbBattleTypeWeakingBerry(item, :GROUND, type, target, mults, false, aiCheck)
  }
)

BattleHandlers::DamageCalcTargetItem.add(:TANGABERRY,
  proc { |item, _user, target, _move, mults, _baseDmg, type, aiCheck|
      pbBattleTypeWeakingBerry(item, :BUG, type, target, mults, false, aiCheck)
  }
)

BattleHandlers::DamageCalcTargetItem.add(:WACANBERRY,
  proc { |item, _user, target, _move, mults, _baseDmg, type, aiCheck|
      pbBattleTypeWeakingBerry(item, :ELECTRIC, type, target, mults, false, aiCheck)
  }
)

BattleHandlers::DamageCalcTargetItem.add(:YACHEBERRY,
  proc { |item, _user, target, _move, mults, _baseDmg, type, aiCheck|
      pbBattleTypeWeakingBerry(item, :ICE, type, target, mults, false, aiCheck)
  }
)

BattleHandlers::DamageCalcTargetItem.add(:EVIOLITE,
  proc { |item, user, target, _move, mults, _baseDmg, _type, aiCheck|
      # NOTE: Eviolite cares about whether the Pokémon itself can evolve, which
      #       means it also cares about the Pokémon's form. Some forms cannot
      #       evolve even if the species generally can, and such forms are not
      #       affected by Eviolite.
      unless target.pokemon.species_data.get_evolutions(true).empty?
        mults[:defense_multiplier] *= 1.5
        user.aiLearnsItem(item) unless aiCheck
      end
  }
)