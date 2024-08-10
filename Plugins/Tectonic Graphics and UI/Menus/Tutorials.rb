def playWildEXPTutorial
    $PokemonGlobal.noWildEXPTutorialized = true
    tutorialMessages = 
    [
        _INTL("Wild Pokemon don't give experience in Pokemon Tectonic."),
        _INTL("Don't worry, there's an abundance of experience to gain in other ways."),
        _INTL("If you encounter a Pokemon you don't want, run away. It's guaranteed!")
    ]
    playTutorial(tutorialMessages)
end

def playRespawningTutorial
    tutorialMessages = 
    [
        _INTL("After a full party heal, defeated enemy trainers will be battle ready again!"),
        _INTL("For example, healing at a Pokemon Center triggers this."),
        _INTL("Trainers who fled won't come back, however.")
    ]
    playTutorial(tutorialMessages)
end

def playBicycleShortcutTutorial
    tutorialMessages = 
    [
        _INTL("There's a shortcut key to instantly mount the bicycle while walking."),
        _INTL("Access your control setttings with <imp>F1</imp> to customize it.")
    ]
    playTutorial(tutorialMessages)
end

def playTraitsTutorial
    $PokemonGlobal.traitsTutorialized = true
    tutorialMessages = 
    [
        _INTL("Individual Pokemon have unique Traits, Likes, and Dislikes."),
        _INTL("These have no effect on battle. They're just for fun!"),
        _INTL("To customize your stats, adjust Style Points in any PokeCenter.")
    ]
    playTutorial(tutorialMessages)
end

def playStatStepsTutorial
    $PokemonGlobal.statStepsTutorialized = true
    tutorialMessages = 
    [
        _INTL("Stats can be changed during battle by 'stat steps'."),
        _INTL("A step is a small change! At +1 steps, only 25% is added to the stat."),
        _INTL("Check the Info menu to see the active steps and their effects on the battlers.")
    ]
    playTutorial(tutorialMessages)
end

def playCustomSpeedTutorial
    $PokemonGlobal.customSpeedTutorialized = true
    tutorialMessages = 
    [
        _INTL("Tectonic introduced many options that let you customize the game speed, especially in battles."),
        _INTL("Make sure to go over all the options to determine what you want to enable.")
    ]
    playTutorial(tutorialMessages)
end

def playMoveInfoPanelTutorial
    $PokemonGlobal.moveInfoPanelTutorialized = true
    tutorialMessages = 
    [
        _INTL("Want to learn about your active battler's moves?"),
        _INTL("Activate the Move Info Panel! It's a feature of the Fight screen."),
        _INTL("Press your \"Action\" key (Z/Shift by default) to toggle it on or off.")
    ]
    playTutorial(tutorialMessages)
end

def playTypeChartChangesTutorial
    $PokemonGlobal.typeChartChangesTutorialized = true
    tutorialMessages = 
    [
        _INTL("Many type matchups were changed in Pokemon Tectonic."),
        _INTL("To strengthen some types, we had to weaken others."),
        _INTL("Check the Masterdex or the Battle Guide to learn these changes.")
    ]
    playTutorial(tutorialMessages)
end

def evolutionButtonCheck(pkmn)
    return if $PokemonGlobal.evolutionButtonTutorialized
    return unless pkmn.level == getLevelCap
    return unless pkmn.check_evolution_on_level_up(false)
    playEvolutionButtonTutorial
end

def playEvolutionButtonTutorial
    $PokemonGlobal.evolutionButtonTutorialized = true
    tutorialMessages = 
    [
        _INTL("Sometimes you will receive evolvable Pokémon at your level cap."),
        _INTL("Does this mean you can't evolve them until later? No!"),
        _INTL("Just press the Evolve button in your party screen.")
    ]
    playTutorial(tutorialMessages)
end

def playMentorshipTutorial
    $PokemonGlobal.mentorMovesTutorialized = true
    tutorialMessages = 
    [
        _INTL("Catching and raising lots of Pokémon is useful for Mentoring."),
        _INTL("Mentoring lets you copy moves between your Pokémon!"),
        _INTL("Just talk to the Mentor Coordinator in any PokéCenter."),
    ]
    playTutorial(tutorialMessages)
end

def playAdaptiveMovesTutorial
    $PokemonGlobal.adaptiveMovesTutorialized = true
    tutorialMessages = 
    [
        _INTL("Some moves are both Physical and Special! These are \"Adaptive\" moves."),
        _INTL("They change based on the user's stats!"),
        _INTL("Physical if Attack is higher, and Special if Sp. Atk is higher."),
    ]
    playTutorial(tutorialMessages)
end

def playPokecenterNPCsTutorial
    playTutorialMessage(_INTL("Every PokéCenter and every Ranger Station will contain the 3 Team Customization NPCs."))
    playTutorialMessage(_INTL("Speak to them to learn how they can upgrade your team!"))
end

def tutorialIntro
    pbBGMFade(1.0)
    pbWait(Graphics.frame_rate)
    pbSEPlay("Voltorb Flip tile",150,100)
end

def tutorialsEnabled?
    return $PokemonSystem.tutorial_popups != 1
end

def playTutorial(tutorialMessages = [])
    unless tutorialsEnabled?
        echoln("Skipping tutorial popup due to toggled setting.")
        return
    end
    currentBGM = $game_system.playing_bgm
    tutorialIntro
    tutorialMessages.each do |tutorialMessage|
        playTutorialMessage(tutorialMessage)
    end
    pbBGMPlay(currentBGM)
end

def playTutorialMessage(tutorialMessage)
    pbMessage(_INTL("\\wm#{tutorialMessage}\\wtnp[#{tutorialMessageDuration}]\1"))
end

def tutorialMessageDuration
	dur = 90
	dur -= 10 * $PokemonSystem.textspeed
	return dur
end