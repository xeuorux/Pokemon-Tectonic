HOT_STREAKS_ACTIVE = false

class PokeBattle_Battle
    #=============================================================================
    # Gaining Experience
    #=============================================================================
    def pbGainExp
        return if @autoTesting
        hasExpJAR = (GameData::Item.exists?(:EXPEZDISPENSER) && $PokemonBag.pbHasItem?(:EXPEZDISPENSER))
        # Play wild victory music if it's the end of the battle (has to be here)
        @scene.pbWildBattleSuccess if wildBattle? && pbAllFainted?(1) && !pbAllFainted?(0)
        return if !@internalBattle || !@expGain
        if bossBattle?
            @battlers.each do |b|
                next if !b || !b.opposes? # Can only gain Exp from fainted foes
                next if !b.fainted? || !b.boss
                pbDisplayPaused(_INTL("Each Pokémon in your party got Exp. Points!"))
                b.participants = []
                eachInTeam(0, 0) do |_pkmn, i|
                    b.participants.push(i)
                    pbGainExpOne(i, b, 1, [], [], hasExpJAR)
                end
                b.boss = false
            end
        elsif wildBattle?
            unless $PokemonGlobal.noWildEXPTutorialized
                @battlers.each do |b|
                    next unless b && b.opposes? # Can only gain Exp from fainted foes
                    next if b.participants.length == 0
                    next unless b.fainted? || b.captured
                    playWildEXPTutorial
                    break
                end
            end
            return
        else
            # Go through each battler in turn to find the Pokémon that participated in
            # battle against it, and award those Pokémon Exp
            expAll = (GameData::Item.exists?(:EXPALL) && $PokemonBag.pbHasItem?(:EXPALL))
            p1 = pbParty(0)
            @battlers.each do |b|
                next unless b && b.opposes? # Can only gain Exp from fainted foes
                next if b.participants.length == 0
                next unless b.fainted? || b.captured
                # Count the number of participants
                numPartic = 0
                b.participants.each do |partic|
                    next unless p1[partic] && p1[partic].able? && pbIsOwner?(0, partic)
                    numPartic += 1
                end
                # Find which Pokémon have an Exp Share
                expShare = []
                unless expAll
                    eachInTeam(0, 0) do |pkmn, i|
                        next unless pkmn.able?
                        next unless pkmn.hasItem?(:EXPSHARE)
                        expShare.push(i)
                    end
                end
                # Calculate Exp gains for the participants
                if numPartic > 0 || expShare.length > 0 || expAll
                    # Gain Exp for participants
                    eachInTeam(0, 0) do |pkmn, i|
                        next unless pkmn.able?
                        next unless b.participants.include?(i) || expShare.include?(i)
                        pbGainExpOne(i, b, numPartic, expShare, expAll, hasExpJAR)
                    end
                    # Gain Exp for all other Pokémon because of Exp All
                    if expAll
                        showMessage = true
                        eachInTeam(0, 0) do |pkmn, i|
                            next unless pkmn.able?
                            next if b.participants.include?(i) || expShare.include?(i)
                            pbDisplayPaused(_INTL("Your party Pokémon in waiting also got Exp. Points!")) if showMessage
                            showMessage = false
                            pbGainExpOne(i, b, numPartic, expShare, expAll, hasExpJAR, false)
                        end
                    end
                end
                # Clear the participants array
                b.participants = []
            end
        end
    end

    def pbGainExpOne(idxParty, defeatedBattler, numPartic, expShare, expAll, hasExpJAR, showMessages = true)
        pkmn = pbParty(0)[idxParty] # The Pokémon gaining exp from defeatedBattler
        growth_rate = pkmn.growth_rate
        # Don't bother calculating if gainer is already at max Exp
        if pkmn.exp >= growth_rate.maximum_exp
            pkmn.calc_stats
            return
        end
        isPartic    = defeatedBattler.participants.include?(idxParty)
        hasExpShare = expShare.include?(idxParty)
        level = defeatedBattler.level
        # Main Exp calculation
        exp = 0
        a = level * defeatedBattler.pokemon.base_exp
        if expShare.length > 0 && (isPartic || hasExpShare)
            if numPartic == 0 # No participants, all Exp goes to Exp Share holders
                exp = a / (Settings::SPLIT_EXP_BETWEEN_GAINERS ? expShare.length : 1)
            elsif Settings::SPLIT_EXP_BETWEEN_GAINERS # Gain from participating and/or Exp Share
                exp = a / (2 * numPartic) if isPartic
                exp += a / (2 * expShare.length) if hasExpShare
            else # Gain from participating and/or Exp Share (Exp not split)
                exp = isPartic ? a : a / 2
            end
        elsif isPartic # Participated in battle, no Exp Shares held by anyone
            exp = a / (Settings::SPLIT_EXP_BETWEEN_GAINERS ? numPartic : 1)
        elsif expAll # Didn't participate in battle, gaining Exp due to Exp All
            # NOTE: Exp All works like the Exp Share from Gen 6+, not like the Exp All
            #       from Gen 1, i.e. Exp isn't split between all Pokémon gaining it.
            exp = a / 2
        end
        return if exp <= 0
        # Pokémon gain more Exp from trainer battles
        if trainerBattle?
            exp *= 1.5
            if $PokemonBag.pbHasItem?(:PERFORMANCEANALYZER2)
                exp *= 1.1
            elsif $PokemonBag.pbHasItem?(:PERFORMANCEANALYZER)
                exp *= 1.0
            end
            exp = exp.floor
        end
        exp /= 5
        # Scale the gained Exp based on the gainer's level (or not)
        if Settings::SCALED_EXP_FORMULA
            levelAdjust = (2 * level + 10.0) / (pkmn.level + level + 10.0)
            levelAdjust **= 5
            levelAdjust = Math.sqrt(levelAdjust)
            exp *= levelAdjust
            exp = exp.floor
            exp += 1 if isPartic || hasExpShare
        end
        # Increase Exp gain based on battling streak
        pkmn.battlingStreak = 0 if pkmn.battlingStreak.nil?
        if pkmn.onHotStreak? && HOT_STREAKS_ACTIVE
            exp = (exp * 1.3).floor
        end
        exp = (exp * 1.1).floor if playerTribalBonus.hasTribeBonus?(:LOYAL)
        exp = (exp * 1.5).floor if @field.effectActive?(:Bliss)
        exp = (exp * (1 + 0.1 * pbQuantity(:EXPCHARM))).floor # Extra 10 percent per EXP charm
        exp = (exp * $PokemonGlobal.exp_multiplier).floor if $PokemonGlobal.exp_multiplier
        modifiedEXP = exp
        pkmn.items.each do |item|
            modifiedEXP = BattleHandlers.triggerExpGainModifierItem(item, pkmn, modifiedEXP)
        end
        exp = modifiedEXP if modifiedEXP >= 0
        # If EXP in this battle is capped, store all XP instead of granting it
        if @expCapped
            @expStored += (exp * EXP_JAR_BASE_EFFICIENCY).floor
            return
        end
        # Make sure Exp doesn't exceed the maximum
        level_cap = LEVEL_CAPS_USED ? getLevelCap : growth_rate.max_level
        expFinal = growth_rate.add_exp(pkmn.exp, exp)
        expLeftovers = expFinal.clamp(0, growth_rate.minimum_exp_for_level(level_cap))
        # Calculates if there is excess exp and if it can be stored
        if (expFinal > expLeftovers) && hasExpJAR
            expLeftovers = expFinal.clamp(0, growth_rate.minimum_exp_for_level(level_cap + 1))
        else
            expLeftovers = 0
        end
        expFinal = expFinal.clamp(0, growth_rate.minimum_exp_for_level(level_cap))
        expGained = expFinal - pkmn.exp
        expLeftovers -= pkmn.exp
        $PokemonGlobal.expJAREfficient = false if $PokemonGlobal.expJAREfficient.nil?
        expLeftovers = (expLeftovers * EXP_JAR_BASE_EFFICIENCY).floor unless $PokemonGlobal.expJAREfficient
        @expStored += expLeftovers if expLeftovers > 0
        curLevel = pkmn.level
        newLevel = growth_rate.level_from_exp(expFinal)
        if expGained == 0 and pkmn.level < level_cap
            pbDisplayPaused(_INTL("{1} gained 0 experience.", pkmn.name))
            return
        end
        # "Exp gained" message
        if showMessages
            if newLevel == level_cap
                if expGained != 0
                    pbDisplayPaused(_INTL("{1} gained only {3} Exp. Points due to the level cap at level {2}.", pkmn.name,
                    level_cap, expGained))
                end
            elsif pkmn.onHotStreak? && HOT_STREAKS_ACTIVE
                pbDisplayPaused(_INTL("{1} got a Hot Streak boosted {2} Exp. Points!", pkmn.name, expGained))
            else
                pbDisplayPaused(_INTL("{1} got {2} Exp. Points!", pkmn.name, expGained))
            end
        end
        if newLevel < curLevel
            debugInfo = "Levels: #{curLevel}->#{newLevel} | Exp: #{pkmn.exp}->#{expFinal} | gain: #{expGained}"
            pbDisplayPaused(_INTL("{1}'s new level is less than its\r\ncurrent level, which shouldn't happen.\r\n[Debug: {2}]",
                pkmn.name, debugInfo))
        end
        if newLevel > level_cap
            raise _INTL("{1}'s new level is greater than the level cap, which shouldn't happen.\r\n[Debug: {2}]",
                pkmn.name, debugInfo)
        end
        tempExp1 = pkmn.exp
        battler = pbFindBattler(idxParty)
        loop do # For each level gained in turn...
            # EXP Bar animation
            levelMinExp = growth_rate.minimum_exp_for_level(curLevel)
            levelMaxExp = growth_rate.minimum_exp_for_level(curLevel + 1)
            tempExp2 = (levelMaxExp < expFinal) ? levelMaxExp : expFinal
            pkmn.exp = tempExp2
            @scene.pbEXPBar(battler, levelMinExp, levelMaxExp, tempExp1, tempExp2)
            tempExp1 = tempExp2
            curLevel += 1
            if curLevel > newLevel
                # Gained all the Exp now, end the animation
                pkmn.calc_stats
                battler.pbUpdate(false) if battler
                @scene.pbRefreshOne(battler.index) if battler
                break
            end
            # Levelled up
            pbCommonAnimation("LevelUp", battler) if battler
            oldTotalHP = pkmn.totalhp
            oldAttack  = pkmn.attack
            oldDefense = pkmn.defense
            oldSpAtk   = pkmn.spatk
            oldSpDef   = pkmn.spdef
            oldSpeed   = pkmn.speed
            pkmn.calc_stats
            battler.pbUpdate(false) if battler
            @scene.pbRefreshOne(battler.index) if battler
            pbDisplayPaused(_INTL("{1} grew to Lv. {2}!", pkmn.name, curLevel))
            @scene.pbLevelUp(pkmn, battler, oldTotalHP, oldAttack, oldDefense,
                                          oldSpAtk, oldSpDef, oldSpeed)
            # Learn all moves learned at this level
            moveList = pkmn.getMoveList
            unless $PokemonSystem.prompt_level_moves == 1
                moveList.each { |m| pbLearnMove(idxParty, m[1]) if m[0] == curLevel }
            end
            battler.pokemon.changeHappiness("levelup") if battler && battler.pokemon
        end
        $PokemonGlobal.expJAR = 0 if $PokemonGlobal.expJAR.nil?
        $PokemonGlobal.expJAR += expLeftovers if expLeftovers > 0 && hasExpJAR
    end

    #=============================================================================
    # Learning a move
    #=============================================================================
    def pbLearnMove(idxParty, newMove)
        pkmn = pbParty(0)[idxParty]
        return unless pkmn
        pkmnName = pkmn.name
        battler = pbFindBattler(idxParty)
        moveName = GameData::Move.get(newMove).name
        # Pokémon already knows the move
        return if pkmn.moves.any? { |m| m && m.id == newMove }
        # Pokémon has space for the new move; just learn it
        if pkmn.moves.length < Pokemon::MAX_MOVES
            pkmn.moves.push(Pokemon::Move.new(newMove))
            pbDisplay(_INTL("{1} learned {2}!", pkmnName, moveName)) { pbSEPlay("Pkmn move learnt") }
            if battler
                battler.moves.push(PokeBattle_Move.from_pokemon_move(self, pkmn.moves.last))
                battler.pbCheckFormOnMovesetChange
            end
            return
        end
        # Pokémon already knows the maximum number of moves; try to forget one to learn the new move
        loop do
            pbDisplayPaused(_INTL("{1} wants to learn {2}, but it already knows {3} moves.",
                pkmnName, moveName, pkmn.moves.length.to_word))
            pbDisplayPaused(_INTL("Which move should be forgotten?"))
            forgetMove = @scene.pbForgetMove(pkmn, newMove)
            if forgetMove >= 0
                oldMoveName = pkmn.moves[forgetMove].name
                pkmn.moves[forgetMove] = Pokemon::Move.new(newMove)   # Replaces current/total PP
                battler.moves[forgetMove] = PokeBattle_Move.from_pokemon_move(self, pkmn.moves[forgetMove]) if battler
                pbDisplayPaused(_INTL("{1} forgot how to use {2}. And...", pkmnName, oldMoveName))
                pbDisplay(_INTL("{1} learned {2}!", pkmnName, moveName)) { pbSEPlay("Pkmn move learnt") }
                battler.pbCheckFormOnMovesetChange if battler
                break
            else
                break
            end
        end
    end
end
