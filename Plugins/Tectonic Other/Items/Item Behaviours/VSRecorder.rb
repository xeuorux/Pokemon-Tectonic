ItemHandlers::UseFromBag.add(:VSRECORDER, proc { |item|
  if $current_save_file_name.nil?
		pbMessage(_INTL("The VS Recorder buzzes erratically. Save your progress to make it work properly."))
		next 0
	end

	save_file_name = $current_save_file_name.split("/")[1].delete_suffix(".rxdata")
  records_path = "./VSRecorder/#{save_file_name}"
	if getRecordedBattles.size < 1
		pbMessage(_INTL("You don't have any battles recorded on your VS Recorder."))
		next 0
	end

	choice = pbMessage(_INTL("What do you do?"), 
    [
      _INTL("Watch battle"), 
      _INTL("Save last battle"), 
      _INTL("Rename battle"), 
      _INTL("Delete battle")
    ],-1)
  
	case choice
	when 0 # Watch battle
		battle_replay_choice = pbMessage(_INTL("Which battle ?"), getRecordedBattleNames, -1)
		next 0 if battle_replay_choice == -1
		playRecordedBattle(getRecordedBattleNames[battle_replay_choice])
		next 1

	when 1 # Save last battle
		unless File.exists?("#{records_path}/Last battle.dat")
			pbMessage(_INTL("Your last battle was either saved or not found on your VS Recorder."))
			next 0
		end
		battle_rename = pbEnterText(_INTL("Enter battle name..."), 0, 20)
		next 0 if battle_rename == ""
		File.rename(
			"#{records_path}/Last battle.dat", 
			"#{records_path}/#{battle_rename}.dat"
		)
		pbMessage("Battle successfully saved.")
		next 1

	when 2 # Rename battle
		battle_rename_choice = pbMessage(_INTL("Which battle ?"), getRecordedBattleNames, -1)
		next 0 if battle_rename_choice == -1
		battle_rename = pbEnterText(_INTL("Enter battle name..."), 0, 20)
		next 0 if battle_rename == ""
		File.rename(
			getRecordedBattles[battle_rename_choice], 
			"#{records_path}/#{battle_rename}.dat"
		)
		pbMessage("Battle successfully renamed.")
		next 1

	when 3 # Delete battle
		battle_delete_choice = pbMessage(_INTL("Which battle ?"), getRecordedBattleNames, -1)
		next 0 if battle_delete_choice == -1
		next 0 unless (pbMessage(_INTL("Are you sure ? This action is permanent."), ["No", "Yes"]) == 1)
		File.delete(getRecordedBattles[battle_delete_choice])
    pbMessage("Battle successfully deleted.")
		next 1
	
  else
		next 0
	end
})

def getRecordedBattleNames
	save_file_name = $current_save_file_name.split("/")[1].delete_suffix(".rxdata")
	return getRecordedBattles.map { |path| path.delete_suffix(".dat").delete_prefix("./VSRecorder/#{save_file_name}/") }
end

def getRecordedBattles
  save_file_name = $current_save_file_name.split("/")[1].delete_suffix(".rxdata")
  return Dir["./VSRecorder/#{save_file_name}/*.dat"]
end