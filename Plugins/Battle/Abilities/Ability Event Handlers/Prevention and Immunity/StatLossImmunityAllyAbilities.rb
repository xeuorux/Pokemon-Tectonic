BattleHandlers::StatLossImmunityAllyAbility.add(:FLOWERVEIL,
    proc { |ability,bearer,battler,stat,battle,showMessages|
      next false if !battler.pbHasType?(:GRASS)
      if showMessages
        battle.pbShowAbilitySplash(bearer)
        if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          battle.pbDisplay(_INTL("{1}'s stats cannot be lowered!",battler.pbThis))
        else
          battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s stat loss!",
             bearer.pbThis,bearer.abilityName,battler.pbThis(true)))
        end
        battle.pbHideAbilitySplash(bearer)
      end
      next true
    }
  )