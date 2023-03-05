class PokeBattle_Move
    def shouldHighlight?(user, target)
        if damagingMove?
            bpAgainstTarget = pbBaseDamageAI(@baseDamage, user, target)
            if @baseDamage == 1
                return bpAgainstTarget >= 100
            else
                return bpAgainstTarget > @baseDamage
            end
        end
        return false
    end

    def shouldShade?(user, target)
        return true if pbMoveFailed?(user, [target], false)
        return true if pbFailsAgainstTargetAI?(user, target)
        return false
    end

    def applyRainDebuff?(user, type, checkingForAI = false)
        return false unless @battle.rainy?
        return false unless RAIN_DEBUFF_ACTIVE
        return false if immuneToRainDebuff?
        return false if %i[WATER ELECTRIC].include?(type)
        return user.debuffedByRain?(checkingForAI)
    end

    def applySunDebuff?(user, type, checkingForAI = false)
        return false unless @battle.sunny?
        return false unless SUN_DEBUFF_ACTIVE
        return false if immuneToSunDebuff?
        return false if %i[FIRE GRASS].include?(type)
        return user.debuffedBySun?(checkingForAI)
    end

    def inherentImmunitiesPierced?(user, target)
        return (user.boss? || target.boss?) && damagingMove?
    end

    def canRemoveItem?(user, target, checkingForAI = false, ignoreTargetFainted = false)
        if @battle.wildBattle? && user.opposes? && !user.boss # Wild Pokémon can't knock off, but bosses can
            return false
        end
        return false if user.fainted?
        return false if target.fainted? && !ignoreTargetFainted
        if checkingForAI
            return false if target.substituted?
        elsif target.damageState.unaffected || target.damageState.substitute
            return false
        end
        return false if target.item.nil? || target.unlosableItem?(target.item, !checkingForAI)
        return false if target.shouldAbilityApply?(:STICKYHOLD, checkingForAI) && !@battle.moldBreaker
        return true
    end

    def canStealItem?(user, target, checkingForAI = false)
        return false unless canRemoveItem?(user, target, checkingForAI, true)
        return false if user.item && @battle.trainerBattle?
        return false if user.unlosableItem?(target.item)
        return true
    end

    # Returns whether the item was removed
    def removeItem(remover, victim, showRemoverSplash = false, removeMessage = nil)
        return false unless canRemoveItem?(remover, victim)
        battle.pbShowAbilitySplash(remover) if showRemoverSplash
        if victim.hasActiveAbility?(:STICKYHOLD)
            battle.pbShowAbilitySplash(victim) if remover.opposes?(victim)
            battle.pbDisplay(_INTL("{1}'s item cannot be removed!", victim.pbThis))
            battle.pbHideAbilitySplash(victim) if remover.opposes?(victim)
            battle.pbHideAbilitySplash(remover) if showRemoverSplash
            return false
        end
        itemName = victim.itemName
        victim.pbRemoveItem(false)
        removeMessage ||= _INTL("{1} forced {2} to drop their {3}!", remover.pbThis,
              victim.pbThis(true), itemName)
        battle.pbDisplay(removeMessage)
        battle.pbHideAbilitySplash(remover) if showRemoverSplash
        return true
    end

    # Returns whether the item was removed
    def stealItem(stealer, victim, showStealerSplash = false)
        return false unless canStealItem?(stealer, victim)
        @battle.pbShowAbilitySplash(stealer) if showStealerSplash
        if victim.hasActiveAbility?(:STICKYHOLD)
            @battle.pbShowAbilitySplash(victim) if stealer.opposes?(victim)
            @battle.pbDisplay(_INTL("{1}'s item cannot be stolen!", victim.pbThis))
            @battle.pbHideAbilitySplash(victim) if stealer.opposes?(victim)
            @battle.pbHideAbilitySplash(stealer) if showStealerSplash
            return false
        end
        oldVictimItem = victim.item
        oldVictimItemName = victim.itemName
        victim.pbRemoveItem
        if @battle.curseActive?(:CURSE_SUPER_ITEMS)
            @battle.pbDisplay(_INTL("{1}'s {2} turned to dust.", victim.pbThis, oldVictimItemName))
            @battle.pbHideAbilitySplash(stealer) if showStealerSplash
        else
            @battle.pbDisplay(_INTL("{1} stole {2}'s {3}!", stealer.pbThis,
              victim.pbThis(true), oldVictimItemName))
            # Permanently steal items from wild pokemon
            if @battle.wildBattle? && victim.opposes? && !@battle.bossBattle?
                victim.setInitialItem(nil)
                pbReceiveItem(oldVictimItem)
                @battle.pbHideAbilitySplash(stealer) if showStealerSplash
            else
                stealer.item = oldVictimItem
                @battle.pbHideAbilitySplash(stealer)
                stealer.pbHeldItemTriggerCheck if showStealerSplash
            end
        end
        return true
    end

    def healStatus(pokemonOrBattler)
        if pokemonOrBattler.is_a?(PokeBattle_Battler)
            pokemonOrBattler.pbCureStatus
        elsif pokemonOrBattler.status != :NONE
            oldStatus = pokemonOrBattler.status
            pokemonOrBattler.status      = :NONE
            pokemonOrBattler.statusCount = 0
            PokeBattle_Battler.showStatusCureMessage(oldStatus, pokemonOrBattler, @battle)
        end
    end

    def selectPartyMemberForEffect(idxBattler, selectableProc = nil)
        if @battle.pbOwnedByPlayer?(idxBattler)
            return playerChoosesPartyMemberForEffect(idxBattler, selectableProc)
        else
            return trainerChoosesPartyMemberForEffect(idxBattler, selectableProc)
        end
    end

    def playerChoosesPartyMemberForEffect(idxBattler, selectableProc = nil)
        # Get player's party
        party = @battle.pbParty(idxBattler)
        partyOrder = @battle.pbPartyOrder(idxBattler)
        partyStart = @battle.pbTeamIndexRangeFromBattlerIndex(idxBattler)[0]
        modParty = @battle.pbPlayerDisplayParty(idxBattler)
        # Start party screen
        pkmnScene = PokemonParty_Scene.new
        pkmnScreen = PokemonPartyScreen.new(pkmnScene, modParty)
        displayPartyIndex = -1
        # Loop while in party screen
        loop do
            # Select a Pokémon by showing the screen
            displayPartyIndex = pkmnScreen.pbChooseAblePokemon(selectableProc)
            next if displayPartyIndex < 0

            # Find the real party index after accounting for shifting around from swaps
            partyIndex = -1
            partyOrder.each_with_index do |pos, i|
                next if pos != displayPartyIndex + partyStart
                partyIndex = i
                break
            end
            next if partyIndex < 0

            # Make sure the selected pokemon isn't an active battler
            next if @battle.pbFindBattler(partyIndex, idxBattler)

            # Get the actual pokemon selection
            pkmn = party[partyIndex]

            # Don't allow invalid choices
            next if !pkmn || pkmn.egg?

            pkmnScene.pbEndScene
            return pkmn
        end
        pkmnScene.pbEndScene
        return nil
    end

    def trainerChoosesPartyMemberForEffect(idxBattler, selectableProc = nil)
        # Get trainer's party
        party = @battle.pbParty(idxBattler)
        party.each_with_index do |pokemon, partyIndex|
            # Don't allow invalid choices
            next if !pokemon || pokemon.egg?

            # Make sure the selected pokemon isn't an active battler
            next if @battle.pbFindBattler(partyIndex, idxBattler)

            return pokemon if selectableProc.call(pokemon)
        end
        return nil
    end

    def removeProtections(target)
        GameData::BattleEffect.each do |effectData|
            next unless effectData.is_protection?
            case effectData.location
            when :Battler
                target.disableEffect(effectData.id)
            when :Side
                target.pbOwnSide.disableEffect(effectData.id)
            end
        end
    end

    # Chooses a move category based on which attacking stat is higher (if no target is provided)
    # Or which will deal more damage to the target
    def selectBestCategory(user, target = nil)
        real_attack = user.attack
        real_special_attack = user.spatk
        if target
            real_defense = target.pbDefense
            real_special_defense = target.pbSpDef
            # Perform simple damage calculation
            physical_damage = real_attack.to_f / real_defense
            special_damage = real_special_attack.to_f / real_special_defense
            # Determine move's category based on likely damage dealt
            if physical_damage == special_damage
                return @battle.pbRandom(2)
            else
                return (physical_damage > special_damage) ? 0 : 1
            end
        elsif real_attack == real_special_attack
            # Determine move's category
            return @battle.pbRandom(2)
        else
            return (real_attack > real_special_attack) ? 0 : 1
        end
    end

    def forceOutTargets(user, targets, switchedBattlers, substituteBlocks = false, random = true, showAbilitySplash: false)
        return if user.fainted?
        roarSwitched = []
        targets.each do |b|
            next if @battle.wildBattle? && b.opposes? # Can't force out wild pokemon or boss pokemon
            next if b.fainted? || b.damageState.unaffected
            next if switchedBattlers.include?(b.index)
            next if b.effectActive?(:Ingrain)
            next if b.hasActiveAbility?(:SUCTIONCUPS) && !@battle.moldBreaker
            next if substituteBlocks && b.damageState.substitute
            next unless @battle.pbCanChooseNonActive?(b.index)
            @battle.pbShowAbilitySplash(user) if showAbilitySplash
            newPkmn = @battle.pbGetReplacementPokemonIndex(b.index, random)
            next if newPkmn < 0
            @battle.pbRecallAndReplace(b.index, newPkmn, true)
            if random
                @battle.pbDisplay(_INTL("{1} was dragged out!", b.pbThis))
            else
                @battle.pbDisplay(_INTL("{1} switches in!", b.pbThis))
            end
            @battle.pbClearChoice(b.index)   # Replacement Pokémon does nothing this round
            switchedBattlers.push(b.index)
            roarSwitched.push(b.index)
            @battle.pbHideAbilitySplash(user) if showAbilitySplash
        end
        if roarSwitched.length > 0
            @battle.moldBreaker = false if roarSwitched.include?(user.index)
            @battle.pbPriority(true).each do |b|
                b.pbEffectsOnSwitchIn(true) if roarSwitched.include?(b.index)
            end
        end
    end
end
