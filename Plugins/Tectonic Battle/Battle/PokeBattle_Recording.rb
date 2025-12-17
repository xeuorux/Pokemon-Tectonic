module PokeBattle_BattleRecorder
	
	attr_accessor :type #Battle type. 0 for wild, 1 for trainer, 2 for avatar

	attr_accessor :recorded_choices #Array of the move choices made
	attr_accessor :recorded_switches #Array of switches made
	attr_accessor :random #Array of the random numbers used in the battle
	attr_accessor :random_log

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
	attr_accessor :battle_rules

	def initialize(scene, playerParty, foeParty, playerTrainers, foeTrainers, type)
		super(scene, playerParty, foeParty, playerTrainers, foeTrainers)
		@recorded_choices = []
		@recorded_switches = []
		@random = []
		@random_log = []
		@is_recorded = true
		@save_battle = true
		@type = type
	end

	def pbRandom(x)
		ret = rand(x)
		@random.push(ret)
		@random_log.push("#{ret.to_s}\n#{caller.to_s}\n")
		return ret
	end

	def recordChoices
		@choices.each_with_index do |c, i|
			c_clone = c.clone
			c_clone[2] = nil #Remove move object (not parsable)
			@recorded_choices[@turnCount][i].push(c_clone)
		end
	end

	def pbCommandPhase
		echoln("===TURN " + @turnCount.to_s + " COMMAND===")
		@recorded_choices.push([]) #Add turn array
    (maxBattlerIndex + 1).times { |i| @recorded_choices[@turnCount].push([])} #Add array for each battler
		super
		recordChoices
		echoln(@choices.to_s)
  end

	def pbExtraCommandPhase
		super
		recordChoices
	end

	def pbStartBattle
		@player_info                  = Marshal.dump(@player)
		@opponent_info                = Marshal.dump(@opponent)
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
		saveRandomLog(@save_battle ? "random_record.txt" : "random_replay.txt")
		super
	end

	def pbSwitchInBetween(idxBattler, checkLaxOnly: false, canCancel: false, safeSwitch: nil)
		if pbOwnedByPlayer?(idxBattler) && !@autoTesting && !@controlPlayer
			ret = pbPartyScreen(idxBattler, checkLaxOnly, canCancel) 
			@recorded_switches.push(ret)
			return ret
		else
			return @battleAI.pbDefaultChooseNewEnemy(idxBattler, safeSwitch)
		end
	end

	def registerLastChoice(index)
		@recorded_choices[@turnCount][index][@commandPhasesThisRound-1].push(@last_choice)
	end

	def registerRules
		@battle_rules = $PokemonTemp.battleRules.clone
	end

	def getBattleData
		return Marshal.dump({
			:type => @type,
			:recorded_choices => @recorded_choices,
			:recorded_switches => @recorded_switches,
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
			:rules => Marshal.dump(@battle_rules),
			:endSpeeches => (@endSpeeches) ? @endSpeeches.clone : "",
			:endSpeechesWin => (@endSpeechesWin) ? @endSpeechesWin.clone : "",
			:canRun => @canRun,
			:switchStyle => @switchStyle,
			:showAnims => @showAnims,
			:backdrop => @backdrop,
			:backdropBase => @backdropBase,
			:time => @time,
			:environment => @environment,
			:level_cap => getLevelCap
		})
	end

	def saveBattle(name)
		Dir.mkdir("./VSRecorder") unless Dir.exists?("./VSRecorder")
		File.open("./VSRecorder/" + name + ".dat", "wb") { |f| f.write(getBattleData) }
	end

	def saveRandomLog(path)
		File.open("./Analysis/" + path, "wb") { |f| f.write(@random_log.to_s) }
	end
end

module PokeBattle_BattleReplayer
	include PokeBattle_BattleRecorder

	attr_accessor :randomindex
	attr_accessor :level_cap

	def initialize(scene, file_name)
		raise _INTL("Record {1} does not exist", file_name) unless File.exists?("./VSRecorder/" + file_name + ".dat")
		battle = File.open("./VSRecorder/" + file_name + ".dat", "rb") {|f| Marshal.load(f)}
		
		@randomindex               = 0
		@player_info               = Marshal.load(battle[:player_info])
		@opponent_info             = Marshal.load(battle[:opponent_info])
		@player_party              = Marshal.load(battle[:player_party])
		@opponent_party            = Marshal.load(battle[:opponent_party])
		
		Marshal.load(battle[:rules]).each_pair { |rule, val| 
			setBattleRule(rule, val) if rule != "size"
			setBattleRule(val) if rule == "size"
		}
		
		super(scene, @player_party, @opponent_party, @player_info, @opponent_info, battle[:type])
		
		@player_party_starts       = Marshal.load(battle[:player_party_starts])
		@opponent_party_starts     = Marshal.load(battle[:opponent_party_starts])
		@held_items                = Marshal.load(battle[:held_items])
		@starting_weather          = battle[:starting_weather]
		@starting_weather_duration = battle[:starting_weather_duration]
		@endSpeeches               = battle[:endSpeeches]
		@endSpeechesWin            = battle[:endSpeechesWin]
		@canRun                    = battle[:canRun]
		@switchStyle               = battle[:switchStyle]
		@showAnims                 = battle[:showAnims]
		@level_cap                 = battle[:level_cap]
		@recorded_choices          = battle[:recorded_choices]
		@recorded_switches         = battle[:recorded_switches]
		@random                    = battle[:random]
		@save_battle               = false
		@is_replayed               = true
		@is_recorded               = false
		@backdrop                  = battle[:backdrop]
		@backdropBase              = battle[:backdropBase]
		@time                      = battle[:time]
		@environment               = battle[:environment]
		
		@party1starts              = @player_party_starts
		@party2starts              = @opponent_party_starts
		@field.weather             = @starting_weather
		@field.weatherDuration     = @starting_weather_duration
		@items                     = @held_items
		
		@bossBattle = true if battle[:type] == 2

	end

	def pbRandom(x)
		ret = @random[@randomindex]
		@randomindex += 1
		@random_log.push("#{ret.to_s}\n#{caller.to_s}\n")
		return ret
	end

	def pbCommandPhase
		pbCommandPhaseLoop(false)
		@choices = []
		@recorded_choices[@turnCount].each do |c|
			@choices.push(c[0])
			currentBattlerIndex = @choices.length - 1
			if @choices[-1][0] == :UseMove
				if @choices[-1][1] == -1
					@choices[-1][2] = @struggle
				else
					@choices[-1][2] = @battlers[currentBattlerIndex].moves[@choices[-1][1]] #Restore move from index
				end
			elsif @choices[-1][0] == :None && !@battlers[currentBattlerIndex].fainted? #If no action was taken and the battler is able (run/forfeit)
				pbRun(currentBattlerIndex)
			end
		end
  end

	def pbExtraCommandPhase
		pbCommandPhaseLoop(false)
		@choices = []
		@recorded_choices[@turnCount].each do |c|
			@choices.push(c[@commandPhasesThisRound-1])
			if @choices[-1][0] == :UseMove
				if @choices[-1][1] == -1
					@choices[-1][2] = @struggle
				else
					@choices[-1][2] = @battlers[@choices.length-1].moves[@choices[-1][1]]
				end
			end
		end
	end

	def registerNextChoice(index)
		choice = @recorded_choices[@turnCount][index]
		if choice.length < 5
			@next_choice = @recorded_choices[@turnCount][index][4]
		else
			@next_choice = nil
		end
	end

	def pbSwitchInBetween(idxBattler, checkLaxOnly: false, canCancel: false, safeSwitch: nil)
		if pbOwnedByPlayer?(idxBattler) && !@autoTesting && !@controlPlayer
			return @recorded_switches.shift
		else
			return @battleAI.pbDefaultChooseNewEnemy(idxBattler, safeSwitch)
		end
	end

end

class PokeBattle_Battle
	def registerLastChoice(index); end
	def registerNextChoice(index); end
	def registerRules; end
end

class PokeBattle_TectonicRecordedBattle < PokeBattle_Battle
	include PokeBattle_BattleRecorder
end

class PokeBattle_TectonicReplayedBattle < PokeBattle_Battle
	include PokeBattle_BattleReplayer
end

def playRecordedBattle(record_name)
	original_level_cap = getLevelCap
	scene = pbNewBattleScene
	battle = PokeBattle_TectonicReplayedBattle.new(scene, record_name)

	pbPrepareBattle(battle)
	battle.registerRules
  $PokemonTemp.clearBattleRules

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
		pbBattleAnimation(pbGetTrainerBattleBGM(battle.opponent), battle.singleBattle? ? 1 : 3, battle.opponent) do
			pbSceneStandby do
				decision = battle.pbStartBattle
			end
			pbAfterBattle(decision, true)
		end
		Input.update
	when 2 #Avatar battle
		pbBattleAnimation(pbGetAvatarBattleBGM(battle.party2), (battle.party2.length == 1) ? 0 : 2, battle.party2) do
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