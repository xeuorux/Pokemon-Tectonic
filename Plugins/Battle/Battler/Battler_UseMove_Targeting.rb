class PokeBattle_Battler
	#=============================================================================
  # Redirect attack to another target
  #=============================================================================
  def pbChangeTargets(move,user,targets,dragondarts=-1)
    target_data = move.pbTarget(user)
    return targets if @battle.switching   # For Pursuit interrupting a switch
    return targets if move.cannotRedirect?
    return targets if move.function != "17C" && (!target_data.can_target_one_foe? || targets.length!=1)
	# Stalwart / Propeller Tail
    allySwitched = false
    ally = -1
    user.eachOpposing do |b|
      next if b.lastMoveUsed && GameData::Move.get(b.lastMoveUsed).function_code != "120"
      next if !target_data.can_target_one_foe?
      next if !hasActiveAbility?(:STALWART) && !hasActiveAbility?(:PROPELLERTAIL) && move.function != "182"
      next if !@battle.choices[b.index][3] == targets
      next if b.effects[PBEffects::SwitchedAlly] == -1
      allySwitched = !allySwitched
      ally = b.effects[PBEffects::SwitchedAlly]
      b.effects[PBEffects::SwitchedAlly] = -1
    end
    if allySwitched && ally >= 0
      targets = []
      pbAddTarget(targets,user,@battle.battlers[ally],move,!PBTargets.canChooseDistantTarget?(move.target))
      return targets
    end
    return targets if user.hasActiveAbility?(:STALWART) || user.hasActiveAbility?(:PROPELLERTAIL)
	return targets if move.function == "182"
    priority = @battle.pbPriority(true)
    nearOnly = !target_data.can_choose_distant_target?
    # Spotlight (takes priority over Follow Me/Rage Powder/Lightning Rod/Storm Drain)
    newTarget = nil; strength = 100   # Lower strength takes priority
    priority.each do |b|
      next if b.fainted? || b.effects[PBEffects::SkyDrop]>=0
      next if b.effects[PBEffects::Spotlight]==0 ||
              b.effects[PBEffects::Spotlight]>=strength
      next if !b.opposes?(user)
      next if nearOnly && !b.near?(user)
      newTarget = b
      strength = b.effects[PBEffects::Spotlight]
    end
    if newTarget
      PBDebug.log("[Move target changed] #{newTarget.pbThis}'s Spotlight made it the target")
      targets = []
      pbAddTarget(targets,user,newTarget,move,nearOnly)
      return targets
    end
	# Dragon Darts redirection
    if dragondarts>=0
      newTargets=[]
      neednewtarget=false
      # Check if first use has to be redirected
      if dragondarts==0
        targets.each do |b|
          next if !b.effects[PBEffects::Protect] &&
          !(b.effects[PBEffects::QuickGuard] && @battle.choices[user.index][4]>0) &&
          !b.effects[PBEffects::SpikyShield] &&
          !b.effects[PBEffects::BanefulBunker] &&
          !b.effects[PBEffects::Obstruct] &&
          !invulnerableTwoTurnAttack?(b,move) &&
          !move.pbImmunityByAbility(user,b) &&
          !Effectiveness.ineffective_type?(move.type,b.type1,b.type2) &&
          move.pbAccuracyCheck(user,b)
          next neednewtarget=true
        end
      end
      # Redirect first use if necessary or get another target on each consecutive use
      if neednewtarget || dragondarts==1
        targets[0].eachAlly do |b|
		  next if b.index == user.index && dragondarts==1 # Don't attack yourself on the second hit.
          next if b.effects[PBEffects::Protect] ||
          (b.effects[PBEffects::QuickGuard] && @battle.choices[user.index][4]>0) ||
          b.effects[PBEffects::SpikyShield] ||
          b.effects[PBEffects::BanefulBunker] ||
          b.effects[PBEffects::Obstruct] ||
          invulnerableTwoTurnAttack?(b,move)||
          move.pbImmunityByAbility(user,b) ||
          Effectiveness.ineffective_type?(move.type,b.type1,b.type2) ||
          !move.pbAccuracyCheck(user,b)
          newTargets.push(b)
		  b.damageState.unaffected = false
		  # In double battle, the pokémon might keep this state from a hit from the ally.
          break
        end
      end
      # Final target
      targets=newTargets if newTargets.length!=0
      # Reduce PP if the new target has Pressure
      if targets[0].hasActiveAbility?(:PRESSURE)
        user.pbReducePP(move) # Reduce PP
      end
    end
    # Follow Me/Rage Powder (takes priority over Lightning Rod/Storm Drain)
    newTarget = nil; strength = 100   # Lower strength takes priority
    priority.each do |b|
      next if b.fainted? || b.effects[PBEffects::SkyDrop]>=0
      next if b.effects[PBEffects::RagePowder] && !user.affectedByPowder?
      next if b.effects[PBEffects::FollowMe]==0 ||
              b.effects[PBEffects::FollowMe]>=strength
      next if !b.opposes?(user)
      next if nearOnly && !b.near?(user)
      newTarget = b
      strength = b.effects[PBEffects::FollowMe]
    end
    if newTarget
      PBDebug.log("[Move target changed] #{newTarget.pbThis}'s Follow Me/Rage Powder made it the target")
      targets = []
      pbAddTarget(targets,user,newTarget,move,nearOnly)
      return targets
    end
	# Bad Luck
    targets = pbChangeTargetByAbility(:BADLUCK,move,user,targets,priority,nearOnly) if move.statusMove?()
    return targets
  end
  
	def pbChangeTargetByAbility(drawingAbility,move,user,targets,priority,nearOnly)
		return targets if targets[0].hasActiveAbility?(drawingAbility)
		priority.each do |b|
		  next if b.index==user.index || b.index==targets[0].index
		  next if !b.hasActiveAbility?(drawingAbility)
		  next if nearOnly && !b.near?(user)
		  @battle.pbShowAbilitySplash(b)
		  targets.clear
		  pbAddTarget(targets,user,b,move,nearOnly)
		  if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
			@battle.pbDisplay(_INTL("{1} took the attack!",b.pbThis))
		  else
			@battle.pbDisplay(_INTL("{1} took the attack with its {2}!",b.pbThis,b.abilityName))
		  end
		  @battle.pbHideAbilitySplash(b)
		  break
		end
		return targets
	end
  
  
	def invulnerableTwoTurnAttack?(target,move)
		miss = true
		if target.inTwoTurnAttack?("0C9","0CC","0CE")   # Fly, Bounce, Sky Drop
			miss = false if move.hitsFlyingTargets?
			elsif target.inTwoTurnAttack?("0CA")            # Dig
			miss = false if move.hitsDiggingTargets?
			elsif target.inTwoTurnAttack?("0CB")            # Dive
			miss = false if move.hitsDivingTargets?
			elsif target.inTwoTurnAttack?("0CD","14D")		#PHANTOMFORCE/SHADOWFORCE in case we have a move that hits them
				miss = true
		end
		return miss
	end
end