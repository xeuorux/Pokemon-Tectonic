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
		newStage = MAIN_QUEST_STAGES.keys[newStage] if newStage.is_a?(Integer)
		if !MAIN_QUEST_STAGES.has_key?(newStage)
			raise _INTL("#{newStage} is an invalid Main Quest Stage key.")
		end
		@mainQuestState = newStage
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