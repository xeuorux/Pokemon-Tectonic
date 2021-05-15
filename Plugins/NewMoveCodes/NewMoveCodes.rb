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
end

#===============================================================================
# User takes recoil damage equal to 2/3 of the damage this move dealt.
# (Head Charge)
#===============================================================================
class PokeBattle_Move_502 < PokeBattle_RecoilMove
  def pbRecoilDamage(user,target)
    return (2.0*target.damageState.totalHPLost/3.0).round
  end
end

#===============================================================================
# Increases the user's Sp. Atk and Speed by 1 stage each. (Lightning Dance)
#===============================================================================
class PokeBattle_Move_503 < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:SPATK,1,:SPEED,1]
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
end

#===============================================================================
# Target's Special Defense is used instead of its Defense for this move's
# calculations. (Soul Claw, Soul Rip)
#===============================================================================
class PokeBattle_Move_506 < PokeBattle_Move
  def pbGetDefenseStats(user,target)
    return target.spdef, target.stages[:SPDEF]+6
  end
end


#===============================================================================
# Lowers the target's Sp. Def. Effectiveness against Steel-type is 2x. (Corrode)
#===============================================================================
class PokeBattle_Move_507 < PokeBattle_TargetStatDownMove
  def initialize(battle,move)
    super
    @statDown = [:SPDEF,1]
  end
  
  def pbCalcTypeModSingle(moveType,defType,user,target)
    return Effectiveness::SUPER_EFFECTIVE_ONE if moveType == :STEEL
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
end

#===============================================================================
# If this move KO's the target, increases the user's Sp. Atk by 3 stages.
# (Slight)
#===============================================================================
class PokeBattle_Move_50B < PokeBattle_Move
  def pbEffectAfterAllHits(user,target)
    return if !target.damageState.fainted
    return if !user.pbCanRaiseStatStage?(PBStats::SPATK,user,self)
    user.pbRaiseStatStage(PBStats::SPATK,3,user)
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
end

#===============================================================================
# User loses half their hp in recoil. (Steel Beam)
#===============================================================================
class PokeBattle_Move_510 < PokeBattle_Move
	def pbEffectAfterAllHits(user,target)
		return if target.damageState.unaffected
		return if !user.takesIndirectDamage?
		amt = (user.hp / 2).ceil
		user.pbReduceHP(amt,false)
		@battle.pbDisplay(_INTL("{1} loses half its health in recoil!",user.pbThis))
		user.pbItemHPHealCheck
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
end

#===============================================================================
# Increases the user's Attack and Sp. Def by 1 stage each. (Flow State)
#===============================================================================
class PokeBattle_Move_512 < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:ATTACK,1,:SPDEF,1]
  end
end

#===============================================================================
# Increases the user's Sp. Atk and Sp. Def by 1 stage each. (Vanguard)
#===============================================================================
class PokeBattle_Move_513 < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:SPATK,1,:DEFENSE,1]
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
	statStagesUp = target.stages[:ATTACK] > 0 || target.stages[:DEFENSE] > 0 || target.stages[:SPEED] > 0 || target.stages[:SPECIAL_ATTACK] > 0 || target.stages[:SPECIAL_DEFENSE] > 0 || target.stages[:ACCURACY] > 0 || target.stages[:EVASION] > 0
    if target.pbCanBurn?(user,false,self) && statStagesUp
      target.pbBurn(user)
    end
  end
end

#===============================================================================
# Priority against Pokemon with half or less health. (Aqua Instinct)
#===============================================================================
class PokeBattle_Move_517 < PokeBattle_Move
	def priorityModification?(user,target);
		return 1 if target.hp.to_f < target.totalhp.to_f/2
		return 0
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
end

#===============================================================================
# Decreases the user's Speed and Defense by 1 stage each. Can't miss. (Prediction Strike)
#===============================================================================
class PokeBattle_Move_519 < PokeBattle_StatDownMove
  def initialize(battle,move)
    super
    @statDown = [:SPEED,1,:DEFENSE,1]
  end
  
  def pbAccuracyCheck(user,target); return true; end
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
end