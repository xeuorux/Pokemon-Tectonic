def setSpeaker(speakerName,viewport = nil)
    unless $SpeakerNameWindow
        $SpeakerNameWindow = Window_AdvancedTextPokemon.new
        $SpeakerNameWindow.setSkin(MessageConfig.pbGetSpeechFrame)
    end
    $SpeakerNameWindow.text = _INTL(speakerName)
    $SpeakerNameWindow.viewport = viewport
    refreshSpeakerWindow
end

def refreshSpeakerWindow
    return unless $SpeakerNameWindow
    $SpeakerNameWindow.resizeToFit($SpeakerNameWindow.text,Graphics.width)
    $SpeakerNameWindow.width = 160 if $SpeakerNameWindow.width <= 160
    $SpeakerNameWindow.y = Graphics.height - $SpeakerNameWindow.height
    $SpeakerNameWindow.z = 99_999
    $SpeakerNameWindow.visible = false # Starts hidden
end

def setSpeakerTrainer(trainerClass,trainerName)
    begin
        trainerData = GameData::Trainer.get(trainerClass,trainerName)
        trainerTypeData = GameData::TrainerType.get(trainerData.trainer_type)
        setSpeaker("#{trainerTypeData.name} #{trainerData.name}")
    rescue ArgumentError
        echoln("Unable to find dialogue label display name for trainer: #{trainerClass} #{trainerName}")
    end
end

def speakerNameWindowVisible?
    return $SpeakerNameWindow&.visible
end

def hideSpeaker
    return unless $SpeakerNameWindow
    $SpeakerNameWindow.visible = false
end

def showSpeaker
    return unless $SpeakerNameWindow
    $SpeakerNameWindow.visible = true
end

def removeSpeaker
    $SpeakerNameWindow.dispose if $SpeakerNameWindow
    $SpeakerNameWindow = nil
end