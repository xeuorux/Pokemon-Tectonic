BattleHandlers::TotalEclipseAbility.add(:TOTALGRASP,
    proc { |_ability, battler, _battle|
        battler.pbRaiseMultipleStatStages([:ATTACK,1,:DEFENSE,1,:SPECIAL_ATTACK,1,:SPECIAL_DEFENSE,1,:SPEED,1],battler,
             showAbilitySplash: true)
    }
)

BattleHandlers::TotalEclipseAbility.add(:TOLLDANGER,
    proc { |_ability, battler, battle|
        battler.pbShowAbilitySplash(battler)
        battler.applyFractionalHealing(1.0/2.0)
        battle.forceUseMove(battler, :HEALBELL)
        battler.pbHideAbilitySplash(battler)
    }
)