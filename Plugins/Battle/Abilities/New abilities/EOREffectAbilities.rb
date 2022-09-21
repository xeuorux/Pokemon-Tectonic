BattleHandlers::EOREffectAbility.add(:ASTRALBODY,
  proc { |ability,battler,battle|
	next unless battle.field.terrain==:Misty
    next if !battler.canHeal?
	  battle.pbShowAbilitySplash(battler)
    battler.pbRecoverHP(battler.totalhp/16)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    else
      battle.pbDisplay(_INTL("{1}'s {2} restored its HP.",battler.pbThis,battler.abilityName))
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::EOREffectAbility.add(:LUXURYTASTE,
  proc { |ability,battler,battle|
    next unless battler.hasActiveItem?(CLOTHING_ITEMS)
    next unless battler.canHeal?
    battle.pbShowAbilitySplash(battler)
    recover = battler.totalhp/8
    recover /= 4 if battler.boss?
    battler.pbRecoverHP(recover)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    else
      battle.pbDisplay(_INTL("{1}'s {2} restored its HP.",battler.pbThis,battler.abilityName))
    end
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
        battle.pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    end
    
    battle.pbHideAbilitySplash(battler)
  }
)