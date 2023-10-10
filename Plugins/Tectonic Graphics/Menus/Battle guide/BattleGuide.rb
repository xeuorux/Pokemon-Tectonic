def showBattleGuide
	listIndex = 0
	loop do
		id, listIndex = pbListScreenExtra(_INTL("Battle Guide"), BattleGuideLister.new(battleGuideMainHash, listIndex))
		break if id.nil?
		case listIndex
		when 0
			pbListScreenExtra(_INTL("Battle Strategy"), BattleGuideLister.new(battleGuideBasicsHash), false)
		when 1
			pbListScreenExtra(_INTL("Acquiring Pokémon"), BattleGuideLister.new(battleGuideAquiringPokemonHash), false)
		when 2
			pbListScreenExtra(_INTL("Moves"), BattleGuideLister.new(battleGuideMovesHash), false)
		when 3
			pbListScreenExtra(_INTL("Type Matchups"), BattleGuideLister.new(battleGuideTypeMatchupsHash), false)
        when 4
			pbListScreenExtra(_INTL("Type Chart"), BattleGuideLister.new(battleGuideTypeChartHash), false)
		when 5
			pbListScreenExtra(_INTL("Stats"), BattleGuideLister.new(battleGuideStatsHash), false)
		when 6
			pbListScreenExtra(_INTL("Abilities"), BattleGuideLister.new(battleGuideAbilitiesHash), false)
		when 7
			pbListScreenExtra(_INTL("Held Items"), BattleGuideLister.new(battleGuideHeldItemsHash), false)
		when 8
			pbListScreenExtra(_INTL("Status Conditions"), BattleGuideLister.new(battleGuideStatusConditionsHash), false)
		when 9
			pbListScreenExtra(_INTL("Trainers"), BattleGuideLister.new(battleGuideTrainersHash), false)
		when 10
			pbListScreenExtra(_INTL("Avatars"), BattleGuideLister.new(battleGuideAvatarsHash), false)
		when 11
			pbListScreenExtra(_INTL("MasterDex"), BattleGuideLister.new(battleGuideMasterdexHash), false)
		when 12
			pbListScreenExtra(_INTL("Weathers"), BattleGuideLister.new(battleGuideWeathersHash), false)
		when 13
			pbListScreenExtra(_INTL("Tribes"), BattleGuideLister.new(battleGuideTribesHash), false)
		else
			break
		end
	end
end