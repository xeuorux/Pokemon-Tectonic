BattleHandlers::SpecialAttackCalcAllyAbility.add(:BATTERY,
    proc { |_ability, _user, _battle, spAtkMult|
        spAtkMult *= 1.3
        next spAtkMult
    }
)

BattleHandlers::SpecialAttackCalcAllyAbility.add(:POSITIVEOUTLOOK,
    proc { |_ability, user, _battle, spAtkMult|
        spAtkMult *= 1.5 if user.pbHasType?(:ELECTRIC)
        next spAtkMult
    }
)
