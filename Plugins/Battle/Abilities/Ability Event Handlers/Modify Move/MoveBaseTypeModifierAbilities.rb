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