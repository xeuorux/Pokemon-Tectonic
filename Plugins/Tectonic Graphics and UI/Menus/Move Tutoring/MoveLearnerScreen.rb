#===============================================================================
# Screen class for handling game logic
#===============================================================================
class MoveLearnerScreen
    def initialize(scene)
      @scene = scene
    end
  
    def pbStartScreen(pkmn,moves,addFirstMove=false)
      @scene.pbStartScene(pkmn, moves)
      loop do
        move = @scene.pbChooseMove
        if move
          if @scene.pbConfirm(_INTL("Teach {1}?", GameData::Move.get(move).name))
            if pbLearnMove(pkmn, move, false, false, addFirstMove)
              @scene.pbEndScene
              return true
            end
          end
        else
          @scene.pbEndScene
          return false
        end
      end
    end
  end