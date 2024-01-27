#===============================================================================
# This move turns into the last move used by the target, until user switches
# out. (Mimic)
#===============================================================================
class PokeBattle_Move_05C < PokeBattle_Move
    def ignoresSubstitute?(_user); return true; end

    def initialize(battle, move)
        super
        @moveBlacklist = [
            "0B6", # Metronome
            # Struggle
            "002", # Struggle
            # Moves that affect the moveset
            "05C",   # Mimic
            "05D",   # Sketch
            "069",   # Transform
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
class PokeBattle_Move_05D < PokeBattle_Move
    def ignoresSubstitute?(_user); return true; end

    def initialize(battle, move)
        super
        @moveBlacklist = [
            "05D", # Sketch (this move)
            "002", # Struggle
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
class PokeBattle_Move_069 < PokeBattle_Move
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
class PokeBattle_Move_0AE < PokeBattle_Move
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
class PokeBattle_Move_0AF < PokeBattle_Move
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
class PokeBattle_Move_0B0 < PokeBattle_Move
    def ignoresSubstitute?(_user); return true; end
    def callsAnotherMove?; return true; end

    def initialize(battle, move)
        super
        @moveBlacklist = [
            "0F1", # Covet, Thief
            # Struggle
            "002",   # Struggle
            # Counter moves
            "071",   # Counter
            "072",   # Mirror Coat
            "073",   # Metal Burst
            # Moves that start focussing at the start of the round
            "115",   # Focus Punch
            "171",   # Shell Trap
            "12B",   # Masquerblade
            "172", # Beak Blast
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