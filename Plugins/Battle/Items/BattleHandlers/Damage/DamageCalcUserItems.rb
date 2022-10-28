BattleHandlers::DamageCalcUserItem.add(:ADAMANTORB,
    proc { |item,user,target,move,mults,baseDmg,type|
      if user.isSpecies?(:DIALGA) && (type == :DRAGON || type == :STEEL)
        mults[:base_damage_multiplier] *= 1.2
      end
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:BLACKBELT,
    proc { |item,user,target,move,mults,baseDmg,type|
      mults[:base_damage_multiplier] *= 1.2 if type == :FIGHTING
    }
  )
  
  BattleHandlers::DamageCalcUserItem.copy(:BLACKBELT,:FISTPLATE)
  
  BattleHandlers::DamageCalcUserItem.add(:BLACKGLASSES,
    proc { |item,user,target,move,mults,baseDmg,type|
      mults[:base_damage_multiplier] *= 1.2 if type == :DARK
    }
  )
  
  BattleHandlers::DamageCalcUserItem.copy(:BLACKGLASSES,:DREADPLATE)
  
  BattleHandlers::DamageCalcUserItem.add(:BUGGEM,
    proc { |item,user,target,move,mults,baseDmg,type|
      pbBattleGem(user,:BUG,move,mults,type)
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:CHARCOAL,
    proc { |item,user,target,move,mults,baseDmg,type|
      mults[:base_damage_multiplier] *= 1.2 if type == :FIRE
    }
  )
  
  BattleHandlers::DamageCalcUserItem.copy(:CHARCOAL,:FLAMEPLATE)
  
  
  BattleHandlers::DamageCalcUserItem.add(:DARKGEM,
    proc { |item,user,target,move,mults,baseDmg,type|
      pbBattleGem(user,:DARK,move,mults,type)
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:DEEPSEATOOTH,
    proc { |item,user,target,move,mults,baseDmg,type|
      if user.isSpecies?(:CLAMPERL) && move.specialMove?
        mults[:attack_multiplier] *= 2
      end
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:DRAGONFANG,
    proc { |item,user,target,move,mults,baseDmg,type|
      mults[:base_damage_multiplier] *= 1.2 if type == :DRAGON
    }
  )
  
  BattleHandlers::DamageCalcUserItem.copy(:DRAGONFANG,:DRACOPLATE)
  
  BattleHandlers::DamageCalcUserItem.add(:DRAGONGEM,
    proc { |item,user,target,move,mults,baseDmg,type|
      pbBattleGem(user,:DRAGON,move,mults,type)
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:ELECTRICGEM,
    proc { |item,user,target,move,mults,baseDmg,type|
      pbBattleGem(user,:ELECTRIC,move,mults,type)
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:EXPERTBELT,
    proc { |item,user,target,move,mults,baseDmg,type|
      if Effectiveness.super_effective?(target.damageState.typeMod)
        mults[:final_damage_multiplier] *= 1.2
      end
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:FAIRYGEM,
    proc { |item,user,target,move,mults,baseDmg,type|
      pbBattleGem(user,:FAIRY,move,mults,type)
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:FIGHTINGGEM,
    proc { |item,user,target,move,mults,baseDmg,type|
      pbBattleGem(user,:FIGHTING,move,mults,type)
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:FIREGEM,
    proc { |item,user,target,move,mults,baseDmg,type|
      pbBattleGem(user,:FIRE,move,mults,type)
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:FLYINGGEM,
    proc { |item,user,target,move,mults,baseDmg,type|
      pbBattleGem(user,:FLYING,move,mults,type)
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:GHOSTGEM,
    proc { |item,user,target,move,mults,baseDmg,type|
      pbBattleGem(user,:GHOST,move,mults,type)
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:GRASSGEM,
    proc { |item,user,target,move,mults,baseDmg,type|
      pbBattleGem(user,:GRASS,move,mults,type)
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:GRISEOUSORB,
    proc { |item,user,target,move,mults,baseDmg,type|
      if user.isSpecies?(:GIRATINA) && (type == :DRAGON || type == :GHOST)
        mults[:base_damage_multiplier] *= 1.2
      end
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:GROUNDGEM,
    proc { |item,user,target,move,mults,baseDmg,type|
      pbBattleGem(user,:GROUND,move,mults,type)
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:HARDSTONE,
    proc { |item,user,target,move,mults,baseDmg,type|
      mults[:base_damage_multiplier] *= 1.2 if type == :ROCK
    }
  )
  
  BattleHandlers::DamageCalcUserItem.copy(:HARDSTONE,:STONEPLATE,:ROCKINCENSE)
  
  BattleHandlers::DamageCalcUserItem.add(:ICEGEM,
    proc { |item,user,target,move,mults,baseDmg,type|
      pbBattleGem(user,:ICE,move,mults,type)
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:LIFEORB,
    proc { |item,user,target,move,mults,baseDmg,type|
      if !move.is_a?(PokeBattle_Confusion)
        mults[:final_damage_multiplier] *= 1.3
      end
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:LIGHTBALL,
    proc { |item,user,target,move,mults,baseDmg,type|
      if user.isSpecies?(:PIKACHU)
        mults[:attack_multiplier] *= 2
      end
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:LUSTROUSORB,
    proc { |item,user,target,move,mults,baseDmg,type|
      if user.isSpecies?(:PALKIA) && (type == :DRAGON || type == :WATER)
        mults[:base_damage_multiplier] *= 1.2
      end
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:MAGNET,
    proc { |item,user,target,move,mults,baseDmg,type|
      mults[:base_damage_multiplier] *= 1.2 if type == :ELECTRIC
    }
  )
  
  BattleHandlers::DamageCalcUserItem.copy(:MAGNET,:ZAPPLATE)
  
  BattleHandlers::DamageCalcUserItem.add(:METALCOAT,
    proc { |item,user,target,move,mults,baseDmg,type|
      mults[:base_damage_multiplier] *= 1.2 if type == :STEEL
    }
  )
  
  BattleHandlers::DamageCalcUserItem.copy(:METALCOAT,:IRONPLATE)
  
  BattleHandlers::DamageCalcUserItem.add(:METRONOME,
    proc { |item,user,target,move,mults,baseDmg,type|
      met = 1 + 0.2 * user.countEffect(:Metronome)
      mults[:final_damage_multiplier] *= met
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:MIRACLESEED,
    proc { |item,user,target,move,mults,baseDmg,type|
      mults[:base_damage_multiplier] *= 1.2 if type == :GRASS
    }
  )
  
  BattleHandlers::DamageCalcUserItem.copy(:MIRACLESEED,:MEADOWPLATE,:ROSEINCENSE)
  
  BattleHandlers::DamageCalcUserItem.add(:MUSCLEBAND,
    proc { |item,user,target,move,mults,baseDmg,type|
      mults[:base_damage_multiplier] *= 1.1 if move.physicalMove?
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:MYSTICWATER,
    proc { |item,user,target,move,mults,baseDmg,type|
      mults[:base_damage_multiplier] *= 1.2 if type == :WATER
    }
  )
  
  BattleHandlers::DamageCalcUserItem.copy(:MYSTICWATER,:SPLASHPLATE,:SEAINCENSE,:WAVEINCENSE)
  
  BattleHandlers::DamageCalcUserItem.add(:NEVERMELTICE,
    proc { |item,user,target,move,mults,baseDmg,type|
      mults[:base_damage_multiplier] *= 1.2 if type == :ICE
    }
  )
  
  BattleHandlers::DamageCalcUserItem.copy(:NEVERMELTICE,:ICICLEPLATE)
  
  BattleHandlers::DamageCalcUserItem.add(:NORMALGEM,
    proc { |item,user,target,move,mults,baseDmg,type|
      pbBattleGem(user,:NORMAL,move,mults,type)
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:PIXIEPLATE,
    proc { |item,user,target,move,mults,baseDmg,type|
      mults[:base_damage_multiplier] *= 1.2 if type == :FAIRY
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:POISONBARB,
    proc { |item,user,target,move,mults,baseDmg,type|
      mults[:base_damage_multiplier] *= 1.2 if type == :POISON
    }
  )
  
  BattleHandlers::DamageCalcUserItem.copy(:POISONBARB,:TOXICPLATE)
  
  BattleHandlers::DamageCalcUserItem.add(:POISONGEM,
    proc { |item,user,target,move,mults,baseDmg,type|
      pbBattleGem(user,:POISON,move,mults,type)
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:PSYCHICGEM,
    proc { |item,user,target,move,mults,baseDmg,type|
      pbBattleGem(user,:PSYCHIC,move,mults,type)
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:ROCKGEM,
    proc { |item,user,target,move,mults,baseDmg,type|
      pbBattleGem(user,:ROCK,move,mults,type)
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:SHARPBEAK,
    proc { |item,user,target,move,mults,baseDmg,type|
      mults[:base_damage_multiplier] *= 1.2 if type == :FLYING
    }
  )
  
  BattleHandlers::DamageCalcUserItem.copy(:SHARPBEAK,:SKYPLATE)
  
  BattleHandlers::DamageCalcUserItem.add(:SILKSCARF,
    proc { |item,user,target,move,mults,baseDmg,type|
      mults[:base_damage_multiplier] *= 1.2 if type == :NORMAL
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:SILVERPOWDER,
    proc { |item,user,target,move,mults,baseDmg,type|
      mults[:base_damage_multiplier] *= 1.2 if type == :BUG
    }
  )
  
  BattleHandlers::DamageCalcUserItem.copy(:SILVERPOWDER,:INSECTPLATE)
  
  BattleHandlers::DamageCalcUserItem.add(:SOFTSAND,
    proc { |item,user,target,move,mults,baseDmg,type|
      mults[:base_damage_multiplier] *= 1.2 if type == :GROUND
    }
  )
  
  BattleHandlers::DamageCalcUserItem.copy(:SOFTSAND,:EARTHPLATE)
  
  BattleHandlers::DamageCalcUserItem.add(:SOULDEW,
    proc { |item,user,target,move,mults,baseDmg,type|
      next if !user.isSpecies?(:LATIAS) && !user.isSpecies?(:LATIOS)
      if Settings::SOUL_DEW_POWERS_UP_TYPES
        mults[:final_damage_multiplier] *= 1.2 if type == :PSYCHIC || type == :DRAGON
      else
        if move.specialMove? && !user.battle.rules["souldewclause"]
          mults[:attack_multiplier] *= 1.5
        end
      end
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:SPELLTAG,
    proc { |item,user,target,move,mults,baseDmg,type|
      mults[:base_damage_multiplier] *= 1.2 if type == :GHOST
    }
  )
  
  BattleHandlers::DamageCalcUserItem.copy(:SPELLTAG,:SPOOKYPLATE)
  
  BattleHandlers::DamageCalcUserItem.add(:STEELGEM,
    proc { |item,user,target,move,mults,baseDmg,type|
      pbBattleGem(user,:STEEL,move,mults,type)
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:TWISTEDSPOON,
    proc { |item,user,target,move,mults,baseDmg,type|
      mults[:base_damage_multiplier] *= 1.2 if type == :PSYCHIC
    }
  )
  
  BattleHandlers::DamageCalcUserItem.copy(:TWISTEDSPOON,:MINDPLATE,:ODDINCENSE)
  
  BattleHandlers::DamageCalcUserItem.add(:WATERGEM,
    proc { |item,user,target,move,mults,baseDmg,type|
      pbBattleGem(user,:WATER,move,mults,type)
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:WISEGLASSES,
    proc { |item,user,target,move,mults,baseDmg,type|
      mults[:base_damage_multiplier] *= 1.1 if move.specialMove?
    }
  )

BattleHandlers::DamageCalcUserItem.add(:CHOICEBAND,
    proc { |item,user,target,move,mults,baseDmg,type|
      mults[:base_damage_multiplier] *= 1.33 if move.physicalMove?
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:CHOICESPECS,
    proc { |item,user,target,move,mults,baseDmg,type|
      mults[:base_damage_multiplier] *= 1.33 if move.specialMove?
    }
  )

  BattleHandlers::DamageCalcUserItem.add(:THICKCLUB,
    proc { |item,user,target,move,mults,baseDmg,type|
      if (user.isSpecies?(:CUBONE) || user.isSpecies?(:MAROWAK)) && move.physicalMove?
        mults[:attack_multiplier] *= 1.5
      end
    }
  )