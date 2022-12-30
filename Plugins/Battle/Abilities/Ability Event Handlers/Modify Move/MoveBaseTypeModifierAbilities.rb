BattleHandlers::MoveBaseTypeModifierAbility.add(:AERILATE,
    proc { |_ability, _user, move, type|
        next if type != :NORMAL || !GameData::Type.exists?(:FLYING)
        move.powerBoost = true
        next :FLYING
    }
)

BattleHandlers::MoveBaseTypeModifierAbility.add(:GALVANIZE,
  proc { |_ability, _user, move, type|
      next if type != :NORMAL || !GameData::Type.exists?(:ELECTRIC)
      move.powerBoost = true
      next :ELECTRIC
  }
)

BattleHandlers::MoveBaseTypeModifierAbility.add(:LIQUIDVOICE,
  proc { |_ability, _user, move, _type|
      next :WATER if GameData::Type.exists?(:WATER) && move.soundMove?
  }
)

BattleHandlers::MoveBaseTypeModifierAbility.add(:NORMALIZE,
  proc { |_ability, _user, move, _type|
      next unless GameData::Type.exists?(:NORMAL)
      move.powerBoost = true
      next :NORMAL
  }
)

BattleHandlers::MoveBaseTypeModifierAbility.add(:PIXILATE,
  proc { |_ability, _user, move, type|
      next if type != :NORMAL || !GameData::Type.exists?(:FAIRY)
      move.powerBoost = true
      next :FAIRY
  }
)

BattleHandlers::MoveBaseTypeModifierAbility.add(:REFRIGERATE,
  proc { |_ability, _user, move, type|
      next if type != :NORMAL || !GameData::Type.exists?(:ICE)
      move.powerBoost = true
      next :ICE
  }
)

BattleHandlers::MoveBaseTypeModifierAbility.add(:FROSTSONG,
    proc { |_ability, _user, move, _type|
        next unless move.soundMove?
        next unless GameData::Type.exists?(:ICE)
        move.powerBoost = true
        next :ICE
    }
)

BattleHandlers::MoveBaseTypeModifierAbility.add(:BLADETRAINED,
    proc { |_ability, _user, move, _type|
        next unless move.slashMove?
        next unless GameData::Type.exists?(:FIGHTING)
        move.powerBoost = true
        next :FIGHTING
    }
)
