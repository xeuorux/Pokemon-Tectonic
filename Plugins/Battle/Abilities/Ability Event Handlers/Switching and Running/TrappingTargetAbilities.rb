BattleHandlers::TrappingTargetAbility.add(:ARENATRAP,
    proc { |_ability, switcher, _bearer, _battle|
        next true unless switcher.airborne?
    }
)

BattleHandlers::TrappingTargetAbility.add(:MAGNETPULL,
  proc { |_ability, switcher, _bearer, _battle|
      next true if switcher.pbHasType?(:STEEL)
  }
)

BattleHandlers::TrappingTargetAbility.add(:SHADOWTAG,
  proc { |_ability, switcher, _bearer, _battle|
      next true unless switcher.hasActiveAbility?(:SHADOWTAG)
  }
)

BattleHandlers::TrappingTargetAbility.add(:CLINGY,
  proc { |_ability, switcher, _bearer, _battle|
      next true if switcher.pbHasAnyStatus?
  }
)