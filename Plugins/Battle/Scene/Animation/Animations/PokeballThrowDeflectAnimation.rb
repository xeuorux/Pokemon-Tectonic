#===============================================================================
# Shows the player throwing a Poké Ball and it being deflected
#===============================================================================
class PokeballThrowDeflectAnimation < PokeBattle_Animation
    include PokeBattle_BallAnimationMixin
  
    def initialize(sprites,viewport,poke_ball,battler)
      @poke_ball = poke_ball
      @battler   = battler
      super(sprites,viewport)
    end
  
    def createProcesses
      # Calculate start and end coordinates for battler sprite movement
      batSprite = @sprites["pokemon_#{@battler.index}"]
      ballPos = PokeBattle_SceneConstants.pbBattlerPosition(@battler.index,batSprite.sideSize)
      ballStartX = -6
      ballStartY = 246
      ballMidX   = 190   # Unused in arc calculation
      ballMidY   = 78
      ballEndX   = ballPos[0]
      ballEndY   = 112
      # Set up Poké Ball sprite
      ball = addBallSprite(ballStartX,ballStartY,@poke_ball)
      ball.setZ(0,90)
      # Poké Ball arc animation
      ball.setSE(0,"Battle throw")
      createBallTrajectory(ball,0,16,
         ballStartX,ballStartY,ballMidX,ballMidY,ballEndX,ballEndY)
      # Poké Ball knocked back
      delay = ball.totalDuration
      ball.setSE(delay,"Battle ball drop")
      ball.moveXY(delay,8,-32,Graphics.height-96+32)   # Back to player's corner
      createBallTumbling(ball,delay,8)
    end
end