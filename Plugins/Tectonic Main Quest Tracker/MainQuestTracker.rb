SaveData.register(:main_quest_tracker) do
	ensure_class :MainQuestTracker
	save_value { $main_quest_tracker }
	load_value { |value| $main_quest_tracker = value }
	new_game_value { MainQuestTracker.new }
end

class MainQuestTracker
	attr_reader :mainQuestState
	
	def initialize()
		@mainQuestState = getMainQuestStages.keys[0]
	end

	def setMainQuestStage(newStage)
		oldStage = @mainQuestState
		newStage = getMainQuestStages.keys[newStage] if newStage.is_a?(Integer)
		if !getMainQuestStages.has_key?(newStage)
			pbMessage(_INTL("\\wmA recoverable error has occured: #{newStage} is an invalid Main Quest Stage key. The \"What Next?\" will be inaccurate until the next Main Quest update. Please let a programmer know you saw this error, and where."))
			return
		end
		@mainQuestState = newStage

		echoln("Changing the current Main Quest stage from #{oldStage} to #{newStage}")
	end

	def getCurrentStage()
		return @mainQuestState
	end

	def getCurrentStageName
		return _INTL(getMainQuestStages[@mainQuestState][0])
	end

	def getCurrentStageHelp
		return _INTL(getMainQuestStages[@mainQuestState][1])
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