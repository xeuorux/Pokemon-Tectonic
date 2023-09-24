#===============================================================================
# Event locations, terrain tags
#===============================================================================
# NOTE: Assumes the event is 1x1 tile in size. Only returns one tile.
def pbFacingTile(direction=nil,event=nil)
    return $MapFactory.getFacingTile(direction,event) if $MapFactory
    return pbFacingTileRegular(direction,event)
  end
  
  # NOTE: Assumes the event is 1x1 tile in size. Only returns one tile.
  def pbFacingTileRegular(direction = nil, event = nil)
    event = $game_player if !event
    return [0, 0, 0] if !event
    x = event.x
    y = event.y
    direction = event.direction if !direction
    x_offset = [0, -1, 0, 1, -1, 0, 1, -1, 0, 1][direction]
    y_offset = [0, 1, 1, 1, 0, 0, 0, -1, -1, -1][direction]
    return [$game_map.map_id, x + x_offset, y + y_offset]
  end
  
  # Returns whether event is in line with the player, is facing the player and is
  # within distance tiles of the player.
  def pbEventFacesPlayer?(event, player, distance)
    return false if !event || !player || distance <= 0
    x_min = x_max = y_min = y_max = -1
    case event.direction
    when 2   # Down
      x_min = event.x
      x_max = event.x + event.width - 1
      y_min = event.y + 1
      y_max = event.y + distance
    when 4   # Left
      x_min = event.x - distance
      x_max = event.x - 1
      y_min = event.y - event.height + 1
      y_max = event.y
    when 6   # Right
      x_min = event.x + event.width
      x_max = event.x + event.width - 1 + distance
      y_min = event.y - event.height + 1
      y_max = event.y
    when 8   # Up
      x_min = event.x
      x_max = event.x + event.width - 1
      y_min = event.y - event.height + 1 - distance
      y_max = event.y - event.height
    else
      return false
    end
    return player.x >= x_min && player.x <= x_max &&
           player.y >= y_min && player.y <= y_max
  end
  
  # Returns whether event is able to walk up to the player.
  def pbEventCanReachPlayer?(event, player, distance, ignoreCollission = false)
    return false if !pbEventFacesPlayer?(event, player, distance)
    delta_x = (event.direction == 6) ? 1 : (event.direction == 4) ? -1 : 0
    delta_y = (event.direction == 2) ? 1 : (event.direction == 8) ? -1 : 0
    case event.direction
    when 2   # Down
      real_distance = player.y - event.y - 1
    when 4   # Left
      real_distance = event.x - player.x - 1
    when 6   # Right
      real_distance = player.x - event.x - event.width
    when 8   # Up
      real_distance = event.y - event.height - player.y
    end
    if real_distance > 0 && !ignoreCollission
      real_distance.times do |i|
        return false if !event.can_move_from_coordinate?(event.x + i * delta_x, event.y + i * delta_y, event.direction)
      end
    end
    return true
  end
  
  # Returns whether the two events are standing next to each other and facing each
  # other.
  def pbFacingEachOther(event1, event2)
    return pbEventFacesPlayer?(event1, event2, 1) && pbEventFacesPlayer?(event2, event1, 1)
  end
  