#===============================================================================
# This move turns into the last move used by the target, until user switches
# out. (Mimic)
#===============================================================================
class PokeBattle_Move_ReplaceMoveThisBattleWithTargetLastMoveUsed < PokeBattle_Move
    def ignoresSubstitute?(_user); return true; end

    def initialize(battle, move)
        super
        @moveBlacklist = [
            "UseRandomNonSignatureMove", # Metronome
            # Struggle
            "Struggle", # Struggle
            # Moves that affect the moveset
            "ReplaceMoveThisBattleWithTargetLastMoveUsed",   # Mimic
            "ReplaceMoveWithTargetLastMoveUsed",   # Sketch
            "TransformUserIntoTarget",   # Transform
        ]
    end

    def pbMoveFailed?(user, _targets, show_message)
        if user.transformed?
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} is transformed!")) if show_message
            return true
        end
        unless user.pbHasMove?(@id)
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} doesn't know Mimic!")) if show_message
            return true
        end
        return false
    end

    def pbFailsAgainstTarget?(user, target, show_message)
        lastMoveData = GameData::Move.try_get(target.lastRegularMoveUsed)
        if !lastMoveData
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} hasn't used a move!")) if show_message
            return true
        end
        if user.pbHasMove?(target.lastRegularMoveUsed)
             @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} already knows #{target.pbThis(true)}'s most recent move!")) if show_message
             return true
        end
        if @moveBlacklist.include?(lastMoveData.function_code)
            @battle.pbDisplay(_INTL("But it failed, #{target.pbThis(true)}'s most recent move can't be Mimicked!")) if show_message
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        user.eachMoveWithIndex do |m, i|
            next if m.id != @id
            newMove = Pokemon::Move.new(target.lastRegularMoveUsed)
            user.moves[i] = PokeBattle_Move.from_pokemon_move(@battle, newMove)
            @battle.pbDisplay(_INTL("{1} learned {2}!", user.pbThis, newMove.name))
            user.pbCheckFormOnMovesetChange
            break
        end
    end
end

#===============================================================================
# This move permanently turns into the last move used by the target. (Sketch)
#===============================================================================
class PokeBattle_Move_ReplaceMoveWithTargetLastMoveUsed < PokeBattle_Move
    def ignoresSubstitute?(_user); return true; end

    def initialize(battle, move)
        super
        @moveBlacklist = [
            "ReplaceMoveWithTargetLastMoveUsed", # Sketch (this move)
            "Struggle", # Struggle
        ]
    end

    def pbMoveFailed?(user, _targets, show_message)
        if user.transformed?
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} is transformed!")) if show_message
            return true
        end
        if !user.pbHasMove?(@id)
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} doesn't know Sketch!")) if show_message
            return true
        end
        return false
    end

    def pbFailsAgainstTarget?(user, target, show_message)
        lastMoveData = GameData::Move.try_get(target.lastRegularMoveUsed)
        if !lastMoveData
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} hasn't used a move!")) if show_message
            return true
        end
        if user.pbHasMove?(target.lastRegularMoveUsed)
             @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} already knows #{target.pbThis(true)}'s most recent move!")) if show_message
             return true
        end
        if @moveBlacklist.include?(lastMoveData.function_code)
            @battle.pbDisplay(_INTL("But it failed, #{target.pbThis(true)}'s most recent move can't be Sketched!")) if show_message
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        user.eachMoveWithIndex do |m, i|
            next if m.id != @id
            newMove = Pokemon::Move.new(target.lastRegularMoveUsed)
            user.pokemon.moves[i] = newMove
            user.moves[i] = PokeBattle_Move.from_pokemon_move(@battle, newMove)
            @battle.pbDisplay(_INTL("{1} learned {2}!", user.pbThis, newMove.name))
            user.pbCheckFormOnMovesetChange
            user.pokemon.first_moves.push(newMove.id)
            break
        end
    end
end

#===============================================================================
# User transforms into the target. (Transform)
#===============================================================================
class PokeBattle_Move_TransformUserIntoTarget < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        if user.transformed?
            @battle.pbDisplay(_INTL("But it failed, since the user is already transformed!")) if show_message
            return true
        end
        return false
    end

    def pbFailsAgainstTarget?(_user, target, show_message)
        if target.transformed?
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is also transformed!")) if show_message
            return true
        end
        if target.illusion?
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is disguised by an Illusion!"))
            end
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        user.pbTransform(target)
    end

    def getEffectScore(_user, _target)
        return 80
    end
end

#===============================================================================
# Uses the last move that the target used. (Mirror Move)
#===============================================================================
class PokeBattle_Move_UseLastMoveUsedByTarget < PokeBattle_Move
    def ignoresSubstitute?(_user); return true; end
    def callsAnotherMove?; return true; end

    def pbFailsAgainstTarget?(user, target, show_message)
        unless target.lastRegularMoveUsed
            if show_message
                @battle.pbDisplay(_INTL("But #{target.pbThis(true)} has no move for #{user.pbThis(true)} to mirror!"))
            end
            return true
        end
        unless @battle.getBattleMoveInstanceFromID(target.lastRegularMoveUsed).canMirrorMove? # Not copyable by Mirror Move
            @battle.pbDisplay(_INTL("But #{target.pbThis(true)}'s last used move can't be mirrored!")) if show_message
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        user.pbUseMoveSimple(target.lastRegularMoveUsed, target.index)
    end

    def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
        # No animation
    end

    def getEffectScore(_user, _target)
        return 80
    end
end

#===============================================================================
# Uses the last move that was used. (Copycat)
#===============================================================================
class PokeBattle_Move_UseLastMoveUsed < PokeBattle_Move
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
            "FrostbiteAttackerBeforeUserActs",   # Condensate
        ]
    end

    def pbChangeUsageCounters(user, specialUsage)
        super
        @copied_move = @battle.lastMoveUsed
    end

    def pbMoveFailed?(_user, _targets, show_message)
        unless @copied_move
            @battle.pbDisplay(_INTL("But it failed, since there was no move to copy!")) if show_message
            return true
        end
        moveObject = @battle.getBattleMoveInstanceFromID(@copied_move)
        if      @moveBlacklist.include?(GameData::Move.get(@copied_move).function_code) || 
                moveObject.forceSwitchMove? ||
                moveObject.is_a?(PokeBattle_HelpingMove) ||
                moveObject.callsAnotherMove?
            @battle.pbDisplay(_INTL("But it failed, since the last used move can't be copied!")) if show_message
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        user.pbUseMoveSimple(@copied_move)
    end

    def getEffectScore(_user, _target)
        return 80
    end
end

#===============================================================================
# Uses the move the target was about to use this round, with 1.5x power.
# (Me First)
#===============================================================================
class PokeBattle_Move_UseMoveTargetIsAboutToUse < PokeBattle_Move
    def ignoresSubstitute?(_user); return true; end
    def callsAnotherMove?; return true; end

    def initialize(battle, move)
        super
        @moveBlacklist = [
            "StealsItem", # Covet, Thief
            # Struggle
            "Struggle",   # Struggle
            # Counter moves
            "CounterPhysicalDamage",   # Counter
            "CounterSpecialDamage",   # Mirror Coat
            "CounterDamagePlusHalf",   # Metal Burst
            # Moves that start focussing at the start of the round
            "FailsIfUserDamagedThisTurn",   # Focus Punch
            "UsedAfterUserTakesPhysicalDamage",   # Shell Trap
            "UsedAfterUserTakesSpecialDamage",   # Masquerblade
            "BurnAttackerBeforeUserActs", # Beak Blast
            "FrostbiteAttackerBeforeUserActs",   # Condensate
        ]
    end

    def pbFailsAgainstTarget?(_user, target, show_message)
        return true if pbMoveFailedTargetAlreadyMoved?(target, show_message)
        oppMove = @battle.choices[target.index][2]
        if !oppMove || oppMove.statusMove? || @moveBlacklist.include?(oppMove.function)
            @battle.pbDisplay(_INTL("But it failed!")) if show_message
            return true
        end
        return false
    end

    def pbFailsAgainstTargetAI?(_user, _target); return false; end

    def pbEffectAgainstTarget(user, target)
        user.applyEffect(:MeFirst)
        user.pbUseMoveSimple(@battle.choices[target.index][2].id)
        user.disableEffect(:MeFirst)
    end

    def getEffectScore(_user, _target)
        echoln("The AI will never use Me First.")
        return -1000
    end
end

#===============================================================================
# The user picks between moves to use, those being the 3 last (Cross Examine)
# moves used by any foe.
#===============================================================================
class PokeBattle_Move_UseChoiceOf3LastUsedMoves < PokeBattle_Move
    def resolutionChoice(user)
        @chosenMoveID = :STRUGGLE
        validMoves = validMoveArray(user)
        moveChoices = []
        validMoves.reverse.each do |moveID|
            next if moveChoices.include?(moveID)
            moveChoices.push(moveID)
            break if moveChoices.length == 3
        end

        moveNames = []
        moveChoices.each do |moveID|
            moveNames.push(GameData::Move.get(moveID).name)
        end
        if moveChoices.length == 1
            @chosenMoveID = moveChoices[0]
        elsif moveChoices.length > 1
            if @battle.autoTesting
                @chosenMoveID = moveChoices.sample
            elsif !user.pbOwnedByPlayer? # Trainer AI
                @chosenMoveID = moveChoices[0]
            else
                chosenIndex = @battle.scene.pbShowCommands(_INTL("Which move should #{user.pbThis(true)} use?"),moveNames,0)
                @chosenMoveID = moveChoices[chosenIndex]
            end
        end
    end

    def validMoveArray(user)
        if user.opposes?
            return @battle.allMovesUsedSide0
        else
            return @battle.allMovesUsedSide1
        end
    end

    def pbMoveFailed?(user, targets, show_message)
        if validMoveArray(user).empty?
            @battle.pbDisplay(_INTL("But it failed, since no foe has yet used a move!")) if show_message
            return true
        end
        super
    end

    def pbEffectGeneral(user)
        user.pbUseMoveSimple( @chosenMoveID)
    end

    def resetMoveUsageState
        @chosenMoveID = nil
    end

    def getEffectScore(_user, _target)
        echoln("The AI will never use Cross-Examine.")
        return 0
    end
end