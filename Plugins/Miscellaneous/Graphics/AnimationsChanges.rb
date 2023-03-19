# pbFadeOutIn(z) { block }
# Fades out the screen before a block is run and fades it back in after the
# block exits.  z indicates the z-coordinate of the viewport used for this effect
def pbFadeOutIn(z=99999,nofadeout=false)
  col=Color.new(0,0,0,0)
  viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z=z
  numFrames = (Graphics.frame_rate*0.25).floor
  alphaDiff = (255.0/numFrames).ceil
  for j in 0..numFrames
    col.set(0,0,0,j*alphaDiff)
    viewport.color=col
    Graphics.update
    Input.update
  end
  pbPushFade
  begin
    yield if block_given?
  ensure
    pbPopFade
    if !nofadeout
      for j in 0..numFrames
        col.set(0,0,0,(numFrames-j)*alphaDiff)
        viewport.color=col
        Graphics.update
        Input.update
      end
    end
    viewport.dispose
  end
end

#===============================================================================
# Makes a Pokémon's ability bar appear
#===============================================================================
class AbilitySplashAppearAnimation < PokeBattle_Animation
  def initialize(sprites,viewport,side)
    @side = side
    super(sprites,viewport)
  end

  def createProcesses
    return if !@sprites["abilityBar_#{@side}"]
    bar = addSprite(@sprites["abilityBar_#{@side}"])
    bar.setVisible(0,true)
    dir = (@side==0) ? 1 : -1
	  duration = fastTransitions? ? 4 : 8
    bar.moveDelta(0,duration,dir*Graphics.width/2,0)
  end
end

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

#===============================================================================
# Makes a side's tribe bar disappear
#===============================================================================
class TribeSplashDisappearAnimation < PokeBattle_Animation
  def initialize(sprites,viewport,side)
    @side = side
    super(sprites,viewport)
  end

  def createProcesses
    return if !@sprites["tribeBar_#{@side}"]
    bar = addSprite(@sprites["tribeBar_#{@side}"])
    dir = (@side==0) ? -1 : 1
	  duration = fastTransitions? ? 4 : 8
    bar.moveDelta(0,duration,dir*Graphics.width/2,0)
    bar.setVisible(duration,false)
  end
end

def fastTransitions?
  return $PokemonSystem.battle_transitions == 1
end