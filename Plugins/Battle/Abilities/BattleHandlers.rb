module BattleHandlers
	AbilityOnEnemySwitchIn              = AbilityHandlerHash.new
	MoveImmunityAllyAbility           	= AbilityHandlerHash.new
    OnBerryConsumedAbility           	  = AbilityHandlerHash.new

	def self.triggerAbilityOnEnemySwitchIn(ability,switcher,bearer,battle)
		AbilityOnEnemySwitchIn.trigger(ability,switcher,bearer,battle)
	end
	
	def self.triggerMoveImmunityAllyAbility(ability,user,target,move,type,battle,ally)
		ret = MoveImmunityAllyAbility.trigger(ability,user,target,move,type,battle,ally)
		return (ret!=nil) ? ret : false
	end

  def self.triggerOnBerryConsumedAbility(ability,user,berry,own_item,battle)
		ret = OnBerryConsumedAbility.trigger(ability,user,berry,own_item,battle)
		return (ret!=nil) ? ret : false
	end
end

# For abilities that grant immunity to moves of a particular type, and heals the
# ability's bearer by 1/4 of its total HP instead.
def pbBattleMoveImmunityHealAbility(user,target,move,moveType,immuneType,battle)
	return false if user.index==target.index
	return false if moveType != immuneType
	battle.pbShowAbilitySplash(target)
	healAmount = target.totalhp / 4.0
	healAmount /= BOSS_HP_BASED_EFFECT_RESISTANCE if target.boss?
	if target.canHeal? && target.pbRecoverHP(healAmount.round) > 0
	  if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
		battle.pbDisplay(_INTL("{1}'s HP was restored.",target.pbThis))
	  else
		battle.pbDisplay(_INTL("{1}'s {2} restored its HP.",target.pbThis,target.abilityName))
	  end
	else
	  if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
		battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
	  else
		battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",
		   target.pbThis,target.abilityName,move.name))
	  end
	end
	battle.pbHideAbilitySplash(target)
	return true
end

def pbBattleWeatherAbility(weather,battler,battle,ignorePrimal=false)
    return if !ignorePrimal && [:HarshSun, :HeavyRain, :StrongWinds].include?(battle.field.weather)
    battle.pbShowAbilitySplash(battler)
    if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1}'s {2} activated!",battler.pbThis,battler.abilityName))
    end
    fixedDuration = ![:HarshSun, :HeavyRain, :StrongWinds].include?(weather)
    battle.pbStartWeather(battler,weather,4)
    # NOTE: The ability splash is hidden again in def pbStartWeather.
end