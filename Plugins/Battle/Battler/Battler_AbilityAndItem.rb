class PokeBattle_Battler


  #=============================================================================
  # Ability effects
  #=============================================================================
  def pbAbilitiesOnSwitchOut
    if abilityActive?
      BattleHandlers.triggerAbilityOnSwitchOut(@battle,self.ability,self,false)
    end
    # Reset form
    @battle.peer.pbOnLeavingBattle(@battle,@pokemon,@battle.usedInBattle[idxOwnSide][@index/2])
    # Treat self as fainted
    @hp = 0
    @fainted = true
    # Check for end of primordial weather
    @battle.pbEndPrimordialWeather
  end
  

=begin
  def pbConsumeItem(recoverable=true,symbiosis=true,belch=true,scavenge=true)
    PBDebug.log("[Item consumed] #{pbThis} consumed its held #{itemName}")
    if recoverable
      setRecycleItem(@item_id)
      @effects[PBEffects::PickupItem] = @item_id
      @effects[PBEffects::PickupUse]  = @battle.nextPickupUse
    end
    setBelched if belch && self.item.is_berry?
    pbRemoveItem
    pbSymbiosis if symbiosis
	pbScavenge if scavenge
  end
=end
  
  #=========================================
  #Also handles SCAVENGE
  #========================================= 
  
  
 def pbConsumeItem(recoverable=true,symbiosis=true,belch=true,scavenge=true)
    PBDebug.log("[Item consumed] #{pbThis} consumed its held #{itemName}")
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


=begin
  def pbSymbiosis
    return if fainted?
    return if self.item
    @battle.pbPriority(true).each do |b|
      next if b.idxOwnSide != self.idxOwnSide
      next if !b.hasActiveAbility?(:SYMBIOSIS)
      next if !b.item || b.unlosableItem?(b.item)
      next if unlosableItem?(b.item)
      @battle.pbShowAbilitySplash(b)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        @battle.pbDisplay(_INTL("{1} shared its {2} with {3}!",
           b.pbThis,b.itemName,pbThis(true)))
      else
        @battle.pbDisplay(_INTL("{1}'s {2} let it share its {3} with {4}!",
           b.pbThis,b.abilityName,b.itemName,pbThis(true)))
      end
	  echoln _INTL("{1}'s item is {2}", b.pbThis, b.item)
      self.item = b.item
      b.item = nil
      b.effects[PBEffects::Unburden] = true
      @battle.pbHideAbilitySplash(b)
      pbHeldItemTriggerCheck
      break
    end
 end
=end
 
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

end