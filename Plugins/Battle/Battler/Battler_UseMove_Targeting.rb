class PokeBattle_Battler
  #=============================================================================
  # Redirect attack to another target
  #=============================================================================
  def pbChangeTargets(move,user,targets,smartSpread = -1)
    target_data = move.pbTarget(user)
    return targets if @battle.switching   # For Pursuit interrupting a switch
    return targets if move.cannotRedirect?
    return targets if !move.smartSpreadsTargets? && (!target_data.can_target_one_foe? || targets.length != 1)
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
    # Spotlight (takes priority over Follow Me/Rage Powder or redirection abilities)
    newTarget = nil; strength = 100   # Lower strength takes priority
    priority.each do |b|
      next if b.fainted? || b.effects[PBEffects::SkyDrop]>=0
      next if b.effects[PBEffects::Spotlight] == 0 ||
              b.effects[PBEffects::Spotlight] >= strength
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
	  # Dragon Darts-style redirection
    # Smart Spread -1 means no spread, 0 means first hit, 1 means 2nd or further hit
    if smartSpread >= 0
      newTargets  = []
      needNewTarget = false
      # Check if first use has to be redirected
      if smartSpread == 0
        targets.each do |b|
          moveWillSucceed = true
          next if !moveWillFail(user,b,move)
          next needNewTarget = true
        end
      end
      # Redirect first use if necessary or get another target on each consecutive use
      if needNewTarget || smartSpread == 1
        targets[0].eachAlly do |b|
          next if b.index == user.index && smartSpread == 1 # Don't attack yourself on the second hit.
          next if moveWillFail(user,b,move)
          newTargets.push(b)
		      b.damageState.unaffected = false
		      # In double battle, the pokémon might keep this state from a hit from the ally.
          break
        end
      end
      # Final target
      targets = newTargets if newTargets.length!=0
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
    targets = pbChangeTargetByAbility(:BADLUCK,move,user,targets,priority,nearOnly) if move.statusMove?() && !user.pbHasAnyStatus?
    # Epic Hero
    maxDamage = 0
    targets.each do |target|
        maxDamage = move.baseDamage if move.baseDamage > maxDamage
    end
    targets = pbChangeTargetByAbility(:EPICHERO,move,user,targets,priority,nearOnly) if maxDamage >= 100
    return targets
  end

  def moveWillFail(user,target,move)
    return true if (target.effects[PBEffects::QuickGuard] && @battle.choices[user.index][4]>0)
    return true if target.protected?
    return true if invulnerableTwoTurnAttack?(target,move)
    return true if move.pbImmunityByAbility(user,target)
    return true if Effectiveness.ineffective_type?(move.type,target.type1,target.type2)
    return true if !move.pbAccuracyCheck(user,target)
    return false
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