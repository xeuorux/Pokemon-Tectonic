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
  
  
    def pbScavenge
		return if fainted?
		return if !self.item
		@battle.pbPriority(true).each do |b|
		next if !b.opposes?
		next if !b.hasActiveAbility?(:SCAVENGE)
		next if !b.item #|| b.unlosableItem?(b.item)
		next if unlosableItem?(b.item)
		@battle.pbShowAbilitySplash(b)
		if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
			@battle.pbDisplay(_INTL("{1} scavenged {2}'s {3}!", b.pbThis,pbThis(true),b.itemName))
		else
			@battle.pbDisplay(_INTL("{1}'s {2} let it take {3} with {4}!",
           b.pbThis,b.abilityName,b.itemName,pbThis(true)))
		end
      self.item = b.item
      b.item = nil
      b.effects[PBEffects::Unburden] = true
      @battle.pbHideAbilitySplash(b)
      pbHeldItemTriggerCheck
      break
	  end
	end
	
end