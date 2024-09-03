KillInfo = Struct.new(:user, :move, :speed, :priority, :score)

class PokeBattle_AI
    attr_reader :precalculatedChoices
    attr_reader :precalculatedDefensiveMatchup
    attr_accessor :battlePalace
    attr_accessor :battleArena

    def initialize(battle)
        @battle = battle
        @precalculatedChoices = {}
        @precalculatedDefensiveMatchup = {}
        @justswitched = [false,false,false,false]
        @battleArena = false
        @battlePalace = false
    end

    def pbAIRandom(x); return rand(x); end

    def pbStdDev(choices)
        sum = 0
        n = 0
        choices.each do |c|
            sum += c[1]
            n += 1
        end
        return 0 if n < 2
        mean = sum.to_f / n.to_f
        varianceTimesN = 0
        choices.each do |c|
            next if c[1] <= 0
            deviation = c[1].to_f - mean
            varianceTimesN += deviation * deviation
        end
        # Using population standard deviation
        # [(n-1) makes it a sample std dev, would be 0 with only 1 sample]
        return Math.sqrt(varianceTimesN / n)
    end

    #=============================================================================
    # Choose an action
    #=============================================================================
    def pbDefaultChooseEnemyCommand(idxBattler)
        return if @battle.pbAutoFightMenu(idxBattler) # Battle palace shenanigans
        battler = @battle.battlers[idxBattler]

        if battler.boss?
            pbChooseMovesBoss(idxBattler)
        elsif @battle.wildBattle? && @battle.opposes?(idxBattler) # Checks for opposing because it could be an partner trainer's pokemon
            pbChooseMovesWild(idxBattler)
        else
            return if !battler.effectActive?(:AutoPilot) && pbEnemyShouldWithdraw?(idxBattler)
            defensiveMatchupRating,killInfoArray = worstDefensiveMatchupAgainstActiveFoes(battler)
            bestMoveChoices,killInfo = pbGetBestTrainerMoveChoices(battler, killInfoArray: killInfoArray)
            pbChooseMovesTrainer(idxBattler, bestMoveChoices)
        end
    end

    def logMoveChoices(user, choices)
        # Log the available choices
        logMsg = "[AI] Move choices for #{user.pbThis(true)} (#{user.index}): "
        choices.each_with_index do |c, i|
            logMsg += "#{user.getMoves[c[0]].name}=#{c[1]}"
            logMsg += " (target #{c[2]})" if c[2] >= 0
            logMsg += " [E]" if user.getMoves[c[0]].empoweredMove?
            logMsg += ", " if i < choices.length - 1
        end
        PBDebug.log(logMsg)
    end

    def resetPrecalculations
        @precalculatedChoices.clear
        @precalculatedDefensiveMatchup.clear
    end

    def pbPredictChoiceByPlayer(idxBattler)
        user = @battle.battlers[idxBattler]
        bestMoveChoices,killInfo = pbGetBestTrainerMoveChoices(user)
        return [:None, 0, nil, -1] if bestMoveChoices.empty?
        switchChoice = pbDetermineSwitch(idxBattler)
        return [:SwitchOut, switchChoice, -1] if switchChoice > -1
        bestMoveChoices.sort_by! { |choice| -choice[1] }
        moveChoice = bestMoveChoices[0]
        moveIndex = moveChoice[0]
        return [:UseMove,moveIndex,user.getMoves[moveIndex],moveChoice[2]]
    end
end
