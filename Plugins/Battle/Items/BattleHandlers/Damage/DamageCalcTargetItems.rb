  BattleHandlers::DamageCalcTargetItem.add(:BABIRIBERRY,
    proc { |item,user,target,move,mults,baseDmg,type|
      pbBattleTypeWeakingBerry(:STEEL,type,target,mults)
    }
  )
  
  BattleHandlers::DamageCalcTargetItem.add(:CHARTIBERRY,
    proc { |item,user,target,move,mults,baseDmg,type|
      pbBattleTypeWeakingBerry(:ROCK,type,target,mults)
    }
  )
  
  BattleHandlers::DamageCalcTargetItem.add(:CHILANBERRY,
    proc { |item,user,target,move,mults,baseDmg,type|
      pbBattleTypeWeakingBerry(:NORMAL,type,target,mults)
    }
  )
  
  BattleHandlers::DamageCalcTargetItem.add(:CHOPLEBERRY,
    proc { |item,user,target,move,mults,baseDmg,type|
      pbBattleTypeWeakingBerry(:FIGHTING,type,target,mults)
    }
  )
  
  BattleHandlers::DamageCalcTargetItem.add(:COBABERRY,
    proc { |item,user,target,move,mults,baseDmg,type|
      pbBattleTypeWeakingBerry(:FLYING,type,target,mults)
    }
  )
  
  BattleHandlers::DamageCalcTargetItem.add(:COLBURBERRY,
    proc { |item,user,target,move,mults,baseDmg,type|
      pbBattleTypeWeakingBerry(:DARK,type,target,mults)
    }
  )
  
  BattleHandlers::DamageCalcTargetItem.add(:DEEPSEASCALE,
    proc { |item,user,target,move,mults,baseDmg,type|
      if target.isSpecies?(:CLAMPERL) && move.specialMove?
        mults[:defense_multiplier] *= 2
      end
    }
  )
  
  BattleHandlers::DamageCalcTargetItem.add(:EVIOLITE,
    proc { |item,user,target,move,mults,baseDmg,type|
      # NOTE: Eviolite cares about whether the Pokémon itself can evolve, which
      #       means it also cares about the Pokémon's form. Some forms cannot
      #       evolve even if the species generally can, and such forms are not
      #       affected by Eviolite.
      if target.pokemon.species_data.get_evolutions(true).length > 0
        mults[:defense_multiplier] *= 1.5
      end
    }
  )
  
  BattleHandlers::DamageCalcTargetItem.add(:HABANBERRY,
    proc { |item,user,target,move,mults,baseDmg,type|
      pbBattleTypeWeakingBerry(:DRAGON,type,target,mults)
    }
  )
  
  BattleHandlers::DamageCalcTargetItem.add(:KASIBBERRY,
    proc { |item,user,target,move,mults,baseDmg,type|
      pbBattleTypeWeakingBerry(:GHOST,type,target,mults)
    }
  )
  
  BattleHandlers::DamageCalcTargetItem.add(:KEBIABERRY,
    proc { |item,user,target,move,mults,baseDmg,type|
      pbBattleTypeWeakingBerry(:POISON,type,target,mults)
    }
  )
  
  BattleHandlers::DamageCalcTargetItem.add(:METALPOWDER,
    proc { |item,user,target,move,mults,baseDmg,type|
      if target.isSpecies?(:DITTO) && !target.transformed?
        mults[:defense_multiplier] *= 1.5
      end
    }
  )
  
  BattleHandlers::DamageCalcTargetItem.add(:OCCABERRY,
    proc { |item,user,target,move,mults,baseDmg,type|
      pbBattleTypeWeakingBerry(:FIRE,type,target,mults)
    }
  )
  
  BattleHandlers::DamageCalcTargetItem.add(:PASSHOBERRY,
    proc { |item,user,target,move,mults,baseDmg,type|
      pbBattleTypeWeakingBerry(:WATER,type,target,mults)
    }
  )
  
  BattleHandlers::DamageCalcTargetItem.add(:PAYAPABERRY,
    proc { |item,user,target,move,mults,baseDmg,type|
      pbBattleTypeWeakingBerry(:PSYCHIC,type,target,mults)
    }
  )
  
  BattleHandlers::DamageCalcTargetItem.add(:RINDOBERRY,
    proc { |item,user,target,move,mults,baseDmg,type|
      pbBattleTypeWeakingBerry(:GRASS,type,target,mults)
    }
  )
  
  BattleHandlers::DamageCalcTargetItem.add(:ROSELIBERRY,
    proc { |item,user,target,move,mults,baseDmg,type|
      pbBattleTypeWeakingBerry(:FAIRY,type,target,mults)
    }
  )
  
  BattleHandlers::DamageCalcTargetItem.add(:SHUCABERRY,
    proc { |item,user,target,move,mults,baseDmg,type|
      pbBattleTypeWeakingBerry(:GROUND,type,target,mults)
    }
  )
  
  BattleHandlers::DamageCalcTargetItem.add(:SOULDEW,
    proc { |item,user,target,move,mults,baseDmg,type|
      next if Settings::SOUL_DEW_POWERS_UP_TYPES
      next if !target.isSpecies?(:LATIAS) && !target.isSpecies?(:LATIOS)
      if move.specialMove? && !user.battle.rules["souldewclause"]
        mults[:defense_multiplier] *= 1.5
      end
    }
  )
  
  BattleHandlers::DamageCalcTargetItem.add(:TANGABERRY,
    proc { |item,user,target,move,mults,baseDmg,type|
      pbBattleTypeWeakingBerry(:BUG,type,target,mults)
    }
  )
  
  BattleHandlers::DamageCalcTargetItem.add(:WACANBERRY,
    proc { |item,user,target,move,mults,baseDmg,type|
      pbBattleTypeWeakingBerry(:ELECTRIC,type,target,mults)
    }
  )
  
  BattleHandlers::DamageCalcTargetItem.add(:YACHEBERRY,
    proc { |item,user,target,move,mults,baseDmg,type|
      pbBattleTypeWeakingBerry(:ICE,type,target,mults)
    }
  )