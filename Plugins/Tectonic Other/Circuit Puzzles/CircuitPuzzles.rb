def circuitPuzzle(circuitPuzzleID)
    circuitDefinition = CIRCUIT_PUZZLES[circuitPuzzleID]
    if circuitDefinition
        pbFadeOutIn {
            scene = CircuitPuzzle_Scene.new(circuitDefinition)
            screen = CircuitPuzzle_Screen.new(scene)
            ret = screen.startPuzzle
        }
    else
        pbMessageDisplay(_INTL("Circuit puzzle with ID #{circuitPuzzleID} not found. Aborting."))
    end
end

class CircuitPuzzle_Scene
    def initialize(circuitDefinition)
        @sprites = {}
        @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
        @viewport.z = 99999

        backgroundFileName = "Circuit Puzzle/Boards/#{circuitDefinition[:base_graphic]}"
        addBackgroundPlane(@sprites, "bg", backgroundFileName, @viewport)
        @sprites["bg"].zoom_x = 4
        @sprites["bg"].zoom_y = 4
    end

    # End the scene here
    def endScene
        pbFadeOutAndHide(@sprites) { update }
        pbDisposeSpriteHash(@sprites)
        # DISPOSE OF BITMAPS HERE #
    end

    def update
        pbUpdateSpriteHash(@sprites)
    end
end

class CircuitPuzzle_Screen
    def initialize(scene)
        @scene = scene
    end
    
    def startPuzzle
        @currentState = 0
        loop do
            Graphics.update
            Input.update
            update
            if Input.trigger?(Input::BACK)
                endScene
                pbPlayCloseMenuSE
                return @currentState
            end
        end
    end

    def endScene
        @scene.endScene
    end

    def update
        @scene.update
    end
end

class CircuitPuzzleStateTracker
end

class PokemonGlobalMetadata
    def circuitPuzzleStateTracker
        @circuitPuzzleStateTracker = CircuitPuzzleStateTracker.new if @circuitPuzzleStateTracker.nil?
        return @circuitPuzzleStateTracker
    end
end

def circuitState
    return $PokemonGlobal.circuitPuzzleStateTracker
end