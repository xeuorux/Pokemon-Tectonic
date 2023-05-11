#===============================================================================
# Makes a side's tribe bar appear
#===============================================================================
class TribeSplashAppearAnimation < PokeBattle_Animation
    def initialize(sprites,viewport,side)
      @side = side
      super(sprites,viewport)
    end
  
    def createProcesses
      return if !@sprites["tribeBar_#{@side}"]
      bar = addSprite(@sprites["tribeBar_#{@side}"])
      bar.setVisible(0,true)
      dir = (@side==0) ? 1 : -1
        duration = fastTransitions? ? 4 : 8
      bar.moveDelta(0,duration,dir*Graphics.width/2,0)
    end
end