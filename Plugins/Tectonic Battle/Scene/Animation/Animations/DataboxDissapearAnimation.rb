#===============================================================================
# Makes a Pokémon's data box disappear
#===============================================================================
class DataBoxDisappearAnimation < PokeBattle_Animation
  def initialize(sprites,viewport,idxBox)
    @idxBox = idxBox
    super(sprites,viewport)
  end

  def createProcesses
    return if !@sprites["dataBox_#{@idxBox}"] || !@sprites["dataBox_#{@idxBox}"].visible
    box = addSprite(@sprites["dataBox_#{@idxBox}"])
    dir = ((@idxBox%2)==0) ? 1 : -1
    duration = fastTransitions? ? 5 : 8
    box.moveDelta(0,duration,dir*Graphics.width/2,0)
    box.setVisible(duration,false)
  end
end