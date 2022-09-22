class PokeBattle_Move
  def pbAromatherapyHeal(pkmn,battler=nil)
		if battler
		  	battler.pbCureStatus()
		else
			oldStatus = (battler) ? battler.status : pkmn.status
			curedName = (battler) ? battler.pbThis : pkmn.name
      pkmn.status      = :NONE
      pkmn.statusCount = 0
			case oldStatus
        when :SLEEP
          @battle.pbDisplay(_INTL("{1} was woken from sleep.",curedName))
        when :POISON
          @battle.pbDisplay(_INTL("{1} was cured of its poisoning.",curedName))
        when :BURN
          @battle.pbDisplay(_INTL("{1}'s burn was healed.",curedName))
        when :PARALYSIS
          @battle.pbDisplay(_INTL("{1} was cured of numb.",curedName))
        when :FROZEN
          @battle.pbDisplay(_INTL("{1} warmed up.",curedName))
        when :FROSTBITE
          @battle.pbDisplay(_INTL("{1} frostbite was healed.",curedName))
        when :FLUSTERED
          @battle.pbDisplay(_INTL("{1} is no longer flustered.",curedName))
        when :FROZEN
          @battle.pbDisplay(_INTL("{1} is no longer mystified.",curedName))
        end
    	end
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
end

class PokeBattle_ConfuseMove < PokeBattle_Move
  def getScore(score,user,target,skill=100)
    canConfuse = target.pbCanConfuse?(user,false) && !target.hasActiveAbilityAI?(:MENTALBLOCK)
		if canConfuse
			score += 20
		elsif move.statusMove?
			score = 0
		end
    return score
  end
end

#===============================================================================
# Generic target's stat increase/decrease classes.
#===============================================================================
class PokeBattle_TargetStatDownMove < PokeBattle_Move
	attr_accessor :statDown

  def getScore(score,user,target,skill=100)
    if target.hasActiveAbilityAI?(:CONTRARY) && target.opposes?(user) && statusMove?
      echoln("#{user.pbThis} doesn't want to use a target stat down move due to thinking the target #{target.pbThis(true)} has Contrary.")
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

class PokeBattle_FixedDamageMove
	def pbCalcTypeModSingle(moveType,defType,user,target)
		ret = super
		ret = Effectiveness::NORMAL_EFFECTIVE_ONE unless Effectiveness.ineffective?(ret)
		return ret
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

class PokeBattle_StatDownMove < PokeBattle_Move
	def pbEffectWhenDealingDamage(user,target); end

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
end

class PokeBattle_MultiStatUpMove
	def getScore(score,user,target,skill=100)
		score += 50 if user.turnCount == 0	 # Multi-stat up moves are often great on the first turn
	
		# Return 0 if all the stats upped by this move are already at max
		stagesMaxxed = true
		upsPhysicalAttack = false
		upsSpecialAttack = false
		for i in 0...@statUp.length/2
			statSym = @statUp[i*2]
			stagesMaxxed = false if !user.statStageAtMax?(statSym)
			score -= user.stages[statSym]*10 # Reduce the score for each existing stage
			upsPhysicalAttack = true if statSym == :ATTACK
			upsSpecialAttack = true if statSym == :SPECIAL_ATTACK
		end
		return 0 if stagesMaxxed

		# Wont use this move if it boosts an offensive
		# Stat that the pokemon can't actually use
		return 0 if upsPhysicalAttack && !upsSpecialAttack && !user.hasPhysicalAttack?
		return 0 if !upsPhysicalAttack && upsSpecialAttack && !user.hasSpecialAttack?

		score -= 10 if !upsPhysicalAttack && !upsSpecialAttack # Boost moves that dont up offensives are worse
		
		return score
	end
end

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
# Protect move.
#===============================================================================
class PokeBattle_ProtectMove < PokeBattle_Move
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
end