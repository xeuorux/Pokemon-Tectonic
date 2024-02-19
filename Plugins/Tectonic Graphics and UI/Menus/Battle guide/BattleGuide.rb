def showBattleGuide
	listIndex = 0
	loop do
		id, listIndex = pbListScreenGuide(_INTL("Battle Guide"), BattleGuideLister.new(battleGuideMainHash, listIndex))
		break if id.nil?
		case listIndex
		when 0
			pbListScreenGuide(_INTL("Battle Strategy"), BattleGuideLister.new(battleGuideBasicsHash), false)
		when 1
			pbListScreenGuide(_INTL("Acquiring Pokémon"), BattleGuideLister.new(battleGuideAquiringPokemonHash), false)
		when 2
			pbListScreenGuide(_INTL("Moves"), BattleGuideLister.new(battleGuideMovesHash), false)
		when 3
			pbListScreenGuide(_INTL("Type Matchups"), BattleGuideLister.new(battleGuideTypeMatchupsHash), false)
        when 4
			pbListScreenGuide(_INTL("Type Chart"), BattleGuideLister.new(battleGuideTypeChartHash), false)
		when 5
			pbListScreenGuide(_INTL("Stats"), BattleGuideLister.new(battleGuideStatsHash), false)
		when 6
			pbListScreenGuide(_INTL("Abilities"), BattleGuideLister.new(battleGuideAbilitiesHash), false)
		when 7
			pbListScreenGuide(_INTL("Held Items"), BattleGuideLister.new(battleGuideHeldItemsHash), false)
		when 8
			pbListScreenGuide(_INTL("Status Conditions"), BattleGuideLister.new(battleGuideStatusConditionsHash), false)
		when 9
			pbListScreenGuide(_INTL("Trainers"), BattleGuideLister.new(battleGuideTrainersHash), false)
		when 10
			pbListScreenGuide(_INTL("Avatars"), BattleGuideLister.new(battleGuideAvatarsHash), false)
		when 11
			pbListScreenGuide(_INTL("MasterDex"), BattleGuideLister.new(battleGuideMasterdexHash), false)
		when 12
			pbListScreenGuide(_INTL("Weathers"), BattleGuideLister.new(battleGuideWeathersHash), false)
		when 13
			pbListScreenGuide(_INTL("Tribes"), BattleGuideLister.new(battleGuideTribesHash), false)
		else
			break
		end
	end
end