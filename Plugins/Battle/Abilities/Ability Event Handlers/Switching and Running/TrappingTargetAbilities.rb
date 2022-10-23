
BattleHandlers::TrappingTargetAbility.add(:ARENATRAP,
    proc { |ability,switcher,bearer,battle|
      next true if !switcher.airborne?
    }
  )
  
  BattleHandlers::TrappingTargetAbility.add(:MAGNETPULL,
    proc { |ability,switcher,bearer,battle|
      next true if switcher.pbHasType?(:STEEL)
    }
  )
  
  BattleHandlers::TrappingTargetAbility.add(:SHADOWTAG,
    proc { |ability,switcher,bearer,battle|
      next true if !switcher.hasActiveAbility?(:SHADOWTAG)
    }
  )