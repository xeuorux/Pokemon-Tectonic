def showBattleGuide
	listIndex = 0
	loop do
		id, listIndex = pbListScreenGuide(_INTL("Battle Guide"), BattleGuideLister.new(battleGuideMainHash, listIndex))
		break if id.nil?

		sectionLabel = battleGuideMainDirectory.keys[listIndex]
		directoryEntry = battleGuideMainDirectory.values[listIndex]
		guideListHash = send directoryEntry[1]
		pbListScreenGuide(+sectionLabel, BattleGuideLister.new(guideListHash), false)
	end
end