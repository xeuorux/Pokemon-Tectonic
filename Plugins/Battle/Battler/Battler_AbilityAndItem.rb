class PokeBattle_Battler
	#=============================================================================
	# Ability effects
	#=============================================================================
	def pbAbilitiesOnSwitchOut
		if abilityActive?
			BattleHandlers.triggerAbilityOnSwitchOut(self.ability,self,false)
		end
		# Reset form
		@battle.peer.pbOnLeavingBattle(@battle,@pokemon,@battle.usedInBattle[idxOwnSide][@index/2])
		# Treat self as fainted
		@hp = 0
		@fainted = true
		# Check for end of primordial weather
		@battle.pbEndPrimordialWeather
	end

	#=========================================
	# Also handles SCAVENGE
	#========================================= 
	def pbConsumeItem(recoverable=true,symbiosis=true,belch=true,scavenge=true)
		if item.nil?
			PBDebug.log("[Item not consumed] #{pbThis} could not consume its held #{itemName} because it was already missing")
			return
		end
		PBDebug.log("[Item consumed] #{pbThis} consumed its held #{itemName}")
		@battle.triggerBattlerConsumedItemDialogue(self,@item_id)
		if recoverable
			setRecycleItem(@item_id)
			@effects[PBEffects::PickupItem] = @item_id
			@effects[PBEffects::PickupUse]  = @battle.nextPickupUse
		end
		setBelched if belch && self.item.is_berry?
		pbScavenge if scavenge
		pbRemoveItem
		pbSymbiosis if symbiosis
	end
 
	def pbScavenge
		return if fainted?
		#return if self.item
		@battle.pbPriority(true).each do |b|
			echoln _INTL("b is {1} and opposes is {2}", b.pbThis,b.idxOwnSide)
			next if b.idxOwnSide == self.idxOwnSide
			next if !b.hasActiveAbility?(:SCAVENGE)
			next if b.item || b.unlosableItem?(b.item)
			next if unlosableItem?(b.item)
			@battle.pbShowAbilitySplash(b)
			if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
				@battle.pbDisplay(_INTL("{1} scavenged {2}'s {3}!", b.pbThis,pbThis(true),b.itemName))
			else
				@battle.pbDisplay(_INTL("{1}'s {2} let it take {3} with {4}!",
			b.pbThis,b.abilityName,b.itemName,pbThis(true)))
			end
		echoln _INTL("{1}'s item is {2}", b.pbThis, b.item)
		b.item = self.item
		@battle.pbHideAbilitySplash(b)
		break
		end
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
			itm = item_to_use || self.item
			if BattleHandlers.triggerTargetItemOnHitPositiveBerry(itm, self, @battle, true)
				pbHeldItemTriggered(itm, false, fling)
			end
		end
	end
  
  
	def pbItemHPHealCheck(item_to_use = nil, fling = false)
		return if !item_to_use && !itemActive?
		itm = item_to_use || self.item
		if BattleHandlers.triggerHPHealItem(itm, self, @battle, !item_to_use.nil?)
			pbHeldItemTriggered(itm, item_to_use.nil?, fling)
		elsif !item_to_use
			pbItemTerrainStatBoostCheck
			pbItemFieldEffectCheck
		end
	end


	def pbItemFieldEffectCheck
		return if !itemActive?
		if BattleHandlers.triggerFieldEffectItem(self.item,self,@battle)
			pbHeldItemTriggered(self.item)
		end
	end

	# item_to_use is an item ID or GameData::Item object. own_item is whether the
	# item is held by self. fling is for Fling only.
	def pbHeldItemTriggered(item_to_use, own_item = true, fling = false)
		# Cheek Pouch and similar abilities
		if GameData::Item.get(item_to_use).is_berry? && abilityActive?
			BattleHandlers.triggerOnBerryConsumedAbility(self.ability,self,item_to_use,own_item,@battle)
		end
		pbConsumeItem if own_item
		pbSymbiosis if !own_item && !fling   # Bug Bite/Pluck users trigger Symbiosis
	end
end