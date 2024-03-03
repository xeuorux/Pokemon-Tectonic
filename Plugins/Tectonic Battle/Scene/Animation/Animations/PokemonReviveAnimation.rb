#===============================================================================
# Shows a Pokémon reviving directly after fainting.
#===============================================================================
class PokemonReviveAnimation < PokeBattle_Animation
    include PokeBattle_BallAnimationMixin

    def initialize(sprites,viewport,battler)
      @battler        = battler
      @shadowVisible  = sprites["shadow_#{battler.index}"].visible
      @sprites        = sprites
      @viewport       = viewport
      @pictureEx      = []   # For all the PictureEx
      @pictureSprites = []   # For all the sprites
      @tempSprites    = []   # For sprites that exist only for this animation
      @animDone       = false
      createProcesses
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
      finalPosition = PokeBattle_SceneConstants.pbBattlerPosition(@battler.index,batSprite.sideSize)
      battlerStartX = finalPosition[0]
      battlerStartY = finalPosition[1]
      battlerEndX = batSprite.x
      battlerEndY = batSprite.y
      # Set up battler sprite
      battler = addSprite(batSprite,PictureOrigin::Bottom)
      battler.setXY(0,battlerStartX,battlerStartY)
      battler.setZoom(0,0)
      battler.setColor(0,col)
      # Battler animation
      delay = 0
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