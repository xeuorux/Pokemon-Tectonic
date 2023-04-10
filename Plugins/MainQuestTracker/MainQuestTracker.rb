SaveData.register(:main_quest_tracker) do
	ensure_class :MainQuestTracker
	save_value { $main_quest_tracker }
	load_value { |value| $main_quest_tracker = value }
	new_game_value { MainQuestTracker.new }
end

class MainQuestTracker
	attr_reader :mainQuestState
	
	def initialize()
		@mainQuestState = MAIN_QUEST_STAGES.keys[0]
	end

	def setMainQuestStage(newStage)
		oldStage = @mainQuestState
		newStage = MAIN_QUEST_STAGES.keys[newStage] if newStage.is_a?(Integer)
		if !MAIN_QUEST_STAGES.has_key?(newStage)
			pbMessage("\\wmA recoverable error has occured: #{newStage} is an invalid Main Quest Stage key. The \"What Next?\" will be inaccurate until the next Main Quest update. Please let a programmer know you saw this error, and where.")
			return
		end
		@mainQuestState = newStage

		echoln("Changing the current Main Quest stage from #{oldStage} to #{newStage}")
	end

	def getCurrentStage()
		return @mainQuestState
	end

	def getCurrentStageName()
		return MainQuestTracker.getNiceNameForStageSymbol(@mainQuestState)
	end

	def getCurrentStageHelp()
		return MAIN_QUEST_STAGES[@mainQuestState]
	end

	def self.getNiceNameForStageSymbol(symbol)
		return symbol.to_s.downcase.gsub("_"," ").split(/ |\_/).map(&:capitalize).join(" ")
	end
end

def setMQStage(stageSym)
	$main_quest_tracker.setMainQuestStage(stageSym)
end

def getMQStage()
	return $main_quest_tracker.getCurrentStageName()
end

def progressMQStage(initialStage,nextStage)
	if $main_quest_tracker.getCurrentStage() == initialStage
		$main_quest_tracker.setMainQuestStage(nextStage)
	end
end