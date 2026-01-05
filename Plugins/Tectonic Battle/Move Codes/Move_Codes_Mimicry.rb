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
            @battle.pbDisplay(_INTL("But it failed, since {1} is transformed!", user.pbThis(true))) if show_message
            return true
        end
        if !user.pbHasMove?(@id)
            @battle.pbDisplay(_INTL("But it failed, since {1} doesn't know Sketch!", user.pbThis(true))) if show_message
            return true
        end
        return false
    end

    def pbFailsAgainstTarget?(user, target, show_message)
        lastMoveData = GameData::Move.try_get(target.lastRegularMoveUsed)
        if !lastMoveData
            @battle.pbDisplay(_INTL("But it failed, since {1} hasn't used a move!", target.pbThis(true))) if show_message
            return true
        end
        if user.pbHasMove?(target.lastRegularMoveUsed)
             @battle.pbDisplay(_INTL("But it failed, since {1} already knows {2}'s most recent move!", user.pbThis(true), target.pbThis(true))) if show_message
             return true
        end
        if @moveBlacklist.include?(lastMoveData.function_code)
            @battle.pbDisplay(_INTL("But it failed, {1}'s most recent move can't be Sketched!", target.pbThis(true))) if show_message
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
            @battle.pbDisplay(_INTL("But it failed, since {1} is also transformed!", target.pbThis(true))) if show_message
            return true
        end
        if target.illusion?
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since {1} is disguised by an Illusion!", target.pbThis(true)))
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
# Uses the attacking move the target was about to use this round, with 1.5x power.
# (Me First)
#===============================================================================
class PokeBattle_Move_UseMoveTargetIsAboutToUse < PokeBattle_Move
    def ignoresSubstitute?(_user); return true; end
    def callsAnotherMove?; return true; end

    def pbFailsAgainstTarget?(_user, target, show_message)
        return true if pbMoveFailedTargetAlreadyMoved?(target, show_message)
        oppMove = @battle.choices[target.index][2]
        unless oppMove
            @battle.pbDisplay(_INTL("But it failed, since the target didn't choose to use a move!")) if show_message
            return true
        end
        if oppMove.statusMove?
            @battle.pbDisplay(_INTL("But it failed, since the target chose to use a status move!")) if show_message
            return true
        end
        unless @battle.canInvokeMove?(oppMove)
            @battle.pbDisplay(_INTL("But it failed, since the target chose a move that can't be copied!")) if show_message
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
    def resolutionChoice(user, replayed_choice)
        @chosenMoveID = :STRUGGLE
        validMoves = validMoveArray(user)
        moveChoices = []
        validMoves.reverse.each do |moveID|
            next if moveChoices.include?(moveID)
            next if moveID == @id
            next unless @battle.canInvokeMove?(moveID)
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
            elsif !replayed_choice.nil?
                @chosenMoveID = replayed_choice
            else
                chosenIndex = @battle.scene.pbShowCommands(_INTL("Which move should {1} use?", user.pbThis(true)),moveNames,0)
                @chosenMoveID = moveChoices[chosenIndex]
                return @chosenMoveID
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