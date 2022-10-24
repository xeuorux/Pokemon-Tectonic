BattleHandlers::StatLossImmunityAllyAbility.add(:FLOWERVEIL,
    proc { |ability,bearer,battler,stat,battle,showMessages|
      next false if !battler.pbHasType?(:GRASS)
      if showMessages
        battle.pbShowAbilitySplash(bearer)
        battle.pbDisplay(_INTL("{1}'s stats cannot be lowered!",battler.pbThis))
        battle.pbHideAbilitySplash(bearer)
      end
      next true
    }
  )