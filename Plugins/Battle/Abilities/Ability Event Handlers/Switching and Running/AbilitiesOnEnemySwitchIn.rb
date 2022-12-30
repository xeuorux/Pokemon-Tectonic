BattleHandlers::AbilityOnEnemySwitchIn.add(:DETERRENT,
    proc { |_ability, switcher, bearer, battle|
        PBDebug.log("[Ability triggered] #{bearer.pbThis}'s #{bearer.abilityName}")
        battle.pbShowAbilitySplash(bearer)
        if switcher.takesIndirectDamage?(true)
            battle.scene.pbDamageAnimation(switcher)
            battle.pbDisplay(_INTL("{1} was attacked on sight!", switcher.pbThis))
            switcher.applyFractionalDamage(1.0 / 8.0)
        end
        battle.pbHideAbilitySplash(bearer)
    }
)
