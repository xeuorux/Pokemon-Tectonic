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
