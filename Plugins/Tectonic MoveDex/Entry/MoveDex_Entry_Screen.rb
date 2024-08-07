class MoveDex_Entry_Screen
    def initialize(scene)
      @scene = scene
    end
  
    def pbStartScreen(moveList,index)
        index = @scene.pbStartScene(moveList,index)
        @scene.pbEndScene
        return index
    end
end