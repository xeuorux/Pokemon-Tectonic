#===============================================================================
# Shows a Pokémon being sent out on the opposing side.
# Includes the Poké Ball being "thrown" (although here the Poké Ball just
# appears in the spot where it opens up rather than being thrown to there).
#===============================================================================
class PokeballTrainerSendOutAnimation < PokeBattle_Animation
  include PokeBattle_BallAnimationMixin

  def initialize(sprites,viewport,idxTrainer,battler,startBattle,idxOrder)
    @idxTrainer     = idxTrainer
    @battler        = battler
    @showingTrainer = startBattle
    @idxOrder       = idxOrder
    @trainer        = @battler.battle.pbGetOwnerFromBattlerIndex(@battler.index)
    sprites["pokemon_#{battler.index}"].visible = false
    @shadowVisible = sprites["shadow_#{battler.index}"].visible
    sprites["shadow_#{battler.index}"].visible = false
    @sprites        = sprites
    @viewport       = viewport
    @pictureEx      = []   # For all the PictureEx
    @pictureSprites = []   # For all the sprites
    @tempSprites    = []   # For sprites that exist only for this animation
    @animDone       = false
    if @trainer.wild?
      createWildProcesses
    else
      createProcesses
    end
  end

  def createWildProcesses
    batSprite = @sprites["pokemon_#{@battler.index}"]
    shaSprite = @sprites["shadow_#{@battler.index}"]
    finalLocationX = batSprite.x
    finalLocationY = batSprite.y
    battler = addSprite(batSprite,PictureOrigin::Bottom)
    battler.setXY(0,finalLocationX+240,finalLocationY)
    battler.setVisible(0,true)
    battler.setZoomXY(0,100,100)
    battler.setColor(0,Color.new(0,0,0,0))
    battler.moveXY(0,12,finalLocationX,finalLocationY)
    secondaryDelay = fastTransitions? ? 6 : 12
    battler.setCallback(secondaryDelay,[batSprite,:pbPlayIntroAnimation])
    if @shadowVisible
      # Set up shadow sprite
      shadow = addSprite(shaSprite,PictureOrigin::Center)
      shadow.setOpacity(0,0)
      # Shadow animation
      shadow.setVisible(0,@shadowVisible)
      shadow.moveOpacity(5,10,255)
    end
  end

  def createProcesses
    batSprite = @sprites["pokemon_#{@battler.index}"]
    shaSprite = @sprites["shadow_#{@battler.index}"]
    # Calculate the Poké Ball graphic to use
    poke_ball = (batSprite.pkmn) ? batSprite.pkmn.poke_ball : nil
    # Calculate the color to turn the battler sprite
    col = getBattlerColorFromPokeBall(poke_ball)
    col.alpha = 255
    # Calculate start and end coordinates for battler sprite movement
    ballPos = PokeBattle_SceneConstants.pbBattlerPosition(@battler.index,batSprite.sideSize)
    battlerStartX = ballPos[0]
    battlerStartY = ballPos[1]
    battlerEndX = batSprite.x
    battlerEndY = batSprite.y
    # Set up Poké Ball sprite
    ball = addBallSprite(0,0,poke_ball)
    ball.setZ(0,batSprite.z-1)
    # Poké Ball animation
    createBallTrajectory(ball,battlerStartX,battlerStartY)
    if fastTransitions?
        delay = ball.totalDuration+2
        delay += 10 if @showingTrainer   # Give time for trainer to slide off screen
        delay += 6 * @idxOrder   # Stagger appearances if multiple Pokémon are sent out at once
    else
        delay = ball.totalDuration+6
        delay += 10 if @showingTrainer   # Give time for trainer to slide off screen
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

  def createBallTrajectory(ball,destX,destY)
    # NOTE: In HGSS, there isn't a Poké Ball arc under any circumstance (neither
    #       when throwing out the first Pokémon nor when switching/replacing a
    #       fainted Pokémon). This is probably worth changing.
    ball.setXY(0,destX,destY-4)
  end
end