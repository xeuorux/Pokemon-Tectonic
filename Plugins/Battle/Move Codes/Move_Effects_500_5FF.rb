#===============================================================================
# Hits thrice.
#===============================================================================
class PokeBattle_Move_500 < PokeBattle_Move
  def multiHitMove?;           return true; end
  def pbNumHits(user,targets,checkingForAI=false); return 3;    end
end
  
#===============================================================================
# Maximizes accuracy.
#===============================================================================
class PokeBattle_Move_501 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
	return !user.pbCanRaiseStatStage?(:ACCURACY,user,self,true)
  end

  def pbEffectGeneral(user)
	user.pbMaximizeStatStage(:ACCURACY,user,self)
  end
  
  def getScore(score,user,target,skill=100)
	score -= (user.stages[:ACCURACY] - 6) * 10
	score = 0 if user.statStageAtMax?(:ACCURACY)
	return score
  end
end

#===============================================================================
# User takes recoil damage equal to 2/3 of the damage this move dealt.
# (Head Charge)
#===============================================================================
class PokeBattle_Move_502 < PokeBattle_RecoilMove
	def recoilFactor;  return (2.0/3.0); end
end

#===============================================================================
# Increases the user's Sp. Atk and Speed by 1 stage each. (Lightning Dance)
#===============================================================================
class PokeBattle_Move_503 < PokeBattle_MultiStatUpMove
  def initialize(battle, move)
    super
    @statUp = [:SPECIAL_ATTACK,1,:SPEED,1]
  end
end

#===============================================================================
# Increases the move's power by 25% if the target moved this round. (Rootwrack)
#===============================================================================
class PokeBattle_Move_504 < PokeBattle_Move
  def pbBaseDamage(baseDmg,user,target)
    targetChoice = @battle.choices[target.index][0]
	if targetChoice == :UseMove && target.movedThisRound?
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
  def pbEffectAgainstTarget(user,target)
	return if target.fainted?
    return if pbMoveFailedTargetAlreadyMoved?(target) # Target has already moved this round
    return if target.effectActive?(:MoveNext) # Target was going to move next anyway (somehow)
    return if @battle.choices[target.index][2].nil? # Target didn't choose to use a move this round
    target.applyEffect(:MoveNext)
    @battle.pbDisplay(_INTL("{1} was kickstarted into action!",target.pbThis))
  end
  
  def getScore(score,user,target,skill=100)
	if !target.opposes? # Targeting a player's pokemon
		# If damage looks like its going to kill the enemy, allow the move, otherwise don't
		damage = @battle.battleAI.pbTotalDamageAI(self,user,target,skill,baseDamage)
		score = damage >= target.hp ? 150 : 0
	else
		# If damage looks like its going to kill or mostly kill the ally, don't allow the move
		damage = @battle.battleAI.pbTotalDamageAI(self,user,target,skill,baseDamage)
		return 0 if damage >= target.hp * 0.8
		score += target.level*4
		score -= pbRoughStat(target,:SPEED,skill) * 2
	end
	return score
  end
end

#===============================================================================
# Target's Special Defense is used instead of its Defense for this move's
# calculations. (Soul Claw, Soul Rip)
#===============================================================================
class PokeBattle_Move_506 < PokeBattle_Move
  def pbDefendingStat(user,target)
    return target, :SPECIAL_DEFENSE
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
# (Not currently used)
#===============================================================================
class PokeBattle_Move_508 < PokeBattle_Move
end

#===============================================================================
# This move ignores target's Defense, Special Defense and evasion stat changes.
# It also ignores their abilities. (Rend)
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

  def ignoresDefensiveStageBoosts?(user,target); return true; end
  
  def getScore(score,user,target,skill=100)
	score += target.stages[:DEFENSE] * 10 if physicalMove?
	score += target.stages[:SPECIAL_DEFENSE] * 10 if specialMove?
	score += target.stages[:EVASION] * 10
	return score
  end
end

#===============================================================================
# Burns or frostbites the target, whichever hits the target's better base stat.
# (Crippling Breath)
#===============================================================================
class PokeBattle_Move_50A < PokeBattle_Move
  def pbFailsAgainstTarget?(user,target)
    return false if damagingMove?
    if !target.pbCanBurn?(user,true,self) && !target.pbCanFrostbite?(user,true,self)
		@battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} can neither be burned or frostbitten!")) 
		return true
	end
	return false
  end

  def pbEffectAgainstTarget(user,target)
    return if damagingMove?
    burnOrFrostbite(target)
  end

  def pbAdditionalEffect(user,target)
    return if target.damageState.substitute
	burnOrFrostbite(user,target)
  end
  
  def burnOrFrostbite(user,target)
	real_attack = target.pbAttack
	real_special_attack = target.pbSpAtk
	
    if target.pbCanBurn?(user,false,self) && real_attack >= real_special_attack
		target.pbBurn(user)
	elsif target.pbCanFrostbite?(user,false,self) && real_special_attack >= real_attack
		target.pbFrostbite(user)
	end
  end
  
  def getScore(score,user,target,skill=100)
	score += target.pbCanBurn?(user,false,self) ? 20 : -20
	score += target.pbCanFrostbite?(user,false,self) ? 20 : -20
	return score
  end
end

#===============================================================================
# If this move KO's the target, increases the user's Sp. Atk by 3 stages.
# (Slight)
#===============================================================================
class PokeBattle_Move_50B < PokeBattle_Move
	# Used to modify the AI elsewhere
	def hasKOEffect?(user,target)
		return false if !user.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user,self)
		return true
	end

	def pbEffectAfterAllHits(user,target)
		return if !target.damageState.fainted
		return if !user.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user,self)
		user.pbRaiseStatStage(:SPECIAL_ATTACK,3,user)
	end
end

#===============================================================================
# Power is doubled if the target is frostbitten. (Ice Impact)
#===============================================================================
class PokeBattle_Move_50C < PokeBattle_Move
  def pbBaseDamage(baseDmg,user,target)
    if target.frostbitten?
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
    if target.burned?
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
# User loses half their hp in recoil. (Steel Beam)
#===============================================================================
class PokeBattle_Move_510 < PokeBattle_Move
	def pbEffectAfterAllHits(user,target)
		return if target.damageState.unaffected
		return if !user.takesIndirectDamage?
		@battle.pbDisplay(_INTL("{1} loses half its health in recoil!",user.pbThis))
    	user.applyFractionalDamage(1.0/2.0,true,true)
	end
	
	def getScore(score,user,target,skill=100)
		score += 50 - ((user.hp.to_f / user.totalhp.to_f) * 100).floor
		return score
	end
end

#===============================================================================
# User loses one third of their hp in recoil. (Shred Shot, Shards)
#===============================================================================
class PokeBattle_Move_511 < PokeBattle_Move
	def pbEffectAfterAllHits(user,target)
		return if target.damageState.unaffected
		return if !user.takesIndirectDamage?
		@battle.pbDisplay(_INTL("{1} loses one third of its health in recoil!",user.pbThis))
		user.applyFractionalDamage(1.0/3.0,true,true)
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
	user.pbPoison(nil, _INTL("{1} is poisoned by the grime! {2}",
       user.pbThis,POISONED_EXPLANATION),false)
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
	user.applyEffect(:Enlightened)
  end
end

#===============================================================================
# Burns opposing Pokemon that have increased their stats. (Burning Jealousy)
#===============================================================================
class PokeBattle_Move_516 < PokeBattle_Move
  def pbAdditionalEffect(user,target)
    return if target.damageState.substitute
    if target.pbCanBurn?(user,false,self) && target.hasRaisedStatStages?
      target.pbBurn(user)
    end
  end
  
  def getScore(score,user,target,skill=100)
    score -= 20
	score += 50 if target.hasRaisedStatStages? && target.pbCanBurn?(user,false,self)
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
	def healRatio(user)
		return 1.0/3.0
	end
  
	def pbMoveFailed?(user,targets)
		return false
	end
	
	def getScore(score,user,target,skill=100)
		score = super
		score += 30
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
# For 5 rounds, Pokemon's Attack and Sp. Atk are swapped. (Puzzle Room)
#===============================================================================
class PokeBattle_Move_51A < PokeBattle_RoomMove
	def initialize(battle,move)
		super
		@roomEffect = :PuzzleRoom
	end
end

#===============================================================================
# User loses their Ice type. Fails if user is not Ice-type. (Cold Conversion)
#===============================================================================
class PokeBattle_Move_51B < PokeBattle_Move
	def pbMoveFailed?(user,targets)
		if !user.pbHasType?(:ICE)
		@battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} is not Ice-type!"))
		return true
		end
		return false
	end

	def pbEffectAfterAllHits(user,target)
		user.applyEffect(:ColdConversion)
	end
	
	def getScore(score,user,target,skill=100)
		score -= 20
		return score
	end
end

#===============================================================================
# Heals user by half, then raises both Attack and Sp. Atk if still unhealed fully. (Dragon Blood)
#===============================================================================
class PokeBattle_Move_51C < PokeBattle_HalfHealingMove 
	def pbEffectGeneral(user)
		super
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
		if target.effectActive?(:CreepOut)
		  @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is already afraid of bug type moves!"))
		  return true
		end
		return false
	end

	def pbEffectAgainstTarget(user,target)
		target.applyEffect(:CreepOut)
	end
	
	def getScore(score,user,target,skill=100)
		score += 20 if target.hp > target.totalhp/2
		score += 20 if user.hp > user.totalhp/2
		return score
	end
end

#===============================================================================
# If the move misses, the user gains 2 stages of speed. (Mudslide)
#===============================================================================
class PokeBattle_Move_51E < PokeBattle_Move
	#This method is called if a move fails to hit all of its targets
	def pbCrashDamage(user,targets=[])
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
		return if !user.pbCanRaiseStatStage?(:ACCURACY,user,self)
		@battle.pbDisplay(_INTL("{1} adjusts its aim!",user.pbThis))
		user.pbRaiseStatStage(:ACCURACY,1,user,true)
	end
end

#===============================================================================
# Increases the user's critical hit rate. (Starfall)
#===============================================================================
class PokeBattle_Move_520 < PokeBattle_Move
  def pbEffectGeneral(user)
	user.applyEffect(:LuckyStar)
  end
  
  def getScore(score,user,target,skill=100)
	score += 30
	score -= 60 if user.effectActive?(:LuckyStar)
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
# Target's highest move is drastically reduced. (Loom Over)
#===============================================================================
class PokeBattle_Move_522 < PokeBattle_TargetMultiStatDownMove
  def pbFailsAgainstTarget?(user,target)
    @statArray = []
    GameData::Stat.each_battle do |s|
      @statArray.push(s.id) if target.pbCanLowerStatStage?(s.id,user,self)
    end
    if @statArray.length==0
      @battle.pbDisplay(_INTL("But it fails, since none of {1}'s stats can be lowered!",target.pbThis))
      return true
    end
    return false
  end
  
  def pbEffectAgainstTarget(user,target)
    target.pbLowerStatStage(target.highestStat,2,user)
  end
end

#===============================================================================
# Move disables self. (Phantom Break)
#===============================================================================
class PokeBattle_Move_523 < PokeBattle_Move
	def pbEffectAfterAllHits(user,target)
		user.applyEffect(:Disable,5)
	end

	def getScore(score,user,target,skill=100)
		score -= 30
		return score
	end
end

#===============================================================================
# Heals the user by 2/3 health. Move disables self. (Stitch Up)
#===============================================================================
class PokeBattle_Move_524 < PokeBattle_HealingMove
	def healRatio(user)
		return 2.0/3.0
	end

	def pbEffectGeneral(user)
		super
		user.applyEffect(:Disable,5)
	end

	def getScore(score,user,target,skill=100)
		score = super
		score -= 30
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
		@battle.pbDisplay(_INTL("{1} is damaged by recoil!",user.pbThis))
		user.applyFractionalDamage(1.0/2.0)
	end
  
    def getScore(score,user,target,skill=100)
		score -= 50 if user.hp <= user.totalhp/2
		super
	end
end

#===============================================================================
# Puts the target to sleep. Fails unless in sunlight. (Summer Daze)
#===============================================================================
class PokeBattle_Move_527 < PokeBattle_SleepMove
	def pbMoveFailed?(user,targets)
		if @battle.pbWeather != :Sun
			@battle.pbDisplay(_INTL("But it failed, since the weather is not Sunny!"))
			return true
		end
		return false
	end
end

#===============================================================================
# Puts the target to sleep. Fails unless the target is at or below half health. (Lullaby)
#===============================================================================
class PokeBattle_Move_528 < PokeBattle_SleepMove
	def pbFailsAgainstTarget?(user,target)
		if target.hp > target.totalhp / 2
			@battle.pbDisplay(_INTL("But it failed, #{target.pbThis(true)} is above half health!"))
			return true
		end
		return !target.pbCanSleep?(user,true,self)
	end
end

#===============================================================================
# Puts the target to sleep. Fails unless the target dealt damage to the user this turn. (Puff Ball)
#===============================================================================
class PokeBattle_Move_529 < PokeBattle_SleepMove
	def pbFailsAgainstTarget?(user,target)
		if !user.lastAttacker.include?(target.index)
			@battle.pbDisplay(_INTL("But it failed, since the #{target.pbThis(true)} didn't attack #{user.pbThis(true)} this turn!"))
			return true
		end
		return !target.pbCanSleep?(user,true,self)
	end
	
	def getScore(score,user,target,skill=100)
		userSpeed = pbRoughStat(user,:SPEED,skill)
		targetSpeed = pbRoughStat(target,:SPEED,skill)
		return 0 if userSpeed > targetSpeed
		super
	end
end

#===============================================================================
# Deals 50% more damage if user is statused. (Hard Feelings, Sore Spot)
#===============================================================================
class PokeBattle_Move_52A < PokeBattle_Move
	def damageReducedByBurn?; return false; end

	def pbBaseDamage(baseDmg,user,target)
		baseDmg *= 1.5 if user.status != :NONE
		return baseDmg
	end
end

#===============================================================================
# Confuses or charms based on which of the target's attacking stats is higher. (Majestic Glare)
#===============================================================================
class PokeBattle_Move_52B < PokeBattle_Move
  def pbFailsAgainstTarget?(user,target)
    return false if damagingMove?
    # if !target.pbCanConfuse?(user,true,self) && !target.pbCanCharm?(user,true,self)
	# 	@battle.pbDisplay(_INTL("But it failed!")) 
	# 	return true
	# end
	if !target.pbCanFluster?(user,false,self) && !target.pbCanMystify?(user,false,self)
	 	@battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} cannot be flustered or mystified!")) 
	 	return true
	end
	return false
  end

  def pbEffectAgainstTarget(user,target)
    return if damagingMove?
    flusterOrMystify(target)
  end

  def pbAdditionalEffect(user,target)
    return if target.damageState.substitute
	flusterOrMystify(user,target)
  end

  def flusterOrMystify(user,target)
	real_attack = target.pbAttack
	real_special_attack = target.pbSpAtk
	
    if target.pbCanFluster?(user,true,self) && real_attack >= real_special_attack
		target.pbFluster
	elsif target.pbCanMystify?(user,true,self) && real_special_attack >= real_attack
		target.pbMystify
	end
  end
  
  def getScore(score,user,target,skill=100)
		score += target.pbCanMystify?(user,false) ? 20 : -20
		score += target.pbCanFluster?(user,false) ? 20 : -20
		return score
  end
end

#===============================================================================
# User gains 1/2 the HP it inflicts as damage. Lower's Sp. Def. (Soul Drain)
#===============================================================================
class PokeBattle_Move_52C < PokeBattle_DrainMove
	def drainFactor(user,target); return 0.5; end

	def pbAdditionalEffect(user,target)
		return if target.damageState.substitute
		return if !target.pbCanLowerStatStage?(:SPECIAL_DEFENSE,user,self)
		target.pbLowerStatStage(:SPECIAL_DEFENSE,1,user)
	end
  
	def getScore(score,user,target,skill=100)
		score += 20 if target.pbCanLowerStatStage?(:SPECIAL_DEFENSE,user,self)
		score += 20 if target.hp > target.totalhp/2
		super
	end
end

#===============================================================================
# Resets weather and cures all active Pokemon of statuses. (Shadowpass)
#===============================================================================
class PokeBattle_Move_52D < PokeBattle_Move
	def pbEffectGeneral(user)
		@battle.endWeather()
		@battle.battlers.each do |b|
			healStatus(b)
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
			@battle.endWeather()
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
	@battle.pbDisplay(_INTL(", since none of your current battlers can have their Attack raised!")) if failed
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
		if user.effectActive?(:Inured)
			@battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} is already inured!"))
			return true
		end
		return false
    end
	
	def pbEffectGeneral(user)
		user.applyEffect(:Inured)
	end
	
	def getScore(score,user,target,skill=100)
		score += 30 if user.firstTurn?
		return score
	end
end

#===============================================================================
# Raises worst stat two stages, second worst stat by one stage. (Breakdance)
#===============================================================================
class PokeBattle_Move_532 < PokeBattle_Move
	def pbFailsAgainstTarget?(user,target)
		@statArray = []
		GameData::Stat.each_main_battle do |statID|
		  @statArray.push(statID) if user.pbCanRaiseStatStage?(statID,user,self)
		end
		if @statArray.length==0
		  @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",user.pbThis))
		  return true
		end
		return false
	end
	
	def pbEffectGeneral(user)
		statsUserCanRaise = user.finalStats.select { |stat, finalValue|
			next user.pbCanRaiseStatStage?(stat, user, self)
		}
		statsRanked =  statsUserCanRaise.sort_by { |s, v| v}
		user.pbRaiseStatStage(statsRanked[0],2,user,true)
		user.pbRaiseStatStage(statsRanked[1],1,user,false) if statsRanked.length > 1
	end
	
	def getScore(score,user,target,skill=100)
		score += 20 if user.firstTurn?
		GameData::Stat.each_main_battle do |s|
			score -= user.stages[s] * 5
		end
		return score
	end
end


#===============================================================================
# Puts the target to sleep. Fails unless the target is mystified or flustered. (Pacify)
#===============================================================================
class PokeBattle_Move_534 < PokeBattle_SleepMove
	def pbFailsAgainstTarget?(user,target)
		if !target.flustered? && !target.mystified?
			@battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is neither flustered nor mystified!"))
			return true
		end
		return !target.pbCanSleep?(user,true,self,true)
	end
	
	def pbEffectAgainstTarget(user,target)
		target.pbCureStatus(false,:FLUSTERED)
		target.pbCureStatus(false,:MYSTIFIED)
		target.pbSleep
	end
end

#===============================================================================
# Can only be used on the first turn. Deals more damage if the user was hurt this turn. (Stare Down)
#===============================================================================
class PokeBattle_Move_535 < PokeBattle_Move
	def pbMoveFailed?(user,targets)
		if !user.firstTurn?
			@battle.pbDisplay(_INTL("But it failed, since it isn't #{user.pbThis(true)} first turn out!"))
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
		score = 0 if user.firstTurn?
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
	score -= user.stages[:SPECIAL_DEFENSE] * 10
	return score
  end
end

#===============================================================================
# Frostbites opposing Pokemon that have increased their stats. (Freezing Jealousy)
#===============================================================================
class PokeBattle_Move_537 < PokeBattle_Move
	def pbAdditionalEffect(user,target)
	  return if target.damageState.substitute
	  if target.pbCanFrostbite?(user,false,self) && target.hasRaisedStatStages?
		target.pbFrostbite(user)
	  end
	end
	
	def getScore(score,user,target,skill=100)
	  score -= 20
	  score += 50 if target.hasRaisedStatStages? && target.pbCanFrostbite?(user,false,self)
	  return score
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
        @battle.pbDisplay(_INTL("The fae mist disappeared from the battlefield!"))
      when :Psychic
        @battle.pbDisplay(_INTL("The weirdness disappeared from the battlefield!"))
    end
    @battle.endTerrain
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
    return if !target.item || target.item.nil? || user.item
    return if target.unlosableItem?(target.item)
    return if user.unlosableItem?(target.item)
    return if target.hasActiveAbility?(:STICKYHOLD) && !@battle.moldBreaker
	return unless target.item.is_berry? || target.item.is_gem?
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
		target.applyEffect(:NerveBreak)
	end
	
	def getScore(score,user,target,skill=100)
		score -= 30
		score += (target.totalhp - target.hp)/target.totalhp * 60

		return score
	end
end

#===============================================================================
# Deals 50% more damage if faster than the target. Then lower's user's speed. (Inertia Shock)
#===============================================================================
class PokeBattle_Move_53B < PokeBattle_StatDownMove
  def initialize(battle,move)
    super
    @statDown = [:SPEED,1]
  end
  
  def pbBaseDamage(baseDmg,user,target)
    baseDmg *= 1.5 if user.pbSpeed > target.pbSpeed
    return baseDmg.round
  end
end


#===============================================================================
# Can't miss if attacking a target that already used an attack this turn. (new!Power Whip)
#===============================================================================
class PokeBattle_Move_53C < PokeBattle_Move
    def pbAccuracyCheck(user,target)
		targetChoice = @battle.choices[target.index][0]
		if targetChoice == :UseMove && target.movedThisRound?
			return true
		end
		return super
	end
  
	def getScore(score,user,target,skill=100)
		return getWantsToBeSlowerScore(score,user,target,skill,2)
	end
end

#===============================================================================
# Heals user by 1/8 of their max health, but does not fail at full health. (???)
#===============================================================================
class PokeBattle_Move_53D < PokeBattle_HealingMove
	def healRatio(user)
		return 1.0/8.0
	end
  
	def pbMoveFailed?(user,targets)
		return false
	end
	
	def getScore(score,user,target,skill=100)
		score = super
		score += 30
		return score
	end
end

#===============================================================================
# Decreases the user's Sp. Atk and Sp. Atk by 1 stage each. (Geyser)
#===============================================================================
class PokeBattle_Move_53E < PokeBattle_StatDownMove
  def initialize(battle,move)
    super
    @statDown = [:SPECIAL_ATTACK,1,:SPECIAL_DEFENSE,1]
  end
end

#===============================================================================
# If the move misses, all targets are forced to switch out. (Rolling Boulder)
#===============================================================================
class PokeBattle_Move_53F < PokeBattle_Move
	#This method is called if a move fails to hit all of its targets
	def pbAllMissed(user,targets)
		return if @battle.wildBattle?
		return if user.fainted?
		
		roarSwitched = []
		targets.each do |b|
		  next if b.fainted? || b.damageState.substitute
		  next if b.effectActive?(:Ingrain)
		  next if b.hasActiveAbility?(:SUCTIONCUPS) && !@battle.moldBreaker
		  newPkmn = @battle.pbGetReplacementPokemonIndex(b.index,true)   # Random
		  next if newPkmn<0
		  @battle.pbRecallAndReplace(b.index, newPkmn, true)
		  @battle.pbDisplay(_INTL("{1} was dragged out!",b.pbThis))
		  @battle.pbClearChoice(b.index)   # Replacement Pokémon does nothing this round
		  roarSwitched.push(b.index)
		end
		if roarSwitched.length>0
		  @battle.moldBreaker = false if roarSwitched.include?(user.index)
		  @battle.pbPriority(true).each do |b|
			b.pbEffectsOnSwitchIn(true) if roarSwitched.include?(b.index)
		  end
		end
	end
end

#===============================================================================
# User's Special Defense is used instead of user's Special Attack for this move's calculations.
# (Aura Trick)
#===============================================================================
class PokeBattle_Move_540 < PokeBattle_Move
  def pbAttackingStat(user,target)
    return user,:SPECIAL_DEFENSE
  end
end


#===============================================================================
# Target's "clothing items" are destroyed. (Up In Flames)
#===============================================================================
class PokeBattle_Move_541 < PokeBattle_Move
  def pbEffectWhenDealingDamage(user,target)
    return if target.damageState.substitute || target.damageState.berryWeakened
    return if !target.item
	return if !CLOTHING_ITEMS.include?(target.item.id)
	itemName = target.itemName
    target.pbRemoveItem
    @battle.pbDisplay(_INTL("{1}'s {2} went up in flames!",target.pbThis,itemName))
  end
end

#===============================================================================
# Target's speed is drastically raised. (Propellant)
#===============================================================================
class PokeBattle_Move_542 < PokeBattle_Move
  def pbAdditionalEffect(user,target)
    return if target.damageState.substitute
    return if !target.pbCanRaiseStatStage?(:SPEED,user,self)
    target.pbRaiseStatStage(:SPEED,2,user)
  end
end

#===============================================================================
# Power doubles for each consecutive use. (Ice Ball)
#===============================================================================
class PokeBattle_Move_543 < PokeBattle_DoublingMove
    def initialize(battle, move)
		@usageCountEffect = :IceBall
        super
    end
end
  
#===============================================================================
# Power doubles for each consecutive use. (Rollout)
#===============================================================================
class PokeBattle_Move_544 < PokeBattle_DoublingMove
    def initialize(battle, move)
		@usageCountEffect = :RollOut
        super
    end
end

#===============================================================================
# Heals for 1/3 the damage dealt. (new!Drain Punch, Venom Leech)
#===============================================================================
class PokeBattle_Move_545 < PokeBattle_DrainMove
	def drainFactor(user,target); return (1.0/3.0); end
end

#===============================================================================
# Always critical hit vs Opponents with raised stats (Glitter Slash)
#===============================================================================
class PokeBattle_Move_546 < PokeBattle_Move 
  def pbCriticalOverride(user,target)
	return 1 if target.hasRaisedStatStages?
	return 0
  end
end


#===============================================================================
# Poisons, chills, or burns the target. (Chaos Wheel)
#===============================================================================
class PokeBattle_Move_547 < PokeBattle_Move
  def pbAdditionalEffect(user,target)
    return if target.damageState.substitute
    case @battle.pbRandom(3)
    when 0 then target.pbPoison(user) if target.pbCanPoison?(user, true, self)
    when 1 then target.pbFluster if target.pbCanFluster?(user, true, self)
    when 2 then target.pbMystify(user) if target.pbCanMystify?(user, true, self)
    end
  end
end

#===============================================================================
# Damages, while also healing the team of statuses. (Purifying Water)
#===============================================================================
class PokeBattle_Move_548 < PokeBattle_Move
	def pbEffectAfterAllHits(user,target)
		@battle.eachSameSideBattler(user) do |b|
			healStatus(b)
		end
		# Cure all Pokémon in the user's and partner trainer's party.
		# NOTE: This intentionally affects the partner trainer's inactive Pokémon
		#       too.
		@battle.pbParty(user.index).each_with_index do |pkmn,i|
			next if !pkmn || !pkmn.able?
			next if @battle.pbFindBattler(i,user)   # Skip Pokémon in battle
			healStatus(pkmn)
		end
	end

	def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
		super
		@battle.pbDisplay(_INTL("The area was purified!"))
	end
end

#===============================================================================
# Raises Sp.Attack of user and team (Mind Link)
#===============================================================================
class PokeBattle_Move_549 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    return false if damagingMove?
	failed = true
	@battle.eachSameSideBattler(user) do |b|
      next if !b.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user,self,true)
      failed = false
      break
    end
	@battle.pbDisplay(_INTL("But it failed, since none of your current battlers can have their Sp. Atk raised!")) if failed
    return failed
  end

  def pbEffectGeneral(user)
    @battle.eachSameSideBattler(user) do |b|
        next if !b.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user,self,true)
        b.pbRaiseStatStage(:SPECIAL_ATTACK,1,user)
    end
  end
  
	def getScore(score,user,target,skill=100)
		@battle.battlers.each do |b|
			pkmn = b.pokemon
			next if !pkmn || !pkmn.able? || !b.opposes?
			score -= b.stages[:SPECIAL_ATTACK] * 10
		end
		return score
	end
end



#===============================================================================
# Deals damage and curses the target. (Spooky Snuggling)
#===============================================================================
class PokeBattle_Move_54A < PokeBattle_Move
	def pbFailsAgainstTarget?(user,target)
		if target.effectActive?(:Curse)
			@battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is already cursed!"))
			return true
		end
		return false
	end

	def pbEffectAgainstTarget(user,target)
		target.applyEffect(:Curse)
	end
end


#===============================================================================
# Removes trapping moves, entry hazards and Leech Seed on user/user's side. Raises speed by 1.
# (Rapid Spin)
#===============================================================================
class PokeBattle_Move_54B < PokeBattle_StatUpMove
	def initialize(battle,move)
		super
		@statUp = [:SPEED,1]
	end
	
	def pbEffectAfterAllHits(user,target)
		return if user.fainted? || target.damageState.unaffected
		user.disableEffect(:Trapping)
		user.disableEffect(:LeechSeed)
		user.pbOwnSide.eachEffect(true) do |effect,value,data|
			next unless data.is_hazard?
			user.pbOwnSide.disableEffect(effect)
		end
	end
  
	def getScore(score,user,target,skill=100)
		if user.alliesInReserve?
			score += hazardWeightOnSide(user.pbOwnSide)
		end
		score += 20 if user.effectActive?(:LeechSeed)
		score += 20 if user.effectActive?(:Trapping)
		return score
	end
end


#===============================================================================
# Increases the user's Sp. Attack by 1 and Sp. Def by 1 stage each.
# In sandstorm, increases are 2 stages each instead. (Desert Dance)
#===============================================================================
class PokeBattle_Move_54C < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:ATTACK,1,:SPECIAL_ATTACK,1]
  end

  def pbOnStartUse(user,targets)
	if [:Sandstorm].include?(@battle.pbWeather)
		@statUp = [:SPECIAL_ATTACK,2,:SPECIAL_DEFENSE,2,:SPEED,1]
	else
		@statUp = [:SPECIAL_ATTACK,1,:SPECIAL_DEFENSE,1] 
	end
  end
end



#===============================================================================
# Decreases a random stat. Can't miss in sandstorm. (Dust Force)
#===============================================================================
class PokeBattle_Move_54D < PokeBattle_TargetStatDownMove
	def initialize(battle,move)
		super
		@statDown = [:SPEED,1]
	end

	def pbBaseAccuracy(user,target)
		return 0 if @battle.pbWeather == :Sandstorm
		return super
	end
  
  
	def pbAdditionalEffect(user,target)
		statOptions = [:ATTACK,:DEFENSE,:SPECIAL_ATTACK,:SPECIAL_DEFENSE,:SPEED]
		@statDown = [statOptions.sample,1]
		super
	end
end

#===============================================================================
# Increases the user's Sp. Atk, Sp. Def and accuracy by 1 stage each. (Store Fuel)
#===============================================================================
class PokeBattle_Move_54E < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:SPECIAL_ATTACK,1,:SPECIAL_DEFENSE,1,:ACCURACY,1]
  end
end

#===============================================================================
# Effectiveness against Dragon-type is 2x. (Slay)
#===============================================================================
class PokeBattle_Move_54F < PokeBattle_Move
  def pbCalcTypeModSingle(moveType,defType,user,target)
    return Effectiveness::SUPER_EFFECTIVE_ONE if defType == :DRAGON
    return super
  end
end

#===============================================================================
# User is protected against moves with the "B" flag this round. If a Pokémon
# attacks the user while this effect applies, that Pokémon is paralyzed (numbed).
# (Stunning Curl)
#===============================================================================
class PokeBattle_Move_550 < PokeBattle_ProtectMove
  def initialize(battle,move)
    super
    @effect = :StunningCurl
  end
end

#===============================================================================
# Entry hazard. Lays burn spikes on the opposing side.
# (Flame Spikes)
#===============================================================================
class PokeBattle_Move_551 < PokeBattle_TypeSpikeMove
	def initialize(battle,move)
		@spikeEffect = :FlameSpikes
		super
	end
end

#===============================================================================
# Starts acid rain weather. (Acid Rain)
#===============================================================================
class PokeBattle_Move_552 < PokeBattle_WeatherMove
	def initialize(battle,move)
	  super
	  @weatherType = :AcidRain
	end
end


#===============================================================================
# Poisons opposing Pokemon that have increased their stats. (Stinging Jealousy)
#===============================================================================
class PokeBattle_Move_553 < PokeBattle_Move
	def pbAdditionalEffect(user,target)
	  return if target.damageState.substitute
	  if target.pbCanPoison?(user,false,self) && target.hasRaisedStatStages?
		target.pbPoison(user)
	  end
	end
	
	def getScore(score,user,target,skill=100)
	  score -= 20
	  score += 50 if target.hasRaisedStatStages? && target.pbCanPoison?(user,false,self)
	  return score
	end
end


#===============================================================================
# Raises Defense of user and team (Stand Together)
#===============================================================================
class PokeBattle_Move_554 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    return false if damagingMove?
	failed = true
	@battle.eachSameSideBattler(user) do |b|
      next if !b.pbCanRaiseStatStage?(:DEFENSE,user,self,true)
      failed = false
      break
    end
	@battle.pbDisplay(_INTL("But it failed, since none of your current battlers can have their Defense raised!")) if failed
    return failed
  end

  def pbEffectGeneral(user)
    @battle.eachSameSideBattler(user) do |b|
        next if !b.pbCanRaiseStatStage?(:DEFENSE,user,self,true)
        b.pbRaiseStatStage(:DEFENSE,1,user)
    end
  end
  
	def getScore(score,user,target,skill=100)
		@battle.battlers.each do |b|
			pkmn = b.pokemon
			next if !pkmn || !pkmn.able? || !b.opposes?
			score -= b.stages[:DEFENSE] * 10
		end
		return score
	end
end


#===============================================================================
# Raises Sp. Def of user and team (Camaraderie)
#===============================================================================
class PokeBattle_Move_555 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    return false if damagingMove?
	failed = true
	@battle.eachSameSideBattler(user) do |b|
      next if !b.pbCanRaiseStatStage?(:SPECIAL_DEFENSE,user,self,true)
      failed = false
      break
    end
	@battle.pbDisplay(_INTL("But it failed, since none of your current battlers can have their Sp. Def raised!")) if failed
    return failed
  end

  def pbEffectGeneral(user)
    @battle.eachSameSideBattler(user) do |b|
        next if !b.pbCanRaiseStatStage?(:SPECIAL_DEFENSE,user,self,true)
        b.pbRaiseStatStage(:SPECIAL_DEFENSE,1,user)
    end
  end
  
	def getScore(score,user,target,skill=100)
		@battle.battlers.each do |b|
			pkmn = b.pokemon
			next if !pkmn || !pkmn.able? || !b.opposes?
			score -= b.stages[:SPECIAL_DEFENSE] * 10
		end
		return score
	end
end

#===============================================================================
# Starts swarm weather. (Swarm)
#===============================================================================
class PokeBattle_Move_556 < PokeBattle_WeatherMove
	def initialize(battle,move)
	  super
	  @weatherType = :Swarm
	end
end


#===============================================================================
# Drains 2/3s if target hurt the user this turn (Trap Jaw)
#===============================================================================
class PokeBattle_Move_557 < PokeBattle_Move
  def healingMove?; return true; end

  def pbEffectAgainstTarget(user,target)
    return if target.damageState.hpLost <= 0
	return if !user.lastAttacker.include?(target.index)
    hpGain = (target.damageState.hpLost*2/3).round
    user.pbRecoverHPFromDrain(hpGain,target)
  end

  def getScore(score,user,target,skill=100)
	return getWantsToBeSlowerScore(score,user,target,skill,3)
  end
end

#===============================================================================
# Forces the target to use a substitute (Doll Stitch)
#===============================================================================
class PokeBattle_Move_558 < PokeBattle_Move
	def pbEffectAgainstTarget(user,target)
		@battle.forceUseMove(target,:SUBSTITUTE,-1,true)
	end
end

#===============================================================================
# Target becomes Ghost type. (Evaporate)
#===============================================================================
class PokeBattle_Move_559 < PokeBattle_Move
	def pbMoveFailed?(user,targets)
	  if !user.canChangeType?
		@battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} can't change its type!"))
		return true
	  end
	  if !user.pbHasOtherType?(:GHOST)
		@battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} is already only a Ghost-type!"))
		return true
	  end
	  return false
	end
  
	def pbEffectGeneral(user)
	  user.pbChangeTypes(:GHOST)
	  typeName = GameData::Type.get(:GHOST).name
	  @battle.pbDisplay(_INTL("{1} transformed into the {2} type!",user.pbThis,typeName))
	end
end

#===============================================================================
# Lowers the user's Sp. Atk and Sp. Def (Phantom Gate)
#===============================================================================
class PokeBattle_Move_55A < PokeBattle_StatDownMove
	def initialize(battle,move)
	  super
	  @statDown = [:SPECIAL_ATTACK,1,:SPECIAL_DEFENSE,1]
	end
end

#===============================================================================
# Heals user to 100%. Only usable on first turn. (Fresh Start)
#===============================================================================
class PokeBattle_Move_55B < PokeBattle_HealingMove
	def healRatio(user)
		return 1.0
	end
  
	def pbMoveFailed?(user,targets)
		if !user.firstTurn?
			@battle.pbDisplay(_INTL("But it failed, since it's not #{user.pbThis(true)}'s first turn out!"))
			return true
		end
		return super
	end
end

#===============================================================================
# Two turn attack. Attacks first turn, skips second turn unless the target fainted.
# TODO: Currently unused
#===============================================================================
class PokeBattle_Move_55C < PokeBattle_Move
  def pbEffectAfterAllHits(user,target)
    user.applyEffect(:HyperBeam,2) if !target.damageState.fainted
  end
end

#===============================================================================
# Increases the target's Attack by 2 stages. Flusters the target. (new!Swagger)
#===============================================================================
class PokeBattle_Move_55D < PokeBattle_Move
	def pbFailsAgainstTarget?(user,target)
		if !target.pbCanRaiseStatStage?(:ATTACK,user,self,false) && !target.pbCanFluster?(user,false,self)
			@battle.pbDisplay(_INTL("But it failed!"))
		  return true
		end
		return false
	end
  
	def pbEffectAgainstTarget(user,target)
		target.pbRaiseStatStage(:ATTACK,2,user) if target.pbCanRaiseStatStage?(:ATTACK,user,self)
	  	target.pbFluster if target.pbCanFluster?(user,true,self)
	end

	def getScore(score,user,target,skill=100)
		score = getFlusterMoveScore(score,user,target,skill,user.ownersPolicies,statusMove?)
		if !target.hasPhysicalAttack?
			score += 30
		else
			score -= 30
		end
		return score
	end
end

#===============================================================================
# Increases the target's Sp. Atk. by 2 stages. Flusters the target. (new!Flatter)
#===============================================================================
class PokeBattle_Move_55E < PokeBattle_Move
	def pbFailsAgainstTarget?(user,target)
	  if !target.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user,self,false) && !target.pbCanMystify?(user,false,self)
	  	@battle.pbDisplay(_INTL("But it failed!"))
		return true
	  end
	  return false
	end
  
	def pbEffectAgainstTarget(user,target)
		target.pbRaiseStatStage(:SPECIAL_ATTACK,2,user) if target.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user,self)
	  	target.pbMystify if target.pbCanMystify?(user,true,self)
	end

	def getScore(score,user,target,skill=100)
		score = getMystifyMoveScore(score,user,target,skill,user.ownersPolicies,statusMove?)
		if !target.hasSpecialAttack?
			score += 30
		else
			score -= 30
		end
		return score
	end
end

#===============================================================================
# User must use this move for 2 more rounds. (Outrage, etc.)
#===============================================================================
class PokeBattle_Move_55F < PokeBattle_Move
	def pbEffectAfterAllHits(user,target)
	  if !target.damageState.unaffected && !user.effectActive?(:Outrage)
		user.applyEffect(:Outrage,3)
	  end
	  user.tickDownAndProc(:Outrage)
	end
end

#===============================================================================
# Flusters the target, and decreases its Defense by one stage. (Displace)
#===============================================================================
class PokeBattle_Move_560 < PokeBattle_Move
	def pbFailsAgainstTarget?(user,target)
		if !target.pbCanLowerStatStage?(:DEFENSE,user,self) && !target.pbCanFluster?(user,false,self)
			@battle.pbDisplay(_INTL("But it failed!"))
		  return true
		end
		return false
	end
  
	def pbEffectAgainstTarget(user,target)
		target.pbLowerStatStage(:DEFENSE,1,user) if target.pbCanLowerStatStage?(:DEFENSE,user,self,true)
	  	target.pbFluster if target.pbCanFluster?(user,true,self)
	end

	def getScore(score,user,target,skill=100)
        canFluster = target.pbCanFluster?(user,false) && !target.hasActiveAbility?(:MENTALBLOCK)
		score += 10 * target.stages[:DEFENSE]
        if canFluster
          score += 20
        elsif statusMove?
          score = 0
        end
        return score
    end
end

#===============================================================================
# Flusters the target, and decreases its Defense by one stage. (Mesmerize)
#===============================================================================
class PokeBattle_Move_561 < PokeBattle_Move
	def pbFailsAgainstTarget?(user,target)
		if !target.pbCanLowerStatStage?(:SPECIAL_DEFENSE,user,self) && !target.pbCanMystify?(user,false,self)
			@battle.pbDisplay(_INTL("But it failed!"))
		  return true
		end
		return false
	end
  
	def pbEffectAgainstTarget(user,target)
		target.pbLowerStatStage(:SPECIAL_DEFENSE,1,user) if target.pbCanLowerStatStage?(:SPECIAL_DEFENSE,user,self,true)
		target.pbMystify if target.pbCanMystify?(user,false,self)
	end

	def getScore(score,user,target,skill=100)
        canMystify = target.pbCanMystify?(user,false) && !target.hasActiveAbility?(:MENTALBLOCK)
		score += 10 * target.stages[:SPECIAL_DEFENSE]
        if canMystify
          score += 20
        elsif statusMove?
          score = 0
        end
        return score
    end
end

#===============================================================================
# Effectiveness against Electric-type is 2x. (Blackout)
#===============================================================================
class PokeBattle_Move_562 < PokeBattle_Move
	def pbCalcTypeModSingle(moveType,defType,user,target)
	  return Effectiveness::SUPER_EFFECTIVE_ONE if defType == :ELECTRIC
	  return super
	end
end

#===============================================================================
# Effectiveness against Ghost-type is 2x. (Holly Charm)
#===============================================================================
class PokeBattle_Move_563 < PokeBattle_Move
	def pbCalcTypeModSingle(moveType,defType,user,target)
	  return Effectiveness::SUPER_EFFECTIVE_ONE if defType == :GHOST
	  return super
	end
end

#===============================================================================
# Uses rest on both self and target. (Bedfellows)
#===============================================================================
class PokeBattle_Move_564 < PokeBattle_Move
	def pbEffectAgainstTarget(user,target)
		@battle.forceUseMove(user,:REST,-1,true)
		@battle.forceUseMove(target,:REST,-1,true)
	end
end

#===============================================================================
# Heals user by 2/3 of its max HP.
#===============================================================================
class PokeBattle_Move_565 < PokeBattle_HealingMove
	def healRatio(user)
	  return 2.0/3.0
	end
end

#===============================================================================
# Returns user to party for swap, deals more damage the lower HP the user has. (Hare Heroics)
#===============================================================================
class PokeBattle_Move_566 < PokeBattle_Move_0EE
  def pbBaseDamage(baseDmg,user,target)
    ret = 20
    n = 48*user.hp/user.totalhp
    if n<2;     ret = 200
    elsif n<5;  ret = 150
    elsif n<10; ret = 100
    elsif n<17; ret = 80
    elsif n<33; ret = 40
    end
    return ret
  end
end

#===============================================================================
# User is protected against moves with the "B" flag this round. If a Pokémon
# attacks with the user with a special attack while this effect applies, that Pokémon is
# burned. (Red-Hot Retreat)
#===============================================================================
class PokeBattle_Move_567 < PokeBattle_ProtectMove
	def initialize(battle,move)
	  super
	  @effect = :RedHotRetreat
	end

	def getScore(score,user,target,skill=100)
		score = super
		# Check only special attackers
		user.eachPotentialAttacker(true) do |b|
		  score += getPoisonMoveScore(0,user,b,skill,user.ownersPolicies,statusMove?)
		end
		return score
	end
end

#===============================================================================
# Reduces the target's defense by one stage.
# After inflicting damage, user switches out. Ignores trapping moves.
# (Rip Turn)
#===============================================================================
class PokeBattle_Move_568 < PokeBattle_Move_0EE
	def initialize(battle,move)
		super
		@statDown = [:DEFENSE,1]
	  end

	def pbFailsAgainstTarget?(user,target)
		return false if damagingMove?
		return !target.pbCanLowerStatStage?(@statDown[0],user,self,true)
	end
	
	def pbEffectAgainstTarget(user,target)
		return if damagingMove?
		target.pbLowerStatStage(@statDown[0],@statDown[1],user)
	end

	def pbAdditionalEffect(user,target)
		return if target.damageState.substitute
		return if !target.pbCanLowerStatStage?(@statDown[0],user,self)
		target.pbLowerStatStage(@statDown[0],@statDown[1],user)
	end
end

#===============================================================================
# Entry hazard. Lays frostbite spikes on the opposing side.
# (Frost Spikes)
#===============================================================================
class PokeBattle_Move_569 < PokeBattle_TypeSpikeMove
	def initialize(battle,move)
		@spikeEffect = :FrostSpikes
		super
	end
end
  
#===============================================================================
# 50% more damage in hailstorm. (Leap Out.)
#===============================================================================
class PokeBattle_Move_56A < PokeBattle_Move
	def pbBaseDamageMultiplier(damageMult,user,target)
		damageMult *= 1.5 if @battle.pbWeather == :Hail
		return damageMult
	end
end

#===============================================================================
# 100% Recoil Move
#===============================================================================
class PokeBattle_Move_56B < PokeBattle_RecoilMove
    def recoilFactor;  return 1.0; end
end

#===============================================================================
# Hits 2-5 times, for three turns in a row. (Pattern Release)
#===============================================================================
class PokeBattle_Move_56C < PokeBattle_Move_0C0
	def pbEffectAfterAllHits(user,target)
		if !target.damageState.unaffected && !user.effectActive?(:Outrage)
		  user.applyEffect(:Outrage,3)
		end
		user.tickDownAndProc(:Outrage)
	  end
end
  
#===============================================================================
# Future attacks hits twice as many times (Volley Stance)
#===============================================================================
class PokeBattle_Move_56D < PokeBattle_Move
	def pbMoveFailed?(user,targets)
	  if user.effectActive?(:VolleyStance)
		@battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} is already in that stance!"))
		return true
	  end
	  return false
	end
  
	def pbEffectGeneral(user)
	  user.applyEffect(:VolleyStance)
	end
end

#===============================================================================
# Raises all stats, but only if user is asleep. (Astral Dream)
#===============================================================================
class PokeBattle_Move_56E < PokeBattle_MultiStatUpMove
	def usableWhenAsleep?; return true; end

	def pbEffectGeneral(user)
		if user.pbCanRaiseStatStage?(:ATTACK,user,self)
		  user.pbRaiseStatStage(:ATTACK,1,user)
		end
		if user.pbCanRaiseStatStage?(:DEFENSE,user,self)
		  user.pbRaiseStatStage(:DEFENSE,1,user)
		end
		if user.pbCanRaiseStatStage?(:SPEED,user,self)
		  user.pbRaiseStatStage(:SPEED,1,user)
		end
		if user.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user,self)
		  user.pbRaiseStatStage(:SPECIAL_ATTACK,1,user)
		end
		if user.pbCanRaiseStatStage?(:SPECIAL_DEFENSE,user,self)
		  user.pbRaiseStatStage(:SPECIAL_DEFENSE,1,user)
		end
	end
  
	def pbMoveFailed?(user,targets)
		if !user.asleep?
			@battle.pbDisplay(_INTL("But it failed!"))
			return true
		end
		if !user.pbCanRaiseStatStage?(:ATTACK,user,self,true) &&
			!user.pbCanRaiseStatStage?(:DEFENSE,user,self,true) &&
			!user.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user,self,true) &&
			!user.pbCanRaiseStatStage?(:SPECIAL_DEFENSE,user,self,true) &&
			!user.pbCanRaiseStatStage?(:SPEED,user,self,true)
		@battle.pbDisplay(_INTL("But it failed!"))
		return true
		end
	  	return false
	end
end

#===============================================================================
# Lower's the Speed of all targets whom have moved this round. (Vine Maze)
#===============================================================================
class PokeBattle_Move_56F < PokeBattle_Move
	def pbAdditionalEffect(user,target)
		return if target.damageState.substitute
		targetChoice = @battle.choices[target.index][0]
		if targetChoice == :UseMove && target.movedThisRound? && target.pbCanLowerStatStage?(:SPEED,user,self)
			target.pbLowerStatStage(:SPEED,1,user)
		end
	end
	
	def getScore(score,user,target,skill=100)
	  return getWantsToBeSlowerScore(score,user,target,skill,2)
	end
end

#===============================================================================
# Flusters the target. Accuracy perfect in rain. Hits flying semi-invuln targets. (Hurricane)
#===============================================================================
class PokeBattle_Move_570 < PokeBattle_FlusterMove
	def immuneToRainDebuff?; return true; end

	def hitsFlyingTargets?; return true; end
  
	def pbBaseAccuracy(user,target)
	  return 0 if [:Rain, :HeavyRain].include?(@battle.pbWeather)
	  return super
	end
end

#===============================================================================
# Power increases if the user is below half health. (Frantic Fang)
#===============================================================================
class PokeBattle_Move_571 < PokeBattle_Move
	def pbBaseDamage(baseDmg,user,target)
	  ret = baseDmg
	  if user.hp <= user.totalhp / 2
		ret *= 2
	  end
	  return ret
	end
end

#===============================================================================
# Puts the target to sleep if they are at or below half health, and raises the user's attack. (Tranquil Tune)
#===============================================================================
class PokeBattle_Move_572 < PokeBattle_Move_528
	def pbEffectAgainstTarget(user,target)
		super
		user.pbRaiseStatStage(:ATTACK,1,user) if user.pbCanRaiseStatStage?(:ATTACK,user,self)
	end

	def getScore(score,user,target,skill=100)
		score += 30 if user.hasPhysicalAttack?
		super
	end
end

#===============================================================================
# Type effectiveness is multiplied by the Psychic-type's effectiveness against
# the target. (Leyline Burst)
#===============================================================================
class PokeBattle_Move_573 < PokeBattle_Move
	def pbCalcTypeModSingle(moveType,defType,user,target)
	  ret = super
	  if GameData::Type.exists?(:PSYCHIC)
		psychicEffectiveness = Effectiveness.calculate_one(:PSYCHIC, defType)
		ret *= psychicEffectiveness.to_f / Effectiveness::NORMAL_EFFECTIVE_ONE
	  end
	  return ret
	end
end
  

#===============================================================================
# Power increases with the highest allies defense. (Hard Place)
#===============================================================================
class PokeBattle_Move_574 < PokeBattle_Move
	def pbBaseDamage(baseDmg,user,target)
	  	highestDefense = 0
		user.eachAlly do |ally_battler|
			real_defense = ally_battler.pbDefense
			highestDefense = real_defense if real_defense > highestDefense
		end
	  	return [highestDefense,40].max
	end
end

#===============================================================================
# Doubles an allies Attack and Speed. The user cannot swap out of battle.
# If the user faints, so too does that ally. (Dragon Ride)
#===============================================================================
class PokeBattle_Move_575 < PokeBattle_Move
	def pbFailsAgainstTarget?(user,target)
	  if target.effectActive?(:OnDragonRide)
		@battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is already on a dragon ride!"))
		return true
	  end
	  if user.effectActive?(:GivingDragonRideTo)
		@battle.pbDisplay(_INTL("But it failed, since #{user.pbThis} is already giving a dragon ride!"))
		return true
	  end
	  return false
	end
  
	def pbEffectAgainstTarget(user,target)
	  target.applyEffect(:OnDragonRide)
	  target.applyEffect(:GivingDragonRideTo,target.index)
	  @battle.pbDisplay(_INTL("{1} gives {2} a ride on its back!",user.pbThis,target.pbThis(true)))
	end
	
	def getScore(score,user,target,skill=100)
	  return 0 if user.hp < user.totalhp / 2
	end
end

#===============================================================================
# Two turn attack. Sets rain first turn, attacks second turn.
# (Archaic Deluge)
#===============================================================================
class PokeBattle_Move_576 < PokeBattle_TwoTurnMove
	def pbChargingTurnMessage(user,targets)
	  @battle.pbDisplay(_INTL("{1} begins the flood!",user.pbThis))
	end
  
	def pbChargingTurnEffect(user,target)
		@battle.pbStartWeather(user,:Rain,5,false)
	end

	def getScore(score,user,target,skill=100)
		if @battle.field.weather != :Rain
			score += 50
		else
			score -= 50
		end
		return score
	end
end

#===============================================================================
# The user takes 33% less damage until end of this turn.
# (Shimmering Heat)
#===============================================================================
class PokeBattle_Move_577 < PokeBattle_Move
	def pbEffectAfterAllHits(user,target)
		user.applyEffect(:ShimmeringHeat)
	end

	def getScore(score,user,target,skill=100)
		return getWantsToBeFasterScore(score,user,target,skill,3)
	end
end

#===============================================================================
# Revives a fainted Grass-type party member back to 100% HP. (Breathe Life)
#===============================================================================
class PokeBattle_Move_578 < PokeBattle_PartyMemberEffectMove
	def legalChoice(pokemon)
		return false if !super
		return false if !pokemon.fainted?
		return false if !pokemon.hasType?(:GRASS)
		return true
	end
  
	def effectOnPartyMember(pokemon)
		pokemon.heal_HP
		pokemon.heal_status
		@battle.pbDisplay(_INTL("{1} recovered all the way to full health!",pokemon.name))
	end
end

#===============================================================================
# Numb's the target. If they are already numbed, curses them instead. (Spectral Tongue)
#===============================================================================
class PokeBattle_Move_579 < PokeBattle_Move
	def pbFailsAgainstTarget?(user,target)
		if target.paralyzed?
			if target.effectActive?(:Curse)
				@battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is already cursed!"))
			end
		else
			return !target.pbCanParalyze?(user,true,self)
		end
	end
  
	def pbEffectAgainstTarget(user,target)
		if target.paralyzed?
			target.applyEffect(:Curse)
		else
			target.pbParalyze(user)
		end
	end
end

#===============================================================================
# Transfers the user's status to the target (Vicious Cleaning)
#===============================================================================
class PokeBattle_Move_580 < PokeBattle_Move
	def pbEffectAgainstTarget(user,target)
		user.getStatuses().each do |status|
			next if status == :NONE
			if target.pbCanInflictStatus?(status,user,false,self)
				case status
				when :SLEEP
				target.pbSleep
				when :POISON
				target.pbPoison(user,nil,user.statusCount!=0)
				when :BURN
				target.pbBurn(user)
				when :PARALYSIS
				target.pbParalyze(user)
				when :FROSTBITE
				target.pbFrostbite
				when :FLUSTERED
				target.pbFluster
				when :MYSTIFIED
				target.pbMystify
				end
			else
				statusData = GameData::Status.get(status)
				@battle.pbDisplay(_INTL("{1} tries to transfer its {2} to {3}, but...",user.pbThis,statusData.real_name,target.pbThis(true)))
				target.pbCanInflictStatus?(status,user,true,self)
			end
			user.pbCureStatus(status)
		end
	end
end

#===============================================================================
# Puts the target to sleep, then minimizes the user's speed. (Sedating Dust)
#===============================================================================
class PokeBattle_Move_581 < PokeBattle_SleepMove
	def pbFailsAgainstTarget?(user,target)
		return !target.pbCanSleep?(user,true,self,true)
	end

	def pbEffectAgainstTarget(user,target)
		target.pbSleep
		user.pbMinimizeStatStage(:SPEED,user,self)
	end

	def getScore(score,user,target,skill=100)
		score -= user.stages[:SPEED] * 5
		super
	end
end

#===============================================================================
# For 5 rounds, swaps all battlers' offensive and defensive stats (Sp. Def <-> Sp. Atk and Def <-> Atk).
# (Odd Room)
#===============================================================================
class PokeBattle_Move_582 < PokeBattle_Move
	def initialize(battle,move)
	  super
	  @roomEffect = :OddRoom
	end
end

#===============================================================================
# Restores health by 33% and raises Speed by one stage. (Mulch Meal)
#===============================================================================
class PokeBattle_Move_583 < PokeBattle_HealingMove
	def healRatio(user)
		return 1.0/3.0
	end
  
	def pbMoveFailed?(user,targets)
	  if user.hp == user.totalhp && !user.pbCanRaiseStatStage?(:SPEED,user,self,true)
		@battle.pbDisplay(_INTL("But it failed!",user.pbThis))
		return true
	  end
	end
  
	def pbEffectGeneral(user)
		super
		user.pbRaiseStatStage(:SPEED,1,user) if user.pbCanRaiseStatStage?(:SPEED,user,self,false)
	end

	def getScore(score,user,target,skill=100)
		score = super
		score += 20
		score -= user.stages[:SPEED] * 20
		return score
	end
end

#===============================================================================
# Raises the target's worst three stats by one stage each. (Guiding Aroma)
#===============================================================================
class PokeBattle_Move_584 < PokeBattle_Move
	def pbFailsAgainstTarget?(user,target)
		@statArray = []
		GameData::Stat.each_main_battle do |s|
		  @statArray.push(s.id) if target.pbCanRaiseStatStage?(s.id,user,self)
		end
		if @statArray.length==0
		  @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",target.pbThis))
		  return true
		end
		return false
	end
	
	def pbEffectAgainstTarget(user,target)
		statsTargetCanRaise = target.finalStats.select { |stat, finalValue|
			next target.pbCanRaiseStatStage?(stat, user, self)
		}
		statsRanked = statsTargetCanRaise.sort_by { |s, v| v}
		target.pbRaiseStatStage(statsRanked[0],1,user,true)
		target.pbRaiseStatStage(statsRanked[1],1,user,false) if statsRanked.length > 1
		target.pbRaiseStatStage(statsRanked[2],1,user,false) if statsRanked.length > 2
	end
	
	def getScore(score,user,target,skill=100)
		score += 20 if user.firstTurn?
		stats = [:ATTACK,:DEFENSE,:SPECIAL_ATTACK,:SPECIAL_DEFENSE,:SPEED]
		stats.each do |s|
			score -= target.stages[s] * 5
		end
		return score
	end
end

#===============================================================================
# Raises the user's Sp. Atk, and the user's attacks become spread. (Flare Witch)
#===============================================================================
class PokeBattle_Move_585 < PokeBattle_Move
	def pbMoveFailed?(user,targets)
	  if user.effectActive?(:FlareWitch) && !user.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user,self,true)
		@battle.pbDisplay(_INTL("But it failed!"))
		return true
	  end
	  return false
	end

	def pbEffectGeneral(user)
		user.pbRaiseStatStage(:SPECIAL_ATTACK,1,user) if user.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user,self,true)
	  	user.applyEffect(:FlareWitch)
	end
end

#===============================================================================
# Effectiveness against Fighting-type is 2x. (Honorless Sting)
#===============================================================================
class PokeBattle_Move_586 < PokeBattle_Move
	def pbCalcTypeModSingle(moveType,defType,user,target)
	  return Effectiveness::SUPER_EFFECTIVE_ONE if defType == :FIGHTING
	  return super
	end
end

#===============================================================================
# (Not currently used.)
#===============================================================================
class PokeBattle_Move_587 < PokeBattle_Move
end

#===============================================================================
# If it faints the target, you gain lots of money after the battle. (Plunder)
#===============================================================================
class PokeBattle_Move_588 < PokeBattle_Move
	def pbEffectAfterAllHits(user,target)
		return if !target.damageState.fainted
		@battle.field.incrementEffect(:PayDay,10*user.level) if user.pbOwnedByPlayer?
	end
end

#===============================================================================
# Attacks two to five times. Gains money for each hit. (Sacred Lots)
#===============================================================================
class PokeBattle_Move_589 < PokeBattle_Move_0C0
	def pbEffectOnNumHits(user,target,numHits)
		return if !target.damageState.fainted
		coinsGenerated = 2 * user.level * numHits
		@battle.field.incrementEffect(:PayDay,coinsGenerated) if user.pbOwnedByPlayer?
		if numHits == 5
			@battle.pbDisplay(_INTL("How fortunate!",coinsGenerated))
		elsif numHits == 0
			@battle.pbDisplay(_INTL("How unfortunate! Better luck next time.",coinsGenerated))
		end
	end
end

#===============================================================================
# Power is tripled if the target is poisoned. (Vipershock)
#===============================================================================
class PokeBattle_Move_58A < PokeBattle_Move
  def pbBaseDamage(baseDmg,user,target)
    if target.poisoned?
      baseDmg *= 3
    end
    return baseDmg
  end
end

#===============================================================================
# Counts as a use of Rollout, Iceball, or Furycutter. (On A Roll)
#===============================================================================
class PokeBattle_Move_58B < PokeBattle_Move
	def pbChangeUsageCounters(user,specialUsage)
		oldEffectValues = {}
		user.eachEffect(true) do |effect, value, data|
			oldEffectValues[effect] = value if data.snowballing_move_counter?
		end
		super
		oldEffectValues.each do |effect, oldValue|
			data = GameData::BattleEffect.get(effect)
			user.effects[effect] = [oldValue + 1, data.maximum].min
		end
	end
end

#===============================================================================
# The user's Speed raises two stages, and it gains the Flying-type. (Mach Flight)
#===============================================================================
class PokeBattle_Move_58C < PokeBattle_Move_030
	def pbMoveFailed?(user,targets)
		if GameData::Type.exists?(:FLYING) && !user.pbHasType?(:FLYING) && user.canChangeType?
			return false
		end
		super
	end

	def pbEffectGeneral(user)
		super
		user.applyEffect(:Type3,:FLYING)
	end
end

#===============================================================================
# Guaranteed to crit, but lowers the user's speed. (Incision)
#===============================================================================
class PokeBattle_Move_58D < PokeBattle_Move_03E
	def pbCriticalOverride(user,target); return 1; end
end

#===============================================================================
# Returns user to party for swap and lays a layer of spikes. (Caltrop Style)
#===============================================================================
class PokeBattle_Move_58E < PokeBattle_Move_0EE
	def pbMoveFailed?(user,targets)
		return false if damagingMove?
		if user.pbOpposingSide.effectAtMax?(:Spikes)
		  @battle.pbDisplay(_INTL("But it failed, since there is no room for more Spikes!"))
		  return true
		end
		return false
	end
	
	def pbEffectGeneral(user)
		return if damagingMove?
		user.pbOpposingSide.incrementEffect(:Spikes)
	end

	def pbAdditionalEffect(user,target)
		return if !damagingMove?
		return if user.pbOpposingSide.effectAtMax?(:Spikes)
		user.pbOpposingSide.incrementEffect(:Spikes)
	end
end

#===============================================================================
# Faints the opponant if they are below 1/3 HP. (Cull)
#===============================================================================
class PokeBattle_Move_58F < PokeBattle_FixedDamageMove
	def pbFixedDamage(user,target)
		if target.hp < (target.totalhp / 3)
			return target.hp
		end
		return nil
	end
end

#===============================================================================
# Decreases the target's Defense by 3 stages. (Eroding Foam)
#===============================================================================
class PokeBattle_Move_590 < PokeBattle_TargetStatDownMove
	def initialize(battle,move)
	  super
	  @statDown = [:DEFENSE,3]
	end
end

#===============================================================================
# Power increases the taller the user is than the target. (Cocodrop)
#===============================================================================
class PokeBattle_Move_591 < PokeBattle_Move
	def pbBaseDamage(baseDmg,user,target)
	  ret = 40
	  n = (user.pbHeight/target.pbHeight).floor
	  if n>=5;    ret = 120
	  elsif n>=4; ret = 100
	  elsif n>=3; ret = 80
	  elsif n>=2; ret = 60
	  end
	  return ret
	end
  end

#===============================================================================
# Damages target if target is a foe, or buff's the target's Speed and
# Sp. Def is it's an ally. (Lightning Spear)
#===============================================================================
class PokeBattle_Move_592 < PokeBattle_Move
	def pbOnStartUse(user,targets)
	  @buffing = false
	  @buffing = !user.opposes?(targets[0]) if targets.length>0
	end
  
	def pbFailsAgainstTarget?(user,target)
		return false if !@buffing
		return true if !target.pbCanRaiseStatStage?(:SPEED,user,self,true) && !target.pbCanRaiseStatStage?(:SPECIAL_DEFENSE,user,self,true)
    	return false
	end
  
	def pbDamagingMove?
	  return false if @buffing
	  return super
	end
  
	def pbEffectAgainstTarget(user,target)
	  return if !@buffing
	  target.pbRaiseStatStage(:SPEED,1,user,self) if target.pbCanRaiseStatStage?(:SPEED,user,self)
	  target.pbRaiseStatStage(:SPECIAL_DEFENSE,1,user,self) if target.pbCanRaiseStatStage?(:SPECIAL_DEFENSE,user,self)
	end
  
	def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
	  if @buffing
		@battle.pbAnimation(:CHARGE,user,targets,hitNum) if showAnimation
	  else
		super
	  end
	end
end

#===============================================================================
# Does Dragon-Darts style hit redirection, plus
# each target hit loses 1 stage of Speed. (Tar Volley)
#===============================================================================
class PokeBattle_Move_592 < PokeBattle_Move_17C
	def pbAdditionalEffect(user,target)
		return if target.damageState.substitute
		return if !target.pbCanLowerStatStage?(:SPEED,user,self)
		target.pbLowerStatStage(:SPEED,1,user)
	end
end

#===============================================================================
# User is protected against moves with the "B" flag this round. If a Pokémon
# attacks with the user with a special attack while this effect applies, that Pokémon
# takes 1/8th chip damage. (Mirror Shield)
#===============================================================================
class PokeBattle_Move_593 < PokeBattle_ProtectMove
	def initialize(battle,move)
	  super
	  @effect = :MirrorShield
	end

	def getScore(score,user,target,skill=100)
		score = super
		# Check only special attackers
		user.eachPotentialAttacker(1) do |b|
		  score += 20
		end
		return score
	end
end

#===============================================================================
# Power doubles if has the Defense Curl effect, which it consumes. (Unfurl)
#===============================================================================
class PokeBattle_Move_594 < PokeBattle_Move
	def pbBaseDamage(baseDmg,user,target)
		baseDmg *= 2 if user.effectActive?(:DefenseCurl)
		return baseDmg
	end

	def pbEffectAfterAllHits(user,target)
		user.disableEffect(:DefenseCurl)
	end
end

#===============================================================================
# User's Attack and Defense are raised by one stage each, and changes user's type to Rock. (Built Different)
#===============================================================================
class PokeBattle_Move_595 < PokeBattle_Move_024
	def pbMoveFailed?(user,targets)
		if GameData::Type.exists?(:ROCK) && !user.pbHasType?(:ROCK) && user.canChangeType?
			return false
		end
		super
	end

	def pbEffectGeneral(user)
		super
		user.applyEffect(:Type3,:ROCK)
	end
end

#===============================================================================
# Maximizes attack, minimizes Speed, target cannot escape. (Death Mark)
#===============================================================================
class PokeBattle_Move_596 < PokeBattle_Move
	def pbFailsAgainstTarget?(user,target)
		if target.effectActive?(:MeanLook) && !user.pbCanRaiseStatStage?(:ATTACK) && !user.pbCanLowerStatStage?(:SPEED)
		  @battle.pbDisplay(_INTL("But it failed!"))
		  return true
		end
		return false
	end

	def pbEffectAgainstTarget(user,target)
		target.pointAt(:MeanLook,user) if !target.effectActive?(:MeanLook)
	end

	def pbEffectGeneral(user)
		user.pbMinimizeStatStage(:SPEED,user,self)
		user.pbMaximizeStatStage(:ATTACK,user,self)
	end
 end

#===============================================================================
# User's side takes 50% less attack damage this turn. (Bulwark)
#===============================================================================
class PokeBattle_Move_597 < PokeBattle_ProtectMove
	def initialize(battle,move)
	  super
	  @effect      = :Bulwark
	  @sidedEffect = true
	end

	def pbProtectMessage(user)
		@battle.pbDisplay(_INTL("{1} spread its arms to guard {2}!",@name,user.pbTeam(true)))
	end
end

#===============================================================================
# (Not currently used)
#===============================================================================
class PokeBattle_Move_598 < PokeBattle_Move
end

#===============================================================================
# User takes recoil damage equal to 1/5 of the damage this move dealt.
#===============================================================================
class PokeBattle_Move_599 < PokeBattle_RecoilMove
	def recoilFactor;  return 0.2; end
end

#===============================================================================
# Burns the target and sets Sun
#===============================================================================
class PokeBattle_Move_59A < PokeBattle_InvokeMove
	def initialize(battle,move)
		super
		@weatherType = :Sun
		@durationSet = 4
		@statusToApply = :BURN
	end
end

#===============================================================================
# Numbs the target and sets Rain
#===============================================================================
class PokeBattle_Move_59B < PokeBattle_InvokeMove
	def initialize(battle,move)
		super
		@weatherType = :Rain
		@durationSet = 4
		@statusToApply = :PARALYSIS
	end
end

#===============================================================================
# Frostbites the target and sets Hail
#===============================================================================
class PokeBattle_Move_59C < PokeBattle_InvokeMove
	def initialize(battle,move)
		super
		@weatherType = :Hail
		@durationSet = 4
		@statusToApply = :FROSTBITE
	end
end

#===============================================================================
# Poisons the target and sets Sandstorm
#===============================================================================
class PokeBattle_Move_59D < PokeBattle_InvokeMove
	def initialize(battle,move)
		super
		@weatherType = :Sandstorm
		@durationSet = 4
		@statusToApply = :POISON
	end
end

#===============================================================================
# Revives a fainted party member back to 1 HP. (Defibrillate)
#===============================================================================
class PokeBattle_Move_59E < PokeBattle_PartyMemberEffectMove
	def legalChoice(pokemon)
		return false if !super
		return false if !pokemon.fainted?
		return true
	end
  
	def effectOnPartyMember(pokemon)
		pokemon.hp = 1
		pokemon.heal_status
		@battle.pbDisplay(_INTL("{1} recovered to 1 HP!",pokemon.name))
	end
end

  #===============================================================================
  # Decreases the target's Attack and Special Attack by 1 stage each. (Singing Stone)
  #===============================================================================
  class PokeBattle_Move_59F < PokeBattle_TargetMultiStatDownMove
  
    def initialize(battle,move)
      super
      @statDown = [:ATTACK,1,:SPECIAL_ATTACK,1]
    end
  end

#===============================================================================
# Type effectiveness is multiplied by the Ice-type's effectiveness against
# the target. (Feverish Gas)
#===============================================================================
class PokeBattle_Move_5A0 < PokeBattle_Move
	def pbCalcTypeModSingle(moveType,defType,user,target)
	  ret = super
	  if GameData::Type.exists?(:ICE)
		iceEffectiveness = Effectiveness.calculate_one(:ICE, defType)
		ret *= iceEffectiveness.to_f / Effectiveness::NORMAL_EFFECTIVE_ONE
	  end
	  return ret
	end
end

#===============================================================================
# Decreases the user's Sp. Def.
# Increases the user's Sp. Atk by 1 stage, and Speed by 2 stages.
# (Shed Coat)
#===============================================================================
class PokeBattle_Move_5A2 < PokeBattle_StatUpDownMove
	def initialize(battle,move)
		super
		@statUp   = [:SPEED,2,:SPECIAL_ATTACK,1]
		@statDown = [:SPECIAL_DEFENSE,1]
	end
end

 #===============================================================================
# Entry hazard. Lays Feather Ward on the opposing side. (Feather Ward)
#===============================================================================
class PokeBattle_Move_5A1 < PokeBattle_Move
	def pbMoveFailed?(user,targets)
		if user.pbOpposingSide.effectActive?(:FeatherWard)
		@battle.pbDisplay(_INTL("But it failed, since sharp feathers already float around the opponent!"))
		return true
		end
		return false
	end

	def pbEffectGeneral(user)
		user.pbOpposingSide.applyEffect(:FeatherWard)
	end

	def getScore(score,user,target,skill=100)
		score = getHazardSettingMoveScore(score,user,target,skill)
		return score
	end
end

#===============================================================================
# Decreases the user's Speed by 2 stages. (Razor Plunge)
#===============================================================================
class PokeBattle_Move_03E < PokeBattle_StatDownMove
	def initialize(battle,move)
	  super
	  @statDown = [:SPEED,2]
	end
  end