class PokemonGlobalMetadata
    attr_writer :noWildEXPTutorialized

    def noWildEXPTutorialized
        @noWildEXPTutorialized = false if @noWildEXPTutorialized.nil?
        return @noWildEXPTutorialized
    end

    attr_writer :traitsTutorialized

    def traitsTutorialized
        @traitsTutorialized = false if @traitsTutorialized.nil?
        return @traitsTutorialized
    end
    
    attr_writer :statStepsTutorialized

    def statStepsTutorialized
        @statStepsTutorialized = false if @statStepsTutorialized.nil?
        return @statStepsTutorialized
    end

    attr_writer :customSpeedTutorialized

    def customSpeedTutorialized
        @customSpeedTutorialized = false if @customSpeedTutorialized.nil?
        return @customSpeedTutorialized
    end

    attr_writer :moveInfoPanelTutorialized

    def moveInfoPanelTutorialized
        @moveInfoPanelTutorialized = false if @moveInfoPanelTutorialized.nil?
        return @moveInfoPanelTutorialized
    end
    
    attr_writer :typeChartChangesTutorialized
    def typeChartChangesTutorialized
        @typeChartChangesTutorialized = false if @daycareEggSteps.nil?
        return @typeChartChangesTutorialized
    end
end

def playWildEXPTutorial
    $PokemonGlobal.noWildEXPTutorialized = true
    playTutorial { |messageWait|
        pbMessage(_INTL("\\wmWild Pokemon don't give experience in Pokemon Tectonic.\\wtnp[#{messageWait}]\1"))
        pbMessage(_INTL("\\wmDon't worry, there's an abundance of experience to gain in other ways.\\wtnp[#{messageWait}]\1"))
        pbMessage(_INTL("\\wmIf you encounter a Pokemon you don't want, run away. It's guaranteed!\\wtnp[#{messageWait}]\1"))
    }
end

def playRespawningTutorial
    playTutorial { |messageWait|
        pbMessage(_INTL("\\wmAfter a full party heal, defeated enemy trainers will be battle ready again!\\wtnp[#{messageWait}]\1"))
        pbMessage(_INTL("\\wmFor example, healing at a Pokemon Center triggers this.\\wtnp[#{messageWait}]\1"))
        pbMessage(_INTL("\\wmTrainers who fled won't come back, however.\\wtnp[#{messageWait}]\1"))
    }
end

def playBicycleShortcutTutorial
    playTutorial { |messageWait|
        pbMessage(_INTL("\\wmThere's a shortcut key to instantly mount the bicycle while walking.\\wtnp[#{messageWait}]\1"))
        pbMessage(_INTL("\\wmAccess your control setttings with <imp>F1</imp> to customize it.\\wtnp[#{messageWait}]\1"))
    }
end

def playTraitsTutorial
    $PokemonGlobal.traitsTutorialized = true
    playTutorial { |messageWait|
        pbMessage(_INTL("\\wmIndividual Pokemon have unique Traits, Likes, and Dislikes.\\wtnp[#{messageWait}]\1"))
        pbMessage(_INTL("\\wmThese have no effect on battle. They're just for fun!\\wtnp[#{messageWait}]\1"))
        pbMessage(_INTL("\\wmTo customize your stats, adjust Style Points in any PokeCenter.\\wtnp[#{messageWait}]\1"))
    }
end

def playStatStepsTutorial
    $PokemonGlobal.statStepsTutorialized = true
    playTutorial { |messageWait|
        pbMessage(_INTL("\\wmStats can be changed during battle by 'stat steps'.\\wtnp[#{messageWait}]\1"))
        pbMessage(_INTL("\\wmA step is a small change! At +1 steps, only 25%% is added to the stat.\\wtnp[#{messageWait}]\1"))
        pbMessage(_INTL("\\wmCheck the Info menu to see the active steps and their effects on the battlers.\\wtnp[#{messageWait}]\1"))
    }
end

def playCustomSpeedTutorial
    $PokemonGlobal.customSpeedTutorialized = true
    playTutorial { |messageWait|
        pbMessage(_INTL("\\wmTectonic introduced many options that let you customize the game speed, especially in battles.\\wtnp[#{messageWait}]\1"))
        pbMessage(_INTL("\\wmMake sure to go over all the options to determine what you want to enable.\\wtnp[#{messageWait}]\1"))
    }
end

def playMoveInfoPanelTutorial
    $PokemonGlobal.moveInfoPanelTutorialized = true
    playTutorial { |messageWait|
        pbMessage(_INTL("\\wmWant to learn about your active battler's moves?\\wtnp[#{messageWait}]\1"))
        pbMessage(_INTL("\\wmActivate the Move Info Panel! It's a feature of the Fight screen.\\wtnp[#{messageWait}]\1"))
        pbMessage(_INTL("\\wmPress your \"Action\" key (Z/Shift by default) to toggle it on or off.\\wtnp[#{messageWait}]\1"))
    }
end

def playTypeChartChangesTutorial
    $PokemonGlobal.typeChartChangesTutorialized = true
    playTutorial { |messageWait|
        pbMessage(_INTL("\\wmMany type matchups were changed in Pokemon Tectonic.\\wtnp[#{messageWait}]\1"))
        pbMessage(_INTL("\\wmTo strengthen some types, we had to weaken others.\\wtnp[#{messageWait}]\1"))
        pbMessage(_INTL("\\wmCheck the Masterdex or the Battle Guide to learn these changes.\\wtnp[#{messageWait}]\1"))
    }
end

def tutorialIntro
    pbBGMFade(1.0)
    pbWait(Graphics.frame_rate)
    pbSEPlay("Voltorb Flip tile",150,100)
end

def playTutorial
    if $PokemonSystem.tutorial_popups == 1
        echoln("Skipping tutorial popup due to toggled setting.")
        return
    end
    currentBGM = $game_system.playing_bgm
    tutorialIntro
    yield tutorialMessageDuration if block_given?
    pbBGMPlay(currentBGM)
end

def tutorialMessageDuration
	dur = 90
	dur -= 10 * $PokemonSystem.textspeed
	return dur
end