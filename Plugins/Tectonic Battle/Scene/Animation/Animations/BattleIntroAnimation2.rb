#===============================================================================
# Shows wild Pokémon fading back to their normal color, and triggers their intro
# animations
#===============================================================================
class BattleIntroAnimation2 < PokeBattle_Animation
    def initialize(sprites,viewport,sideSize)
      @sideSize = sideSize
      super(sprites,viewport)
    end
  
    def createProcesses
      for i in 0...@sideSize
        idxBattler = 2*i+1
        next if !@sprites["pokemon_#{idxBattler}"]
        battler = addSprite(@sprites["pokemon_#{idxBattler}"],PictureOrigin::Bottom)
        battler.moveTone(0,4,Tone.new(0,0,0,0))
        battler.setCallback(10*i,[@sprites["pokemon_#{idxBattler}"],:pbPlayIntroAnimation])
      end
    end
end