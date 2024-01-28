#===============================================================================
# Uses a random move the user knows. Fails if user is not asleep. (Sleep Talk)
#===============================================================================
class PokeBattle_Move_0B4 < PokeBattle_Move
    def usableWhenAsleep?; return true; end
    def callsAnotherMove?; return true; end

    def initialize(battle, move)
        super
        @moveBlacklist = [
            # Struggle
            "002",   # Struggle
            # Moves that affect the moveset (except Transform)
            "05C",   # Mimic
            "05D",   # Sketch
            # Moves that start focussing at the start of the round
            "115",   # Focus Punch
            "171",   # Shell Trap
            "12B",   # Masquerblade
            "172", # Beak Blast
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
class PokeBattle_Move_0B5 < PokeBattle_Move
    def callsAnotherMove?; return true; end

    def initialize(battle, move)
        super
        @moveBlacklist = [
            # Struggle
            "002",   # Struggle
            # Moves that affect the moveset
            "05C",   # Mimic
            "05D",   # Sketch
            "069",   # Transform
            # Counter moves
            "071",   # Counter
            "072",   # Mirror Coat
            "073",   # Metal Burst
            # Move-redirecting and stealing moves
            "0B1",   # Magic Coat
            "0B2",   # Snatch
            "117",   # Follow Me, Rage Powder
            "16A",   # Spotlight
            # Set up effects that trigger upon KO
            "0E6",   # Grudge
            "0E7",   # Destiny Bond
            # Held item-moving moves
            "0F1",   # Covet, Thief
            "0F2",   # Switcheroo, Trick
            "0F3",   # Bestow
            # Moves that start focussing at the start of the round
            "115",   # Focus Punch
            "171",   # Shell Trap
            "12B",   # Masquerblade
            "172",   # Beak Blast
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
class PokeBattle_Move_0B6 < PokeBattle_Move
    def callsAnotherMove?; return true; end

    def initialize(battle, move)
        super
        @moveBlacklist = [
            "011",   # Snore
            "11D",   # After You
            "11E",   # Quash
            # Move-redirecting and stealing moves
            "0B1",   # Magic Coat
            "0B2",   # Snatch
            "117",   # Follow Me, Rage Powder
            "16A",   # Spotlight
            # Held item-moving moves
            "0F1",   # Covet, Thief
            "0F2",   # Switcheroo, Trick
            "0F3",   # Bestow
        ]

        @metronomeMoves = []
        GameData::Move::DATA.keys.each do |move_id|
            move_data = GameData::Move.get(move_id)
            next if move_data.is_signature?
            next if move_data.cut
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
class PokeBattle_Move_13C < PokeBattle_Move
    def callsAnotherMove?; return true; end

    def initialize(battle, move)
        super
        @discoverableMoves = []
        GameData::Move::DATA.keys.each do |move_id|
            move_data = GameData::Move.get(move_id)
            next unless move_data.category == 2
            next if move_data.is_signature?
            next if move_data.cut
            next unless move_data.can_be_forced?
            next if move_data.empoweredMove?
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
        return 80
    end
end

#===============================================================================
# Uses a random special Dragon-themed move, then a random physical Dragon-themed move. (Dragon Invocation)
#===============================================================================
class PokeBattle_Move_5C3 < PokeBattle_Move
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