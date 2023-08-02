ItemHandlers::UseFromBag.add(:ITEMFINDER,proc { |item|
  next 2
})

ItemHandlers::UseFromBag.copy(:ITEMFINDER,:DOWSINGMCHN,:DOWSINGMACHINE)

ItemHandlers::UseInField.add(:ITEMFINDER,proc { |item|
    event = pbClosestHiddenItem
    if !event
      pbMessage(_INTL("... \\wt[10]... \\wt[10]... \\wt[10]...\\wt[10]Nope! There's no response."))
    else
      offsetX = event.x-$game_player.x
      offsetY = event.y-$game_player.y
      if offsetX==0 && offsetY==0   # Standing on the item, spin around
        4.times do
          pbWait(Graphics.frame_rate*2/10)
          $game_player.turn_right_90
        end
        pbWait(Graphics.frame_rate*3/10)
        pbMessage(_INTL("The {1}'s indicating something right underfoot!",GameData::Item.get(item).name))
      else   # Item is nearby, face towards it
        direction = $game_player.direction
        if offsetX.abs>offsetY.abs
          direction = (offsetX<0) ? 4 : 6
        else
          direction = (offsetY<0) ? 8 : 2
        end
        case direction
        when 2 then $game_player.turn_down
        when 4 then $game_player.turn_left
        when 6 then $game_player.turn_right
        when 8 then $game_player.turn_up
        end
        pbWait(Graphics.frame_rate*3/10)
        pbMessage(_INTL("Huh? The {1}'s responding!\1",GameData::Item.get(item).name))
        pbMessage(_INTL("There's an item buried around here!"))
      end
    end
    next 1
  })
  
  ItemHandlers::UseInField.copy(:ITEMFINDER,:DOWSINGMCHN,:DOWSINGMACHINE)