class Pokemon
	def setupStatTracking()
		@trackedStats = {
			"Faint Count" => 0,
			"KO Count" => 0
		}
	end

	def getTrackedStats
		setupStatTracking() if !@trackedStats
		return @trackedStats
	end
	
	def addToTrackedStat(statName)
		setupStatTracking() if !@trackedStats
		if @trackedStats.key?(statName)
			@trackedStats[statName] += 1
		else
			@trackedStats[statName] = 1
		end
	end
	
	def addToFaintCount()
		addToTrackedStat("Faint Count")
	end
	
	def addToKOCount()
		addToTrackedStat("KO Count")
	end
end