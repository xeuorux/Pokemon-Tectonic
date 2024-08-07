class MoveDex_Screen
    def initialize(scene)
      @scene = scene
    end
  
    def pbStartScreen
        @scene.pbStartScene
        @scene.pbEndScene
    end
end

def openMoveDex
    pbFadeOutIn do
        moveDexScene = MoveDex_Scene.new
        screen = MoveDex_Screen.new(moveDexScene)
        screen.pbStartScreen
    end
end