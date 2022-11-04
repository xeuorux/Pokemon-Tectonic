class PokeBattle_Battler
	#=============================================================================
	# Called when a Pokémon (self) is sent into battle or its ability changes.
	#=============================================================================
	def pbEffectsOnSwitchIn(switchIn = false)
		# Healing Wish/Lunar Dance/entry hazards
		@battle.pbOnActiveOne(self) if switchIn
		# Primal Revert upon entering battle
		@battle.pbPrimalReversion(@index) unless fainted?
		# Ending primordial weather, checking Trace
		pbContinualAbilityChecks(true)
		# Abilities that trigger upon switching in
		BattleHandlers.triggerAbilityOnSwitchIn(ability, self, @battle) if (!fainted? && unstoppableAbility?) || abilityActive?
		# Check for end of primordial weather
		@battle.pbEndPrimordialWeather
		# Items that trigger upon switching in (Air Balloon message)
		BattleHandlers.triggerItemOnSwitchIn(item, self, @battle) if switchIn && itemActive?
		# Berry check, status-curing ability check
		pbHeldItemTriggerCheck if switchIn
		pbAbilityStatusCureCheck
	end

	#=============================================================================
	# Ability effects
	#=============================================================================
	def pbAbilitiesOnSwitchOut
		BattleHandlers.triggerAbilityOnSwitchOut(ability, self, false) if abilityActive?
		# Reset form
		@battle.peer.pbOnLeavingBattle(@battle, @pokemon, @battle.usedInBattle[idxOwnSide][@index / 2])
		# Treat self as fainted
		@hp = 0
		@fainted = true
		# Check for end of primordial weather
		@battle.pbEndPrimordialWeather
	end

	def pbAbilitiesOnFainting
		# Self fainted; check all other battlers to see if their abilities trigger
		@battle.pbPriority(true).each do |b|
			next if !b || !b.abilityActive?
			BattleHandlers.triggerAbilityChangeOnBattlerFainting(b.ability, b, self, @battle)
		end
		@battle.pbPriority(true).each do |b|
			next if !b || !b.abilityActive?
			BattleHandlers.triggerAbilityOnBattlerFainting(b.ability, b, self, @battle)
		end
	end

	# Used for Emergency Exit/Wimp Out.
	def pbAbilitiesOnDamageTaken(oldHP, newHP = -1)
		return false unless abilityActive?
		newHP = @hp if newHP < 0
		return false if oldHP < @totalhp / 2 || newHP >= @totalhp / 2 # Didn't drop below half
		ret = BattleHandlers.triggerAbilityOnHPDroppedBelowHalf(ability, self, @battle)
		return ret # Whether self has switched out
	end

	# Called when a Pokémon (self) enters battle, at the end of each move used,
	# and at the end of each round.
	def pbContinualAbilityChecks(onSwitchIn = false)
		# Check for end of primordial weather
		@battle.pbEndPrimordialWeather
		# Trace
		if hasActiveAbility?(:TRACE)
			# NOTE: In Gen 5 only, Trace only triggers upon the Trace bearer switching
			#       in and not at any later times, even if a traceable ability turns
			#       up later. Essentials ignores this, and allows Trace to trigger
			#       whenever it can even in the old battle mechanics.
			choices = []
			@battle.eachOtherSideBattler(@index) do |b|
				next if b.ungainableAbility? ||
												%i[POWEROFALCHEMY RECEIVER TRACE].include?(b.ability_id)
				choices.push(b)
			end
			if choices.length > 0
				choice = choices[@battle.pbRandom(choices.length)]
				@battle.pbShowAbilitySplash(self)
				self.ability = choice.ability
				@battle.pbDisplay(_INTL("{1} traced {2}'s {3}!", pbThis, choice.pbThis(true), choice.abilityName))
				@battle.pbHideAbilitySplash(self)
				BattleHandlers.triggerAbilityOnSwitchIn(ability, self, @battle) if !onSwitchIn && (unstoppableAbility? || abilityActive?)
			end
		end
	end

	#=============================================================================
	# Ability curing
	#=============================================================================
	# Cures status conditions, confusion and infatuation.
	def pbAbilityStatusCureCheck
		BattleHandlers.triggerStatusCureAbility(ability, self) if abilityActive?
	end

	#=============================================================================
	# Ability change
	#=============================================================================
	def pbOnAbilityChanged(oldAbil)
		if illusion? && oldAbil == :ILLUSION
			disableEffect(:Illusion)
			unless effectActive?(:Transform)
				@battle.scene.pbChangePokemon(self, @pokemon)
				@battle.pbDisplay(_INTL("{1}'s {2} wore off!", pbThis, GameData::Ability.get(oldAbil).name))
				@battle.pbSetSeen(self)
			end
		end
		disableEffect(:GastroAcid) if unstoppableAbility?
		disableEffect(:SlowStart) if ability != :SLOWSTART
		# Revert form if Flower Gift/Forecast was lost
		pbCheckFormOnWeatherChange
		# Check for end of primordial weather
		@battle.pbEndPrimordialWeather
	end

	#=============================================================================
	# Held item consuming/removing
	#=============================================================================
	def canConsumeBerry?
		return false if @battle.pbCheckOpposingAbility(:UNNERVE, @index)
		return true
	end

	def canConsumePinchBerry?(check_gluttony = true)
		return false unless canConsumeBerry?
		return true if @hp <= @totalhp / 4
		return true if @hp <= @totalhp / 2 && (!check_gluttony || hasActiveAbility?(:GLUTTONY))
		return false
	end

	# permanent is whether the item is lost even after battle. Is false for Knock
	# Off.
	def pbRemoveItem(permanent = true)
		permanent = false # Items respawn after battle always!!
		disableEffect(:ChoiceBand)
		applyEffect(:ItemLost) if item
		setInitialItem(nil) if permanent && item == initialItem
		self.item = nil
	end

	#=========================================
	# Also handles SCAVENGE
	#=========================================
	def pbConsumeItem(recoverable = true, symbiosis = true, belch = true, scavenge = true)
		if item.nil?
			PBDebug.log("[Item not consumed] #{pbThis} could not consume its held #{itemName} because it was already missing")
			return
		end
		PBDebug.log("[Item consumed] #{pbThis} consumed its held #{itemName}")
		@battle.triggerBattlerConsumedItemDialogue(self, @item_id)
		if recoverable
			setRecycleItem(@item_id)
			applyEffect(:PickupItem,@item_id)
			applyEffect(:PickupUse,@battle.nextPickupUse)
		end
		setBelched if belch && item.is_berry?
		pbScavenge if scavenge
		pbRemoveItem
		pbSymbiosis if symbiosis
	end

	def pbScavenge
		return if fainted?
		return if @battle.curseActive?(:CURSE_SUPER_ITEMS) && pbOwnedByPlayer?
		# return if self.item
		@battle.pbPriority(true).each do |b|
			next if b.idxOwnSide == idxOwnSide
			next unless b.hasActiveAbility?(:SCAVENGE)
			next if b.item || b.unlosableItem?(b.item)
			next if unlosableItem?(b.item)
			@battle.pbShowAbilitySplash(b)
			@battle.pbDisplay(_INTL("{1} scavenged {2}'s {3}!", b.pbThis, pbThis(true), b.itemName))
			b.item = item
			@battle.pbHideAbilitySplash(b)
			break
		end
	end

	def pbSymbiosis
		return if fainted?
		return unless item
		@battle.pbPriority(true).each do |b|
			next if b.opposes?
			next unless b.hasActiveAbility?(:SYMBIOSIS)
			next if !b.item || b.unlosableItem?(b.item)
			next if unlosableItem?(b.item)
			@battle.pbShowAbilitySplash(b)
			@battle.pbDisplay(_INTL('{1} shared its {2} with {3}!',b.pbThis, b.itemName, pbThis(true)))
			self.item = b.item
			b.item = nil
			applyEffect(:ItemLost)
			@battle.pbHideAbilitySplash(b)
			pbHeldItemTriggerCheck
			break
		end
	end

	# item_to_use is an item ID or GameData::Item object. own_item is whether the
	# item is held by self. fling is for Fling only.
	def pbHeldItemTriggered(item_to_use, own_item = true, fling = false)
		# Cheek Pouch and similar abilities
		BattleHandlers.triggerOnBerryConsumedAbility(ability, self, item_to_use, own_item, @battle) if GameData::Item.get(item_to_use).is_berry? && abilityActive?
		pbConsumeItem if own_item
		pbSymbiosis if !own_item && !fling # Bug Bite/Pluck users trigger Symbiosis
	end

	#=============================================================================
	# Held item trigger checks
	#=============================================================================
	# NOTE: A Pokémon using Bug Bite/Pluck, and a Pokémon having an item thrown at
	#       it via Fling, will gain the effect of the item even if the Pokémon is
	#       affected by item-negating effects.
	# item_to_use is an item ID for Bug Bite/Pluck and Fling, and nil otherwise.
	# fling is for Fling only.
	def pbHeldItemTriggerCheck(item_to_use = nil, fling = false)
		return if fainted?
		return if !item_to_use && !itemActive?
		pbItemHPHealCheck(item_to_use, fling)
		pbItemStatusCureCheck(item_to_use, fling)
		pbItemEndOfMoveCheck(item_to_use, fling)
		# For Enigma Berry, Kee Berry and Maranga Berry, which have their effects
		# when forcibly consumed by Pluck/Fling.
		if item_to_use
			itm = item_to_use || item
			pbHeldItemTriggered(itm, false, fling) if BattleHandlers.triggerTargetItemOnHitPositiveBerry(itm, self, @battle, true)
		end
	end

	def pbItemHPHealCheck(item_to_use = nil, fling = false)
		return if !item_to_use && !itemActive?
		itm = item_to_use || item
		if BattleHandlers.triggerHPHealItem(itm, self, @battle, !item_to_use.nil?)
			pbHeldItemTriggered(itm, item_to_use.nil?, fling)
		elsif !item_to_use
			pbItemTerrainStatBoostCheck
			pbItemFieldEffectCheck
		end
	end

	# Cures status conditions, confusion, infatuation and the other effects cured
	# by Mental Herb.
	# item_to_use is an item ID for Bug Bite/Pluck and Fling, and nil otherwise.
	# fling is for Fling only.
	def pbItemStatusCureCheck(item_to_use = nil, fling = false)
		return if fainted?
		return if !item_to_use && !itemActive?
		itm = item_to_use || item
		pbHeldItemTriggered(itm, item_to_use.nil?, fling) if BattleHandlers.triggerStatusCureItem(itm, self, @battle, !item_to_use.nil?)
	end

	# Called at the end of using a move.
	# item_to_use is an item ID for Bug Bite/Pluck and Fling, and nil otherwise.
	# fling is for Fling only.
	def pbItemEndOfMoveCheck(item_to_use = nil, fling = false)
		return if fainted?
		return if !item_to_use && !itemActive?
		itm = item_to_use || item
		if BattleHandlers.triggerEndOfMoveItem(itm, self, @battle, !item_to_use.nil?)
			pbHeldItemTriggered(itm, item_to_use.nil?, fling)
		elsif BattleHandlers.triggerEndOfMoveStatRestoreItem(itm, self, @battle, !item_to_use.nil?)
			pbHeldItemTriggered(itm, item_to_use.nil?, fling)
		end
	end

	# Used for White Herb (restore lowered stats). Only called by Moody and Sticky
	# Web, as all other stat reduction happens because of/during move usage and
	# this handler is also called at the end of each move's usage.
	# item_to_use is an item ID for Bug Bite/Pluck and Fling, and nil otherwise.
	# fling is for Fling only.
	def pbItemStatRestoreCheck(item_to_use = nil, fling = false)
		return if fainted?
		return if !item_to_use && !itemActive?
		itm = item_to_use || item
		pbHeldItemTriggered(itm, item_to_use.nil?, fling) if BattleHandlers.triggerEndOfMoveStatRestoreItem(itm, self, @battle, !item_to_use.nil?)
	end

	# Called when the battle terrain changes and when a Pokémon loses HP.
	def pbItemTerrainStatBoostCheck
		return unless itemActive?
		pbHeldItemTriggered(item) if BattleHandlers.triggerTerrainStatBoostItem(item, self, @battle)
	end

	def pbItemFieldEffectCheck
		return unless itemActive?
		pbHeldItemTriggered(item) if BattleHandlers.triggerFieldEffectItem(item, self, @battle)
	end

	# Used for Adrenaline Orb. Called when Intimidate is triggered (even if
	# Intimidate has no effect on the Pokémon).
	def pbItemOnIntimidatedCheck
		return unless itemActive?
		pbHeldItemTriggered(item) if BattleHandlers.triggerItemOnIntimidated(item, self, @battle)
	end
end
