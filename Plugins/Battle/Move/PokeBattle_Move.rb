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

  def pbBaseDamageAI(baseDmg,user,target,skill=100)
    super(baseDmg,user,target)
  end
end