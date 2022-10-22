BattleHandlers::AbilityOnEnemySwitchIn.add(:DETERRENT,
    proc { |ability,switcher,bearer,battle|
      PBDebug.log("[Ability triggered] #{bearer.pbThis}'s #{bearer.abilityName}")
      battle.pbShowAbilitySplash(bearer)
      if switcher.takesIndirectDamage?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
        battle.scene.pbDamageAnimation(switcher)
        battle.pbDisplay(_INTL("{1} was attacked on sight!",switcher.pbThis))
        switcher.applyFractionalDamage(1.0/8.0)
      end
      battle.pbHideAbilitySplash(bearer)
    }
  )