#===============================================================================
# Screen class for handling game logic
#===============================================================================
class MoveLearnerScreen
    def initialize(scene)
      @scene = scene
    end
  
    def pbStartScreen(pkmn,moves,mentoring=false)
      @scene.pbStartScene(pkmn, moves)
      loop do
        move = @scene.pbChooseMove
        if move
          if @scene.pbConfirm(_INTL("Teach {1}?", GameData::Move.get(move).name))
            if pbLearnMove(pkmn, move)
              pkmn.add_first_move(move) if mentoring
              @scene.pbEndScene
              return true
            end
          end
        elsif @scene.pbConfirm(_INTL("Give up trying to teach a new move to {1}?", pkmn.name))
          @scene.pbEndScene
          return false
        end
      end
    end
  end