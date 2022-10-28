BURNED_EXPLANATION = 'It Attack is reduced by a third'.freeze
POISONED_EXPLANATION = 'Its Speed is halved'.freeze
FROSTBITE_EXPLANATION = 'Its Sp. Atk is reduced by a third'.freeze
NUMBED_EXPLANATION = "Its Speed is halved, and it'll deal less damage".freeze
CHILLED_EXPLANATION = "Its speed is halved, and it'll take more damage".freeze
FLUSTERED_EXPLANATION = 'Its Defense is reduced by a third'.freeze
MYSTIFIED_EXPLANATION = 'Its Sp. Def is reduced by a third'.freeze

class PokeBattle_Battler
	def getStatuses
		statuses = [ability == :COMATOSE ? :SLEEP : @status]
		statuses.push(@bossStatus) if boss?
		return statuses
	end

	#=============================================================================
	# Generalised checks for whether a status problem can be inflicted
	#=============================================================================
	# NOTE: Not all "does it have this status?" checks use this method. If the
	#			 check is leading up to curing self of that status condition, then it
	#			 will look at hasStatusNoTrigger instead - if it is that
	#			 status condition then it is curable. This method only checks for
	#			 "counts as having that status", which includes Comatose which can't be
	#			 cured.
	def pbHasStatus?(checkStatus)
		return true if BattleHandlers.triggerStatusCheckAbilityNonIgnorable(ability, self, checkStatus)
		return getStatuses.include?(checkStatus)
	end

	def hasStatusNoTrigger(checkStatus)
		return getStatuses.include?(checkStatus)
	end
	alias hasStatusNoTrigger? hasStatusNoTrigger

	def pbHasAnyStatus?
		return true if BattleHandlers.triggerStatusCheckAbilityNonIgnorable(ability, self, nil)
		return hasAnyStatusNoTrigger
	end

	def hasAnyStatusNoTrigger
		hasStatus = false
		getStatuses.each do |status|
			hasStatus = true if status != :NONE
		end
		return hasStatus
	end
	alias hasAnyStatusNoTrigger? hasAnyStatusNoTrigger

	def hasSpotsForStatus
		hasSpots = false
		getStatuses.each do |status|
			hasSpots = true if status == :NONE
		end
		return hasSpots
	end
	alias hasSpotsForStatus? hasSpotsForStatus

	def reduceStatusCount(statusToReduce = nil)
		if statusToReduce.nil?
			@statusCount -= 1
			@bossStatusCount -= 1 if boss?
		elsif @status == statusToReduce
			@statusCount -= 1
		elsif boss? && @bossStatus == statusToReduce
			@bossStatusCount -= 1
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

	def pbCanInflictStatus?(newStatus, user, showMessages, move = nil, ignoreStatus = false)
		return false if fainted?
		selfInflicted = (user && user.index == @index)
		statusDoublingCurse = pbOwnedByPlayer? && @battle.curseActive?(:CURSE_STATUS_DOUBLED)
		# Already have that status problem
		if getStatuses.include?(newStatus) && !ignoreStatus
			if showMessages
				msg = ''
				case status
				when :SLEEP	then msg = _INTL('{1} is already asleep!', pbThis)
				when :POISON	then msg = _INTL('{1} is already poisoned!', pbThis)
				when :BURN	then msg = _INTL('{1} already has a burn!', pbThis)
				when :PARALYSIS	then msg = _INTL('{1} is already numbed!', pbThis)
				when :FROZEN	then msg = _INTL('{1} is already chilled!', pbThis)
				when :FLUSTERED		then msg = _INTL('{1} is already flustered!', pbThis)
				when :MYSTIFIED		then msg = _INTL('{1} is already mystified!', pbThis)
				when :FROSTBITE		then msg = _INTL('{1} is already frostbitten!', pbThis)
				end
				@battle.pbDisplay(msg)
			end
			return false
		end
		# Trying to give too many statuses
		if !hasSpotsForStatus && !ignoreStatus && !selfInflicted
			if showMessages
				@battle.pbDisplay(_INTL('{1} cannot have any more status problems...', pbThis(false)))
			end
			return false
		end
		# Trying to inflict a status problem on a Pokémon behind a substitute
		if substituted? && !(move && move.ignoresSubstitute?(user)) && !selfInflicted && !statusDoublingCurse
			if showMessages
				@battle.pbDisplay(_INTL("It doesn't affect {1} behind its substitute...",
						pbThis(true)))
			end
			return false
		end
		# Terrains immunity
		if affectedByTerrain? && !statusDoublingCurse
			case @battle.field.terrain
			when :Electric
				if %i[SLEEP FLUSTERED MYSTIFIED].include?(newStatus)
					if showMessages
						@battle.pbDisplay(_INTL('{1} surrounds itself with electrified terrain!',
								pbThis(true)))
					end
					return false
				end
			when :Misty
				if %i[POISON BURN FROSTBITE].include?(newStatus)
					if showMessages
						@battle.pbDisplay(_INTL('{1} surrounds itself with fairy terrain!',
								pbThis(true)))
					end
					return false
				end
			end
		end
		# Uproar immunity
		if newStatus == :SLEEP && !(hasActiveAbility?(:SOUNDPROOF) && !@battle.moldBreaker) && !statusDoublingCurse
			@battle.eachBattler do |b|
				next if !b.effectActive?(:Uproar)
				@battle.pbDisplay(_INTL("But the uproar kept {1} awake!", pbThis(true))) if showMessages
				return false
			end
		end
		# Type immunities
		hasImmuneType = false
		immuneType = nil
		case newStatus
		when :SLEEP
			if pbHasType?(:GRASS) && !selfInflicted
				hasImmuneType = true
				immuneType = :GRASS
			end
		when :POISON
			unless user&.hasActiveAbility?(:CORROSION)
				if pbHasType?(:POISON)
					hasImmuneType = true
					immuneType = :POISON
				end
				if pbHasType?(:STEEL)
					hasImmuneType = true
					immuneType = :STEEL
				end
			end
		when :BURN
			if pbHasType?(:FIRE)
				hasImmuneType = true
				immuneType = :FIRE
			end
		when :PARALYSIS
			if pbHasType?(:ELECTRIC)
				hasImmuneType = true
				immuneType = :ELECTRIC
			end
		when :FROZEN, :FROSTBITE
			if pbHasType?(:ICE)
				hasImmuneType = true
				immuneType = :ICE
			end
		when :FLUSTERED
			if pbHasType?(:PSYCHIC)
				hasImmuneType = true
				immuneType = :PSYCHIC
			end
		when :MYSTIFIED
			if pbHasType?(:FAIRY)
				hasImmuneType = true
				immuneType = :FAIRY
			end
		end
		if hasImmuneType
			immuneTypeRealName = GameData::Type.get(immuneType).real_name
			if showMessages
				@battle.pbDisplay(_INTL("It doesn't affect {1} since it's an {2}-type...", pbThis(true),
						immuneTypeRealName))
			end
			return false
		end
		# Ability immunity
		immuneByAbility = false
		immAlly = nil
		if BattleHandlers.triggerStatusImmunityAbilityNonIgnorable(ability, self, newStatus)
			immuneByAbility = true
		elsif selfInflicted || !@battle.moldBreaker
			if abilityActive? && BattleHandlers.triggerStatusImmunityAbility(ability, self, newStatus)
				immuneByAbility = true
			else
				eachAlly do |b|
					next unless b.abilityActive?
					next unless BattleHandlers.triggerStatusImmunityAllyAbility(b.ability, self, newStatus)
					immuneByAbility = true
					immAlly = b
					break
				end
			end
		end
		if immuneByAbility
			if showMessages
				@battle.pbShowAbilitySplash(immAlly || self)
				msg = ''
				case newStatus
				when :SLEEP	then msg = _INTL('{1} stays awake!', pbThis)
				when :POISON	then msg = _INTL('{1} cannot be poisoned!', pbThis)
				when :BURN	then msg = _INTL('{1} cannot be burned!', pbThis)
				when :PARALYSIS	then msg = _INTL('{1} cannot be numbed!', pbThis)
				when :FROZEN	then msg = _INTL('{1} cannot be chilled!', pbThis)
				when :FLUSTERED		then msg = _INTL('{1} cannot be flustered!', pbThis)
				when :MYSTIFIED		then msg = _INTL('{1} cannot be mystified!', pbThis)
				when :FROSTBITE		then msg = _INTL('{1} cannot be frostbitten!', pbThis)
				end
				@battle.pbDisplay(msg)
				@battle.pbHideAbilitySplash(immAlly || self)
			end
			return false
		end
		# Safeguard immunity
		if pbOwnSide.effectActive?(:Safeguard) && !selfInflicted && move &&
					!(user && user.hasActiveAbility?(:INFILTRATOR)) && !statusDoublingCurse
			@battle.pbDisplay(_INTL("{1}'s team is protected by Safeguard!", pbThis)) if showMessages
			return false
		end
		return true
	end

	def pbCanSynchronizeStatus?(newStatus, target)
		return false if fainted?
		# Trying to replace a status problem with another one
		return false unless hasSpotsForStatus
		# Terrain immunity
		return false if @battle.field.terrain == :Misty &&
																		affectedByTerrain? &&
																		%i[BURN POISON].include?(newStatus)
		return false if @battle.field.terrain == :Electric &&
																		affectedByTerrain? &&
																		newStatus == :FROZEN
		# Type immunities
		hasImmuneType = false
		case newStatus
		when :POISON
			# NOTE: target will have Synchronize, so it can't have Corrosion.
			unless target&.hasActiveAbility?(:CORROSION)
				hasImmuneType |= pbHasType?(:POISON)
				hasImmuneType |= pbHasType?(:STEEL)
			end
		when :BURN
			hasImmuneType |= pbHasType?(:FIRE)
		when :PARALYSIS
			hasImmuneType |= pbHasType?(:ELECTRIC) && Settings::MORE_TYPE_EFFECTS
		when :FROZEN, :FROSTBITE
			hasImmuneType |= pbHasType?(:ICE)
		when :SLEEP
			hasImmuneType |= pbHasType?(:GRASS)
		when :FLUSTERED
			hasImmuneType |= pbHasType?(:PSYCHIC)
		when :MYSTIFIED
			hasImmuneType |= pbHasType?(:FAIRY)
		end
		return false if hasImmuneType
		# Ability immunity
		return false if BattleHandlers.triggerStatusImmunityAbilityNonIgnorable(ability, self, newStatus)
		return false if abilityActive? && BattleHandlers.triggerStatusImmunityAbility(ability, self, newStatus)
		eachAlly do |b|
			next unless b.abilityActive?
			next unless BattleHandlers.triggerStatusImmunityAllyAbility(b.ability, self, newStatus)
			return false
		end
		# Safeguard immunity
		if pbOwnSide.effectActive?(:Safeguard) &&
					!(user && user.hasActiveAbility?(:INFILTRATOR))
			return false
		end
		return true
	end

	#=============================================================================
	# Generalised infliction of status problem
	#=============================================================================
	def pbInflictStatus(newStatus, newStatusCount = 0, msg = nil, user = nil)

		newStatusCount = pbSleepDuration if newStatusCount <= 0 && newStatus == :SLEEP

		# Inflict the new status
		if !boss?
			self.status	= newStatus
			self.statusCount	= newStatusCount
		elsif @status == :NONE && !hasActiveAbility?(:COMATOSE)
			self.status	= newStatus
			self.statusCount = newStatusCount
		else
			self.bossStatus	= newStatus
			self.bossStatusCount	= newStatusCount
		end
		disableEffect(:Toxic)
		# Show animation
		if newStatus == :POISON && newStatusCount.positive?
			@battle.pbCommonAnimation('Toxic', self)
		else
			anim_name = GameData::Status.get(newStatus).animation
			@battle.pbCommonAnimation(anim_name, self) if anim_name
		end
		# Show message
		if msg != 'false'
			if msg && !msg.empty?
				@battle.pbDisplay(msg)
			else
				case newStatus
				when :SLEEP
					@battle.pbDisplay(_INTL('{1} fell asleep!', pbThis))
				when :POISON
					@battle.pbDisplay(_INTL('{1} was poisoned! {2}!', pbThis, POISONED_EXPLANATION))
				when :BURN
					@battle.pbDisplay(_INTL('{1} was burned! {2}!', pbThis, BURNED_EXPLANATION))
				when :PARALYSIS
					@battle.pbDisplay(_INTL('{1} is numbed! {2}!', pbThis, NUMBED_EXPLANATION))
				when :FROZEN
					@battle.pbDisplay(_INTL('{1} was chilled! {2}!', pbThis, CHILLED_EXPLANATION))
				when :FLUSTERED
					@battle.pbDisplay(_INTL('{1} is flustered! {2}!', pbThis, FLUSTERED_EXPLANATION))
				when :MYSTIFIED
					@battle.pbDisplay(_INTL('{1} is mystified! {2}!', pbThis, MYSTIFIED_EXPLANATION))
				when :FROSTBITE
					@battle.pbDisplay(_INTL('{1} was frostbitten! {2}!', pbThis, FROSTBITE_EXPLANATION))
				end
			end
		end
		if newStatus == :SLEEP
			PBDebug.log("[Status change] #{pbThis}'s sleep count is #{newStatusCount}")
			@battle.eachBattler do |b|
				next if b.nil?
				next unless b.hasActiveAbility?(:DREAMWEAVER)
				@battle.pbShowAbilitySplash(b)
				b.pbRaiseStatStage(:SPECIAL_ATTACK, 1, b)
				@battle.pbHideAbilitySplash(b)
			end
		end
		# Form change check
		pbCheckFormOnStatusChange
		# Synchronize
		BattleHandlers.triggerAbilityOnStatusInflicted(ability, self, user, newStatus) if abilityActive?
		# Status cures
		pbItemStatusCureCheck
		pbAbilityStatusCureCheck

		# Rampaging moves get cancelled immediately by falling asleep
		disableEffect(:Outrage) if newStatus == :SLEEP
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
		return false unless hasSpotsForStatus
		return false if affectedByTerrain? && %i[Electric Misty].include?(@battle.field.terrain)
		unless hasActiveAbility?(:SOUNDPROOF)
			@battle.eachBattler do |b|
				return false if b.effectActive?(:Uproar)
			end
		end
		return false if BattleHandlers.triggerStatusImmunityAbilityNonIgnorable(ability, self, :SLEEP)
		# NOTE: Bulbapedia claims that Flower Veil shouldn't prevent sleep due to
		#			 drowsiness, but I disagree because that makes no sense. Also, the
		#			 comparable Sweet Veil does prevent sleep due to drowsiness.
		return false if abilityActive? && BattleHandlers.triggerStatusImmunityAbility(ability, self, :SLEEP)
		eachAlly do |b|
			next unless b.abilityActive?
			next unless BattleHandlers.triggerStatusImmunityAllyAbility(b.ability, self, :SLEEP)
			return false
		end
		# NOTE: Bulbapedia claims that Safeguard shouldn't prevent sleep due to
		#			 drowsiness. I disagree with this too. Compare with the other sided
		#			 effects Misty/Electric Terrain, which do prevent it.
		return false if pbOwnSide.effectActive?(:Safeguard)
		return true
	end

	def pbSleep(msg = nil)
		pbInflictStatus(:SLEEP, -1, msg)
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

	def pbPoison(user = nil, msg = nil, toxic = false)
		if boss && toxic
			@battle.pbDisplay("The projection's power blunts the toxin.")
			toxic = false
		end
		pbInflictStatus(:POISON, toxic ? 1 : 0, msg, user)
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
		getStatuses.each do |oneStatus|
			next if !statusToContinue.nil? && oneStatus != statusToContinue
			if oneStatus == :POISON && @statusCount.positive?
				@battle.pbCommonAnimation('Toxic', self)
			else
				anim_name = GameData::Status.get(oneStatus).animation
				@battle.pbCommonAnimation(anim_name, self) if anim_name
			end
			yield if block_given?
			if !defined?($PokemonSystem.status_effect_messages) || $PokemonSystem.status_effect_messages.zero?
				case oneStatus
				when :SLEEP
					@battle.pbDisplay(_INTL('{1} is fast asleep.', pbThis))
				when :POISON
					@battle.pbDisplay(_INTL('{1} was hurt by poison!', pbThis))
				when :BURN
					@battle.pbDisplay(_INTL('{1} was hurt by its burn!', pbThis))
				when :FROSTBITE
					@battle.pbDisplay(_INTL('{1} was hurt by frostbite!', pbThis))
				when :FLUSTERED
					@battle.pbDisplay(_INTL('{1} was flustered, and attacked itself!', pbThis))
				when :MYSTIFIED
					@battle.pbDisplay(_INTL('{1} was mystified, and attacked itself!', pbThis))
				end
			end
			PBDebug.log("[Status continues] #{pbThis}'s sleep count is #{@statusCount}") if oneStatus == :SLEEP
		end
	end

	def pbCureStatus(showMessages = true, statusToCure = nil)
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
			next if oldStatus == :NONE

			PokeBattle_Battler.showStatusCureMessage(oldStatus, self, @battle) if showMessages
			PBDebug.log("[Status change] #{pbThis}'s status #{oldStatus} was cured")

			# Lingering Daze
			next unless oldStatus == :SLEEP
			@battle.eachOtherSideBattler(@index) do |b|
				if b.hasActiveAbility?(:LINGERINGDAZE)
					@battle.pbShowAbilitySplash(b)
					pbLowerStatStage(:ATTACK, 2, b)
					pbLowerStatStage(:SPECIAL_ATTACK, 2, b, false)
					@battle.pbHideAbilitySplash(b)
				end
			end
		end

		@battle.scene.pbRefreshOne(@index)
	end

	def self.showStatusCureMessage(status, pokemonOrBattler, battle)
		curedName = pokemonOrBattler.is_a?(PokeBattle_Battler) ? pokemonOrBattler.pbThis : pokemonOrBattler.name
		case status
		when :SLEEP	then battle.pbDisplay(_INTL('{1} woke up!', curedName))
		when :POISON	then battle.pbDisplay(_INTL('{1} was cured of its poisoning.', curedName))
		when :BURN	then battle.pbDisplay(_INTL("{1}'s burn was healed.", curedName))
		when :FROSTBITE		then battle.pbDisplay(_INTL("{1}'s frostbite was healed.", curedName))
		when :PARALYSIS 	then battle.pbDisplay(_INTL('{1} is no longer numbed.', curedName))
		when :FROZEN	then battle.pbDisplay(_INTL('{1} warmed up!', curedName))
		when :FLUSTERED		then battle.pbDisplay(_INTL('{1} is no longer flustered!', curedName))
		when :MYSTIFIED		then battle.pbDisplay(_INTL('{1} is no longer mystified!', curedName))
		end
	end

	#=============================================================================
	# Confusion
	#=============================================================================
	def confused?
		return effectActive?(:Confusion)
	end
	
	def pbCanConfuse?(user = nil, showMessages = true, move = nil, selfInflicted = false)
		return false if fainted?
		if confused?
			@battle.pbDisplay(_INTL('{1} is already confused.', pbThis)) if showMessages
			return false
		end
		if substituted? && !(move && move.ignoresSubstitute?(user)) &&
					!selfInflicted
			@battle.pbDisplay(_INTL('But it failed!')) if showMessages
			return false
		end
		if (selfInflicted || !@battle.moldBreaker) && hasActiveAbility?(:OWNTEMPO)
			if showMessages
				@battle.pbShowAbilitySplash(self)
				@battle.pbDisplay(_INTL("{1} doesn't become confused!", pbThis))
				@battle.pbHideAbilitySplash(self)
			end
			return false
		end
		if pbOwnSide.effectActive?(:Safeguard) && !selfInflicted && !(user && user.hasActiveAbility?(:INFILTRATOR))
			@battle.pbDisplay(_INTL("{1}'s team is protected by Safeguard!", pbThis)) if showMessages
			return false
		end
		return true
	end

	def pbCanConfuseSelf?(showMessages)
		return pbCanConfuse?(nil, showMessages, nil, true)
	end

	def pbConfuse(msg = nil)
		applyEffect(:Confusion, pbConfusionDuration)
		applyEffect(:ConfusionChance, 0)
	end

	def pbConfusionDuration(duration = -1)
		duration = 3 if duration <= 0
		return duration
	end

	#=============================================================================
	# Charm
	#=============================================================================
	def charmed?
		return effectActive?(:Charm)
	end

	def pbCanCharm?(user = nil, showMessages = true, move = nil, selfInflicted = false)
		return false if fainted?
		if charmed?
			@battle.pbDisplay(_INTL('{1} is already charmed.', pbThis)) if showMessages
			return false
		end
		if substituted? && !(move && move.ignoresSubstitute?(user)) &&
					!selfInflicted
			@battle.pbDisplay(_INTL('But it failed!')) if showMessages
			return false
		end
		if (selfInflicted || !@battle.moldBreaker) && hasActiveAbility?(:OWNTEMPO)
			if showMessages
				@battle.pbShowAbilitySplash(self)
				@battle.pbDisplay(_INTL("{1} doesn't become charmed!", pbThis))
				@battle.pbHideAbilitySplash(self)
			end
			return false
		end
		if pbOwnSide.effectActive?(:Safeguard) && !selfInflicted && !(user && user.hasActiveAbility?(:INFILTRATOR))
			@battle.pbDisplay(_INTL("{1}'s team is protected by Safeguard!", pbThis)) if showMessages
			return false
		end
		return true
	end

	def pbCanCharmSelf?(showMessages)
		return pbCanConfuse?(nil, showMessages, nil, true)
	end

	def pbCharm(msg = nil)
		applyEffect(:Charm, pbCharmDuration)
		applyEffect(:CharmChance, 0)
	end

	def pbCharmDuration(duration = -1)
		duration = 3 if duration <= 0
		return duration
	end

	#=============================================================================
	# Flinching
	#=============================================================================
	def pbFlinch(_user = nil)
		return if hasActiveAbility?(:INNERFOCUS) && !@battle.moldBreaker
		applyEffect(:Flinch)
	end

	#=============================================================================
	# Frozen
	#=============================================================================
	def pbCanFrozenSynchronize?(target)
		return pbCanSynchronizeStatus?(:FROZEN, target)
	end

	#=============================================================================
	# Flustered
	#=============================================================================
	def flustered?
		return pbHasStatus?(:FLUSTERED)
	end

	def pbCanFluster?(user, showMessages, move = nil)
		return pbCanInflictStatus?(:FLUSTERED, user, showMessages, move)
	end

	def pbFluster(user = nil, msg = nil)
		pbInflictStatus(:FLUSTERED, 0, msg, user)
	end

	#=============================================================================
	# Mystified
	#=============================================================================
	def mystified?
		return pbHasStatus?(:MYSTIFIED)
	end

	def pbCanMystify?(user, showMessages, move = nil)
		return pbCanInflictStatus?(:MYSTIFIED, user, showMessages, move)
	end

	def pbMystify(user = nil, msg = nil)
		pbInflictStatus(:MYSTIFIED, 0, msg, user)
	end

	#=============================================================================
	# Frostbite
	#=============================================================================
	def frostbitten?
		return pbHasStatus?(:FROSTBITE)
	end

	def pbCanFrostbite?(user, showMessages, move = nil)
		return pbCanInflictStatus?(:FROSTBITE, user, showMessages, move)
	end

	def pbCanFrostbiteSynchronize?(target)
		return pbCanSynchronizeStatus?(:FROSTBITE, target)
	end

	def pbFrostbite(user = nil, msg = nil)
		pbInflictStatus(:FROSTBITE, 0, msg, user)
	end

	#=============================================================================
	# Attract (Cut mechanic)
	#=============================================================================
	def pbCanAttract?(*args)
		return false
	end
end
