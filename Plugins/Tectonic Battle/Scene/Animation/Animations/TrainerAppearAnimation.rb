#===============================================================================
# Make an enemy trainer slide on-screen from the right. Makes the previous
# trainer slide off to the right first if it is on-screen.
# Used at the end of battle.
#===============================================================================
class TrainerAppearAnimation < PokeBattle_Animation
    def initialize(sprites,viewport,idxTrainer)
      @idxTrainer = idxTrainer
      super(sprites,viewport)
    end
  
    def createProcesses
      delay = 0
      # Make old trainer sprite move off-screen first if necessary
      if @idxTrainer>0 && @sprites["trainer_#{@idxTrainer}"].visible
        oldTrainer = addSprite(@sprites["trainer_#{@idxTrainer}"],PictureOrigin::Bottom)
        oldTrainer.moveDelta(delay,8,Graphics.width/4,0)
        oldTrainer.setVisible(delay+8,false)
        delay = oldTrainer.totalDuration
      end
      # Make new trainer sprite move on-screen
      if @sprites["trainer_#{@idxTrainer+1}"]
        trainerX, trainerY = PokeBattle_SceneConstants.pbTrainerPosition(1)
        trainerX += 64+Graphics.width/4
        newTrainer = addSprite(@sprites["trainer_#{@idxTrainer+1}"],PictureOrigin::Bottom)
        newTrainer.setVisible(delay,true)
        newTrainer.setXY(delay,trainerX,trainerY)
        newTrainer.moveDelta(delay,8,-Graphics.width/4,0)
      end
    end
end  