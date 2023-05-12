BattleHandlers::TotalEclipseAbility.add(:TOTALGRASP,
    proc { |ability, battler, _battle|
        battler.pbRaiseMultipleStatSteps([:ATTACK,2,:DEFENSE,2,:SPECIAL_ATTACK,2,:SPECIAL_DEFENSE,2,:SPEED,2], battler, ability: ability)
    }
)

BattleHandlers::TotalEclipseAbility.add(:TOLLDANGER,
    proc { |ability, battler, battle|
        battle.pbShowAbilitySplash(battler, ability)
        battler.applyFractionalHealing(1.0/2.0)
        battle.forceUseMove(battler, :HEALBELL)
        battle.pbHideAbilitySplash(battler)
    }
)