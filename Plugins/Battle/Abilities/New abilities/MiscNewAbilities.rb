#===============================================================================
# StatLossImmunityAbility handlers
#===============================================================================
BattleHandlers::StatLossImmunityAbility.copy(:CLEARBODY,:WHITESMOKE,:STUBBORN)

BattleHandlers::StatLossImmunityAbility.add(:IMPERVIOUS,
  proc { |ability,battler,stat,battle,showMessages|
    next false if stat!=:DEFENSE && stat!=:SPECIAL_DEFENSE
    if showMessages
      battle.pbShowAbilitySplash(battler)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s {2} cannot be lowered!",battler.pbThis,GameData::Stat.get(stat).name))
      else
        battle.pbDisplay(_INTL("{1}'s {2} prevents {3} loss!",battler.pbThis,
           battler.abilityName,GameData::Stat.get(stat).name))
      end
      battle.pbHideAbilitySplash(battler)
    end
    next true
  }
)

#===============================================================================
# AbilityOnEnemySwitchIn handlers
#===============================================================================

BattleHandlers::AbilityOnEnemySwitchIn.add(:DETERRENT,
  proc { |ability,switcher,bearer,battle|
    PBDebug.log("[Ability triggered] #{bearer.pbThis}'s #{bearer.abilityName}")
    battle.pbShowAbilitySplash(bearer)
    if switcher.takesIndirectDamage?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      battle.scene.pbDamageAnimation(switcher)
      battle.pbDisplay(_INTL("{1} was attacked on sight!",switcher.pbThis))
      switcher.applyFractionalDamage(1.0/8.0)
    end
    battle.pbHideAbilitySplash(bearer)
  }
)

#===============================================================================
# AccuracyCalcUserAbility handlers
#===============================================================================

BattleHandlers::AccuracyCalcUserAbility.add(:SANDSNIPER,
  proc { |ability,mods,user,target,move,type|
    mods[:base_accuracy] = 0 if user.battle.pbWeather == :Sandstorm
  }
)

BattleHandlers::AccuracyCalcUserAbility.add(:AQUASNEAK,
  proc { |ability,mods,user,target,move,type|
    mods[:base_accuracy] = 0 if user.turnCount <= 1
  }
)

#===============================================================================
# MoveBlockingAbility handlers
#===============================================================================
BattleHandlers::MoveBlockingAbility.add(:KILLJOY,
  proc { |ability,bearer,user,targets,move,battle|
    next move.danceMove?
  }
)

BattleHandlers::MoveBlockingAbility.copy(:DAZZLING,:ROYALMAJESTY)

BattleHandlers::MoveBlockingAbility.add(:BADINFLUENCE,
  proc { |ability,bearer,user,targets,move,battle|
    next move.healingMove?
  }
)

#===============================================================================
# AccuracyCalcTargetAbility handlers
#===============================================================================
BattleHandlers::AccuracyCalcUserAllyAbility.add(:OCULAR,
  proc { |ability,mods,user,target,move,type|
    mods[:accuracy_multiplier] *= 1.5
  }
)

#===============================================================================
# AbilityOnBattlerFainting handlers
#===============================================================================

BattleHandlers::AbilityOnBattlerFainting.add(:ARCANEFINALE,
  proc { |ability,battler,fainted,battle|
    next if battler.opposes?(fainted)
    next if !battler.isLastAlive?
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is the team's finale!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnBattlerFainting.add(:HEROICFINALE,
  proc { |ability,battler,fainted,battle|
    next if battler.opposes?(fainted)
    next if !battler.isLastAlive?
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is the team's finale!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

#===============================================================================
# AbilityOnStatLoss handlers
#===============================================================================

BattleHandlers::AbilityOnStatLoss.add(:BELLIGERENT,
  proc { |ability,battler,stat,user|
    next if user && !user.opposes?(battler)
    battler.pbRaiseStatStageByAbility(:SPECIAL_ATTACK,2,battler)
	  battler.pbRaiseStatStageByAbility(:ATTACK,2,battler)
  }
)

BattleHandlers::AbilityOnStatLoss.add(:IMPERIOUS,
  proc { |ability,battler,stat,user|
    next if user && !user.opposes?(battler)
    battler.pbRaiseStatStageByAbility(:SPEED,2,battler)
  }
)

#===============================================================================
# OnBerryConsumed handlers
#===============================================================================
BattleHandlers::OnBerryConsumedAbility.add(:ROAST,
  proc { |ability,user,berry,own_item,battle|
    next if !user.pbCanRaiseStatStage?(:ATTACK,user) && !user.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user)
    battle.pbShowAbilitySplash(user)
    user.pbRaiseStatStage(:ATTACK,1,user) if user.pbCanRaiseStatStage?(:ATTACK,user)
    user.pbRaiseStatStage(:SPECIAL_ATTACK,1,user) if user.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user)
    battle.pbHideAbilitySplash(user)
  }
)

#===============================================================================
# Other handlers
#==============================================================================
BattleHandlers::EORWeatherAbility.add(:HEATSAVOR,
  proc { |ability,weather,battler,battle|
    next if ![:Sun, :HarshSun].include?(weather)
    next if !battler.canHeal?
    battle.pbShowAbilitySplash(battler)
    healAmount = battler.totalhp / 16.0
    healAmount /= BOSS_HP_BASED_EFFECT_RESISTANCE.to_f if battler.boss?
    healingMessage = battle.pbDisplay(_INTL("{1} soaks up the heat.",battler.pbThis))
    battler.pbRecoverHP(healAmount,true,true,true,healingMessage)
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::EORWeatherAbility.add(:FINESUGAR,
  proc { |ability,weather,battler,battle|
    case weather
    when :Rain, :HeavyRain
      battle.pbShowAbilitySplash(battler)
      battle.pbDisplay(_INTL("{1} was hurt by the rain!",battler.pbThis))
      battler.applyFractionalDamage(1.0/8.0)
      battle.pbHideAbilitySplash(battler)
    when :Sun, :HarshSun
      next if !battler.canHeal?
      battle.pbShowAbilitySplash(battler)
      healAmount = battler.totalhp / 8.0
      healAmount /= BOSS_HP_BASED_EFFECT_RESISTANCE.to_f if battler.boss?
      healingMessage = battle.pbDisplay(_INTL("{1} caramlizes slightly in the heat.",battler.pbThis))
      battler.pbRecoverHP(healAmount,true,true,true,healingMessage)
      battle.pbHideAbilitySplash(battler)
    end
  }
)

BattleHandlers::DamageCalcUserAllyAbility.add(:POSITIVEOUTLOOK,
  proc { |ability,user,target,move,mults,baseDmg,type|
			mults[:base_damage_multiplier] *= 1.50 	if user.pbHasType?(:ELECTRIC) && move.specialMove?
  }
)

BattleHandlers::DamageCalcTargetAllyAbility.add(:NEGATIVEOUTLOOK,
  proc { |ability,user,target,move,mults,baseDmg,type|
	mults[:final_damage_multiplier] *= (2.0/3.0) if target.pbHasType?(:ELECTRIC) && move.specialMove?
	 }
)

BattleHandlers::MoveImmunityAllyAbility.add(:GARGANTUAN,
  proc { |ability,user,target,move,type,battle,ally|
	condition = false
	condition = user.index!=target.index && move.pbTarget(user).num_targets >1
  next false if !condition
	battle.pbShowAbilitySplash(ally)
	battle.pbDisplay(_INTL("{1} was shielded from {2} by {3}'s huge size!",target.pbThis,move.name,ally.pbThis(false)))
	battle.pbHideAbilitySplash(ally)
	next true
  }
)

BattleHandlers::CriticalCalcTargetAbility.copy(:BATTLEARMOR,:IMPERVIOUS)

BattleHandlers::MoveBaseTypeModifierAbility.add(:FROSTSONG,
  proc { |ability,user,move,type|
    next if !move.soundMove?
    next if !GameData::Type.exists?(:ICE)
    move.powerBoost = true
    next :ICE
  }
)

BattleHandlers::MoveBaseTypeModifierAbility.add(:BLADETRAINED,
  proc { |ability,user,move,type|
    next if !move.slashMove?
    next if !GameData::Type.exists?(:FIGHTING)
    move.powerBoost = true
    next :FIGHTING
  }
)

#===============================================================================
# WeightCalcAbility handlers
#===============================================================================

BattleHandlers::WeightCalcAbility.add(:ROBUST,
  proc { |ability,battler,weight|
    next weight * 2
  }
)