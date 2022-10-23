BattleHandlers::MoveBaseTypeModifierAbility.add(:AERILATE,
    proc { |ability,user,move,type|
      next if type != :NORMAL || !GameData::Type.exists?(:FLYING)
      move.powerBoost = true
      next :FLYING
    }
  )
  
  BattleHandlers::MoveBaseTypeModifierAbility.add(:GALVANIZE,
    proc { |ability,user,move,type|
      next if type != :NORMAL || !GameData::Type.exists?(:ELECTRIC)
      move.powerBoost = true
      next :ELECTRIC
    }
  )
  
  BattleHandlers::MoveBaseTypeModifierAbility.add(:LIQUIDVOICE,
    proc { |ability,user,move,type|
      next :WATER if GameData::Type.exists?(:WATER) && move.soundMove?
    }
  )
  
  BattleHandlers::MoveBaseTypeModifierAbility.add(:NORMALIZE,
    proc { |ability,user,move,type|
      next if !GameData::Type.exists?(:NORMAL)
      move.powerBoost = true
      next :NORMAL
    }
  )
  
  BattleHandlers::MoveBaseTypeModifierAbility.add(:PIXILATE,
    proc { |ability,user,move,type|
      next if type != :NORMAL || !GameData::Type.exists?(:FAIRY)
      move.powerBoost = true
      next :FAIRY
    }
  )
  
  BattleHandlers::MoveBaseTypeModifierAbility.add(:REFRIGERATE,
    proc { |ability,user,move,type|
      next if type != :NORMAL || !GameData::Type.exists?(:ICE)
      move.powerBoost = true
      next :ICE
    }
  )

BattleHandlers::MoveBaseTypeModifierAbility.add(:FROSTSONG,
    proc { |ability,user,move,type|
      next if !move.soundMove?
      next if !GameData::Type.exists?(:ICE)
      move.powerBoost = true
      next :ICE
    }
)

BattleHandlers::MoveBaseTypeModifierAbility.add(:BLADETRAINED,
    proc { |ability,user,move,type|
        next if !move.slashMove?
        next if !GameData::Type.exists?(:FIGHTING)
        move.powerBoost = true
        next :FIGHTING
    }
)