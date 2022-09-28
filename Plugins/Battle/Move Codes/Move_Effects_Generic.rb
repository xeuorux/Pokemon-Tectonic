#===============================================================================
# Superclass that handles moves using a non-existent function code.
# Damaging moves just do damage with no additional effect.
# Status moves always fail.
#===============================================================================
class PokeBattle_UnimplementedMove < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if statusMove?
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end
end

#===============================================================================
# Pseudomove for confusion damage.
#===============================================================================
class PokeBattle_Confusion < PokeBattle_Move
  def initialize(battle,move,basePower=50)
    @battle     = battle
    @realMove   = move
    @id         = 0
    @name       = ""
    @function   = "000"
    @baseDamage = basePower
    @type       = nil
    @category   = 0
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

  def physicalMove?(thisType=nil);    return true;  end
  def specialMove?(thisType=nil);     return false; end
  def pbCritialOverride(user,target); return -1;    end
end

#===============================================================================
# Implements the move Struggle.
# For cases where the real move named Struggle is not defined.
#===============================================================================
class PokeBattle_Struggle < PokeBattle_Move
  def initialize(battle,move)
    @battle     = battle
    @realMove   = nil                     # Not associated with a move
    @id         = (move) ? move.id : :STRUGGLE
    @name       = (move) ? move.name : _INTL("Struggle")
    @function   = "002"
    @baseDamage = 50
    @type       = nil
    @category   = 0
    @accuracy   = 0
    @pp         = -1
    @target     = 0
    @priority   = 0
    @flags      = ""
    @addlEffect = 0
    @calcType   = nil
    @powerBoost = false
    @snatched   = false
  end

  def physicalMove?(thisType=nil); return true;  end
  def specialMove?(thisType=nil);  return false; end

  def pbEffectAfterAllHits(user,target)
    return if target.damageState.unaffected
    user.applyFractionalDamage(1.0/4.0,false)
    @battle.pbDisplay(_INTL("{1} was damaged by recoil!",user.pbThis))
  end
end

#===============================================================================
# Generic status problem-inflicting classes.
#===============================================================================
class PokeBattle_SleepMove < PokeBattle_Move
  def pbFailsAgainstTarget?(user,target)
    return false if damagingMove?
    return !target.pbCanSleep?(user,true,self)
  end

  def pbEffectAgainstTarget(user,target)
    return if damagingMove?
    target.pbSleep
  end

  def pbAdditionalEffect(user,target)
    return if target.damageState.substitute
    target.pbSleep if target.pbCanSleep?(user,false,self)
  end
end

class PokeBattle_PoisonMove < PokeBattle_Move
  def initialize(battle,move)
    super
    @toxic = false
  end

  def pbFailsAgainstTarget?(user,target)
    return false if damagingMove?
    return !target.pbCanPoison?(user,true,self)
  end

  def pbEffectAgainstTarget(user,target)
    return if damagingMove?
    target.pbPoison(user,nil,@toxic)
  end

  def pbAdditionalEffect(user,target)
    return if target.damageState.substitute
    target.pbPoison(user,nil,@toxic) if target.pbCanPoison?(user,false,self)
  end
end

class PokeBattle_ParalysisMove < PokeBattle_Move
  def pbFailsAgainstTarget?(user,target)
    return false if damagingMove?
    return !target.pbCanParalyze?(user,true,self)
  end

  def pbEffectAgainstTarget(user,target)
    return if damagingMove?
    target.pbParalyze(user)
  end

  def pbAdditionalEffect(user,target)
    return if target.damageState.substitute
    target.pbParalyze(user) if target.pbCanParalyze?(user,false,self)
  end
end

class PokeBattle_BurnMove < PokeBattle_Move
  def pbFailsAgainstTarget?(user,target)
    return false if damagingMove?
    return !target.pbCanBurn?(user,true,self)
  end

  def pbEffectAgainstTarget(user,target)
    return if damagingMove?
    target.pbBurn(user)
  end

  def pbAdditionalEffect(user,target)
    return if target.damageState.substitute
    target.pbBurn(user) if target.pbCanBurn?(user,false,self)
  end
end

class PokeBattle_FreezeMove < PokeBattle_Move
  def pbFailsAgainstTarget?(user,target)
    return false if damagingMove?
    return !target.pbCanFreeze?(user,true,self)
  end

  def pbEffectAgainstTarget(user,target)
    return if damagingMove?
    target.pbFreeze
  end

  def pbAdditionalEffect(user,target)
    return if target.damageState.substitute
    target.pbFreeze if target.pbCanFreeze?(user,false,self)
  end
end

#===============================================================================
# Other problem-causing classes.
#===============================================================================
class PokeBattle_FlinchMove < PokeBattle_Move
  def flinchingMove?; return true; end

  def pbEffectAgainstTarget(user,target)
    return if damagingMove?
    target.pbFlinch(user)
  end

  def pbAdditionalEffect(user,target)
    return if target.damageState.substitute
    target.pbFlinch(user)
  end
end

class PokeBattle_ConfuseMove < PokeBattle_Move
  def pbFailsAgainstTarget?(user,target)
    return false if damagingMove?
    return !target.pbCanConfuse?(user,true,self)
  end

  def pbEffectAgainstTarget(user,target)
    return if damagingMove?
    target.pbConfuse
  end

  def pbAdditionalEffect(user,target)
    return if target.damageState.substitute
    return if !target.pbCanConfuse?(user,false,self)
    target.pbConfuse
  end

  def getScore(score,user,target,skill=100)
    canConfuse = target.pbCanConfuse?(user,false) && !target.hasActiveAbilityAI?(:MENTALBLOCK)
		if canConfuse
			score += 20
		elsif statusMove?
			score = 0
		end
    return score
  end
end

#===============================================================================
# Generic user's stat increase/decrease classes.
#===============================================================================
class PokeBattle_StatUpMove < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    return false if damagingMove?
    return !user.pbCanRaiseStatStage?(@statUp[0],user,self,true)
  end

  def pbEffectGeneral(user)
    return if damagingMove?
    user.pbRaiseStatStage(@statUp[0],@statUp[1],user)
  end

  def pbAdditionalEffect(user,target)
    if user.pbCanRaiseStatStage?(@statUp[0],user,self)
      user.pbRaiseStatStage(@statUp[0],@statUp[1],user)
    end
  end

  def getScore(score,user,target,skill=100)
    statToRaise = @statUp[0]
    statRaiseAmount = @statUp[1]

    # Stat up moves tend to be strong on the first turn
    if user.turnCount == 0
      if damagingMove?
        score += 20 
      else
        score += 50
      end	
    end

    score += 20 if statRaiseAmount > 1	 # Stat up moves that raise stats multiple times are better
    score += 20 if statRaiseAmount > 2	 # Stat up moves that raise stats multiple times are better

    # Wont use this move if it boosts an offensive
		# Stat that the pokemon can't actually use
    if !damagingMove?
		  return 0 if statToRaise == :ATTACK && !user.hasPhysicalAttack?
		  return 0 if statToRaise == :SPECIAL_ATTACK && !user.hasSpecialAttack?
    end
	
		score -= user.stages[statToRaise]*10

    score -= 10 if ![:ATTACK,:SPECIAL_ATTACK].include?(statToRaise) # Boost moves that dont up offensives are worse
		
		return score
	end
end

class PokeBattle_MultiStatUpMove < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    return false if damagingMove?
    failed = true
    for i in 0...@statUp.length/2
      next if !user.pbCanRaiseStatStage?(@statUp[i*2],user,self)
      failed = false
      break
    end
    if failed
      @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",user.pbThis))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    return if damagingMove?
    showAnim = true
    for i in 0...@statUp.length/2
      next if !user.pbCanRaiseStatStage?(@statUp[i*2],user,self)
      if user.pbRaiseStatStage(@statUp[i*2],@statUp[i*2+1],user,showAnim)
        showAnim = false
      end
    end
  end

  def pbAdditionalEffect(user,target)
    showAnim = true
    for i in 0...@statUp.length/2
      next if !user.pbCanRaiseStatStage?(@statUp[i*2],user,self)
      if user.pbRaiseStatStage(@statUp[i*2],@statUp[i*2+1],user,showAnim)
        showAnim = false
      end
    end
  end

  def getScore(score,user,target,skill=100)
    # Stat up moves tend to be strong on the first turn
    if user.turnCount == 0
      if damagingMove?
        score += 20 
      else
        score += 50
      end	
    end

    score += 20 # Multi stat up moves are generally strong

    # Analyze each stat up entry
		upsPhysicalAttack = false
		upsSpecialAttack = false
    totalStats = 0
		for i in 0...@statUp.length/2
			statSym = @statUp[i*2]
			score -= user.stages[statSym] * 10 # Reduce the score for each existing stage
			upsPhysicalAttack = true if statSym == :ATTACK
			upsSpecialAttack = true if statSym == :SPECIAL_ATTACK
      totalStats += 1
		end

    score += 20 if totalStats > 2	 # Stat up moves that raise 3 or more stats are better

		# Check if it boosts an offensive stat that the pokemon can't actually use
    if !damagingMove?
      return 0 if upsPhysicalAttack && !upsSpecialAttack && !user.hasPhysicalAttack?
      return 0 if !upsPhysicalAttack && upsSpecialAttack && !user.hasSpecialAttack?
    end

		score -= 10 if !upsPhysicalAttack && !upsSpecialAttack # Boost moves that dont up offensives are worse
		
		return score
	end
end

class PokeBattle_StatDownMove < PokeBattle_Move
  def pbEffectAfterAllHits(user,target)
    return if @battle.pbAllFainted?(target.idxOwnSide)
    showAnim = true
    for i in 0...@statDown.length/2
      next if !user.pbCanLowerStatStage?(@statDown[i*2],user,self)
      if user.pbLowerStatStage(@statDown[i*2],@statDown[i*2+1],user,showAnim)
        showAnim = false
      end
    end
  end

  def getScore
    average = 0
    count = 0
    for i in 0...@statUp.length/2
			statSym = @statUp[i*2]
			average += user.stages[statSym] * 10 # Reduce the score for each existing stage
      count += 1
		end

		score += average/count
    return score
  end
end

#===============================================================================
# Generic target's stat increase/decrease classes.
#===============================================================================
class PokeBattle_TargetStatDownMove < PokeBattle_Move
  attr_accessor :statDown

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

  def getScore(score,user,target,skill=100)
    if target.hasActiveAbilityAI?(:CONTRARY) && target.opposes?(user) && statusMove?
      return 0
    end

    reverse = target.hasActiveAbility?(:CONTRARY) && !target.opposes?(user)

    statReducing = @statDown[0]
    reductionAmount = @statDown[1]
    if statusMove?
			if !target.pbCanLowerStatStage?(statReducing,user)
				score = 0 if !reverse
			else
				score += target.stages[statReducing]*20
        score += 20 * (reductionAmount - 1)
        if statReducing == :ATTACK
				  if target.hasPhysicalAttack?
					  score += 20
				  else
					  score = 0
				  end
        elsif statReducing == :SPECIAL_ATTACK
          if target.hasSpecialAttack?
					  score += 20
				  else
					  score = 0
				  end
        elsif statReducing == :SPEED
          aspeed = pbRoughStat(user,:SPEED,skill)
          ospeed = pbRoughStat(target,:SPEED,skill)
          if !statReducing
            if aspeed < ospeed
              score += 20
            else
              score = 0
            end
          end
        end
			end
		else
			score += 20 if target.stages[statReducing] > 0
      if statReducing == :ATTACK
			  score += 20 if target.hasPhysicalAttack?
      elsif statReducing == :SPECIAL_ATTACK
        score += 20 if target.hasSpecialAttack?
      elsif statReducing == :SPEED
        aspeed = pbRoughStat(user,:SPEED,skill)
				ospeed = pbRoughStat(target,:SPEED,skill)
				score += 20 if aspeed < ospeed
      end
		end
    return score
  end
end

class PokeBattle_TargetMultiStatDownMove < PokeBattle_Move
  def pbFailsAgainstTarget?(user,target)
    return false if damagingMove?
    failed = true
    for i in 0...@statDown.length/2
      next if !target.pbCanLowerStatStage?(@statDown[i*2],user,self)
      failed = false
      break
    end
    if failed
      # NOTE: It's a bit of a faff to make sure the appropriate failure message
      #       is shown here, I know.
      canLower = false
      if target.hasActiveAbility?(:CONTRARY) && !@battle.moldBreaker
        for i in 0...@statDown.length/2
          next if target.statStageAtMax?(@statDown[i*2])
          canLower = true
          break
        end
        @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",user.pbThis)) if !canLower
      else
        for i in 0...@statDown.length/2
          next if target.statStageAtMin?(@statDown[i*2])
          canLower = true
          break
        end
        @battle.pbDisplay(_INTL("{1}'s stats won't go any lower!",user.pbThis)) if !canLower
      end
      if canLower
        target.pbCanLowerStatStage?(@statDown[0],user,self,true)
      end
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    return if damagingMove?
    showAnim = true
    for i in 0...@statDown.length/2
      next if !target.pbCanLowerStatStage?(@statDown[i*2],user,self)
      if target.pbLowerStatStage(@statDown[i*2],@statDown[i*2+1],user,showAnim)
        showAnim = false
      end
    end
  end

  def pbAdditionalEffect(user,target)
    return if target.damageState.substitute
    showAnim = true
    for i in 0...@statDown.length/2
      next if !target.pbCanLowerStatStage?(@statDown[i*2],user,self)
      if target.pbLowerStatStage(@statDown[i*2],@statDown[i*2+1],user,showAnim)
        showAnim = false
      end
    end
  end
end

#===============================================================================
# Fixed damage-inflicting move.
#===============================================================================
class PokeBattle_FixedDamageMove < PokeBattle_Move
  def pbFixedDamage(user,target); return 1; end

  def pbCalcTypeModSingle(moveType,defType,user,target)
		ret = super
		ret = Effectiveness::NORMAL_EFFECTIVE_ONE unless Effectiveness.ineffective?(ret)
		return ret
	end

  def pbCalcDamage(user,target,numTargets=1)
    target.damageState.critical   = false
    target.damageState.calcDamage = pbFixedDamage(user,target)
    target.damageState.calcDamage = 1 if target.damageState.calcDamage<1
  end
end

#===============================================================================
# Two turn move.
#===============================================================================
class PokeBattle_TwoTurnMove < PokeBattle_Move
  def chargingTurnMove?; return true; end

  # user.effects[PBEffects::TwoTurnAttack] is set to the move's ID if this
  # method returns true, or nil if false.
  # Non-nil means the charging turn. nil means the attacking turn.
  def pbIsChargingTurn?(user)
    @powerHerb = false
    @chargingTurn = false   # Assume damaging turn by default
    @damagingTurn = true
    # 0 at start of charging turn, move's ID at start of damaging turn
    if !user.effects[PBEffects::TwoTurnAttack]
      @powerHerb = user.hasActiveItem?(:POWERHERB)
      @chargingTurn = true
      @damagingTurn = @powerHerb
    end
    return !@damagingTurn   # Deliberately not "return @chargingTurn"
  end

  def pbDamagingMove?   # Stops damage being dealt in the first (charging) turn
    return false if !@damagingTurn
    return super
  end

  def pbAccuracyCheck(user,target)
    return true if !@damagingTurn
    return super
  end

  def pbInitialEffect(user,targets,hitNum)
    pbChargingTurnMessage(user,targets) if @chargingTurn
    if @chargingTurn && @damagingTurn   # Move only takes one turn to use
      pbShowAnimation(@id,user,targets,1)   # Charging anim
      targets.each { |b| pbChargingTurnEffect(user,b) }
      if @powerHerb
        # Moves that would make the user semi-invulnerable will hide the user
        # after the charging animation, so the "UseItem" animation shouldn't show
        # for it
        if !["0C9","0CA","0CB","0CC","0CD","0CE","14D"].include?(@function)
          @battle.pbCommonAnimation("UseItem",user)
        end
        @battle.pbDisplay(_INTL("{1} became fully charged due to its Power Herb!",user.pbThis))
        user.pbConsumeItem
      end
    end
    pbAttackingTurnMessage(user,targets) if @damagingTurn
  end

  def pbChargingTurnMessage(user,targets)
    @battle.pbDisplay(_INTL("{1} began charging up!",user.pbThis))
  end

  def pbAttackingTurnMessage(user,targets)
  end

  def pbChargingTurnEffect(user,target)
    # Skull Bash/Sky Drop are the only two-turn moves with an effect here, and
    # the latter just records the target is being Sky Dropped
  end

  def pbAttackingTurnEffect(user,target)
  end

  def pbEffectAgainstTarget(user,target)
    if @damagingTurn;    pbAttackingTurnEffect(user,target)
    elsif @chargingTurn; pbChargingTurnEffect(user,target)
    end
  end

  def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
    hitNum = 1 if @chargingTurn && !@damagingTurn   # Charging anim
    super
  end
end

#===============================================================================
# Healing move.
#===============================================================================
class PokeBattle_HealingMove < PokeBattle_Move
  def healingMove?;       return true; end
  def pbHealAmount(user); return 1;    end

  def pbMoveFailed?(user,targets)
    if user.hp==user.totalhp
      @battle.pbDisplay(_INTL("{1}'s HP is full!",user.pbThis))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    amt = pbHealAmount(user)
    user.pbRecoverHP(amt)
    @battle.pbDisplay(_INTL("{1}'s HP was restored.",user.pbThis))
  end
end

#===============================================================================
# Recoil move.
#===============================================================================
class PokeBattle_RecoilMove < PokeBattle_Move
  def recoilMove?;                 return true; end
  def pbRecoilDamage(user,target); return 1;    end

  def pbEffectAfterAllHits(user,target)
    return if target.damageState.unaffected
    return if !user.takesIndirectDamage?
    return if user.hasActiveAbility?(:ROCKHEAD)
    amt = pbRecoilDamage(user,target)
    amt = 1 if amt<1
    user.pbReduceHP(amt,false)
    @battle.pbDisplay(_INTL("{1} is damaged by recoil!",user.pbThis))
    user.pbItemHPHealCheck
  end
end

#===============================================================================
# Protect move.
#===============================================================================
class PokeBattle_ProtectMove < PokeBattle_Move
  def initialize(battle,move)
    super
    @sidedEffect = false
  end

  def pbChangeUsageCounters(user,specialUsage)
    oldVal = user.effects[PBEffects::ProtectRate]
    super
    user.effects[PBEffects::ProtectRate] = oldVal
  end

  def pbMoveFailed?(user,targets)
    if @sidedEffect
      if user.pbOwnSide.effects[@effect]
        user.effects[PBEffects::ProtectRate] = 1
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
    elsif user.effects[@effect]
      user.effects[PBEffects::ProtectRate] = 1
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    if (!@sidedEffect || Settings::MECHANICS_GENERATION <= 5) &&
        user.effects[PBEffects::ProtectRate]>1
      user.effects[PBEffects::ProtectRate] = 1
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbMoveFailedNoSpecial?(user,targets)
    if pbMoveFailedLastInRound?(user)
      user.effects[PBEffects::ProtectRate] = 1
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    if @sidedEffect
      user.pbOwnSide.effects[@effect] = true
    else
      user.effects[@effect] = true
    end
    user.effects[PBEffects::ProtectRate] *= (Settings::MECHANICS_GENERATION >= 6) ? 3 : 2
    pbProtectMessage(user)
  end

  def pbProtectMessage(user)
    if @sidedEffect
      @battle.pbDisplay(_INTL("{1} protected {2}!",@name,user.pbTeam(true)))
    else
      @battle.pbDisplay(_INTL("{1} protected itself!",user.pbThis))
    end
  end
end

#===============================================================================
# Weather-inducing move.
#===============================================================================
class PokeBattle_WeatherMove < PokeBattle_Move
  def initialize(battle,move)
    super
    @weatherType = :None
    @durationSet = 5
  end

  def pbMoveFailed?(user,targets)
    return false if damagingMove?
    return primevalWeatherPresent?
  end

  def primevalWeatherPresent?()
    case @battle.field.weather
    when :HarshSun
      @battle.pbDisplay(_INTL("The extremely harsh sunlight was not lessened at all!"))
      return true
    when :HeavyRain
      @battle.pbDisplay(_INTL("There is no relief from this heavy rain!"))
      return true
    when :StrongWinds
      @battle.pbDisplay(_INTL("The mysterious air current blows on regardless!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    @battle.pbStartWeather(user,@weatherType,@durationSet,false) if !primevalWeatherPresent?()
  end

  def getScore(score,user,target,skill=100)
    if damagingMove?
      score += 60
    else
      score += 20
    end
    if @battle.pbCheckGlobalAbility(:AIRLOCK) || @battle.pbCheckGlobalAbility(:CLOUDNINE)
			score = 0
		elsif @battle.pbWeather == :Sun
			score = 0
    end
    return score
  end
end

#===============================================================================
# Pledge move.
#===============================================================================
class PokeBattle_PledgeMove < PokeBattle_Move
  def pbOnStartUse(user,targets)
    @pledgeSetup = false; @pledgeCombo = false; @pledgeOtherUser = nil
    @comboEffect = nil; @overrideType = nil; @overrideAnim = nil
    # Check whether this is the use of a combo move
    @combos.each do |i|
      next if i[0]!=user.effects[PBEffects::FirstPledge]
      @battle.pbDisplay(_INTL("The two moves have become one! It's a combined move!"))
      @pledgeCombo = true
      @comboEffect = i[1]; @overrideType = i[2]; @overrideAnim = i[3]
      @overrideType = nil if !GameData::Type.exists?(@overrideType)
      break
    end
    return if @pledgeCombo
    # Check whether this is the setup of a combo move
    user.eachAlly do |b|
      next if @battle.choices[b.index][0]!=:UseMove || b.movedThisRound?
      move = @battle.choices[b.index][2]
      next if !move
      @combos.each do |i|
        next if i[0]!=move.function
        @pledgeSetup = true
        @pledgeOtherUser = b
        break
      end
      break if @pledgeSetup
    end
  end

  def pbDamagingMove?
    return false if @pledgeSetup
    return super
  end

  def pbBaseType(user)
    return @overrideType if @overrideType!=nil
    return super
  end

  def pbBaseDamage(baseDmg,user,target)
    baseDmg *= 2 if @pledgeCombo
    return baseDmg
  end

  def pbEffectGeneral(user)
    user.effects[PBEffects::FirstPledge] = 0
    return if !@pledgeSetup
    @battle.pbDisplay(_INTL("{1} is waiting for {2}'s move...",
       user.pbThis,@pledgeOtherUser.pbThis(true)))
    @pledgeOtherUser.effects[PBEffects::FirstPledge] = @function
    @pledgeOtherUser.effects[PBEffects::MoveNext]    = true
    user.lastMoveFailed = true   # Treated as a failure for Stomping Tantrum
  end

  def pbEffectAfterAllHits(user,target)
    return if !@pledgeCombo
    msg = nil; animName = nil
    case @comboEffect
    when :SeaOfFire   # Grass + Fire
      if user.pbOpposingSide.effects[PBEffects::SeaOfFire]==0
        user.pbOpposingSide.effects[PBEffects::SeaOfFire] = 4
        msg = _INTL("A sea of fire enveloped {1}!",user.pbOpposingTeam(true))
        animName = (user.opposes?) ? "SeaOfFire" : "SeaOfFireOpp"
      end
    when :Rainbow   # Fire + Water
      if user.pbOwnSide.effects[PBEffects::Rainbow]==0
        user.pbOwnSide.effects[PBEffects::Rainbow] = 4
        msg = _INTL("A rainbow appeared in the sky on {1}'s side!",user.pbTeam(true))
        animName = (user.opposes?) ? "RainbowOpp" : "Rainbow"
      end
    when :Swamp   # Water + Grass
      if user.pbOpposingSide.effects[PBEffects::Swamp]==0
        user.pbOpposingSide.effects[PBEffects::Swamp] = 4
        msg = _INTL("A swamp enveloped {1}!",user.pbOpposingTeam(true))
        animName = (user.opposes?) ? "Swamp" : "SwampOpp"
      end
    end
    @battle.pbDisplay(msg) if msg
    @battle.pbCommonAnimation(animName) if animName
  end

  def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
    return if @pledgeSetup   # No animation for setting up
    id = @overrideAnim if @overrideAnim
    return super
  end
end

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

class PokeBattle_TargetMultiStatUpMove < PokeBattle_Move
  def pbFailsAgainstTarget?(user,target)
    return false if damagingMove?
    failed = true
    for i in 0...@statUp.length/2
      next if !target.pbCanRaiseStatStage?(@statUp[i*2],user,self)
      failed = false
      break
    end
    if failed
      # NOTE: It's a bit of a faff to make sure the appropriate failure message
      #       is shown here, I know.
      canRaise = false
      if target.hasActiveAbility?(:CONTRARY) && !@battle.moldBreaker
        for i in 0...@statUp.length/2
          next if target.statStageAtMin?(@statUp[i*2])
          canRaise = true
          break
        end
        @battle.pbDisplay(_INTL("{1}'s stats won't go any lower!",target.pbThis)) if !canRaise
      else
        for i in 0...@statUp.length/2
          next if target.statStageAtMax?(@statUp[i*2])
          canRaise = true
          break
        end
        @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",target.pbThis)) if !canRaise
      end
      if canRaise
        target.pbCanRaiseStatStage?(@statUp[0],user,self,true)
      end
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    return if damagingMove?
    showAnim = true
    for i in 0...@statUp.length/2
      next if !target.pbCanRaiseStatStage?(@statUp[i*2],user,self)
      if target.pbRaiseStatStage(@statUp[i*2],@statUp[i*2+1],user,showAnim)
        showAnim = false
      end
    end
  end

  def pbAdditionalEffect(user,target)
    return if target.damageState.substitute
    showAnim = true
    for i in 0...@statUp.length/2
      next if !target.pbCanLowerStatStage?(@statUp[i*2],user,self)
      if target.pbRaiseStatStage(@statUp[i*2],@statUp[i*2+1],user,showAnim)
        showAnim = false
      end
    end
  end
  
  def getScore(score,user,target,skill=100)
    return 0 if target.opposes?(user)
      failed = true
    for i in 0...@statUp.length/2
      score -= target.stages[@statUp[i*2]] * 10
        failed = false if target.pbCanRaiseStatStage?(@statUp[i*2],user,self)
        break
      end
    score = 0 if failed
    return score
  end
end