def pbSetEscapePoint
    $PokemonGlobal.escapePoint = [] if !$PokemonGlobal.escapePoint
    xco = $game_player.x
    yco = $game_player.y
    case $game_player.direction
    when 2   # Down
      yco -= 1
      dir = 8
    when 4   # Left
      xco += 1
      dir = 6
    when 6   # Right
      xco -= 1
      dir = 4
    when 8   # Up
      yco += 1
      dir = 2
    end
    $PokemonGlobal.escapePoint = [$game_map.map_id,xco,yco,dir]
  end
  
def pbEraseEscapePoint
    $PokemonGlobal.escapePoint = []
end

def pbSetPokemonCenter
    $PokemonGlobal.pokecenterMapId     = $game_map.map_id
    $PokemonGlobal.pokecenterX         = $game_player.x
    $PokemonGlobal.pokecenterY         = $game_player.y
    $PokemonGlobal.pokecenterDirection = $game_player.direction
end