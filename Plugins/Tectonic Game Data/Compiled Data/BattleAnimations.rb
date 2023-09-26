module Compiler
    module_function
  
    #=============================================================================
    # Compile battle animations
    #=============================================================================
    def compile_animations
      begin
        pbanims = load_data("Data/PkmnAnimations.rxdata")
      rescue
        pbanims = PBAnimations.new
      end
      changed = false
      move2anim = [[],[]]
      for i in 0...pbanims.length
        next if !pbanims[i]
        if pbanims[i].name[/^OppMove\:\s*(.*)$/]
          if GameData::Move.exists?($~[1])
            moveid = GameData::Move.get($~[1]).id_number
            changed = true if !move2anim[0][moveid] || move2anim[1][moveid] != i
            move2anim[1][moveid] = i
          end
        elsif pbanims[i].name[/^Move\:\s*(.*)$/]
          if GameData::Move.exists?($~[1])
            moveid = GameData::Move.get($~[1]).id_number
            changed = true if !move2anim[0][moveid] || move2anim[0][moveid] != i
            move2anim[0][moveid] = i
          end
        end
      end
      if changed
        save_data(move2anim,"Data/move2anim.dat")
        save_data(pbanims,"Data/PkmnAnimations.rxdata")
      end
    end
end

#===============================================================================
# Methods relating to battle animations data.
#===============================================================================
def pbLoadBattleAnimations
    $PokemonTemp = PokemonTemp.new if !$PokemonTemp
    if !$PokemonTemp.battleAnims
        if pbRgssExists?("Data/PkmnAnimations.rxdata")
        $PokemonTemp.battleAnims = load_data("Data/PkmnAnimations.rxdata")
        end
    end
    return $PokemonTemp.battleAnims
end

def pbLoadMoveToAnim
    $PokemonTemp = PokemonTemp.new if !$PokemonTemp
    if !$PokemonTemp.moveToAnim
        $PokemonTemp.moveToAnim = load_data("Data/move2anim.dat") || []
    end
    return $PokemonTemp.moveToAnim
end