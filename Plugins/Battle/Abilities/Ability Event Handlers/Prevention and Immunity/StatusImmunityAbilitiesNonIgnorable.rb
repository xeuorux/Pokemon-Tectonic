BattleHandlers::StatusImmunityAbilityNonIgnorable.add(:SHIELDSDOWN,
    proc { |_ability, battler, _status|
        next true if battler.isSpecies?(:MINIOR) && battler.form < 7
    }
)
