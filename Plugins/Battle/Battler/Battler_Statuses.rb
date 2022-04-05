class PokeBattle_Battler

	def getStatuses()
		statuses = [@status]
		statuses.push(@bossStatus) if boss?
		return statuses
	end

	#=============================================================================
	# Generalised checks for whether a status problem can be inflicted
	#=============================================================================
	# NOTE: Not all "does it have this status?" checks use this method. If the
	#			 check is leading up to curing self of that status condition, then it
	#			 will look at the value of @status directly instead - if it is that
	#			 status condition then it is curable. This method only checks for
	#			 "counts as having that status", which includes Comatose which can't be
	#			 cured.
	def pbHasStatus?(checkStatus)
		if BattleHandlers.triggerStatusCheckAbilityNonIgnorable(self.ability,self,checkStatus)
			return true
		end
		return getStatuses().include?(checkStatus)
	end
	
	def hasStatusNoTrigger(checkStatus)
		return getStatuses().include?(checkStatus)
	end

	def pbHasAnyStatus?
		if BattleHandlers.triggerStatusCheckAbilityNonIgnorable(self.ability,self,nil)
			return true
		end
		return hasAnyStatusNoTrigger()
	end
	
	def hasAnyStatusNoTrigger()
		hasStatus = false
		getStatuses().each do |status|
			hasStatus = true if status != :NONE
		end
		return hasStatus
	end
	
	def hasSpotsForStatus()
		hasSpots = false
		getStatuses().each do |status|
			hasSpots = true if status == :NONE
		end
		return hasSpots
	end
	
	def reduceStatusCount(statusToReduce = nil)
		if statusToReduce.nil?
			@statusCount -= 1
			@bossStatusCount -= 1 if boss?
		else
			if @status == statusToReduce
				@statusCount -= 1
			elsif boss? && @bossStatus == statusToReduce
				@bossStatusCount -= 1
			end
		end
	end
	
	def getStatusCount(statusOfConcern)
		if @status == statusOfConcern
			return @statusCount
		elsif boss? && @bossStatus == statusOfConcern
			return @bossStatusCount
		end
		return 0
	end

	def pbCanInflictStatus?(newStatus,user,showMessages,move=nil,ignoreStatus=false)
		return false if fainted?
		selfInflicted = (user && user.index==@index)
		# Already have that status problem
		if getStatuses().include?(newStatus) && !ignoreStatus
			if showMessages
				msg = ""
				case self.status
				when :SLEEP		 then msg = _INTL("{1} is already asleep!", pbThis)
				when :POISON		then msg = _INTL("{1} is already poisoned!", pbThis)
				when :BURN			then msg = _INTL("{1} already has a burn!", pbThis)
				when :PARALYSIS then msg = _INTL("{1} is already numbed!", pbThis)
				when :FROZEN		then msg = _INTL("{1} is already chilled!", pbThis)
				end
				@battle.pbDisplay(msg)
			end
			return false
		end
		if !boss?
			# Trying to replace a status problem with another one
			if self.status != :NONE && !ignoreStatus && !selfInflicted
				@battle.pbDisplay(_INTL("{1} already has a status problem...",pbThis(false))) if showMessages
				return false
			end
		else
			# Trying to give too many statuses
			if !hasSpotsForStatus() && !ignoreStatus && !selfInflicted
				@battle.pbDisplay(_INTL("{1} cannot have any more status problems...",pbThis(false))) if showMessages
				return false
			end
		end
		# Trying to inflict a status problem on a Pokémon behind a substitute
		if @effects[PBEffects::Substitute]>0 && !(move && move.ignoresSubstitute?(user)) &&
			 !selfInflicted
			@battle.pbDisplay(_INTL("It doesn't affect {1} behind its substitute...",pbThis(true))) if showMessages
			return false
		end
		# Weather immunity
		if newStatus == :FROZEN && [:Sun, :HarshSun].include?(@battle.pbWeather)
			@battle.pbDisplay(_INTL("It doesn't affect {1} due to the sunny weather...",pbThis(true))) if showMessages
			return false
		end
		# Terrains immunity
		if affectedByTerrain?
			case @battle.field.terrain
			when :Electric
				if newStatus == :SLEEP || newStatus == :FROZEN
					@battle.pbDisplay(_INTL("{1} surrounds itself with electrified terrain!",
						 pbThis(true))) if showMessages
					return false
				end
			when :Misty
				if newStatus == :POISON || newStatus == :Burn
			@battle.pbDisplay(_INTL("{1} surrounds itself with fairy terrain!",pbThis(true))) if showMessages
			return false
		end
			end
		end
		# Uproar immunity
		if newStatus == :SLEEP && !(hasActiveAbility?(:SOUNDPROOF) && !@battle.moldBreaker)
			@battle.eachBattler do |b|
				next if b.effects[PBEffects::Uproar]==0
				@battle.pbDisplay(_INTL("But the uproar kept {1} awake!",pbThis(true))) if showMessages
				return false
			end
		end
		# Type immunities
		hasImmuneType = false
		case newStatus
		when :SLEEP
			# No type is immune to sleep
		when :POISON
			if !(user && user.hasActiveAbility?(:CORROSION))
				hasImmuneType |= pbHasType?(:POISON)
				hasImmuneType |= pbHasType?(:STEEL)
			end
		when :BURN
			hasImmuneType |= pbHasType?(:FIRE)
		when :PARALYSIS
			hasImmuneType |= pbHasType?(:ELECTRIC) && Settings::MORE_TYPE_EFFECTS
		when :FROZEN
			hasImmuneType |= pbHasType?(:ICE)
		end
		if hasImmuneType
			@battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis(true))) if showMessages
			return false
		end
		# Ability immunity
		immuneByAbility = false; immAlly = nil
		if BattleHandlers.triggerStatusImmunityAbilityNonIgnorable(self.ability,self,newStatus)
			immuneByAbility = true
		elsif selfInflicted || !@battle.moldBreaker
			if abilityActive? && BattleHandlers.triggerStatusImmunityAbility(self.ability,self,newStatus)
				immuneByAbility = true
			else
				eachAlly do |b|
					next if !b.abilityActive?
					next if !BattleHandlers.triggerStatusImmunityAllyAbility(b.ability,self,newStatus)
					immuneByAbility = true
					immAlly = b
					break
				end
			end
		end
		if immuneByAbility
			if showMessages
				@battle.pbShowAbilitySplash(immAlly || self)
				msg = ""
				if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
					case newStatus
					when :SLEEP		 then msg = _INTL("{1} stays awake!", pbThis)
					when :POISON		then msg = _INTL("{1} cannot be poisoned!", pbThis)
					when :BURN			then msg = _INTL("{1} cannot be burned!", pbThis)
					when :PARALYSIS then msg = _INTL("{1} cannot be numbed!", pbThis)
					when :FROZEN		then msg = _INTL("{1} cannot be chilled!", pbThis)
					end
				elsif immAlly
					case newStatus
					when :SLEEP
						msg = _INTL("{1} stays awake because of {2}'s {3}!",
							 pbThis,immAlly.pbThis(true),immAlly.abilityName)
					when :POISON
						msg = _INTL("{1} cannot be poisoned because of {2}'s {3}!",
							 pbThis,immAlly.pbThis(true),immAlly.abilityName)
					when :BURN
						msg = _INTL("{1} cannot be burned because of {2}'s {3}!",
							 pbThis,immAlly.pbThis(true),immAlly.abilityName)
					when :PARALYSIS
						msg = _INTL("{1} cannot be numbed because of {2}'s {3}!",
							 pbThis,immAlly.pbThis(true),immAlly.abilityName)
					when :FROZEN
						msg = _INTL("{1} cannot be chilled because of {2}'s {3}!",
							 pbThis,immAlly.pbThis(true),immAlly.abilityName)
					end
				else
					case newStatus
					when :SLEEP		 then msg = _INTL("{1} stays awake because of its {2}!", pbThis, abilityName)
					when :POISON		then msg = _INTL("{1}'s {2} prevents poisoning!", pbThis, abilityName)
					when :BURN			then msg = _INTL("{1}'s {2} prevents burns!", pbThis, abilityName)
					when :PARALYSIS then msg = _INTL("{1}'s {2} prevents numbing!", pbThis, abilityName)
					when :FROZEN		then msg = _INTL("{1}'s {2} prevents chilling!", pbThis, abilityName)
					end
				end
				@battle.pbDisplay(msg)
				@battle.pbHideAbilitySplash(immAlly || self)
			end
			return false
		end
		# Safeguard immunity
		if pbOwnSide.effects[PBEffects::Safeguard]>0 && !selfInflicted && move &&
			 !(user && user.hasActiveAbility?(:INFILTRATOR))
			@battle.pbDisplay(_INTL("{1}'s team is protected by Safeguard!",pbThis)) if showMessages
			return false
		end
		return true
	end

	def pbCanSynchronizeStatus?(newStatus,target)
		return false if fainted?
		# Trying to replace a status problem with another one
		return false if !hasSpotsForStatus()
		# Terrain immunity
		return false if @battle.field.terrain == :Misty &&
			affectedByTerrain? &&
			(newStatus == :BURN || newStatus == :POISON)
		return false if @battle.field.terrain == :Electric &&
			affectedByTerrain? &&
			newStatus == :FROZEN
		# Type immunities
		hasImmuneType = false
		case newStatus
		when :POISON
			# NOTE: target will have Synchronize, so it can't have Corrosion.
			if !(target && target.hasActiveAbility?(:CORROSION))
				hasImmuneType |= pbHasType?(:POISON)
				hasImmuneType |= pbHasType?(:STEEL)
			end
		when :BURN
			hasImmuneType |= pbHasType?(:FIRE)
		when :PARALYSIS
			hasImmuneType |= pbHasType?(:ELECTRIC) && Settings::MORE_TYPE_EFFECTS
		when :FROZEN
			hasImmuneType |= pbHasType?(:ICE)
		end
		return false if hasImmuneType
		# Ability immunity
		if BattleHandlers.triggerStatusImmunityAbilityNonIgnorable(self.ability,self,newStatus)
			return false
		end
		if abilityActive? && BattleHandlers.triggerStatusImmunityAbility(self.ability,self,newStatus)
			return false
		end
		eachAlly do |b|
			next if !b.abilityActive?
			next if !BattleHandlers.triggerStatusImmunityAllyAbility(b.ability,self,newStatus)
			return false
		end
		# Safeguard immunity
		if pbOwnSide.effects[PBEffects::Safeguard]>0 &&
			 !(user && user.hasActiveAbility?(:INFILTRATOR))
			return false
		end
		return true
	end

	#=============================================================================
	# Generalised infliction of status problem
	#=============================================================================
	def pbInflictStatus(newStatus,newStatusCount=0,msg=nil,user=nil)
		# Inflict the new status
		if !boss?
		self.status			= newStatus
		self.statusCount	= newStatusCount
	else
		if @status == :NONE
			self.status			= newStatus
			self.statusCount = newStatusCount
		else
			self.bossStatus			= newStatus
			self.bossStatusCount	= newStatusCount
		end
	end
		@effects[PBEffects::Toxic] = 0
		# Show animation
		if newStatus == :POISON && newStatusCount > 0
			@battle.pbCommonAnimation("Toxic", self)
		else
			anim_name = GameData::Status.get(newStatus).animation
			@battle.pbCommonAnimation(anim_name, self) if anim_name
		end
		# Show message
	if msg != "false"
		if msg && !msg.empty?
			@battle.pbDisplay(msg)
		else
			case newStatus
			when :SLEEP
			@battle.pbDisplay(_INTL("{1} fell asleep!", pbThis))
			when :POISON
			if newStatusCount>0
				@battle.pbDisplay(_INTL("{1} was toxified!", pbThis))
			else
				@battle.pbDisplay(_INTL("{1} was poisoned! Its Sp. Atk is reduced by a third!", pbThis))
			end
			when :BURN
			@battle.pbDisplay(_INTL("{1} was burned! Its Attack is reduced by a third!", pbThis))
			when :PARALYSIS
			@battle.pbDisplay(_INTL("{1} is numbed! It's slower and it's stat improvements are ignored!", pbThis))
			when :FROZEN
			@battle.pbDisplay(_INTL("{1} was chilled! It's slower and takes more damage!", pbThis))
			end
		end
	end
		#PBDebug.log("[Status change] #{pbThis}'s sleep count is #{newStatusCount}") if newStatus == :SLEEP
		# Form change check
		pbCheckFormOnStatusChange
		# Synchronize
		if abilityActive?
			BattleHandlers.triggerAbilityOnStatusInflicted(self.ability,self,user,newStatus)
		end
		# Status cures
		pbItemStatusCureCheck
		pbAbilityStatusCureCheck
		# Petal Dance/Outrage/Thrash get cancelled immediately by falling asleep
		# NOTE: I don't know why this applies only to Outrage and only to falling
		#			 asleep (i.e. it doesn't cancel Rollout/Uproar/other multi-turn
		#			 moves, and it doesn't cancel any moves if self becomes frozen/
		#			 disabled/anything else). This behaviour was tested in Gen 5.
		if newStatus == :SLEEP && @effects[PBEffects::Outrage] > 0
			@effects[PBEffects::Outrage] = 0
			@currentMove = nil
		end
	end

	#=============================================================================
	# Sleep
	#=============================================================================
	def asleep?
		return pbHasStatus?(:SLEEP)
	end

	def pbCanSleep?(user, showMessages, move = nil, ignoreStatus = false)
		return pbCanInflictStatus?(:SLEEP, user, showMessages, move, ignoreStatus)
	end

	def pbCanSleepYawn?
		return false if self.status != :NONE
		if affectedByTerrain?
			return false if [:Electric, :Misty].include?(@battle.field.terrain)
		end
		if !hasActiveAbility?(:SOUNDPROOF)
			@battle.eachBattler do |b|
				return false if b.effects[PBEffects::Uproar]>0
			end
		end
		if BattleHandlers.triggerStatusImmunityAbilityNonIgnorable(self.ability, self, :SLEEP)
			return false
		end
		# NOTE: Bulbapedia claims that Flower Veil shouldn't prevent sleep due to
		#			 drowsiness, but I disagree because that makes no sense. Also, the
		#			 comparable Sweet Veil does prevent sleep due to drowsiness.
		if abilityActive? && BattleHandlers.triggerStatusImmunityAbility(self.ability, self, :SLEEP)
			return false
		end
		eachAlly do |b|
			next if !b.abilityActive?
			next if !BattleHandlers.triggerStatusImmunityAllyAbility(b.ability, self, :SLEEP)
			return false
		end
		# NOTE: Bulbapedia claims that Safeguard shouldn't prevent sleep due to
		#			 drowsiness. I disagree with this too. Compare with the other sided
		#			 effects Misty/Electric Terrain, which do prevent it.
		return false if pbOwnSide.effects[PBEffects::Safeguard]>0
		return true
	end

	def pbSleep(msg = nil)
		pbInflictStatus(:SLEEP, pbSleepDuration, msg)
	end

	def pbSleepSelf(msg = nil, duration = -1)
		pbInflictStatus(:SLEEP, pbSleepDuration(duration), msg)
	end

	def pbSleepDuration(duration = -1)
		duration = 4 if duration <= 0
		duration = 2 if hasActiveAbility?(:EARLYBIRD) || boss
		return duration
	end

	#=============================================================================
	# Poison
	#=============================================================================
	def poisoned?
		return pbHasStatus?(:POISON)
	end

	def pbCanPoison?(user, showMessages, move = nil)
		return pbCanInflictStatus?(:POISON, user, showMessages, move)
	end

	def pbCanPoisonSynchronize?(target)
		return pbCanSynchronizeStatus?(:POISON, target)
	end

	def pbPoison(user=nil,msg=nil,toxic=false)
		if (boss && toxic)
			@battle.pbDisplay("The projection's power blunts the toxin.")
			toxic = false
		end
		pbInflictStatus(:POISON,(toxic) ? 1 : 0,msg,user)
	end

	#=============================================================================
	# Burn
	#=============================================================================
	def burned?
		return pbHasStatus?(:BURN)
	end

	def pbCanBurn?(user, showMessages, move = nil)
		return pbCanInflictStatus?(:BURN, user, showMessages, move)
	end

	def pbCanBurnSynchronize?(target)
		return pbCanSynchronizeStatus?(:BURN, target)
	end

	def pbBurn(user = nil, msg = nil)
		pbInflictStatus(:BURN, 0, msg, user)
	end

	#=============================================================================
	# Paralyze
	#=============================================================================
	def paralyzed?
		return pbHasStatus?(:PARALYSIS)
	end

	def pbCanParalyze?(user, showMessages, move = nil)
		return pbCanInflictStatus?(:PARALYSIS, user, showMessages, move)
	end

	def pbCanParalyzeSynchronize?(target)
		return pbCanSynchronizeStatus?(:PARALYSIS, target)
	end

	def pbParalyze(user = nil, msg = nil)
		pbInflictStatus(:PARALYSIS, 0, msg, user)
	end

	#=============================================================================
	# Freeze
	#=============================================================================
	def frozen?
		return pbHasStatus?(:FROZEN)
	end

	def pbCanFreeze?(user, showMessages, move = nil)
		return pbCanInflictStatus?(:FROZEN, user, showMessages, move)
	end

	def pbFreeze(msg = nil)
		pbInflictStatus(:FROZEN, 0, msg)
	end

	#=============================================================================
	# Generalised status displays
	#=============================================================================
	def pbContinueStatus(statusToContinue = nil)
		getStatuses().each do |oneStatus|
		next if !statusToContinue.nil? && oneStatus != statusToContinue
		if oneStatus == :POISON && @statusCount > 0
			@battle.pbCommonAnimation("Toxic", self)
		else
			anim_name = GameData::Status.get(oneStatus).animation
			@battle.pbCommonAnimation(anim_name, self) if anim_name
		end
		yield if block_given?
		case oneStatus
		when :SLEEP
			@battle.pbDisplay(_INTL("{1} is fast asleep.", pbThis))
		when :POISON
			@battle.pbDisplay(_INTL("{1} was hurt by poison!", pbThis))
		when :BURN
			@battle.pbDisplay(_INTL("{1} was hurt by its burn!", pbThis))
		when :FROZEN
			@battle.pbDisplay(_INTL("{1} is frozen solid!", pbThis))
		end
		PBDebug.log("[Status continues] #{pbThis}'s sleep count is #{@statusCount}") if oneStatus == :SLEEP
	end
	end

	def pbCureStatus(showMessages=true,statusToCure=nil)
		oldStatuses = []
	
		if statusToCure.nil? || @status == statusToCure
			oldStatuses.push(@status)
			self.status = :NONE
		end
			
		if boss?
			if @bossStatus == statusToCure
				oldStatuses.push(@bossStatus)
				self.bossStatus = :NONE
			elsif @status == :NONE
				self.status = @bossStatus
				self.bossStatus = :NONE
			end
		end
		
		oldStatuses.each do |oldStatus|
			if showMessages
				case oldStatus
				when :SLEEP		 then @battle.pbDisplay(_INTL("{1} woke up!", pbThis))
				when :POISON		then @battle.pbDisplay(_INTL("{1} was cured of its poisoning.", pbThis))
				when :BURN			then @battle.pbDisplay(_INTL("{1}'s burn was healed.", pbThis))
				when :PARALYSIS then @battle.pbDisplay(_INTL("{1} is no longer numbed.", pbThis))
				when :FROZEN		then @battle.pbDisplay(_INTL("{1} thawed out!", pbThis))
				end
			end
	
			# Lingering Daze
			if oldStatus == :SLEEP
				@battle.eachOtherSideBattler(@index) do |b|
					if b.hasActiveAbility?(:LINGERINGDAZE)
						@battle.pbShowAbilitySplash(b)
						pbLowerStatStageByAbility(:SPECIAL_ATTACK,1,b)
						pbLowerStatStageByAbility(:SPECIAL_DEFENSE,1,b)
						@battle.pbHideAbilitySplash(b)
					end
				end
			end
		end
	
		@battle.scene.pbRefreshOne(@index)
		PBDebug.log("[Status change] #{pbThis}'s status was cured")
	end

	#=============================================================================
	# Confusion
	#=============================================================================
	def pbCanConfuse?(user=nil,showMessages=true,move=nil,selfInflicted=false)
		return false if fainted?
		if @effects[PBEffects::Confusion]>0
			@battle.pbDisplay(_INTL("{1} is already confused.",pbThis)) if showMessages
			return false
		end
		if @effects[PBEffects::Substitute]>0 && !(move && move.ignoresSubstitute?(user)) &&
			 !selfInflicted
			@battle.pbDisplay(_INTL("But it failed!")) if showMessages
			return false
		end
		# Terrains immunity
		if affectedByTerrain? && @battle.field.terrain == :Misty
			@battle.pbDisplay(_INTL("{1} surrounds itself with misty terrain!",pbThis(true))) if showMessages
			return false
		end
		if selfInflicted || !@battle.moldBreaker
			if hasActiveAbility?(:OWNTEMPO)
				if showMessages
					@battle.pbShowAbilitySplash(self)
					if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
						@battle.pbDisplay(_INTL("{1} doesn't become confused!",pbThis))
					else
						@battle.pbDisplay(_INTL("{1}'s {2} prevents confusion!",pbThis,abilityName))
					end
					@battle.pbHideAbilitySplash(self)
				end
				return false
			end
		end
		if pbOwnSide.effects[PBEffects::Safeguard]>0 && !selfInflicted &&
			 !(user && user.hasActiveAbility?(:INFILTRATOR))
			@battle.pbDisplay(_INTL("{1}'s team is protected by Safeguard!",pbThis)) if showMessages
			return false
		end
		return true
	end

	def pbCanConfuseSelf?(showMessages)
		return pbCanConfuse?(nil,showMessages,nil,true)
	end

	def pbConfuse(msg=nil)
		@effects[PBEffects::Confusion] = pbConfusionDuration
	@effects[PBEffects::ConfusionChance] = 0
		@battle.pbCommonAnimation("Confusion",self)
		msg = _INTL("{1} became confused!",pbThis) if !msg || msg==""
		@battle.pbDisplay(msg)
		PBDebug.log("[Lingering effect] #{pbThis}'s confusion count is #{@effects[PBEffects::Confusion]}")
		# Confusion cures
		pbItemStatusCureCheck
		pbAbilityStatusCureCheck
	end

	def pbConfusionDuration(duration=-1)
		duration = 3 if duration<=0
		return duration
	end

	def pbCureConfusion
		@effects[PBEffects::Confusion] = 0
	@effects[PBEffects::ConfusionChance] = 0
	end
	
	#=============================================================================
	# Charm
	#=============================================================================
	def pbCanCharm?(user=nil,showMessages=true,move=nil,selfInflicted=false)
		return false if fainted?
		if @effects[PBEffects::Charm]>0
			@battle.pbDisplay(_INTL("{1} is already charmed.",pbThis)) if showMessages
			return false
		end
		if @effects[PBEffects::Substitute]>0 && !(move && move.ignoresSubstitute?(user)) &&
			 !selfInflicted
			@battle.pbDisplay(_INTL("But it failed!")) if showMessages
			return false
		end
		# Terrains immunity
		if affectedByTerrain? && @battle.field.terrain == :Misty
			@battle.pbDisplay(_INTL("{1} surrounds itself with misty terrain!",pbThis(true))) if showMessages
			return false
		end
		if selfInflicted || !@battle.moldBreaker
			if hasActiveAbility?(:OWNTEMPO)
				if showMessages
					@battle.pbShowAbilitySplash(self)
					if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
						@battle.pbDisplay(_INTL("{1} doesn't become charmed!",pbThis))
					else
						@battle.pbDisplay(_INTL("{1}'s {2} prevents charmed!",pbThis,abilityName))
					end
					@battle.pbHideAbilitySplash(self)
				end
				return false
			end
		end
		if pbOwnSide.effects[PBEffects::Safeguard]>0 && !selfInflicted &&
			 !(user && user.hasActiveAbility?(:INFILTRATOR))
			@battle.pbDisplay(_INTL("{1}'s team is protected by Safeguard!",pbThis)) if showMessages
			return false
		end
		return true
	end

	def pbCanCharmSelf?(showMessages)
		return pbCanConfuse?(nil,showMessages,nil,true)
	end
	
	def pbCharm(msg=nil)
		@effects[PBEffects::Charm] = pbCharmDuration
	@effects[PBEffects::CharmChance] = 0
		@battle.pbAnimation(:LUCKYCHANT,self,nil)
		msg = _INTL("{1} became charmed!",pbThis) if !msg || msg==""
		@battle.pbDisplay(msg)
		PBDebug.log("[Lingering effect] #{pbThis}'s charm count is #{@effects[PBEffects::Confusion]}")
		# Charm cures
		pbItemStatusCureCheck
		pbAbilityStatusCureCheck
	end

	def pbCharmDuration(duration=-1)
		duration = 3 if duration<=0
		return duration
	end

	def pbCureCharm
		@effects[PBEffects::Charm] = 0
	@effects[PBEffects::CharmChance] = 0
	end

	#=============================================================================
	# Attraction
	#=============================================================================
	def pbCanAttract?(user,showMessages=true)
		return false if fainted?
		return false if !user || user.fainted?
		if @effects[PBEffects::Attract]>=0
			@battle.pbDisplay(_INTL("{1} is unaffected!",pbThis)) if showMessages
			return false
		end
		agender = user.gender
		ogender = gender
		if agender==2 || ogender==2 || agender==ogender
			@battle.pbDisplay(_INTL("{1} is unaffected!",pbThis)) if showMessages
			return false
		end
		if !@battle.moldBreaker
			if hasActiveAbility?([:AROMAVEIL,:OBLIVIOUS])
				if showMessages
					@battle.pbShowAbilitySplash(self)
					if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
						@battle.pbDisplay(_INTL("{1} is unaffected!",pbThis))
					else
						@battle.pbDisplay(_INTL("{1}'s {2} prevents romance!",pbThis,abilityName))
					end
					@battle.pbHideAbilitySplash(self)
				end
				return false
			else
				eachAlly do |b|
					next if !b.hasActiveAbility?(:AROMAVEIL)
					if showMessages
						@battle.pbShowAbilitySplash(self)
						if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
							@battle.pbDisplay(_INTL("{1} is unaffected!",pbThis))
						else
							@battle.pbDisplay(_INTL("{1}'s {2} prevents romance!",b.pbThis,b.abilityName))
						end
						@battle.pbHideAbilitySplash(self)
					end
					return true
				end
			end
		end
		return true
	end

	def pbAttract(user,msg=nil)
		@effects[PBEffects::Attract] = user.index
		@battle.pbCommonAnimation("Attract",self)
		msg = _INTL("{1} fell in love!",pbThis) if nil_or_empty?(msg)
		@battle.pbDisplay(msg)
		# Destiny Knot
		if hasActiveItem?(:DESTINYKNOT) && user.pbCanAttract?(self,false)
			user.pbAttract(self,_INTL("{1} fell in love from the {2}!",user.pbThis(true),itemName))
		end
		# Attraction cures
		pbItemStatusCureCheck
		pbAbilityStatusCureCheck
	end

	def pbCureAttract
		@effects[PBEffects::Attract] = -1
	end

	#=============================================================================
	# Flinching
	#=============================================================================
	def pbFlinch(_user=nil)
		return if hasActiveAbility?(:INNERFOCUS) && !@battle.moldBreaker
		@effects[PBEffects::Flinch] = true
	end
	
	
	def pbCanFrozenSynchronize?(target)
		return pbCanSynchronizeStatus?(:FROZEN, target)
	end
end
