#===============================================================================
# Makes a Pokémon's data box appear
#===============================================================================
class DataBoxAppearAnimation < PokeBattle_Animation
    def initialize(sprites,viewport,idxBox)
      @idxBox = idxBox
      super(sprites,viewport)
    end
  
    def createProcesses
      return if !@sprites["dataBox_#{@idxBox}"]
      box = addSprite(@sprites["dataBox_#{@idxBox}"])
      box.setVisible(0,true)
      dir = ((@idxBox%2)==0) ? 1 : -1
      box.setDelta(0,dir*Graphics.width/2,0)
      duration = textFast? ? 5 : 8
      box.moveDelta(0,duration,-dir*Graphics.width/2,0)
    end
end