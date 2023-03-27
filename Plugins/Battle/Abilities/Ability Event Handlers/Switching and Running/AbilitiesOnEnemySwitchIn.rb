BattleHandlers::AbilityOnEnemySwitchIn.add(:DETERRENT,
    proc { |ability, switcher, bearer, battle|
        battle.pbShowAbilitySplash(bearer, ability)
        if switcher.takesIndirectDamage?(true)
            battle.pbDisplay(_INTL("{1} was attacked on sight!", switcher.pbThis))
            switcher.applyFractionalDamage(1.0 / 8.0)
        end
        battle.pbHideAbilitySplash(bearer)
    }
)
