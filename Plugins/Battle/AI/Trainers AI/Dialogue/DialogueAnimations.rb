class PokeBattle_Scene
    #=============================================================================
    # Animates an opposing trainer sliding off from from on-screen.
    #=============================================================================
    def pbUnshowOpponent(idxTrainer)
        # Set up trainer appearing animation
        appearAnim = TrainerDisappearAnimation.new(@sprites, @viewport, idxTrainer)
        @animations.push(appearAnim)
        # Play the animation
        pbUpdate while inPartyAnimation?
    end

    def trainerMovesInOut(trainerIndex, &block)
        pbShowOpponent(trainerIndex)
        block.call if block
        pbUnshowOpponent(trainerIndex)
    end

    def showTrainerDialogue(idxTrainer, &block)
        # Gather dialogue from event calls through the trainer's policies
        dialogue = []
        policies = @battle.opponent[idxTrainer].policies
        policies.each do |policy|
            dialogue = block.call(policy, dialogue)
        rescue StandardError
            pbMessage(_INTL("An error was encountered while trying to check for trainer dialogue."))
        end

        # Error state
        unless dialogue
            echoln("Dialogue array somehow became null while trying to show trainer dialogue!")
            return
        end

        # If there's some dialogue schedule, move the trainer on screen,
        # display all the dialogue, then move the trainer off screen
        if dialogue.length != 0
            trainerMovesInOut(idxTrainer) do
                dialogue.each do |line|
                    line = globalMessageReplacements(line)
                    pbDisplayPausedMessage(line)
                end
            end
        end
    end
end

#===============================================================================
# Make an enemy trainer slide off-screen to the right.
#===============================================================================
class TrainerDisappearAnimation < PokeBattle_Animation
    def initialize(sprites, viewport, idxTrainer)
        @idxTrainer = idxTrainer
        super(sprites, viewport)
    end

    def createProcesses
        delay = 0
        # Make old trainer sprite move off-screen first if necessary
        if @sprites["trainer_#{@idxTrainer + 1}"].visible
            trainer = addSprite(@sprites["trainer_#{@idxTrainer + 1}"], PictureOrigin::Bottom)
            trainer.moveDelta(delay, 8, Graphics.width / 4, 0)
            trainer.setVisible(delay + 8, false)
            delay = trainer.totalDuration
        end
    end
end
