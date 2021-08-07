#===============================================================================
# Pseudomove for charm damage.
#===============================================================================
class PokeBattle_Charm < PokeBattle_Move
  def initialize(battle,move)
    @battle     = battle
    @realMove   = move
    @id         = 0
    @name       = ""
    @function   = "000"
    @baseDamage = 50
    @type       = nil
    @category   = 1
    @accuracy   = 100
    @pp         = -1
    @target     = 0
    @priority   = 0
    @flags      = ""
    @addlEffect = 0
    @calcType   = nil
    @powerBoost = false
    @snatched   = false
  end

  def physicalMove?(thisType=nil);    return false;  end
  def specialMove?(thisType=nil);     return true; end
  def pbCritialOverride(user,target); return -1;    end
end

class PokeBattle_CharmMove < PokeBattle_Move
  def pbFailsAgainstTarget?(user,target)
    return false if damagingMove?
    return !target.pbCanCharm?(user,true,self)
  end

  def pbEffectAgainstTarget(user,target)
    return if damagingMove?
    target.pbCharm
  end

  def pbAdditionalEffect(user,target)
    return if target.damageState.substitute
    return if !target.pbCanCharm?(user,false,self)
    target.pbCharm
  end
end

#===============================================================================
# Charms the target.
#===============================================================================
class PokeBattle_Move_400 < PokeBattle_CharmMove
	def getScore(score,user,target,skill=100)
	  if target.pbCanCharm?(user,false)
        score += 30
      elsif skill>=PBTrainerAI.mediumSkill
        score = 0 if statusMove?
      end
	  return score
	end
end

#===============================================================================
# Hits thrice.
#===============================================================================
class PokeBattle_Move_500 < PokeBattle_Move
  def multiHitMove?;           return true; end
  def pbNumHits(user,targets); return 3;    end
  end
  
#===============================================================================
# Maximizes accuracy.
#===============================================================================
class PokeBattle_Move_501 < PokeBattle_StatUpMove
  def initialize(battle,move)
    super
    @statUp = [:ACCURACY,12]
  end
  
  def getScore(score,user,target,skill=100)
	score -= (user.stages[:ACCURACY] - 6)*10
	score = 0 if user.statStageAtMax?(:ACCURACY)
	return score
  end
end

#===============================================================================
# User takes recoil damage equal to 2/3 of the damage this move dealt.
# (Head Charge)
#===============================================================================
class PokeBattle_Move_502 < PokeBattle_RecoilMove
  def pbRecoilDamage(user,target)
    return (2.0*target.damageState.totalHPLost/3.0).round
  end
  
  def getScore(score,user,target,skill=100)
	score -= 30
	return score
  end
end

#===============================================================================
# Increases the user's Sp. Atk and Speed by 1 stage each. (Lightning Dance)
#===============================================================================
class PokeBattle_Move_503 < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:SPECIAL_ATTACK,1,:SPEED,1]
  end
end

#===============================================================================
# Increases the move's power by 25% if the target moved this round. (Rootwrack)
#===============================================================================
class PokeBattle_Move_504 < PokeBattle_Move
  def pbBaseDamage(baseDmg,user,target)
    if @battle.choices[target.index][0]!=:None &&
       ((@battle.choices[target.index][0]!=:UseMove &&
       @battle.choices[target.index][0]!=:Shift) || target.movedThisRound?)
      baseDmg *= 1.25
    end
    return baseDmg
  end
  
  def getScore(score,user,target,skill=100)
	return getWantsToBeSlowerScore(score,user,target,skill,2)
  end
end


#===============================================================================
# Target moves immediately after the user, ignoring priority/speed. (Kickstart)
#===============================================================================
class PokeBattle_Move_505 < PokeBattle_Move
  def ignoresSubstitute?(user); return true; end

  def pbFailsAgainstTarget?(user,target)
    # Target has already moved this round
    return true if pbMoveFailedTargetAlreadyMoved?(target)
    # Target was going to move next anyway (somehow)
    if target.effects[PBEffects::MoveNext]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    # Target didn't choose to use a move this round
    oppMove = @battle.choices[target.index][2]
    if !oppMove || oppMove.id<=0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    target.effects[PBEffects::MoveNext] = true
    target.effects[PBEffects::Quash]    = 0
    @battle.pbDisplay(_INTL("{1} was kickstarted into action!",target.pbThis))
  end
  
  def getScore(score,user,target,skill=100)
    if skill>=PBTrainerAI.mediumSkill
		if !target.opposes? # Targeting a player's pokemon
		    # If damage looks like its going to kill the enemy, allow the move, otherwise don't
			damage = @battle.battleAI.pbRoughDamage(self,user,target,skill,baseDamage)
			score = damage >= target.hp ? 150 : 0
		else
			# If damage looks like its going to kill or mostly kill the ally, don't allow the move
			damage = @battle.battleAI.pbRoughDamage(self,user,target,skill,baseDamage)
			return 0 if damage >= target.hp * 0.8
			score += target.level*4
			score -= pbRoughStat(target,:SPEED,skill) * 2
		end
	end
	return score
  end
end

#===============================================================================
# Target's Special Defense is used instead of its Defense for this move's
# calculations. (Soul Claw, Soul Rip)
#===============================================================================
class PokeBattle_Move_506 < PokeBattle_Move
  def pbGetDefenseStats(user,target)
    return target.spdef, target.stages[:SPECIAL_DEFENSE]+6
  end
end


#===============================================================================
# Lowers the target's Sp. Def. Effectiveness against Steel-type is 2x. (Corrode)
#===============================================================================
class PokeBattle_Move_507 < PokeBattle_TargetStatDownMove
  def initialize(battle,move)
    super
    @statDown = [:SPECIAL_DEFENSE,1]
  end
  
  def pbCalcTypeModSingle(moveType,defType,user,target)
    return Effectiveness::SUPER_EFFECTIVE_ONE if defType == :STEEL
    return super
  end
end


#===============================================================================
# Recoil and freeze chance move. (Crystal Crush)
#===============================================================================
class PokeBattle_Move_508 < PokeBattle_RecoilMove
  def pbRecoilDamage(user,target)
    return (target.damageState.totalHPLost/3.0).round
  end

  def pbAdditionalEffect(user,target)
    return if target.damageState.substitute
    target.pbFreeze(user) if target.pbCanFreeze?(user,false,self)
  end
  
  def getScore(score,user,target,skill=100)
	return getFreezeMoveScore(score,user,target,skill=100) - 30
  end
end

#===============================================================================
# This move ignores target's Defense, Special Defense and evasion stat changes.
# It also ignores their abilities. (Shred)
#===============================================================================
class PokeBattle_Move_509 < PokeBattle_Move
  def pbChangeUsageCounters(user,specialUsage)
    super
    @battle.moldBreaker = true if !specialUsage
  end
  
  def pbCalcAccuracyMultipliers(user,target,multipliers)
    super
    modifiers[EVA_STAGE] = 0   # Accuracy stat stage
  end

  def pbGetDefenseStats(user,target)
    ret1, _ret2 = super
    return ret1, 6   # Def/SpDef stat stage
  end
  
  def getScore(score,user,target,skill=100)
	score += target.stages[:DEFENSE] * 10 if physicalMove?
	score += target.stages[:SPECIAL_DEFENSE] * 10 if specialMove?
	score += target.stages[:EVASION] * 10
	return score
  end
end

#===============================================================================
# Burns or poisons the target, whichever hits the target's better base stat.
# (Crippling Breath)
#===============================================================================
class PokeBattle_Move_50A < PokeBattle_Move
  def pbAdditionalEffect(user,target)
    return if target.damageState.substitute
    if target.attack > target.spatk
      target.pbBurn(user) if target.pbCanBurn?(user,false,self)
    else
      target.pbPoison(user) if target.pbCanPoison?(user,false,self)
    end
  end
  
  def getScore(score,user,target,skill=100)
	score += target.pbCanBurn?(user,false,self) ? 20 : -20
	score += target.pbCanPoison?(user,false,self) ? 20 : -20
	return score
  end
end

#===============================================================================
# If this move KO's the target, increases the user's Sp. Atk by 3 stages.
# (Slight)
#===============================================================================
class PokeBattle_Move_50B < PokeBattle_Move
  def pbEffectAfterAllHits(user,target)
    return if !target.damageState.fainted
    return if !user.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user,self)
    user.pbRaiseStatStage(:SPECIAL_ATTACK,3,user)
  end
  
  def getScore(score,user,target,skill=100)
	score += 20 if !user.statStageAtMax?(:SPECIAL_ATTACK) && target.hp<=target.totalhp/4
	return score
  end
end

#===============================================================================
# Power is doubled if the target is chilled. (Frostbite)
#===============================================================================
class PokeBattle_Move_50C < PokeBattle_Move
  def pbBaseDamage(baseDmg,user,target)
    if target.frozen? &&
       (target.effects[PBEffects::Substitute]==0 || ignoresSubstitute?(user))
      baseDmg *= 2
    end
    return baseDmg
  end
end

#===============================================================================
# Accuracy perfect against poisoned targets. (Sludge Slam)
#===============================================================================
class PokeBattle_Move_50D < PokeBattle_Move
  def pbBaseAccuracy(user,target)
    return 0 if target.poisoned?
    return super
  end
end

#===============================================================================
# Power is doubled if the target is burned. (Flare Up)
#===============================================================================
class PokeBattle_Move_50E < PokeBattle_Move
  def pbBaseDamage(baseDmg,user,target)
    if target.burned? &&
       (target.effects[PBEffects::Substitute]==0 || ignoresSubstitute?(user))
      baseDmg *= 2
    end
    return baseDmg
  end
end

#===============================================================================
# Decreases the user's Attack by 2 stages. (Infinite Force)
#===============================================================================
class PokeBattle_Move_50F < PokeBattle_StatDownMove
  def initialize(battle,move)
    super
    @statDown = [:ATTACK,2]
  end
  
  def getScore(score,user,target,skill=100)
	return score + user.stages[:ATTACK]*10
  end
end

#===============================================================================
# User loses one third of their hp in recoil. (Shred Shot, Shards)
#===============================================================================
class PokeBattle_Move_511 < PokeBattle_Move
	def pbEffectAfterAllHits(user,target)
		return if target.damageState.unaffected
		return if !user.takesIndirectDamage?
		amt = (user.hp / 3).ceil
		user.pbReduceHP(amt,false)
		@battle.pbDisplay(_INTL("{1} loses one third of its health in recoil!",user.pbThis))
		user.pbItemHPHealCheck
	end
	
	def getScore(score,user,target,skill=100)
		score += 30 - ((user.hp.to_f / user.totalhp.to_f) * 80).floor
		return score
	end
end

#===============================================================================
# Increases the user's Attack and Sp. Def by 1 stage each. (Flow State)
#===============================================================================
class PokeBattle_Move_512 < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:ATTACK,1,:SPECIAL_DEFENSE,1]
  end
end

#===============================================================================
# Increases the user's Sp. Atk and Sp. Def by 1 stage each. (Vanguard)
#===============================================================================
class PokeBattle_Move_513 < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:SPECIAL_ATTACK,1,:DEFENSE,1]
  end
end

#===============================================================================
# Poison's the user, even if normally immune to poison. (Grime Grapple)
#===============================================================================
class PokeBattle_Move_514 < PokeBattle_Move
  def pbEffectAfterAllHits(user,target)
    return if target.damageState.unaffected
	user.pbPoison(nil, _INTL("{1} is poisoned by the grime! Their Sp. Atk is reduced!",
       user.pbThis),false)
  end
  
  def getScore(score,user,target,skill=100)
	score -= ((user.hp.to_f / user.totalhp.to_f) * 40).floor
	if [:LUMBERRY,:PECHABERRY].include?(user.item) || user.hasActiveAbility?(:IMMUNITY) || user.hasActiveAbility?(:POISONHEAL) || user.hasActiveAbility?(:GUTS) || user.hasActiveAbility?(:AUDACITY)
		score += 60
	end
	return score
  end
end

#===============================================================================
# The user is immune to secondary effects of moves against them until their next attack. (Enlightened Hit)
#===============================================================================
class PokeBattle_Move_515 < PokeBattle_Move
  def pbEffectAfterAllHits(user,target)
    return if target.damageState.unaffected
	user.effects[PBEffects::Enlightened] = true
  end
end


#===============================================================================
# Burns opposing Pokemon that have increased their stats. (Burning Jealousy)
#===============================================================================
class PokeBattle_Move_516 < PokeBattle_Move
  def statStagesUp?(target)
	return target.stages[:ATTACK] > 0 || target.stages[:DEFENSE] > 0 || target.stages[:SPEED] > 0 || target.stages[:SPECIAL_ATTACK] > 0 || target.stages[:SPECIAL_DEFENSE] > 0 || target.stages[:ACCURACY] > 0 || target.stages[:EVASION] > 0
  end

  def pbAdditionalEffect(user,target)
    return if target.damageState.substitute
    if target.pbCanBurn?(user,false,self) && statStagesUp?(target)
      target.pbBurn(user)
    end
  end
  
  def getScore(score,user,target,skill=100)
    score -= 20
	score += 50 if statStagesUp?(target) && target.pbCanBurn?(user,false,self)
	return score
  end
end

#===============================================================================
# Priority against Pokemon with half or less health. (Aqua Instinct)
#===============================================================================
class PokeBattle_Move_517 < PokeBattle_Move
	def priorityModification(user,targets);
		targets.each do |b|
			return 1 if b.hp.to_f < b.totalhp.to_f/2
		end
		return 0
	end
	
	def getScore(score,user,target,skill=100)
		score -= 20
		score += 50 if target.hp < target.totalhp/2
		return score
    end
end

#===============================================================================
# Heals user by 1/3 of their max health, but does not fail at full health. (Douse)
#===============================================================================
class PokeBattle_Move_518 < PokeBattle_HealingMove
  def pbOnStartUse(user,targets)
    @healAmount = (user.totalhp*1/3.0).round
  end
  
  def pbMoveFailed?(user,targets)
    return false
  end

  def pbHealAmount(user)
    return @healAmount
  end
  
  def getScore(score,user,target,skill=100)
		score -= 20
		score += 40 if user.hp < user.totalhp
		score += 40 if user.hp < user.totalhp/2.0
		return score
  end
end

#===============================================================================
# Decreases the user's Speed and Defense by 1 stage each. Can't miss. (Reflex Overdrive)
#===============================================================================
class PokeBattle_Move_519 < PokeBattle_StatDownMove
  def initialize(battle,move)
    super
    @statDown = [:SPEED,1,:DEFENSE,1]
  end
  
  def pbAccuracyCheck(user,target); return true; end
  
  def getScore(score,user,target,skill=100)
	score += user.stages[:SPEED]*5
	score += user.stages[:DEFENSE]*5
	score += 40 if user.stages[:ACCURACY] < 0
	score += 40 if target.stages[:EVASION] > 0
	return score
  end
end

#===============================================================================
# Badly poisons the target. Heals for 1/3 the damage dealt. (Venom Leech)
#===============================================================================
class PokeBattle_Move_51A < PokeBattle_PoisonMove
  def healingMove?; return Settings::MECHANICS_GENERATION >= 6; end

  def initialize(battle,move)
    super
    @toxic = true
  end
  
  def pbEffectAgainstTarget(user,target)
    return if target.damageState.hpLost<=0
    hpGain = (target.damageState.hpLost/3.0).round
    user.pbRecoverHPFromDrain(hpGain,target)
  end
  
  def getScore(score,user,target,skill=100)
    score -= 40 if target.pbCanPoison?(user,false)
	score += 40 if user.hp < user.totalhp/2.0
	return score
  end
end

#===============================================================================
# User loses their Ice type. Fails if user is not Ice-type. (Cold Conversion)
#===============================================================================
class PokeBattle_Move_51B < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if !user.pbHasType?(:ICE)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectAfterAllHits(user,target)
    if !user.effects[PBEffects::ColdConversion]
      user.effects[PBEffects::ColdConversion] = true
      @battle.pbDisplay(_INTL("{1} lost its cold!",user.pbThis))
    end
  end
  
  def getScore(score,user,target,skill=100)
    score = 0 if !user.pbHasType?(:ICE)
	return score
  end
end

#===============================================================================
# Heals user by half, then raises both Attack and Sp. Atk if still unhealed fully. (Dragon Blood)
#===============================================================================
class PokeBattle_Move_51C < PokeBattle_HealingMove
  def pbHealAmount(user)
    return(user.totalhp/2.0).round
  end
  
  def pbEffectGeneral(user)
    amt = pbHealAmount(user)
    user.pbRecoverHP(amt)
    @battle.pbDisplay(_INTL("{1}'s HP was restored.",user.pbThis))
	if user.hp < user.totalhp
		if user.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user,self)
			user.pbRaiseStatStage(:SPECIAL_ATTACK,1,user)
		end
		if user.pbCanRaiseStatStage?(:ATTACK,user,self)
			user.pbRaiseStatStage(:ATTACK,1,user)
		end
	end
  end
  
  def getScore(score,user,target,skill=100)
	score += 40 if user.hp < 2*user.totalhp/3
    score += 40 if user.hp < user.totalhp/2
	return score
  end
end

#===============================================================================
# Target gains a weakness to Bug-type attacks. (Creep Out)
#===============================================================================
class PokeBattle_Move_51D < PokeBattle_Move
	def pbFailsAgainstTarget?(user,target)
		if target.effects[PBEffects::CreepOut]
		  @battle.pbDisplay(_INTL("The target is already afraid of bug type moves!"))
		  return true
		end
		return false
	  end

  def pbEffectAgainstTarget(user,target)
    target.effects[PBEffects::CreepOut] = true
    @battle.pbDisplay(_INTL("{1} is now afraid of bug type moves!",target.pbThis))
  end
  
  def getScore(score,user,target,skill=100)
	score += 20 if target.hp > target.totalhp/2
	score += 20 if user.hp > user.totalhp/2
	score = 0 if target.effects[PBEffects::CreepOut]
	return score
  end
end

#===============================================================================
# If the move misses, the user gains 2 stages of speed. (Mudslide)
#===============================================================================
class PokeBattle_Move_51E < PokeBattle_Move
	#This method is called if a move fails to hit all of its targets
	def pbCrashDamage(user)
		@battle.pbDisplay(_INTL("{1} kept going and picked up speed!",user.pbThis))
		if user.pbCanRaiseStatStage?(:SPEED,user,self)
			user.pbRaiseStatStage(:SPEED,2,user)
		end
	end
	
	def getScore(score,user,target,skill=100)
		score -= user.stages[:SPEED] * 10
		return score
	end
end


#===============================================================================
# If the move misses, the user gains Special Attack and Accuracy. (Rockapult)
#===============================================================================
class PokeBattle_Move_51F < PokeBattle_Move
	#This method is called if a move fails to hit all of its targets
	def pbCrashDamage(user)
		@battle.pbDisplay(_INTL("{1} adjusts its aim!",user.pbThis))
		@statUp = [:SPECIAL_ATTACK,1,:ACCURACY,1]
		showAnim = true
		for i in 0...@statUp.length/2
		  next if !user.pbCanRaiseStatStage?(@statUp[i*2],user,self)
		  if user.pbRaiseStatStage(@statUp[i*2],@statUp[i*2+1],user,showAnim)
			showAnim = false
		  end
		end
	end
	
	def getScore(score,user,target,skill=100)
		score += 20
		score -= user.stages[:SPEED] * 10
		return score
	end
end

#===============================================================================
# Increases the user's critical hit rate. (Starfall)
#===============================================================================
class PokeBattle_Move_520 < PokeBattle_Move
  def pbEffectGeneral(user)
	if !user.effects[PBEffects::LuckyStar]
		user.effects[PBEffects::LuckyStar] = true
		@battle.pbDisplay(_INTL("{1} is blessed by the lucky star!",user.pbThis))
    end
  end
  
  def getScore(score,user,target,skill=100)
	score += 30
	score -= 60 if user.effects[PBEffects::LuckyStar]
	return score
  end
end

#===============================================================================
# Target's last move used loses 4 PP. (Spiteful Chant, Eerie Spell)
#===============================================================================
class PokeBattle_Move_521 < PokeBattle_Move
  def ignoresSubstitute?(user); return true; end

  def pbEffectAgainstTarget(user,target)
    target.eachMove do |m|
      next if m.id!=target.lastRegularMoveUsed
      reduction = [4,m.pp].min
      target.pbSetPP(m,m.pp-reduction)
      @battle.pbDisplay(_INTL("It reduced the PP of {1}'s {2} by {3}!",
         target.pbThis(true),m.name,reduction))
      break
    end
  end
end

#===============================================================================
# Target's highest move is drastically reduced. (Dragon Roar)
#===============================================================================
class PokeBattle_Move_522 < PokeBattle_TargetMultiStatDownMove
  def pbFailsAgainstTarget?(user,target)
    @statArray = []
    GameData::Stat.each_battle do |s|
      @statArray.push(s.id) if target.pbCanLowerStatStage?(s.id,user,self)
    end
    if @statArray.length==0
      @battle.pbDisplay(_INTL("{1}'s stats won't go any lower!",target.pbThis))
      return true
    end
    return false
  end
  
  def pbEffectAgainstTarget(user,target)
	stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
	stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
	bestStat = :ATTACK
	bestStatValue = -100
    GameData::Stat.each_battle do |s|
      next if !target.pbCanLowerStatStage?(s.id,user,self)
	  baseStat      = target.plainStats[s.id]
	  statStage		= target.stages[s.id]+6
	  statValue = (baseStat.to_f*stageMul[statStage]/stageDiv[statStage]).floor
	  if statValue > bestStatValue
		bestStatValue = statValue
		bestStat = s.id
	  end
    end
	
    target.pbLowerStatStage(bestStat,2,user)
  end
end

#===============================================================================
# Move disables self. (Phantom Break)
#===============================================================================
class PokeBattle_Move_523 < PokeBattle_Move
	def pbEffectAfterAllHits(user,target)
		user.effects[PBEffects::Disable]     = 5
		user.effects[PBEffects::DisableMove] = user.lastRegularMoveUsed
		@battle.pbDisplay(_INTL("{1}'s {2} was disabled!",user.pbThis,
		   GameData::Move.get(user.lastRegularMoveUsed).name))
		user.pbItemStatusCureCheck
	end
end

#===============================================================================
# Heals the user by 2/3 health. Move disables self. (Stitch Up)
#===============================================================================
class PokeBattle_Move_524 < PokeBattle_HealingMove
	def pbHealAmount(user)
		return (user.totalhp*2.0/3.0).round
	end

	def pbEffectAfterAllHits(user,target)
		user.effects[PBEffects::Disable]     = 5
		user.effects[PBEffects::DisableMove] = user.lastRegularMoveUsed
		@battle.pbDisplay(_INTL("{1}'s {2} was disabled!",user.pbThis,
		   GameData::Move.get(user.lastRegularMoveUsed).name))
		user.pbItemStatusCureCheck
	end
	
	def getScore(score,user,target,skill=100)
		score = 0 if user.hp > user.totalhp/2
		score += 80 if user.hp < user.totalhp/3
		return score
	end
end

#===============================================================================
# Increases the user's Attack, Defense and Speed by 1 stage each.
# (Shiver Dance)
#===============================================================================
class PokeBattle_Move_525 < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:ATTACK,1,:DEFENSE,1,:SPEED,1]
  end
end

#===============================================================================
# Puts the target to sleep. User loses half of their max HP as recoil. (Demon's Kiss)
#===============================================================================
class PokeBattle_Move_526 < PokeBattle_SleepMove
  def pbEffectAgainstTarget(user,target)
    target.pbSleep
	return if !user.takesIndirectDamage?
    return if user.hasActiveAbility?(:ROCKHEAD)
    amt = (user.totalhp/2.0).ceil
    user.pbReduceHP(amt,false)
    @battle.pbDisplay(_INTL("{1} is damaged by recoil!",user.pbThis))
    user.pbItemHPHealCheck
  end
  
    def getScore(score,user,target,skill=100)
		score -= 50 if user.hp <= user.totalhp/2
		score = sleepMoveAI(score,user,target,skill=100)
		return score
	end
end

#===============================================================================
# Puts the target to sleep. Fails unless in sunlight. (Summer Daze)
#===============================================================================
class PokeBattle_Move_527 < PokeBattle_SleepMove
	def pbMoveFailed?(user,targets)
		if @battle.pbWeather != :Sun
			@battle.pbDisplay(_INTL("But it failed!"))
			return true
		end
		return false
	end
	
	def getScore(score,user,target,skill=100)
		score = sleepMoveAI(score,user,target,skill=100)
		if score != 0 && @battle.pbWeather != :Sun
			score = 10
			score = 0 if skill > PBTrainerAI.mediumSkill
		end
		return score
	end
end

#===============================================================================
# Puts the target to sleep. Fails unless the target is at or below half health. (Lullaby)
#===============================================================================
class PokeBattle_Move_528 < PokeBattle_SleepMove
	def pbFailsAgainstTarget?(user,target)
		if target.hp > target.totalhp / 2 || !target.pbCanSleep?(user,true,self)
			@battle.pbDisplay(_INTL("But it failed!"))
			return true
		end
		return false
	end
	
	def getScore(score,user,target,skill=100)
		score = sleepMoveAI(score,user,target,skill=100)
		if score != 0 && target.hp > target.totalhp/2
			score = 10
			score = 0 if skill > PBTrainerAI.mediumSkill
		end
		return score
	end
end

#===============================================================================
# Puts the target to sleep. Fails unless the target dealt damage to the user this turn. (Puff Ball)
#===============================================================================
class PokeBattle_Move_529 < PokeBattle_SleepMove
	def pbFailsAgainstTarget?(user,target)
		if !user.lastAttacker.include?(target.index) || !target.pbCanSleep?(user,true,self)
			@battle.pbDisplay(_INTL("But it failed!"))
			return true
		end
		return false
	end
	
	def getScore(score,user,target,skill=100)
		score = sleepMoveAI(score,user,target,skill)
		score = getWantsToBeSlowerScore(score,user,target,skill,5)
		return score
	end
end

#===============================================================================
# Deals 50% more damage if user is statused. (Hard Feelings, Sore Spot)
#===============================================================================
class PokeBattle_Move_52A < PokeBattle_Move
	def damageReducedByBurn?; return false; end

	def pbBaseDamage(baseDmg,user,target)
		baseDmg *= 1.5 if user.status != :None
		return baseDmg
	end
end

#===============================================================================
# Confuses or charms based on which of the target's attacking stats is higher. (Majestic Glare)
#===============================================================================
class PokeBattle_Move_52B < PokeBattle_Move
	def pbFailsAgainstTarget?(user,target)
    return false if damagingMove?
    if !target.pbCanConfuse?(user,true,self) && !target.pbCanCharm?(user,true,self)
		@battle.pbDisplay(_INTL("But it failed!")) 
		return true
	end
	return false
  end

  def pbEffectAgainstTarget(user,target)
    return if damagingMove?
    confuseOrCharm(target)
  end

  def pbAdditionalEffect(user,target)
    return if target.damageState.substitute
	confuseOrCharm(user,target)
  end
  
  def confuseOrCharm(user,target)
	stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
	stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
	attackStage = target.stages[:ATTACK]+6
	attack = (target.attack.to_f*stageMul[attackStage]/stageDiv[attackStage]).floor
	spAtkStage = target.stages[:SPECIAL_ATTACK]+6
	spAtk = (target.spatk.to_f*stageMul[spAtkStage]/stageDiv[spAtkStage]).floor
	
    if target.pbCanConfuse?(user,false,self) && attack >= spAtk
		target.pbConfuse
	elsif target.pbCanCharm?(user,false,self) && spAtk >= attack
		target.pbCharm
	end
  end
  
  def getScore(score,user,target,skill=100)
		score += target.pbCanConfuse?(user,false) ? 20 : -20
		score += target.pbCanCharm?(user,false) ? 20 : -20
		return score
  end
end

#===============================================================================
# User gains 1/2 the HP it inflicts as damage. Lower's Sp. Def. (Soul Drain)
#===============================================================================
class PokeBattle_Move_52C < PokeBattle_Move
  def healingMove?; return Settings::MECHANICS_GENERATION >= 6; end

  def pbEffectAgainstTarget(user,target)
    return if target.damageState.hpLost<=0
    hpGain = (target.damageState.hpLost*0.5).round
    user.pbRecoverHPFromDrain(hpGain,target)
  end
  
  def pbAdditionalEffect(user,target)
    return if target.damageState.substitute
    return if !target.pbCanLowerStatStage?(:SPECIAL_DEFENSE,user,self)
    target.pbLowerStatStage(:SPECIAL_DEFENSE,1,user)
  end
  
  def getScore(score,user,target,skill=100)
		score += 50 if target.hp > target.totalhp/2
		return score
  end
end

#===============================================================================
# Resets weather and cures all active Pokemon of statuses. (Shadowpass)
#===============================================================================
class PokeBattle_Move_52D < PokeBattle_Move
	def pbEffectGeneral(user)
		if @battle.field.weather != :None
			case @battle.field.weather
			  when :Sun       then @battle.pbDisplay(_INTL("The sunlight faded."))
			  when :Rain      then @battle.pbDisplay(_INTL("The rain stopped."))
			  when :Sandstorm then @battle.pbDisplay(_INTL("The sandstorm subsided."))
			  when :Hail      then @battle.pbDisplay(_INTL("The hail stopped."))
			  when :ShadowSky then @battle.pbDisplay(_INTL("The shadow sky faded."))
			  when :HeavyRain then @battle.pbDisplay("The heavy rain has lifted!")
			  when :HarshSun  then @battle.pbDisplay("The harsh sunlight faded!")
			  when :StrongWinds then @battle.pbDisplay("The mysterious air current has dissipated!")
			end
			@battle.field.weather 			= :None
			@battle.field.weatherDuration  = 0
		end
		
		@battle.battlers.each do |b|
			pkmn = b.pokemon
			next if !pkmn || !pkmn.able? || pkmn.status == :NONE
			pbAromatherapyHeal(pkmn)
		end
	end
	
	def pbAromatherapyHeal(pkmn,battler=nil)
		oldStatus = (battler) ? battler.status : pkmn.status
		curedName = (battler) ? battler.pbThis : pkmn.name
		if battler
		  battler.pbCureStatus(false)
		else
		  pkmn.status      = :NONE
		  pkmn.statusCount = 0
		end
		case oldStatus
		when :SLEEP
		  @battle.pbDisplay(_INTL("{1} was woken from sleep.",curedName))
		when :POISON
		  @battle.pbDisplay(_INTL("{1} was cured of its poisoning.",curedName))
		when :BURN
		  @battle.pbDisplay(_INTL("{1}'s burn was healed.",curedName))
		when :PARALYSIS
		  @battle.pbDisplay(_INTL("{1} was cured of paralysis.",curedName))
		when :FROZEN
		  @battle.pbDisplay(_INTL("{1} was unchilled.",curedName))
    end
  end
  
  def getScore(score,user,target,skill=100)
		score -= 50 if @battle.field.weather == :None
		@battle.battlers.each do |b|
			pkmn = b.pokemon
			next if !pkmn || !pkmn.able? || pkmn.status == :NONE
			score += b.opposes? ? 20 : -20 
		end
		return score
  end
end

#===============================================================================
# Lowers the target's Defense and Evasion by 2. (Echolocate)
#===============================================================================
class PokeBattle_Move_52E < PokeBattle_TargetMultiStatDownMove
  def initialize(battle,move)
    super
    @statDown = [:DEFENSE,2,:EVASION,2]
  end
  def pbAccuracyCheck(user,target); return true; end
  
  def getScore(score,user,target,skill=100)
		score -= 50
		score += target.stages[:EVASION] * 20
		score += target.stages[:DEFENSE] * 20
		return score
  end
end

#===============================================================================
# Resets weather and reduces the Attack of all enemies. (Wingspan Eclipse)
#===============================================================================
class PokeBattle_Move_52F < PokeBattle_Move_042
	def pbEffectGeneral(user)
		if @battle.field.weather != :None
			case @battle.field.weather
			  when :Sun       then @battle.pbDisplay(_INTL("The sunlight faded."))
			  when :Rain      then @battle.pbDisplay(_INTL("The rain stopped."))
			  when :Sandstorm then @battle.pbDisplay(_INTL("The sandstorm subsided."))
			  when :Hail      then @battle.pbDisplay(_INTL("The hail stopped."))
			  when :ShadowSky then @battle.pbDisplay(_INTL("The shadow sky faded."))
			  when :HeavyRain then @battle.pbDisplay("The heavy rain has lifted!")
			  when :HarshSun  then @battle.pbDisplay("The harsh sunlight faded!")
			  when :StrongWinds then @battle.pbDisplay("The mysterious air current has dissipated!")
			end
			@battle.field.weather 			= :None
			@battle.field.weatherDuration  = 0
		end
	end
	
	def getScore(score,user,target,skill=100)
		score -= 50 if @battle.field.weather = :None
		@battle.battlers.each do |b|
			pkmn = b.pokemon
			next if !pkmn || !pkmn.able? || b.opposes?
			score += b.stages[:ATTACK] * 10
		end
		return score
	end
end

#===============================================================================
# Raises Attack of user and team (new!Howl)
#===============================================================================
class PokeBattle_Move_530 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    return false if damagingMove?
	failed = true
	@battle.eachSameSideBattler(user) do |b|
      next if !b.pbCanRaiseStatStage?(:ATTACK,user,self,true)
      failed = false
      break
    end
	@battle.pbDisplay(_INTL("But it failed!")) if failed
    return failed
  end

  def pbEffectGeneral(user)
    @battle.eachSameSideBattler(user) do |b|
        next if !b.pbCanRaiseStatStage?(:ATTACK,user,self,true)
        b.pbRaiseStatStage(:ATTACK,1,user)
    end
  end
  
	def getScore(score,user,target,skill=100)
		@battle.battlers.each do |b|
			pkmn = b.pokemon
			next if !pkmn || !pkmn.able? || !b.opposes?
			score -= b.stages[:ATTACK] * 10
		end
		return score
	end
end

#===============================================================================
# User takes half damage from Super Effective moves. (Inure)
#===============================================================================
class PokeBattle_Move_531 < PokeBattle_Move
	def pbMoveFailed?(user,targets)
		return false if damagingMove?
		if user.effects[PBEffects::Inured]
			@battle.pbDisplay(_INTL("But it failed!"))
			return true
		end
		return false
    end
	
	def pbEffectGeneral(user)
		user.effects[PBEffects::Inured] = true
	end
	
	def getScore(score,user,target,skill=100)
		score += 50 if user.turnCount == 0
		score = 0 if user.effects[PBEffects::Inured]
		return score
	end
end

#===============================================================================
# Raises worst stat two stages, second worst stat by one stage. (Breakdance)
#===============================================================================
class PokeBattle_Move_532 < PokeBattle_Move
	def pbFailsAgainstTarget?(user,target)
		@statArray = []
		GameData::Stat.each_battle do |s|
		  @statArray.push(s.id) if user.pbCanRaiseStatStage?(s.id,user,self)
		end
		if @statArray.length==0
		  @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",user.pbThis))
		  return true
		end
		return false
	end
	
	def pbEffectAgainstTarget(user,target)
		stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
		stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
		statsRanked = [:ATTACK,:DEFENSE,:SPECIAL_ATTACK,:SPECIAL_DEFENSE,:SPEED]
		statsRanked.sort_by { |s| (user.attack.to_f*stageMul[user.stages[s]]/stageDiv[user.stages[s]]).floor }
		target.pbRaiseStatStage(statsRanked[0],2,user)
		target.pbRaiseStatStage(statsRanked[1],1,user)
	end
	
	def getScore(score,user,target,skill=100)
		score += 50 if user.turnCount == 0
		stats = [:ATTACK,:DEFENSE,:SPECIAL_ATTACK,:SPECIAL_DEFENSE,:SPEED]
		stats.each do |s|
			score -= user.stages[s] * 5
		end
		return score
	end
end


#===============================================================================
# Puts the target to sleep. Fails unless the target is charmed or confused. (Pacify)
#===============================================================================
class PokeBattle_Move_534 < PokeBattle_SleepMove
	def pbFailsAgainstTarget?(user,target)
		if target.effects[PBEffects::Confusion] == 0 && target.effects[PBEffects::Charm] == 0
			@battle.pbDisplay(_INTL("But it failed!"))
			return true
		end
		return false
	end
	
	def pbEffectAgainstTarget(user,target)
		target.pbCureConfusion
		target.pbCureCharm
		target.pbSleep
	end
	
	def getScore(score,user,target,skill=100)
		score = sleepMoveAI(score,user,target,skill=100)
		if target.effects[PBEffects::Confusion] == 0 && target.effects[PBEffects::Charm] == 0
			score = 10
			score = 0 if skill>PBTrainerAI.mediumSkill
		end
		return score
	end
end

#===============================================================================
# Can only be used on the first turn. Deals more damage if the user was hurt this turn. (Stare Down)
#===============================================================================
class PokeBattle_Move535 < PokeBattle_Move
	def pbMoveFailed?(user,targets)
		if user.turnCount > 1
			@battle.pbDisplay(_INTL("But it failed!"))
			return true
		end
		return false
	end
	
	def pbBaseDamage(baseDmg,user,target)
		baseDmg *= 2 if user.lastAttacker.include?(target.index)
		return baseDmg
	end
	
	def getScore(score,user,target,skill=100)
		score += 50
		score = getWantsToBeSlowerScore(score,user,target,skill=100,1)
		score = 0 if user.turnCount != 0
		return score
	end
end
#===============================================================================
# Two turn attack. Ups user's Special Defense by 2 stage first turn, attacks second turn.
# (Zephyr Wing)
#===============================================================================
class PokeBattle_Move_536 < PokeBattle_TwoTurnMove
  def pbChargingTurnMessage(user,targets)
    @battle.pbDisplay(_INTL("{1}'s wings start glowing!",user.pbThis))
  end

  def pbChargingTurnEffect(user,target)
    if user.pbCanRaiseStatStage?(:SPECIAL_DEFENSE,user,self)
      user.pbRaiseStatStage(:SPECIAL_DEFENSE,1,user)
    end
  end
  
  def getScore(score,user,target,skill=100)
		score += user.hp > user.totalhp/2 ? 50 : -50
		return score
  end
end

#===============================================================================
# User takes recoil damage equal to 1/5 of the damage this move dealt.
#===============================================================================
class PokeBattle_Move_537 < PokeBattle_RecoilMove
  def pbRecoilDamage(user,target)
    return (target.damageState.totalHPLost/5.0).round
  end
  
  def getScore(score,user,target,skill=100)
		return score - 10
  end
end

#===============================================================================
# Removes all Terrain. Does not fail if there is no Terrain (Terraform)
#===============================================================================
class PokeBattle_Move_538 < PokeBattle_Move
  def pbEffectGeneral(user)
    case @battle.field.terrain
      when :Electric
        @battle.pbDisplay(_INTL("The electric current disappeared from the battlefield!"))
      when :Grassy
        @battle.pbDisplay(_INTL("The grass disappeared from the battlefield!"))
      when :Misty
        @battle.pbDisplay(_INTL("The mist disappeared from the battlefield!"))
      when :Psychic
        @battle.pbDisplay(_INTL("The weirdness disappeared from the battlefield!"))
    end
    @battle.pbStartTerrain(user,:None,true)
  end
  
  def getScore(score,user,target,skill=100)
		score += @battle.field.terrain != :None ? 30 : -30
		return score
  end
end

#===============================================================================
# Steals the targets item if its a berry or gem. (Pilfer)
#===============================================================================
class PokeBattle_Move_539 < PokeBattle_Move
  def pbEffectAfterAllHits(user,target)
    return if @battle.wildBattle? && !user.boss   # Wild Pokémon can't thieve, except if they are bosses
    return if user.fainted?
    return if target.damageState.unaffected || target.damageState.substitute
    return if !target.item || user.item
    return if target.unlosableItem?(target.item)
    return if user.unlosableItem?(target.item)
    return if target.hasActiveAbility?(:STICKYHOLD) && !@battle.moldBreaker
	return if !item.is_berry? && !item.is_gem?
    itemName = target.itemName
    user.item = target.item
    # Permanently steal the item from wild Pokémon
    if @battle.wildBattle? && target.opposes? &&
       target.initialItem==target.item && !user.initialItem
      user.setInitialItem(target.item)
      target.pbRemoveItem
    else
      target.pbRemoveItem(false)
    end
    @battle.pbDisplay(_INTL("{1} stole {2}'s {3}!",user.pbThis,target.pbThis(true),itemName))
    user.pbHeldItemTriggerCheck
  end
end

#===============================================================================
# If the target would heal until end of turn, instead they take that much life loss. (Nerve Break)
#===============================================================================
class PokeBattle_Move_53A < PokeBattle_Move
  def pbAdditionalEffect(user,target)
    return if target.fainted? || target.damageState.substitute
	return if target.effects[PBEffects::NerveBreak]
	target.effects[PBEffects::NerveBreak] = true
  end
  
  def getScore(score,user,target,skill=100)
		score -= 30
		score += (target.totalhp - target.hp)/target.level
		return score
  end
end

#===============================================================================
# Deals 50% more damage if faster than the target. Then lower's user's speed. (Nerve Break)
#===============================================================================
class PokeBattle_Move_53B < PokeBattle_StatDownMove
  def initialize(battle,move)
    super
    @statDown = [:SPEED,1]
  end
  
  def pbModifyDamage(damageMult,user,target)
    damageMult *= 1.5 if user.pbSpeed > target.pbSpeed
    return damageMult
  end
end


#===============================================================================
# Can't miss if attacking a target that already hit you this turn. (new!Power Whip)
#===============================================================================
class PokeBattle_Move_53C < PokeBattle_Move
    def pbAccuracyCheck(user,target)
	if @battle.choices[target.index][0]!=:None &&
       ((@battle.choices[target.index][0]!=:UseMove &&
       @battle.choices[target.index][0]!=:Shift) || target.movedThisRound?)
      return true
    end
	return super
  end
  
  def getScore(score,user,target,skill=100)
	return getWantsToBeSlowerScore(score,user,target,skill,2)
  end
end

#===============================================================================
# Heals user by 1/8 of their max health, but does not fail at full health. (Mending Spring)
#===============================================================================
class PokeBattle_Move_53D < PokeBattle_HealingMove
  def pbOnStartUse(user,targets)
    @healAmount = (user.totalhp*1/8.0).round
  end
  
  def pbMoveFailed?(user,targets)
    return false
  end

  def pbHealAmount(user)
    return @healAmount
  end
  
  def getScore(score,user,target,skill=100)
		score -= 10
		score += 20 if user.hp < user.totalhp
		score += 20 if user.hp < user.totalhp/2.0
		return score
  end
end