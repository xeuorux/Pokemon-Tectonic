BattleHandlers::DamageCalcUserItem.add(:ADAMANTORB,
    proc { |item, user, _target, _move, mults, _baseDmg, type, _aiChecking|
        mults[:base_damage_multiplier] *= 1.2 if user.isSpecies?(:DIALGA) && %i[DRAGON STEEL].include?(type)
    }
)

BattleHandlers::DamageCalcUserItem.add(:BLACKBELT,
  proc { |item, _user, _target, _move, mults, _baseDmg, type, _aiChecking|
      mults[:base_damage_multiplier] *= 1.2 if type == :FIGHTING
  }
)

BattleHandlers::DamageCalcUserItem.copy(:BLACKBELT, :FISTPLATE)

BattleHandlers::DamageCalcUserItem.add(:BLACKGLASSES,
  proc { |item, _user, _target, _move, mults, _baseDmg, type, _aiChecking|
      mults[:base_damage_multiplier] *= 1.2 if type == :DARK
  }
)

BattleHandlers::DamageCalcUserItem.copy(:BLACKGLASSES, :DREADPLATE)

BattleHandlers::DamageCalcUserItem.add(:BUGGEM,
  proc { |item, user, _target, move, mults, _baseDmg, type, aiChecking|
      pbBattleGem(item, user, :BUG, move, mults, type, aiChecking)
  }
)

BattleHandlers::DamageCalcUserItem.add(:CHARCOAL,
  proc { |item, _user, _target, _move, mults, _baseDmg, type, _aiChecking|
      mults[:base_damage_multiplier] *= 1.2 if type == :FIRE
  }
)

BattleHandlers::DamageCalcUserItem.copy(:CHARCOAL, :FLAMEPLATE)

BattleHandlers::DamageCalcUserItem.add(:DARKGEM,
  proc { |item, user, _target, move, mults, _baseDmg, type, aiChecking|
      pbBattleGem(item, user, :DARK, move, mults, type, aiChecking)
  }
)

BattleHandlers::DamageCalcUserItem.add(:DRAGONFANG,
  proc { |item, _user, _target, _move, mults, _baseDmg, type, _aiChecking|
      mults[:base_damage_multiplier] *= 1.2 if type == :DRAGON
  }
)

BattleHandlers::DamageCalcUserItem.copy(:DRAGONFANG, :DRACOPLATE)

BattleHandlers::DamageCalcUserItem.add(:DRAGONGEM,
  proc { |item, user, _target, move, mults, _baseDmg, type, aiChecking|
      pbBattleGem(item, user, :DRAGON, move, mults, type, aiChecking)
  }
)

BattleHandlers::DamageCalcUserItem.add(:ELECTRICGEM,
  proc { |item, user, _target, move, mults, _baseDmg, type, aiChecking|
      pbBattleGem(item, user, :ELECTRIC, move, mults, type, aiChecking)
  }
)

BattleHandlers::DamageCalcUserItem.add(:EXPERTBELT,
  proc { |item, _user, target, _move, mults, _baseDmg, _type, _aiChecking|
      mults[:final_damage_multiplier] *= 1.2 if Effectiveness.super_effective?(target.damageState.typeMod)
  }
)

BattleHandlers::DamageCalcUserItem.add(:FAIRYGEM,
  proc { |item, user, _target, move, mults, _baseDmg, type, aiChecking|
      pbBattleGem(item, user, :FAIRY, move, mults, type, aiChecking)
  }
)

BattleHandlers::DamageCalcUserItem.add(:FIGHTINGGEM,
  proc { |item, user, _target, move, mults, _baseDmg, type, aiChecking|
      pbBattleGem(item, user, :FIGHTING, move, mults, type, aiChecking)
  }
)

BattleHandlers::DamageCalcUserItem.add(:FIREGEM,
  proc { |item, user, _target, move, mults, _baseDmg, type, aiChecking|
      pbBattleGem(item, user, :FIRE, move, mults, type, aiChecking)
  }
)

BattleHandlers::DamageCalcUserItem.add(:FLYINGGEM,
  proc { |item, user, _target, move, mults, _baseDmg, type, aiChecking|
      pbBattleGem(item, user, :FLYING, move, mults, type, aiChecking)
  }
)

BattleHandlers::DamageCalcUserItem.add(:GHOSTGEM,
  proc { |item, user, _target, move, mults, _baseDmg, type, aiChecking|
      pbBattleGem(item, user, :GHOST, move, mults, type, aiChecking)
  }
)

BattleHandlers::DamageCalcUserItem.add(:GRASSGEM,
  proc { |item, user, _target, move, mults, _baseDmg, type, aiChecking|
      pbBattleGem(item, user, :GRASS, move, mults, type, aiChecking)
  }
)

BattleHandlers::DamageCalcUserItem.add(:GRISEOUSORB,
  proc { |item, user, _target, _move, mults, _baseDmg, type, _aiChecking|
      mults[:base_damage_multiplier] *= 1.2 if user.isSpecies?(:GIRATINA) && %i[DRAGON GHOST].include?(type)
  }
)

BattleHandlers::DamageCalcUserItem.add(:GROUNDGEM,
  proc { |item, user, _target, move, mults, _baseDmg, type, aiChecking|
      pbBattleGem(item, user, :GROUND, move, mults, type, aiChecking)
  }
)

BattleHandlers::DamageCalcUserItem.add(:HARDSTONE,
  proc { |item, _user, _target, _move, mults, _baseDmg, type, _aiChecking|
      mults[:base_damage_multiplier] *= 1.2 if type == :ROCK
  }
)

BattleHandlers::DamageCalcUserItem.copy(:HARDSTONE, :STONEPLATE, :ROCKINCENSE)

BattleHandlers::DamageCalcUserItem.add(:ICEGEM,
  proc { |item, user, _target, move, mults, _baseDmg, type, aiChecking|
      pbBattleGem(item, user, :ICE, move, mults, type, aiChecking)
  }
)

BattleHandlers::DamageCalcUserItem.add(:LIFEORB,
  proc { |item, _user, _target, move, mults, _baseDmg, _type, _aiChecking|
      mults[:final_damage_multiplier] *= 1.3 unless move.is_a?(PokeBattle_Confusion)
  }
)

BattleHandlers::DamageCalcUserItem.add(:LIGHTBALL,
  proc { |item, user, _target, _move, mults, _baseDmg, _type, _aiChecking|
      mults[:attack_multiplier] *= 2 if user.isSpecies?(:PIKACHU)
  }
)

BattleHandlers::DamageCalcUserItem.add(:LUSTROUSORB,
  proc { |item, user, _target, _move, mults, _baseDmg, type, _aiChecking|
      mults[:base_damage_multiplier] *= 1.2 if user.isSpecies?(:PALKIA) && %i[DRAGON WATER].include?(type)
  }
)

BattleHandlers::DamageCalcUserItem.add(:MAGNET,
  proc { |item, _user, _target, _move, mults, _baseDmg, type, _aiChecking|
      mults[:base_damage_multiplier] *= 1.2 if type == :ELECTRIC
  }
)

BattleHandlers::DamageCalcUserItem.copy(:MAGNET, :ZAPPLATE)

BattleHandlers::DamageCalcUserItem.add(:METALCOAT,
  proc { |item, _user, _target, _move, mults, _baseDmg, type, _aiChecking|
      mults[:base_damage_multiplier] *= 1.2 if type == :STEEL
  }
)

BattleHandlers::DamageCalcUserItem.copy(:METALCOAT, :IRONPLATE)

BattleHandlers::DamageCalcUserItem.add(:METRONOME,
  proc { |item, user, _target, _move, mults, _baseDmg, _type, _aiChecking|
      met = 1 + 0.2 * user.countEffect(:Metronome)
      mults[:final_damage_multiplier] *= met
  }
)

BattleHandlers::DamageCalcUserItem.add(:MIRACLESEED,
  proc { |item, _user, _target, _move, mults, _baseDmg, type, _aiChecking|
      mults[:base_damage_multiplier] *= 1.2 if type == :GRASS
  }
)

BattleHandlers::DamageCalcUserItem.copy(:MIRACLESEED, :MEADOWPLATE, :ROSEINCENSE)

BattleHandlers::DamageCalcUserItem.add(:MYSTICWATER,
  proc { |item, _user, _target, _move, mults, _baseDmg, type, _aiChecking|
      mults[:base_damage_multiplier] *= 1.2 if type == :WATER
  }
)

BattleHandlers::DamageCalcUserItem.copy(:MYSTICWATER, :SPLASHPLATE, :SEAINCENSE, :WAVEINCENSE)

BattleHandlers::DamageCalcUserItem.add(:NEVERMELTICE,
  proc { |item, _user, _target, _move, mults, _baseDmg, type, _aiChecking|
      mults[:base_damage_multiplier] *= 1.2 if type == :ICE
  }
)

BattleHandlers::DamageCalcUserItem.copy(:NEVERMELTICE, :ICICLEPLATE)

BattleHandlers::DamageCalcUserItem.add(:NORMALGEM,
  proc { |item, user, _target, move, mults, _baseDmg, type, aiChecking|
      pbBattleGem(item, user, :NORMAL, move, mults, type, aiChecking)
  }
)

BattleHandlers::DamageCalcUserItem.add(:PIXIEPLATE,
  proc { |item, _user, _target, _move, mults, _baseDmg, type, _aiChecking|
      mults[:base_damage_multiplier] *= 1.2 if type == :FAIRY
  }
)

BattleHandlers::DamageCalcUserItem.add(:POISONBARB,
  proc { |item, _user, _target, _move, mults, _baseDmg, type, _aiChecking|
      mults[:base_damage_multiplier] *= 1.2 if type == :POISON
  }
)

BattleHandlers::DamageCalcUserItem.copy(:POISONBARB, :TOXICPLATE)

BattleHandlers::DamageCalcUserItem.add(:POISONGEM,
  proc { |item, user, _target, move, mults, _baseDmg, type, aiChecking|
      pbBattleGem(item, user, :POISON, move, mults, type, aiChecking)
  }
)

BattleHandlers::DamageCalcUserItem.add(:PSYCHICGEM,
  proc { |item, user, _target, move, mults, _baseDmg, type, aiChecking|
      pbBattleGem(item, user, :PSYCHIC, move, mults, type, aiChecking)
  }
)

BattleHandlers::DamageCalcUserItem.add(:ROCKGEM,
  proc { |item, user, _target, move, mults, _baseDmg, type, aiChecking|
      pbBattleGem(item, user, :ROCK, move, mults, type, aiChecking)
  }
)

BattleHandlers::DamageCalcUserItem.add(:SHARPBEAK,
  proc { |item, _user, _target, _move, mults, _baseDmg, type, _aiChecking|
      mults[:base_damage_multiplier] *= 1.2 if type == :FLYING
  }
)

BattleHandlers::DamageCalcUserItem.copy(:SHARPBEAK, :SKYPLATE)

BattleHandlers::DamageCalcUserItem.add(:SILKSCARF,
  proc { |item, _user, _target, _move, mults, _baseDmg, type, _aiChecking|
      mults[:base_damage_multiplier] *= 1.2 if type == :NORMAL
  }
)

BattleHandlers::DamageCalcUserItem.add(:SILVERPOWDER,
  proc { |item, _user, _target, _move, mults, _baseDmg, type, _aiChecking|
      mults[:base_damage_multiplier] *= 1.2 if type == :BUG
  }
)

BattleHandlers::DamageCalcUserItem.copy(:SILVERPOWDER, :INSECTPLATE)

BattleHandlers::DamageCalcUserItem.add(:SOFTSAND,
  proc { |item, _user, _target, _move, mults, _baseDmg, type, _aiChecking|
      mults[:base_damage_multiplier] *= 1.2 if type == :GROUND
  }
)

BattleHandlers::DamageCalcUserItem.copy(:SOFTSAND, :EARTHPLATE)

BattleHandlers::DamageCalcUserItem.add(:SOULDEW,
  proc { |item, user, _target, move, mults, _baseDmg, type, _aiChecking|
      next if !user.isSpecies?(:LATIAS) && !user.isSpecies?(:LATIOS)
      if Settings::SOUL_DEW_POWERS_UP_TYPES
          mults[:final_damage_multiplier] *= 1.2 if %i[PSYCHIC DRAGON].include?(type)
      elsif move.specialMove? && !user.battle.rules["souldewclause"]
          mults[:attack_multiplier] *= 1.5
      end
  }
)

BattleHandlers::DamageCalcUserItem.add(:SPELLTAG,
  proc { |item, _user, _target, _move, mults, _baseDmg, type, _aiChecking|
      mults[:base_damage_multiplier] *= 1.2 if type == :GHOST
  }
)

BattleHandlers::DamageCalcUserItem.copy(:SPELLTAG, :SPOOKYPLATE)

BattleHandlers::DamageCalcUserItem.add(:STEELGEM,
  proc { |item, user, _target, move, mults, _baseDmg, type, aiChecking|
      pbBattleGem(item, user, :STEEL, move, mults, type, aiChecking)
  }
)

BattleHandlers::DamageCalcUserItem.add(:TWISTEDSPOON,
  proc { |item, _user, _target, _move, mults, _baseDmg, type, _aiChecking|
      mults[:base_damage_multiplier] *= 1.2 if type == :PSYCHIC
  }
)

BattleHandlers::DamageCalcUserItem.copy(:TWISTEDSPOON, :MINDPLATE, :ODDINCENSE)

BattleHandlers::DamageCalcUserItem.add(:WATERGEM,
  proc { |item, user, _target, move, mults, _baseDmg, type, aiChecking|
      pbBattleGem(item, user, :WATER, move, mults, type, aiChecking)
  }
)

BattleHandlers::DamageCalcUserItem.add(:PRISMATICPLATE,
  proc { |item, user, target, _move, mults, _baseDmg, type, _aiChecking|
      mults[:final_damage_multiplier] *= 1.2 if user.pbHasType?(type)
  }
)

BattleHandlers::DamageCalcUserItem.add(:STRENGTHHERB,
  proc { |item, user, target, move, mults, _baseDmg, type, aiChecking|
      next unless move.physicalMove?
      user.applyEffect(:EmpoweringHerbConsumed, item) unless aiChecking
      mults[:final_damage_multiplier] *= 1.33
  }
)

BattleHandlers::DamageCalcUserItem.add(:INTELLECTHERB,
  proc { |item, user, target, move, mults, _baseDmg, type, aiChecking|
      next unless move.specialMove?
      user.applyEffect(:EmpoweringHerbConsumed, item) unless aiChecking
      mults[:final_damage_multiplier] *= 1.33
  }
)

BattleHandlers::DamageCalcUserItem.add(:SCOPELENS,
  proc { |item, user, target, move, mults, _baseDmg, type, aiChecking|
    mults[:final_damage_multiplier] *= 1.33 if target.damageState.critical
  }
)