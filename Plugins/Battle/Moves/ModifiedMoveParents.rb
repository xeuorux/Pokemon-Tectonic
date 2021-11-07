#===============================================================================
# Pseudomove for confusion damage.
#===============================================================================
class PokeBattle_Confusion < PokeBattle_Move
  def initialize(battle,move)
    @battle     = battle
    @realMove   = move
    @id         = 0
    @name       = ""
    @function   = "000"
    @baseDamage = 50
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

#===============================================================================
# Generic target's stat increase/decrease classes.
#===============================================================================
class PokeBattle_TargetStatDownMove < PokeBattle_Move
	attr_accessor :statDown
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
	echoln (_INTL("hitnum = {1}",hitNum))
    super
  end
end