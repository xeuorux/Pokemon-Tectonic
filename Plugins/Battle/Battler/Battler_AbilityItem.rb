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
        if (!fainted? && unstoppableAbility?) || abilityActive?
            eachAbility do |ability|
                BattleHandlers.triggerAbilityOnSwitchIn(ability, self, @battle)
            end
        end
        # Check for end of primordial weather
        @battle.pbEndPrimordialWeather
        # Items that trigger upon switching in (Air Balloon message)
        if switchIn
            eachActiveItem do |item|
                BattleHandlers.triggerItemOnSwitchIn(item, self, @battle)
            end
        end
        # Berry check, status-curing ability check
        pbHeldItemTriggerCheck if switchIn
        pbAbilityStatusCureCheck
    end

    #=============================================================================
    # Ability effects
    #=============================================================================
    def pbAbilitiesOnSwitchOut
        eachActiveAbility do |ability|
            BattleHandlers.triggerAbilityOnSwitchOut(ability, self, false)
        end
        # Caretaker bonus
        pbRecoverHP(@totalhp / 16.0, false, false, false) if hasTribeBonus?(:CARETAKER)
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
            next unless b
            b.eachActiveAbility do |ability|
                BattleHandlers.triggerAbilityChangeOnBattlerFainting(ability, b, self, @battle)
            end
        end
        @battle.pbPriority(true).each do |b|
            next unless b
            b.eachActiveAbility do |ability|
                BattleHandlers.triggerAbilityOnBattlerFainting(ability, b, self, @battle)
            end
        end

        # Scoure tribal bonus
        opposingIndex = (@index + 1) % 2
        opposingSide = @battle.sides[opposingIndex]
        trainerGroup = opposingIndex == 0 ? @battle.player : @battle.opponent

        trainerGroup&.each do |trainer|
            trainerName = trainer.name
            if trainer.tribalBonus.hasTribeBonus?(:SCOURGE)
                healingMessage = _INTL("#{trainerName}'s team takes joy in #{pbThis(true)}'s pain!")
                healingMessage = "The opposing #{healingMessage}" if opposingIndex == 1
                @battle.pbShowTribeSplash(opposingSide, :SCOURGE, trainerName: trainerName)
                @battle.pbDisplay(healingMessage)
                trainer.party.each_with_index do |partyMember, index|
                    next if partyMember.fainted?
                    next if partyMember.hp == partyMember.totalhp
                    battler = @battle.pbFindBattler(index, opposingIndex)
                    if battler
                        battler.applyFractionalHealing(1/12.0)
                    else
                        partyMember.healByFraction(1/12.0)
                    end
                end
                @battle.pbHideTribeSplash(opposingSide)
            end
        end
    end

    # Used for Emergency Exit/Wimp Out.
    def pbAbilitiesOnDamageTaken(oldHP, newHP = -1)
        newHP = @hp if newHP < 0
        return false if oldHP < @totalhp / 2 || newHP >= @totalhp / 2 # Didn't drop below half
        ret = false
        eachActiveAbility(true) do |ability|
            ret = true if BattleHandlers.triggerAbilityOnHPDroppedBelowHalf(ability, self, @battle)
        end
        return ret # Whether self has switched out
    end

    # Called when a Pokémon (self) enters battle, at the end of each move used,
    # and at the end of each round.
    def pbContinualAbilityChecks(onSwitchIn = false)
        # Check for end of primordial weather
        @battle.pbEndPrimordialWeather

        # Trace
        if hasActiveAbility?(:TRACE)
            choices = []
            @battle.eachOtherSideBattler(@index) do |b|
                next if b.ungainableAbility?(b.firstAbility) || UNCOPYABLE_ABILITIES.include?(b.firstAbility)
                choices.push(b)
            end
            unless choices.empty?
                choice = choices.sample
                @battle.pbShowAbilitySplash(self, :TRACE)
                stolenAbility = choice.ability
                setAbility(stolenAbility)
                @battle.pbDisplay(_INTL("{1} traced {2}'s {3}!", pbThis, choice.pbThis(true), getAbilityName(stolenAbility)))
                @battle.pbHideAbilitySplash(self)
                if !onSwitchIn && (unstoppableAbility?(stolenAbility) || abilityActive?)
                    BattleHandlers.triggerAbilityOnSwitchIn(stolenAbility, self, @battle)
                end
                return
            end
        end
        # Over-Acting
        if hasActiveAbility?(:OVERACTING)
            choices = []
            @battle.eachOtherSideBattler(@index) do |b|
                anyCopyables = false
                b.eachLegalAbility do |abilityID|
                    next if b.ungainableAbility?(abilityID) || GameData::Ability::UNCOPYABLE_ABILITIES.include?(abilityID)
                    anyCopyables = true
                    break
                end
                choices.push(b) if anyCopyables
            end
            unless choices.empty?
                choice = choices.sample
                @battle.pbShowAbilitySplash(self, :OVERACTING)
                @battle.pbDisplay(_INTL("{1} is acting like a {2}!", pbThis, GameData::Species.get(choice.species).real_name))
                legalAbilities = choice.legalAbilities
                setAbility(legalAbilities)
                legalAbilities.each do |legalAbility|
                    @battle.pbDisplay(_INTL("{1} mimicked the ability {2}!", pbThis, choice.pbThis(true), getAbilityName(legalAbility)))
                end
                @battle.pbHideAbilitySplash(self)
                if !onSwitchIn && (unstoppableAbility? || abilityActive?)
                    eachAbility do |ability|
                        BattleHandlers.triggerAbilityOnSwitchIn(ability, self, @battle)
                    end
                end
            end
        end
    end

    #=============================================================================
    # Ability curing
    #=============================================================================
    # Cures status conditions, confusion and infatuation.
    #=============================================================================
    def pbAbilityStatusCureCheck
        eachActiveAbility do |ability|
            BattleHandlers.triggerStatusCureAbility(ability, self)
        end
    end

    #=============================================================================
    # Ability change
    #=============================================================================
    def pbOnAbilitiesLost(oldAbilities)
        if illusion? && oldAbilities.include?(:ILLUSION)
            disableEffect(:Illusion)
            unless effectActive?(:Transform)
                @battle.scene.pbChangePokemon(self, @pokemon)
                @battle.pbDisplay(_INTL("{1}'s {2} wore off!", pbThis, getAbilityName(:ILLUSION)))
                @battle.pbSetSeen(self)
            end
        end
        disableEffect(:GastroAcid) if unstoppableAbility?
        disableEffect(:SlowStart) unless hasAbility?(:SLOWSTART)
        
        # Revert form if Flower Gift/Forecast was lost
        pbCheckFormOnWeatherChange

        # Check for end of primordial weather
        @battle.pbEndPrimordialWeather
        
        if items.length > 1 && hasAbility?(GameData::Ability::MULTI_ITEM_ABILITIES)
            droppedItems = false
            GameData::Ability::MULTI_ITEM_ABILITIES.each do |doubleItemAbility|
                next unless oldAbilities.include?(doubleItemAbility)
                itemKept = items[0]
                setItems(itemKept)
                @battle.pbDisplay(_INTL("{1} dropped all of its items except {2}!", pbThis, getItemName(itemKept)))
                droppedItems = true
                break
            end
        end
    end

    #=============================================================================
    # Held item adding or gifting
    #=============================================================================
    def giveItem(item,stolen = false)
        return if item.nil?
        return unless canAddItem?(item, stolen)
        item = GameData::Item.get(item).id
        disableEffect(:ItemLost)
        @pokemon.giveItem(item)
        refreshDataBox
    end
    
    def setItems(value)
        @pokemon.setItems(value)
    end

    def recycleItem(recyclingMsg: nil, ability: nil)
        return unless @recyclableItem
        itemToRecycle = @recyclableItem
        return unless canAddItem?(itemToRecycle)
        @battle.pbShowAbilitySplash(self, ability)
        giveItem(itemToRecycle)
        setRecycleItem(nil)
        recyclingMsg ||= _INTL("{1} recycled one {2}!", pbThis, getItemName(itemToRecycle))
        battle.pbDisplay(recyclingMsg)
        @battle.pbHideAbilitySplash(self)
        pbHeldItemTriggerCheck
    end

    #=============================================================================
    # Held item consuming/removing
    #=============================================================================
    def canConsumeBerry?
        return false if @battle.pbCheckOpposingAbility(%i[UNNERVE ASONEICE ASONEGHOST STRESSFUL], @index)
        return true
    end

    def canLeftovers?
        return false if @battle.pbCheckOpposingAbility(%i[UNNERVE ASONEICE ASONEGHOST], @index)
        return true
    end

    def canConsumeGem?
        return false if @battle.pbCheckOpposingAbility(%i[STRESSFUL], @index)
        return true
    end

    def canConsumePinchBerry?(check_gluttony = true)
        return false unless canConsumeBerry?
        return true if @hp <= @totalhp / 4
        return true if @hp <= @totalhp / 2 && (!check_gluttony || hasActiveAbility?(:GLUTTONY))
        return false
    end

    def removeItem(item)
        itemIndex = items.index(item)
        unless itemIndex
            raise _INTL("Error: Asked to remove item #{item} from #{pbThis(true)}, but it doesn't have that item")
        end
        disableEffect(:ChoiceBand) if CHOICE_LOCKING_ITEMS.include?(item)
        items.delete_at(itemIndex)
        applyEffect(:ItemLost) if items.length == 0
        refreshDataBox
    end
    alias removeItem removeItem

    #=========================================
    # Also handles SCAVENGE
    #=========================================
    def consumeItem(item, recoverable: true, belch: true)
        if item.nil?
            PBDebug.log("[Item not consumed] #{pbThis} could not consume a #{item} because it was already missing")
            return
        end
        unless hasItem?(item)
            PBDebug.log("[Item not consumed] #{pbThis} could not consume a #{item} because it didn't have one")
            return
        end
        itemData = GameData::Item.get(item)
        itemName = itemData.name
        PBDebug.log("[Item consumed] #{pbThis} consumed its held #{itemName}")
        @battle.triggerBattlerConsumedItemDialogue(self, item)
        if recoverable
            setRecycleItem(item)
            applyEffect(:PickupItem, item)
            applyEffect(:PickupUse, @battle.nextPickupUse)
        end
        setBelched if belch && itemData.is_berry?
        removeItem(item)
    end

    # item_to_use is an item ID or GameData::Item object. ownitem is whether the
    # item is held by self. fling is for Fling only.
    def pbHeldItemTriggered(item_to_use, ownitem = true, fling = false)
        # Cheek Pouch and similar abilities
        if GameData::Item.get(item_to_use).is_berry?
            eachActiveAbility do |ability|
                BattleHandlers.triggerOnBerryConsumedAbility(ability, self, item_to_use, ownitem, @battle)
            end
        end
        consumeItem(item_to_use) if ownitem
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
        pbItemHPHealCheck(item_to_use, fling)
        pbItemStatusCureCheck(item_to_use, fling)
        pbItemEndOfMoveCheck(item_to_use, fling)
        # For Enigma Berry, Kee Berry and Maranga Berry, which have their effects
        # when forcibly consumed by Pluck/Fling.
        if item_to_use
            if BattleHandlers.triggerTargetItemOnHitPositiveBerry(item_to_use, self, @battle, true)
                pbHeldItemTriggered(item_to_use, false, fling)
            end
        end
    end

    def pbItemHPHealCheck(item_to_use = nil, fling = false)
        # Check for berry filching
        unless item_to_use
            eachActiveItem do |item|
                next unless GameData::Item.get(item).is_berry?
                filcher = nil

                @battle.eachBattler { |b|
                    next if b.index == @index
                    next unless b.hasActiveAbility?(:GREEDYGUTS)
                    filcher = b
                    break
                }
    
                # If the berry is being filched
                if filcher && BattleHandlers.triggerHPHealItem(item, filcher, @battle, false, self)
                    filcher.pbHeldItemTriggered(item, false)
                    consumeItem(item)
                end
            end
        end

        forced = !item_to_use.nil?

        itemsToCheck = forced ? [item_to_use] : activeItems.clone

        itemsToCheck.each do |item|
            # Check for user
            next unless BattleHandlers.triggerHPHealItem(item, self, @battle, forced, nil)
            pbHeldItemTriggered(item, !forced, fling)
        end

        unless forced
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

        forced = !item_to_use.nil?

        itemsToCheck = forced ? [item_to_use] : activeItems.clone
        itemsToCheck.each do |item|
            if BattleHandlers.triggerStatusCureItem(item, self, @battle, forced)
                pbHeldItemTriggered(item, !forced, fling)
            end
        end
    end

    # Called at the end of using a move.
    # item_to_use is an item ID for Bug Bite/Pluck and Fling, and nil otherwise.
    # fling is for Fling only.
    def pbItemEndOfMoveCheck(item_to_use = nil, fling = false)
        return if fainted?

        forced = !item_to_use.nil?

        itemsToCheck = forced ? [item_to_use] : activeItems.clone
        itemsToCheck.each do |item|
            if BattleHandlers.triggerEndOfMoveItem(item, self, @battle, forced)
                pbHeldItemTriggered(item, !forced, fling)
            elsif BattleHandlers.triggerEndOfMoveStatRestoreItem(item, self, @battle, forced)
                pbHeldItemTriggered(item, !forced, fling)
            end
        end
    end

    # Used for White Herb / Black Herb. Only called by Moody and Sticky
    # Web, as all other stat reduction happens because of/during move usage and
    # this handler is also called at the end of each move's usage.
    # item_to_use is an item ID for Bug Bite/Pluck and Fling, and nil otherwise.
    # fling is for Fling only.
    def pbItemStatRestoreCheck(item_to_use = nil, fling = false)
        return if fainted?

        forced = !item_to_use.nil?

        itemsToCheck = forced ? [item_to_use] : activeItems.clone

        itemsToCheck.each do |item|
            if BattleHandlers.triggerEndOfMoveStatRestoreItem(item, self, @battle, forced)
                pbHeldItemTriggered(item, !forced, fling)
            end
        end
    end

    # Called when the battle terrain changes and when a Pokémon loses HP.
    def pbItemTerrainStatBoostCheck
        itemsToCheck = activeItems.clone
        itemsToCheck.each do |item|
            pbHeldItemTriggered(item) if BattleHandlers.triggerTerrainStatBoostItem(item, self, @battle)
        end
    end

    def pbItemFieldEffectCheck
        itemsToCheck = activeItems.clone
        itemsToCheck.each do |item|
            pbHeldItemTriggered(item) if BattleHandlers.triggerFieldEffectItem(item, self, @battle)
        end
    end

    # Used for Adrenaline Orb. Called when Intimidate is triggered (even if
    # Intimidate has no effect on the Pokémon).
    def pbItemOnIntimidatedCheck
        itemsToCheck = activeItems.clone
        itemsToCheck.each do |item|
            pbHeldItemTriggered(item) if BattleHandlers.triggerItemOnIntimidated(item, self, @battle)
        end
    end
end
