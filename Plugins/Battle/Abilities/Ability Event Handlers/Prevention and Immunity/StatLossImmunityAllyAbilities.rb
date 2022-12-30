BattleHandlers::StatLossImmunityAllyAbility.add(:FLOWERVEIL,
    proc { |_ability, bearer, battler, _stat, battle, showMessages|
        next false unless battler.pbHasType?(:GRASS)
        if showMessages
            battle.pbShowAbilitySplash(bearer)
            battle.pbDisplay(_INTL("{1}'s stats cannot be lowered!", battler.pbThis))
            battle.pbHideAbilitySplash(bearer)
        end
        next true
    }
)
