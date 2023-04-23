BattleHandlers::MoveBaseTypeModifierAbility.add(:AERILATE,
    proc { |ability, _user, move, type|
        next if type != :NORMAL || !GameData::Type.exists?(:FLYING)
        move.powerBoost = true
        next :FLYING
    }
)

BattleHandlers::MoveBaseTypeModifierAbility.add(:GALVANIZE,
  proc { |ability, _user, move, type|
      next if type != :NORMAL || !GameData::Type.exists?(:ELECTRIC)
      move.powerBoost = true
      next :ELECTRIC
  }
)

BattleHandlers::MoveBaseTypeModifierAbility.add(:LIQUIDVOICE,
  proc { |ability, _user, move, _type|
      next :WATER if GameData::Type.exists?(:WATER) && move.soundMove?
  }
)

BattleHandlers::MoveBaseTypeModifierAbility.add(:NORMALIZE,
  proc { |ability, _user, move, _type|
      next unless GameData::Type.exists?(:NORMAL)
      move.powerBoost = true
      next :NORMAL
  }
)

BattleHandlers::MoveBaseTypeModifierAbility.add(:PIXILATE,
  proc { |ability, _user, move, type|
      next if type != :NORMAL || !GameData::Type.exists?(:FAIRY)
      move.powerBoost = true
      next :FAIRY
  }
)

BattleHandlers::MoveBaseTypeModifierAbility.add(:REFRIGERATE,
  proc { |ability, _user, move, type|
      next if type != :NORMAL || !GameData::Type.exists?(:ICE)
      move.powerBoost = true
      next :ICE
  }
)

BattleHandlers::MoveBaseTypeModifierAbility.add(:FROSTSONG,
    proc { |ability, _user, move, _type|
        next unless move.soundMove?
        next unless GameData::Type.exists?(:ICE)
        move.powerBoost = true
        next :ICE
    }
)

BattleHandlers::MoveBaseTypeModifierAbility.add(:BLADETRAINED,
    proc { |ability, _user, move, _type|
        next unless move.bladeMove?
        next unless GameData::Type.exists?(:FIGHTING)
        move.powerBoost = true
        next :FIGHTING
    }
)
