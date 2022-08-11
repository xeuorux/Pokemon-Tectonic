#===============================================================================
# Pseudomove for charm damage.
#===============================================================================
class PokeBattle_Charm < PokeBattle_Move
	def initialize(battle,move,basePower=50)
	  @battle     = battle
	  @realMove   = move
	  @id         = 0
	  @name       = ""
	  @function   = "000"
	  @baseDamage = basePower
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

#===============================================================================
# Flusters the target.
#===============================================================================
class PokeBattle_FlusterMove < PokeBattle_Move
	def pbFailsAgainstTarget?(user,target)
	  return false if damagingMove?
	  return !target.pbCanFluster?(user,true,self)
	end
  
	def pbEffectAgainstTarget(user,target)
	  return if damagingMove?
	  target.pbFluster
	end
  
	def pbAdditionalEffect(user,target)
	  return if target.damageState.substitute
	  return if !target.pbCanFluster?(user,false,self)
	  target.pbFluster
	end

    def getScore(score,user,target,skill=100)
        canFluster = target.pbCanFluster?(user,false) && !target.hasActiveAbility?(:MENTALBLOCK)
        if canFluster
          score += 20
        elsif statusMove?
          score = 0
        end
        return score
    end
end

#===============================================================================
# Mystifies the target.
#===============================================================================
class PokeBattle_MystifyMove < PokeBattle_Move
	def pbFailsAgainstTarget?(user,target)
	  return false if damagingMove?
	  return !target.pbCanMystify?(user,true,self)
	end
  
	def pbEffectAgainstTarget(user,target)
	  return if damagingMove?
	  target.pbMystify
	end
  
	def pbAdditionalEffect(user,target)
	  return if target.damageState.substitute
	  return if !target.pbCanMystify?(user,false,self)
	  target.pbMystify
	end

    def getScore(score,user,target,skill=100)
        canMystify = target.pbCanMystify?(user,false) && !target.hasActiveAbility?(:MENTALBLOCK)
        if canMystify
          score += 20
        elsif statusMove?
          score = 0
        end
        return score
    end
end

#===============================================================================
# Charms the target.
#===============================================================================
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

  def getScore(score,user,target,skill=100)
	canCharm = target.pbCanCharm?(user,false) && !target.hasActiveAbility?(:MENTALBLOCK)
	if canCharm
	  score += 20
	elsif statusMove?
	  score = 0
	end
	return score
  end
end

#===============================================================================
# Frostbite's the target.
#===============================================================================
class PokeBattle_FrostbiteMove < PokeBattle_Move
	def pbFailsAgainstTarget?(user,target)
	  return false if damagingMove?
	  return !target.pbCanFrostbite?(user,true,self)
	end
  
	def pbEffectAgainstTarget(user,target)
	  return if damagingMove?
	  target.pbFrostbite
	end
  
	def pbAdditionalEffect(user,target)
	  return if target.damageState.substitute
	  return if !target.pbCanFrostbite?(user,false,self)
	  target.pbFrostbite
	end

    def getScore(score,user,target,skill=100)
        canFrostbite = target.pbCanFrostbite?(user,false)
        if canFrostbite
          score += 20
        elsif statusMove?
          score = 0
        end
        return score
    end
end

#===============================================================================
# Charms the target.
#===============================================================================
class PokeBattle_Move_400 < PokeBattle_CharmMove
end

#===============================================================================
# Flusters the target.
#===============================================================================
class PokeBattle_Move_401 < PokeBattle_FlusterMove
end

#===============================================================================
# Mystifies the target.
#===============================================================================
class PokeBattle_Move_402 < PokeBattle_MystifyMove
end

#===============================================================================
# Frostbite's the target.
#===============================================================================
class PokeBattle_Move_403 < PokeBattle_FrostbiteMove
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
  def ignoresSubstitute?(user); return true; end

  def pbFailsAgainstTarget?(user,target)
    # Target has already moved this round
    return true if pbMoveFailedTargetAlreadyMoved?(target)
    # Target was going to move next anyway (somehow)
    if target.effects[PBEffects::MoveNext]
      @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} was already going to move next!"))
      return true
    end
    # Target didn't choose to use a move this round
    oppMove = @battle.choices[target.index][2]
    if !oppMove
      @battle.pbDisplay(_INTL("But it failed, #{target.pbThis(true)} isn't set to use a move this turn!"))
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
    target.pbFreeze if target.pbCanFreeze?(user,false,self)
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
	stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
	stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
	attackStage = target.stages[:ATTACK]+6
	attack = (target.attack.to_f*stageMul[attackStage].to_f/stageDiv[attackStage].to_f).floor
	spAtkStage = target.stages[:SPECIAL_ATTACK]+6
	spAtk = (target.spatk.to_f*stageMul[spAtkStage].to_f/stageDiv[spAtkStage].to_f).floor
	
    if target.pbCanBurn?(user,false,self) && attack >= spAtk
		target.pbBurn(user)
	elsif target.pbCanFrostbite?(user,false,self) && spAtk >= attack
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
# Power is doubled if the target is frostbitten. (Ice Impact)
#===============================================================================
class PokeBattle_Move_50C < PokeBattle_Move
  def pbBaseDamage(baseDmg,user,target)
    if target.frostbitten? &&
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
	user.effects[PBEffects::Enlightened] = true
  end
end

#===============================================================================
# Burns opposing Pokemon that have increased their stats. (Burning Jealousy)
#===============================================================================
class PokeBattle_Move_516 < PokeBattle_Move
  def pbAdditionalEffect(user,target)
    return if target.damageState.substitute
    if target.pbCanBurn?(user,false,self) && target.statStagesUp?
      target.pbBurn(user)
    end
  end
  
  def getScore(score,user,target,skill=100)
    score -= 20
	score += 50 if target.statStagesUp? && target.pbCanBurn?(user,false,self)
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
	@healAmount /= 4.0 if user.boss?
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
# For 5 rounds, Pokemon's Attack and Sp. Atk are swapped. (Puzzle Room)
#===============================================================================
class PokeBattle_Move_51A < PokeBattle_Move
	def pbEffectGeneral(user)
	  if @battle.field.effects[PBEffects::PuzzleRoom]>0
		@battle.field.effects[PBEffects::PuzzleRoom] = 0
		@battle.pbDisplay(_INTL("The area returned to normal!"))
	  else
		@battle.field.effects[PBEffects::PuzzleRoom] = 5
		@battle.pbDisplay(_INTL("It created a puzzling area in which Pokémon's Attack and Sp. Atk are swapped!"))
	  end
	end
  
	def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
	  return if @battle.field.effects[PBEffects::PuzzleRoom] > 0   # No animation
	  super
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
    if !user.effects[PBEffects::ColdConversion]
      user.effects[PBEffects::ColdConversion] = true
      @battle.pbDisplay(_INTL("{1} lost its cold!",user.pbThis))
	  @battle.scene.pbRefresh()
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

	def pbEffectGeneral(user)
		super
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
			@battle.pbDisplay(_INTL("But it failed, since the weather is not Sunny!"))
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
		if target.hp > target.totalhp / 2
			@battle.pbDisplay(_INTL("But it failed, #{target.pbThis(true)} is above half health!"))
			return true
		end
		return !target.pbCanSleep?(user,true,self)
	end
	
	def getScore(score,user,target,skill=100)
		score = sleepMoveAI(score,user,target,skill=100)
		if score != 0 && target.hp > target.totalhp/2
			score = 0
		end
		return score
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
	if !target.pbCanFluster?(user,true,self) && !target.pbCanMystify?(user,true,self)
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
	stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
	stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
	attackStage = target.stages[:ATTACK]+6
	attack = (target.attack.to_f*stageMul[attackStage].to_f/stageDiv[attackStage].to_f).floor
	spAtkStage = target.stages[:SPECIAL_ATTACK]+6
	spAtk = (target.spatk.to_f*stageMul[spAtkStage].to_f/stageDiv[spAtkStage].to_f).floor
	
    if target.pbCanFluster?(user,false,self) && attack >= spAtk
		target.pbFluster
	elsif target.pbCanMystify?(user,false,self) && spAtk >= attack
		target.pbMystify
	end
  end
  
#   def confuseOrCharm(user,target)
# 	stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
# 	stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
# 	attackStage = target.stages[:ATTACK]+6
# 	attack = (target.attack.to_f*stageMul[attackStage].to_f/stageDiv[attackStage].to_f).floor
# 	spAtkStage = target.stages[:SPECIAL_ATTACK]+6
# 	spAtk = (target.spatk.to_f*stageMul[spAtkStage].to_f/stageDiv[spAtkStage].to_f).floor
	
#     if target.pbCanConfuse?(user,false,self) && attack >= spAtk
# 		target.pbConfuse
# 	elsif target.pbCanCharm?(user,false,self) && spAtk >= attack
# 		target.pbCharm
# 	end
#   end
  
  def getScore(score,user,target,skill=100)
		score += target.pbCanMystify?(user,false) ? 20 : -20
		score += target.pbCanFluster?(user,false) ? 20 : -20
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
			pbAromatherapyHeal(pkmn,b)
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
		return false if damagingMove?
		if user.effects[PBEffects::Inured]
			@battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} is already inured!"))
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
	
	def pbEffectGeneral(user)
		stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
		stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
		statsRanked = [:ATTACK,:DEFENSE,:SPECIAL_ATTACK,:SPECIAL_DEFENSE,:SPEED]
		statsRanked.sort_by { |s| user.stats[s].to_f * stageMul[user.stages[s]+6] / stageDiv[user.stages[s]+6] }
		user.pbRaiseStatStageBasic(statsRanked[0],2)
		user.pbRaiseStatStageBasic(statsRanked[1],1)
	end
	
	def getScore(score,user,target,skill=100)
		score += 20 if user.turnCount == 0
		stats = [:ATTACK,:DEFENSE,:SPECIAL_ATTACK,:SPECIAL_DEFENSE,:SPEED]
		stats.each do |s|
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
		# if target.effects[PBEffects::Confusion] == 0 && target.effects[PBEffects::Charm] == 0
		# 	@battle.pbDisplay(_INTL("But it failed!"))
		# 	return true
		# end
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
	
	def getScore(score,user,target,skill=100)
		score = sleepMoveAI(score,user,target,skill=100)
		return score
	end
end

#===============================================================================
# Can only be used on the first turn. Deals more damage if the user was hurt this turn. (Stare Down)
#===============================================================================
class PokeBattle_Move_535 < PokeBattle_Move
	def pbMoveFailed?(user,targets)
		if user.turnCount > 1
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
# Frostbites opposing Pokemon that have increased their stats. (Freezing Jealousy)
#===============================================================================
class PokeBattle_Move_537 < PokeBattle_Move
	def pbAdditionalEffect(user,target)
	  return if target.damageState.substitute
	  if target.pbCanFrostbite?(user,false,self) && target.statStagesUp?
		target.pbFrostbite(user)
	  end
	end
	
	def getScore(score,user,target,skill=100)
	  score -= 20
	  score += 50 if target.statStagesUp? && target.pbCanFrostbite?(user,false,self)
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
# Deals 50% more damage if faster than the target. Then lower's user's speed. (Inertia Shock)
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
		  next if b.effects[PBEffects::Ingrain]
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
  def pbGetAttackStats(user,target)
    return user.spdef, user.stages[:SPECIAL_DEFENSE]+6
  end
end


#===============================================================================
# Target's "clothing items" are destroyed. (Up In Flames)
#===============================================================================
class PokeBattle_Move_541 < PokeBattle_Move
  def pbEffectWhenDealingDamage(user,target)
    return if target.damageState.substitute || target.damageState.berryWeakened
    return if !target.item
	return if !CLOTHING_ITEMS.include?(target.item)
    target.pbRemoveItem
    @battle.pbDisplay(_INTL("{1}'s {2} was incinerated!",target.pbThis,target.itemName))
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
class PokeBattle_Move_543 < PokeBattle_Move
  def pbChangeUsageCounters(user,specialUsage)
    oldVal = user.effects[PBEffects::IceBall]
    super
    maxMult = 1
    while (@baseDamage<<(maxMult-1))<160
      maxMult += 1   # 1-4 for base damage of 20, 1-3 for base damage of 40
    end
    user.effects[PBEffects::IceBall] = (oldVal>=maxMult) ? maxMult : oldVal+1
  end

  def pbBaseDamage(baseDmg,user,target)
    return baseDmg<<(user.effects[PBEffects::IceBall]-1)
  end
end

#===============================================================================
# Power doubles for each consecutive use. (Rollout)
#===============================================================================
class PokeBattle_Move_544 < PokeBattle_Move
  def pbChangeUsageCounters(user,specialUsage)
    oldVal = user.effects[PBEffects::RollOut]
    super
    maxMult = 1
    while (@baseDamage<<(maxMult-1))<160
      maxMult += 1   # 1-4 for base damage of 20, 1-3 for base damage of 40
    end
    user.effects[PBEffects::RollOut] = (oldVal>=maxMult) ? maxMult : oldVal+1
  end

  def pbBaseDamage(baseDmg,user,target)
    return baseDmg<<(user.effects[PBEffects::RollOut]-1)
  end
end

#===============================================================================
# Heals for 1/3 the damage dealt. (new!Drain Punch, Venom Leech)
#===============================================================================
class PokeBattle_Move_545 < PokeBattle_Move
  def healingMove?; return Settings::MECHANICS_GENERATION >= 6; end
  
  def pbEffectAgainstTarget(user,target)
    return if target.damageState.hpLost<=0
    hpGain = (target.damageState.hpLost/3.0).round
    user.pbRecoverHPFromDrain(hpGain,target)
  end
  
  def getScore(score,user,target,skill=100)
	score += 40 if user.hp < user.totalhp/2.0
	return score
  end
end



#===============================================================================
# Always critical hit vs Opponents with raised stats (Glitter Slash)
#===============================================================================
class PokeBattle_Move_546 < PokeBattle_Move 
  def pbCritialOverride(user,target)
	return 1 if target.statStagesUp?
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
    when 0 then target.pbPoison(user) if target.pbCanPoison?(user, false, self)
    when 1 then target.pbFluster if target.pbCanFluster?(user, false, self)
    when 2 then target.pbMystify(user) if target.pbCanMystify?(user, false, self)
    end
  end
end

#===============================================================================
# Damages, while also healing the team of statuses. (Purifying Water)
#===============================================================================
class PokeBattle_Move_548 < PokeBattle_Move
	def pbEffectAfterAllHits(user,target)
		@battle.eachSameSideBattler(user) do |b|
			next if b.status == :NONE
			pbAromatherapyHeal(b.pokemon,b)
		end
		# Cure all Pokémon in the user's and partner trainer's party.
		# NOTE: This intentionally affects the partner trainer's inactive Pokémon
		#       too.
		@battle.pbParty(user.index).each_with_index do |pkmn,i|
			next if !pkmn || !pkmn.able? || pkmn.status == :NONE
			next if @battle.pbFindBattler(i,user)   # Skip Pokémon in battle
			pbAromatherapyHeal(pkmn)
		end
	end

	def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
		super
		@battle.pbDisplay(_INTL("The area was purified!"))
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
# Deals damage and curses the target. (SPOOOKY SNUGGLING)
#===============================================================================
class PokeBattle_Move_54A < PokeBattle_Move

	def pbEffectAgainstTarget(user,target)
		return false if target.effects[PBEffects::Curse] == true
		target.effects[PBEffects::Curse] = true
		@battle.pbDisplay(_INTL("{1} was cursed!", target.pbThis))
	end
	
end


#===============================================================================
# Removes trapping moves, entry hazards and Leech Seed on user/user's side. Raises speed by 1.
# (new Rapid Spin)
#===============================================================================
class PokeBattle_Move_54B < PokeBattle_StatUpMove
	def initialize(battle,move)
		super
		@statUp = [:SPEED,1]
		echoln "did this work"
	end
	
	def pbEffectAfterAllHits(user,target)
		return if user.fainted? || target.damageState.unaffected
		if user.effects[PBEffects::Trapping]>0
			trapMove = GameData::Move.get(user.effects[PBEffects::TrappingMove]).name
			trapUser = @battle.battlers[user.effects[PBEffects::TrappingUser]]
			@battle.pbDisplay(_INTL("{1} got free of {2}'s {3}!",user.pbThis,trapUser.pbThis(true),trapMove))
			user.effects[PBEffects::Trapping]     = 0
			user.effects[PBEffects::TrappingMove] = nil
			user.effects[PBEffects::TrappingUser] = -1
		end
		if user.effects[PBEffects::LeechSeed]>=0
			user.effects[PBEffects::LeechSeed] = -1
			@battle.pbDisplay(_INTL("{1} shed Leech Seed!",user.pbThis))
		end
		if user.pbOwnSide.effects[PBEffects::StealthRock]
			user.pbOwnSide.effects[PBEffects::StealthRock] = false
			@battle.pbDisplay(_INTL("{1} blew away stealth rocks!",user.pbThis))
		end
		if user.pbOwnSide.effects[PBEffects::Spikes]>0
			user.pbOwnSide.effects[PBEffects::Spikes] = 0
			@battle.pbDisplay(_INTL("{1} blew away spikes!",user.pbThis))
		end
		if user.pbOwnSide.effects[PBEffects::ToxicSpikes] > 0
			user.pbOwnSide.effects[PBEffects::ToxicSpikes] = 0
			@battle.pbDisplay(_INTL("{1} blew away poison spikes!",user.pbThis))
		end
		if user.pbOwnSide.effects[PBEffects::FlameSpikes] > 0
			user.pbOwnSide.effects[PBEffects::FlameSpikes] = 0
			@battle.pbDisplay(_INTL("{1} blew away flame spikes!",user.pbThis))
		end
		if user.pbOwnSide.effects[PBEffects::FrostSpikes] > 0
			user.pbOwnSide.effects[PBEffects::FrostSpikes] = 0
			@battle.pbDisplay(_INTL("{1} blew away frost spikes!",user.pbThis))
		end
		if user.pbOwnSide.effects[PBEffects::StickyWeb]
			user.pbOwnSide.effects[PBEffects::StickyWeb] = false
			@battle.pbDisplay(_INTL("{1} blew away sticky webs!",user.pbThis))
		end
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
		statOptions = [:ATTACK,:DEFENSE,:SPECIALATTACK,:SPECIALDEFENSE,:SPEED]
		rng = @battle.pbRandom(100) % 5
		@statDown = [statOptions[rng],1]
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
    @effect = PBEffects::StunningCurl
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
	  if target.pbCanPoison?(user,false,self) && target.statStagesUp?
		target.pbPoison(user)
	  end
	end
	
	def getScore(score,user,target,skill=100)
	  score -= 20
	  score += 50 if target.statStagesUp? && target.pbCanPoison?(user,false,self)
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
# Raises Sp. Def of user and team (CAMARADERIE)
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
  def healingMove?; return Settings::MECHANICS_GENERATION >= 6; end

  def pbEffectAgainstTarget(user,target)
    return if target.damageState.hpLost <= 0
	return if !user.lastAttacker.include?(target.index)
    hpGain = (target.damageState.hpLost*2/3).round
    user.pbRecoverHPFromDrain(hpGain,target) if drain
  end

  def getScore(score,user,target,skill=100)
	return getWantsToBeSlowerScore(score,user,target,skill,3)
  end
end

#===============================================================================
# Forces the target to use a substitute (Doll Stitch)
#===============================================================================
class PokeBattle_Move_558 < PokeBattle_Move
	def pbFailsAgainstTarget?(user,target)
		if target.boss
			@battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is an Avatar!"))
			return true
		end
		if target.effects[PBEffects::Substitute]>0
			@battle.pbDisplay(_INTL("{1} already has a substitute!",target.pbThis))
			return true
		end
		@subLife = target.totalhp/4
		@subLife = 1 if @subLife<1
		if target.hp<=@subLife
			@battle.pbDisplay(_INTL("But {1} does not have enough HP left to make a substitute!",target.pbThis))
			return true
		end
		return false
	end

	def pbEffectAgainstTarget(user,target)
		target.pbReduceHP(@subLife,false,false)
		target.pbItemHPHealCheck
		target.effects[PBEffects::Trapping]     = 0
		target.effects[PBEffects::TrappingMove] = nil
		target.effects[PBEffects::Substitute]   = @subLife
		@battle.pbDisplay(_INTL("{1} put {2} in a substitute!",user.pbThis,target.pbThis))
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
  
	def pbEffectGeneral(user,target)
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
	def pbHealAmount(user)
		return user.totalhp
	end
  
	def pbMoveFailed?(user,targets)
		if user.turncount > 1
			@battle.pbDisplay(_INTL("But it failed, since it's not #{user.pbThis(true)}'s first turn out!"))
			return true
		end
		return super
	end
end

#===============================================================================
# Two turn attack. Attacks first turn, skips second turn (if successful).
#===============================================================================
class PokeBattle_Move_55C < PokeBattle_Move
  def pbEffectAfterAllHits(user,target)
    if !target.damageState.fainted
		user.effects[PBEffects::HyperBeam] = 2
	end
    user.currentMove = @id #ONLY PUT HERE BECAUSE IT WAS IN ORIGINAL HYPER BEAM CODE, PLEASE TEST
  end
end

#===============================================================================
# Increases the target's Attack by 2 stages. Flusters the target. (new!Swagger)
#===============================================================================
class PokeBattle_Move_55D < PokeBattle_Move
	def pbMoveFailed?(user,targets)
	  failed = true
	  targets.each do |b|
		next if !b.pbCanRaiseStatStage?(:ATTACK,user,self) &&
				!b.pbCanFluster?(user,false,self)
		failed = false
		break
	  end
	  if failed
		@battle.pbDisplay(_INTL("But it failed!"))
		return true
	  end
	  return false
	end
  
	def pbEffectAgainstTarget(user,target)
	  if target.pbCanRaiseStatStage?(:ATTACK,user,self)
		target.pbRaiseStatStage(:ATTACK,2,user)
	  end
	  target.pbFluster if target.pbCanFluster?(user,false,self)
	end
end

#===============================================================================
# Increases the target's Sp. Atk. by 2 stages. Flusters the target. (new!Flatter)
#===============================================================================
class PokeBattle_Move_55E < PokeBattle_Move
	def pbMoveFailed?(user,targets)
	  failed = true
	  targets.each do |b|
		next if !b.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user,self) &&
				!b.pbCanMystify?(user,false,self)
		failed = false
		break
	  end
	  if failed
		@battle.pbDisplay(_INTL("But it failed!"))
		return true
	  end
	  return false
	end
  
	def pbEffectAgainstTarget(user,target)
	  if target.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user,self)
		target.pbRaiseStatStage(:SPECIAL_ATTACK,2,user)
	  end
	  target.pbMystify if target.pbCanMystify?(user,false,self)
	end
end

#===============================================================================
# User must use this move for 2 more rounds.
# (new!Outrage, etc.)
#===============================================================================
class PokeBattle_Move_55F < PokeBattle_Move
	def pbEffectAfterAllHits(user,target)
	  if !target.damageState.unaffected && user.effects[PBEffects::Outrage] == 0
		user.effects[PBEffects::Outrage] = 3
		user.currentMove = @id
	  end
	  if user.effects[PBEffects::Outrage]>0
		user.effects[PBEffects::Outrage] -= 1
		if user.effects[PBEffects::Outrage]==0
		  @battle.pbDisplay(_INTL("{1} spun down from its attack.",user.pbThis))
		end
	  end
	end
end

#===============================================================================
# Flusters the target, and decreases its Defense by one stage. (Displace)
#===============================================================================
class PokeBattle_Move_560 < PokeBattle_Move
	def pbMoveFailed?(user,targets)
	  failed = true
	  targets.each do |b|
		next if !b.pbCanLowerStatStage?(:DEFENSE,user,self) &&
				!b.pbCanFluster?(user,false,self)
		failed = false
		break
	  end
	  if failed
		@battle.pbDisplay(_INTL("But it failed!"))
		return true
	  end
	  return false
	end
  
	def pbEffectAgainstTarget(user,target)
	  if target.pbCanLowerStatStage?(:DEFENSE,user,self)
		target.pbLowerStatStage(:DEFENSE,1,user)
	  end
	  target.pbFluster if target.pbCanFluster?(user,false,self)
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
	def pbMoveFailed?(user,targets)
	  failed = true
	  targets.each do |b|
		next if !b.pbCanLowerStatStage?(:SPECIAL_DEFENSE,user,self) &&
				!b.pbCanMystify?(user,false,self)
		failed = false
		break
	  end
	  if failed
		@battle.pbDisplay(_INTL("But it failed!"))
		return true
	  end
	  return false
	end
  
	def pbEffectAgainstTarget(user,target)
		if target.pbCanLowerStatStage?(:SPECIAL_DEFENSE,user,self)
			target.pbLowerStatStage(:SPECIAL_DEFENSE,1,user)
		end
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
class PokeBattle_Move_564 < PokeBattle_HealingMove
	def pbMoveFailed?(user,targets)
		if user.asleep?
		@battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} is already asleep!"))
		return true
		end
		if !user.pbCanSleep?(user,true,self,true)
			@battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} cannot fall asleep!"))
			return true
		end
		return true if super
		return false
	end

	def pbHealAmount(user)
		return user.totalhp-user.hp
	end
  
	def pbEffectAgainstTarget(user,target)
		if !target.asleep?
			hpGain = target.totalhp-target.hp
			target.pbRecoverHP(hpGain)
			@battle.pbDisplay(_INTL("{1} slept and became healthy!",target.pbThis))
		end
	end

	def pbEffectGeneral(user)
		if user.asleep? || !user.pbCanSleep?(user,true,self,true)
			@battle.pbDisplay(_INTL("But it failed!"))
		else
			user.pbSleepSelf(_INTL("{1} slept and became healthy!",user.pbThis),3)
			super
		end
	end
end

#===============================================================================
# Heals user by 2/3 of its max HP.
#===============================================================================
class PokeBattle_Move_565 < PokeBattle_HealingMove
	def pbHealAmount(user)
	  return (user.totalhp*2.0/3.0).round
	end
end

#===============================================================================
# Returns user to party for swap, deals more damage the lower HP the user has.
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
	  @effect = PBEffects::RedHotRetreat
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
  def pbRecoilDamage(user,target)
    return (target.damageState.totalHPLost/1.0).round
  end
end

#===============================================================================
# Hits 3-5 times, for three turns in a row. (Pattern Release)
#===============================================================================
class PokeBattle_Move_56C < PokeBattle_Move_55F
	def multiHitMove?; return true; end
  
	def pbNumHits(user,targets)
	  hitChances = [2,2,3,3,4,5]
	  r = @battle.pbRandom(hitChances.length)
	  r = hitChances.length-1 if user.hasActiveAbility?(:SKILLLINK)
	  return hitChances[r]
	end
end
  
#===============================================================================
# Future attacks hits twice as many times (Volley Stance)
#===============================================================================
class PokeBattle_Move_56D < PokeBattle_Move
	def pbMoveFailed?(user,targets)
	  if user.effects[PBEffects::VolleyStance]
		@battle.pbDisplay(_INTL("But it failed!"))
		return true
	  end
	  return false
	end
  
	def pbEffectGeneral(user)
	  user.effects[PBEffects::VolleyStance] = true
	  @battle.pbDisplay(_INTL("{1} takes a stance to begin bombardment!",user.pbThis))
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
# Flusters the target. Accuracy perfect in rain, 50% in sunshine. Hits some
# semi-invulnerable targets. (Hurricane)
#===============================================================================
class PokeBattle_Move_570 < PokeBattle_FlusterMove
	def hitsFlyingTargets?; return true; end
  
	def pbBaseAccuracy(user,target)
	  case @battle.pbWeather
	  when :Sun, :HarshSun
		return 50
	  when :Rain, :HeavyRain
		return 0
	  end
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