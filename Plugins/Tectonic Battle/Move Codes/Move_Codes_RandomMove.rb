#===============================================================================
# Uses a random move the user knows. Fails if user is not asleep. (Sleep Talk)
#===============================================================================
class PokeBattle_Move_UseRandomUserMoveIfAsleep < PokeBattle_Move
    def usableWhenAsleep?; return true; end
    def callsAnotherMove?; return true; end

    def initialize(battle, move)
        super
        @moveBlacklist = [
            # Struggle
            "Struggle",   # Struggle
            # Moves that affect the moveset (except Transform)
            "ReplaceMoveThisBattleWithTargetLastMoveUsed",   # Mimic
            "ReplaceMoveWithTargetLastMoveUsed",   # Sketch
            # Moves that start focussing at the start of the round
            "FailsIfUserDamagedThisTurn",   # Focus Punch
            "UsedAfterUserTakesPhysicalDamage",   # Shell Trap
            "UsedAfterUserTakesSpecialDamage",   # Masquerblade
            "BurnAttackerBeforeUserActs", # Beak Blast
            "FrostbiteAttackerBeforeUserActs", # Condensate
        ]
    end

    def getSleepTalkMoves(user)
        sleepTalkMoves = []
        user.eachMoveWithIndex do |m, i|
            next if @moveBlacklist.include?(m.function)
            next if m.is_a?(PokeBattle_TwoTurnMove)
            next if m.callsAnotherMove?
            next unless @battle.pbCanChooseMove?(user.index, i, false, true)
            sleepTalkMoves.push(i)
        end
        return sleepTalkMoves
    end

    def pbMoveFailed?(user, _targets, show_message)
        unless user.asleep?
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} isn't asleep!")) if show_message
            return true
        end
        if getSleepTalkMoves(user).length == 0
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since none of #{user.pbThis(true)}'s moves can be used from Sleep Talk!"))
            end
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        choice = getSleepTalkMoves(user).sample
        user.pbUseMoveSimple(user.getMoves[choice].id, user.pbDirectOpposing.index)
    end

    def getEffectScore(_user, _target)
        echoln("The AI will never use Sleep talk.")
        return -1000
    end
end

#===============================================================================
# Uses a random move known by any non-user Pokémon in the user's party. (Assist)
#===============================================================================
class PokeBattle_Move_UseRandomMoveFromUserParty < PokeBattle_Move
    def callsAnotherMove?; return true; end

    def initialize(battle, move)
        super
        @moveBlacklist = [
            # Struggle
            "Struggle",   # Struggle
            # Moves that affect the moveset
            "ReplaceMoveThisBattleWithTargetLastMoveUsed",   # Mimic
            "ReplaceMoveWithTargetLastMoveUsed",   # Sketch
            "TransformUserIntoTarget",   # Transform
            # Counter moves
            "CounterPhysicalDamage",   # Counter
            "CounterSpecialDamage",   # Mirror Coat
            "CounterDamagePlusHalf",   # Metal Burst
            # Move-redirecting and stealing moves
            "BounceBackProblemCausingStatusMoves",   # Magic Coat
            "StealAndUseBeneficialStatusMove",   # Snatch
            "RedirectAllMovesToUser",   # Follow Me, Rage Powder
            "RedirectAllMovesToTarget",   # Spotlight
            # Set up effects that trigger upon KO
            "AttackerFaintsIfUserFaints",   # Destiny Bond
            # Held item-moving moves
            "StealsItem",   # Covet, Thief
            "SwapItems",   # Switcheroo, Trick
            "GiftItem",   # Bestow
            # Moves that start focussing at the start of the round
            "FailsIfUserDamagedThisTurn",   # Focus Punch
            "UsedAfterUserTakesPhysicalDamage",   # Shell Trap
            "UsedAfterUserTakesSpecialDamage",   # Masquerblade
            "BurnAttackerBeforeUserActs",   # Beak Blast
            "FrostbiteAttackerBeforeUserActs", # Condensate
        ]
    end

    def getAssistMoves(user)
        assistMoves = []
        @battle.pbParty(user.index).each_with_index do |pkmn, i|
            next if !pkmn || i == user.pokemonIndex
            next if pkmn.egg?
            pkmn.moves.each do |move|
                next if @moveBlacklist.include?(move.function_code)
                battleMoveInstance = @battle.getBattleMoveInstanceFromID(move.id)
                next if battleMoveInstance.forceSwitchMove?
                next if battleMoveInstance.is_a?(PokeBattle_TwoTurnMove)
                next if battleMoveInstance.is_a?(PokeBattle_HelpingMove)
                next if battleMoveInstance.is_a?(PokeBattle_ProtectMove)
                next if battleMoveInstance.callsAnotherMove?
                assistMoves.push(move.id)
            end
        end
        return assistMoves
    end

    def pbMoveFailed?(user, _targets, show_message)
        if getAssistMoves(user).length == 0
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since there are no moves #{user.pbThis(true)} can use!"))
            end
            return true
        end
        
        return false
    end

    def pbEffectGeneral(user)
        move = getAssistMoves(user).sample
        user.pbUseMoveSimple(move)
    end
end

#===============================================================================
# Uses a random move that exists. (Metronome)
#===============================================================================
class PokeBattle_Move_UseRandomNonSignatureMove < PokeBattle_Move
    def callsAnotherMove?; return true; end

    def initialize(battle, move)
        super
        @moveBlacklist = [
            "FlinchTargetFailsIfUserNotAsleep",   # Snore
            "TargetActsNext",   # After You
            "TargetActsLast",   # Quash
            # Move-redirecting and stealing moves
            "BounceBackProblemCausingStatusMoves",   # Magic Coat
            "StealAndUseBeneficialStatusMove",   # Snatch
            "RedirectAllMovesToUser",   # Follow Me, Rage Powder
            "RedirectAllMovesToTarget",   # Spotlight
            # Held item-moving moves
            "StealsItem",   # Covet, Thief
            "SwapItems",   # Switcheroo, Trick
            "GiftItem",   # Bestow
            # Invalid moves
            "Invalid",
        ]

        @metronomeMoves = []
        GameData::Move::DATA.keys.each do |move_id|
            move_data = GameData::Move.get(move_id)
            next if move_data.learnable?
            next unless move_data.can_be_forced?
            next if @moveBlacklist.include?(move_data.function_code)
            next if move_data.empoweredMove?
            moveObject = @battle.getBattleMoveInstanceFromID(move_id)
            next if moveObject.is_a?(PokeBattle_ProtectMove)
            next if moveObject.is_a?(PokeBattle_HelpingMove)
            next if moveObject.callsAnotherMove?
            @metronomeMoves.push(move_data.id)
        end
    end

    def pbMoveFailed?(_user, _targets, show_message)
        if @metronomeMoves.empty?
            @battle.pbDisplay(_INTL("But it failed, since there are no moves to use!")) if show_message
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        choice = @metronomeMoves.sample
        user.pbUseMoveSimple(choice)
    end

    def getEffectScore(_user, _target)
        echoln("The AI will never use Metronome")
        return -1000
    end
end

#===============================================================================
# The user is given the choice of using one of 3 randomly chosen status moves. (Discovered Power)
#===============================================================================
class PokeBattle_Move_UseChoiceOf3RandomNonSignatureStatusMoves < PokeBattle_Move
    def callsAnotherMove?; return true; end

    def initialize(battle, move)
        super
        @discoverableMoves = []
        GameData::Move::DATA.keys.each do |move_id|
            move_data = GameData::Move.get(move_id)
            next unless move_data.category == 2 # Status moves only
            next if move_data.function_code == "Invalid"
            next if move_data.is_signature?
            next unless move_data.learnable?
            next unless move_data.can_be_forced?
            moveObject = @battle.getBattleMoveInstanceFromID(move_id)
            next if moveObject.is_a?(PokeBattle_ProtectMove)
            next if moveObject.is_a?(PokeBattle_HelpingMove)
            next if moveObject.callsAnotherMove?
            @discoverableMoves.push(move_data.id)
        end
    end

    def resolutionChoice(user)
        validMoves = []
        validMoveNames = []
        until validMoves.length == 3
            movePossibility = @discoverableMoves.sample
            unless validMoves.include?(movePossibility)
                validMoves.push(movePossibility)
                validMoveNames.push(getMoveName(movePossibility))
            end
        end

        if @battle.autoTesting
            @chosenMove = validMoves.sample
        elsif !user.pbOwnedByPlayer? # Trainer AI
            @chosenMove = validMoves[0]
        else
            chosenIndex = @battle.scene.pbShowCommands(_INTL("Which move should #{user.pbThis(true)} use?"),validMoveNames,0)
            @chosenMove = validMoves[chosenIndex]
        end
    end

    def pbEffectGeneral(user)
        user.pbUseMoveSimple(@chosenMove) if @chosenMove
    end

    def resetMoveUsageState
        @chosenMove = nil
    end

    def getEffectScore(_user, _target)
        echoln("The AI will never use Discovered Power")
        return -1000
    end
end

#===============================================================================
# Uses a random special Dragon-themed move, then a random physical Dragon-themed move. (Dragon Invocation)
#===============================================================================
class PokeBattle_Move_UseTwoRandomDragonThemedMoves < PokeBattle_Move
    def callsAnotherMove?; return true; end

    def initialize(battle, move)
        super
        @invocationMovesPhysical = [
            :DRAGONCLAW,
            :DRAGONCLAW,
            :CRUNCH,
            :EARTHQUAKE,
            :DUALWINGBEAT,
        ]

        @invocationMovesSpecial = [
            :DRAGONBREATH,
            :DRAGONBREATH,
            :FLAMETHROWER,
            :MIASMA,
            :FROSTBREATH,
        ]
    end

    def pbEffectGeneral(user)
        user.pbUseMoveSimple(@invocationMovesSpecial.sample)
        user.pbUseMoveSimple(@invocationMovesPhysical.sample)
    end

    def getEffectScore(_user, _target)
        echoln("The AI will never use Dragon Invocation")
        return -1000
    end
end

#===============================================================================
# The user is given the choice of using one of 3 randomly chosen moves (Selective Memory)
# in a predetermined list of non-Psychic attacks.
#===============================================================================
class PokeBattle_Move_UseChoiceOf3RandomNonSignatureNonPsychicDamagingMoves < PokeBattle_Move
    def callsAnotherMove?; return true; end

    def initialize(battle, move)
        super
        @selectableMoves = %i[
            HYPERVOICE
            FLAMETHROWER
            BUBBLEBLASTER
            ENERGYBALL
            THUNDERBOLT
            ICEBEAM
            AURASPHERE
            MIASMA
            EARTHPOWER
            COLDFRONT
            BUGBUZZ
            POWERGEM
            SHADOWBALL
            DRAGONPULSE
            DARKALLURE
            FLASHCANNON
            MOONBLAST
            CLEARSMOG
            HEX
            TRICKYTOXINS
            CHARGEBEAM
            BLUSTER
            BLOSSOM
            HYPERBEAM
        ]
    end

    def resolutionChoice(user)
        validMoves = []
        validMoveNames = []
        until validMoves.length == 3
            movePossibility = @selectableMoves.sample
            unless validMoves.include?(movePossibility)
                validMoves.push(movePossibility)
                validMoveNames.push(getMoveName(movePossibility))
            end
        end

        if @battle.autoTesting
            @chosenMove = validMoves.sample
        elsif !user.pbOwnedByPlayer? # Trainer AI
            @chosenMove = validMoves[0]
        else
            chosenIndex = @battle.scene.pbShowCommands(_INTL("Which move should #{user.pbThis(true)} use?"),validMoveNames,0)
            @chosenMove = validMoves[chosenIndex]
        end
    end

    def pbEffectGeneral(user)
        user.pbUseMoveSimple(@chosenMove) if @chosenMove
    end

    def resetMoveUsageState
        @chosenMove = nil
    end

    def getEffectScore(_user, _target)
        echoln("The AI will never use Selective Memory")
        return -1000
    end
end