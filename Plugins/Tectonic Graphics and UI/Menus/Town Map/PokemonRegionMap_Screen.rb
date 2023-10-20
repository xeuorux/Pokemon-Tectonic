class PokemonRegionMapScreen
    def initialize(scene)
      @scene = scene
    end
  
    def pbStartFlyScreen
      @scene.pbStartScene(false,1)
      ret = @scene.pbMapScene(1)
      @scene.pbEndScene
      return ret
    end
  
    def pbStartScreen
      @scene.pbStartScene($DEBUG)
      @scene.pbMapScene
      @scene.pbEndScene
    end
    
    def pbStartWaypointScreen
      @scene.pbStartScene(false,2)
      ret = @scene.pbMapScene(2)
      @scene.pbEndScene
      return ret
    end
  end