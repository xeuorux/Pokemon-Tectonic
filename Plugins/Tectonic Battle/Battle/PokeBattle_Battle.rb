# Results of battle:
#    0 - Undecided or aborted
#    1 - Player won
#    2 - Player lost
#    3 - Player or wild Pokémon ran from battle, or player forfeited the match
#    4 - Wild Pokémon was caught
#    5 - Draw
# Possible actions a battler can take in a round:
#    :None
#    :UseMove
#    :SwitchOut
#    :UseItem
#    :Call
#    :Run
#    :Shift

class PokeBattle_Battle
    #=============================================================================
    # Trainers and owner-related methods
    #=============================================================================
    def pbPlayer; return @player[0]; end

    # Given a battler index, returns the index within @player/@opponent of the
    # trainer that controls that battler index.
    # NOTE: You shouldn't ever have more trainers on a side than there are battler
    #       positions on that side. This method doesn't account for if you do.
    def pbGetOwnerIndexFromBattlerIndex(idxBattler)
        trainer = opposes?(idxBattler) ? @opponent : @player
        return 0 unless trainer
        case trainer.length
        when 2
            n = pbSideSize(idxBattler % 2)
            return [0, 0, 1][idxBattler / 2] if n == 3
            return idxBattler / 2 # Same as [0,1][idxBattler/2], i.e. 2 battler slots
        when 3
            return idxBattler / 2
        end
        return 0
    end

    def pbGetOwnerFromBattlerIndex(idxBattler)
        idxTrainer = pbGetOwnerIndexFromBattlerIndex(idxBattler)
        return opposes?(idxBattler) ? @opponent[idxTrainer] : @player[idxTrainer]
    end

    def pbGetOwnerIndexFromPartyIndex(idxBattler, idxParty)
        ret = -1
        pbPartyStarts(idxBattler).each_with_index do |start, i|
            break if start > idxParty
            ret = i
        end
        return ret
    end

    # Only used for the purpose of an error message when one trainer tries to
    # switch another trainer's Pokémon.
    def pbGetOwnerFromPartyIndex(idxBattler, idxParty)
        idxTrainer = pbGetOwnerIndexFromPartyIndex(idxBattler, idxParty)
        return opposes?(idxBattler) ? @opponent[idxTrainer] : @player[idxTrainer]
    end

    def pbGetOwnerName(idxBattler)
        idxTrainer = pbGetOwnerIndexFromBattlerIndex(idxBattler)
        return @opponent[idxTrainer].full_name if opposes?(idxBattler) # Opponent
        return @player[idxTrainer].full_name if idxTrainer > 0 # Ally trainer
        return @player[idxTrainer].name # Player
    end

    def pbGetOwnerItems(idxBattler)
        return [] if !@items || !opposes?(idxBattler)
        return @items[pbGetOwnerIndexFromBattlerIndex(idxBattler)]
    end

    # Returns whether the battler in position idxBattler is owned by the same
    # trainer that owns the Pokémon in party slot idxParty. This assumes that
    # both the battler position and the party slot are from the same side.
    def pbIsOwner?(idxBattler, idxParty)
        idxTrainer1 = pbGetOwnerIndexFromBattlerIndex(idxBattler)
        idxTrainer2 = pbGetOwnerIndexFromPartyIndex(idxBattler, idxParty)
        return idxTrainer1 == idxTrainer2
    end

    def pbOwnedByPlayer?(idxBattler)
        return false if opposes?(idxBattler)
        return pbGetOwnerIndexFromBattlerIndex(idxBattler) == 0
    end

    # Returns the number of Pokémon positions controlled by the given trainerIndex
    # on the given side of battle.
    def pbNumPositions(side, idxTrainer)
        ret = 0
        for i in 0...pbSideSize(side)
            t = pbGetOwnerIndexFromBattlerIndex(i * 2 + side)
            next if t != idxTrainer
            ret += 1
        end
        return ret
    end

    #=============================================================================
    # Get party information (counts all teams on the same side)
    #=============================================================================
    def pbParty(idxBattler)
        return opposes?(idxBattler) ? @party2 : @party1
    end

    def pbOpposingParty(idxBattler)
        return opposes?(idxBattler) ? @party1 : @party2
    end

    def pbPartyOrder(idxBattler)
        return opposes?(idxBattler) ? @party2order : @party1order
    end

    def pbPartyStarts(idxBattler)
        return opposes?(idxBattler) ? @party2starts : @party1starts
    end

    # Returns the player's team in its display order. Used when showing the party
    # screen.
    def pbPlayerDisplayParty(idxBattler = 0)
        partyOrders = pbPartyOrder(idxBattler)
        idxStart, _idxEnd = pbTeamIndexRangeFromBattlerIndex(idxBattler)
        ret = []
        eachInTeamFromBattlerIndex(idxBattler) { |pkmn, i|
            break if pkmn.boss?
            ret[partyOrders[i] - idxStart] = pkmn
        }
        return ret
    end

    def pbAbleCount(idxBattler = 0)
        party = pbParty(idxBattler)
        count = 0
        party.each { |pkmn| count += 1 if pkmn && pkmn.able? }
        return count
    end

    def pbAbleNonActiveCount(idxBattler = 0)
        party = pbParty(idxBattler)
        inBattleIndices = []
        eachSameSideBattler(idxBattler) { |b| inBattleIndices.push(b.pokemonIndex) }
        count = 0
        party.each_with_index do |pkmn, idxParty|
            next if !pkmn || !pkmn.able?
            next if inBattleIndices.include?(idxParty)
            count += 1
        end
        return count
    end

    def pbAllFainted?(idxBattler = 0)
        return pbAbleCount(idxBattler) == 0
    end

    # For the given side of the field (0=player's, 1=opponent's), returns an array
    # containing the number of able Pokémon in each team.
    def pbAbleTeamCounts(side)
        party = pbParty(side)
        partyStarts = pbPartyStarts(side)
        ret = []
        idxTeam = -1
        nextStart = 0
        party.each_with_index do |pkmn, i|
            if i >= nextStart
                idxTeam += 1
                nextStart = (idxTeam < partyStarts.length - 1) ? partyStarts[idxTeam + 1] : party.length
            end
            next if !pkmn || !pkmn.able?
            ret[idxTeam] = 0 unless ret[idxTeam]
            ret[idxTeam] += 1
        end
        return ret
    end

    #=============================================================================
    # Get team information (a team is only the Pokémon owned by a particular
    # trainer)
    #=============================================================================
    def pbTeamIndexRangeFromBattlerIndex(idxBattler)
        partyStarts = pbPartyStarts(idxBattler)
        idxTrainer = pbGetOwnerIndexFromBattlerIndex(idxBattler)
        idxPartyStart = partyStarts[idxTrainer]
        idxPartyEnd   = (idxTrainer < partyStarts.length - 1) ? partyStarts[idxTrainer + 1] : pbParty(idxBattler).length
        return idxPartyStart, idxPartyEnd
    end

    def pbTeamLengthFromBattlerIndex(idxBattler)
        idxPartyStart, idxPartyEnd = pbTeamIndexRangeFromBattlerIndex(idxBattler)
        return idxPartyEnd - idxPartyStart
    end

    def eachInTeamFromBattlerIndex(idxBattler)
        party = pbParty(idxBattler)
        idxPartyStart, idxPartyEnd = pbTeamIndexRangeFromBattlerIndex(idxBattler)
        party.each_with_index { |pkmn, i| yield pkmn, i if pkmn && i >= idxPartyStart && i < idxPartyEnd }
    end

    def eachInTeam(side, idxTrainer)
        party       = pbParty(side)
        partyStarts = pbPartyStarts(side)
        idxPartyStart = partyStarts[idxTrainer]
        idxPartyEnd   = (idxTrainer < partyStarts.length - 1) ? partyStarts[idxTrainer + 1] : party.length
        party.each_with_index { |pkmn, i| yield pkmn, i if pkmn && i >= idxPartyStart && i < idxPartyEnd }
    end

    # Used for Illusion.
    # NOTE: This cares about the temporary rearranged order of the team. That is,
    #       if you do some switching, the last Pokémon in the team could change
    #       and the Illusion could be a different Pokémon.
    def pbLastInTeam(idxBattler)
        party       = pbParty(idxBattler)
        partyOrders = pbPartyOrder(idxBattler)
        idxPartyStart, idxPartyEnd = pbTeamIndexRangeFromBattlerIndex(idxBattler)
        ret = -1
        party.each_with_index do |pkmn, i|
            next if i < idxPartyStart || i >= idxPartyEnd # Check the team only
            next if !pkmn || !pkmn.able? # Can't copy a non-fainted Pokémon or egg
            ret = i if ret < 0 || partyOrders[i] > partyOrders[ret]
        end
        return ret
    end

    # Used to calculate money gained/lost after winning/losing a battle.
    def pbMaxLevelInTeam(side, idxTrainer)
        ret = 1
        eachInTeam(side, idxTrainer) do |pkmn, _i|
            ret = pkmn.level if pkmn.level > ret
        end
        return ret
    end

    #=============================================================================
    # Iterate through battlers
    #=============================================================================
    def eachBattler
        @battlers.each { |b| yield b if b && !b.fainted? }
    end

    def eachSameSideBattler(idxBattler = 0)
        idxBattler = idxBattler.index if idxBattler.respond_to?("index")
        @battlers.each { |b| yield b if b && !b.fainted? && !b.opposes?(idxBattler) }
    end

    def eachOtherSideBattler(idxBattler = 0)
        idxBattler = idxBattler.index if idxBattler.respond_to?("index")
        @battlers.each { |b| yield b if b && !b.fainted? && b.opposes?(idxBattler) }
    end

    def pbSideBattlerCount(idxBattler = 0)
        ret = 0
        eachSameSideBattler(idxBattler) { |_b| ret += 1 }
        return ret
    end

    def pbOpposingBattlerCount(idxBattler = 0)
        ret = 0
        eachOtherSideBattler(idxBattler) { |_b| ret += 1 }
        return ret
    end

    # This method only counts the player's Pokémon, not a partner trainer's.
    def pbPlayerBattlerCount
        ret = 0
        eachSameSideBattler { |b| ret += 1 if b.pbOwnedByPlayer? }
        return ret
    end

    def pbCheckGlobalAbility(abil)
        eachBattler { |b| return b if b.hasActiveAbility?(abil) }
        return nil
    end

    def pbCheckSameSideAbility(abil, idxBattler = 0, nearOnly = false)
        eachSameSideBattler(idxBattler) do |b|
            next if nearOnly && !b.near?(idxBattler)
            return b if b.hasActiveAbility?(abil)
        end
        return nil
    end

    def pbCheckOpposingAbility(abil, idxBattler = 0, nearOnly = false)
        eachOtherSideBattler(idxBattler) do |b|
            next if nearOnly && !b.near?(idxBattler)
            return b if b.hasActiveAbility?(abil)
        end
        return nil
    end
    
    def pbCheckOtherAbility(abil, idxBattler = 0, nearOnly = false)
        eachOtherSideBattler(idxBattler) do |b|
            next if nearOnly && !b.near?(idxBattler)
            return b if b.hasActiveAbility?(abil)
        end
        eachSameSideBattler(idxBattler) do |b|
            next if b.index == idxBattler
            next if nearOnly && !b.near?(idxBattler)
            return b if b.hasActiveAbility?(abil)
        end
        return nil
    end

    # Given a battler index, and using battle side sizes, returns an array of
    # battler indices from the opposing side that are in order of most "opposite".
    # Used when choosing a target and pressing up/down to move the cursor to the
    # opposite side, and also when deciding which target to select first for some
    # moves.
    def pbGetOpposingIndicesInOrder(idxBattler)
        case pbSideSize(0)
        when 1
            case pbSideSize(1)
            when 1   # 1v1 single
                return [0] if opposes?(idxBattler)
                return [1]
            when 2   # 1v2
                return [0] if opposes?(idxBattler)
                return [3, 1]
            when 3   # 1v3
                return [0] if opposes?(idxBattler)
                return [3, 5, 1]
            end
        when 2
            case pbSideSize(1)
            when 1   # 2v1
                return [0, 2] if opposes?(idxBattler)
                return [1]
            when 2   # 2v2 double
                return [[3, 1], [2, 0], [1, 3], [0, 2]][idxBattler]
            when 3   # 2v3
                return [[5, 3, 1], [2, 0], [3, 1, 5]][idxBattler] if idxBattler < 3
                return [0, 2]
            end
        when 3
            case pbSideSize(1)
            when 1   # 3v1
                return [2, 0, 4] if opposes?(idxBattler)
                return [1]
            when 2   # 3v2
                return [[3, 1], [2, 4, 0], [3, 1], [2, 0, 4], [1, 3]][idxBattler]
            when 3   # 3v3 triple
                return [[5, 3, 1], [4, 2, 0], [3, 5, 1], [2, 0, 4], [1, 3, 5], [0, 2, 4]][idxBattler]
            end
        end
        return [idxBattler]
    end

    #=============================================================================
    # Comparing the positions of two battlers
    #=============================================================================
    def opposes?(idxBattler1, idxBattler2 = 0)
        idxBattler1 = idxBattler1.index if idxBattler1.respond_to?("index")
        idxBattler2 = idxBattler2.index if idxBattler2.respond_to?("index")
        return (idxBattler1 & 1) != (idxBattler2 & 1) # True if they're not both even or both odd
    end

    def nearBattlers?(idxBattler1, idxBattler2)
        return false if idxBattler1 == idxBattler2
        return true if pbSideSize(0) <= 2 && pbSideSize(1) <= 2
        # Get all pairs of battler positions that are not close to each other
        pairsArray = [[0, 4], [1, 5]] # Covers 3v1 and 1v3
        if pbSideSize(0) == 3 && pbSideSize(1) == 3
            pairsArray.push([0, 1])
            pairsArray.push([4, 5])
        end
        # See if any pair matches the two battlers being assessed
        pairsArray.each do |pair|
            return false if pair.include?(idxBattler1) && pair.include?(idxBattler2)
        end
        return true
    end

    #=============================================================================
    # Altering a party or rearranging battlers
    #=============================================================================
    def pbRemoveFromParty(idxBattler, idxParty)
        party = pbParty(idxBattler)
        # Erase the Pokémon from the party
        party[idxParty] = nil
        # Rearrange the display order of the team to place the erased Pokémon last
        # in it (to avoid gaps)
        partyOrders = pbPartyOrder(idxBattler)
        partyStarts = pbPartyStarts(idxBattler)
        idxTrainer = pbGetOwnerIndexFromPartyIndex(idxBattler, idxParty)
        idxPartyStart = partyStarts[idxTrainer]
        idxPartyEnd   = (idxTrainer < partyStarts.length - 1) ? partyStarts[idxTrainer + 1] : party.length
        origPartyPos = partyOrders[idxParty] # Position of erased Pokémon initially
        partyOrders[idxParty] = idxPartyEnd # Put erased Pokémon last in the team
        party.each_with_index do |_pkmn, i|
            next if i < idxPartyStart || i >= idxPartyEnd # Only check the team
            next if partyOrders[i] < origPartyPos # Appeared before erased Pokémon
            partyOrders[i] -= 1 # Appeared after erased Pokémon; bump it up by 1
        end
    end

    def pbSwapBattlers(idxA, idxB)
        return false if !@battlers[idxA] || !@battlers[idxB]
        # Can't swap if battlers aren't owned by the same trainer
        return false if opposes?(idxA, idxB)
        return false if pbGetOwnerIndexFromBattlerIndex(idxA) != pbGetOwnerIndexFromBattlerIndex(idxB)
        @battlers[idxA],       @battlers[idxB]       = @battlers[idxB],       @battlers[idxA]
        @battlers[idxA].index, @battlers[idxB].index = @battlers[idxB].index, @battlers[idxA].index
        @choices[idxA],        @choices[idxB]        = @choices[idxB],        @choices[idxA]
        @scene.pbSwapBattlerSprites(idxA, idxB)
        # Swap the target of any battlers' effects that point at either of the
        # swapped battlers, to ensure they still point at the correct target
        eachBattler do |b|
            b.eachEffect(true) do |effect, value, data|
                next unless data.swaps_with_battlers
                if value == idxA
                    b.effects[effect] = idxB
                elsif value == idxB
                    b.effects[effect] = idxA
                end
            end
        end
        return true
    end

    #=============================================================================
    #
    #=============================================================================
    # Returns the battler representing the Pokémon at index idxParty in its party,
    # on the same side as a battler with battler index of idxBattlerOther.
    def pbFindBattler(idxParty, idxBattlerOther = 0)
        eachSameSideBattler(idxBattlerOther) { |b| return b if b.pokemonIndex == idxParty }
        return nil
    end

    def pokemonIsActiveBattler?(pokemon)
        eachBattler do |b|
            next unless b.pokemon.personalID == pokemon.personalID
            return true 
        end
        return false
    end

    # Only used for Wish, as the Wishing Pokémon will no longer be in battle.
    def pbThisEx(idxBattler, idxParty)
        party = pbParty(idxBattler)
        partyMember = party[idxParty]
        return "ERROR" if partyMember.nil?
        if opposes?(idxBattler)
            return _INTL("The opposing {1}", partyMember.name) if trainerBattle?
            return _INTL("The wild {1}", partyMember.name)
        end
        return _INTL("The ally {1}", partyMember.name) unless pbOwnedByPlayer?(idxBattler)
        return partyMember.name
    end
end
