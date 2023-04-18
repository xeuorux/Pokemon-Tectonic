#===============================================================================
  # Shows the player throwing a rock at a wild Pokémon in a Safari battle.
  #===============================================================================
  class ThrowRockAnimation < PokeBattle_Animation
    include PokeBattle_BallAnimationMixin
  
    def initialize(sprites,viewport,battler)
      @battler = battler
      @trainer = battler.battle.pbGetOwnerFromBattlerIndex(battler.index)
      super(sprites,viewport)
    end
  
    def createProcesses
      # Calculate start and end coordinates for battler sprite movement
      batSprite = @sprites["pokemon_#{@battler.index}"]
      traSprite = @sprites["player_1"]
      ballStartX = traSprite.x
      ballStartY = traSprite.y-traSprite.bitmap.height/2
      ballMidX   = 0   # Unused in arc calculation
      ballMidY   = 122
      ballEndX   = batSprite.x
      ballEndY   = batSprite.y-batSprite.bitmap.height/2
      # Set up trainer sprite
      trainer = addSprite(traSprite,PictureOrigin::Bottom)
      # Set up bait sprite
      ball = addNewSprite(ballStartX,ballStartY,
         "Graphics/Battle animations/safari_rock",PictureOrigin::Center)
      ball.setZ(0,batSprite.z+1)
      # Trainer animation
      if traSprite.bitmap.width>=traSprite.bitmap.height*2
        ballStartX, ballStartY = trainerThrowingFrames(ball,trainer,traSprite)
      end
      delay = ball.totalDuration   # 0 or 7
      # Bait arc animation
      ball.setSE(delay,"Battle throw")
      createBallTrajectory(ball,delay,12,
         ballStartX,ballStartY,ballMidX,ballMidY,ballEndX,ballEndY)
      ball.setZ(9,batSprite.z+1)
      delay = ball.totalDuration
      ball.setSE(delay,"Battle damage weak")
      ball.moveOpacity(delay+2,2,0)
      ball.setVisible(delay+4,false)
      # Set up anger sprite
      anger = addNewSprite(ballEndX-42,ballEndY-36,
         "Graphics/Battle animations/safari_anger",PictureOrigin::Center)
      anger.setVisible(0,false)
      anger.setZ(0,batSprite.z+1)
      # Show anger appearing
      delay = ball.totalDuration+5
      2.times do
        anger.setSE(delay,"Player jump")
        anger.setVisible(delay,true)
        anger.moveZoom(delay,3,130)
        anger.moveZoom(delay+3,3,100)
        anger.setVisible(delay+6,false)
        anger.setDelta(delay+6,96,-16)
        delay = anger.totalDuration+3
      end
    end
  end