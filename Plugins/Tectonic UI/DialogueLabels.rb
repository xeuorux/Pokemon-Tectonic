UNKNOWN = _INTL("???")

# Main characters
TAMARIND = _INTL("Tamarind")
YEZERA = _INTL("Yezera")
ZAIN = _INTL("Zain")

# Recurring NPCs
IMOGENE = _INTL("Imogene")
ALESSA = _INTL("Alessa")
SKYLAR = _INTL("Skylar")
KEONI = _INTL("Keoni")
EIFION = _INTL("Eifion")
CANDY = _INTL("Candy")

# Gym leaders
LAMBERT = _INTL("Lambert")
EKO = _INTL("Eko")
HELENA = _INTL("Helena")
RAFAEL = _INTL("Rafael")
ZOE = _INTL("Zoé")
BENCE = _INTL("Bence")
NOEL = _INTL("Noel")
VICTOIRE = _INTL("Victoire")
SAMORN = _INTL("Samorn")

# Former champions
SCILLA = _INTL("Scilla")
CASEY = _INTL("Casey")
CHARA = _INTL("Chara")
ELISE = _INTL("Elise")
VINCENT = _INTL("Vincent")
PRAVEEN = _INTL("Praveen")
ANSEL = _INTL("Ansel")

# Pro Trainers
XANDER = _INTL("Xander")
JADE = _INTL("Jade")
BLAIRE = _INTL("Blaire")
EMIR = _INTL("Emir")
NYX = _INTL("Nyx")
NERO = _INTL("Nero")

# Other
CARETAKER = _INTL("Valentina")
SANG = _INTL("Sang")
MAVIS = _INTL("Mavis")
LAINIE = _INTL("Lainie")

def setSpeaker(speakerName,viewport = nil)
    unless $SpeakerNameWindow
        $SpeakerNameWindow = Window_AdvancedTextPokemon.new
        $SpeakerNameWindow.setSkin(MessageConfig.pbGetSpeechFrame)
    end
    $SpeakerNameWindow.text = speakerName
    $SpeakerNameWindow.resizeToFit($SpeakerNameWindow.text,Graphics.width)
    $SpeakerNameWindow.width = 160 if $SpeakerNameWindow.width<=160
    $SpeakerNameWindow.y = Graphics.height - $SpeakerNameWindow.height
    $SpeakerNameWindow.viewport = viewport
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

class Game_Event
    def start
        return if @list.size == 0
        @starting = true
        removeSpeaker unless pbMapInterpreter.message_waiting
    end
end