# @deprecated Use {Game.save} instead. pbSave is slated to be removed in v20.
def pbSave(safesave = false)
    Deprecation.warn_method("pbSave", "v20", "Game.save")
    Game.save(safe: safesave)
end

def properlySave
    if $current_save_file_name.nil?
        count = FileSave.count
        SaveData.changeFILEPATH(FileSave.name(count + 1))
        $current_save_file_name = FileSave.name(count + 1)
    end
    setProperSavePath
    return Game.save
end

def pbEmergencySave
    oldscene = $scene
    $scene = nil
    pbMessage(_INTL("The script is taking too long. The game will restart."))
    return unless $Trainer
    # It will store the last save file when you dont file save
    setProperSavePath
    if SaveData.exists?
        File.open(SaveData::FILE_PATH, "rb") do |r|
            File.open(SaveData::FILE_PATH + ".bak", "wb") do |w|
                while s = r.read(4096)
                    w.write s
                end
            end
        end
    end
    if savingAllowed?
        if Game.save
            pbMessage(_INTL("\\se[]The game was saved.\\me[GUI save game]"))
        else
            pbMessage(_INTL("\\se[]Save failed.\\wtnp[30]"))
        end
    end
    pbMessage(_INTL("The previous save file has been backed up.\\wtnp[30]"))
    $scene = oldscene
end

def makeBackupSave
    setProperSavePath
    SaveData.save_backup(SaveData::FILE_PATH)
end

def savingAllowed?
    return true unless GameData::MapMetadata.exists?($game_map.map_id)
    return !GameData::MapMetadata.get($game_map.map_id).saving_blocked
end

def showSaveBlockMessage
    pbMessage(_INTL("Saving is not allowed at the moment."))
end

def setProperSavePath
    SaveData.changeFILEPATH($current_save_file_name.nil? ? FileSave.name : $current_save_file_name)
end

def pbCustomMessageForSave(message, commands, index, &block)
    return pbMessage(message, commands, index, &block)
end