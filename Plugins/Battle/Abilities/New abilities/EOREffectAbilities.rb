BattleHandlers::EOREffectAbility.add(:ASTRALBODY,
  proc { |ability,battler,battle|
	next unless battle.field.terrain==:Misty
    next if !battler.canHeal?
	  battle.pbShowAbilitySplash(battler)
    healAmount = battler.totalhp / 16.0
    healAmount /= BOSS_HP_BASED_EFFECT_RESISTANCE.to_f if battler.boss?
    healingMessage = battle.pbDisplay(_INTL("{1} absorbs magic from the fae mist.",battler.pbThis))
    battler.pbRecoverHP(healAmount,true,true,true,healingMessage)
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::EOREffectAbility.add(:LUXURYTASTE,
  proc { |ability,battler,battle|
    next unless battler.hasActiveItem?(CLOTHING_ITEMS)
    next unless battler.canHeal?
    battle.pbShowAbilitySplash(battler)
    healAmount = battler.totalhp / 8.0
    healAmount /= BOSS_HP_BASED_EFFECT_RESISTANCE.to_f if battler.boss?
    healingMessage = battle.pbDisplay(_INTL("{1} luxuriated in its fine clothing.",battler.pbThis))
    battler.pbRecoverHP(healAmount,true,true,true,healingMessage)
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::EOREffectAbility.add(:WARMTHCYCLE,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    if !battler.statStageAtMax?(:SPEED)
        if battler.pbCanRaiseStatStage?(:SPEED)
            battle.pbDisplay(_INTL("{1} warms up!",battler.pbThis))
            battler.pbRaiseStatStage(:SPEED,2,battler)
            battler.applyFractionalDamage(1.0/8.0,false)
        end
    else
        battle.pbDisplay(_INTL("{1} vents its accumulated heat!",battler.pbThis))
        battler.pbLowerStatStage(:SPEED,6,battler)
        battler.pbRecoverHP(battler.totalhp - battler.hp)
    end
    
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::EOREffectAbility.add(:EXTREMEHEAT,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battler.applyFractionalDamage(1.0/10.0,false)
    battle.pbHideAbilitySplash(battler)
  }
)