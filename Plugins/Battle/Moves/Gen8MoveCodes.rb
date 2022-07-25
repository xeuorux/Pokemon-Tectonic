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
	##echoln target.opposes?(user)
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


#===============================================================================
# Chance to paralyze the target. Fail if the user is not a Morpeko.
# If the user is a Morpeko-Hangry, this move will be Dark type. (Aura Wheel)
#===============================================================================
class PokeBattle_Move_176 < PokeBattle_ParalysisMove
  def pbMoveFailed?(user,targets)
    if @id == :AURAWHEEL && user.species != :MORPEKO && user.effects[PBEffects::TransformSpecies] != :MORPEKO
      @battle.pbDisplay(_INTL("But {1} can't use the move!",user.pbThis))
      return true
    end
    return false
  end

  def pbBaseType(user)
    ret = :NORMAL
    case user.form
    when 0
      ret = :ELECTRIC
    when 1
      ret = :DARK
    end
    return ret
  end
  
  def getScore(score,user,target,skill=100)
	score = getParalysisMoveScore(score,user,target,skill=100)
	score = 0 if @id == :AURAWHEEL && user.species != :MORPEKO && user.effects[PBEffects::TransformSpecies] != :MORPEKO
	return score
  end
end



#===============================================================================
# User's Defense is used instead of user's Attack for this move's calculations.
# (Body Press)
#===============================================================================
class PokeBattle_Move_177 < PokeBattle_Move
  def pbGetAttackStats(user,target)
    return user.defense, user.stages[:DEFENSE]+6
  end
end



#===============================================================================
# If the user attacks before the target, or if the target switches in during the
# turn that Fishious Rend is used, its base power doubles. (Fishious Rend, Bolt Beak)
#===============================================================================
class PokeBattle_Move_178 < PokeBattle_Move
  def pbBaseDamage(baseDmg,user,target)
    if @battle.choices[target.index][0]!=:None &&
       ((@battle.choices[target.index][0]!=:UseMove &&
       @battle.choices[target.index][0]==:Shift) || target.movedThisRound?)
    else
      baseDmg *= 2
    end
    return baseDmg
  end
  
  def getScore(score,user,target,skill=100)
	score = getWantsToBeSlowerScore(score,user,target,skill,-5)
	return score
  end
end



#===============================================================================
# Raises all user's stats by 1 stage in exchange for the user losing 1/3 of its
# maximum HP, rounded down. Fails if the user would faint. (Clangorous Soul)
#===============================================================================
class PokeBattle_Move_179 < PokeBattle_Move
  def pbMoveFailed?(user,targets,messages=true)
    if user.hp<=(user.totalhp/3) ||
	  (!user.pbCanRaiseStatStage?(:ATTACK,user,self,messages) &&
      !user.pbCanRaiseStatStage?(:DEFENSE,user,self,messages) &&
      !user.pbCanRaiseStatStage?(:SPEED,user,self,messages) &&
      !user.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user,self,messages) &&
      !user.pbCanRaiseStatStage?(:SPECIAL_DEFENSE,user,self,messages))
      @battle.pbDisplay(_INTL("But it failed!")) if messages
      return true
    end
    return false
  end

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
    user.pbReduceHP(user.totalhp/3,false)
  end
  
  def getScore(score,user,target,skill=100)
	score += 50 if user.turnCount == 0
	score -= 80 if user.hp < user.totalhp/2
	return score
  end
end



#===============================================================================
# Swaps barriers, veils and other effects between each side of the battlefield.
# (Court Change)
#===============================================================================
class PokeBattle_Move_17A < PokeBattle_Move
  def initialize(battle,move)
    super
    @statUp = [:ATTACK,2,:SPECIAL_ATTACK,2]
	@numericEffects = [PBEffects::Reflect,PBEffects::LightScreen,PBEffects::AuroraVeil,PBEffects::SeaOfFire,
  PBEffects::Swamp,PBEffects::Rainbow,PBEffects::Mist,PBEffects::Safeguard,PBEffects::Spikes,
  PBEffects::ToxicSpikes,PBEffects::Tailwind]
	@booleanEffects = [PBEffects::StealthRock,PBEffects::StickyWeb]
  end


  def pbEffectGeneral(user)
    changeside=false
    sides=[user.pbOwnSide,user.pbOpposingSide]
    for i in 0...2
	  noNumericEffectsActive = true
	  noBooleanEffectsActive = true
	  
	  @numericEffects.each do |effect|
		noNumericEffectsActive = false if sides[i].effects[effect]!=0
	  end
	  
	  @booleanEffects.each do |effect|
		noBooleanEffectsActive = false if sides[i].effects[effect]
	  end
	  
      next if noNumericEffectsActive && noBooleanEffectsActive
      changeside=true
    end
    if !changeside
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    else
      ownside=sides[0]; oppside=sides[1]

	  @numericEffects.concat(@booleanEffects).each do |effect|
		temp = ownside.effects[effect]
		ownside.effects[effect]=oppside.effects[effect]
		oppside.effects[effect]=temp
	  end
	  
	  # Sticky Web user is preserved, for Defiant/Competitive.
      stickywebuser=ownside.effects[PBEffects::StickyWebUser]
      ownside.effects[PBEffects::StickyWebUser]=oppside.effects[PBEffects::StickyWebUser]
      oppside.effects[PBEffects::StickyWebUser]=stickywebuser
	  
      @battle.pbDisplay(_INTL("{1} swapped the battle effects affecting each side of the field!",user.pbThis))
      return 0
    end
  end
  
  def getScore(score,user,target,skill=100)
	sides=[user.pbOwnSide,user.pbOpposingSide]
	@numericEffects.each do |effect|
		score -= 10 if sides[0].effects[effect]!=0
		score += 10 if sides[1].effects[effect]!=0
	end
	  
	@booleanEffects.each do |effect|
		score -= 10 if sides[0].effects[effect]
		score += 10 if sides[1].effects[effect]
	end
	return score
  end
end



#===============================================================================
# The user sharply raises the target's Attack and Sp. Atk stats by decorating
# the target. (Decorate)
#===============================================================================
class PokeBattle_Move_17B < PokeBattle_TargetMultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:ATTACK,2,:SPECIAL_ATTACK,2]
  end
end



#===============================================================================
# In singles, this move hits the target twice. In doubles, this move hits each
# target once. If one of the two opponents protects or while semi-invulnerable
# or is a Fairy-type Pokémon, it hits the opponent that doesn't protect twice.
# In Doubles, not affected by WideGuard.
# (Dragon Darts)
#===============================================================================
class PokeBattle_Move_17C < PokeBattle_Move_0BD
  def smartSpreadsTargets?; return true; end

  def pbNumHits(user,targets)
    return 1 if targets.length > 1
    return 2
  end
end

#===============================================================================
# Prevents both the user and the target from escaping. (Jaw Lock)
#===============================================================================
class PokeBattle_Move_17D < PokeBattle_Move
  def pbEffectAgainstTarget(user,target)
    if target.effects[PBEffects::JawLockUser]<0 && !target.effects[PBEffects::JawLock] &&
      user.effects[PBEffects::JawLockUser]<0 && !user.effects[PBEffects::JawLock]
      user.effects[PBEffects::JawLock] = true
      target.effects[PBEffects::JawLock] = true
      user.effects[PBEffects::JawLockUser] = user.index
      target.effects[PBEffects::JawLockUser] = user.index
      @battle.pbDisplay(_INTL("Neither Pokémon can run away!"))
    end
  end
end



#===============================================================================
# The user restores 1/4 of its maximum HP, rounded half up. If there is and
# adjacent ally, the user restores 1/4 of both its and its ally's maximum HP,
# rounded up. (Life Dew)
#===============================================================================
class PokeBattle_Move_17E < PokeBattle_Move
  def healingMove?; return true; end
  def worksWithNoTargets?; return true; end

  def pbMoveFailed?(user,targets)
    failed = true
    @battle.eachSameSideBattler(user) do |b|
      next if b.hp == b.totalhp
      failed = false
      break
    end
    if failed
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbFailsAgainstTarget?(user,target)
    if target.hp==target.totalhp
      @battle.pbDisplay(_INTL("{1}'s HP is full!",target.pbThis))
      return true
    elsif !target.canHeal?
      @battle.pbDisplay(_INTL("{1} is unaffected!",target.pbThis))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    hpGain = (target.totalhp/4.0).round
    target.pbRecoverHP(hpGain)
    @battle.pbDisplay(_INTL("{1}'s HP was restored.",target.pbThis))
  end

  def pbHealAmount(user)
    return (user.totalhp/4.0).round
  end
  
  
  def getScore(score,user,target,skill=100)
	score += 20 if user.hp < user.totalhp
	score += 20 if user.hp < user.totalhp/2
	score += 20 if target.hp < target.totalhp
	score += 20 if target.hp < target.totalhp/2
	score -= 80 if !user.canHeal?
	score -= 80 if !target.canHeal?
	return score
  end
end


#===============================================================================
# Increases each stat by 1 stage. Prevents user from fleeing. (No Retreat)
#===============================================================================
class PokeBattle_Move_17F < PokeBattle_MultiStatUpMove
  def pbMoveFailed?(user,targets,messages=true)
    if user.effects[PBEffects::NoRetreat]
      @battle.pbDisplay(_INTL("But it failed!")) if messages
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

	user.effects[PBEffects::NoRetreat] = true
    if !(user.effects[PBEffects::MeanLook]>=0 || user.effects[PBEffects::Trapping]>0 ||
       user.effects[PBEffects::JawLock] || user.effects[PBEffects::OctolockUser]>=0)
      @battle.pbDisplay(_INTL("{1} can no longer escape because it used No Retreat!",user.pbThis))
    end
  end
  
  def getScore(score,user,target,skill=100)
	score += 40 if user.turnCount == 0
	score -= 40 if user.hp<user.totalhp/2
	score = 0 if user.effects[PBEffects::NoRetreat]
	return score
  end
end

#===============================================================================
# User is protected against damaging moves this round. Decreases the Defense of
# the user of a stopped contact move by 2 stages. (Obstruct)
#===============================================================================
class PokeBattle_Move_180 < PokeBattle_ProtectMove
  def initialize(battle,move)
    super
    @effect = PBEffects::Obstruct
  end
end

#===============================================================================
# Lowers target's Defense and Special Defense by 1 stage at the end of each
# turn. Prevents target from retreating. (Octolock)
#===============================================================================
class PokeBattle_Move_181 < PokeBattle_Move
  def pbFailsAgainstTarget?(user,target)
    if target.effects[PBEffects::OctolockUser]>=0 || (target.damageState.substitute && !ignoresSubstitute?(user))
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    if target.pbHasType?(:GHOST)
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    target.effects[PBEffects::OctolockUser] = user.index
    target.effects[PBEffects::Octolock] = true
    @battle.pbDisplay(_INTL("{1} can no longer escape!",target.pbThis))
  end
  
  def getScore(score,user,target,skill=100)
    score += 40 if target.hp > target.totalhp/2
	score = 0 if target.effects[PBEffects::Octolock] || target.pbHasType?(:GHOST)
	return score
  end
end

#===============================================================================
# Ignores move redirection from abilities and moves. (Snipe Shot)
#===============================================================================
class PokeBattle_Move_182 < PokeBattle_Move
end

#===============================================================================
# Consumes berry and raises the user's Defense by 2 stages. (Stuff Cheeks)
#===============================================================================
class PokeBattle_Move_183 < PokeBattle_Move
  def pbEffectGeneral(user)
    if !user.item || !user.item.is_berry?
      @battle.pbDisplay("But it failed!")
      return -1
    end
    if user.pbCanRaiseStatStage?(:DEFENSE,user,self)
      user.pbRaiseStatStage(:DEFENSE,2,user)
    end
    user.pbHeldItemTriggerCheck(user.item,false)
    user.pbConsumeItem(true,true,false) if user.item
  end
  
  def getScore(score,user,target,skill=100)
    score += 40 if user.hp > user.totalhp/2
	score -= user.stages[:DEFENSE] * 10
	score = 0 if !user.item || !user.item.is_berry?
	return score
  end
end



#===============================================================================
# Forces all active Pokémon to consume their held berries. This move bypasses
# Substitutes. (Tea Time)
#===============================================================================
class PokeBattle_Move_184 < PokeBattle_Move
  def ignoresSubstitute?(user); return true; end

  def pbMoveFailed?(user,targets,messages=true)
    @validTargets = []
    @battle.eachBattler do |b|
      next if !b.item || !b.item.is_berry?
      @validTargets.push(b.index)
    end
    if @validTargets.length==0
      @battle.pbDisplay(_INTL("But it failed!")) if messages
      return true
    end
    @battle.pbDisplay(_INTL("It's tea time! Everyone dug in to their Berries!")) if messages
    return false
  end

  def pbFailsAgainstTarget?(user,target)
    return false if @validTargets.include?(target.index)
    return true if target.semiInvulnerable?
  end

  def pbEffectAgainstTarget(user,target)
    target.pbHeldItemTriggerCheck(target.item,false)
    target.pbConsumeItem(true,true,false) if target.item.is_berry?
  end
  
  def getScore(score,user,target,skill=100)
    score -= 40
	score += 20 if target.item && target.item.is_berry?
	return score
  end
end



#===============================================================================
# Decreases Opponent's Defense by 1 stage. Does Double Damage under gravity
# (Grav Apple)
#===============================================================================
class PokeBattle_Move_185 < PokeBattle_TargetStatDownMove
  def initialize(battle,move)
    super
    @statDown = [:DEFENSE,1]
  end

  def pbBaseDamage(baseDmg,user,target)
    baseDmg=baseDmg*1.5 if @battle.field.effects[PBEffects::Gravity]>0
    return baseDmg
  end
end

#===============================================================================
# Decrease 1 stage of speed and weakens target to fire moves. (Tar Shot)
#===============================================================================
class PokeBattle_Move_186 < PokeBattle_Move
  def pbEffectAgainstTarget(user,target)
    if !target.pbCanLowerStatStage?(:SPEED,target,self) && !target.effects[PBEffects::TarShot]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    if target.pbCanLowerStatStage?(:SPEED,target,self)
      target.pbLowerStatStage(:SPEED,1,target)
    end
    if target.effects[PBEffects::TarShot]==false
      target.effects[PBEffects::TarShot]=true
      @battle.pbDisplay(_INTL("{1} became weaker to fire!",target.pbThis))
    end
  end

  def getScore(score,user,target,skill=100)
	score += 30 if (target.hp > target.totalhp / 2)
	score += target.stages[:SPEED] * 10
	score -= 60 if target.effects[PBEffects::TarShot]
	return score
  end
end

#===============================================================================
# Changes Category based on Opponent's Def and SpDef. Has 20% Chance to Poison
# (Shell Side Arm)
#===============================================================================
class PokeBattle_Move_187 < PokeBattle_Move_005
  def initialize(battle,move)
    super
    @calcCategory = 1
  end

  def pbEffectAgainstTarget(user,target)
    if rand(5)<1 && target.pbCanPoison?(user,true,self)
      target.pbPoison(user)
    end
  end

  def physicalMove?(thisType=nil); return (@calcCategory==0); end
  def specialMove?(thisType=nil);  return (@calcCategory==1); end

  def pbOnStartUse(user,targets)
    stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
    stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
    defense      = targets[0].defense
    defenseStage = targets[0].stages[:DEFENSE]+6
    realDefense  = (defense.to_f*stageMul[defenseStage]/stageDiv[defenseStage]).floor
    spdef        = targets[0].spdef
    spdefStage   = targets[0].stages[:SPDEF]+6
    realSpdef    = (spdef.to_f*stageMul[spdefStage]/stageDiv[spdefStage]).floor
    # Determine move's category
    return @calcCategory = 0 if realDefense<realSpdef
    return @calcCategory = 1 if realDefense>=realSpdef
    if @id==:WONDERROOM; end
  end
  
  def getScore(score,user,target,skill=100)
	score = getPoisonMoveScore(score,user,target,skill,statusMove?)
	return score
  end
end



#===============================================================================
# Hits 3 times and always critical. (Surging Strikes)
#===============================================================================
class PokeBattle_Move_188 < PokeBattle_Move_0A0
  def multiHitMove?;           return true; end
  def pbNumHits(user,targets); return 3;    end
end

#===============================================================================
# Restore HP and heals any status conditions of itself and its allies
# (Jungle Healing)
#===============================================================================
class PokeBattle_Move_189 < PokeBattle_Move
  def healingMove?; return true; end

  def pbMoveFailed?(user,targets,messages=true)
    jglheal = 0
    for i in 0...targets.length
      jglheal += 1 if (targets[i].hp == targets[i].totalhp || !targets[i].canHeal?) && targets[i].status == :NONE
    end
    if jglheal == targets.length
      @battle.pbDisplay(_INTL("But it failed!")) if messages
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
      target.pbCureStatus
    if target.hp != target.totalhp && target.canHeal?
      hpGain = (target.totalhp/4.0).round
      target.pbRecoverHP(hpGain)
      @battle.pbDisplay(_INTL("{1}'s health was restored.",target.pbThis))
    end
    super
  end
end



#===============================================================================
# Changes type and base power based on Battle Terrain (Terrain Pulse)
#===============================================================================
class PokeBattle_Move_18A < PokeBattle_Move
  def pbBaseDamage(baseDmg,user,target)
    baseDmg *= 2 if @battle.field.terrain != :None && !user.airborne?
    return baseDmg
  end

  def pbBaseType(user)
    ret = :NORMAL
    if !user.airborne?
      case @battle.field.terrain
      when :Electric
        ret = :ELECTRIC || ret
      when :Grassy
        ret = :GRASS || ret
      when :Misty
        ret = :FAIRY || ret
      when :Psychic
        ret = :PSYCHIC || ret
      end
    end
    return ret
  end

  def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
    t = pbBaseType(user)
    hitNum = 1 if t == :ELECTRIC
    hitNum = 2 if t == :GRASS
    hitNum = 3 if t == :FAIRY
    hitNum = 4 if t == :PSYCHIC
    super
  end
end



#===============================================================================
# Burns opposing Pokemon that have increased their stats. (Burning Jealousy)
#===============================================================================
class PokeBattle_Move_18B < PokeBattle_Move
  def pbAdditionalEffect(user,target)
    return if target.damageState.substitute
    if target.pbCanBurn?(user,false,self) && target.statStagesUp?
      target.pbBurn(user)
    end
  end
  
  def getScore(score,user,target,skill=100)
		score -= 30
		score += 60 if target.pbCanBurn?(user,false,self) && statStagesUp(target)
		return score
  end
  
  def statStagesUp(target)
	return target.stages[:ATTACK] > 0 || target.stages[:DEFENSE] > 0 || target.stages[:SPEED] > 0 || target.stages[:SPECIAL_ATTACK] > 0 || target.stages[:SPECIAL_DEFENSE] > 0 || target.stages[:ACCURACY] > 0 || target.stages[:EVASION] > 0
  end
end



#===============================================================================
# Move has increased Priority in Grassy Terrain (Grassy Glide)
#===============================================================================
class PokeBattle_Move_18C < PokeBattle_Move
	def priorityModification(user,targets);
		return 1 if @battle.field.terrain == :Grassy
		return 0
	end
	
	def getScore(score,user,target,skill=100)
		score -= 20
		if @battle.field.terrain == :Grassy
			score += 50
			score += 50 if target.hp<=target.totalhp/2
		end
		return score
	end
end



#===============================================================================
# Power Doubles onn Electric Terrain (Rising Voltage)
#===============================================================================
class PokeBattle_Move_18D < PokeBattle_Move
  def pbBaseDamage(baseDmg,user,target)
    baseDmg *= 2 if @battle.field.terrain==:Electric && !target.airborne?
    return baseDmg
  end
end



#===============================================================================
# Boosts Targets' Attack and Defense (Coaching)
#===============================================================================
class PokeBattle_Move_18E < PokeBattle_TargetMultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:ATTACK,1,:DEFENSE,1]
  end
end



#===============================================================================
# Renders item unusable (Corrosive Gas)
#===============================================================================
class PokeBattle_Move_18F < PokeBattle_Move
  def pbEffectAgainstTarget(user,target)
    return if @battle.wildBattle? && user.opposes? && !user.boss  # Wild Pokémon can't knock off, except bosses
    return if user.fainted?
    return if target.damageState.substitute
    return if target.item==0 || target.unlosableItem?(target.item)
    return if target.hasActiveAbility?(:STICKYHOLD) && !@battle.moldBreaker
    itemName = target.itemName
    target.pbRemoveItem(false)
    @battle.pbDisplay(_INTL("{1} dropped its {2}!",target.pbThis,itemName))
  end
end



#===============================================================================
# Power is boosted on Psychic Terrain (Expanding Force)
#===============================================================================
class PokeBattle_Move_190 < PokeBattle_Move
  def pbBaseDamage(baseDmg,user,target)
    baseDmg *= 1.5 if @battle.field.terrain==:Psychic
    return baseDmg
  end
end



#===============================================================================
# Boosts Sp Atk on 1st Turn and Attacks on 2nd (Meteor Beam)
#===============================================================================
class PokeBattle_Move_191 < PokeBattle_TwoTurnMove
  def pbChargingTurnMessage(user,targets)
    @battle.pbDisplay(_INTL("{1} is overflowing with space power!",user.pbThis))
  end

  def pbChargingTurnEffect(user,target)
    if user.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user,self)
      user.pbRaiseStatStage(:SPECIAL_ATTACK,1,user)
    end
  end
end



#===============================================================================
# Fails if the Target has no Item (Poltergeist)
#===============================================================================
class PokeBattle_Move_192 < PokeBattle_Move
  def pbFailsAgainstTarget?(user,target)
    if target.item
      @battle.pbDisplay(_INTL("{1} is about to be attacked by its {2}!",target.pbThis,target.itemName))
      return false
    end
    @battle.pbDisplay(_INTL("But it failed!"))
    return true
  end
  
  def getScore(score,user,target,skill=100)
	score += 20
	score = 0 if !target.item
	return score
  end
end



#===============================================================================
# Reduces Defense and Raises Speed after all hits (Scale Shot)
#===============================================================================
class PokeBattle_Move_193 < PokeBattle_Move_0C0
  def pbEffectAfterAllHits(user,target)
    if user.pbCanRaiseStatStage?(:SPEED,user,self)
      user.pbRaiseStatStage(:SPEED,1,user)
    end
    if user.pbCanLowerStatStage?(:DEFENSE,target)
      user.pbLowerStatStage(:DEFENSE,1,user)
    end
  end
  
  def getScore(score,user,target,skill=100)
	score -= user.stages[:SPEED] * 10
	score += user.stages[:DEFENSE] * 10
	return score
  end
end



#===============================================================================
# Double damage if stats were lowered that turn. (Lash Out)
#===============================================================================
class PokeBattle_Move_194 < PokeBattle_Move
  def pbBaseDamage(baseDmg,user,target)
    baseDmg *= 2 if user.effects[PBEffects::LashOut]
    return baseDmg
  end
end



#===============================================================================
# Removes all Terrain. Fails if there is no Terrain (Steel Roller)
#===============================================================================
class PokeBattle_Move_195 < PokeBattle_Move
  def pbMoveFailed?(user,targets,messages=true)
    if @battle.field.terrain == :None
      @battle.pbDisplay(_INTL("But it failed!")) if messages
      return true
    end
    return false
  end

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
	score += 30
	score = 0 if battle.field.terrain == :NONE
	return score
  end
end



#===============================================================================
# Self KO. Boosted Damage when on Misty Terrain (Misty Explosion)
#===============================================================================
class PokeBattle_Move_196 < PokeBattle_Move_0E0
  def pbBaseDamage(baseDmg,user,target)
    if @battle.field.terrain==:Misty && !user.airborne?
      baseDmg = (baseDmg*1.5).round
    end
    return baseDmg
  end
  
  def getScore(score,user,target,skill=100)
	  score += 50
    score -= ((user.hp.to_f / user.totalhp.to_f) * 100).floor
	  return score
  end

  def pbSelfKO(user)
    return if user.fainted?
    reduction = user.totalhp / 2.0
    reduction /= 4 if user.boss?
    user.pbReduceHP(reduction.ceil,false)
    user.pbItemHPHealCheck
  end
end



#===============================================================================
# Target becomes Psychic type. (Magic Powder)
#===============================================================================
class PokeBattle_Move_197 < PokeBattle_Move
  def pbFailsAgainstTarget?(user,target)
    if !target.canChangeType? ||
       !target.pbHasOtherType?(:PSYCHIC)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    newType = :PSYCHIC
    target.pbChangeTypes(newType)
    typeName = newType.name
    @battle.pbDisplay(_INTL("{1} transformed into the {2} type!",target.pbThis,typeName))
  end
  
  def getScore(score,user,target,skill=100)
	score += 50
	score = 0 if !target.canChangeType? || !target.pbHasOtherType?(:PSYCHIC)
	return score
  end
end

#===============================================================================
# Target's last move used loses 3 PP. (Eerie Spell - Galarian Slowking)
#===============================================================================
class PokeBattle_Move_198 < PokeBattle_Move
  def pbFailsAgainstTarget?(user,target)
    failed = true
    target.eachMove do |m|
      next if m.id!=target.lastRegularMoveUsed || m.pp==0 || m.totalpp<=0
      failed = false; break
    end
    if failed
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    target.eachMove do |m|
      next if m.id!=target.lastRegularMoveUsed
      reduction = [3,m.pp].min
      target.pbSetPP(m,m.pp-reduction)
      @battle.pbDisplay(_INTL("It reduced the PP of {1}'s {2} by {3}!",
         target.pbThis(true),m.name,reduction))
      break
    end
  end
end


#===============================================================================
# Deals double damage to Dynamax POkémons. Dynamax is not implemented though.
# (Behemoth Blade, Behemoth Bash, Dynamax Cannon)
#===============================================================================
class PokeBattle_Move_199 < PokeBattle_Move
  # DYNAMAX IS NOT IMPLEMENTED.
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
	
	def getScore(score,user,target,skill=100)
		score += 50 - ((user.hp.to_f / user.totalhp.to_f) * 100).floor
		return score
	end
end