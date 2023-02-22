# None!

BattleHandlers::FullMoonAbility.add(:WEREWOLF,
    proc { |_ability, battler, _battle|
        next unless user.species == :LYCANROC
        next unless user.form == 0
        battle.pbShowAbilitySplash(user)
        user.pbChangeForm(1, _INTL("{1}'s transforms with exposure to the Full Moon!", user.pbThis))
        battle.pbHideAbilitySplash(user)
    }
)