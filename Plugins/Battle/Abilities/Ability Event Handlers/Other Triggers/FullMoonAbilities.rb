# None!

BattleHandlers::FullMoonAbility.add(:WEREWOLF,
    proc { |ability, battler, battle|
        next unless battler.species == :LYCANROC
        next unless battler.form == 0
        battle.pbShowAbilitySplash(battler, ability)
        battler.pbChangeForm(1, _INTL("{1}'s transforms with exposure to the Full Moon!", battler.pbThis))
        battle.pbHideAbilitySplash(battler)
    }
)