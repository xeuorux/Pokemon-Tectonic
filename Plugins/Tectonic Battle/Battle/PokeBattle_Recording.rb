module PokeBattle_BattleRecorder
	
	attr_accessor :type #Battle type. 0 for wild, 1 for trainer, 2 for avatar

	attr_accessor :recorded_choices #Array of the move choices made
	attr_accessor :random #Array of the random numbers used in the battle

	attr_accessor :player_info
	attr_accessor :player_party
	attr_accessor :player_party_starts
	
	attr_accessor :opponent_info
	attr_accessor :opponent_party
	attr_accessor :opponent_party_starts

	attr_accessor :starting_weather
	attr_accessor :starting_weather_duration

	attr_accessor :held_items

	attr_accessor :save_battle

	def initialize(scene, playerParty, foeParty, playerTrainers, foeTrainers, type)
		super(scene, playerParty, foeParty, playerTrainers, foeTrainers)
		@recorded_choices = []
		@random = []
		@is_recorded = true
		@save_battle = true
		@type = type
		echoln("TYPE: " + type.to_s)
	end

	def pbRandom(x)
		ret = rand(x)
		@random.push(ret)
		return ret
	end

	def pbCommandPhase
		@recorded_choices.push([]) #Add turn array
      	(maxBattlerIndex + 1).times { |i| @recorded_choices[@turnCount].push([])} #Add array for each battler
		@recorded_choices[@turnCount].each { |a| a.push(nil)} #Add first action placeholder

		super
		@choices.each_with_index do |c, i|
			c_clone = c.clone
			c_clone[2] = nil #Remove move object (not parsable)
			@recorded_choices[@turnCount][i][0] = c_clone
		end
    end

	def pbExtraCommandPhase
		super
		@choices.each_with_index do |c, i|
			b = @battlers[i]
			c_clone = c.clone
			c_clone[1] = b.moves.find_index(c[1]) #Transform move into move index
			@recorded_choices[@turnCount][i][@commandPhasesThisRound] = c_clone
		end
	end

	def pbGetTrainerInfo(trainer)
      return nil if !trainer
      if trainer.is_a?(Array)
        ret = []
        for i in 0...trainer.length
          if trainer[i].is_a?(Player)
            ret.push([trainer[i].trainer_type,trainer[i].name.clone,trainer[i].id,trainer[i].badges.clone])
          else   # NPCTrainer
            ret.push([trainer[i].trainer_type,trainer[i].name.clone,trainer[i].id])
          end
        end
        return ret
      elsif trainer[i].is_a?(Player)
        return [[trainer.trainer_type,trainer.name.clone,trainer.id,trainer.badges.clone]]
      else
        return [[trainer.trainer_type,trainer.name.clone,trainer.id]]
      end
    end

	def pbStartBattle
      	@player_info                  = pbGetTrainerInfo(@player)
      	@opponent_info                = pbGetTrainerInfo(@opponent)
      	@player_party                 = Marshal.dump(@party1)
      	@opponent_party               = Marshal.dump(@party2)
      	@player_party_starts          = Marshal.dump(@party1starts)
      	@opponent_party_starts        = Marshal.dump(@party2starts)
      	@starting_weather             = @field.weather
      	@starting_weather_duration    = @field.weatherDuration
      	@held_items                   = Marshal.dump(@items)
      	super
    end

	def pbEndOfBattle
		saveBattle("LastBattle") if @save_battle
		super
	end

	def registerLastChoice(index)
		@recorded_choices[@turnCount][index][@commandPhasesThisRound-1].push(last_choice) 
	end

	def getBattleData
		return Marshal.dump({
			:type => @type,
			:recorded_choices => @recorded_choices,
			:random => @random,
			:player_info => @player_info,
			:player_party => @player_party,
			:player_party_starts => @player_party_starts,
			:opponent_info => @opponent_info,
			:opponent_party => @opponent_party,
			:opponent_party_starts => @opponent_party_starts,
			:starting_weather => @starting_weather,
			:starting_weather_duration => @starting_weather_duration,
			:held_items => @held_items,
			:rules => Marshal.dump(@rules),
			:endSpeeches => (@endSpeeches) ? @endSpeeches.clone : "",
			:endSpeechesWin => (@endSpeechesWin) ? @endSpeechesWin.clone : "",
			:canRun => @canRun,
			:switchStyle => @switchStyle,
			:showAnims => @showAnims,
			:backdrop => @backdrop,
			:backdropBase => @backdropBase,
			:time => @time,
			:environment => @environment,
			:level_cap => getLevelCap()
		})
	end

	def saveBattle(name)
		Dir.mkdir("./VSRecorder") unless Dir.exists?("./VSRecorder")
		File.open("./VSRecorder/" + name + ".dat", "wb") { |f| f.write(getBattleData) }
	end
end

module PokeBattle_BattleReplayer
	include PokeBattle_BattleRecorder

	attr_accessor :randomindex
	attr_accessor :level_cap

	def initialize(scene, file_name)
		raise _INTL("Record {1} does not exist", file_name) unless File.exists?("./VSRecorder/" + file_name + ".dat")
		battle = File.open("./VSRecorder/" + file_name + ".dat", "rb") {|f| Marshal.load(f)}
		
		@is_recorded               = false
		@is_replayed               = true
		@randomindex               = 0
		@save_battle               = false
		
		@player_party              = Marshal.load(battle[:player_party])
		@player_party_starts       = Marshal.load(battle[:player_party_starts])
		@opponent_party            = Marshal.load(battle[:opponent_party])
		@opponent_party_starts     = Marshal.load(battle[:opponent_party_starts])
		@held_items                = Marshal.load(battle[:held_items])
		@rules                     = Marshal.load(battle[:rules])
		@recorded_choices          = battle[:recorded_choices]
		@random                    = battle[:random]
		@player_info               = battle[:player_info]
		@opponent_info             = battle[:opponent_info]
		@starting_weather          = battle[:starting_weather]
		@starting_weather_duration = battle[:starting_weather_duration]
		@endSpeeches               = battle[:endSpeeches]
		@endSpeechesWin            = battle[:endSpeechesWin]
		@canRun                    = battle[:canRun]
		@switchStyle               = battle[:switchStyle]
		@showAnims                 = battle[:showAnims]
		@backdrop                  = battle[:backdrop]
		@backdropBase              = battle[:backdropBase]
		@time                      = battle[:time]
		@environment               = battle[:environment]
		@level_cap                 = battle[:level_cap]

		@player                    = pbLoadTrainer(@player_info[0], @player_info[1], @player_info[2])
      	@opponent                  = pbLoadTrainer(@opponent_info[0], @opponent_info[1], @opponent_info[2])

		super(scene, @player_party, @opponent_party, @player, @opponent, battle[:type])
	end

	def pbRandom(x)
		ret = @random[@randomindex]
		@randomindex += 1
		return ret
	end

	def pbCommandPhase
		choices = []
		@recorded_choices.each_with_index do |c,i|
			choices[@turnCount][i] = @choices[@turnCount][i][0]
		end 
    end

	def pbExtraCommandPhase
		choices = []
		@recorded_choices.each_with_index do |c, i|
			@choices[@turnCount][i] = @choices[@turnCount][i][@commandPhasesThisRound]
		end
	end

	def pbStartBattle
      	@party1                    = Marshal.load(@player_party)
      	@party2                    = Marshal.load(@opponent_party)
      	@party1starts              = Marshal.load(@player_party_starts)
      	@party2starts              = Marshal.load(@opponent_party_starts)
      	@field.weather             = @starting_weather
      	@field.weatherDuration     = @starting_weather_duration
      	@items                     = Marshal.load(@held_items)
      	super
    end

	def registerNextChoice(index)
		choice = @recorded_choices[@turnCount][index]
		if choice.length < 5
			next_choice = @recorded_choices[@turnCount][index][4]
		else
			next_choice = nil
		end
	end
end

class PokeBattle_Battle
	def registerLastChoice(index); end
	def registerNextChoice(index); end
end

class PokeBattle_TectonicRecordedBattle < PokeBattle_Battle
	include PokeBattle_BattleRecorder
end

class PokeBattle_TectonicReplayedBattle < PokeBattle_Battle
	include PokeBattle_BattleReplayer
end

def playRecordedBattle(record_name)
	original_level_cap = getLevelCap()
	scene = pbNewBattleScene
	battle = PokeBattle_TectonicReplayedBattle.new(scene, record_name)
	
	setLevelCap(battle.level_cap, false)
	decision = 0	
	case battle.type
	when 0 #Wild battle
		pbBattleAnimation(pbGetWildBattleBGM(battle.party2),(battle.party2.length==1) ? 0 : 2,battle.party2) do
			pbSceneStandby do
				decision = battle.pbStartBattle
			end
			pbAfterBattle(decision,true)
		end
		Input.update
	when 1 #Trainer battle
		pbBattleAnimation(pbGetTrainerBattleBGM(battle.party2), battle.singleBattle? ? 1 : 3, battle.party2) do
            pbSceneStandby do
                decision = battle.pbStartBattle
            end
            pbAfterBattle(decision, true)
        end
		Input.update
	when 2 #Avatar battle
		pbBattleAnimation(pbGetAvatarBattleBGM(battle.party2), (foeParty.length == 1) ? 0 : 2, battle.party2) do
            pbSceneStandby do
                decision = battle.pbStartBattle
            end
            pbAfterBattle(decision, true)
        end
		Input.update
	else
		raise _INTL("Recorded battle has an invalid battle type. ({1})", battle.type)
	end
	setLevelCap(original_level_cap, false)
end

