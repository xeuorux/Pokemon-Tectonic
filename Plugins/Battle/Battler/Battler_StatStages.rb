class PokeBattle_Battler
	# These are not yet used everywhere they should be. Do not modify and expect consistent results.
	STAGE_MULTIPLIERS = [2, 2, 2, 2, 2, 2, 2, 3, 4, 5, 6, 7, 8].freeze
	STAGE_DIVISORS    = [8, 7, 6, 5, 4, 3, 2, 2, 2, 2, 2, 2, 2].freeze

	#=============================================================================
	# Increase stat stages
	#=============================================================================
	def statStageAtMax?(stat)
		return @stages[stat] >= 6
	end

	def pbRaiseStatStageBasic(stat, increment, ignoreContrary = false)
		unless @battle.moldBreaker
			# Contrary
			return pbLowerStatStageBasic(stat, increment, true) if hasActiveAbility?(:CONTRARY) && !ignoreContrary
			# Simple
			increment *= 2 if hasActiveAbility?(:SIMPLE)
		end
		# Change the stat stage
		increment = [increment, 6 - @stages[stat]].min
		if increment.positive?
			stat_name = GameData::Stat.get(stat).name
			new = @stages[stat] + increment
			PBDebug.log("[Stat change] #{pbThis}'s #{stat_name}: #{@stages[stat]} -> #{new} (+#{increment})")
			@stages[stat] += increment
		end
		return increment
	end

	def pbCanRaiseStatStage?(stat, user = nil, move = nil, showFailMsg = false, ignoreContrary = false)
		return false if fainted?
		# Contrary
		return pbCanLowerStatStage?(stat, user, move, showFailMsg, true) if hasActiveAbility?(:CONTRARY) && !ignoreContrary && !@battle.moldBreaker
		# Check the stat stage
		if statStageAtMax?(stat)
			if showFailMsg
				@battle.pbDisplay(_INTL("{1}'s {2} won't go any higher!",pbThis, GameData::Stat.get(stat).name))
			end
			return false
		end
		return true
	end

	def pbRaiseStatStage(stat, increment, user, showAnim = true, ignoreContrary = false)
		# Contrary
		return pbLowerStatStage(stat, increment, user, showAnim, true) if hasActiveAbility?(:CONTRARY) && !ignoreContrary && !@battle.moldBreaker
		# Perform the stat stage change
		increment = pbRaiseStatStageBasic(stat, increment, ignoreContrary)
		return false if increment <= 0
		# Stat up animation and message
		@battle.pbCommonAnimation('StatUp', self) if showAnim
		arrStatTexts = [
			_INTL("{1}'s {2} rose{3}!", pbThis, GameData::Stat.get(stat).name, boss? ? ' slightly' : ''),
			_INTL("{1}'s {2} rose{3}!", pbThis, GameData::Stat.get(stat).name, boss? ? '' : ' sharply'),
			_INTL("{1}'s {2} rose{3}!", pbThis, GameData::Stat.get(stat).name,
									boss? ? ' greatly' : ' drastically'),
		]
		@battle.pbDisplay(arrStatTexts[[increment - 1, 2].min])
		# Trigger abilities upon stat gain
		BattleHandlers.triggerAbilityOnStatGain(ability, self, stat, user) if abilityActive?
		return true
	end

	def pbRaiseStatStageByCause(stat, increment, user, cause, showAnim = true, ignoreContrary = false)
		# Contrary
		return pbLowerStatStageByCause(stat, increment, user, cause, showAnim, true) if hasActiveAbility?(:CONTRARY) && !ignoreContrary && !@battle.moldBreaker
		# Perform the stat stage change
		increment = pbRaiseStatStageBasic(stat, increment, ignoreContrary)
		return false if increment <= 0
		# Stat up animation and message
		@battle.pbCommonAnimation('StatUp', self) if showAnim
		if user.index == @index
			arrStatTexts = [
				_INTL("{1}'s {2}{4} raised its {3}!", pbThis, cause, GameData::Stat.get(stat).name,
						boss? ? ' slightly' : ''),
				_INTL("{1}'s {2}{4} raised its {3}!", pbThis, cause, GameData::Stat.get(stat).name,
						boss? ? '' : ' sharply'),
				_INTL("{1}'s {2}{4} raised its {3}!", pbThis, cause, GameData::Stat.get(stat).name,
						boss? ? ' greatly' : ' drastically'),
			]
		else
			arrStatTexts = [
				_INTL("{1}'s {2}{5} raised {3}'s {4}!", user.pbThis, cause, pbThis(true),
						GameData::Stat.get(stat).name, boss? ? ' slightly' : ''),
				_INTL("{1}'s {2}{5} raised {3}'s {4}!", user.pbThis, cause, pbThis(true),
						GameData::Stat.get(stat).name, boss? ? '' : ' sharply'),
				_INTL("{1}'s {2}{5} raised {3}'s {4}!", user.pbThis, cause, pbThis(true),
						GameData::Stat.get(stat).name, boss? ? ' greatly' : ' drastically'),
			]
		end
		@battle.pbDisplay(arrStatTexts[[increment - 1, 2].min])
		# Trigger abilities upon stat gain
		BattleHandlers.triggerAbilityOnStatGain(ability, self, stat, user) if abilityActive?
		return true
	end

	def pbRaiseStatStageByAbility(stat, increment, user, splashAnim = true)
		return false if fainted?
		ret = false
		@battle.pbShowAbilitySplash(user) if splashAnim
		if pbCanRaiseStatStage?(stat, user, nil, PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
			if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
				ret = pbRaiseStatStage(stat, increment, user)
			else
				ret = pbRaiseStatStageByCause(stat, increment, user, user.abilityName)
			end
		end
		@battle.pbHideAbilitySplash(user) if splashAnim
		return ret
	end

	#=============================================================================
	# Decrease stat stages
	#=============================================================================
	def statStageAtMin?(stat)
		return @stages[stat] <= -6
	end

	def pbCanLowerStatStage?(stat, user = nil, move = nil, showFailMsg = false, ignoreContrary = false)
		return false if fainted?
		# Contrary
		return pbCanRaiseStatStage?(stat, user, move, showFailMsg, true) if hasActiveAbility?(:CONTRARY) && !ignoreContrary && !@battle.moldBreaker
		if !user || user.index != @index # Not self-inflicted
			if substituted? && !(move && move.ignoresSubstitute?(user))
				@battle.pbDisplay(_INTL('{1} is protected by its substitute!', pbThis)) if showFailMsg
				return false
			end
			if pbOwnSide.effectActive?(:Mist) &&
						!(user && user.hasActiveAbility?(:INFILTRATOR))
				@battle.pbDisplay(_INTL('{1} is protected by Mist!', pbThis)) if showFailMsg
				return false
			end
			if abilityActive?
				return false if !@battle.moldBreaker && BattleHandlers.triggerStatLossImmunityAbility(
					ability, self, stat, @battle, showFailMsg
				)
				return false if BattleHandlers.triggerStatLossImmunityAbilityNonIgnorable(
					ability, self, stat, @battle, showFailMsg
				)
			end
			unless @battle.moldBreaker
				eachAlly do |b|
					next unless b.abilityActive?
					return false if BattleHandlers.triggerStatLossImmunityAllyAbility(
						b.ability, b, self, stat, @battle, showFailMsg
					)
				end
			end
		elsif hasActiveAbility?(:STUBBORN) && !@battle.moldBreaker
			return false
		end
		# Check the stat stage
		if statStageAtMin?(stat)
			if showFailMsg
				@battle.pbDisplay(_INTL("{1}'s {2} won't go any lower!",pbThis, GameData::Stat.get(stat).name))
			end
			return false
		end
		return true
	end

	def pbLowerStatStageBasic(stat, increment, ignoreContrary = false)
		unless @battle.moldBreaker
			# Contrary
			return pbRaiseStatStageBasic(stat, increment, true) if hasActiveAbility?(:CONTRARY) && !ignoreContrary
			# Simple
			increment *= 2 if hasActiveAbility?(:SIMPLE)
		end
		# Change the stat stage
		increment = [increment, 6 + @stages[stat]].min
		if increment.positive?
			stat_name = GameData::Stat.get(stat).name
			new = @stages[stat] - increment
			PBDebug.log("[Stat change] #{pbThis}'s #{stat_name}: #{@stages[stat]} -> #{new} (-#{increment})")
			@stages[stat] -= increment
		end
		return increment
	end

	def pbLowerStatStage(stat, increment, user, showAnim = true, ignoreContrary = false, ignoreMirrorArmor = false)
		# Mirror Armor, only if not self inflicted
		if !ignoreMirrorArmor && hasActiveAbility?(:MIRRORARMOR) && (!user || user.index != @index) &&
					!@battle.moldBreaker && pbCanLowerStatStage?(stat)
			battle.pbShowAbilitySplash(self)
			@battle.pbDisplay(_INTL("{1}'s Mirror Armor activated!", pbThis))
			unless user
				battle.pbHideAbilitySplash(self)
				return false
			end
			if !user.hasActiveAbility?(:MIRRORARMOR) && user.pbCanLowerStatStage?(stat, nil, nil, true)
				user.pbLowerStatStageByAbility(stat, increment, user, splashAnim = false,							checkContact = false)
				# Trigger user's abilities upon stat loss
				BattleHandlers.triggerAbilityOnStatLoss(user.ability, user, stat, self) if user.abilityActive?
			end
			battle.pbHideAbilitySplash(self)
			return false
		end
		# Contrary
		return pbRaiseStatStage(stat, increment, user, showAnim, true) if hasActiveAbility?(:CONTRARY) && !ignoreContrary && !@battle.moldBreaker
		# Stubborn
		return false if hasActiveAbility?(:STUBBORN) && !@battle.moldBreaker
		# Perform the stat stage change
		increment = pbLowerStatStageBasic(stat, increment, ignoreContrary)
		return false if increment <= 0
		# Stat down animation and message
		@battle.pbCommonAnimation('StatDown', self) if showAnim
		arrStatTexts = [
			_INTL("{1}'s {2}{3} fell!", pbThis, GameData::Stat.get(stat).name, boss? ? ' slightly' : ''),
			_INTL("{1}'s {2}{3} fell!", pbThis, GameData::Stat.get(stat).name, boss? ? '' : ' harshly'),
			_INTL("{1}'s {2}{3} fell!", pbThis, GameData::Stat.get(stat).name,
									boss? ? ' severely' : ' badly'),
		]
		@battle.pbDisplay(arrStatTexts[[increment - 1, 2].min])
		# Trigger abilities upon stat loss
		BattleHandlers.triggerAbilityOnStatLoss(ability, self, stat, user) if abilityActive?
		applyEffect(:StatsDropped)
		return true
	end

	def pbLowerStatStageByCause(stat, increment, user, cause, showAnim = true, ignoreContrary = false, ignoreMirrorArmor = false)
		# Mirror Armor
		if !ignoreMirrorArmor && hasActiveAbility?(:MIRRORARMOR) && (!user || user.index != @index) &&
					!@battle.moldBreaker && pbCanLowerStatStage?(stat)
			battle.pbShowAbilitySplash(self)
			@battle.pbDisplay(_INTL("{1}'s Mirror Armor activated!", pbThis))
			unless user
				battle.pbHideAbilitySplash(self)
				return false
			end
			if !user.hasActiveAbility?(:MIRRORARMOR) && user.pbCanLowerStatStage?(stat, nil, nil, true)
				user.pbLowerStatStageByAbility(stat, increment, user, splashAnim = false,							checkContact = false)
				# Trigger user's abilities upon stat loss
				BattleHandlers.triggerAbilityOnStatLoss(user.ability, user, stat, self) if user.abilityActive?
			end
			battle.pbHideAbilitySplash(self)
			return false
		end
		# Contrary
		return pbRaiseStatStageByCause(stat, increment, user, cause, showAnim, true) if hasActiveAbility?(:CONTRARY) && !ignoreContrary && !@battle.moldBreaker
		# Stubborn
		return false if hasActiveAbility?(:STUBBORN) && !@battle.moldBreaker
		# Perform the stat stage change
		increment = pbLowerStatStageBasic(stat, increment, ignoreContrary)
		return false if increment <= 0
		# Stat down animation and message
		@battle.pbCommonAnimation('StatDown', self) if showAnim
		if user.index == @index
			arrStatTexts = [
				_INTL("{1}'s {2}{4} lowered its {3}!", pbThis, cause, GameData::Stat.get(stat).name,
						boss? ? ' slightly' : ''),
				_INTL("{1}'s {2}{4} lowered its {3}!", pbThis, cause, GameData::Stat.get(stat).name,
						boss? ? '' : ' harshly'),
				_INTL("{1}'s {2}{4} lowered its {3}!", pbThis, cause, GameData::Stat.get(stat).name,
						boss? ? ' severely' : ' badly'),
			]
		else
			arrStatTexts = [
				_INTL("{1}'s {2}{5} lowered {3}'s {4}!", user.pbThis, cause, pbThis(true),
						GameData::Stat.get(stat).name, boss? ? ' slightly' : ''),
				_INTL("{1}'s {2}{5} lowered {3}'s {4}!", user.pbThis, cause, pbThis(true),
						GameData::Stat.get(stat).name, boss? ? '' : ' harshly'),
				_INTL("{1}'s {2}{5} lowered {3}'s {4}!", user.pbThis, cause, pbThis(true),
						GameData::Stat.get(stat).name, boss? ? ' severely' : ' badly'),
			]
		end
		@battle.pbDisplay(arrStatTexts[[increment - 1, 2].min])
		# Trigger abilities upon stat loss
		BattleHandlers.triggerAbilityOnStatLoss(ability, self, stat, user) if abilityActive?
		applyEffect(:StatsDropped)
		return true
	end

	def pbLowerStatStageByAbility(stat, increment, user, splashAnim = true, checkContact = false)
		ret = false
		@battle.pbShowAbilitySplash(user) if splashAnim
		if pbCanLowerStatStage?(stat, user, nil, PokeBattle_SceneConstants::USE_ABILITY_SPLASH) &&
					(!checkContact || affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH))
			if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
				ret = pbLowerStatStage(stat, increment, user)
			else
				ret = pbLowerStatStageByCause(stat, increment, user, user.abilityName)
			end
		end
		@battle.pbHideAbilitySplash(user) if splashAnim
		return ret
	end

	def pbLowerAttackStatStageIntimidate(user)
		return false if fainted?
		# NOTE: Substitute intentially blocks Intimidate even if self has Contrary.
		if substituted?
			if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
				@battle.pbDisplay(_INTL('{1} is protected by its substitute!', pbThis))
			else
				@battle.pbDisplay(_INTL("{1}'s substitute protected it from {2}'s {3}!",pbThis, user.pbThis(true), user.abilityName))
			end
			return false
		end
		if hasActiveAbility?(:INNERFOCUS)
			@battle.pbShowAbilitySplash(self, true)
			@battle.pbDisplay(_INTL("{1}'s {2} prevented {3}'s {4} from working!",
					pbThis, abilityName, user.pbThis(true), user.abilityName))
			@battle.pbHideAbilitySplash(self)
			return false
		end
		return pbLowerStatStageByAbility(:ATTACK, 1, user, false) if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
		# NOTE: These checks exist to ensure appropriate messages are shown if
		#       Intimidate is blocked somehow (i.e. the messages should mention the
		#       Intimidate ability by name).
		unless hasActiveAbility?(:CONTRARY)
			if pbOwnSide.effectActive?(:Mist)
				@battle.pbDisplay(_INTL("{1} is protected from {2}'s {3} by Mist!",pbThis, user.pbThis(true), user.abilityName))
				return false
			end
			if abilityActive? && (BattleHandlers.triggerStatLossImmunityAbility(ability, self, :ATTACK,											@battle, false) ||
						BattleHandlers.triggerStatLossImmunityAbilityNonIgnorable(ability, self, :ATTACK, @battle,								false))
				@battle.pbDisplay(_INTL("{1}'s {2} prevented {3}'s {4} from working!",pbThis, abilityName, user.pbThis(true), user.abilityName))
				return false
			end
			eachAlly do |b|
				next unless b.abilityActive?
				if BattleHandlers.triggerStatLossImmunityAllyAbility(b.ability, b, self, :ATTACK, @battle,	false)
					@battle.pbDisplay(_INTL("{1} is protected from {2}'s {3} by {4}'s {5}!",	pbThis, user.pbThis(true), user.abilityName, b.pbThis(true), b.abilityName))
					return false
				end
			end
		end
		return false unless pbCanLowerStatStage?(:ATTACK, user)
		return pbLowerStatStageByCause(:ATTACK, 1, user, user.abilityName)
	end

	def pbLowerSpecialAttackStatStageFascinate(user)
		return false if fainted?
		# NOTE: Substitute intentially blocks Intimidate even if self has Contrary.
		if substitute?
			if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
				@battle.pbDisplay(_INTL('{1} is protected by its substitute!', pbThis))
			else
				@battle.pbDisplay(_INTL("{1}'s substitute protected it from {2}'s {3}!",pbThis, user.pbThis(true), user.abilityName))
			end
			return false
		end
		if hasActiveAbility?(:INNERFOCUS)
			@battle.pbShowAbilitySplash(self, true)
			@battle.pbDisplay(_INTL("{1}'s {2} prevented {3}'s {4} from working!",
					pbThis, abilityName, user.pbThis(true), user.abilityName))
			@battle.pbHideAbilitySplash(self)
			return false
		end
		return pbLowerStatStageByAbility(:SPECIAL_ATTACK, 1, user, false) if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
		# NOTE: These checks exist to ensure appropriate messages are shown if
		#       Intimidate is blocked somehow (i.e. the messages should mention the
		#       Intimidate ability by name).
		unless hasActiveAbility?(:CONTRARY)
			if pbOwnSide.effectActive?(:Mist)
				@battle.pbDisplay(_INTL("{1} is protected from {2}'s {3} by Mist!",pbThis, user.pbThis(true), user.abilityName))
				return false
			end
			if abilityActive? && (BattleHandlers.triggerStatLossImmunityAbility(ability, self,											:SPECIAL_ATTACK, @battle, false) ||
						BattleHandlers.triggerStatLossImmunityAbilityNonIgnorable(ability, self, :SPECIAL_ATTACK,								@battle, false))
				@battle.pbDisplay(_INTL("{1}'s {2} prevented {3}'s {4} from working!",pbThis, abilityName, user.pbThis(true), user.abilityName))
				return false
			end
			eachAlly do |b|
				next unless b.abilityActive?
				if BattleHandlers.triggerStatLossImmunityAllyAbility(b.ability, b, self, :SPECIAL_ATTACK,	@battle, false)
					@battle.pbDisplay(_INTL("{1} is protected from {2}'s {3} by {4}'s {5}!",	pbThis, user.pbThis(true), user.abilityName, b.pbThis(true), b.abilityName))
					return false
				end
			end
		end
		return false unless pbCanLowerStatStage?(:SPECIAL_ATTACK, user)
		return pbLowerStatStageByCause(:SPECIAL_ATTACK, 1, user, user.abilityName)
	end

	def pbLowerSpeedStatStageFrustrate(user)
		return false if fainted?
		# NOTE: Substitute intentially blocks Intimidate even if self has Contrary.
		if substituted?
			if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
				@battle.pbDisplay(_INTL('{1} is protected by its substitute!', pbThis))
			else
				@battle.pbDisplay(_INTL("{1}'s substitute protected it from {2}'s {3}!",pbThis, user.pbThis(true), user.abilityName))
			end
			return false
		end
		if hasActiveAbility?(:INNERFOCUS)
			@battle.pbShowAbilitySplash(self, true)
			@battle.pbDisplay(_INTL("{1}'s {2} prevented {3}'s {4} from working!",
					pbThis, abilityName, user.pbThis(true), user.abilityName))
			@battle.pbHideAbilitySplash(self)
			return false
		end
		return pbLowerStatStageByAbility(:SPEED, 1, user, false) if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
		# NOTE: These checks exist to ensure appropriate messages are shown if
		#       Intimidate is blocked somehow (i.e. the messages should mention the
		#       Intimidate ability by name).
		unless hasActiveAbility?(:CONTRARY)
			if pbOwnSide.effectActive?(:Mist)
				@battle.pbDisplay(_INTL("{1} is protected from {2}'s {3} by Mist!",pbThis, user.pbThis(true), user.abilityName))
				return false
			end
			if abilityActive? && (BattleHandlers.triggerStatLossImmunityAbility(ability, self, :SPEED,											@battle, false) ||
						BattleHandlers.triggerStatLossImmunityAbilityNonIgnorable(ability, self, :SPEED, @battle,								false))
				@battle.pbDisplay(_INTL("{1}'s {2} prevented {3}'s {4} from working!",pbThis, abilityName, user.pbThis(true), user.abilityName))
				return false
			end
			eachAlly do |b|
				next unless b.abilityActive?
				if BattleHandlers.triggerStatLossImmunityAllyAbility(b.ability, b, self, :SPEED, @battle,	false)
					@battle.pbDisplay(_INTL("{1} is protected from {2}'s {3} by {4}'s {5}!",	pbThis, user.pbThis(true), user.abilityName, b.pbThis(true), b.abilityName))
					return false
				end
			end
		end
		return false unless pbCanLowerStatStage?(:SPEED, user)
		return pbLowerStatStageByCause(:SPEED, 1, user, user.abilityName)
	end

	def pbMinimizeStatStage(stat, user = nil, move = nil, ignoreContrary = false)
		if hasActiveAbility?(:CONTRARY) && !ignoreContrary
			pbMaximizeStatStage(stat, user, move, true)
		elsif pbCanLowerStatStage?(stat, user, move, true, ignoreContrary)
			@stages[stat] = -6
			@battle.pbCommonAnimation('StatDown', self)
			statName = GameData::Stat.get(stat).real_name
			@battle.pbDisplay(_INTL('{1} minimized its {2}!', pbThis, statName))
		end
	end

	def pbMaximizeStatStage(stat, user = nil, move = nil, ignoreContrary = false)
		if hasActiveAbility?(:CONTRARY) && !ignoreContrary
			pbMinimizeStatStage(stat, user, move, true)
		elsif pbCanRaiseStatStage?(stat, user, move, true, ignoreContrary)
			@stages[stat] = 6
			@battle.pbCommonAnimation('StatUp', self)
			statName = GameData::Stat.get(stat).real_name
			@battle.pbDisplay(_INTL('{1} maximizes its {2}!', pbThis, statName))
		end
	end

	#=============================================================================
	# Reset stat stages
	#=============================================================================
	def hasAlteredStatStages?
		GameData::Stat.each_battle { |s| return true if @stages[s.id] != 0 }
		return false
	end

	def hasRaisedStatStages?
		GameData::Stat.each_battle { |s| return true if (@stages[s.id]).positive? }
		return false
	end

	def hasLoweredStatStages?
		GameData::Stat.each_battle { |s| return true if (@stages[s.id]).negative? }
		return false
	end

	def pbResetStatStages
		GameData::Stat.each_battle { |s| @stages[s.id] = 0 }
	end
end
