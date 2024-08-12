BADGE_NAMES = [
		"Loyalty",
		"Perseverance",
		"Patience",
		"Reverence",
		"Solidarity",
		"Clarity",
		"Generosity",
		"Mercy"
	]
TOTAL_BADGES = 8
BADGE_COUNT_VARIABLE = 27

# Trigger params are badgeEarned, badgeCount, newLevelCap
module Events
	@@OnBadgeEarned = Event.new
	
	# e[0] is badge number earned, starting at 0
	# e[1] is total badges earned
	# e[2] is an array of size TOTAL_BADGES with false or true for whether has each badge in order
	# e[3] is the intended level cap after earning this badge
	def self.onBadgeEarned;     @@OnBadgeEarned;     end
	def self.onBadgeEarned=(v); @@OnBadgeEarned = v; end
end

def earnBadge(badgeNum)
	if badgeNum > TOTAL_BADGES
		raise _INTL("Badge Number #{badgeNum} is above the total number of badges.")
	end

	name = BADGE_NAMES[badgeNum-1]
	pbMessage(_INTL("\\db[Pictures/Trainer Card/DISPLAY_BADGE_{1}]\\me[Badge get]You've earned the {2} Badge!\\wtnp[120]",badgeNum,name))
	$Trainer.badges[badgeNum-1] = true
	$game_switches[3+badgeNum] = true # "Defeated Gym X" switch
	
	badgesEarnedArray = []
	$Trainer.badges.each_with_index do |hasBadge,index|
		break if index >= TOTAL_BADGES
		badgesEarnedArray.push(hasBadge)
	end

	updateTotalBadgesVar
	
	Events.onBadgeEarned.trigger(self,badgeNum-1,$game_variables[BADGE_COUNT_VARIABLE],badgesEarnedArray)
	
	giveBattleReport

	postBattleTeamSnapshot(_INTL("Badge #{badgeNum} Team"),true)
	
	refreshMapEvents
end

def postBattleTeamSnapshot(label=nil,curseMatters=false)
	snapshotFlags = []
	snapshotFlags.push("perfect") if battlePerfected?
	snapshotFlags.push("cursed") if curseMatters && tarotAmuletActive?
	teamSnapshot(label,snapshotFlags)
end

def teamSnapshot(label=nil,flags=[])
	makeBackupSave
	return if $PokemonSystem.party_snapshots == 1
	pbMessage(_INTL("\\wmTaking team snapshot."))
	PokemonPartyShowcase_Scene.new($Trainer,snapshot: true,snapShotName: label,flags: flags)
end

def updateTotalBadgesVar
	totalBadges = 0
	$Trainer.badges.each_with_index do |hasBadge,index|
		break if index >= TOTAL_BADGES
		totalBadges += 1 if hasBadge
	end

	# Update the total badge count
	$game_variables[BADGE_COUNT_VARIABLE] = totalBadges
end

def giveBattleReport()
	pbMessage(_INTL("\\i[PERFORMANCEANALYZER]The Performance Analyzer whirs, then begins printing."))
	pbReceiveItem(:BATTLEREPORT)
end

def doubleBattleBenceZoe()
	return pbDoubleTrainerBattleCursed([[:LEADER_Zoe,"Zoé",0],[:LEADER_Bence,"Bence",0]],[[:LEADER_Zoe,"Zoé",1],[:LEADER_Bence,"Bence",1]])
end

def hasFirstFourBadges?()
	return $game_switches[4] && $game_switches[5] && $game_switches[6] && $game_switches[7]
end

def hasAllEightBadges?()
	return $game_switches[4] && $game_switches[5] && $game_switches[6] && $game_switches[7] &&
		$game_switches[8] && $game_switches[9] && $game_switches[10] && $game_switches[11]
end

def hasAllBadgesUpTo?(badgeNumber) # Index at 1
	for i in 4..(badgeNumber+3) do
		return false unless $game_switches[i]
	end
	return true
end

def hasBadge?(badgeNumber) # Index at 1
	return $game_switches[3 + badgeNumber]
end

def getBadgeCount
	return getGlobalVariable(BADGE_COUNT_VARIABLE)
end

def has6Badges?
	return getBadgeCount >= 6
end

def has7Badges?
	return getBadgeCount >= 7
end

def has8Badges?
	return getBadgeCount >= 8
end

def endGymChoice()
	pbTrainerEnd
	command_end
end