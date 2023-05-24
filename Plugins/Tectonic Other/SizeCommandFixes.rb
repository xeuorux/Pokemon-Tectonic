class Game_Character
  def move_toward_player
	myXPos = @x + (@width-1) / 2.0
	playerXPos = ($game_player.x + ($game_player.width-1) / 2.0)
    xDifference = myXPos - playerXPos
	myYPos = @y - (@height-1) / 2.0
	playerYPos = ($game_player.y - ($game_player.height-1) / 2.0)
    yDifference = myYPos - playerYPos
    abs_xDif = xDifference.abs
    abs_yDif = yDifference.abs
	return if abs_xDif < @width && abs_yDif < @height
    if abs_xDif == abs_yDif
      (rand(2) == 0) ? abs_xDif += 1 : abs_yDif += 1
    end
    if abs_xDif > abs_yDif
      (xDifference > 0) ? move_left : move_right
      if !moving? && yDifference != 0
        (yDifference > 0) ? move_up : move_down
      end
    else
      (yDifference > 0) ? move_up : move_down
      if !moving? && xDifference != 0
        (xDifference > 0) ? move_left : move_right
      end
    end
  end

  def move_away_from_player
    myXPos = @x + (@width-1) / 2.0
	playerXPos = ($game_player.x + ($game_player.width-1) / 2.0)
    xDifference = myXPos - playerXPos
	myYPos = @y - (@height-1) / 2.0
	playerYPos = ($game_player.y - ($game_player.height-1) / 2.0)
    yDifference = myYPos - playerYPos
    abs_xDif = xDifference.abs
    abs_yDif = yDifference.abs
	return if abs_xDif < @width && abs_yDif < @height
    abs_xDif = xDifference.abs
    abs_yDif = yDifference.abs
    if abs_xDif == abs_yDif
      (rand(2) == 0) ? abs_xDif += 1 : abs_yDif += 1
    end
    if abs_xDif > abs_yDif
      (xDifference > 0) ? move_right : move_left
      if !moving? && yDifference != 0
        (yDifference > 0) ? move_down : move_up
      end
    else
      (yDifference > 0) ? move_down : move_up
      if !moving? && xDifference != 0
        (xDifference > 0) ? move_right : move_left
      end
    end
  end
end

class Game_Event < Game_Character
	attr_reader :width
	attr_reader :height
end

def pbExclaim(event,id=Settings::EXCLAMATION_ANIMATION_ID,tinting=false)
  if event.is_a?(Array)
    sprite = nil
    done = []
    for i in event
      if !done.include?(i.id)
		pbExclaim(i,id,tinting)
        done.push(i.id)
      end
    end
  else
	xPos = event.x
	xPos += (event.width-1)/2.0
	yPos = event.y
	yPos -= (event.height-1)/2.0
    sprite = $scene.spriteset.addUserAnimation(id,xPos,yPos,tinting,2)
  end
  while !sprite.disposed?
    Graphics.update
    Input.update
    pbUpdateSceneMap
  end
end

def pbNoticePlayer(event)
  if !pbFacingEachOther(event,$game_player)
    pbExclaim(event)
  end
  pbTurnTowardEvent($game_player,event)
  pbMoveTowardPlayer(event)
end

def noticePlayer
  pbNoticePlayer(get_self)
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