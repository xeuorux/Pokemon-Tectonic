BattleHandlers::TotalEclipseAbility.add(:TOTALGRASP,
    proc { |ability, battler, _battle|
        battler.pbRaiseMultipleStatStages([:ATTACK,1,:DEFENSE,1,:SPECIAL_ATTACK,1,:SPECIAL_DEFENSE,1,:SPEED,1],battler,
             ability: ability)
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