#===============================================================================
# Shows a Pokémon being sent out on the player's side (including by a partner).
# Includes the Poké Ball being thrown.
#===============================================================================
class PokeballPlayerSendOutAnimation < PokeBattle_Animation
    include PokeBattle_BallAnimationMixin
  
    def initialize(sprites,viewport,idxTrainer,battler,startBattle,idxOrder=0)
      @idxTrainer     = idxTrainer
      @battler        = battler
      @showingTrainer = startBattle
      @idxOrder       = idxOrder
      @trainer        = @battler.battle.pbGetOwnerFromBattlerIndex(@battler.index)
      sprites["pokemon_#{battler.index}"].visible = false
      @shadowVisible = sprites["shadow_#{battler.index}"].visible
      sprites["shadow_#{battler.index}"].visible = false
      super(sprites,viewport)
    end
  
    def createProcesses
      batSprite = @sprites["pokemon_#{@battler.index}"]
      shaSprite = @sprites["shadow_#{@battler.index}"]
      traSprite = @sprites["player_#{@idxTrainer}"]
      # Calculate the Poké Ball graphic to use
      poke_ball = (batSprite.pkmn) ? batSprite.pkmn.poke_ball : nil
      # Calculate the color to turn the battler sprite
      col = getBattlerColorFromPokeBall(poke_ball)
      col.alpha = 255
      # Calculate start and end coordinates for battler sprite movement
      ballPos = PokeBattle_SceneConstants.pbBattlerPosition(@battler.index,batSprite.sideSize)
      battlerStartX = ballPos[0]   # Is also where the Ball needs to end
      battlerStartY = ballPos[1]   # Is also where the Ball needs to end + 18
      battlerEndX = batSprite.x
      battlerEndY = batSprite.y
      # Calculate start and end coordinates for Poké Ball sprite movement
      ballStartX = -6
      ballStartY = 202
      ballMidX = 0   # Unused in trajectory calculation
      ballMidY = battlerStartY-144
      # Set up Poké Ball sprite
      ball = addBallSprite(ballStartX,ballStartY,poke_ball)
      ball.setZ(0,25)
      ball.setVisible(0,false)
      # Poké Ball tracking the player's hand animation (if trainer is visible)
      if @showingTrainer && traSprite && traSprite.x>0
        ball.setZ(0,traSprite.z-1)
        ballStartX, ballStartY = ballTracksHand(ball,traSprite)
      end
      delay = ball.totalDuration   # 0 or 7
      # Poké Ball trajectory animation
      createBallTrajectory(ball,delay,12,
         ballStartX,ballStartY,ballMidX,ballMidY,battlerStartX,battlerStartY-18)
      ball.setZ(9,batSprite.z-1)
      if textFast?
        delay = ball.totalDuration + 2
        delay += 6 * @idxOrder   # Stagger appearances if multiple Pokémon are sent out at once
      else
        delay = ball.totalDuration + 4
        delay += 10 * @idxOrder   # Stagger appearances if multiple Pokémon are sent out at once
      end
      ballOpenUp(ball,delay-2,poke_ball)
      ballBurst(delay,battlerStartX,battlerStartY-18,poke_ball)
      ball.moveOpacity(delay+2,2,0)
      # Set up battler sprite
      battler = addSprite(batSprite,PictureOrigin::Bottom)
      battler.setXY(0,battlerStartX,battlerStartY)
      battler.setZoom(0,0)
      battler.setColor(0,col)
      # Battler animation
      battlerAppear(battler,delay,battlerEndX,battlerEndY,batSprite,col)
      if @shadowVisible
        # Set up shadow sprite
        shadow = addSprite(shaSprite,PictureOrigin::Center)
        shadow.setOpacity(0,0)
        # Shadow animation
        shadow.setVisible(delay,@shadowVisible)
        shadow.moveOpacity(delay+5,10,255)
      end
    end
end