class LineupAppearAnimation < PokeBattle_Animation
    def initialize(sprites,viewport,side,party,ballCount,partyStarts,fullAnim)
        @side        = side
        @party       = party
        @partyStarts = partyStarts
        @ballCount   = ballCount
        @fullAnim    = fullAnim   # True at start of battle, false when switching
        resetGraphics(sprites)
        super(sprites,viewport)
      end


    def resetGraphics(sprites)
        bar = sprites["partyBar_#{@side}"]
        case @side
        when 0   # Player's lineup
          barX  = Graphics.width - BAR_DISPLAY_WIDTH
          barY  = Graphics.height - 142
          ballX = barX + 44
          ballY = barY - 30
        when 1   # Opposing lineup
          barX  = BAR_DISPLAY_WIDTH
          barY  = 114
          ballX = barX - 44 - 30   # 30 is width of ball icon
          ballY = barY - 30
          barX  -= bar.bitmap.width
        end
        ballXdiff = 32*(1-2*@side)
        bar.x       = barX
        bar.y       = barY
        bar.opacity = 255
        bar.visible = false
        for i in 0...@ballCount
          ball = sprites["partyBall_#{@side}_#{i}"]
          if i > 0 && i % PokeBattle_SceneConstants::NUM_BALLS == 0
            ballX -= ballXdiff * PokeBattle_SceneConstants::NUM_BALLS
          end
          ball.x       = ballX
          ball.y       = ballY - 36 * (i / PokeBattle_SceneConstants::NUM_BALLS)
          ball.opacity = 255
          ball.visible = false
          ballX += ballXdiff
        end
    end

    def getPartyIndexFromBallIndex(idxBall)
      # Player's lineup (just show balls for player's party)
      if @side==0
        return idxBall if @partyStarts.length<2
        return idxBall if idxBall<@partyStarts[1]
        return -1
      end
      # Opposing lineup
      # NOTE: This doesn't work well for 4+ opposing trainers.
      ballsPerTrainer = @ballCount/@partyStarts.length   # 6/3/2
      startsIndex = idxBall/ballsPerTrainer
      teamIndex = idxBall%ballsPerTrainer
      ret = @partyStarts[startsIndex]+teamIndex
      if startsIndex<@partyStarts.length-1
        # There is a later trainer, don't spill over into its team
        return -1 if ret>=@partyStarts[startsIndex+1]
      end
      return ret
    end

    def createProcesses
      bar = addSprite(@sprites["partyBar_#{@side}"])
      bar.setVisible(0,true)
      dir = (@side==0) ? 1 : -1
      bar.setDelta(0,dir*Graphics.width/2,0)
      bar.moveDelta(0,8,-dir*Graphics.width/2,0)
      delay = bar.totalDuration
      for i in 0...@ballCount
        createBall(i,(@fullAnim) ? delay+i*2 : 0,dir)
      end
    end
end