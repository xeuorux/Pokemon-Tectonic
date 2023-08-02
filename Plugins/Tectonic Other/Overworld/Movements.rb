def pbTurnTowardEvent(event,otherEvent)
    sx = 0
    sy = 0
    if $MapFactory
      relativePos = $MapFactory.getThisAndOtherEventRelativePos(otherEvent,event)
      sx = relativePos[0]
      sy = relativePos[1]
    else
      sx = event.x - otherEvent.x
      sy = event.y - otherEvent.y
    end
    sx += (event.width - otherEvent.width) / 2.0
    sy -= (event.height - otherEvent.height) / 2.0
    return if sx == 0 && sy == 0
    if sx.abs > sy.abs
      (sx > 0) ? event.turn_left : event.turn_right
    else
      (sy > 0) ? event.turn_up : event.turn_down
    end
  end
  
  def pbJumpToward(dist=1,playSound=false,cancelSurf=false)
    x = $game_player.x
    y = $game_player.y
    case $game_player.direction
    when 2 then $game_player.jump(0, dist)    # down
    when 4 then $game_player.jump(-dist, 0)   # left
    when 6 then $game_player.jump(dist, 0)    # right
    when 8 then $game_player.jump(0, -dist)   # up
    end
    if $game_player.x!=x || $game_player.y!=y
      pbSEPlay("Player jump") if playSound
      $PokemonEncounters.reset_step_count if cancelSurf
      $PokemonTemp.endSurf = true if cancelSurf
      while $game_player.jumping?
        Graphics.update
        Input.update
        pbUpdateSceneMap
      end
      return true
    end
    return false
  end

def pbMoveTowardPlayer(event)
    maxsize = [$game_map.width, $game_map.height].max
    return if !pbEventCanReachPlayer?(event, $game_player, maxsize)
    loop do
      x = event.x
      y = event.y
      event.move_toward_player
      break if event.x == x && event.y == y # Stop if stuck
      while event.moving?
        Graphics.update
        Input.update
        pbUpdateSceneMap
      end
    end
    $PokemonMap.addMovedEvent(event.id) if $PokemonMap
  end