#===============================================================================
# Shows a Pokémon being recalled into its Poké Ball
#===============================================================================
class BattlerRecallAnimation < PokeBattle_Animation
    include PokeBattle_BallAnimationMixin
  
    def initialize(sprites,viewport,idxBattler)
      @idxBattler = idxBattler
      super(sprites,viewport)
    end
  
    def createProcesses
      batSprite = @sprites["pokemon_#{@idxBattler}"]
      shaSprite = @sprites["shadow_#{@idxBattler}"]
      # Calculate the Poké Ball graphic to use
      poke_ball = (batSprite.pkmn) ? batSprite.pkmn.poke_ball : nil
      # Calculate the color to turn the battler sprite
      col = getBattlerColorFromPokeBall(poke_ball)
      col.alpha = 0
      # Calculate end coordinates for battler sprite movement
      ballPos = PokeBattle_SceneConstants.pbBattlerPosition(@idxBattler,batSprite.sideSize)
      battlerEndX = ballPos[0]
      battlerEndY = ballPos[1]
      # Set up battler sprite
      battler = addSprite(batSprite,PictureOrigin::Bottom)
      battler.setVisible(0,true)
      battler.setColor(0,col)
      # Set up Poké Ball sprite
      ball = addBallSprite(battlerEndX,battlerEndY,poke_ball)
      ball.setZ(0,batSprite.z+1)
      # Poké Ball animation
      ballOpenUp(ball,0,poke_ball)
      delay = ball.totalDuration
      ballBurstRecall(delay,battlerEndX,battlerEndY,poke_ball)
      ball.moveOpacity(10,2,0)
      # Battler animation
      battlerAbsorb(battler,delay,battlerEndX,battlerEndY,col)
      if shaSprite.visible
        # Set up shadow sprite
        shadow = addSprite(shaSprite,PictureOrigin::Center)
        # Shadow animation
        shadow.moveOpacity(0,10,0)
        shadow.setVisible(delay,false)
      end
    end
end