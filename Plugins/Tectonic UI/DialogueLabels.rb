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

# Former champions
SCILLA = _INTL("Scilla")
CASEY = _INTL("Casey")
CHARA = _INTL("Chara")
ELISE = _INTL("Elise")
VINCENT = _INTL("Vincent")
PRAVEEN = _INTL("Praveen")
ANSEL = _INTL("Ansel")

# Other
CARETAKER = _INTL("Valentina")

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
end

def speakerNameWindowVisible?
    return $SpeakerNameWindow&.visible
end

def hideSpeaker
    $SpeakerNameWindow.visible = false if $SpeakerNameWindow
end

def showSpeaker
    $SpeakerNameWindow.visible = true if $SpeakerNameWindow
end

def removeSpeaker
    $SpeakerNameWindow.dispose if $SpeakerNameWindow
    $SpeakerNameWindow = nil
end