class PokeBattle_Move
	def isEmpowered?; return false; end
  alias empowered? isEmpowered?
  
	def pbAllMissed(user, targets); end

  #=============================================================================
  # Animate the damage dealt, including lowering the HP
  #=============================================================================
  # Animate being damaged and losing HP (by a move)
  def pbAnimateHitAndHPLost(user,targets,fastHitAnimation=false)
    # Animate allies first, then foes
    animArray = []
    for side in 0...2   # side here means "allies first, then foes"
      targets.each do |b|
        next if b.damageState.unaffected || b.damageState.hpLost==0
        next if (side==0 && b.opposes?(user)) || (side==1 && !b.opposes?(user))
        oldHP = b.hp+b.damageState.hpLost
        PBDebug.log("[Move damage] #{b.pbThis} lost #{b.damageState.hpLost} HP (#{oldHP}=>#{b.hp})")
        effectiveness = 0
        if Effectiveness.resistant?(b.damageState.typeMod);          effectiveness = 1
        elsif Effectiveness.super_effective?(b.damageState.typeMod); effectiveness = 2
        end
		    effectiveness = -1 if Effectiveness.ineffective?(b.damageState.typeMod)
        effectiveness = 4 if Effectiveness.hyper_effective?(b.damageState.typeMod)
        animArray.push([b,oldHP,effectiveness])
      end
      if animArray.length>0
        @battle.scene.pbHitAndHPLossAnimation(animArray,fastHitAnimation)
        animArray.clear
      end
    end
  end
  
  #=============================================================================
  # Weaken the damage dealt (doesn't actually change a battler's HP)
  #=============================================================================
  def pbCheckDamageAbsorption(user,target)
    # Substitute will take the damage
    if target.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(user) &&
       (!user || user.index!=target.index)
      target.damageState.substitute = true
      return
    end
    # Disguise will take the damage
    if !@battle.moldBreaker && target.isSpecies?(:MIMIKYU) &&
       target.form==0 && target.ability == :DISGUISE
      target.damageState.disguise = true
      return
    end
	  # Ice Face will take the damage
    if !@battle.moldBreaker && target.species == :EISCUE &&
       target.form==0 && target.ability == :ICEFACE && physicalMove?
      target.damageState.iceface = true
      return
    end
  end
  
  def pbReduceDamage(user,target)
    damage = target.damageState.calcDamage
	  target.damageState.displayedDamage = damage
    # Substitute takes the damage
    if target.damageState.substitute
      damage = target.effects[PBEffects::Substitute] if damage>target.effects[PBEffects::Substitute]
      target.damageState.hpLost       = damage
      target.damageState.totalHPLost += damage
	  target.damageState.displayedDamage = damage
      return
    end
    # Disguise takes the damage
    if target.damageState.disguise
		  target.damageState.displayedDamage = 0
		  return
	  end
    # Ice Face takes the damage
    if target.damageState.iceface
      target.damageState.displayedDamage = 0
      return
    end
    # Target takes the damage
	  damageAdjusted = false
    if damage>=target.hp
      damage = target.hp
      # Survive a lethal hit with 1 HP effects
      if nonLethal?(user,target)
        damage -= 1
		    damageAdjusted = true
      elsif target.effects[PBEffects::Endure]
        target.damageState.endured = true
        damage -= 1
		    damageAdjusted = true
      elsif target.effects[PBEffects::EmpoweredEndure] > 0
		    target.damageState.endured = true
        damage -= 1
		    damageAdjusted = true
		    target.effects[PBEffects::EmpoweredEndure] -= 1
      elsif damage==target.totalhp
        if target.hasActiveAbility?(:STURDY) && !@battle.moldBreaker
          target.damageState.sturdy = true
          damage -= 1
		      damageAdjusted = true
        elsif target.hasActiveItem?(:FOCUSSASH) && target.hp==target.totalhp
          target.damageState.focusSash = true
          damage -= 1
		      damageAdjusted = true
        elsif target.hasActiveItem?(:FOCUSBAND) && @battle.pbRandom(100)<10
          target.damageState.focusBand = true
          damage -= 1
		      damageAdjusted = true
        end
      end
    end
	  target.damageState.displayedDamage = damage if damageAdjusted
    damage = 0 if damage<0
	  target.damageState.displayedDamage = 0 if target.damageState.displayedDamage < 0
    target.damageState.hpLost       = damage
    target.damageState.totalHPLost += damage
  end

  #=============================================================================
  # Messages upon being hit
  #=============================================================================
  def pbEffectivenessMessage(user,target,numTargets=1)
    return if target.damageState.disguise
	  return if target.damageState.iceface
	  return if defined?($PokemonSystem.effectiveness_messages) && $PokemonSystem.effectiveness_messages == 1
	  if Effectiveness.hyper_effective?(target.damageState.typeMod)
	  if numTargets > 1
        @battle.pbDisplay(_INTL("It's hyper effective on {1}!",target.pbThis(true)))
      else
        @battle.pbDisplay(_INTL("It's hyper effective!"))
      end
    elsif Effectiveness.super_effective?(target.damageState.typeMod)
      if numTargets > 1
        @battle.pbDisplay(_INTL("It's super effective on {1}!",target.pbThis(true)))
      else
        @battle.pbDisplay(_INTL("It's super effective!"))
      end
    elsif Effectiveness.barely_effective?(target.damageState.typeMod)
      if numTargets > 1
        @battle.pbDisplay(_INTL("It's barely effective on {1}...",target.pbThis(true)))
      else
        @battle.pbDisplay(_INTL("It's barely effective..."))
      end
    elsif Effectiveness.not_very_effective?(target.damageState.typeMod)
      if numTargets > 1
        @battle.pbDisplay(_INTL("It's not very effective on {1}...",target.pbThis(true)))
      else
        @battle.pbDisplay(_INTL("It's not very effective..."))
      end
    end
  end
  
  def pbHitEffectivenessMessages(user,target,numTargets=1)
    return if target.damageState.disguise
  	return if target.damageState.iceface
    if target.damageState.substitute
      @battle.pbDisplay(_INTL("The substitute took damage for {1}!",target.pbThis(true)))
    end
    if target.damageState.critical
      if numTargets>1
        @battle.pbDisplay(_INTL("A critical hit on {1}!",target.pbThis(true)))
      else
        @battle.pbDisplay(_INTL("A critical hit!"))
      end
    end
    # Effectiveness message, for moves with 1 hit
    if !multiHitMove? && user.effects[PBEffects::ParentalBond]==0
      pbEffectivenessMessage(user,target,numTargets)
    end
    if target.damageState.substitute && target.effects[PBEffects::Substitute]==0
      target.effects[PBEffects::Substitute] = 0
      @battle.pbDisplay(_INTL("{1}'s substitute faded!",target.pbThis))
    end
  end
  
  def pbEndureKOMessage(target)
    if target.damageState.disguise
      @battle.pbShowAbilitySplash(target)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        @battle.pbDisplay(_INTL("Its disguise served it as a decoy!"))
      else
        @battle.pbDisplay(_INTL("{1}'s disguise served it as a decoy!",target.pbThis))
      end
      @battle.pbHideAbilitySplash(target)
      target.pbChangeForm(1,_INTL("{1}'s disguise was busted!",target.pbThis))
	  elsif target.damageState.iceface
      @battle.pbShowAbilitySplash(target)
      target.pbChangeForm(1,_INTL("{1} transformed!",target.pbThis))
      @battle.pbHideAbilitySplash(target)
    elsif target.damageState.endured
      @battle.pbDisplay(_INTL("{1} endured the hit!",target.pbThis))
    elsif target.damageState.sturdy
      @battle.pbShowAbilitySplash(target)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        @battle.pbDisplay(_INTL("{1} endured the hit!",target.pbThis))
      else
        @battle.pbDisplay(_INTL("{1} hung on with Sturdy!",target.pbThis))
      end
      @battle.pbHideAbilitySplash(target)
    elsif target.damageState.focusSash
      @battle.pbCommonAnimation("UseItem",target)
      @battle.pbDisplay(_INTL("{1} hung on using its Focus Sash!",target.pbThis))
      target.pbConsumeItem
    elsif target.damageState.focusBand
      @battle.pbCommonAnimation("UseItem",target)
      @battle.pbDisplay(_INTL("{1} hung on using its Focus Band!",target.pbThis))
    end
  end
  
  # Checks whether the move should have modified priority
	def priorityModification(user,target); return 0; end
	
	# Returns whether the move will be a critical hit.
	def pbIsCritical?(user,target)
		return false if target.pbOwnSide.effects[PBEffects::LuckyChant]>0
		# Set up the critical hit ratios
		ratios = [16,8,4,2,1]
		c = 0
		# Ability effects that alter critical hit rate
		if c>=0 && user.abilityActive?
		  c = BattleHandlers.triggerCriticalCalcUserAbility(user.ability,user,target,c)
		end
		if c>=0 && target.abilityActive? && !@battle.moldBreaker
		  c = BattleHandlers.triggerCriticalCalcTargetAbility(target.ability,user,target,c)
		end
		# Item effects that alter critical hit rate
		if c>=0 && user.itemActive?
		  c = BattleHandlers.triggerCriticalCalcUserItem(user.item,user,target,c)
		end
		if c>=0 && target.itemActive?
		  c = BattleHandlers.triggerCriticalCalcTargetItem(target.item,user,target,c)
		end
		return false if c<0
		# Move-specific "always/never a critical hit" effects
		case pbCritialOverride(user,target)
		when 1  then return true
		when -1 then return false
		end
		# Other effects
		return true if c>50   # Merciless
		return true if user.effects[PBEffects::LaserFocus]>0 ||
			user.effects[PBEffects::EmpoweredLaserFocus]
		return false if user.boss?
		c += 1 if highCriticalRate?
		c += user.effects[PBEffects::FocusEnergy]
		c += 1 if user.effects[PBEffects::LuckyStar]
		c = ratios.length-1 if c>=ratios.length
		echoln("Critical hit stage: #{c}")
		# Calculation
		return @battle.pbRandom(ratios[c])==0
    end
  
  #=============================================================================
  # Additional effect chance
  #=============================================================================
  def pbAdditionalEffectChance(user,target,effectChance=0)
    return 0 if target.hasActiveAbility?(:SHIELDDUST) && !@battle.moldBreaker
	  return 0 if target.effects[PBEffects::Enlightened]
    ret = (effectChance>0) ? effectChance : @addlEffect
    if Settings::MECHANICS_GENERATION >= 6 || @function != "0A4"   # Secret Power
      ret *= 2 if user.hasActiveAbility?(:SERENEGRACE) ||
                  user.pbOwnSide.effects[PBEffects::Rainbow]>0
    end
    ret = 100 if $DEBUG && Input.press?(Input::CTRL)
    return ret
  end
  
  # NOTE: Flinching caused by a move's effect is applied in that move's code,
  #       not here.
  def pbFlinchChance(user,target)
    return 0 if flinchingMove?
    return 0 if target.hasActiveAbility?(:SHIELDDUST) && !@battle.moldBreaker
	  return 0 if target.effects[PBEffects::Enlightened]
    ret = 0
    if user.hasActiveAbility?(:STENCH,true)
      ret = 10
    elsif user.hasActiveItem?([:KINGSROCK,:RAZORFANG],true)
      ret = 10
    end
    ret *= 2 if user.hasActiveAbility?(:SERENEGRACE) ||
                user.pbOwnSide.effects[PBEffects::Rainbow]>0
    return ret
  end
  
  def pbGetAttackStats(user,target)
    if specialMove? || (user.hasActiveAbility?(:MYSTICFIST) && punchingMove?)
      return user.spatk, user.stages[:SPECIAL_ATTACK]+6
    end
    return user.attack, user.stages[:ATTACK]+6
  end

  def pbGetDefenseStats(user,target)
    if specialMove? || (user.hasActiveAbility?(:MYSTICFIST) && punchingMove?)
      return target.spdef, target.stages[:SPECIAL_DEFENSE]+6
    end
    return target.defense, target.stages[:DEFENSE]+6
  end
  
  def pbCalcDamage(user,target,numTargets=1)
    return if statusMove?
    if target.damageState.disguise
      target.damageState.calcDamage = 1
      return
    end
    stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
    stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
    # Get the move's type
    type = @calcType   # nil is treated as physical
    # Calculate whether this hit deals critical damage
    target.damageState.critical = pbIsCritical?(user,target)
    # Calcuate base power of move
    baseDmg = pbBaseDamage(@baseDamage,user,target)
    # Calculate user's attack stat
    atk, atkStage = pbGetAttackStats(user,target)
    if !target.hasActiveAbility?(:UNAWARE) || @battle.moldBreaker
      atkStage = 6 if target.damageState.critical && atkStage<6
	    calc = stageMul[atkStage].to_f/stageDiv[atkStage].to_f
	    calc = (calc.to_f + 1.0)/2.0 if user.boss?
      atk = (atk.to_f*calc).floor
    end
	  # if atkStage > 6 && user.paralyzed?
		#   atkStage = 6
	  # end
    # Calculate target's defense stat
    defense, defStage = pbGetDefenseStats(user,target)
    if !user.hasActiveAbility?(:UNAWARE)
      if defStage > 6 && (target.damageState.critical || user.hasActiveAbility?(:INFILTRATOR))
        defStage = 6
      end
	    calc = stageMul[defStage].to_f/stageDiv[defStage].to_f
	    calc = (calc.to_f + 1.0)/2.0 if target.boss?
      defense = (defense.to_f*calc).floor
    end
    # if defStage > 6 && target.paralyzed?
    #   defStage = 6
    # end
    # Calculate all multiplier effects
    multipliers = {
      :base_damage_multiplier  => 1.0,
      :attack_multiplier       => 1.0,
      :defense_multiplier      => 1.0,
      :final_damage_multiplier => 1.0
    }
    pbCalcDamageMultipliers(user,target,numTargets,type,baseDmg,multipliers)
    # Main damage calculation
    baseDmg = [(baseDmg * multipliers[:base_damage_multiplier]).round, 1].max
    atk     = [(atk     * multipliers[:attack_multiplier]).round, 1].max
    defense = [(defense * multipliers[:defense_multiplier]).round, 1].max
    damage  = (((2.0 * user.level / 5 + 2).floor * baseDmg * atk / defense).floor / 50).floor + 2
    damage  = [(damage  * multipliers[:final_damage_multiplier]).round, 1].max
    target.damageState.calcDamage = damage
  end

  
	def pbCalcDamageMultipliers(user,target,numTargets,type,baseDmg,multipliers)
		# Global abilities
		if (@battle.pbCheckGlobalAbility(:DARKAURA) && type == :DARK) ||
		   (@battle.pbCheckGlobalAbility(:FAIRYAURA) && type == :FAIRY)
		  if @battle.pbCheckGlobalAbility(:AURABREAK)
			multipliers[:base_damage_multiplier] *= 2 / 3.0
		  else
			multipliers[:base_damage_multiplier] *= 4 / 3.0
		  end
		end
		if (@battle.pbCheckGlobalAbility(:RUINOUS))
			multipliers[:base_damage_multiplier] *= 1.2
		end
		# Ability effects that alter damage
		if user.abilityActive?
		  BattleHandlers.triggerDamageCalcUserAbility(user.ability,
			 user,target,self,multipliers,baseDmg,type)
		end
		if !@battle.moldBreaker
		  # NOTE: It's odd that the user's Mold Breaker prevents its partner's
		  #       beneficial abilities (i.e. Flower Gift boosting Atk), but that's
		  #       how it works.
		  user.eachAlly do |b|
			next if !b.abilityActive?
			BattleHandlers.triggerDamageCalcUserAllyAbility(b.ability,
			   user,target,self,multipliers,baseDmg,type)
		  end
		  if target.abilityActive?
			BattleHandlers.triggerDamageCalcTargetAbility(target.ability,
			   user,target,self,multipliers,baseDmg,type) if !@battle.moldBreaker
			BattleHandlers.triggerDamageCalcTargetAbilityNonIgnorable(target.ability,
			   user,target,self,multipliers,baseDmg,type)
		  end
		  target.eachAlly do |b|
			next if !b.abilityActive?
			BattleHandlers.triggerDamageCalcTargetAllyAbility(b.ability,
			   user,target,self,multipliers,baseDmg,type)
		  end
		end
		# Item effects that alter damage
		if user.itemActive?
		  BattleHandlers.triggerDamageCalcUserItem(user.item,
			 user,target,self,multipliers,baseDmg,type)
		end
		if target.itemActive?
		  BattleHandlers.triggerDamageCalcTargetItem(target.item,
			 user,target,self,multipliers,baseDmg,type)
		end
		# Parental Bond's second attack
		if user.effects[PBEffects::ParentalBond]==1
		  multipliers[:base_damage_multiplier] /= 4
		end
		# Other
		if user.effects[PBEffects::MeFirst]
		  multipliers[:base_damage_multiplier] *= 1.5
		end
		if user.effects[PBEffects::HelpingHand] && !self.is_a?(PokeBattle_Confusion)
		  multipliers[:base_damage_multiplier] *= 1.5
		end
		if user.effects[PBEffects::Charge]>0 && type == :ELECTRIC
		  multipliers[:base_damage_multiplier] *= 2
		end
		# Mud Sport
		if type == :ELECTRIC
		  @battle.eachBattler do |b|
			next if !b.effects[PBEffects::MudSport]
			multipliers[:base_damage_multiplier] /= 3
			break
		  end
		  if @battle.field.effects[PBEffects::MudSportField]>0
			multipliers[:base_damage_multiplier] /= 3
		  end
		end
		# Water Sport
		if type == :FIRE
		  @battle.eachBattler do |b|
			next if !b.effects[PBEffects::WaterSport]
			multipliers[:base_damage_multiplier] /= 3
			break
		  end
		  if @battle.field.effects[PBEffects::WaterSportField]>0
			multipliers[:base_damage_multiplier] /= 3
		  end
		end
		# Terrain moves
		case @battle.field.terrain
		when :Electric
		  multipliers[:base_damage_multiplier] *= 1.3 if type == :ELECTRIC && user.affectedByTerrain?
		when :Grassy
		  multipliers[:base_damage_multiplier] *= 1.3 if type == :GRASS && user.affectedByTerrain?
		when :Psychic
		  multipliers[:base_damage_multiplier] *= 1.3 if type == :PSYCHIC && user.affectedByTerrain?
		when :Misty
		  multipliers[:base_damage_multiplier] *= 1.3 if type == :FAIRY && target.affectedByTerrain?
		end
		# Multi-targeting attacks
		if numTargets>1
		  multipliers[:final_damage_multiplier] *= 0.75
		end
		# Weather
		case @battle.pbWeather
		when :Sun, :HarshSun
		  if type == :FIRE
			multipliers[:final_damage_multiplier] *= 1.5
		  elsif type == :WATER
			multipliers[:final_damage_multiplier] /= 2
		  end
		when :Rain, :HeavyRain
		  if type == :FIRE
			multipliers[:final_damage_multiplier] /= 2
		  elsif type == :WATER
			multipliers[:final_damage_multiplier] *= 1.5
		  end
    when :Swarm
		  if type == :DRAGON || type == :BUG
			  multipliers[:final_damage_multiplier] *= 1.5
		  end
		when :Sandstorm
		  if target.pbHasType?(:ROCK) && specialMove? && @function != "122"   # Psyshock
			  multipliers[:defense_multiplier] *= 1.5
		  end
		when :Hail
		  if target.pbHasType?(:ICE) && physicalMove?
			  multipliers[:defense_multiplier] *= 1.5
		  end
		end
		# Critical hits
		if target.damageState.critical
		  if Settings::NEW_CRITICAL_HIT_RATE_MECHANICS
			  multipliers[:final_damage_multiplier] *= 1.5
		  else
			  multipliers[:final_damage_multiplier] *= 2
		  end
		end
    # Random variance
    if !self.is_a?(PokeBattle_Confusion) && !self.is_a?(PokeBattle_Charm)
      multipliers[:final_damage_multiplier] *= 0.9
    end
		# STAB
    unless user.pbOwnedByPlayer? && @battle.curses.include?(:DULLED)
      if type && user.pbHasType?(type)
        stab = 1.5
        if user.hasActiveAbility?(:ADAPTED)
          stab *= 4.0/3.0
        end
        multipliers[:final_damage_multiplier] *= stab
      end
    end
		# Type effectiveness
		typeEffect = target.damageState.typeMod.to_f / Effectiveness::NORMAL_EFFECTIVE
		multipliers[:final_damage_multiplier] *= typeEffect
		# Burn
		if user.burned? && physicalMove? && damageReducedByBurn? &&
		   !user.hasActiveAbility?(:GUTS) && !user.hasActiveAbility?(:BURNHEAL)
		  if !user.boss?
			  multipliers[:final_damage_multiplier] *= 2.0/3.0
		  else
			  multipliers[:final_damage_multiplier] *= 4.0/5.0
		  end
		end
		# Poison
		if user.poisoned? && user.statusCount == 0 && specialMove? && damageReducedByBurn? &&
		   !user.hasActiveAbility?(:AUDACITY) && !user.hasActiveAbility?(:POISONHEAL)
		  if !user.boss?
			  multipliers[:final_damage_multiplier] *= 2.0/3.0
		  else
			  multipliers[:final_damage_multiplier] *= 4.0/5.0
		  end
		end
		# Chill
		if target.frozen?
		  if !target.boss?
			  multipliers[:final_damage_multiplier] *= 4.0/3.0
		  else
			  multipliers[:final_damage_multiplier] *= 5.0/4.0
		  end
		end
    # Numb
		if user.paralyzed?
		  if !user.boss?
			  multipliers[:final_damage_multiplier] *= 3.0/4.0
		  else
			  multipliers[:final_damage_multiplier] *= 17.0/20.0
		  end
		end
		# Aurora Veil, Reflect, Light Screen
		if !ignoresReflect? && !target.damageState.critical &&
		   !user.hasActiveAbility?(:INFILTRATOR)
		  if target.pbOwnSide.effects[PBEffects::AuroraVeil] > 0
        if @battle.pbSideBattlerCount(target)>1
          multipliers[:final_damage_multiplier] *= 2 / 3.0
        else
          multipliers[:final_damage_multiplier] /= 2
        end
		  elsif target.pbOwnSide.effects[PBEffects::Reflect] > 0 && physicalMove?
        if @battle.pbSideBattlerCount(target)>1
          multipliers[:final_damage_multiplier] *= 2 / 3.0
        else
          multipliers[:final_damage_multiplier] /= 2
        end
		  elsif target.pbOwnSide.effects[PBEffects::LightScreen] > 0 && specialMove?
        if @battle.pbSideBattlerCount(target) > 1
          multipliers[:final_damage_multiplier] *= 2 / 3.0
        else
          multipliers[:final_damage_multiplier] /= 2
        end
		  end
		end
    if target.effects[PBEffects::StunningCurl]
      multipliers[:final_damage_multiplier] /= 2
    end
		# Move-specific base damage modifiers
		multipliers[:base_damage_multiplier] = pbBaseDamageMultiplier(multipliers[:base_damage_multiplier], user, target)
		# Move-specific final damage modifiers
		multipliers[:final_damage_multiplier] = pbModifyDamage(multipliers[:final_damage_multiplier], user, target)
  end
  
  #=============================================================================
  # Type effectiveness calculation
  #=============================================================================
  def pbCalcTypeModSingle(moveType,defType,user,target)
    ret = Effectiveness.calculate_one(moveType, defType)
    # Ring Target
    if target.hasActiveItem?(:RINGTARGET)
      ret = Effectiveness::NORMAL_EFFECTIVE_ONE if Effectiveness.ineffective_type?(moveType, defType)
    end
    # Foresight/Scrappy
    if user.hasActiveAbility?(:SCRAPPY) || target.effects[PBEffects::Foresight]
      ret = Effectiveness::NORMAL_EFFECTIVE_ONE if defType == :GHOST &&
                                                   Effectiveness.ineffective_type?(moveType, defType)
    end
    # Miracle Eye
    if target.effects[PBEffects::MiracleEye]
      ret = Effectiveness::NORMAL_EFFECTIVE_ONE if defType == :DARK &&
                                                   Effectiveness.ineffective_type?(moveType, defType)
    end
    # Creep Out
    if target.effects[PBEffects::CreepOut] && moveType == :BUG
      ret *= 2
    end
    # Delta Stream's weather
    if @battle.pbWeather == :StrongWinds
      ret = Effectiveness::NORMAL_EFFECTIVE_ONE if defType == :FLYING &&
                                                   Effectiveness.super_effective_type?(moveType, defType)
    end
    # Grounded Flying-type Pokémon become susceptible to Ground moves
    if !target.airborne?
      ret = Effectiveness::NORMAL_EFFECTIVE_ONE if defType == :FLYING && moveType == :GROUND
    end
	
    # Inured
    if target.effects[PBEffects::Inured]
      ret /= 2 if Effectiveness.super_effective_type?(moveType, defType)
    end
    
    # Tar Shot
    if target.effects[PBEffects::TarShot] && moveType == :FIRE
        ret *= 2
      end
    
    # Break Through
    if user.hasActiveAbility?(:BREAKTHROUGH) &&
        Effectiveness.ineffective_type?(moveType, defType)
      ret = Effectiveness::NORMAL_EFFECTIVE_ONE
    end
    
    if @battle.bossBattle? && ret == 0
      ret = 0.5
      @battle.pbDisplay(_INTL("Within the avatar's aura, immunities are resistances!"))
    end
    return ret
  end
  
  def pbCalcTypeMod(moveType,user,target)
    return Effectiveness::NORMAL_EFFECTIVE if !moveType
    return Effectiveness::NORMAL_EFFECTIVE if moveType == :GROUND && target.pbHasType?(:FLYING) && target.hasActiveItem?(:IRONBALL)
    # Determine types
    tTypes = target.pbTypes(true)
    # Get effectivenesses
    typeMods = [Effectiveness::NORMAL_EFFECTIVE_ONE] * 3   # 3 types max
    if moveType == :SHADOW
      if target.shadowPokemon?
        typeMods[0] = Effectiveness::NOT_VERY_EFFECTIVE_ONE
      else
        typeMods[0] = Effectiveness::SUPER_EFFECTIVE_ONE
      end
    else
      tTypes.each_with_index do |type,i|
        typeMods[i] = pbCalcTypeModSingle(moveType,type,user,target)
      end
    end
    # Multiply all effectivenesses together
    ret = 1
    typeMods.each { |m| ret *= m }
	
    # Late boss specific immunity abilities check
    if @battle.bossBattle?
      if pbImmunityByAbility(user,target)
        if damagingMove?
          @battle.pbDisplay(_INTL("Except, within the avatar's aura, immunities are resistances!"))
        else
          @battle.pbDisplay(_INTL("Except, within the avatar's aura, the move can pierce the immunity!"))
        end
        ret /= 2
      elsif damagingMove? && moveType == :GROUND && target.airborne? && !hitsFlyingTargets? && target.hasLevitate? && !@battle.moldBreaker
        @battle.pbDisplay(_INTL("Except, within the avatar's aura, immunities are resistances!"))
        ret /= 2
      end
    end
	
    # Type effectiveness changing curses
    @battle.curses.each do |curse|
      ret = @battle.triggerEffectivenessChangeCurseEffect(curse,moveType,user,target,ret)
    end
	
    return ret
  end
  
  # Accuracy calculations for one-hit KO moves and "always hit" moves are
  # handled elsewhere.
  def pbAccuracyCheck(user,target)
    # "Always hit" effects and "always hit" accuracy
    return true if target.effects[PBEffects::Telekinesis]>0
    return true if target.effects[PBEffects::Minimize] && tramplesMinimize?(1)
    baseAcc = pbBaseAccuracy(user,target)
    return true if baseAcc==0
    # Calculate all multiplier effects
    modifiers = {}
    modifiers[:base_accuracy]  = baseAcc
    modifiers[:accuracy_stage] = user.stages[:ACCURACY]
    modifiers[:evasion_stage]  = target.stages[:EVASION]
    modifiers[:accuracy_multiplier] = 1.0
    modifiers[:evasion_multiplier]  = 1.0
    pbCalcAccuracyModifiers(user,target,modifiers)
    # Check if move can't miss
    return true if modifiers[:base_accuracy] == 0
    # Calculation
    accStage = [[modifiers[:accuracy_stage], -6].max, 6].min + 6
    evaStage = [[modifiers[:evasion_stage], -6].max, 6].min + 6
    stageMul = [3,3,3,3,3,3, 3, 4,5,6,7,8,9]
    stageDiv = [9,8,7,6,5,4, 3, 3,3,3,3,3,3]
    accuracy = 100.0 * stageMul[accStage].to_f / stageDiv[accStage].to_f
    evasion  = 100.0 * stageMul[evaStage].to_f / stageDiv[evaStage].to_f
    accuracy = (accuracy.to_f * modifiers[:accuracy_multiplier].to_f).round
    if user.boss?
        accuracy = (accuracy.to_f + 100.0) / 2.0
      end
      evasion  = (evasion.to_f  * modifiers[:evasion_multiplier].to_f).round
    if target.boss?
        evasion = (evasion.to_f + 100.0) / 2.0
      end
      evasion = 1 if evasion < 1
      # Calculation
    calc = accuracy.to_f / evasion.to_f
      return @battle.pbRandom(100) < modifiers[:base_accuracy] * calc
    end
  
  def pbDisplayUseMessage(user,targets=[])
    # Trigger dialogue for a trainer or the player about to use a move
    if @battle.opponent
      if user.pbOwnedByPlayer?
        @battle.opponent.each_with_index do |trainer_speaking,idxTrainer|
          @battle.scene.showTrainerDialogue(idxTrainer) { |policy,dialogue|
            PokeBattle_AI.triggerPlayerIsUsingMoveDialogue(policy,user,self,targets,trainer_speaking,dialogue)
          }
        end	
      else
        idxTrainer = @battle.pbGetOwnerIndexFromBattlerIndex(user.index)
        trainer_speaking = @battle.opponent[idxTrainer] || nil
        if !trainer_speaking.nil?
          @battle.scene.showTrainerDialogue(idxTrainer) { |policy,dialogue|
            PokeBattle_AI.triggerTrainerIsUsingMoveDialogue(policy,user,self,targets,trainer_speaking,dialogue)
          }
        end
      end
    end
    
    if isEmpowered?
      pbMessage(_INTL("\\ts[{3}]{1} used <c2=06644bd2>{2}</c2>!",user.pbThis,@name,MessageConfig.pbGetTextSpeed() * 2))
    else
      @battle.pbDisplayBrief(_INTL("{1} used {2}!",user.pbThis,@name))
    end
    if damagingMove? && !multiHitMove?
      targets.each do |target|
        bp = pbBaseDamage(baseDamage,user,target).floor
        if bp != baseDamage
          if targets.length == 1
            @battle.pbDisplayBrief(_INTL("Its base power was adjusted to {1}!",bp))
          else
            @battle.pbDisplayBrief(_INTL("Its base power was adjusted to {1} against {2}!",bp,target.pbThis(true)))
          end
        end
      end
    end
  end
  
  # Reset move usage counters (child classes can increment them).
  def pbChangeUsageCounters(user,specialUsage)
    user.effects[PBEffects::FuryCutter]   = 0
	  user.effects[PBEffects::IceBall]   = 0
  	user.effects[PBEffects::RollOut]   = 0
    user.effects[PBEffects::ParentalBond] = 0
    user.effects[PBEffects::ProtectRate]  = 1
    @battle.field.effects[PBEffects::FusionBolt]  = false
    @battle.field.effects[PBEffects::FusionFlare] = false
  end
  
  #=============================================================================
  # Check if target is immune to the move because of its ability
  #=============================================================================
  def pbImmunityByAbility(user,target)
    return false if @battle.moldBreaker
    ret = false
    if target.abilityActive?
      ret = BattleHandlers.triggerMoveImmunityTargetAbility(target.ability,
         user,target,self,@calcType,@battle)
    end
    if !ret
      target.eachAlly do |b|
        next if !b.abilityActive?
        ret = BattleHandlers.triggerMoveImmunityAllyAbility(b.ability,user,target,self,@calcType,@battle,b)
        break if ret
      end
    end
    return ret
  end
  
  def slashMove?;        return @flags[/p/]; end

  def contactMove?; return physicalMove? end

	# NOTE: Flinching caused by a move's effect is applied in that move's code,
  #       not here.
  def pbFlinchChance(user,target)
    return 0 if flinchingMove?
    return 0 if target.hasActiveAbility?(:SHIELDDUST) && !@battle.moldBreaker
    ret = 0
    if user.hasActiveAbility?(:STENCH,true)
      ret = 50
    elsif user.hasActiveItem?([:KINGSROCK,:RAZORFANG],true)
      ret = 10
    end
    ret *= 2 if user.hasActiveAbility?(:SERENEGRACE) ||
                user.pbOwnSide.effects[PBEffects::Rainbow]>0
    return ret
  end
end