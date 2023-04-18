#===============================================================================
# Makes a Pokémon's ability bar disappear
#===============================================================================
class AbilitySplashDisappearAnimation < PokeBattle_Animation
  def initialize(sprites,viewport,side)
    @side = side
    super(sprites,viewport)
  end

  def createProcesses
    return if !@sprites["abilityBar_#{@side}"]
    bar = addSprite(@sprites["abilityBar_#{@side}"])
    dir = (@side==0) ? -1 : 1
	  duration = fastTransitions? ? 4 : 8
    bar.moveDelta(0,duration,dir*Graphics.width/2,0)
    bar.setVisible(duration,false)
  end
end