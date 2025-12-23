ItemHandlers::UseFromBag.add(:SMARTPHONE, proc { |item|
	choice = pbMessage(_INTL("Open which app?"), [_INTL("Camera"), _INTL("VS Recorder"),], -1)
	next 2 if choice == 0

	if $current_save_file_name.nil?
		pbMessage(_INTL("The VS Recorder buzzes erratically. Save your progress to make it work properly."))
		next 0
	end
	save_file_name = $current_save_file_name.split("/")[1].delete_suffix(".rxdata")
	if Dir["./VSRecorder/#{save_file_name}/*.dat"].size < 1
		pbMessage(_INTL("You don't have any battles recorded on your VS Recorder."))
		next 0
	end
	choice = pbMessage(_INTL("What do you do?"), [_INTL("Watch battle"), _INTL("Save last battle"), _INTL("Rename battle"), _INTL("Delete battle")], -1)
	case choice
	when 0 # Watch battle
		battle_replay_choice = pbMessage(_INTL("Which battle ?"), getRecordedBattleNames, -1)
		next 0 if battle_replay_choice == -1
		playRecordedBattle(getRecordedBattleNames[battle_replay_choice])
		next 0
	when 1 # Save last battle
		unless File.exists?("./VSRecorder/#{save_file_name}/Last battle.dat")
			pbMessage(_INTL("Your last battle was either saved or not found on your VS Recorder."))
			next 0
		end
		battle_rename = pbEnterText(_INTL("Enter battle name..."), 0, 20)
		next 0 if battle_rename == ""
		File.rename(
			"./VSRecorder/#{save_file_name}/Last battle.dat", 
			"./VSRecorder/#{save_file_name}/#{battle_rename}.dat"
		)
		next 0
	when 2 # Rename battle
		battle_rename_choice = pbMessage(_INTL("Which battle ?"), getRecordedBattleNames, -1)
		next 0 if battle_rename_choice == -1
		battle_rename = pbEnterText(_INTL("Enter battle name..."), 0, 20)
		next 0 if battle_rename == ""
		File.rename(
			Dir["./VSRecorder/#{save_file_name}/*.dat"][battle_rename_choice], 
			"./VSRecorder/#{save_file_name}/#{battle_rename}.dat"
		)
		next 0
	when 3 # Delete battle
		battle_delete_choice = pbMessage(_INTL("Which battle ?"), getRecordedBattleNames, -1)
		next 0 if battle_delete_choice == -1
		next 0 unless (pbMessage(_INTL("Are you sure ? This action is permanent."), ["No", "Yes"]) == 1)
		File.delete(Dir["./VSRecorder/#{save_file_name}/*.dat"][battle_delete_choice])
	else
		next 0
	end
})

def getRecordedBattleNames
	save_file_name = $current_save_file_name.split("/")[1].delete_suffix(".rxdata")
	return Dir["./VSRecorder/#{save_file_name}/*.dat"].map { |path| path.delete_suffix(".dat").delete_prefix("./VSRecorder/#{save_file_name}/") }
end

ItemHandlers::ConfirmUseInField.add(:SMARTPHONE,proc { |item|
  next true
})

ItemHandlers::UseInField.add(:SMARTPHONE,proc { |item|
	next takeSelfie
})