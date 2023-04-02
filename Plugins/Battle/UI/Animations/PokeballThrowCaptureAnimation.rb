#===============================================================================
# Shows the player's Poké Ball being thrown to capture a Pokémon
#===============================================================================
class PokeballThrowCaptureAnimation < PokeBattle_Animation
    include PokeBattle_BallAnimationMixin
  
    def initialize(sprites,viewport, poke_ball,numShakes,critCapture,battler,showingTrainer,velocityMult = 1.0)
      @poke_ball      = poke_ball
      @numShakes      = (critCapture) ? 1 : numShakes
      @critCapture    = critCapture
      @battler        = battler
      @showingTrainer = showingTrainer    # Only true if a Safari Zone battle
      @shadowVisible  = sprites["shadow_#{battler.index}"].visible
      @trainer        = battler.battle.pbPlayer
      @velocityMult = velocityMult
      baseBallThrowDuration = $PokemonSystem.battlescene == 1 ? 10 : 16
      @ballThrowDuration = (baseBallThrowDuration / @velocityMult.to_f).ceil
      @spedUp = $PokemonSystem.battlescene == 1
      super(sprites,viewport)
    end

    def createProcesses
      # Calculate start and end coordinates for battler sprite movement
      batSprite = @sprites["pokemon_#{@battler.index}"]
      shaSprite = @sprites["shadow_#{@battler.index}"]
      traSprite = @sprites["player_1"]
      ballPos = PokeBattle_SceneConstants.pbBattlerPosition(@battler.index,batSprite.sideSize)
      battlerStartX = batSprite.x
      battlerStartY = batSprite.y
      ballStartX = -6
      ballStartY = 246
      ballMidX   = 0   # Unused in arc calculation
      ballMidY   = -2 + @velocityMult * 80
      ballEndX   = ballPos[0]
      ballEndY   = 112
      ballEndY += 30 if @spedUp
      ballGroundY = ballPos[1]-4
      battleAnimationsDisabled = $PokemonSystem.battlescene == 2
      # Set up Poké Ball sprite
      if battleAnimationsDisabled
        ball = addBallSprite(ballEndX,ballGroundY,@poke_ball)
      else
        ball = addBallSprite(ballStartX,ballStartY,@poke_ball)
      end
      ball.setZ(0,batSprite.z+1)
      @ballSpriteIndex = (@numShakes>=4 || @critCapture) ? @tempSprites.length-1 : -1
      unless battleAnimationsDisabled
        # Set up trainer sprite (only visible in Safari Zone battles)
        if @showingTrainer && traSprite
          if traSprite.bitmap.width>=traSprite.bitmap.height*2
            trainer = addSprite(traSprite,PictureOrigin::Bottom)
            # Trainer animation
            ballStartX, ballStartY = trainerThrowingFrames(ball,trainer,traSprite)
          end
        end
        delay = ball.totalDuration   # 0 or 7
        # Poké Ball arc animation
        ball.setSE(delay,"Battle throw")
        createBallTrajectory(ball,delay,@ballThrowDuration,
          ballStartX,ballStartY,ballMidX,ballMidY,ballEndX,ballEndY)
        ball.setZ(9,batSprite.z+1)
        ball.setSE(delay+16,"Battle ball hit")
      end
      # Poké Ball opens up
      delay = ball.totalDuration+6
      ballOpenUp(ball,delay,@poke_ball,true,false)
      # Set up battler sprite
      battler = addSprite(batSprite,PictureOrigin::Bottom)
      # Poké Ball absorbs battler
      delay = ball.totalDuration
      ballBurstCapture(delay,ballEndX,ballEndY,@poke_ball)
      delay = ball.totalDuration+4
      # NOTE: The Pokémon does not change color while being absorbed into a Poké
      #       Ball during a capture attempt. This may be an oversight in HGSS.
      battler.setSE(delay,"Battle jump to ball")
      battler.moveXY(delay,5,ballEndX,ballEndY)
      battler.moveZoom(delay,5,0)
      battler.setVisible(delay+5,false)
      if @shadowVisible
        # Set up shadow sprite
        shadow = addSprite(shaSprite,PictureOrigin::Center)
        # Shadow animation
        shadow.moveOpacity(delay,5,0)
        shadow.moveZoom(delay,5,0)
        shadow.setVisible(delay+5,false)
      end
      # Poké Ball closes
      delay = battler.totalDuration
      ballSetClosed(ball,delay,@poke_ball)
      ball.moveTone(delay,3,Tone.new(96,64,-160,160))
      ball.moveTone(delay+5,3,Tone.new(0,0,0,0))
      # Poké Ball critical capture animation
      delay = ball.totalDuration+3
      if @critCapture
        ball.setSE(delay,"Battle ball shake")
        ball.moveXY(delay,1,ballEndX+4,ballEndY)
        ball.moveXY(delay+1,2,ballEndX-4,ballEndY)
        ball.moveXY(delay+3,2,ballEndX+4,ballEndY)
        ball.setSE(delay+4,"Battle ball shake")
        ball.moveXY(delay+5,2,ballEndX-4,ballEndY)
        ball.moveXY(delay+7,1,ballEndX,ballEndY)
        delay = ball.totalDuration+3
      end
      unless battleAnimationsDisabled
        # Poké Ball drops to the ground
        if @spedUp
          bounceDurs = [3,3,2,1]
        else
          bounceDurs = [4,4,3,2]
        end
        bounceHeights = [1,2,4,8]
        for i in 0...4
          t = bounceDurs[i]   # Time taken to rise or fall for each bounce
          d = bounceHeights[i]   # Fraction of the starting height each bounce rises to
          delay -= t if i==0
          if i>0
            ball.setZoomXY(delay,100+5*(5-i),100-5*(5-i))   # Squish
            ball.moveZoom(delay,2,100)                      # Unsquish
            ball.moveXY(delay,t,ballEndX,ballGroundY-(ballGroundY-ballEndY)/d)
          end
          ball.moveXY(delay+t,t,ballEndX,ballGroundY)
          ball.setSE(delay+2*t,"Battle ball drop",100-i*7)
          delay = ball.totalDuration
        end
        battler.setXY(ball.totalDuration,ballEndX,ballGroundY)
        # Poké Ball shakes
        delay = ball.totalDuration + (@spedUp ? 8 : 12)
        shakeDur = @spedUp ? 1 : 2
        for i in 0...[@numShakes,3].min
          ball.setSE(delay,"Battle ball shake")
          ball.moveXY(delay,shakeDur,ballEndX-2*(4-i),ballGroundY)
          ball.moveAngle(delay,shakeDur,5*(4-i))   # positive means counterclockwise
          ball.moveXY(delay+shakeDur,shakeDur*2,ballEndX+2*(4-i),ballGroundY)
          ball.moveAngle(delay+shakeDur,shakeDur*2,-5*(4-i))   # negative means clockwise
          ball.moveXY(delay+shakeDur*3,shakeDur,ballEndX,ballGroundY)
          ball.moveAngle(delay+shakeDur*3,shakeDur,0)
          delay = ball.totalDuration + (@spedUp ? 4 : 8)
        end
      end
      if @numShakes==0 || (@numShakes<4 && !@critCapture)
        # Poké Ball opens
        ball.setZ(delay,batSprite.z-1)
        ballOpenUp(ball,delay,@poke_ball,false)
        ballBurst(delay,ballEndX,ballGroundY,@poke_ball)
        ball.moveOpacity(delay+2,2,0)
        # Battler emerges
        col = getBattlerColorFromPokeBall(@poke_ball)
        col.alpha = 255
        battler.setColor(delay,col)
        battlerAppear(battler,delay,battlerStartX,battlerStartY,batSprite,col)
        if @shadowVisible
          shadow.setVisible(delay+5,true)
          shadow.setZoom(delay+5,100)
          shadow.moveOpacity(delay+5,10,255)
        end
      else
        # Pokémon was caught
        ballCaptureSuccess(ball,delay,ballEndX,ballGroundY)
      end
    end
  
    def dispose
      if @ballSpriteIndex>=0
        # Capture was successful, the Poké Ball sprite should stay around after
        # this animation has finished.
        @sprites["captureBall"] = @tempSprites[@ballSpriteIndex]
        @tempSprites[@ballSpriteIndex] = nil
      end
      super
    end
  end