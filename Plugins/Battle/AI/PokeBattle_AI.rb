# AI skill levels:
#     0:     Wild Pokémon
#     1-31:  Basic trainer (young/inexperienced)
#     32-47: Some skill
#     48-99: High skill
#     100+:  Best trainers (Gym Leaders, Elite Four, Champion)
# NOTE: A trainer's skill value can range from 0-255, but by default only four
#       distinct skill levels exist. The skill value is typically the same as
#       the trainer's base money value.
module PBTrainerAI
    # Minimum skill level to be in each AI category.
    def self.minimumSkill; return 1;   end
    def self.mediumSkill;  return 32;  end
    def self.highSkill;    return 48;  end
    def self.bestSkill;    return 100; end
end
    
class PokeBattle_AI
    def initialize(battle)
      @battle = battle
    end
  
    def pbAIRandom(x); return rand(x); end
  
    def pbStdDev(choices)
      sum = 0
      n   = 0
      choices.each do |c|
        sum += c[1]
        n   += 1
      end
      return 0 if n<2
      mean = sum.to_f/n.to_f
      varianceTimesN = 0
      choices.each do |c|
        next if c[1]<=0
        deviation = c[1].to_f-mean
        varianceTimesN += deviation*deviation
      end
      # Using population standard deviation
      # [(n-1) makes it a sample std dev, would be 0 with only 1 sample]
      return Math.sqrt(varianceTimesN/n)
    end
  
    #=============================================================================
    # Decide whether the opponent should Mega Evolve their Pokémon
    #=============================================================================
    def pbEnemyShouldMegaEvolve?(idxBattler)
      battler = @battle.battlers[idxBattler]
      if @battle.pbCanMegaEvolve?(idxBattler)   # Simple "always should if possible"
        PBDebug.log("[AI] #{battler.pbThis} (#{idxBattler}) will Mega Evolve")
        return true
      end
      return false
    end
  
    #=============================================================================
    # Choose an action
    #=============================================================================
    def pbDefaultChooseEnemyCommand(idxBattler)
        return if @battle.pbAutoFightMenu(idxBattler) #Battle palace shenanigans
        @battle.pbRegisterMegaEvolution(idxBattler) if pbEnemyShouldMegaEvolve?(idxBattler)
        user = @battle.battlers[idxBattler]
        
        if user.boss?
          pbChooseMovesBoss(idxBattler)
        elsif @battle.wildBattle? && @battle.opposes?(idxBattler) # Checks for opposing because it could be an partner trainer's pokemon
          @battle.pbRegisterMove(idxBattler,pbAIRandom(user.moves.length),false)
        else
          bestMoveChoices = pbGetBestTrainerMoveChoices(user,100,user.ownersPolicies)
          return if pbEnemyShouldWithdraw?(idxBattler,bestMoveChoices)
          pbChooseMovesTrainer(idxBattler,bestMoveChoices)
        end
    end

    def logMoveChoices(user,choices)
        # Log the available choices
        logMsg = "[AI] Move choices for #{user.pbThis(true)} (#{user.index}): "
        choices.each_with_index do |c,i|
          logMsg += "#{user.moves[c[0]].name}=#{c[1]}"
          logMsg += " (target #{c[2]})" if c[2]>=0
          logMsg += " [E]" if user.moves[c[0]].empoweredMove?
          logMsg += ", " if i < choices.length-1
        end
        PBDebug.log(logMsg)
    end
end
  