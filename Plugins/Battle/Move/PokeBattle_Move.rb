RAIN_DEBUFF_ACTIVE = true
SUN_DEBUFF_ACTIVE = true

class PokeBattle_Move
	def isEmpowered?; return false; end
  alias empowered? isEmpowered?

  def immuneToRainDebuff?; return false; end
  def immuneToSunDebuff?; return false; end

  def smartSpreadsTargets?; return false; end
  
	def pbAllMissed(user, targets); end # Move effects that occur after all hits if all of them missed

  def pbEffectOnNumHits(user,target,numHits); end   # Move effects that occur after all hits, which base themselves on how many hits landed

  def pbMoveFailedNoSpecial?(user,targets); return false; end # Check if the move should fail, specifically if its not being specifically used (e.g. Dancer)
  
  # Checks whether the move should have modified priority
	def priorityModification(user,target); return 0; end

  def slashMove?;        return @flags[/p/]; end
  def contactMove?;      return physicalMove? end

  def pbTarget(user)
    targetData = GameData::Target.get(@target)
    if damagingMove? && targetData.can_target_one_foe? && user.effects[PBEffects::FlareWitch]
      return GameData::Target.get(:AllNearFoes)
    else
      return targetData
    end
  end

  ########################################################
  ### AI functions
  ########################################################
  def getScore(score,user,target,skill=100)
		return score
	end

  # For moves that want to lie to the AI about their base damage
  # Or avoid side effects of the base damage method
  # Or give an estimate of the base damage when it can't be accurately measured at the point of choosing moves
  def pbBaseDamageAI(baseDmg,user,target,skill=100)
    pbBaseDamage(baseDmg,user,target)
  end

  # Same as the above, but for number of hits
  # Can return a float, for average hit amount on random moves
  def pbNumHitsAI(user,target,skill=100)
    return 1
  end

  def canRemoveItem?(user,target,checkingForAI=false)
    return false if @battle.wildBattle? && user.opposes? && !user.boss   # Wild Pokémon can't knock off, but bosses can
    return false if user.fainted?
    if checkingForAI
      return false if target.substituted?
    else
      return false if target.damageState.unaffected || target.damageState.substitute
    end
    return false if !target.item || target.unlosableItem?(target.item)
    return false if target.shouldAbilityApply?(:STICKYHOLD,checkingForAI) && !@battle.moldBreaker
    return true
  end

  def canStealItem?(user,target,checkingForAI=false)
    return false if !canRemoveItem?(user,target)
    return false if user.item && @battle.trainerBattle?
    return false if user.unlosableItem?(target.item)
    return true
  end

  def hasKOEffect?(user,target); return false; end
end