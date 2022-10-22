module BattleHandlers
	PriorityChangeAbility				= AbilityHandlerHash.new
	AbilityOnEnemySwitchIn              = AbilityHandlerHash.new
	MoveImmunityAllyAbility           	= AbilityHandlerHash.new
    OnBerryConsumedAbility           	= AbilityHandlerHash.new

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

	def self.triggerPriorityChangeAbility(ability,battler,move,pri,targets=[])
		ret = PriorityChangeAbility.trigger(ability,battler,move,pri,targets)
		return (ret!=nil) ? ret : pri
	end
end

# For abilities that grant immunity to moves of a particular type, and heals the
# ability's bearer by 1/4 of its total HP instead.
def pbBattleMoveImmunityHealAbility(user,target,move,moveType,immuneType,battle)
	return false if user.index==target.index
	return false if moveType != immuneType
	battle.pbShowAbilitySplash(target)
	healAmount = target.totalhp / 4.0
	healAmount /= BOSS_HP_BASED_EFFECT_RESISTANCE.to_f if target.boss?
	if !target.canHeal? || target.pbRecoverHP(healAmount) <= 0
	  battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!", target.pbThis,target.abilityName,move.name))
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
    battle.pbStartWeather(battler,weather,4)
    # NOTE: The ability splash is hidden again in def pbStartWeather.
end