BattleHandlers::TrappingTargetAbility.add(:ARENATRAP,
    proc { |ability, switcher, _bearer, _battle|
        next true unless switcher.airborne?
    }
)

BattleHandlers::TrappingTargetAbility.add(:SHADOWTAG,
  proc { |ability, switcher, _bearer, _battle|
      next true unless switcher.hasActiveAbility?(:SHADOWTAG)
  }
)

BattleHandlers::TrappingTargetAbility.add(:CLINGY,
  proc { |ability, switcher, _bearer, _battle|
      next true if switcher.pbHasAnyStatus?
  }
)

BattleHandlers::TrappingTargetAbility.add(:FROSTPITALITY,
  proc { |ability, switcher, _bearer, battle|
      next true if battle.pbWeather == :Hail
  }
)

BattleHandlers::TrappingTargetAbility.add(:MAGNETTRAP,
  proc { |ability, switcher, bearer, _battle|
      next true if bearer.pbSpAtk > switcher.pbSpAtk
  }
)