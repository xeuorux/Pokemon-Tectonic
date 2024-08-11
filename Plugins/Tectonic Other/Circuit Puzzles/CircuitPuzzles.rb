def circuitPuzzle(circuitPuzzleID)
    circuitDefinition = CIRCUIT_PUZZLES[circuitPuzzleID]
    if circuitDefinition
        circuitBaseGraphic = circuitDefinition[:base_graphic]
        pbSEPlay("Circuit puzzle load")
        ret = nil
        pbFadeOutIn {
            scene = CircuitPuzzle_Scene.new(circuitBaseGraphic)
            screen = CircuitPuzzle_Screen.new(scene,circuitDefinition,circuitPuzzleID)
            ret = screen.startPuzzle
        }
        return ret
    else
        pbMessageDisplay(_INTL("Circuit puzzle with ID #{circuitPuzzleID} not found. Aborting."))
    end
end

class CircuitPuzzle_Scene
    # A hash
    # Keys are [ComponentType,ComponentUniqueID]
    # Values are sprites
    attr_reader :componentSprites
    attr_reader :cursorX
    attr_reader :cursorY

    def initialize(circuitBaseGraphic)
        @sprites = {}
        @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
        @viewport.z = 99999

        backgroundFileName = "Circuit Puzzle/Boards/#{circuitBaseGraphic}"
        addBackgroundPlane(@sprites, "bg", backgroundFileName, @viewport)
        @sprites["bg"].zoom_x = 4
        @sprites["bg"].zoom_y = 4
        @componentSprites = []

        # Initialize the bitmaps for all possible components
        @componentBitmaps = {}
        CIRCUIT_COMPONENTS.each do |key,value|
            fileName = "Graphics/Pictures/Circuit Puzzle/Components/#{value[:graphic]}"
            componentBitmap = AnimatedBitmap.new(fileName)
            @componentBitmaps[key] = componentBitmap
        end

        @sprites["cursor"] = AnimatedSprite.create("Graphics/Pictures/Town Map/mapCursor",2,5)
        @sprites["cursor"].viewport = @viewport
        @sprites["cursor"].play
        @sprites["cursor"].zoom_x = 2
        @sprites["cursor"].zoom_y = 2
        @sprites["cursor"].z = 10
        @cursorX = 0
        @cursorY = 0
    end

    def addCircuitComponents(circuitDefinition)
        circuitDefinition[:interactables].each do |circuitComponentDefinition|
            componentID = circuitComponentDefinition[0]
            componentX = circuitComponentDefinition[1]
            componentY = circuitComponentDefinition[2]
            defaultState = circuitComponentDefinition[3]
            
            componentBitmap = @componentBitmaps[componentID]
            newSprite = SpriteWrapper.new
            newSprite.bitmap = componentBitmap.bitmap
            newSprite.viewport = @viewport
            newSprite.x = componentX * 64 + 8
            newSprite.y = componentY * 64 + 8
            newSprite.src_rect.height = 12
            newSprite.src_rect.y = defaultState * 12
            newSprite.zoom_x = 4
            newSprite.zoom_y = 4
            @sprites["component_#{componentSprites.size}"] = newSprite
            componentSprites.push(newSprite)
        end
    end

    def cursorX=(value)
        @cursorX = value
        @sprites["cursor"].x = value * 64
    end

    def cursorY=(value)
        @cursorY = value
        @sprites["cursor"].y = value * 64
    end

    def updateComponentState(componentIndex,state)
        componentSprites[componentIndex].src_rect.y = state * 12
    end

    # End the scene here
    def endScene
        pbFadeOutAndHide(@sprites) { update }
        pbDisposeSpriteHash(@sprites)
        # DISPOSE OF BITMAPS HERE #
        @componentBitmaps.each do |key,value|
            value.dispose unless value.disposed?
        end
    end

    def update
        pbUpdateSpriteHash(@sprites)
    end
end

class CircuitComponent
    attr_reader :componentID
    attr_accessor :state
    attr_reader :x
    attr_reader :y

    def initialize(componentID,x,y)
        @x = x
        @y = y
        componentDefinition = CIRCUIT_COMPONENTS[componentID]
        @state = 0
        @legalStates = componentDefinition[:states]
    end

    def cycleState
        @state += 1
        @state = 0 if @state >= @legalStates
    end
end

class CircuitPuzzle_Screen
    def initialize(scene,circuitDefinition,puzzleID)
        @scene = scene
        @puzzleID = puzzleID
        @circuitDefinition = circuitDefinition
        @components = []
        @cursorX = 3
        @cursorY = 3
        @inSolutionState = false
        @inLegalState = true

        loadPuzzleComponents
        loadCircuitState
        detectLegalState
        unless @inLegalState
            pbMessageDisplay(_INTL("Circuit puzzle with ID #{circuitPuzzleID} somehow loaded in illegal state."))
        end
    end

    def loadPuzzleComponents
        @scene.addCircuitComponents(@circuitDefinition)

        @circuitDefinition[:interactables].each do |circuitComponentDefinition|
            componentID = circuitComponentDefinition[0]
            componentX = circuitComponentDefinition[1]
            componentY = circuitComponentDefinition[2]
            defaultState = circuitComponentDefinition[3]

            newComponent = CircuitComponent.new(componentID,componentX,componentY)
            newComponent.state = defaultState || 0
            @components.push(newComponent)
        end
    end

    def loadCircuitState
        tracker = $PokemonGlobal.circuitPuzzleStateTracker
        savedComponentStates = tracker.loadPuzzleState(@puzzleID)
        @components.each_with_index do |component,index|
            component.state = savedComponentStates[index]
            @scene.updateComponentState(index,component.state)
        end
    end

    def saveCircuitState
        tracker = $PokemonGlobal.circuitPuzzleStateTracker
        puzzleState = []
        @components.each do |component|
            puzzleState.push(component.state)
        end
        tracker.savePuzzleState(@puzzleID,puzzleState)
    end
    
    def startPuzzle
        Graphics.update
        Input.update
        detectSolution
        loop do
            Graphics.update
            Input.update
            update
            if Input.trigger?(Input::BACK)
                if @inLegalState
                    saveCircuitState
                    endScene
                    pbPlayCloseMenuSE
                    return @inSolutionState
                else
                    pbMessageDisplay(_INTL("The circuit is in an illegal state! You can't leave it like this."))
                end
            elsif Input.trigger?(Input::USE)
                if cursorInteract
                    pbPlayDecisionSE
                    detectLegalState
                    detectSolution
                else
                    pbPlayBuzzerSE
                end
            elsif Input.trigger?(Input::UP)
                if @scene.cursorY <= 0
                    pbPlayBuzzerSE
                    next
                end
                @cursorY -= 1
                pbPlayCursorSE
            elsif Input.trigger?(Input::DOWN)
                if @scene.cursorY >= 5
                    pbPlayBuzzerSE
                    next
                end
                @cursorY += 1
                pbPlayCursorSE
            elsif Input.trigger?(Input::LEFT)
                if @scene.cursorX <= 0
                    pbPlayBuzzerSE
                    next
                end
                @cursorX -= 1
                pbPlayCursorSE
            elsif Input.trigger?(Input::RIGHT)
                if @scene.cursorX >= 7
                    pbPlayBuzzerSE
                    next
                end
                @cursorX += 1
                pbPlayCursorSE
            elsif Input.triggerex?(:P) && $DEBUG
                @components.each_with_index do |component,index|
                    echoln("Component #{index} is in state #{component.state}")
                end
            end

            @scene.cursorX = @cursorX
            @scene.cursorY = @cursorY
        end
    end

    def detectLegalState
        @inLegalState = false
        if @circuitDefinition[:legal_states].nil?
            @inLegalState = true
        else
            @circuitDefinition[:legal_states].each do |legalState|
                thisLegalMatches = true
                @components.each_with_index do |component,index|
                    legalStateForComponent = legalState[index]
                    next if component.state == legalStateForComponent
                    thisLegalMatches = false
                    break
                end
                if thisLegalMatches
                    @inLegalState = true
                    break
                end
            end
        end
    end

    def detectSolution
        @inSolutionState = false
        @circuitDefinition[:solution_states].each do |possibleSolution|
            thisSolutionWorks = true
            @components.each_with_index do |component,index|
                solutionStateForComponent = possibleSolution[index]
                next if component.state == solutionStateForComponent
                thisSolutionWorks = false
                break
            end
            if thisSolutionWorks
                @inSolutionState = true
                break
            end
        end
        if @inSolutionState
            pbWait(20)
            pbSEPlay("Mining found all",100,80)
        end
    end

    def cursorInteract
        return false if @inSolutionState
        @components.each_with_index do |component,index|
            next unless component.x == @cursorX
            next unless component.y == @cursorY
            component.cycleState
            pbSEPlay("Anim/Paralyze1")
            @scene.updateComponentState(index,component.state)
            return true
        end
        return false
    end

    def endScene
        @scene.endScene
    end

    def update
        @scene.update
    end
end
class CircuitPuzzleStateTracker
    def initialize
        @puzzleStateData = {}
    end

    def loadPuzzleState(puzzleID)
        if @puzzleStateData.key?(puzzleID)
            return @puzzleStateData[puzzleID]
        else
            newPuzzleState = []
            circuitDefinition = CIRCUIT_PUZZLES[puzzleID]
            circuitDefinition[:interactables].each do |interactableDefinition|
                newPuzzleState.push(interactableDefinition[3])
            end
            @puzzleStateData[puzzleID] = newPuzzleState
            return newPuzzleState
        end
    end
    
    def savePuzzleState(puzzleID,puzzleState)
        @puzzleStateData[puzzleID] = puzzleState
    end
end

def circuitState
    return $PokemonGlobal.circuitPuzzleStateTracker
end