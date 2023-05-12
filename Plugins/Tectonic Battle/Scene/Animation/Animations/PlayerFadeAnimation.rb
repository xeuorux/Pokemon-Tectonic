#===============================================================================
# Shows the player (and partner) and the player party lineup sliding off screen.
# Shows the player's/partner's throwing animation (if they have one).
# Doesn't show the ball thrown or the Pokémon.
#===============================================================================
class PlayerFadeAnimation < PokeBattle_Animation
    def initialize(sprites,viewport,fullAnim=false)
      @fullAnim = fullAnim   # True at start of battle, false when switching
      super(sprites,viewport)
    end
  
    def createProcesses
      # NOTE: The movement speeds of trainers/bar/balls are all different.
      # Move trainer sprite(s) off-screen
      spriteNameBase = "player"
      i = 1
      while @sprites[spriteNameBase+"_#{i}"]
        pl = @sprites[spriteNameBase+"_#{i}"]
        i += 1
        next if !pl.visible || pl.x<0
        trainer = addSprite(pl,PictureOrigin::Bottom)
        trainer.moveDelta(0,16,-Graphics.width/2,0)
        # Animate trainer sprite(s) if they have multiple frames
        if pl.bitmap && !pl.bitmap.disposed? && pl.bitmap.width>=pl.bitmap.height*2
          size = pl.src_rect.width   # Width per frame
          trainer.setSrc(0,size,0)
          trainer.setSrc(5,size*2,0)
          trainer.setSrc(7,size*3,0)
          trainer.setSrc(9,size*4,0)
        end
        trainer.setVisible(16,false)
      end
      # Move and fade party bar/balls
      delay = 3
      if @sprites["partyBar_0"] && @sprites["partyBar_0"].visible
        partyBar = addSprite(@sprites["partyBar_0"])
        partyBar.moveDelta(delay,16,-Graphics.width/4,0) if @fullAnim
        partyBar.moveOpacity(delay,12,0)
        partyBar.setVisible(delay+12,false)
        partyBar.setOpacity(delay+12,255)
      end
      for i in 0...PokeBattle_SceneConstants::NUM_BALLS
        next if !@sprites["partyBall_0_#{i}"] || !@sprites["partyBall_0_#{i}"].visible
        partyBall = addSprite(@sprites["partyBall_0_#{i}"])
        partyBall.moveDelta(delay+2*i,16,-Graphics.width,0) if @fullAnim
        partyBall.moveOpacity(delay,12,0)
        partyBall.setVisible(delay+12,false)
        partyBall.setOpacity(delay+12,255)
      end
    end
end