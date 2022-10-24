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

# For abilities that grant immunity to moves of a particular type, and raises
# one of the ability's bearer's stats instead.
def pbBattleMoveImmunityStatAbility(user,target,move,moveType,immuneType,stat,increment,battle)
	return false if user.index==target.index
	return false if moveType != immuneType
	battle.pbShowAbilitySplash(target)
	if target.pbCanRaiseStatStage?(stat,target)
	  target.pbRaiseStatStage(stat,increment,target)
	else
	  battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
	end
	battle.pbHideAbilitySplash(target)
	return true
end

def pbBattleWeatherAbility(weather,battler,battle,ignorePrimal=false)
    return if !ignorePrimal && [:HarshSun, :HeavyRain, :StrongWinds].include?(battle.field.weather)
    battle.pbShowAbilitySplash(battler)
    battle.pbStartWeather(battler,weather,4)
    # NOTE: The ability splash is hidden again in def pbStartWeather.
end

def terrainSetAbility(terrain,battler,battle,ignorePrimal=false)
	return if battle.field.terrain == terrain
	battle.pbShowAbilitySplash(battler)
	battle.pbStartTerrain(battler, terrain)
	# NOTE: The ability splash is hidden again in def pbStartTerrain.
end

def randomStatusProcAbility(status,chance,user,target,move,battle)
	return if battle.pbRandom(100) >= chance
	return if user.pbHasStatus?(status)
	return if move.immuneToAdditionalEffects(user,target,chance)
    battle.pbShowAbilitySplash(user)
    if target.pbCanInflictStatus?(status, user, true, move)
      target.pbInflictStatus(user)
    end
    battle.pbHideAbilitySplash(user)
end