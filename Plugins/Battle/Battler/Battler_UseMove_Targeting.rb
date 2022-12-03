class PokeBattle_Battler
	#=============================================================================
	# Get move's user
	#=============================================================================
	def pbFindUser(_choice, _move)
		return self
	end

	def pbChangeUser(choice, move, user)
		# Snatch
		move.snatched = false
		if move.canSnatch?
			newUser = nil
			strength = 100
			@battle.eachBattler do |b|
				next if b.effects[:Snatch] == 0 || b.effects[:Snatch] >= strength
				next if b.effectActive?(:SkyDrop)
				newUser = b
				strength = b.effects[:Snatch]
			end
			if newUser
				user = newUser
				user.effects[:Snatch] = 0
				move.snatched = true
				@battle.moldBreaker = user.hasMoldBreaker?
				choice[3] = -1 # Clear pre-chosen target
			end
		end
		return user
	end

	#=============================================================================
	# Get move's default target(s)
	#=============================================================================
	def pbFindTargets(choice, move, user)
		preTarget = choice[3] # A target that was already chosen
		targets = []
		# Get list of targets
		case move.pbTarget(user).id # Curse can change its target type
		when :NearAlly
			targetBattler = (preTarget >= 0) ? @battle.battlers[preTarget] : nil
			pbAddTargetRandomAlly(targets, user, move) unless pbAddTarget(targets, user, targetBattler, move)
		when :UserOrNearAlly
			targetBattler = (preTarget >= 0) ? @battle.battlers[preTarget] : nil
			pbAddTarget(targets, user, user, move, true, true) unless pbAddTarget(targets, user, targetBattler, move, true, true)
		when :UserAndAllies
			pbAddTarget(targets, user, user, move, true, true)
			@battle.eachSameSideBattler(user.index) { |b| pbAddTarget(targets, user, b, move, false, true) }
		when :NearFoe, :NearOther
			targetBattler = (preTarget >= 0) ? @battle.battlers[preTarget] : nil
			unless pbAddTarget(targets, user, targetBattler, move)
				if preTarget >= 0 && !user.opposes?(preTarget)
					pbAddTargetRandomAlly(targets, user, move)
				else
					pbAddTargetRandomFoe(targets, user, move)
				end
			end
		when :RandomNearFoe
			pbAddTargetRandomFoe(targets, user, move)
		when :AllNearFoes
			@battle.eachOtherSideBattler(user.index) { |b| pbAddTarget(targets, user, b, move) }
		when :Foe, :Other
			targetBattler = (preTarget >= 0) ? @battle.battlers[preTarget] : nil
			unless pbAddTarget(targets, user, targetBattler, move, false)
				if preTarget >= 0 && !user.opposes?(preTarget)
					pbAddTargetRandomAlly(targets, user, move, false)
				else
					pbAddTargetRandomFoe(targets, user, move, false)
				end
			end
		when :AllFoes
			@battle.eachOtherSideBattler(user.index) { |b| pbAddTarget(targets, user, b, move, false) }
		when :AllNearOthers
			@battle.eachBattler { |b| pbAddTarget(targets, user, b, move) }
		when :AllBattlers
			@battle.eachBattler { |b| pbAddTarget(targets, user, b, move, false, true) }
		else
			# Used by Counter/Mirror Coat/Metal Burst/Bide
			move.pbAddTarget(targets, user) # Move-specific pbAddTarget, not the def below
		end
		return targets
	end

	def moveWillFail(user, target, move)
		return true if target.protectedAgainst?(user,move)
		return true if invulnerableTwoTurnAttack?(target, move)
		return true if move.pbImmunityByAbility(user, target, false)
		return true if Effectiveness.ineffective_type?(move.type, target.type1, target.type2)
		return true unless move.pbAccuracyCheck(user, target)
		return false
	end

	def invulnerableTwoTurnAttack?(target, move)
		miss = true
		if target.inTwoTurnAttack?('0C9', '0CC', '0CE') # Fly, Bounce, Sky Drop
			miss = false if move.hitsFlyingTargets?
		elsif target.inTwoTurnAttack?('0CA')            # Dig
			miss = false if move.hitsDiggingTargets?
		elsif target.inTwoTurnAttack?('0CB')            # Dive
			miss = false if move.hitsDivingTargets?
		elsif target.inTwoTurnAttack?('0CD', '14D')	# PHANTOMFORCE/SHADOWFORCE in case we have a move that hits them
			miss = true
		end
		return miss
	end

	#=============================================================================
	# Redirect attack to another target
	#=============================================================================
	def pbChangeTargets(move, user, targets, smartSpread = -1)
		target_data = move.pbTarget(user)
		return targets if @battle.switching # For Pursuit interrupting a switch
		return targets if move.cannotRedirect?
		return targets if !target_data.can_target_one_foe? || targets.length != 1
		move.pbModifyTargets(targets, user) # For Dragon Darts, etc.
		return targets if user.hasActiveAbility?(:STALWART) || user.hasActiveAbility?(:PROPELLERTAIL)
		priority = @battle.pbPriority(true)
		nearOnly = !target_data.can_choose_distant_target?
		# Spotlight (takes priority over Follow Me/Rage Powder or redirection abilities)
		newTarget = nil
		strength = 100 # Lower strength takes priority
		priority.each do |b|
			next if b.fainted? || b.effectActive?(:SkyDrop)
			next if b.effects[:Spotlight] == 0 || b.effects[:Spotlight] >= strength
			next unless b.opposes?(user)
			next if nearOnly && !b.near?(user)
			newTarget = b
			strength = b.effects[:Spotlight]
		end
		if newTarget
			PBDebug.log("[Move target changed] #{newTarget.pbThis}'s Spotlight made it the target")
			targets = []
			pbAddTarget(targets, user, newTarget, move, nearOnly)
			return targets
		end
		# Follow Me/Rage Powder (takes priority over Lightning Rod/Storm Drain)
		newTarget = nil
		strength = 100 # Lower strength takes priority
		priority.each do |b|
			next if b.fainted? || b.effectActive?(:SkyDrop)
			next if b.effects[:RagePowder] && !user.affectedByPowder?
			next if b.effects[:FollowMe] == 0 || b.effects[:FollowMe] >= strength
			next unless b.opposes?(user)
			next if nearOnly && !b.near?(user)
			newTarget = b
			strength = b.effects[:FollowMe]
		end
		if newTarget
			PBDebug.log("[Move target changed] #{newTarget.pbThis}'s Follow Me/Rage Powder made it the target")
			targets = []
			pbAddTarget(targets, user, newTarget, move, nearOnly)
			return targets
		end
		# Bad Luck
		targets = pbChangeTargetByAbility(:BADLUCK, move, user, targets, priority, nearOnly) if move.statusMove? && !user.pbHasAnyStatus?
		# Epic Hero
		maxBaseDamage = 0
		targets.each do |_target|
			maxBaseDamage = move.baseDamage if move.baseDamage > maxBaseDamage
		end
		targets = pbChangeTargetByAbility(:EPICHERO, move, user, targets, priority, nearOnly) if maxBaseDamage >= 100
		return targets
	end

	def pbChangeTargetByAbility(drawingAbility, move, user, targets, priority, nearOnly)
		return targets if targets[0].hasActiveAbility?(drawingAbility)
		priority.each do |b|
			next if b.index == user.index || b.index == targets[0].index
			next unless b.hasActiveAbility?(drawingAbility)
			next if nearOnly && !b.near?(user)
			@battle.pbShowAbilitySplash(b)
			targets.clear
			pbAddTarget(targets, user, b, move, nearOnly)
			@battle.pbDisplay(_INTL('{1} took the attack!', b.pbThis))
			@battle.pbHideAbilitySplash(b)
			break
		end
		return targets
	end

	#=============================================================================
	# Register target
	#=============================================================================
	def pbAddTarget(targets, user, target, move, nearOnly = true, allowUser = false)
		return false if !target || (target.fainted? && !move.cannotRedirect?)
		return false if !(allowUser && user == target) && nearOnly && !user.near?(target)
		targets.each { |b| return true if b.index == target.index }   # Already added
		targets.push(target)
		return true
	end

	def pbAddTargetRandomAlly(targets, user, _move, nearOnly = true)
		choices = []
		user.eachAlly do |b|
			next if nearOnly && !user.near?(b)
			pbAddTarget(choices, user, b, nearOnly)
		end
		pbAddTarget(targets, user, choices[@battle.pbRandom(choices.length)], nearOnly) if choices.length > 0
	end

	def pbAddTargetRandomFoe(targets, user, _move, nearOnly = true)
		choices = []
		user.eachOpposing do |b|
			next if nearOnly && !user.near?(b)
			pbAddTarget(choices, user, b, nearOnly)
		end
		pbAddTarget(targets, user, choices[@battle.pbRandom(choices.length)], nearOnly) if choices.length > 0
	end
end
