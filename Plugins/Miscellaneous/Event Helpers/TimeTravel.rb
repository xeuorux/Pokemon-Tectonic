PRESENT_TONE = Tone.new(0,0,0,0)
PAST_TONE = Tone.new(40,30,10,130)

def getTimeTone
    if $game_switches[78] # Time Traveling
        $game_screen.start_tone_change(PAST_TONE, 0)
    else
        $game_screen.start_tone_change(PRESENT_TONE, 0)
    end
end

def toggleTimeTravel
    $game_switches[78] = !$game_switches[78]
end

def timeTravelToEvent(eventID)
    goingForwards = $game_switches[78]
    pbSEPlay("Anim/Sand",70,80)
    pbSEPlay("Anim/Sand",40,65)
    pbWait(10)
    if goingForwards
        pbSEPlay("Anim/PRSFX- Roar of Time2",20,200)
    else
        pbSEPlay("Anim/PRSFX- Roar of Time2",20,200)
    end
    $game_screen.start_tone_change(Tone.new(230,230,230,255), 20)
	pbWait(20)
    toggleTimeTravel
    transferPlayerToEvent(eventID)
    $game_screen.start_tone_change(getTimeTone, 20)
	pbWait(20)
end